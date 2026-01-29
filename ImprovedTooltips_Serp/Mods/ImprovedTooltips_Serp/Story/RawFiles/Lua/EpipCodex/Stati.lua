


---------------------------------------------
-- Implements a Codex section that displays stati and their applying/removal rules
-- based on vanilla Statuses.gameScript and Immunity/Cleanse stats 
---------------------------------------------
local EpipEncounters = Mods and Mods.EpipEncounters
local DataStructures = EpipEncounters.DataStructures
local Client = EpipEncounters.Client
local Epip = EpipEncounters.Epip
local Vector = EpipEncounters.Vector
local table = EpipEncounters.table
local Text = EpipEncounters.Text
local E_Stats = EpipEncounters.Stats
local Character = EpipEncounters.Character
local Timer = EpipEncounters.Timer
local GameState = EpipEncounters.GameState


local Set = DataStructures.Get("DataStructures_Set")
local Generic = Client.UI.Generic
local Codex = Epip.GetFeature("Feature_Codex")
local GridSectionClass = Codex:GetClass("Features.Codex.Sections.Grid")
local SearchBarPrefab = Generic.GetPrefab("GenericUI_Prefab_SearchBar")
local SlotPrefab = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local Icons = Epip.GetFeature("Feature_GenericUITextures").ICONS
local V = Vector.Create


---@class Features.Codex.Stati : Feature
local Stati = {
    _SearchTerm = "",

    -- Set of patterns to filter out invalid stati. Use lowercase only, as the matching is performed on the IDs in lowercase.
    KEYWORD_BLACKLIST_LOWER = Set.Create({ -- lowercase
        "script",
        "dummy",
        "quest",
        "aura",
    }),
    KEYWORD_BLACKLIST = Set.Create({
        "Infusion", -- filter template infusions
    }),
    KEYWORD_BLACKLIST_STARTSWITH = Set.Create({
        "PIP_", -- outdated Epic Enemies status
        "AMER_", -- outdated Epic Enemies status
    }),
    KEYWORD_BLACKLIST_MODSOURCE = Set.Create({
        "Epip", -- outdated Epic Enemies status
    }),

    Settings = {},
    TranslatedStrings = {
        Section_Description = {
            Handle = "h1f8a4b2c9d3e5f0a1b2c3d4e5f6a7b8c",
            Text = "Shows all game stati and how they apply (does not include special rules added by mods)",
            ContextDescription = "Description for Stati section",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsStatusValid = {}, ---@type Event<Feature_Codex_Stati_Hook_IsStatusValid>
    },
}
Epip.RegisterFeature("Codex_Stati", Stati)
local TSK = Stati.TranslatedStrings


---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Codex_Stati_Status
---@field ID string
---@field Stat StatsLib_StatsEntry_StatusData

---------------------------------------------
-- EVENTS AND HOOKS
---------------------------------------------

---@class Feature_Codex_Stati_Hook_IsStatusValid
---@field Stat StatsLib_StatsEntry_StatusData
---@field ID string
---@field Valid boolean Hookable. Defaults to `true`.

---------------------------------------------
-- SETTINGS
---------------------------------------------


---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the stati to render.
---@return Feature_Codex_Stati_Status[]
function Stati.GetStati()
    local allSstati = Ext.Stats.GetStats("StatusData")
    local stati = {} ---@type Feature_Codex_Stati_Status[]

    for _,id in ipairs(allSstati) do
      if Stati.IsStatusValid(id) then
        table.insert(stati, {Stat = E_Stats.Get("StatusData", id), ID = id})
      end
    end

    table.sort(stati, function (a, b)
      local displayNameA = Stati._GetStatusDisplayName(a.Stat)
      local displayNameB = Stati._GetStatusDisplayName(b.Stat)
      return displayNameA < displayNameB
    end)

    return stati
end

---Returns whether a Status is valid to be shown in the UI.
---@see Feature_Codex_Status_Hook_IsStatusValid
---@param id string
---@return boolean
function Stati.IsStatusValid(id)
    return Stati.Hooks.IsStatusValid:Throw({
        Stat = E_Stats.Get("StatsLib_StatsEntry_StatusData", id),
        ID = id,
        Valid = true,
    }).Valid
end

---------------------------------------------
-- PRIVATE METHODS
---------------------------------------------

---Returns the display name of a Status.
---@param stat StatsLib_StatsEntry_StatusData
---@return string
function Stati._GetStatusDisplayName(stat)
    return Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName) or stat.DisplayNameRef
