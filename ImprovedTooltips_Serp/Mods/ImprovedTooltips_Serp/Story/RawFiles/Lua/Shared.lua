-- TODO:
-- bei Stati evtl. noch anzeigen, welche Potion/Objects und welche Skills diesen Status geben? könnte zuviel text werden
-- status werte anzeigen
  
-- TODO:
-- item ingredient Riesennägel gucken wo definiert ist, dass man damit Schuhe rutschfest machen kann
-- und das im tooltip anzeigen
  
ModSettings = ModSettings or {Colouring=1,ShowSkillStatus=2,ShowSurfaceStatus=2,ShowItemStatus=1}
  
  
CacheCraftingInfos = {}
  
Ext.Require("helpers/GetSurfaces.lua") -- _GetSurfaces
Ext.Require("helpers/gameScriptStatusLogic.lua") -- GetInfoTextForStatus

-- statusses which have no stats
-- but add some known SavingThrow and ImmuneFlag and translation handle to them
engineStatuses = {
    SOURCE_MUTED = {
        DisplayName = "h534aec4fgecc5g4b34gb0f5g8b08c3c4309e",
        SavingThrow = "MagicArmor",
        ImmuneFlag = "None",
        FormatColor = "Orange",
    },
    ADRENALINE = {DisplayName = "h4c891442g3b79g4dbeg906fgf8eeffcf60df"},
    COMBAT = {},
    SPIRIT_VISION = {},
    UNSHEATHED = {},
    CHANNELING = {},
    IDENTIFY = {},
    INSURFACE = {},
    FLOATING = {DisplayName = "h278121a7g2132g4efdgb151g9af722d670dc"},
    THROWN = {DisplayName = "hfa754958gff75g4474g8cd5g508b4fb7a984",ImmuneFlag="ThrownImmunity"},
    INFUSED = {DisplayName = "hae4ca8a4g56feg480eg95c8ge5761ab1eb2e"},
    CLIMBING = {},
    CHARMED = {
        DisplayName = "h30fc0122g6378g408cgac6fg6e3bcb3c852b",
        SavingThrow = "MagicArmor",
        ImmuneFlag = "CharmImmunity",
        FormatColor = "Pink",
    },
    LYING = {},
    CLEAN = {DisplayName = "h8fb688afg29efg4804g9d68g955c3c463053"},
    ACTIVE_DEFENSE = {},
    SNEAKING = {DisplayName = "h6bf7caf0g7756g443bg926dg1ee5975ee133"},
    TELEPORT_FALLING = {},
    DYING = {DisplayName = "h2e807311g8c4bg4141g85f3gcc88ee095888"},
    STORY_FROZEN = {},
    FORCE_MOVE = {},
    CONSUME = {},
    BOOST = {},
    DRAIN = {DisplayName = "h9cf08d12gc1b8g4c7cg8662g40d03ca96df5", SavingThrow = "MagicArmor", ImmuneFlag = "None"},
    LINGERING_WOUNDS = {DisplayName = "h3924a821gdb1fg4d6fg920eg62ee3c4586ed"},
    DECAYING_TOUCH = {
        DisplayName = "hbc2789fegb2deg4952ga436ga8a0aad070bf",
        SavingThrow = "PhysicalArmor",
        ImmuneFlag = "DecayingImmunity",
        FormatColor = "Purple",
    },
    UNHEALABLE = {DisplayName = "hc33f0ac7gc3f0g47b3gba3cg8c3ddb82508e"},
    STANCE = {},
    INFECTIOUS_DISEASED = {
      SavingThrow = "PhysicalArmor", 
      ImmuneFlag = "InfectiousDiseasedImmunity",
      DisplayName = "h791f1994g94e9g4471g9e10g398f8d194c90",
      FormatColor = "Purple",
    },
    SUMMONING = {},
    AOO = {},
    COMBUSTION = {},
    REMORSE = {DisplayName = "h7e0fe51fg9df2g4854gb8f1g183251dcc25b"},
    OVERPOWER = {},
    ENCUMBERED = {DisplayName = "hdc2c6815g4c4fg4e81g94d5g299646e91500"},
    TUTORIAL_BED = {},
    DAMAGE = {},
    FLANKED = {DisplayName = "hd052e4cfg1a83g4ee5g886cgbf15dc656a0b"},
    LEADERSHIP = {DisplayName = "h7c65fe39g1526g427bg8a2dgab7e74c66202"},
    DARK_AVENGER = {DisplayName = "h64892b81g9543g4608ga303gcffa5055d869"},
    SMELLY = {DisplayName = "h312fc6d0gd271g40ffg949dge80fba98335e"},
    MATERIAL = {},
    REPAIR = {},
    SHACKLES_OF_PAIN = {
        DisplayName = "h36a82a09gc2dag46feg990cgf3807db54d54",
        SavingThrow = "PhysicalArmor",
        ImmuneFlag = "ShacklesOfPainImmunity",
        FormatColor = "Red",
    },
    POLYMORPHED = {},
    SPIRIT = {DisplayName = "h90cedca8g690cg4aabg8df0g98da27d72991"},
    CONSTRAINED = {},
    EFFECT = {},
    EXPLODE = {},
    SPARK = {},
    SITTING = {DisplayName = "h33b529f1g6fb3g4210g8b40ga41e4d05c0d0"},
    INCAPACITATED = {},
    UNLOCK = {},
    SHACKLES_OF_PAIN_CASTER = {DisplayName = "h89ad2635gd8acg4dc1gb7f5g2287082b3733"},
    WIND_WALKER = {DisplayName = "hc7566374g36afg4345gaf18gab4ba7d7c809"},
    HIT = {},
    ROTATE = {}
}

