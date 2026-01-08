-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md and the changelogs for v56 onwards, because they are not included in docu

SharedFns = {}


-- #######################################################

function SharedFns.RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.Osiris.RegisterListener(event, arity, state, function(...)
		if Ext.Server.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError(err)
			end
		end
	end)
end
-- returns the first key from table with value x
SharedFns.table_contains_value = function(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end
-- only character main chars (not sure yet if controllable has any effect or if currently in party)
-- returned nicht dasselbe wie Osi.CharacterIsPlayer (denn das nimmt zb auch incarnation mit auf)
SharedFns.GetAllPlayerChars = function()
  local _players = Osi.DB_IsPlayer:Get(nil) -- Will return a list of tuples of all player characters
  local players = {}
  for _,tupl in ipairs(_players) do
    local charGUID = tupl[1]
    table.insert(players,charGUID)
  end
  return players
end
SharedFns.IsPlayerMainChar = function(charGUID)
  local players = SharedFns.GetAllPlayerChars()
  return SharedFns.table_contains_value(players,charGUID)
end

local function deepcopy(orig, copies)
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

-- ##################################################################
-- ###################   Events   ###################################
-- ##################################################################

-- hm does not work, would like to add to infusions tooltip sth like "works for all summons"
-- Ext.Events.ModuleLoading:Subscribe(function()
  -- Ext.Print("ModuleLoading Serp")
  -- Ext.Stats.AddCustomDescription("Target_RangedInfusion", "SkillProperties", "Custom desc one")
-- end)




-- Client only
-- Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
-- note that StatsLoaded is not thrown every time you load into a session, iirc it only triggers when loading mods or going from title screen -> session
-- Calling Sync is not needed and may cause bugs in StatsLoaded!
SharedFns.OnStatsLoaded = function(e) 

  
  local Target_insert = "|Tagged:SUMMON|Tagged:DRAGON" -- Add Target_insert after Target_putAfter of every SkillData Target
  local Target_putAfter = "|Tagged:INCARNATE_G"
  for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    local MyStat = Ext.Stats.Get(name) -- GetRaw is for TargetConditions and SkillProperties not good useable (setting a new value of TargetConditions causes an error and SkillProperties is much more complicated)
    local TargetConditions = MyStat["TargetConditions"] -- eg: MySummon&(Tagged:INCARNATE_S|Tagged:INCARNATE_G)&!Spirit
    if TargetConditions and type(TargetConditions)=="string" and string.find(TargetConditions,Target_putAfter,1,true) then
      local new = TargetConditions:gsub(Target_putAfter,"%0"..Target_insert) -- %0 refers to the entire match found by gsub
      new = new:gsub("MySummon&", "") -- remove restriction to own summons -- ist "MySummon&" obwohl in Skill_Target "MySummon;" steht: MySummon&(Tagged:INCARNATE_S|Tagged:INCARNATE_G|Tagged:SUMMON|Tagged:DRAGON)&!Spirit
      -- Ext.Print("Change TargetConditions ",name," to ",new,". old was: ",TargetConditions)
      MyStat["TargetConditions"] = new
    end

    if MyStat then
      local SkillProperties = MyStat["SkillProperties"] -- in MyStat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
      if SkillProperties and type(SkillProperties)=="table" then
        local INCARNATE_S_entry = nil
        for _,entry in pairs(SkillProperties) do
          if entry.Condition=="Tagged:INCARNATE_S" then
            INCARNATE_S_entry = entry
            -- table (1 = table (
                -- 'Arg5' = -1
                -- 'Condition' = 'Tagged:INCARNATE_S'
                -- 'Duration' = -6.0
                -- 'SurfaceBoost' = false
                -- 'SurfaceBoosts' = table ()
                -- 'StatsId' = ''
                -- 'Arg4' = -1
                -- 'StatusChance' = 1.0
                -- 'Context' = stats::PropertyContext(Target)
                -- 'Type' = Status
                -- 'Action' = 'INF_FIRE'
              -- ))
            break
          end
        end
        if INCARNATE_S_entry then
          local dragonentry = deepcopy(INCARNATE_S_entry)
          dragonentry.Condition = "Tagged:DRAGON"
          dragonentry.Action = "BUFFALL_"..INCARNATE_S_entry.Action
          table.insert(SkillProperties,dragonentry)
          local summonentry = deepcopy(INCARNATE_S_entry)
          summonentry.Condition = "Tagged:SUMMON"
          summonentry.Action = "BUFFALL_"..INCARNATE_S_entry.Action
          table.insert(SkillProperties,summonentry)
          -- Ext.Print("Change SkillProperties ",name,dragonentry.Action)
          MyStat["SkillProperties"] = SkillProperties
        end
      end
    end
  end
  
  -- IceInfusion
  local MyStat = Ext.Stats.Get("INF_BLESSED_ICE")
  MyStat.DisplayNameRef = "|Blessed Water Infusion|"
  MyStat.StatusEffect = "RS3_FX_Char_ElementalDevil_Water_A_01:Dummy_BodyFX"
  MyStat.Material = "bb9f1adc-f4c9-426b-ac6b-f550c02b4ad6"
  local MyStat = Ext.Stats.Get("INF_BLESSED_ICE_G")
  MyStat.StatusEffect = "RS3_FX_Char_ElementalDevil_Giant_Water_A_01:Dummy_BodyFX;RS3_FX_Char_ElementalDevil_Giant_Water_A_01_Head:Dummy_StatusFX;RS3_FX_Char_ElementalDevil_Water_A_02:Dummy_R_HandFX,Dummy_L_HandFX"
  MyStat.Material = "d14d655e-3d4b-42a4-953a-0e270e352865"
  local MyStat = Ext.Stats.Get("Target_IceInfusion")
  MyStat.Icon = "Skill_Water_WaterInfusion"
  MyStat.DisplayNameRef = "|Blessed Water Infusion|"
  MyStat.DescriptionRef = "Change Incarnate's element to blessed water, unlocking Restoration and Steam Lance."
  
  local MyStat = Ext.Stats.Get("Summon_Incarnate")
  local SkillProperties = MyStat["SkillProperties"] -- in MyStat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
  if SkillProperties and type(SkillProperties)=="table" then
    local INCARNATE_S_entry = nil
    for _,entry in pairs(SkillProperties) do
      if entry.Condition=="InSurface:SurfaceBlood&Tagged:INCARNATE_S" then
        INCARNATE_S_entry = entry -- just to have a sample
        break
      end
    end
    if INCARNATE_S_entry then
      local newentry = deepcopy(INCARNATE_S_entry)
      newentry.Condition = "InSurface:SurfaceWaterFrozen&Tagged:INCARNATE_S"
      newentry.Action = "INF_ICE"
      table.insert(SkillProperties,newentry)
      newentry = deepcopy(INCARNATE_S_entry)
      newentry.Condition = "InSurface:SurfaceWaterFrozen&Tagged:INCARNATE_G"
      newentry.Action = "INF_ICE_G"
      table.insert(SkillProperties,newentry)
      MyStat["SkillProperties"] = SkillProperties
    end
  end
  
  
-- for _,entry in pairs(Ext.Stats.Get("Summon_Incarnate").SkillProperties) do print("erste",_,entry); for k,v in pairs(entry) do print("zweite",k,v) end end
  
-- erste   1       table: 00007FF3FAE24DC8
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_ICE
-- zweite  SurfaceBoosts   table: 00007FF3FAE24E00
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfaceWaterFrozen&Tagged:INCARNATE_S
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   2       table: 00007FF3FAE24F18
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_BLOOD_G
-- zweite  SurfaceBoosts   table: 00007FF3FAE24F50
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfaceBlood&Tagged:INCARNATE_G
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   3       table: 00007FF3FAE24F88
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_FIRE_G
-- zweite  SurfaceBoosts   table: 00007FF3FAE24FC0
-- zweite  Duration        -6.0
-- zweite  Condition       Tagged:INCARNATE_G&(InSurface:SurfaceFire|InSurface:SurfaceLava)
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   4       table: 00007FF3FAE24FF8
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_POISON
-- zweite  SurfaceBoosts   table: 00007FF3FAE25030
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfacePoison&Tagged:INCARNATE_S
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   5       table: 00007FF3FAE25068
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_WATER
-- zweite  SurfaceBoosts   table: 00007FF3FAE250A0
-- zweite  Duration        -6.0
-- zweite  Condition       (InSurface:SurfaceWater|InSurface:SurfaceDeepwater)&Tagged:INCARNATE_S
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   6       table: 00007FF3FAE250D8
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_BLOOD
-- zweite  SurfaceBoosts   table: 00007FF3FAE25110
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfaceBlood&Tagged:INCARNATE_S
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   7       table: 00007FF3FAE25148
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_FIRE
-- zweite  SurfaceBoosts   table: 00007FF3FAE25180
-- zweite  Duration        -6.0
-- zweite  Condition       Tagged:INCARNATE_S&(InSurface:SurfaceFire|InSurface:SurfaceLava)
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   8       table: 00007FF3FAE251B8
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_WATER_G
-- zweite  SurfaceBoosts   table: 00007FF3FAE251F0
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfaceWater&Tagged:INCARNATE_G
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   9       table: 00007FF3FAE25228
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_ELECTRIC_G
-- zweite  SurfaceBoosts   table: 00007FF3FAE25260
-- zweite  Duration        -6.0
-- zweite  Condition       Tagged:INCARNATE_G&(InSurface:SurfaceWaterElectrified|InSurface:SurfaceBloodElectrified)
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   10      table: 00007FF3FAE25298
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_ICE_G
-- zweite  SurfaceBoosts   table: 00007FF3FAE252D0
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfaceWaterFrozen&Tagged:INCARNATE_G
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   11      table: 00007FF3FAE25308
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_ELECTRIC
-- zweite  SurfaceBoosts   table: 00007FF3FAE25340
-- zweite  Duration        -6.0
-- zweite  Condition       Tagged:INCARNATE_S&(InSurface:SurfaceWaterElectrified|InSurface:SurfaceBloodElectrified)
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   12      table: 00007FF3FAE25378
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_OIL_G
-- zweite  SurfaceBoosts   table: 00007FF3FAE253B0
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfaceOil&Tagged:INCARNATE_G
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   13      table: 00007FF3FAE253E8
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_POISON_G
-- zweite  SurfaceBoosts   table: 00007FF3FAE25420
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfacePoison&Tagged:INCARNATE_G
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
-- erste   14      table: 00007FF3FAE25458
-- zweite  StatusChance    1.0
-- zweite  Type    Status
-- zweite  StatsId
-- zweite  Arg4    -1
-- zweite  Arg5    -1
-- zweite  Action  INF_OIL
-- zweite  SurfaceBoosts   table: 00007FF3FAE25490
-- zweite  Duration        -6.0
-- zweite  Condition       InSurface:SurfaceOil&Tagged:INCARNATE_S
-- zweite  SurfaceBoost    false
-- zweite  Context stats::PropertyContext(Target)
  
  
end


-- local RawStat = Ext.Stats.GetRaw("Target_FireInfusion");local SkillProperties = RawStat["SkillProperties"];for k,v in pairs(SkillProperties) do print("erste",k,v,type(v));if type(v)=="userdata" then for kk,vv in pairs(v) do print("zweite",kk,vv,type(vv)); if type(vv)=="userdata" then for kkk,vvv in pairs(vv) do print("dritte",kkk,vvv,type(vvv)); if type(vvv)=="userdata" then for kkkk,vvvv in pairs(vvv) do print("vierte",kkkk,vvvv,type(vvvv)) end end end end end end ;end 
-- erste   Name    Target_FireInfusion_SkillProperties     string
-- erste   AllPropertyContexts     stats::PropertyContext(Target)  userdata
-- zweite  1       Target  string
-- erste   Properties      stats::NamedElementManager<stats::PropertyData> (00007FF424F082A0)      userdata
-- zweite  NameToIndex     Map<FixedString, uint32> (00007FF424F082C8)     userdata
-- dritte  INF_FIRE_TARGET_IF(Tagged:INCARNATE_S)  0       number
-- dritte  INF_FIRE_G_TARGET_IF(Tagged:INCARNATE_G)        1       number
-- zweite  Elements        Array<stats::PropertyData> (00007FF424F082B0)   userdata
-- dritte  1       stats::PropertyStatus (00007FF415D8F1F0)        userdata
-- vierte  StatusChance    1.0     number
-- vierte  Name    INF_FIRE_TARGET_IF(Tagged:INCARNATE_S)  string
-- vierte  Duration        -6.0    number
-- vierte  TypeId  Status  userdata
-- vierte  Context stats::PropertyContext(Target)  userdata
-- vierte  Status  INF_FIRE        string
-- vierte  StatsId         string
-- vierte  Arg4    -1      number
-- vierte  Arg5    -1      number
-- vierte  SurfaceBoost    false   boolean
-- vierte  SurfaceBoosts   Array<SurfaceType> (00007FF415D8F240)   userdata
-- dritte  2       stats::PropertyStatus (00007FF415D8F650)        userdata
-- vierte  StatusChance    1.0     number
-- vierte  Name    INF_FIRE_G_TARGET_IF(Tagged:INCARNATE_G)        string
-- vierte  Duration        -6.0    number
-- vierte  TypeId  Status  userdata
-- vierte  Context stats::PropertyContext(Target)  userdata
-- vierte  Status  INF_FIRE_G      string
-- vierte  StatsId         string
-- vierte  Arg4    -1      number
-- vierte  Arg5    -1      number
-- vierte  SurfaceBoost    false   boolean
-- vierte  SurfaceBoosts   Array<SurfaceType> (00007FF415D8F6A0)   userdata
-- zweite  GetByName       function: 00007FFBDFE7EB60      function
    

-- add the 2 new infusion skills to every summoner player character
-- chars can have the ability from equipment
SharedFns.ChangeSummonSkills = function(charGUID,summoninglevel)
  summoninglevel = summoninglevel or Osi.CharacterGetAbility(charGUID,"Summoning")
  for _,skill in ipairs({"Target_BloodInfusion","Target_OilInfusion"}) do
    if summoninglevel>=1 then
      if Osi.CharacterHasSkill(charGUID,skill)==0 then
        Osi.CharacterAddSkill(charGUID,skill)
      end
    else
      if Osi.CharacterHasSkill(charGUID,skill)==1 then
        Osi.CharacterRemoveSkill(charGUID,skill)
      end
    end
  end
end

SharedFns.OnSaveLoaded = function(major, minor, patch, build)
  local players = SharedFns.GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    SharedFns.ChangeSummonSkills(charGUID)
  end
end
-- event also called for summons!
SharedFns.OnCharacterJoinedParty = function(charGUID)
  if SharedFns.IsPlayerMainChar(charGUID) then
    SharedFns.ChangeSummonSkills(charGUID)
  end
end

-- Ext.Stats.EnumLabelToIndex("AbilityType","RangerLore")
-- Ext.Stats.EnumIndexToLabel("AbilityType",2)
-- (CHARACTERGUID)_Character, (STRING)_Ability, (INTEGER)_OldBaseValue, (INTEGER)_NewBaseValue)
-- Is not called for changes by equipment
SharedFns.OnCharacterBaseAbilityChanged = function(charGUID,ability,old,new)
  -- Ext.Print("OnCharacterBaseAbilityChanged",charGUID,ability,old,new)
  -- local ability = Ext.Stats.EnumIndexToLabel("AbilityType",ability) -- is already string
  if ability=="Summoning" then
    SharedFns.ChangeSummonSkills(charGUID,new)
  end
end