end
function Stati._GetStatusDescription(stat)
    return Ext.L10N.GetTranslatedStringFromKey(stat.Description) or stat.DescriptionRef
end

---------------------------------------------
-- SECTION
---------------------------------------------

---@class Feature_Codex_Stati_Section : Features.Codex.Sections.Grid
local Section = {

    Name = Text.CommonStrings.Statuses,
    Description = TSK.Section_Description,
    Icon = "hotbar_icon_skills", -- TODO find a cooler one
    Settings = {
    },
    SEARCH_BAR_SIZE = V(170, 43),
    SEARCH_DELAY_TIMER_ID = "Feature_Codex_Stati_SearchDelay",
    SEARCH_DELAY = 0.7, -- In seconds.
}
Codex:RegisterClass("Feature_Codex_Stati_Section_SERP", Section, {"Features.Codex.Sections.Grid"})
Codex.RegisterSection("Stati_SERP", Section)

---@override
---@param root GenericUI_Element_Empty
function Section:Render(root)
    GridSectionClass.Render(self, root)
    -- Set up search bar
    local searchBar = SearchBarPrefab.Create(Codex.UI, "Stati_SearchBar", root, self.SEARCH_BAR_SIZE)
    searchBar.Events.SearchChanged:Subscribe(function (ev)
        Stati._SearchTerm = ev.Text
        -- Update the grid only after a delay.
        local existingTimer = Timer.GetTimer(self.SEARCH_DELAY_TIMER_ID)
        if existingTimer then
            existingTimer:Cancel()
        end
        Timer.Start(self.SEARCH_DELAY_TIMER_ID, self.SEARCH_DELAY, function (_)
            Section:UpdateStati()
        end)
    end)
end

---@override
function Section:Update(_)
    Section:UpdateStati()
end

---Updates the stati grid.
function Section:UpdateStati()
    local stati = Stati.GetStati()
    -- Stati:DebugLog("Updating stati")
    self:__Update(stati)
end

---@override
---@param index integer
---@return GenericUI_Prefab_HotbarSlot
function Section:__CreateElement(index)
    local instance = Codex.UI:CreateElement("Stati.Status." .. index, "GenericUI_Element_IggyIcon", self.Grid)
    instance:SetIcon("unknown", 58, 58) -- Use this call to set the icon when updating elements
    instance.Events.MouseOver:Subscribe(function (_)
      local StatusID = IndexToStatus[index]
      local stat = engineStatuses[StatusID] and engineStatuses[StatusID] or Ext.Stats.Get(StatusID)
      if stat and GameState.IsInSession() then
        local StatusLoc = GetTranslation(stat.DisplayName,StatusID) --Stati._GetStatusDisplayName(stat)
        StatusLoc = ColourizeStatus(StatusID,StatusLoc,true)
        local StatName = StatusLoc..(CurrentPressedKeys["Ctrl"] and " ("..StatusID..")" or "")
        local Desc = Stati._GetStatusDescription(stat)
        Desc = Desc..CreateStatusApplyTooltip(StatusID,nil,true,nil,Desc=="",true)
        local howtoremove = CreateStatusRemoveTooltip(StatusID)
        if howtoremove and howtoremove~="" then
          Desc = Desc.."\n\n"..howtoremove
        end
        if Desc~="" then
          Desc=Desc.."\n"
        end
        Desc = Desc..CreateStatusStackIdSavingThowTooltip(StatusID,true)
        local modsource = Mods.LeaderLib and Mods.LeaderLib.GameHelpers.Stats.GetModInfo(StatusID,true,false)
        if modsource and modsource~="" then
          if Desc~="" then
            Desc=Desc.."\n"
          end
          Desc = Desc.."<font color='#33AAFF' size='18'>"..modsource.."</font>"  
        end
        local attributes = GetStatusAttr(status,stat)
        local tooltip = {
            {
              Type = "StatName", --"ItemName",
              Label = StatName
            },
            {
              Type = "SkillDescription",
              Label = Desc,
            }
            -- {
              -- "Label" : "Wet",
              -- "Type" : "StatName"
            -- },
            -- {
              -- "Label" : "More vulnerable to electric and ice attacks.\n<font color='DA2121'>Water Resistance: -10%</font>\n<font color='DA2121'>Air Resistance: -20%</font>",
              -- "Type" : "StatusDescription"
            -- },
            -- {
              -- "Label" : "Fire Resistance: +10%",
              -- "Type" : "StatusBonus"
            -- },
            -- {
              -- "Label" : "Immunity to Shocked",
              -- "Type" : "StatusImmunity"
            -- },
            -- {
              -- "Label" : "Duration: 1 Turn<br><font face='Averia Serif' color='DBDBDB'>Applied by Fane</font>",
              -- "Type" : "StatusDescription"
            -- }
            
           }
        for attr,info in pairs(attributes) do
          local value = tostring(info.value)
          if value and value~="" and info.loc~="Skill: " then
            if not value:find("-",1,true) then
              value = "+"..value
            end
            value = ": "..value
            if (attr:lower():find("boost",1,true) and attr~="SPCostBoost" and attr~="APCostBoost") or attr:lower():find("chance",1,true) or attr:lower():find("resistance",1,true) then
              value = value.."%"
            end
          end
          table.insert(tooltip,{Type="StatusBonus", Label="<font color='6EB09D'>"..info.loc..value.."</font>"})
        end
        Client.Tooltip.ShowCustomFormattedTooltip({
          Elements = tooltip
          })
      end
    end)
    instance.Events.MouseOut:Subscribe(function (_)
        Codex.UI:HideTooltip()
    end)
    return instance