function GetTranslation(statsid_or_handle,fallback)
  if not statsid_or_handle then
    return fallback
  end
  local loc = Ext.L10N.GetTranslatedStringFromKey(statsid_or_handle)
  if not loc or loc=="" then
    loc = Ext.L10N.GetTranslatedString(statsid_or_handle,fallback)
  end
  if not loc or loc=="" then
    loc = fallback
  end
  return loc
end

-- opener eg. = "\n<font color='#6EB09D'>Removed by Stati:</font> "
-- desctable = {{chance=100,codename="FEAR",loc="Panisch"}}
function CreateDescrString(opener,desctable,seperator,kind)
  seperator = seperator or ", "
  local IsCtrl = CurrentPressedKeys["Ctrl"]
  local desc = opener
  local addedLocs = {}
  for _,info in ipairs(desctable) do
    local loc,codename,chance
    if type(info)=="table" then
      codename = info.codename
      loc = info.loc
      chance = info.chance
    else
      codename = info
      loc = StatusLocs[codename] 
      if not loc or loc=="" then
        local stat = not engineStatuses[codename] and Ext.Stats.Get(codename) or engineStatuses[codename]
        loc = stat and GetTranslation(stat.DisplayName,codename) or codename
      end
    end
    if not chance or chance~=0 then
      if not addedLocs[loc] or IsCtrl then -- only add stati with exact same translation only once, unless we hold Shift
        addedLocs[loc] = true
        loc = ColourizeStatus(codename,loc,true,kind)
        local chancetxt = chance and chance<100 and " "..tostring(chance).."%" or ""
        local brackets = loc~=codename and IsCtrl and " ("..codename..")" or ""
        desc = desc..loc..chancetxt..brackets
        if next(desctable,_) then
          desc = desc..seperator
        end
      end
    end
  end
  return desc
end

