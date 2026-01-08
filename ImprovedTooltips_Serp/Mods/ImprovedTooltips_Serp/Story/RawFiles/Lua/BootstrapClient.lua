
-- Extender functions copy pasted to get the surface on position for client
local SurfaceFlags = {
	Ground = {
		Type = {
			Fire = 0x1000000,
			Water = 0x2000000,
			Blood = 0x4000000,
			Poison = 0x8000000,
			Oil = 0x10000000,
			Lava = 0x20000000,
			Source = 0x40000000,
			Web = 0x80000000,
			Deepwater = 0x100000000,
			Sulfurium = 0x200000000,
			--UNUSED = 0x400000000
		},
		State = {
			Blessed = 0x400000000000,
			Cursed = 0x800000000000,
			Purified = 0x1000000000000,
			--??? = 0x2000000000000
		},
		Modifier = {
			Electrified = 0x40000000000000,
			Frozen = 0x80000000000000,
		},
	},
	Cloud = {
		Type = {
			FireCloud = 0x800000000,
			WaterCloud = 0x1000000000,
			BloodCloud = 0x2000000000,
			PoisonCloud = 0x4000000000,
			SmokeCloud = 0x8000000000,
			ExplosionCloud = 0x10000000000,
			FrostCloud = 0x20000000000,
			Deathfog = 0x40000000000,
			ShockwaveCloud = 0x80000000000,
			--UNUSED = 0x100000000000
			--UNUSED = 0x200000000000
		},
		State = {
			Blessed = 0x4000000000000,
			Cursed = 0x8000000000000,
			Purified = 0x10000000000000,
			--UNUSED = 0x20000000000000
		},
		Modifier = {
			Electrified = 0x100000000000000,
			-- ElectrifiedDecay = 0x200000000000000,
			-- SomeDecay = 0x400000000000000,
			--UNUSED = 0x800000000000000
		}
	},
	--AI grid painted flags
	-- Irreplaceable = 0x4000000000000000,
	-- IrreplaceableCloud = 0x800000000000000,
}

local function SetSurfaceFromFlags(flags, data)
	for k,f in pairs(SurfaceFlags.Ground.Type) do
		if (flags & f) ~= 0 then
			data.Ground = k
		end
	end
	if data.Ground then
		for k,f in pairs(SurfaceFlags.Ground.Modifier) do
			if (flags & f) ~= 0 then
				data.Ground = data.Ground .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Ground.State) do
			if (flags & f) ~= 0 then
				data.Ground = data.Ground .. k
			end
		end
	end
	for k,f in pairs(SurfaceFlags.Cloud.Type) do
		if (flags & f) ~= 0 then
			data.Cloud = k
		end
	end
	if data.Cloud then
		for k,f in pairs(SurfaceFlags.Cloud.Modifier) do
			if (flags & f) ~= 0 then
				data.Cloud = data.Cloud .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Cloud.State) do
			if (flags & f) ~= 0 then
				data.Cloud = data.Cloud .. k
			end
		end
	end
end

local function _GetSurfaces(x, z, grid)
  local cell = grid:GetCellInfo(x, z)
  if cell then
    local data = { Cell=cell }
    if cell.Flags then
      SetSurfaceFromFlags(cell.Flags, data)
    end
    return data
  end
end


-- #########################


-- current version of Epip is preventing Game.Tooltip.Register.Surface from working, but using the one from Epip itself works
local EpipSurfaceTooltips = Mods and Mods.EpipEncounters and Mods.EpipEncounters.Client.Tooltip.Hooks.RenderSurfaceTooltip

local MissingExtenderSurfaces = {DeathfogCloud="c651b724-32e2-4e34-99b4-272826ac3e37"}

-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

---@param o1 any|table First object to compare
---@param o2 any|table Second object to compare
-- ignores metatables
local function equals(o1, o2)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end
    local keySet = {}
    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2) == false then
            return false
        end
        keySet[key1] = true
    end
    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