end

IndexToStatus = {}
function Section:__UpdateElement(index, instance, statusobj)
    -- print("__UpdateElement",index, instance, status)
    -- if index==1 then
      -- _D(status)
    -- end
    -- instance.ID == Stati.Status." .. index
    local StatusID = statusobj.ID
    IndexToStatus[index]=StatusID
    local stat = E_Stats.Get("StatsLib_StatsEntry_StatusData", StatusID)
    -- local stat = statusobj.Stat
    -- local StatsId = stat.StatsId
    instance:SetIcon(stat.Icon)
end


---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Default implementation of IsStatusValid.
Stati.Hooks.IsStatusValid:Subscribe(function (ev)
    local valid = ev.Valid
    local stat = ev.Stat
    local StatusID = ev.ID

    if valid then
    
        -- Check for blacklisted keywords in ID
        local lowercaseID = StatusID:lower()
        for pattern in Stati.KEYWORD_BLACKLIST_LOWER:Iterator() do
            if lowercaseID:match(pattern) then
                valid = false
                goto End
            end
        end
        for pattern in Stati.KEYWORD_BLACKLIST:Iterator() do
            if StatusID:match(pattern) then
                valid = false
                goto End
            end
        end
        for pattern in Stati.KEYWORD_BLACKLIST_STARTSWITH:Iterator() do
            if StatusID:find(pattern, 1, true)==1 then
                valid = false
                goto End
            end
        end
        for pattern in Stati.KEYWORD_BLACKLIST_MODSOURCE:Iterator() do
            local modsource = Mods.LeaderLib and Mods.LeaderLib.GameHelpers.Stats.GetModInfo(StatusID,true,true)
            if modsource and modsource==pattern then
                valid = false
                goto End
            end
        end

        local locName = GetTranslation(ev.Stat.DisplayName,StatusID) -- Stati._GetStatusDisplayName(ev.Stat)
        if locName==StatusID then -- no valid loc text
          valid = false
          goto End
        end
        local lowercaseName = locName:lower()

        -- Filter out stati with no display name or icon - these tend to be unobtainable stati that are not properly marked as such by the developer.
        if ev.Stat.DisplayName == "" then -- We cannot check for valid handles here as there are mods like Derpy's which set the text directly to this field.
            valid = false
            goto End
        elseif stat.Icon == "unknown" or stat.Icon == "" then
            valid = false
            goto End
        end

        -- Filter based on search term - should be done last for performance reasons
        local searchTerm = Stati._SearchTerm:lower()
        if searchTerm ~= "" then
            local searchMatches = lowercaseName:match(searchTerm) or lowercaseID:match(searchTerm) -- Name and ID search.
            if not searchMatches then
                valid = false
                goto End
            end
        end
    end

    ::End::

    ev.Valid = valid
end, {StringID = "DefaultImplementation"})


-- #################