function CreateItemTooltipAddition(item,tooltip,nonewlinestart)
  local addstringtodesc = ""
  -- not to weapon/armor and so, because the tooltip gets too big, use the Epip Codex instead to inform yourself about a status
  if item and item.StatsFromName and (item.StatsFromName.ModifierList=="Potion" or item.StatsFromName.ModifierList=="Object") then
    
    if tooltip and item.CurrentTemplate and item.CurrentTemplate.OnUsePeaceActions then
      for _,useaction in pairs(item.CurrentTemplate.OnUsePeaceActions) do
        if useaction.Type=="UseSkill" then
          local skill = useaction.SkillID
          local skilldesc = CreateSkillToolipAddition(skill,nil,true)
          AddToTooltip(tooltip,skilldesc)
        end
      end
    end
    
    if ModSettings["ShowItemStatus"]==1 or (ModSettings["ShowItemStatus"]==2 and CurrentPressedKeys["Shift"]) then
      local ExtraProperties = item.StatsFromName.PropertyLists and item.StatsFromName.PropertyLists.ExtraProperties and item.StatsFromName.PropertyLists.ExtraProperties.Properties and item.StatsFromName.PropertyLists.ExtraProperties.Properties.Elements
      local appliesStati = {}
      if ExtraProperties then
        for _,property in ipairs(ExtraProperties) do
          if property.TypeId=="Status" then
            local Context = {"Self"} -- I think these effects are always Self, regardless what is written in them
            appliesStati[property.Status] = {chance=property.StatusChance*100,duration=property.Duration,Context=Context}
          end
        end
      end
      for status,info in pairs(appliesStati) do
        local chance = info.chance
        local duration = info.duration
        local Context = info.Context
        local stat = not engineStatuses[status] and Ext.Stats.Get(status) or engineStatuses[status]
        local status_loc = StatusLocs[status] or stat and GetTranslation(stat.DisplayName,status) or status
        if chance and chance>0 then
          if StatusScriptRules[status] then
            addstringtodesc = addstringtodesc..CreateStatusApplyTooltip(status,Context,nil,nil,nonewlinestart)
          end
          if next(appliesStati,status) then
            addstringtodesc = addstringtodesc.." | "
          end
        end
      end
    end
    
    if item and item.StatsFromName and item.StatsFromName.ModifierList=="Potion" then
      local StackId = item.StatsFromName.StatsEntry.StackId
      local StackPriority = item.StatsFromName.StatsEntry.Priority
      local ObjectCategory = item.StatsFromName.StatsEntry.ObjectCategory
      local Duration = item.StatsFromName.StatsEntry.Duration
      if StackId and StackId~="" and Duration>0 then
        if addstringtodesc~="" and nonewlinestart then
          addstringtodesc=addstringtodesc.."\n"
        end
        addstringtodesc = addstringtodesc.."(StackId: "..tostring(StackId).." Category:"..tostring(ObjectCategory).." "..tostring(StackPriority)..")"
      end
    end
    
  end
  if item and item.StatsFromName then
    -- add info about unique/quest and crafting
    
    -- create cache
    local ItemComboProperties = {}
    for i,comboprop in pairs(Ext.Stats.GetStats("ItemComboProperty")) do
      ItemComboProperties[comboprop] = ItemComboProperties[comboprop] or {}
      for _,entry in ipairs(Ext.Stats.ItemComboProperty.GetLegacy(comboprop).Entries) do
        table.insert(ItemComboProperties[comboprop],{IngredientType=entry.IngredientType,ObjectId=entry.ObjectId})
      end
    end
    if next(CacheCraftingInfos)==nil then -- only needed once per saveload
      for i,combo in pairs(Ext.Stats.GetStats("ItemCombination")) do
        local recipe = Ext.Stats.ItemCombo.GetLegacy(combo)
        local results = {}
        for _,resultinfo in ipairs(recipe.Results) do
          for __,result_info in ipairs(resultinfo.Results) do
            if result_info.Result and result_info.Result~="" then
              table.insert(results,{recipename=recipe.Name,result=result_info.Result,amount=result_info.ResultAmount})
            elseif result_info.Result and result_info.Result=="" and result_info.Boost and result_info.Boost~="" then -- inlcude Boosts like Boost_Armor_Boots_Crafting_Special_KnockdownImmunity
              table.insert(results,{recipename=recipe.Name,result=result_info.Boost,amount=result_info.ResultAmount})
            end
          end
        end
        if #results>0 then
          for _,ingredientinfo in ipairs(recipe.Ingredients) do
            local IngredientType = ingredientinfo.IngredientType
            CacheCraftingInfos[IngredientType] = CacheCraftingInfos[IngredientType] or {Category={},Object={},Property={}}
            if IngredientType=="Property" then
              local comboprop = ingredientinfo.Object
              if ItemComboProperties[comboprop] then
                for __,entry in ipairs(ItemComboProperties[comboprop]) do
                  CacheCraftingInfos[entry.IngredientType][entry.ObjectId] = CacheCraftingInfos[entry.IngredientType][entry.ObjectId] or {}
                  table.insert(CacheCraftingInfos[entry.IngredientType][entry.ObjectId],results)
                end
              end
            else
              CacheCraftingInfos[IngredientType][ingredientinfo.Object] = CacheCraftingInfos[IngredientType][ingredientinfo.Object] or {}
              table.insert(CacheCraftingInfos[IngredientType][ingredientinfo.Object],results)
            end
          end
        end
      end
    end
    
    local infostring = "\n\n"
    if item.StatsFromName.StatsEntry.Unique==1 then
      infostring = infostring.."<font color='#40b606'>IsUnique</font> "
    end
    if item.StatsFromName.Name:lower():find("quest",1,true) then
      infostring = infostring.."<font color='#40b606'>IsQuest</font> "
    end
    local crafting_results = {}
    for IngredientType,ingredientinfo in pairs(CacheCraftingInfos) do
      for IngredientName,results in pairs(ingredientinfo) do
        if IngredientType=="Object" and IngredientName==item.StatsFromName.Name or IngredientType=="Category" and table_contains_value(item.StatsFromName.StatsEntry.ComboCategory,IngredientName) then
          for _,resultinfo in ipairs(results) do
            table.insert(crafting_results,resultinfo)
          end
        end
      end
    end
    if #crafting_results>0 then
      infostring = infostring.."<font color='#40b606'>IsIngredient</font> "
      local propertystring = "Counts as "
      for comboprop,comboentries in pairs(ItemComboProperties) do
        for _,entry in ipairs(comboentries) do
          if entry.ObjectId==item.StatsFromName.Name then
            propertystring = propertystring..comboprop.." "
          end
        end
      end
      for _,category in ipairs(item.StatsFromName.StatsEntry.ComboCategory) do
        propertystring = propertystring..category.." "
      end
      if propertystring~="Counts as " then
        infostring = infostring..propertystring
      end
      if CurrentPressedKeys["Shift"] then
        local addedlocs = {}
        infostring = infostring..": <font color='#40b606'>Used to craft:</font>\n"
        for _,resultinfos in ipairs(crafting_results) do
          for __,resultinfo in pairs(resultinfos) do
            -- if Osi.CharacterHasRecipeUnlocked(Osi.CharacterGetHostCharacter(),resultinfo.recipename)==1 then -- cant check Osi for client... so show everything..
              local loc = GetTranslation(resultinfo.result,"")
              if loc=="" then
                local stats = Ext.Stats.Get(resultinfo.result)
                if stats then
                  if stats.RootTemplate then
                    Template = Ext.Template.GetTemplate(stats.RootTemplate)
                    loc = GetTranslation(Template.DisplayName,"")
                  end
                  if not loc or loc=="" then
                    if stats.DisplayName then
                      loc = GetTranslation(stats.DisplayName,stats.DisplayName)
                    elseif stats.RootTemplate then
                      loc = Ext.Template.GetTemplate(stats.RootTemplate).DisplayName
                    end
                  end
                end
                if not loc or loc=="" then
                  loc = resultinfo.result
                end
              end
              if not addedlocs[loc] then
                infostring = infostring..tostring(loc)..(resultinfo.amount~=1 and " ("..tostring(resultinfo.amount)..")" or "")
                if next(resultinfos,__) or next(crafting_results,_) then
                  infostring = infostring..", "
                end
                addedlocs[loc] = true
              end
            -- end
          end
        end
      end
    end
    if infostring~="\n\n" then
      local found = false
      for __,tentry in ipairs(tooltip.Data) do
        if tentry.Type=="ItemDescription" then -- ItemDescription is on the bottom
          tentry.Label = tentry.Label..infostring
          found = true
          break
        end
      end
      if not found then
        local entry = {Type="ItemDescription",Label=infostring}
        table.insert(tooltip.Data,entry)
      end
    end
  
  end  
  
  return addstringtodesc
end