-- Osi.GetSurfaceNameByTypeIndex is not available on client..
local function _GetSurfaceNameByTypeIndex(s_index)
  return Ext.Enums.SurfaceType[s_index] and tostring(Ext.Enums.SurfaceType[s_index]) or "Unknown"
  
  -- for index,surface in pairs(Ext.Enums.SurfaceType) do
    -- print("_GetSurfaceNameByTypeIndex iterating..",surface,index,type(s_index),type(index))
    -- if s_index==index then
      -- return tostring(surface)
    -- end
  -- end
  -- return "Unknown"
end

-- Epip uses skill tooltips to display some tooltips, ignore them by checking if the tooltip has Cooldown
-- must load after Epip to notice this
local function IsValidSkillTooltip(tooltip)
  if tooltip and tooltip.Data then
    for _, entry in ipairs(tooltip.Data) do
      if entry["Type"]=="SkillCooldown" then
        return true
      end
    end
  end
  return false
end

-- Tooltip improvements
-- Game.Tooltip.Register
-- {
	-- "Ability" : "function: 00007FF473BEFE28",
	-- "CustomStat" : "function: 00007FF473C74848",
	-- "Generic" : "function: 00007FF473C74870",
	-- "Global" : "function: 00007FF473BEFE00",
	-- "Item" : "function: 00007FF473C74898",
	-- "PlayerPortrait" : "function: 00007FF473C748C0",
	-- "Pyramid" : "function: 00007FF473C748E8",
	-- "Rune" : "function: 00007FF473C74910",
	-- "Skill" : "function: 00007FF473C74938",
	-- "Stat" : "function: 00007FF473C74960",
	-- "Status" : "function: 00007FF473C74988",
	-- "Surface" : "function: 00007FF473C749B0",
	-- "Tag" : "function: 00007FF473C749D8",
	-- "Talent" : "function: 00007FF473C74A00",
	-- "World" : "function: 00007FF473C74A28"
-- }