-- __UpdateElement status:
-- {
    -- "ID" : "BONUSUNIQUES_TAINTEDSTEEL_DEBUFF_6",
    -- "Stat" :
    -- {
    -- "AbsorbSurfaceRange" : 0,
    -- "AbsorbSurfaceType" : "",
    -- "AiCalculationSkillOverride" : "",
    -- "ApplyAfterCleanse" : "No",
    -- "ApplyEffect" : "",
    -- "ApplyStatusOnTick" : "",
    -- "AuraAllies" : "",
    -- "AuraEnemies" : "",
    -- "AuraFX" : "",
    -- "AuraItems" : "",
    -- "AuraNeutrals" : "",
    -- "AuraRadius" : 0,
    -- "AuraSelf" : "",
    -- "BeamEffect" : "",
    -- "BonusFromAbility" : "None",
    -- "BringIntoCombat" : "Yes",
    -- "Charges" : 0,
    -- "CleanseStatuses" : "",
    -- "DamageCharacters" : "No",
    -- "DamageEvent" : "None",
    -- "DamageItems" : "No",
    -- "DamagePercentage" : 0,
    -- "DamageStats" : "",
    -- "DamageTorches" : "No",
    -- "DeathType" : "None",
    -- "DefendTargetPosition" : "No",
    -- "Description" : "BONUSUNIQUES_TAINTEDSTEEL_DEBUFF_Description",
    -- "DescriptionCaster" : "",
    -- "DescriptionParams" : "",
    -- "DescriptionRef" : "This characters' armor has begun to corrode, reducing it's Physical Resistance.<br>,
    -- "DescriptionTarget" : "",
    -- "DieAction" : "",
    -- "DisableInteractions" : "No",
    -- "DisplayName" : "BONUSUNIQUES_TAINTEDSTEEL_DEBUFF_6_DisplayName",
    -- "DisplayNameRef" : "Tainted Steel VI",
    -- "ForGameMaster" : "No",
    -- "ForceOverhead" : "No",
    -- "ForceStackOverwrite" : "No",
    -- "FormatColor" : "Poison",
    -- "FreezeCooldowns" : "No",
    -- "FreezeTime" : 0,
    -- "HealEffectId" : "",
    -- "HealMultiplier" : 0,
    -- "HealStat" : "None",
    -- "HealType" : "FixedValue",
    -- "HealValue" : 0,
    -- "HealingEvent" : "None",
    -- "Icon" : "BonusUniques_Status_TaintedSteel",
    -- "ImmuneFlag" : "None",
    -- "InitiateCombat" : "Yes",
    -- "Instant" : "No",
    -- "IsChanneled" : "No",
    -- "IsDisarmed" : "No",
    -- "IsInvulnerable" : "No",
    -- "IsResistingDeath" : "No",
    -- "Items" : "",
    -- "LeaveAction" : "",
    -- "LoseBoost" : null,
    -- "LoseControl" : "No",
    -- "Material" : "",
    -- "MaterialApplyArmor" : "No",
    -- "MaterialApplyBody" : "No",
    -- "MaterialApplyNormalMap" : "No",
    -- "MaterialApplyWeapon" : "No",
    -- "MaterialFadeAmount" : 0,
    -- "MaterialOverlayOffset" : 0,
    -- "MaterialParameters" : "",
    -- "MaterialType" : "None",
    -- "MaxCharges" : 0,
    -- "MaxCleanseCount" : 0,
    -- "Necromantic" : "No",
    -- "OnlyWhileMoving" : "No",
    -- "OverrideDefaultDescription" : "No",
    -- "PeaceOnly" : "No",
    -- "PermanentOnTorch" : "No",
    -- "PlayerHasTag" : "",
    -- "PlayerSameParty" : "No",
    -- "PolymorphResult" : "",
    -- "Projectile" : "",
    -- "Radius" : 0,
    -- "ResetCooldowns" : "",
    -- "ResetOncePerCombat" : "No",
    -- "RetainSkills" : "",
    -- "SavingThrow" : "None",
    -- "ScaleWithVitality" : "No",
    -- "ShouldAttachToCaster" : "No",
    -- "Skills" : "",
    -- "SoundLoop" : "",
    -- "SoundStart" : "",
    -- "SoundStop" : "",
    -- "StackId" : "BonusUniques_Stack_TaintedSteel_Debuff",
    -- "StackPriority" : 5,
    -- "StatsId" : "BonusUniques_Stats_TaintedSteel_Debuff_6",
    -- "StatusEffect" : "",
    -- "StatusEffectOnTurn" : "",
    -- "StatusEffectOverrideForItems" : "",
    -- "StatusType" : "CONSUME",
    -- "SurfaceChange" : "",
    -- "TargetConditions" : "",
    -- "TargetEffect" : "",
    -- "TickSFX" : "",
    -- "Toggle" : "No",
    -- "VampirismType" : "None",
    -- "WeaponOverride" : "",
    -- "WinBoost" : null
    -- }
-- }