function deepcopy(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      if copies[orig] then
          copy = copies[orig]
      else
          copy = {}
          copies[orig] = copy
          for orig_key, orig_value in next, orig, nil do
              copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
          end
          setmetatable(copy, deepcopy(getmetatable(orig), copies))
      end
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

-- ###########################################################################
-- ###########################################################################
-- ###########################################################################


local MissingExtenderSurfaces = {DeathfogCloud="c651b724-32e2-4e34-99b4-272826ac3e37"} -- or must change it to "Deathfog" instead

-- returns the first key from table with value x
function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

---@param o1 any|table First object to compare
---@param o2 any|table Second object to compare
-- ignores metatables
function equals(o1, o2)
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

-- "<font color='"..colourcode.."'>"..statusname_loc.."</font>"
-- 6EB09D is greenish
function GetFormatColour(FormatColor,kind) --  in LeaderLib
  local colourcode = "#FFFFFF"
  if FormatColor and Mods.LeaderLib then
    if kind=="skill" and Mods.LeaderLib.Data.Colors.Ability[FormatColor] then
      colourcode = Mods.LeaderLib.Data.Colors.Ability[FormatColor]
    elseif Mods.LeaderLib.Data.Colors.FormatStringColor[FormatColor] then
      colourcode = Mods.LeaderLib.Data.Colors.FormatStringColor[FormatColor]
    elseif Mods.LeaderLib.LocalizedText.DamageTypeHandles[FormatColor] then
      colourcode = Mods.LeaderLib.LocalizedText.DamageTypeHandles[FormatColor].Color
    elseif Mods.LeaderLib.Data.Colors.Common[FormatColor] then
      colourcode = Mods.LeaderLib.Data.Colors.Common[FormatColor]
    end
  end
  return colourcode
end
function GetStatusColour(StatusId,stat,kind)
  -- print("GetStatusColour",StatusId)
  if not stat then
    if engineStatuses[StatusId] and engineStatuses[StatusId].FormatColor then
      stat = engineStatuses[StatusId]
    elseif not engineStatuses[StatusId] then
      stat = Ext.Stats.Get(StatusId)
    end
  end
  if stat then
    local FormatColor = kind=="skill" and stat.Ability or stat.FormatColor
    return GetFormatColour(FormatColor,kind)
  end
end
function ColourizeStatus(status,status_loc,colourize,kind)
  local colourcode
  if ModSettings.Colouring==1 and colourize and status~="NULLL" and status_loc then
    colourcode = GetStatusColour(status,nil,kind)
    if colourcode then
      status_loc = "<font color='"..colourcode.."'>"..status_loc.."</font>"
    end
  end
  return status_loc
end


-- Osi.GetSurfaceNameByTypeIndex is not available on client..
function _GetSurfaceNameByTypeIndex(s_index)
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
function IsValidSkillTooltip(tooltip)
  if tooltip and tooltip.Data then
    for _, entry in ipairs(tooltip.Data) do
      if entry["Type"]=="SkillCooldown" then
        return true
      end
    end
  end
  return false
end


function CreateCreatesSurfaceTooltip(surfaceinfo)
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
    local SurfaceTypeForTemplate = SurfaceType=="DeathfogCloud" and "Deathfog" or SurfaceType
    local status,template = pcall(Ext.Surface.GetTemplate,SurfaceTypeForTemplate) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
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
  return SurfaceText
end

-- recreate the info about status StatAttributes
-- loc_table= {
        -- "AutoReplacePlaceholders" : false,
        -- "Content" : "AP Cost", -- english
        -- "Handle" : "h228e474ag396ag4dc9g837egd8d05d15bbb2"
-- }
function GetStatusAttr(status,stat)
  local attributes = {}
  stat = stat or (not engineStatuses[status] or Ext.Stats.Get(status))
  if stat and Mods.LeaderLib and not engineStatuses[status] then -- requires LocalizedText from LeaderLib
    local StatsId = stat.StatsId
    
    local Skills = stat.Skills -- string with ; separated
    if Skills and Skills~="" then
      for skill in string.gmatch(Skills,"([^;]+)") do
        local stat_skill = Ext.Stats.Get(skill)
        local loc = GetTranslation(stat_skill.DisplayName,skill)
        attributes[skill] = {loc="Skill: ",value=loc}
      end
    end
    local Skills = stat.LeaveAction -- string with ; separated
    if Skills and Skills~="" then
      for skill in string.gmatch(Skills,"([^;]+)") do
        local stat_skill = Ext.Stats.Get(skill)
        local loc = "+ "..GetTranslation(stat_skill.DisplayName,skill)
        attributes[skill] = {loc=loc,value=""}
      end
    end
    if stat.LoseControl=="Yes" then
      attributes["LoseControl"] = {loc="LoseControl",value=""}
    end
    if stat.IsInvulnerable=="Yes" then
      attributes["IsInvulnerable"] = {loc=GetTranslation("h1889cf51gd0a8g4a53gbaa5g6e78d3ed6eab","IsInvulnerable"),value=""}
    end
    if stat.ResetCooldowns and stat.ResetCooldowns~="" then
      attributes["ResetCooldowns"] = {loc="Resets "..GetTranslation("hcd311863gbd69g4425gbcf5gcab3cea1ce1d","Cooldowns"),value=stat.ResetCooldowns}
    end
    
    if StatsId and StatsId~="" and not StatsId:find(";",1,true) then -- can be multiples, to complicated to support, its just Supercharge which does this
      local StatsStat = Ext.Stats.Get(StatsId)
      if StatsStat then
        for attr,loc_table in pairs(Mods.LeaderLib.LocalizedText.StatAttributes) do
          if Potion_Modifiers[attr] and StatsStat[attr] and type(StatsStat[attr])=="number" and StatsStat[attr]~=0 then -- there are a few that are strings (eg. Reflection) we should add, but too much work...
            local loc = GetTranslation(loc_table.Handle,loc_table.Content)
            attributes[attr] = {loc=loc,value=StatsStat[attr]}
          end
        end
        for attr,loc_table in pairs(Mods.LeaderLib.LocalizedText.AbilityNames) do
          if Potion_Modifiers[attr] and not attributes[attr] and StatsStat[attr] and type(StatsStat[attr])=="number" and StatsStat[attr]~=0 then -- there are a few that are strings (eg. Reflection) we should add, but too much work...
            local loc = GetTranslation(loc_table.Handle,loc_table.Content)
            attributes[attr] = {loc=loc,value=StatsStat[attr]}
          end
        end
      end
    end
  end
  return attributes
end

function CreateStatusStackIdSavingThowTooltip(status,nonewlinestart)
  local addstringtodesc = ""
  if not engineStatuses[status] then -- Food status is CONSUME
    local stat = Ext.Stats.Get(status)
    if stat then
      local StackId = stat.StackId
      local StackPriority = stat.StackPriority
      local SavingThrow = stat.SavingThrow
      if SavingThrow and SavingThrow~="None" then
        if not nonewlinestart then
          addstringtodesc = addstringtodesc.."\n"
        end
        local loc_SavingThrow = SavingThrow=="MagicArmor" and "hc6dcb940gb6b6g41aagaeceg31008af9c082" or SavingThrow=="PhysicalArmor" and "hb677b3f7g5cf6g49c3g84fag2f773ef50dd6"
        loc_SavingThrow = loc_SavingThrow and GetTranslation(loc_SavingThrow,SavingThrow) or SavingThrow
        addstringtodesc = addstringtodesc.."<font color='#DCDCCC'>SavingTrow:</font> "..tostring(loc_SavingThrow)
      end
      if StackId and StackId~="" then
        if not nonewlinestart or addstringtodesc~="" then
          addstringtodesc = addstringtodesc.."\n"
        end
        addstringtodesc = addstringtodesc.."(StackId: "..tostring(StackId).." "..tostring(StackPriority)..")"
      end
    end
  elseif engineStatuses[status] and engineStatuses[status].SavingThrow and engineStatuses[status].SavingThrow~="None" then
    if not nonewlinestart or addstringtodesc~="" then
      addstringtodesc = addstringtodesc.."\n"
    end
    addstringtodesc = addstringtodesc.."<font color='#DCDCCC'>SavingTrow:</font> "..tostring(engineStatuses[status].SavingThrow)
  end
  return addstringtodesc
end

function CreateStatusRemoveTooltip(status)
  local addstringtodesc = ""
  if StatusCleansedBySkills[status] then
    local opener = "\n<font color='#DCDCCC'>Cleansed by Skills:</font> "
    addstringtodesc = addstringtodesc..CreateDescrString(opener,StatusCleansedBySkills[status],nil,"skill")
  end
  if StatusScriptRemovalRules[status] then
    addstringtodesc = addstringtodesc.."\n<font color='#DCDCCC'>Removed by Stati:</font>\n"
    addstringtodesc = addstringtodesc..GetInfoTextForStatusRemoval(status,StatusLocs,"",true)
  end
  return addstringtodesc
end


function CreateStatusApplyTooltip(status,Context,withoutheader,prefix,nonewlinestart,withoutstackid)
  -- Adding info what the applied appliedstati may cleanse (chance and duration is already in tooltip)
  prefix = prefix or ""
  local desc = ""
  local stat = not engineStatuses[status] and Ext.Stats.Get(status) or engineStatuses[status]
  local status_loc = StatusLocs[status] or stat and GetTranslation(stat.DisplayName,status) or status
  local codename = " ("..status..") "
  if not withoutheader then
    status_loc = ColourizeStatus(status,status_loc,true)
    desc = desc..prefix.."<font color='#DCDCCC'>Status</font> "..status_loc..(CurrentPressedKeys["Ctrl"] and codename or "")..(Context and " ("..table.concat(Context,",")..")" or "")
  end
  if StatusScriptRules[status] then
    if desc~="" then
      desc=desc.."\n"
    end
    desc = desc..GetInfoTextForStatus(status,StatusLocs," ",true)
  end
  if StatusProvidesImmunityAgainstStati[status] then
    if desc~="" then
      desc=desc.."\n"
    end
    local opener = prefix.."<font color='#DCDCCC'>Provides Immunities</font>: "
    desc = desc..CreateDescrString(opener,StatusProvidesImmunityAgainstStati[status])
  end
  -- StackId
  if not withoutstackid and not engineStatuses[status] then
    local stat = Ext.Stats.Get(status)
    if stat then
      local StackId = stat.StackId
      local StackPriority = stat.StackPriority
      if StackId and StackId~="" then
        if desc~="" then
          desc=desc.."\n"
        end
        desc = desc..prefix.."(StackId: "..tostring(StackId).." "..tostring(StackPriority)..")"
      end
    end
  end
  if desc and desc~="" then
    -- desc = (not nonewlinestart and "\n" or "").."<font color='#D2D2D2'>".."Applies Effects:".."</font>"..desc
    desc = (not nonewlinestart and "\n" or "")..desc
  end
  return desc
end


function CreateSkillToolipAddition(skill,char,forItem)
  -- print("CreateSkillToolipAddition",skill,char)
  local skilldesc = {}
  local MyStat = Ext.Stats.Get(skill)
  if MyStat then
    local AreaRadius = MyStat.AreaRadius
    -- Info about surface a skill creates
    local createssurfaces = {}
    local appliedstati = {}
    local SkillProperties = MyStat["SkillProperties"] -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
    if SkillProperties and type(SkillProperties)=="table" then
      for _,entry in pairs(SkillProperties) do
        if entry.Type=="GameAction" and (entry.Action=="CreateSurface" or entry.Action=="TargetCreateSurface") then
          table.insert(createssurfaces,{SurfaceType=entry.Arg3,SurfaceLifetime=entry.Arg2~=0 and entry.Arg2/6,SurfaceRadius=entry.Arg1,SurfaceStatusChance=nil})
        elseif entry.Type=="Status" and entry.StatsId=="" then
          local status = entry.Action
          local Context = {} -- transform from lightC to table
          for k,v in pairs(entry.Context) do
            if v~="AoE" or (AreaRadius and AreaRadius>0) then -- not including AoE if it has no AreaRadius
              Context[k]=v
            end
          end
          table.insert(appliedstati,{status=status,Context=Context})
        end
      end
    end
    
    local addcleansestringtoskill = ""
    if not forItem and (ModSettings.ShowSkillStatus==1 or (ModSettings.ShowSkillStatus==2 and CurrentPressedKeys["Shift"])) or forItem and (ModSettings.ShowItemStatus==1 or (ModSettings.ShowItemStatus==2 and CurrentPressedKeys["Shift"])) then
      for i,info in ipairs(appliedstati) do
        local status = info.status
        local Context = info.Context or {}
        addcleansestringtoskill = addcleansestringtoskill..CreateStatusApplyTooltip(status,Context)
      end
    end
    -- add info to skills which stati they clean
    local skillcleantext = ""
    if SkillCleanseStati[skill] and SkillCleanseStati[skill].stati and next(SkillCleanseStati[skill].stati) and SkillCleanseStati[skill].chance>0 then
      local chancetxt = SkillCleanseStati[skill].chance<100 and "("..tostring(SkillCleanseStati[skill].chance).."%) " or ""
      local opener = "\n<font color='#DCDCCC'>Cleanse Stati</font>"..chancetxt..": "
      skillcleantext = CreateDescrString(opener,SkillCleanseStati[skill].stati,nil)
    end
    -- print("skillcleantext",skill,skillcleantext)
    skilldesc["SkillDescription"] = (skilldesc["SkillDescription"] or {})
    table.insert(skilldesc["SkillDescription"],{Label=skillcleantext..addcleansestringtoskill,firstfound=true})
    
    local StatSurfaceType = MyStat.SurfaceType
    if StatSurfaceType and StatSurfaceType~="None" then
      table.insert(createssurfaces,{SurfaceType=StatSurfaceType,SurfaceLifetime=MyStat.SurfaceLifetime,SurfaceRadius=MyStat.SurfaceRadius,SurfaceStatusChance=MyStat.SurfaceStatusChance})
    end
    for _,surfaceinfo in ipairs(createssurfaces) do
      local SurfaceType = surfaceinfo.SurfaceType
      local SurfaceText = CreateCreatesSurfaceTooltip(surfaceinfo)
      skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
      table.insert(skilldesc["SkillExplodeRadius"],{Label="<font color='#DCDCCC'>Creates Surface</font> "..tostring(SurfaceType).."\n"..SurfaceText,createnewentry=true})
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
        skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
        table.insert(skilldesc["SkillExplodeRadius"],{Value=tostring(AreaRadius).."m",Label="Area Radius:",createnewentry=true})
      end
      local GroundSkillTypes = {"Path","Rain","Cone","Dome","Jump","Quake","Shout","Storm","Summon","Tornado","Wall","Zone"}
      if table_contains_value(GroundSkillTypes,MyStat.SkillType) then
        if not table_contains_value(CanTarget,"Ground") then
          table.insert(CanTarget,"Ground")
        end
      end
      
      skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
      table.insert(skilldesc["SkillExplodeRadius"],{Label="Target Conditions: "..TargetConditions,createnewentry=true}) -- not using Value here, because it is limited in characters, to many will not be displayed
      if #CanTarget>0 then
        skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
        table.insert(skilldesc["SkillExplodeRadius"],{Value=table.concat(CanTarget, ","),Label="Can Target:",createnewentry=true}) -- not using Value here, because it is limited in characters, to many will not be displayed
      end    
    end
    
    
    if char and char.SkillManager.Skills[skill] then
      local cooldownleft = char.SkillManager.Skills[skill].ActiveCooldown -- in seconds, not turns. 1 turn=6 seconds
      if cooldownleft~=0 then
        cooldownleft = tostring( math.ceil(cooldownleft / 6) )
        skilldesc["SkillRequiredEquipment"] = (skilldesc["SkillRequiredEquipment"] or {})
        table.insert(skilldesc["SkillRequiredEquipment"],{Label="("..cooldownleft..") ",createnewentry=false,addinfront=true,firstfound=true})
      end
    end
      
  end
  return skilldesc
end

function _AddToTooltip(tooltip,Type,info)
  if info.createnewentry then
    local entry = {Type=Type,Value=info.Value,Label=info.Label}
    table.insert(tooltip.Data,entry)
  else
    for _,entry in ipairs(tooltip.Data) do
      -- print("_AddToTooltip",entry.Type,Type,info.Label)
      if entry.Type==Type  then
        if info.Value then
          if info.addinfront then
            entry.Value = info.Value..entry.Value
          else
            entry.Value = entry.Value..info.Value
          end
        end
        if info.Label then
          if info.addinfront then
            entry.Label = info.Label..entry.Label
          else
            entry.Label = entry.Label..info.Label
          end
        end
        if info.firstfound then
          break
        end
      end
    end
  end
end
function AddToTooltip(tooltip,desctable)
  for Type,infos in pairs(desctable) do
    for _,info in ipairs(infos) do
      _AddToTooltip(tooltip,Type,info)
    end
  end
end



-- Surface Tooltip anpassen:
-- 1) Wasserschaden header von wasserfläche in Wasser umwandeln
-- 2) Stati die verursacht werden können mit Chance zufügen
-- Statuschance can be overriden by skill which caused it with SurfaceType SurfaceStatusChance, dont think we can catch it here..
local previoustooltipdata = nil
local previoussurface = nil
function AdjustSurfaceTooltip(SurfaceType,tooltip)
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
            local SStat = not engineStatuses[statusinfo.StatusId] and Ext.Stats.Get(statusinfo.StatusId) or engineStatuses[statusinfo.StatusId]
            local statusname_loc = SStat and GetTranslation(SStat.DisplayName,statusinfo.StatusId) or statusinfo.StatusId
            status_loc = ColourizeStatus(statusinfo.StatusId,statusname_loc,true)
            addremove = "\n<font color='#DCDCCC'>"..(statusinfo.RemoveStatus and "Removes " or "Applies ").."</font> "..statusname_loc..(CurrentPressedKeys["Ctrl"] and " ("..statusinfo.StatusId..")" or "")
            local IgnoresArmor = statusinfo.ForceStatus and "\n  Ignores Armor" or ""
            local KeepAlive = statusinfo.KeepAlive and "\n  Stays Active" or ""
            local OnlyWhileMoving = statusinfo.OnlyWhileMoving and "\n  Only While Moving" or ""
            local VanishOnReapply = statusinfo.VanishOnReapply and "\n  Removes Surface" or ""
            SurfaceStatusText = SurfaceStatusText..addremove.."\n  Chance: "..tostring(round(statusinfo.Chance*100,2)).." %\n  Duration: "..tostring(round(statusinfo.Duration/6,1)).." turns"..IgnoresArmor..KeepAlive..VanishOnReapply
            if not statusinfo.RemoveStatus and (ModSettings.ShowSurfaceStatus==1 or (ModSettings.ShowSurfaceStatus==2 and CurrentPressedKeys["Shift"])) then -- no need to say what a status does, if it is removed
              SurfaceStatusText = SurfaceStatusText..CreateStatusApplyTooltip(statusinfo.StatusId,nil,true,"  ")
            end
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