-- Improve skill tooltips
-- Add Info about who can be targeted with a Skill
-- using color does not seem to work.. <font color='5ec2ffff'>
Game.Tooltip.Register.Skill(function(char, skill, tooltip)
  if IsValidSkillTooltip(tooltip) then
    local charGuid = char.MyGuid
    local MyStat = Ext.Stats.Get(skill)
    if MyStat then
      
      -- Info about surface a skill creates
      local surfaces = {}
      local SkillProperties = MyStat["SkillProperties"] -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
      if SkillProperties and type(SkillProperties)=="table" then
        -- Ext.Print("ImprovedTooltips Skill Tooltip SkillProperties",skill,_D(SkillProperties))
      -- [{	"Action" : "CreateSurface",
      -- "Arg1" : 3.0,
      -- "Arg2" : 0.0,
      -- "Arg3" : "Oil",
      -- "Arg4" : 1.0,
      -- "Arg5" : 0.0,
      -- "Context" : ["Target","AoE"],
      -- "StatusHealType" : "None",
      -- "Type" : "GameAction"}]
      -- Shout_PoisonWave
      -- [{"Action" : "TargetCreateSurface",
        -- "Arg1" : 4.0,
        -- "Arg2" : 0.0,
        -- "Arg3" : "PoisonCloud",
        -- "Arg4" : 1.0,
        -- "Arg5" : 1.0,
        -- "Context" :
        -- ["Self"],
        -- "StatusHealType" : "None",
        -- "Type" : "GameAction"}]
        for _,entry in pairs(SkillProperties) do
          if entry.Action=="CreateSurface" or entry.Action=="TargetCreateSurface" then
            table.insert(surfaces,{SurfaceType=entry.Arg3,SurfaceLifetime=entry.Arg2~=0 and entry.Arg2/6,SurfaceRadius=entry.Arg1,SurfaceStatusChance=nil})
          end
        end
      end
      local StatSurfaceType = MyStat.SurfaceType
      if StatSurfaceType and StatSurfaceType~="None" then
        table.insert(surfaces,{SurfaceType=StatSurfaceType,SurfaceLifetime=MyStat.SurfaceLifetime,SurfaceRadius=MyStat.SurfaceRadius,SurfaceStatusChance=MyStat.SurfaceStatusChance})
      end
      for _,surfaceinfo in ipairs(surfaces) do
        local SurfaceRadius = surfaceinfo.SurfaceRadius
        local SurfaceLifetime = surfaceinfo.SurfaceLifetime
        local SurfaceType = surfaceinfo.SurfaceType
        local SurfaceStatusChance = surfaceinfo.SurfaceStatusChance
        local SurfaceText = ""
        if SurfaceRadius and SurfaceRadius>0 then -- else it will be the AreaRadius/affected radius of the skill
          SurfaceText = SurfaceText.."SurfaceRadius: "..tostring(SurfaceRadius).." m\n"
        end
        if SurfaceLifetime and SurfaceLifetime>0 then
          SurfaceText = SurfaceText.."SurfaceLifetime: "..tostring(round(SurfaceLifetime/6,1)).." turns\n"
        elseif SurfaceType~="DamageType" then
          local status,template = pcall(Ext.Surface.GetTemplate,SurfaceType) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
          if status==false and MissingExtenderSurfaces[SurfaceType] then
            template = Ext.Template.GetTemplate(MissingExtenderSurfaces[SurfaceType])
            if not template then
              Ext.Print("ImprovedTooltips: Surface.GetTemplate faild (add it manually to MissingExtenderSurfaces) to get template for:",SurfaceType)
            end
          end
          if template then
            local DefaultLifeTime = template.DefaultLifeTime
            if DefaultLifeTime and DefaultLifeTime>0 then
              SurfaceText = SurfaceText.."SurfaceLifetime: "..tostring(round(DefaultLifeTime/6,1)).." turns\n"
            end
          end
        end
        if SurfaceStatusChance and SurfaceStatusChance>0 then
          SurfaceText = SurfaceText.."SurfaceStatusChance: "..tostring(SurfaceStatusChance).." %"
        end
        -- "\nSurfaceGrowStep: "..tostring(SurfaceGrowStep).."\nSurfaceGrowInterval: "..tostring(SurfaceGrowInterval) -- dont think Grow is important to know?
        local entry = {Type="SkillExplodeRadius",Label="Creates Surface "..tostring(SurfaceType).."\n"..SurfaceText}
        table.insert(tooltip.Data,entry)
      end
      
      local TargetConditions = MyStat["TargetConditions"]
      if TargetConditions then
        TargetConditions = TargetConditions:gsub("&!Spirit", "") -- remove this because true for nearly all skills
        TargetConditions = TargetConditions:gsub("!Spirit", "")
        if TargetConditions=="" then
          TargetConditions = "All"
        end
        local CanTarget = {}
        if MyStat.CanTargetCharacters=="Yes" then
          table.insert(CanTarget,"Char")
        end
        if MyStat.CanTargetTerrain=="Yes" then
          table.insert(CanTarget,"Ground")
        end
        if MyStat.CanTargetItems=="Yes" then
          table.insert(CanTarget,"Item")
        end
        local AreaRadius = MyStat.AreaRadius
        AreaRadius = AreaRadius and AreaRadius>0 and tostring(AreaRadius) or ""
        if AreaRadius~="" then
          local entry = {Type="SkillExplodeRadius",Value=tostring(AreaRadius).."m",Label="Area Radius:"} -- will display 2 times SkillExplodeRadius if it also has a vanilla exploderadius
          table.insert(tooltip.Data,entry)
        end
        local GroundSkillTypes = {"Path","Rain","Cone","Dome","Jump","Quake","Shout","Storm","Summon","Tornado","Wall","Zone"}
        if table_contains_value(GroundSkillTypes,MyStat.SkillType) then
          if not table_contains_value(CanTarget,"Ground") then
            table.insert(CanTarget,"Ground")
          end
        end
        
        local entry = {Type="SkillExplodeRadius",Label="Target Conditions: "..TargetConditions} -- not using Value here, because it is limited in characters, to many will not be displayed
        table.insert(tooltip.Data,entry)
        if #CanTarget>0 then
          local entry = {Type="SkillExplodeRadius",Value=table.concat(CanTarget, ","),Label="Can Target:"} -- will display 2 times SkillExplodeRadius if it also has a vanilla exploderadius
          table.insert(tooltip.Data,entry)
        end    
      end
      for _, entry in ipairs(tooltip.Data) do -- display left cooldown in tooltip, because icon does not display properly for higher than 99
        if entry.Type=="SkillRequiredEquipment" and entry.RequirementMet==false and char.SkillManager.Skills[skill] then
          local cooldownleft = char.SkillManager.Skills[skill].ActiveCooldown -- in seconds, not turns. 1 turn=6 seconds
          if cooldownleft~=0 then
            cooldownleft = tostring( math.ceil(cooldownleft / 6) )
            entry.Label = "("..cooldownleft..") "..entry.Label
          end
        end
      end
      -- for _, entry in ipairs(tooltip.Data) do
        -- for k,v in pairs(entry) do
          -- print(charGuid,skill,k,v)
        -- end
        -- print("...")
      -- end
      -- print("####")
    end
  end
end)