-- return true to allow and false to not allow skill
-- filter out eg. enemy/quest skills and so on, to only leave the ones the player might have
function FilterSkills(skill,stat)
  -- stat.IsEnemySkill=="Yes" -- dont include enemy exclusive skills ... nearly all mods and even part of vanilla, especially gift bags, failed to properly mark skills which are Enemy-only (many do Yes for player skills) -.-
  if skill:lower():find("enemy",1,true) or skill:lower():find("quest",1,true) or skill:lower():find("dummy",1,true) or skill:lower():find("script",1,true) then
    return false
  end
  if not stat.Icon or stat.Icon=="" or not stat.Description or stat.Description=="" or not stat.DisplayName or stat.DisplayName=="" then
    return false
  end -- MemorizationRequirements can not be securely used, since also several inate or weapon skills dont require memory.. and have no Ability type defined
  return true
end

  
-- _D(Mods.ImprovedTooltips_Serp.SkillCleanseStati)
-- _D(Mods.ImprovedTooltips_Serp.StatusRequiresImmunity)
-- _D(Mods.ImprovedTooltips_Serp.StatsIdToStati)
-- _D(Mods.ImprovedTooltips_Serp.ImmunityFromStati)
-- _D(Mods.ImprovedTooltips_Serp.StatusRequiresImmunity_REV)
-- _D(Mods.ImprovedTooltips_Serp.StatusProvidesImmunityAgainstStati)

StatusCleansedBySkills = {} -- will be filled SessionLoaded
SkillCleanseStati = {} -- doing this skill on a target, will remove the stati from the target, will be filled StatsLoaded
-- helper tables to fill StatusRemovedByStati
StatusRequiresImmunity = {} -- the immunity which is required to be immune against this status
StatusRequiresImmunity_REV = {} -- 
StatsIdToStati = {}
ImmunityFromStats = {} -- a list per immunity, which stats provide this immunity
ImmunityFromStati = {} -- a list per immunity, which stati provide this immunity
StatusProvidesImmunityAgainstStati = {}
StatusLocs = {NULLL="Ø"} -- translation in local language
StatusSources = {} -- weapons,potions,skill which can apply a status
Ext.Events.SessionLoaded:Subscribe(function(_)
  -- Ext.Print("ImprovedTooltips_Serp SessionLoaded Start")
  for i,skill in pairs(Ext.Stats.GetStats("SkillData")) do
    local stat = Ext.Stats.Get(skill)
    if FilterSkills(skill,stat) then
      local CleanseStatuses = stat.CleanseStatuses -- string FROZEN;STUNNED;PETRIFIED;PLAGUE;SUFFOCATING;POISONED;BURNING;NECROFIRE;FEAR;MUTED;TAUNTED;MADNESS
      local StatusClearChance = stat.StatusClearChance
      local skill_loc = GetTranslation(stat.DisplayName,skill)
      SkillCleanseStati[skill] = {stati={},loc=skill_loc,chance=StatusClearChance}
      for status in string.gmatch(CleanseStatuses, "([^;]+)") do -- seperate by ;
        StatusCleansedBySkills[status] = StatusCleansedBySkills[status] or {}
        table.insert(StatusCleansedBySkills[status],{codename=skill,loc=skill_loc,chance=StatusClearChance})
        table.insert(SkillCleanseStati[skill].stati,status)
      end
    end
  end
  
  for i,statusname in pairs(Ext.Stats.GetStats("StatusData")) do
    local stat = Ext.Stats.Get(statusname)
    local status_loc = GetTranslation(stat.DisplayName,statusname)
    StatusLocs[statusname] = status_loc
    local ImmuneFlag = stat.ImmuneFlag -- ist nur eine immunity als string und bedeuted wenn du die hast, bist du immun gegen status
    if ImmuneFlag and ImmuneFlag~="None" then
      StatusRequiresImmunity[statusname] = ImmuneFlag
      StatusRequiresImmunity_REV[ImmuneFlag] = StatusRequiresImmunity_REV[ImmuneFlag] or {}
      if not table_contains_value(StatusRequiresImmunity_REV[ImmuneFlag],statusname) then
        table.insert(StatusRequiresImmunity_REV[ImmuneFlag],statusname)
      end
    end
    local StatsId = stat.StatsId
    if StatsId and StatsId~="" then
      StatsIdToStati[StatsId] = StatsIdToStati[StatsId] or {}
      if not table_contains_value(StatsIdToStati[StatsId],statusname) then
        table.insert(StatsIdToStati[StatsId],statusname) -- one StatsId can be used by multiple Stati
      end
    end
  end
  for statusname,info in pairs(engineStatuses) do
    if info.ImmuneFlag and info.ImmuneFlag~="None" then
      StatusRequiresImmunity[statusname] = info.ImmuneFlag
    end
    if info.DisplayName then
      local status_loc = GetTranslation(info.DisplayName,statusname)
      StatusLocs[statusname] = status_loc
    end
  end
  
  for i,StatsId in pairs(Ext.Stats.GetStats("Potion")) do
    local stat = Ext.Stats.Get(StatsId)
    
    local immunitiesFromCurrentStatsId = {}
    local flags = stat.Flags -- a table, can contain Immunity, but not only this
    for _,flag in pairs(flags) do
      if flag:lower():find("immunity",1,true) then
        ImmunityFromStats[flag] = ImmunityFromStats[flag] or {}
        table.insert(ImmunityFromStats[flag],StatsId) -- several stats can provide the same immunity
        table.insert(immunitiesFromCurrentStatsId,flag)
      end
    end
    
    if StatsIdToStati[StatsId] and next(immunitiesFromCurrentStatsId) then
      for _,statusname in ipairs(StatsIdToStati[StatsId]) do
        local status_stat = not engineStatuses[statusname] and Ext.Stats.Get(statusname)
        local StatusType = status_stat and status_stat.StatusType or statusname
        if StatusType~="KNOCKED_DOWN" then -- game bug that this StatusType ignores immunities set in the files...
          for __,immunity in ipairs(immunitiesFromCurrentStatsId) do
            ImmunityFromStati[immunity] = ImmunityFromStati[immunity] or {}
            if not table_contains_value(ImmunityFromStati[immunity],statusname) then
              table.insert(ImmunityFromStati[immunity],statusname)
            end
            if StatusRequiresImmunity_REV[immunity] then
              for ___,immunestatus in ipairs(StatusRequiresImmunity_REV[immunity]) do
                StatusProvidesImmunityAgainstStati[statusname] = StatusProvidesImmunityAgainstStati[statusname] or {}
                if not table_contains_value(StatusProvidesImmunityAgainstStati[statusname],immunestatus) then
                  table.insert(StatusProvidesImmunityAgainstStati[statusname],immunestatus)
                end
              end
            end
          end
        end
      end
    end
    
  end
  
  -- Ext.Print("ImprovedTooltips_Serp SessionLoaded Ende")

end)