-- Surface Tooltip anpassen:
-- 1) Wasserschaden header von wasserfläche in Wasser umwandeln
-- 2) Stati die verursacht werden können mit Chance zufügen
-- Statuschance can be overriden by skill which caused it with SurfaceType SurfaceStatusChance, dont think we can catch it here..
local previoustooltipdata = nil
local previoussurface = nil
local function AdjustSurfaceTooltip(SurfaceType,tooltip)
  if SurfaceType and SurfaceType~="Unknown" then
    -- print(SurfaceType)
    -- _D(tooltip.Data)
    
    local issecondsurfaceofdouble = false -- Game.Tooltip.Register.Surface gets complicated for double surfaces, because its called twice, but tooltip.data already contains both surfaces
    if equals(previoustooltipdata,tooltip.Data) and previoussurface~=SurfaceType then
      issecondsurfaceofdouble = true
      -- print("issecondsurfaceofdouble",previoussurface,SurfaceType)
    end
    
    -- fix german surface titles saying "Water Damage" instead of "Water" (Wasserschaden instead of Wasser)
    for _,entry in ipairs(tooltip.Data) do
      if entry.Type=="Title" and entry.Label:find("schaden",1,true) then
        entry.Label = entry.Label:gsub("schaden","") -- remove the word "schaden" from the title of surfaces
      end
    end
    
    -- add status
    local status,template = pcall(Ext.Surface.GetTemplate,SurfaceType) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
    if status==false and MissingExtenderSurfaces[SurfaceType] then
      template = Ext.Template.GetTemplate(MissingExtenderSurfaces[SurfaceType])
      if not template then
        Ext.Print("ImprovedTooltips: Surface.GetTemplate failed (add it manually to MissingExtenderSurfaces) to get template for:",SurfaceType)
      end
    end
    if template then
      local Statuses = template.Statuses
      if Statuses then
        SurfaceStatusText = ""
        for _,statusinfo in pairs(Statuses) do
          if (statusinfo.StatusId~="FOGBLIND_SERP" or statusinfo.RemoveStatus==false) and statusinfo.ApplyToCharacters then -- I added in my mod MoreSurfaceEffects to all surfaces that they remove my status, that is not important to show
            local SStat = Ext.Stats.Get(statusinfo.StatusId)
            local statusname_loc = SStat and Ext.L10N.GetTranslatedStringFromKey(SStat.DisplayName,statusinfo.StatusId) or statusinfo.StatusId
            local addremove = statusinfo.RemoveStatus and "\n Removes " or "\n Adds "
            local IgnoresArmor = statusinfo.ForceStatus and "\n   Ignores Armor" or ""
            local KeepAlive = statusinfo.KeepAlive and "\n   Stays Active" or ""
            local OnlyWhileMoving = statusinfo.OnlyWhileMoving and "\n   Only While Moving" or ""
            local VanishOnReapply = statusinfo.VanishOnReapply and "\n   Removes Surface" or ""
            SurfaceStatusText = SurfaceStatusText..addremove..statusname_loc.."\n   Chance: "..tostring(round(statusinfo.Chance*100,2)).." %\n   Duration: "..tostring(round(statusinfo.Duration/6,1)).." turns"..IgnoresArmor..KeepAlive..VanishOnReapply
          end
        end
        if SurfaceStatusText~="" then
          local ignoredfirst = false
          for _,entry in ipairs(tooltip.Data) do
            if entry.Type=="SurfaceDescription" and not entry.Label:find(SurfaceStatusText,1,true) then
              if issecondsurfaceofdouble then
                if ignoredfirst then
                  entry.Label = entry.Label..SurfaceStatusText
                  break
                else
                  ignoredfirst = true
                end
              else
                entry.Label = entry.Label..SurfaceStatusText
                break
              end
            end
          end
        end
      end
      previoustooltipdata = tooltip.Data
      previoussurface = SurfaceType
    end
    
  end