-- from "\Public\Shared\Stats\Generated\Structure\Modifiers.txt"
Potion_Modifiers={ModifierType=true,VitalityBoost=true,Strength=true,Finesse=true,Intelligence=true,Constitution=true,Memory=true,Wits=true,SingleHanded=true,TwoHanded=true,Ranged=true,DualWielding=true,RogueLore=true,WarriorLore=true,RangerLore=true,FireSpecialist=true,WaterSpecialist=true,AirSpecialist=true,EarthSpecialist=true,Sourcery=true,Necromancy=true,Polymorph=true,Summoning=true,PainReflection=true,Perseverance=true,Leadership=true,Telekinesis=true,Sneaking=true,Thievery=true,Loremaster=true,Repair=true,Barter=true,Persuasion=true,Luck=true,FireResistance=true,EarthResistance=true,WaterResistance=true,AirResistance=true,PoisonResistance=true,PhysicalResistance=true,PiercingResistance=true,Sight=true,Hearing=true,Initiative=true,Vitality=true,VitalityPercentage=true,MagicPoints=true,ActionPoints=true,ChanceToHitBoost=true,AccuracyBoost=true,DodgeBoost=true,DamageBoost=true,APCostBoost=true,SPCostBoost=true,APMaximum=true,APStart=true,APRecovery=true,Movement=true,MovementSpeedBoost=true,Gain=true,Armor=true,MagicArmor=true,ArmorBoost=true,MagicArmorBoost=true,CriticalChance=true,Act=true,["Act part"]=true,Duration=true,UseAPCost=true,ComboCategory=true,StackId=true,BoostConditions=true,Flags=true,StatusMaterial=true,StatusEffect=true,StatusIcon=true,SavingThrow=true,Weight=true,Value=true,InventoryTab=true,UnknownBeforeConsume=true,Reflection=true,Damage=true,["Damage Multiplier"]=true,["Damage Range"]=true,DamageType=true,AuraRadius=true,AuraSelf=true,AuraAllies=true,AuraEnemies=true,AuraNeutrals=true,AuraItems=true,AuraFX=true,RootTemplate=true,ObjectCategory=true,MinAmount=true,MaxAmount=true,Priority=true,Unique=true,MinLevel=true,MaxLevel=true,BloodSurfaceType=true,MaxSummons=true,AddToBottomBar=true,SummonLifelinkModifier=true,IgnoredByAI=true,RangeBoost=true,BonusWeapon=true,AiCalculationStatsOverride=true,RuneEffectWeapon=true,RuneEffectUpperbody=true,RuneEffectAmulet=true,RuneLevel=true,LifeSteal=true,IsFood=true,IsConsumable=true}