end

if EpipSurfaceTooltips then
  EpipSurfaceTooltips:Subscribe(function (ev)
    if ev.Type=="Surface" then -- SurfaceIndex in ev.UI is totally wrong unfortunately 
      local tooltip = ev.Tooltip
      tooltip.Data = tooltip.Elements
      -- local cc = Ext.UI.GetCursorControl();_D(Ext.UI.GetByHandle(cc.TextDisplayUIHandle))
      -- print(ev.UI.SurfaceIndex,_GetSurfaceNameByTypeIndex(ev.UI.SurfaceIndex)) -- also wrong
      -- print(ev.UI.SurfaceIndex2,_GetSurfaceNameByTypeIndex(ev.UI.SurfaceIndex2))
      local cursor = Ext.UI.GetPickingState()
      if cursor and cursor.WalkablePosition then
        local x,y,z = table.unpack(cursor.WalkablePosition)
        local surfaces = _GetSurfaces(x, z, Ext.Entity.GetAiGrid())
        AdjustSurfaceTooltip(surfaces.Ground,tooltip)
        AdjustSurfaceTooltip(surfaces.Cloud,tooltip)
        -- {
          -- "Cell" : 
          -- {
            -- "AiFlags" : 
            -- [
              -- "Water",
              -- "WaterCloud"
            -- ],
            -- "CloudSurfaceType" : "WaterCloud",
            -- "Flags" : 68753031168,
            -- "GroundSurfaceType" : "Water",
            -- "Height" : -5.25,
            -- "Objects" : []
          -- },
          -- "Cloud" : "WaterCloud",
          -- "Ground" : "Water"
        -- }
      end
    end
  end)
else
  Game.Tooltip.Register.Surface(function(char,SurfaceType,tooltip)
    AdjustSurfaceTooltip(SurfaceType,tooltip)
  end)
end
-- Surface
-- {
	-- "ControllerEnabled" : false,
	-- "Data" : 
	-- [
		-- {
			-- "Label" : "Blut",
			-- "Type" : "Title"
		-- },
		-- {
			-- "Label" : "Kann unter Strom gesetzt und eingefroren werden.",
			-- "Type" : "SurfaceDescription"
		-- }
	-- ],
	-- "TooltipUIType" : 43,
	-- "UIType" : 43
-- }


-- Surface template
-- "Statuses" :
  -- [
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : false,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : true,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : false,
                  -- "StatusId" : "INVISIBLE",
                  -- "VanishOnReapply" : false
          -- },
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : true,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : false,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : true,
                  -- "StatusId" : "MUTED",
                  -- "VanishOnReapply" : false
          -- }
  -- ],


-- Game.Tooltip.Register.Surface: double surface tooltip.Data and the event is called twice:
-- [
	-- {
		-- "Label" : "Wasserschaden",
		-- "Type" : "Title"
	-- },
	-- {
		-- "Label" : "Kann unter Strom gesetzt und eingefroren werden.",
		-- "Type" : "SurfaceDescription"
	-- },
	-- {
		-- "Label" : "Dauer: 7 Runden",
		-- "Type" : "Duration"
	-- },
	-- {
		-- "Type" : "Splitter"
	-- },
	-- {
		-- "Label" : "Dampfwolke",
		-- "Type" : "Title"
	-- },
	-- {
		-- "Label" : "Hebt den Brennend-Statuseffekt auf.",
		-- "Type" : "SurfaceDescription"
	-- }
-- ]


-- EpipSurfaceTooltips
-- EpipSurfaceTooltips
-- {
	-- "Prevented" : true,
	-- "Tooltip" : 
	-- {
		-- "Data" : "*RECURSION*",
		-- "Elements" : 
		-- [
			-- {
				-- "Label" : "Wasserschaden",
				-- "Type" : "Title"
			-- },
			-- {
				-- "Label" : "Kann unter Strom gesetzt und eingefroren werden.",
				-- "Type" : "SurfaceDescription"
			-- },
			-- {
				-- "Label" : "Dauer: 10 Runden",
				-- "Type" : "Duration"
			-- },
			-- {
				-- "Type" : "Splitter"
			-- },
			-- {
				-- "Label" : "Dampfwolke",
				-- "Type" : "Title"
			-- },
			-- {
				-- "Label" : "Hebt den Brennend-Statuseffekt auf.",
				-- "Type" : "SurfaceDescription"
			-- }
		-- ]
	-- },
	-- "Type" : "Surface",
	-- "UI" : 
	-- {
		-- "AnchorId" : "",
		-- "AnchorObjectName" : "textDisplay_1",
		-- "AnchorPos" : "",
		-- "AnchorTPos" : "",
		-- "AnchorTarget" : "",
		-- "CaptureExternalInterfaceCalls" : "function: 00007FFE2F4F5980",
		-- "CaptureInvokes" : "function: 00007FFE2F4F59C0",
		-- "ChildUIHandle" : "userdata: 0000000000000000",
		-- "ClearCustomIcon" : "function: 00007FFE2F4F5B00",
		-- "CustomScale" : 1.0,
		-- "Destroy" : "function: 00007FFE2F4F58B0",
		-- "EnableCustomDraw" : "function: 00007FFE2F4F5A00",
		-- "ExternalInterfaceCall" : "function: 00007FFE2F4F58F0",
		-- "Flags" : 
		-- [
			-- "OF_DeleteOnChildDestroy",
			-- "OF_Loaded",
			-- "OF_Visible"
		-- ],
		-- "FlashMovieSize" : 
		-- [
			-- 1920.0,
			-- 1080.0
		-- ],
		-- "FlashSize" : 
		-- [
			-- 1920.0,
			-- 1080.0
		-- ],
		-- "ForceClearTooltipText" : false,
		-- "GetHandle" : "function: 00007FFE2F4F56D0",
		-- "GetPlayerHandle" : "function: 00007FFE2F4F5750",
		-- "GetPosition" : "function: 00007FFE2F4F5170",
		-- "GetRoot" : "function: 00007FFE2F4F5840",
		-- "GetTypeId" : "function: 00007FFE2F4F57E0",
		-- "GetUIScaleMultiplier" : "function: 00007FFE2F4F5B90",
		-- "GetValue" : "function: 00007FFE2F4F5610",
		-- "GotoFrame" : "function: 00007FFE2F4F5510",
		-- "HasAnchorPos" : false,
		-- "HasSurfaceText" : true,
		-- "Hide" : "function: 00007FFE2F4F5430",
		-- "InputFocused" : false,
		-- "Invoke" : "function: 00007FFE2F4F5470",
		-- "IsActive" : true,
		-- "IsDragging" : false,
		-- "IsDragging2" : false,
		-- "IsMoving2" : false,
		-- "IsUIMoving" : false,
		-- "Layer" : 11,
		-- "Left" : 0.0,
		-- "MinSize" : 
		-- [
			-- 0.0,
			-- 0.0
		-- ],
		-- "MovieLayout" : 6,
		-- "OF_Activated" : false,
		-- "OF_DeleteOnChildDestroy" : true,
		-- "OF_DontHideOnDelete" : false,
		-- "OF_FullScreen" : false,
		-- "OF_KeepCustomInScreen" : false,
		-- "OF_KeepInScreen" : false,
		-- "OF_Load" : false,
		-- "OF_Loaded" : true,
		-- "OF_PauseRequest" : false,
		-- "OF_PlayerInput1" : false,
		-- "OF_PlayerInput2" : false,
		-- "OF_PlayerInput3" : false,
		-- "OF_PlayerInput4" : false,
		-- "OF_PlayerModal1" : false,
		-- "OF_PlayerModal2" : false,
		-- "OF_PlayerModal3" : false,
		-- "OF_PlayerModal4" : false,
		-- "OF_PlayerTextInput1" : false,
		-- "OF_PlayerTextInput2" : false,
		-- "OF_PlayerTextInput3" : false,
		-- "OF_PlayerTextInput4" : false,
		-- "OF_PrecacheUIData" : false,
		-- "OF_PreventCameraMove" : false,
		-- "OF_RequestDelete" : false,
		-- "OF_SortOnAdd" : false,
		-- "OF_Visible" : true,
		-- "ParentUIHandle" : "userdata: 0000000000000000",
		-- "Path" : "E:/Spiele/GOG Games/Divinity - Original Sin 2/DefEd/Data/Public/Game/GUI/textDisplay.swf",
		-- "PlayerId" : 1,
		-- "RenderDataPrepared" : true,
		-- "RenderOrder" : 26,
		-- "RequestClearTooltipText" : false,
		-- "Resize" : "function: 00007FFE2F4F5310",
		-- "Right" : 0.0,
		-- "SetCustomIcon" : "function: 00007FFE2F4F5A40",
		-- "SetCustomPortraitIcon" : "function: 00007FFE2F4F5AA0",
		-- "SetPosition" : "function: 00007FFE2F4F5210",
		-- "SetValue" : "function: 00007FFE2F4F5670",
		-- "Show" : "function: 00007FFE2F4F53F0",
		-- "SurfaceIndex" : 8,
		-- "SurfaceIndex2" : 6,
		-- "SurfaceTurns" : 10,
		-- "SurfaceTurns2" : 0,
		-- "SysPanelPosition" : 
		-- [
			-- 0,
			-- 0
		-- ],
		-- "SysPanelSize" : 
		-- [
			-- -1.0,
			-- -1.0
		-- ],
		-- "Text" : "",
		-- "TooltipArrayUpdated" : true,
		-- "Top" : 0.0,
		-- "Type" : 43,
		-- "UIObjectHandle" : "userdata: 00C000020000002D",
		-- "UIScale" : 1.0,
		-- "UIScaling" : false,
		-- "WorldScreenPositionX" : 772,
		-- "WorldScreenPositionY" : 743
	-- }
-- }










-- Game.Tooltip.RegisterListener(function(request, tooltip)
  -- print("TOOLTIP",request.Type)
  -- _D(request)
  -- _D(tooltip.Data)
-- end)



