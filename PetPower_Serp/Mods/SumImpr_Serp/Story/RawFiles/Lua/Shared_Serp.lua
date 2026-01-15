-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md and the changelogs for v56 onwards, because they are not included in docu

SharedFns = {}

if Ext.IsServer() then
  Ext.Require("Server_ChangeDamageType.lua")
end


FreeInfusions = {}
-- FreeInfusions = {Target_IceInfusion_Normal={Summoning=1,WaterSpecialist=1}}

-- the giftbag adds 3 magic points to every summon for whatever reason, so do this more compatible in lua here
local AddMagicPoints = {"Summon_Poison_Slug","Summon_Oil_Slug","Summon_Plant","Summon_Fire_Slug","Summon_Incarnate_Character","Summon_Incarnate_Giant_Character",
  "Summon_BonePile_Character","Summon_BloatedCorpse_Character","Animals_Slugs_Poison_Summon","Summon_Condor_Character","ARX_HorrorSleep_Sunset_Newt",
  "Animals_Wolf_A_Black","Summon_Cat_Character"}

InfusionSkillChanges = {
    Target_RangedInfusion={SPNewAction="RangedInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Unlocks Ranged attack for your summon. Increases Magic Armour by [1] and damage by [2]%."},
    Target_PowerInfusion={SPNewAction="PowerInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Unlocks Battering Ram and an additional ability (depending on summon). Increases Physical Armour by [1] and damage by [2]%."},
    Target_ShadowInfusion={SPNewAction="ShadowInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Unlocks Chameleon Skin and an additional ability (depending on summon)."},
    Target_WarpInfusion={SPNewAction="WarpInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Grants additional mobility skills to a summon."},
    Target_FireInfusion={SPNewAction="FireInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Fire damage and gains an additional Pyrokinetic skill (depending on summon)."},
    Target_IceInfusion={SPNewAction="IceInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Water damage. Also grants Steam Lance and an additional Hydrosophist skill (depending on summon)."},
    Target_ElectricInfusion={SPNewAction="ElectricInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Air damage and gains an additional Aerotheurge skill (depending on summon)."},
    Target_PoisonInfusion={SPNewAction="PoisonInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Poison damage and gains an additional Geomancer skill (depending on summon)."},
    Target_NecrofireInfusion={SPNewAction="NecrofireInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Fire damage. Also grants Epidemic of Fire and an additional Pyrokinetic skill (depending on summon)."},
    Target_WaterInfusion={SPNewAction="WaterInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Water damage and gains an additional Hydrosophist skill (depending on summon)."},
    Target_AcidInfusion={SPNewAction="AcidInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Poison damage. Also grants Acid Spores and an additional Geomancer skill (depending on summon)."},
    Target_CursedElectricInfusion={SPNewAction="CursedElectricInfusion",SPDuration=0,Cooldown=1,DescriptionRef="Summon becomes immune to Air damage. Also grants Closed Circuit and an additional Aerotheurge skill (depending on summon)."},
  }
-- for mod added infusion skills which use vanilla INF_, replace the INF_ action with the new one:
SPInfStatusReplace = {INF_RANGED="RangedInfusion",INF_POWER="PowerInfusion",INF_SHADOW="ShadowInfusion",INF_WARP="WarpInfusion",
  INF_FIRE="FireInfusion",INF_BLESSED_ICE="IceInfusion",INF_ELECTRIC="ElectricInfusion",INF_POISON="PoisonInfusion",INF_NECROFIRE="NecrofireInfusion",
  INF_WATER="WaterInfusion",INF_ACID="AcidInfusion",INF_CURSED_ELECTRIC="CursedElectricInfusion",INF_BLOOD="BloodInfusion",
  INF_OIL="OilInfusion",INF_CURSED_BLOOD="CursedBloodInfusion",INF_CURSED_OIL="CursedOilInfusion",
  INF_FIRE_G="FireInfusion",INF_BLESSED_ICE_G="IceInfusion",INF_ELECTRIC_G="ElectricInfusion",INF_POISON_G="PoisonInfusion",
  INF_NECROFIRE_G="NecrofireInfusion", INF_WATER_G="WaterInfusion",INF_ACID_G="AcidInfusion",INF_CURSED_ELECTRIC_G="CursedElectricInfusion",
  INF_BLOOD_G="BloodInfusion",INF_OIL_G="OilInfusion",INF_CURSED_BLOOD_G="CursedBloodInfusion",INF_CURSED_OIL_G="CursedOilInfusion",
  INF_ICE="IceNormalInfusion";INF_ICE_G="IceNormalInfusion",
}
-- newly INF stati from mods will simply apply the same to all summons

-- #######################################################
-- #######################################################

local function UnifycharGuid(charGUID,char)
  char = char or Ext.Entity.GetCharacter(charGUID)
  return char and char.MyGuid or charGUID,char -- looks slightly different..: Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd vs c451954c-73bf-46ce-a1d1-caa9bbdc3cfd
end

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
SharedFns.table_removearrayvalue = function(t, lookup_value, removeall)
  for i, v in ipairs(t) do
    if v == lookup_value then
      if not removeall then
        break
      end
    end
  end
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

-- http://lua-users.org/wiki/OrderedTable
local function OrderedTable()
  local key2val, nextkey, firstkey = {}, {}, {}
  nextkey[nextkey] = firstkey
  local function onext(self, key)
    while key ~= nil do
      key = nextkey[key]
      local val = self[key]
      if val ~= nil then return key, val end
    end
  end
  local selfmeta = firstkey
  selfmeta.__nextkey = nextkey
  function selfmeta:__newindex(key, val)
    rawset(self, key, val)
    if nextkey[key] == nil then -- adding a new key
      nextkey[nextkey[nextkey]] = key
      nextkey[nextkey] = key
    end
  end
  function selfmeta:__pairs() return onext, self, firstkey end
  return setmetatable(key2val, selfmeta)
end

-- ##################################################################
-- ###################   Events   ###################################
-- ##################################################################




-- Client only
-- Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
-- note that StatsLoaded is not thrown every time you load into a session, iirc it only triggers when loading mods or going from title screen -> session
-- Calling Sync is not needed and may cause bugs in StatsLoaded!
SharedFns.OnStatsLoaded = function(e) 
  
  local AllRelevantStats = {}
  
  for i,name in pairs(Ext.Stats.GetStats("Character")) do
    if SharedFns.table_contains_value(AddMagicPoints,name) then
      local stat = Ext.Stats.Get(name)
      if stat then
        stat["MagicPoints"] = 3
      end
    end
    table.insert(AllRelevantStats,name)
  end
  for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    table.insert(AllRelevantStats,name)
  end
  for i,name in pairs(Ext.Stats.GetStats("Potion")) do
    table.insert(AllRelevantStats,name)
  end

  for i,name in pairs(AllRelevantStats) do
    local stat = Ext.Stats.Get(name)
    if stat then
      if name=="Summon_Incarnate" or stat.Using=="Summon_Incarnate" then
        -- make it ice incarnate if cast on ice
        local SkillProperties = stat["SkillProperties"] -- in stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
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
            stat["SkillProperties"] = SkillProperties
          end
        end
        
      -- Potion.xml adjustment made compatible
      elseif name=="Stats_Infusion_Necrofire" or stat.Using=="Stats_Infusion_Necrofire" then
        local flags = stat.Flags or {}
        table.insert(flags,"BurnImmunity")
        stat.Flags = flags
      elseif name=="Stats_Infusion_Acid" or stat.Using=="Stats_Infusion_Acid" then
        local flags = stat.Flags or {}
        table.insert(flags,"PoisonImmunity")
        table.insert(flags,"AcidImmunity")
        stat.Flags = flags      
        
      -- Skill xml adjustments
      elseif name=="Cone_EnemyOozeSpray" or stat.Using=="Cone_EnemyOozeSpray" then
        stat.CastTextEvent = "castsurface"
        stat.CastEffectTextEvent = ""
        
      elseif name=="Projectile_IncarnateRangedAttack" or stat.Using=="Projectile_IncarnateRangedAttack" then
        stat.DisplayNameRef = "|Ranged Attack|"
        stat.PrepareEffect = "{DamageType}[None]RS3_FX_Skills_Voodoo_Prepare_Voodoo_Blood_Root_01,KeepRot [Fire]RS3_FX_Skills_Fire_Prepare_Throw_Line_Root_01,KeepRot [Water]RS3_FX_Skills_Water_Prepare_Divine_Root_01,KeepRot [Air]RS3_FX_Skills_Air_Lightning_Prepare_Ground_01,KeepRot [Earth]RS3_FX_Skills_Earth_Prepare_Shout_Root_01,KeepRot [Poison]RS3_FX_Skills_Earth_Prepare_Throw_Line_Root_01,KeepRot"
        stat.CastEffect = "{DamageType}[None]RS3_FX_Char_Creature_ElementalDevil_Blood_Cast_Throw_01 [Fire]RS3_FX_Char_Creature_ElementalDevil_Fire_Cast_Throw_01 [Water]RS3_FX_Char_Creature_ElementalDevil_Water_Cast_Throw_01 [Air]RS3_FX_Char_Creature_ElementalDevil_Air_Cast_Throw_01 [Earth]RS3_FX_Char_Creature_ElementalDevil_Oil_Cast_Throw_01 [Poison]RS3_FX_Char_Creature_ElementalDevil_Poison_Cast_Throw_01"

      elseif name=="Projectile_PlantAcidSpore" or stat.Using=="Projectile_PlantAcidSpore" then
        stat.Icon = "CMP_Skill_AcidSpore"
      elseif name=="Shout_IncarnateSwapPlaces" or stat.Using=="Shout_IncarnateSwapPlaces" then
        stat.DisplayName = "Shout_IncarnateSwapPlaces_DisplayName"
        stat.DisplayNameRef = "Trading Places"
        stat.DescriptionRef = "Swaps the locations of a summon and its master."
      elseif name=="Shout_EnemyVileBurst" or stat.Using=="Shout_EnemyVileBurst" then
        -- Shout_EnemyVileBurst SkillProperties
        -- [{           -- "Action" : "TargetCreateSurface",
                        -- "Arg1" : 3.0,
                        -- "Arg2" : 0.0,
                        -- "Arg3" : "Blood",
                        -- "Arg4" : 1.0,
                        -- "Arg5" : 0.0,
                        -- "Context" : ["Self"],
                        -- "StatusHealType" : "None",
                        -- "Type" : "GameAction"
                -- },{
                        -- "Action" : "DYING",
                        -- "Arg4" : -1,
                        -- "Arg5" : -1,
                        -- "Context" :["Self"],
                        -- "Duration" : -6.0,
                        -- "StatsId" : "DoT",
                        -- "StatusChance" : 1.0,
                        -- "SurfaceBoost" : false,
                        -- "SurfaceBoosts" : [],
                        -- "Type" : "Status"}]
        -- change from   data "SkillProperties" "SELF:TargetCreateSurface,3,,Blood,100;SELF:DYING,100,-1,DoT" 
        -- to   data "SkillProperties" "SELF:DYING,100,-1,DoT"
        local SkillProperties = stat.SkillProperties
        if SkillProperties and type(SkillProperties)=="table" then
          local indextoremove = nil
          for i,entry in ipairs(SkillProperties) do
            if entry.Type=="GameAction" and entry.Action=="TargetCreateSurface" then
              indextoremove = i
              break
            end
          end
          if indextoremove then
            table.remove(SkillProperties,indextoremove)
            stat.SkillProperties = SkillProperties
          end
        end
      
        -- Target_RangedInfusion SkillProperties
        -- [{
        -- "Action" : "INF_RANGED",
        -- "Arg4" : -1,
        -- "Arg5" : -1,
        -- "Context" : ["Target","AoE"],
        -- "Duration" : -6.0,
        -- "StatsId" : "",
        -- "StatusChance" : 1.0,
        -- "SurfaceBoost" : false,
        -- "SurfaceBoosts" : [],
        -- "Type" : "Status"}]
        
        -- [1 = {
                -- 'Arg5' = -1
                -- 'Condition' = 'Tagged:INCARNATE_S'
                -- 'Duration' = -6.0
                -- 'SurfaceBoost' = false
                -- 'SurfaceBoosts' = []
                -- 'StatsId' = ''
                -- 'Arg4' = -1
                -- 'StatusChance' = 1.0
                -- 'Context' = stats::PropertyContext(Target)
                -- 'Type' = Status
                -- 'Action' = 'INF_FIRE'
              -- }]
        
        -- [{      "Action" : "RangedInfusion",
                -- "Arg4" : -1,
                -- "Arg5" : -1,
                -- "Context" : ["AoE","Target"],
                -- "Duration" : 0.0,
                -- "StatsId" : "",
                -- "StatusChance" : 1.0,
                -- "SurfaceBoost" : false,
                -- "SurfaceBoosts" : [],
                -- "Type" : "Status" }]
      -- TargetConditions for Infusions are changed below in another loop
      elseif InfusionSkillChanges[name] or (stat.Using and InfusionSkillChanges[stat.Using]) then
        local todo = InfusionSkillChanges[name] or (stat.Using and InfusionSkillChanges[stat.Using])
        local SkillProperties = stat.SkillProperties
        if SkillProperties and type(SkillProperties)=="table" then
          SkillProperties = {{Action=todo.SPNewAction,
            Arg4=-1,Arg5=-1,
            Context={"AoE","Target"},
            Duration=todo.Duration,
            StatsId="",
            StatusChance=1.0,SurfaceBoost=false,SurfaceBoosts={},
            Type="Status"
          }}
          stat.SkillProperties = SkillProperties
        end
        stat.Cooldown = todo.Cooldown
        stat.DescriptionRef = todo.DescriptionRef
      
    
      elseif name=="Projectile_LaunchPoisonSlug" or stat.Using=="Projectile_LaunchPoisonSlug" or name=="Projectile_LaunchOilBlob" or stat.Using=="Projectile_LaunchOilBlob" then
        stat.SpawnLifetime = 5
        
      elseif name=="_Summon_Incarnate_NecroFire_Infused" or stat.Using=="_Summon_Incarnate_NecroFire_Infused" then
        stat.DamageBoost = 10
      elseif name=="_Summon_Incarnate_BlessedIce_Infused" or stat.Using=="_Summon_Incarnate_BlessedIce_Infused" then
        stat.DamageBoost = 10
      elseif name=="_Summon_Incarnate_Earth_Infused" or stat.Using=="_Summon_Incarnate_Earth_Infused" then
        stat.DamageBoost = 0
      elseif name=="_Summon_Incarnate_Acid_Infused" or stat.Using=="_Summon_Incarnate_Acid_Infused" then -- officially 0, but nonsense
        stat.DamageBoost = 10
      elseif name=="_Summon_Incarnate_CursedElectric_Infused" or stat.Using=="_Summon_Incarnate_CursedElectric_Infused" then
        stat.DamageBoost = 10
      elseif name=="_Summon_Incarnate_NecroFire_Infused_Giant" or stat.Using=="_Summon_Incarnate_NecroFire_Infused_Giant" then
        stat.DamageBoost = 60
      elseif name=="_Summon_Incarnate_BlessedIce_Infused_Giant" or stat.Using=="_Summon_Incarnate_BlessedIce_Infused_Giant" then
        stat.DamageBoost = 60
      elseif name=="_Summon_Incarnate_Acid_Infused_Giant" or stat.Using=="_Summon_Incarnate_Acid_Infused_Giant" then
        stat.DamageBoost = 60
      elseif name=="_Summon_Incarnate_CursedElectric_Infused_Giant" or stat.Using=="_Summon_Incarnate_CursedElectric_Infused_Giant" then
        stat.DamageBoost = 60
        
        -- give oil armorboost and ice magicarmorboost
      elseif name=="Stats_Infusion_Oil" or stat.Using=="Stats_Infusion_Oil" then
        stat.ArmorBoost = 20
      elseif name=="Stats_Infusion_Cursed_Oil" or stat.Using=="Stats_Infusion_Cursed_Oil" then
        stat.ArmorBoost = 40
      elseif name=="Stats_Infusion_Ice" or stat.Using=="Stats_Infusion_Ice" then
        stat.MagicArmorBoost = 20
      elseif name=="Stats_Infusion_Blessed_Ice" or stat.Using=="Stats_Infusion_Blessed_Ice" then
        stat.MagicArmorBoost = 40
        table.insert(stat.Flags,"SlippingImmunity")
        table.insert(stat.Flags,"ChilledImmunity")
        
        -- make incarnate stronger by giving it 5 of all abilities (vanilla only has WarriorLore 5, which means with element infusion it will in fact deal less damage)
        -- (in fact these ability points of incarnate scale with level of the caster)
        -- dont change other summons, because eg. for a FireSlug it is ok, if after poison infusion it does less damage, since its not their main damage type.
         -- but incarnate should be allrounder
      elseif name=="Summon_Incarnate_Character" or stat.Using=="Summon_Incarnate_Character" then
        stat.FireSpecialist = 5
        stat.WaterSpecialist = 5
        stat.AirSpecialist = 5
        stat.EarthSpecialist = 5
      
      end
      
    end
  end
  
  -- no need to check .Using here, since we change everything with "nfusion" in the name and MySummon in TargetConditions
  for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    if name:find("nfusion",1,true) then
      local MyStat = Ext.Stats.Get(name) -- GetRaw is for TargetConditions and SkillProperties not good useable (setting a new value of TargetConditions causes an error and SkillProperties is much more complicated)
      if MyStat then
        local TargetConditions = MyStat["TargetConditions"] -- eg: MySummon&(Tagged:INCARNATE_S|Tagged:INCARNATE_G)&!Spirit
        if TargetConditions and type(TargetConditions)=="string" and TargetConditions:find("MySummon",1,true) then
          local new = TargetConditions:gsub("MySummon&", "Ally&") -- remove restriction to own summons -- ist "MySummon&" obwohl in Skill_Target "MySummon;" steht: MySummon&(Tagged:INCARNATE_S|Tagged:INCARNATE_G|Tagged:SUMMON|Tagged:DRAGON)&!Spirit
          if not new:find("|Tagged:SUMMON") then
            new = new:gsub("Tagged:INCARNATE_S|", "Tagged:INCARNATE_S|Tagged:SUMMON|") -- different than giftbag, because we simply check SUMMON tag instead
          end
          if not new:find("&!Spirit") then
            new = new.."&!Spirit" -- is in vanilla, so better include it
          end
          MyStat["TargetConditions"] = new
        end
        -- update vanilla INF_ stati used by mods in skills (newly added INF stati should work fine, doing the same status on all summons, unless SkillProperties checks for specific Tags)
        local SkillProperties = MyStat.SkillProperties
        if SkillProperties and type(SkillProperties)=="table" then
          local changed = false
          for _,entry in ipairs(SkillProperties) do
            if entry.Type=="Status" then
              for inf,new in pairs(SPInfStatusReplace) do
                if entry.Action==inf then
                  entry.Action = new
                  entry.Duration = 0
                  changed = true
                  break
                end
              end
            end
          end
          if changed then
            MyStat.SkillProperties = SkillProperties
          end
        end
      end
    end
  end
  
  
  -- Adjusting the RootTemplates is not completely possible, because we dont have access to Scripts in them with Ext.Template.GetTemplate
  -- we can change Tags, but this is not important, since we search for SUMMON anyways
  -- But we can change Scripts indirectly by using Ext.IO.AddPathOverride below!
  -- so we will remove the game overwritten RootTemplate files and do the changes here, if it was not just a Tag change
  -- Luckily the Slugs seem to work fine after AddPathOverride, although the scripts had different starting Paramaters!
  local template = Ext.Template.GetTemplate("6f8db517-f1af-4b47-b095-f239fd2293d0")
  template.Equipment = "Summon_Toy"
  -- 6f8db517-f1af-4b47-b095-f239fd2293d0 Summons_WindUpToy
  -- 7ecb0aa4-376f-4e9a-99d6-6eff900c3c77 Summons_PoisonOoze
  -- 40c6a905-74c3-4d89-9ffe-d3493a22cabd Summons_BloatedCorpse
  -- 53f49a2d-36a1-4c47-8cef-91c0f3ae0ef9 Summons_SoulWolf
  -- 163befcc-d8f6-4c3a-ba1d-536d1f7568bc Summons_FireSlug
  -- 0441f88d-4a0a-40ec-ac69-3a4fe7906cdf Summons_Condor
  -- e61da3a2-6dfd-4f2e-8f62-6bfbddb5a7f9 Summons_OilBlob
  -- e63a712f-fc87-4469-8848-fd8941043afd Summons_Plant
end
Ext.IO.AddPathOverride("Public/Shared/Scripts/Bomber.charScript", "Public/SumImpr_Serp/Scripts/CMP_Bomber.charScript")
Ext.IO.AddPathOverride("Public/CMP_SummoningImproved_Kamil/Scripts/CMP_Bomber.charScript", "Public/SumImpr_Serp/Scripts/CMP_Bomber.charScript")
Ext.IO.AddPathOverride("Public/Shared/Scripts/CMB_Slug.charScript", "Public/SumImpr_Serp/Scripts/CMP_Slugs.charScript")
Ext.IO.AddPathOverride("Public/CMP_SummoningImproved_Kamil/Scripts/CMP_Slugs.charScript", "Public/SumImpr_Serp/Scripts/CMP_Slugs.charScript")


-- add free infusion skills, so we dont need a skillbook for them
SharedFns.DoFreeInfusions = function(charGUID)
  for skill,reqs in pairs(FreeInfusions) do
    local canlearn = true
    for reqab,reqlevel in pairs(reqs) do
      local level = Osi.CharacterGetAbility(charGUID,reqab)
      if not level or level<reqlevel then
        canlearn = false
        break
      end
    end
    if canlearn then
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
    SharedFns.DoFreeInfusions(charGUID)
  end
end


-- (CHARACTERGUID)_Character, (STRING)_Ability, (INTEGER)_OldBaseValue, (INTEGER)_NewBaseValue)
-- Is not called for changes by equipment
SharedFns.OnCharacterBaseAbilityChanged = function(charGUID,ability,old,new)
  SharedFns.DoFreeInfusions(charGUID)
end

SharedFns.OnCharacterJoinedParty = function(charGUID)
  if SharedFns.IsPlayerMainChar(charGUID) then
    SharedFns.DoFreeInfusions(charGUID)
  end
end


-- ############################################################
-- ############################################################

-- Lua Replacement of the txt script CMP_SummoningImproved_Statuses.txt
-- (because easier to code and debug, I failed to work with these stupid DB stuff and removing Shout_SuicideBomberExplosion for toy refused to work on IceNormalInfusion)


-- make sure our script is always loaded, instead of vanilla
Ext.IO.AddPathOverride("Mods/CMP_SummoningImproved_Kamil/Story/RawFiles/Goals/CMP_SummoningImproved_Statuses.txt", "Mods/SumImpr_Serp/Story/RawFiles/Goals/CMP_SummoningImproved_Statuses_Serp.txt")


-- Apply the correct infusion also to all non-hardcoded summons possibly added by other mods. Using the INCARNATE_S infusion
-- copy pasted from CMP_SummoningImproved_Statuses.txt (some selected mod summons added into that file instead)
local VanillaHandledSummons = {
  -- Osiris script suck, we will do it everything in lua instead, therefore outcommented
  -- "118d7359-b7d5-41ea-8c55-86ce27afceba","13f9314d-e744-4dc5-acf2-c6bf77a04892",
  -- "2a923cb8-beeb-48be-9a3a-5da981b1e3fe","e63a712f-fc87-4469-8848-fd8941043afd","40c6a905-74c3-4d89-9ffe-d3493a22cabd",
  -- "e61da3a2-6dfd-4f2e-8f62-6bfbddb5a7f9","163befcc-d8f6-4c3a-ba1d-536d1f7568bc","0441f88d-4a0a-40ec-ac69-3a4fe7906cdf",
  -- "1918aa0e-862e-4f53-8656-7f579658222a","7ecb0aa4-376f-4e9a-99d6-6eff900c3c77","53f49a2d-36a1-4c47-8cef-91c0f3ae0ef9",
  -- "6f8db517-f1af-4b47-b095-f239fd2293d0","4f7cdf30-0d44-44d2-bcf2-91850728107d",
  -- some mod summons added in there already, but outcommented, doing it on lua instead
  -- "672acd14-e1da-46a4-b365-1883ddc60243","892f8d0d-44bb-4772-a6c8-7798937ecc39","bb08f08c-ffff-4743-8410-4a0dacacc9be",
  -- "f1f51e01-cc07-4127-b3f2-424eeffe1323","1ea8cdd9-4275-400e-9b9f-ffce3bb7b503","d5028e0e-3787-4561-aec3-c0c3ddb10586","66fef67a-2a03-41d7-82f4-710933d553a7",
  -- "7131368d-fec2-4773-a9fe-2dfb7e96d09f","91db43b6-f064-44b6-adc5-92077965bd95","f6a7a5e9-b333-4acc-a652-5b37420def87",
}

-- checking the Stats Name of summon for some specific texts to decide which inf we apply
-- incarnate , incarnate_g , bone , plant, corpse, oil, fire, poison, condor, dragon, wolf , toy, cat
-- order matters, the first found will we chosen, if non found a random one will be chosen
StatsnameToInfusion = OrderedTable()
  StatsnameToInfusion.giantincarnate="incarnate_g"; StatsnameToInfusion.incarnate_g="incarnate_g"; StatsnameToInfusion.incarnate="incarnate";
  StatsnameToInfusion.mewt="dragon"; StatsnameToInfusion.dragon="dragon"; StatsnameToInfusion.bone="bone"; 
  StatsnameToInfusion.zombie="corpse"; StatsnameToInfusion.corpse="corpse"; StatsnameToInfusion.skeleton={"bone","corpse"}; 
  StatsnameToInfusion.plant="plant"; StatsnameToInfusion.condor="condor"; StatsnameToInfusion.vulture="condor"; 
  StatsnameToInfusion.bird="condor"; StatsnameToInfusion.wolf="wolf"; StatsnameToInfusion.toy="toy"; StatsnameToInfusion.bomber="toy"; 
  StatsnameToInfusion.cat="cat"; StatsnameToInfusion.dog="wolf"; StatsnameToInfusion.magma="fire"; 
  StatsnameToInfusion.death={"bone","corpse"}; StatsnameToInfusion.oil="oil"; StatsnameToInfusion.earth="oil"; 
  StatsnameToInfusion.stone="oil"; StatsnameToInfusion.poison="poison"; StatsnameToInfusion.fire="fire"; 
  StatsnameToInfusion.slug={"fire","oil","poison"};StatsnameToInfusion.ooze={"fire","oil","poison"};
  
SharedFns.InfusionToStatus = {
  WarpInfusion={incarnate="INF_WARP_INCARNATE_S",incarnate_g="INF_WARP_INCARNATE_S",bone="INF_WARP_BONEPILE",plant="INF_WARP_PLANT",oil="INF_WARP_OILBLOB",fire="INF_WARP_FIRESLUG",condor="INF_WARP_CONDOR",dragon="INF_WARP_NEWT",poison="INF_WARP_POISONSLUG",wolf="INF_WARP_SOULWOLF",toy="INF_WARP_TOY",cat="INF_WARP_CAT",corpse="INF_WARP_CORPSE",},
  RangedInfusion={incarnate="INF_RANGED",incarnate_g="INF_RANGED",bone="INF_RANGED_BONEPILE",plant="INF_POWER_PLANT",oil="INF_POWER_OILBLOB",fire="INF_POWER_FIRESLUG",condor="INF_RANGED_CONDOR",dragon="INF_RANGED_NEWT",poison="INF_RANGED_POISONSLUG",wolf="INF_RANGED_SOULWOLF",toy="INF_RANGED_TOY",cat="INF_RANGED_CAT",corpse="INF_POWER_CORPSE",},
  PowerInfusion={incarnate="INF_POWER_INCARNATE_S",incarnate_g="INF_POWER_INCARNATE_S",bone="INF_POWER_BONEPILE",plant="INF_RANGED_PLANT",oil="INF_RANGED_OILBLOB",fire="INF_RANGED_FIRESLUG",condor="INF_POWER_CONDOR",dragon="INF_POWER_NEWT",poison="INF_POWER_POISONSLUG",wolf="INF_POWER_SOULWOLF",toy="INF_POWER_TOY",cat="INF_POWER_CAT",corpse="INF_RANGED_CORPSE",},
  ShadowInfusion={incarnate="INF_SHADOW_INCARNATE_S",incarnate_g="INF_SHADOW_INCARNATE_S",bone="INF_SHADOW_BONEPILE",plant="INF_SHADOW_PLANT",oil="INF_SHADOW_OILBLOB",fire="INF_SHADOW_FIRESLUG",condor="INF_SHADOW_CONDOR",dragon="INF_SHADOW_NEWT",poison="INF_SHADOW_POISONSLUG",wolf="INF_SHADOW_SOULWOLF",toy="INF_SHADOW_TOY",cat="INF_SHADOW_CAT",corpse="INF_SHADOW_CORPSE",},
  FireInfusion={incarnate="INF_FIRE_INCARNATE_S",incarnate_g="INF_FIRE_INCARNATE_G",bone="INF_FIRE_BONEPILE",plant="INF_FIRE_PLANT",oil="INF_FIRE_OILBLOB",fire="INF_FIRE_FIRESLUG",condor="INF_FIRE_CONDOR",dragon="INF_FIRE_NEWT",poison="INF_FIRE_POISONSLUG",wolf="INF_FIRE_SOULWOLF",toy="INF_FIRE_TOY",cat="INF_FIRE_CAT",corpse="INF_FIRE_CORPSE",},
  IceInfusion={incarnate="INF_BLESSED_ICE_INCARNATE_S",incarnate_g="INF_BLESSED_ICE_INCARNATE_G",bone="INF_BLESSED_ICE_BONEPILE",plant="INF_BLESSED_ICE_PLANT",oil="INF_BLESSED_ICE_OILBLOB",fire="INF_BLESSED_ICE_FIRESLUG",condor="INF_BLESSED_ICE_CONDOR",dragon="INF_BLESSED_ICE_NEWT",poison="INF_BLESSED_ICE_POISONSLUG",wolf="INF_BLESSED_ICE_SOULWOLF",toy="INF_BLESSED_ICE_TOY",cat="INF_BLESSED_ICE_CAT",corpse="INF_BLESSED_ICE_CORPSE",},
  ElectricInfusion={incarnate="INF_ELECTRIC_INCARNATE_S",incarnate_g="INF_ELECTRIC_INCARNATE_G",bone="INF_ELECTRIC_BONEPILE",plant="INF_ELECTRIC_PLANT",oil="INF_ELECTRIC_OILBLOB",fire="INF_ELECTRIC_FIRESLUG",condor="INF_ELECTRIC_CONDOR",dragon="INF_ELECTRIC_NEWT",poison="INF_ELECTRIC_POISONSLUG",wolf="INF_ELECTRIC_SOULWOLF",toy="INF_ELECTRIC_TOY",cat="INF_ELECTRIC_CAT",corpse="INF_ELECTRIC_CORPSE",},
  PoisonInfusion={incarnate="INF_POISON_INCARNATE_S",incarnate_g="INF_POISON_INCARNATE_G",bone="INF_POISON_BONEPILE",plant="INF_POISON_PLANT",oil="INF_POISON_OILBLOB",fire="INF_POISON_FIRESLUG",condor="INF_POISON_CONDOR",dragon="INF_POISON_NEWT",poison="INF_POISON_POISONSLUG",wolf="INF_POISON_SOULWOLF",toy="INF_POISON_TOY",cat="INF_POISON_CAT",corpse="INF_POISON_CORPSE",},
  NecrofireInfusion={incarnate="INF_NECROFIRE_INCARNATE_S",incarnate_g="INF_NECROFIRE_INCARNATE_G",bone="INF_NECROFIRE_BONEPILE",plant="INF_NECROFIRE_PLANT",oil="INF_NECROFIRE_OILBLOB",fire="INF_NECROFIRE_FIRESLUG",condor="INF_NECROFIRE_CONDOR",dragon="INF_NECROFIRE_NEWT",poison="INF_NECROFIRE_POISONSLUG",wolf="INF_NECROFIRE_SOULWOLF",toy="INF_NECROFIRE_TOY",cat="INF_NECROFIRE_CAT",corpse="INF_NECROFIRE_CORPSE",},
  WaterInfusion={incarnate="INF_WATER_INCARNATE_S",incarnate_g="INF_WATER_INCARNATE_G",bone="INF_WATER_BONEPILE",plant="INF_WATER_PLANT",oil="INF_WATER_OILBLOB",fire="INF_WATER_FIRESLUG",condor="INF_WATER_CONDOR",dragon="INF_WATER_NEWT",poison="INF_WATER_POISONSLUG",wolf="INF_WATER_SOULWOLF",toy="INF_WATER_TOY",cat="INF_WATER_CAT",corpse="INF_WATER_CORPSE",},
  AcidInfusion={incarnate="INF_ACID_INCARNATE_S",incarnate_g="INF_ACID_INCARNATE_G",bone="INF_ACID_BONEPILE",plant="INF_ACID_PLANT",oil="INF_ACID_OILBLOB",fire="INF_ACID_FIRESLUG",condor="INF_ACID_CONDOR",dragon="INF_ACID_NEWT",poison="INF_ACID_POISONSLUG",wolf="INF_ACID_SOULWOLF",toy="INF_ACID_TOY",cat="INF_ACID_CAT",corpse="INF_ACID_CORPSE",},
  CursedElectricInfusion={incarnate="INF_CURSED_ELECTRIC_INCARNATE_S",incarnate_g="INF_CURSED_ELECTRIC_INCARNATE_G",bone="INF_CURSED_ELECTRIC_BONEPILE",plant="INF_CURSED_ELECTRIC_PLANT",oil="INF_CURSED_ELECTRIC_OILBLOB",fire="INF_CURSED_ELECTRIC_FIRESLUG",condor="INF_CURSED_ELECTRIC_CONDOR",dragon="INF_CURSED_ELECTRIC_NEWT",poison="INF_CURSED_ELECTRIC_POISONSLUG",wolf="INF_CURSED_ELECTRIC_SOULWOLF",toy="INF_CURSED_ELECTRIC_TOY",cat="INF_CURSED_ELECTRIC_CAT",corpse="INF_CURSED_ELECTRIC_CORPSE",},
  OilInfusion={incarnate="INF_OIL_INCARNATE_S",incarnate_g="INF_OIL_INCARNATE_G",bone="INF_OIL_BONEPILE",plant="INF_OIL_PLANT",oil="INF_OIL_OILBLOB",fire="INF_OIL_FIRESLUG",condor="INF_OIL_CONDOR",dragon="INF_OIL_NEWT",poison="INF_OIL_POISONSLUG",wolf="INF_OIL_SOULWOLF",toy="INF_OIL_TOY",cat="INF_OIL_CAT",corpse="INF_OIL_CORPSE",},
  CursedOilInfusion={incarnate="INF_CURSED_OIL_INCARNATE_S",incarnate_g="INF_CURSED_OIL_INCARNATE_G",bone="INF_CURSED_OIL_BONEPILE",plant="INF_CURSED_OIL_PLANT",oil="INF_CURSED_OIL_OILBLOB",fire="INF_CURSED_OIL_FIRESLUG",condor="INF_CURSED_OIL_CONDOR",dragon="INF_CURSED_OIL_NEWT",poison="INF_CURSED_OIL_POISONSLUG",wolf="INF_CURSED_OIL_SOULWOLF",toy="INF_CURSED_OIL_TOY",cat="INF_CURSED_OIL_CAT",corpse="INF_CURSED_OIL_CORPSE",},
  BloodInfusion={incarnate="INF_BLOOD_INCARNATE_S",incarnate_g="INF_BLOOD_INCARNATE_G",bone="INF_BLOOD_BONEPILE",plant="INF_BLOOD_PLANT",oil="INF_BLOOD_OILBLOB",fire="INF_BLOOD_FIRESLUG",condor="INF_BLOOD_CONDOR",dragon="INF_BLOOD_NEWT",poison="INF_BLOOD_POISONSLUG",wolf="INF_BLOOD_SOULWOLF",toy="INF_BLOOD_TOY",cat="INF_BLOOD_CAT",corpse="INF_BLOOD_CORPSE",},
  CursedBloodInfusion={incarnate="INF_CURSED_BLOOD_INCARNATE_S",incarnate_g="INF_CURSED_BLOOD_INCARNATE_G",bone="INF_CURSED_BLOOD_BONEPILE",plant="INF_CURSED_BLOOD_PLANT",oil="INF_CURSED_BLOOD_OILBLOB",fire="INF_CURSED_BLOOD_FIRESLUG",condor="INF_CURSED_BLOOD_CONDOR",dragon="INF_CURSED_BLOOD_NEWT",poison="INF_CURSED_BLOOD_POISONSLUG",wolf="INF_CURSED_BLOOD_SOULWOLF",toy="INF_CURSED_BLOOD_TOY",cat="INF_CURSED_BLOOD_CAT",corpse="INF_CURSED_BLOOD_CORPSE",},
  IceNormalInfusion={incarnate="INF_ICE",incarnate_g="INF_ICE_G",bone="INF_ICE_ALL",plant="INF_ICE_ALL",oil="INF_ICE_ALL",fire="INF_ICE_ALL",condor="INF_ICE_ALL",dragon="INF_ICE_ALL",poison="INF_ICE_ALL",wolf="INF_ICE_ALL",toy="INF_ICE_TOY",cat="INF_ICE_ALL",corpse="INF_ICE_ALL",},
}
NonVanillaInfusions = {IceNormalInfusion=true} -- not handled in vanilla txt script file

-- WeaponOverride was removed in status for more compatible. define here the new DamageType
-- (DamageBoost is done in Stats from the Status instead of the weapon now)
InfusionToWeaponDamageType = {
  -- WarpInfusion="",
  -- RangedInfusion="",
  -- PowerInfusion="",
  -- ShadowInfusion="",
  FireInfusion="Fire",
  IceInfusion="Water",
  ElectricInfusion="Air",
  PoisonInfusion="Poison",
  NecrofireInfusion="Fire",
  WaterInfusion="Water",
  AcidInfusion="Poison",
  CursedElectricInfusion="Air",
  OilInfusion="Earth",
  CursedOilInfusion="Earth",
  BloodInfusion="Physical",
  CursedBloodInfusion="Physical",
  IceNormalInfusion="Water",
}

SharedFns.InfusionToSurface = {
  FireInfusion="SurfaceFire",
  IceInfusion="SurfaceWaterFrozenBlessed",
  ElectricInfusion="SurfaceWaterElectrified",
  PoisonInfusion="SurfacePoison",
  NecrofireInfusion="SurfaceFireCursed",
  WaterInfusion="SurfaceWater",
  AcidInfusion="SurfacePoisonCursed",
  CursedElectricInfusion="SurfaceWaterCloudElectrifiedCursed",
  OilInfusion="SurfaceOil",
  CursedOilInfusion="SurfaceOilCursed",
  BloodInfusion="SurfaceBlood",
  CursedBloodInfusion="SurfaceBloodCursed",
  IceNormalInfusion="SurfaceWaterFrozen",
}
-- templateid of Slugs/ooze/bloatedCorpse which draw surface path and bleed the element
SharedFns.SlugsToSurface = {
  -- vanilla
  ["40c6a905-74c3-4d89-9ffe-d3493a22cabd"]="SurfaceBlood",["e61da3a2-6dfd-4f2e-8f62-6bfbddb5a7f9"]="SurfaceOil",
  ["163befcc-d8f6-4c3a-ba1d-536d1f7568bc"]="SurfaceFire",["7ecb0aa4-376f-4e9a-99d6-6eff900c3c77"]="SurfacePoison",
  -- mod (skill collection, so from different mods I think)
  ["7131368d-fec2-4773-a9fe-2dfb7e96d09f"]="SurfacePoison",["91db43b6-f064-44b6-adc5-92077965bd95"]="SurfaceWater",
  ["f6a7a5e9-b333-4acc-a652-5b37420def87"]="SurfaceFire",
}


SharedFns.OnCharacterStatusApplied = function(charGUID,status,causee)
  if SharedFns.InfusionToStatus[status] then
    local status_lower = status:lower()
    local char = Ext.Entity.GetCharacter(charGUID)
    if char then
      local template = char.RootTemplate
      if template then
        local templateid = template.Id
        if templateid then
          if templateid:find("6f8db517-f1af-4b47-b095-f239fd2293d0",1,true) and InfusionToWeaponDamageType[status] then -- Toy, remove suicide skill if any elemental infusion, correct skill is added via status
            Osi.CharacterRemoveSkill(charGUID,"Shout_SuicideBomberExplosion")
          end
          -- if NonVanillaInfusions[status] or not SharedFns.table_contains_value(VanillaHandledSummons,templateid) then
            local StatsName = template.Stats:lower()
            local usedstatskey = {"incarnate","incarnate_g","bone","plant","corpse","oil","fire","poison","condor","dragon","wolf","toy","cat"}
            local charGUID_lower = charGUID:lower()
            for txtsearch,statskey in pairs(StatsnameToInfusion) do
              if StatsName:find(txtsearch,1,true) or charGUID_lower:find(txtsearch,1,true) then
                usedstatskey = statskey
                break -- first found is used
              end
            end
            if type(usedstatskey)=="table" then
              usedstatskey = usedstatskey[Ext.Random(#usedstatskey)] -- random choice (yes may be different per cast and even chance to get the stronger buff for incarnates)
            end
            local inf_status = SharedFns.InfusionToStatus[status][usedstatskey]
            if inf_status then
              -- Ext.Print("PetPowerSerp: OnCharacterStatusApplied",charGUID,status,StatsName,inf_status)
              Osi.RemoveStatus(charGUID,status)
              Osi.ApplyStatus(charGUID,inf_status,-1,1)
            end
          -- end
          
          -- Change DamageType for all of them, because we removed the WeaponOverride from the Status, to be compatible with any summon without replacing the weapon with another one (because if removes weapon skills and changes damage)
          local newweapondamagetype = InfusionToWeaponDamageType[status]
          if newweapondamagetype then
            local weapondone = {}
            for _,weapon in ipairs({char.Stats.MainWeapon,char.Stats.OffHandWeapon,char.Stats:GetItemBySlot("Weapon"),char.Stats:GetItemBySlot("Shield")}) do -- OffHandWeapon only gets weapon, not shield
              weapon = weapon and weapon.GameObject
              if weapon and not weapondone[weapon] then
                weapondone[weapon]=true -- to not do the same twice
                print("PetPowerSerp: Infusion Change DamageType",charGUID,weapon,newweapondamagetype)
                EsvReforger:ChangeDamageType(weapon,newweapondamagetype,char,true)
              end
            end
            if SharedFns.SlugsToSurface[templateid] then
              if SharedFns.InfusionToSurface[status] then
                Osi.CharacterSetCustomBloodSurface(charGUID,SharedFns.InfusionToSurface[status])
              end
            end
          end
        end
      end
    end
  end
end

if Ext.IsServer() then
  SharedFns.RegisterProtectedOsirisListener("StoryEvent", 2, "before", function(charGUID, event)
    -- print("OnObjectStoryEvent",charGUID, event)
    if Osi.ObjectIsCharacter(charGUID)==1 then
      if event=="CMP_ResetBloodSurface" then
        local char = Ext.Entity.GetCharacter(charGUID)
        if char then
          local template = char.RootTemplate
          if template then
            local templateid = template.Id
            if templateid then
              if templateid:find("40c6a905-74c3-4d89-9ffe-d3493a22cabd",1,true) then -- BloatedCorpse vanilla
                Osi.CharacterSetCustomBloodSurface(charGUID,"SurfaceBlood")
              end
            end
          end
        end
      end
    end
  end)
end




-- ########################


-- RootTemplate
-- {
	-- "AIBoundsAIType" : 2,
	-- "AIBoundsHeight" : 1.440000057220459,
	-- "AIBoundsMax" : 
	-- [
		-- 0.97918897867202759,
		-- 2.5808200836181641,
		-- 1.0911400318145752
	-- ],
	-- "AIBoundsMin" : 
	-- [
		-- -0.97918897867202759,
		-- -0.033359501510858536,
		-- -0.72933501005172729
	-- ],
	-- "AIBoundsRadius" : 0.31999999284744263,
	-- "ActivationGroupId" : "",
	-- "AllowReceiveDecalWhenAnimated" : false,
	-- "AvoidTraps" : true,
	-- "BloodSurfaceType" : "",
	-- "CameraOffset" : 
	-- [
		-- 0.0,
		-- 0.0,
		-- 0.0
	-- ],
	-- "CanBeTeleported" : true,
	-- "CanClimbLadders" : false,
	-- "CanOpenDoors" : false,
	-- "CanShootThrough" : false,
	-- "CastShadow" : true,
	-- "ClimbAttachSpeed" : 4.0,
	-- "ClimbDetachSpeed" : 2.440000057220459,
	-- "ClimbLoopSpeed" : 4.0,
	-- "CombatComponent" : 
	-- {
		-- "Alignment" : "Good NPC",
		-- "CanFight" : true,
		-- "CanJoinCombat" : true,
		-- "CombatGroupID" : "",
		-- "IsBoss" : false,
		-- "IsInspector" : false,
		-- "StartCombatRange" : -1.0
	-- },
	-- "CombatTemplate" : "*RECURSION*",
	-- "CoverAmount" : 0,
	-- "DefaultDialog" : "",
	-- "DefaultState" : 0,
	-- "DisplayName" : "h95bf4e0cg845ag478ag949fgafbdc2847bc5",
	-- "EmptyVisualSet" : true,
	-- "Equipment" : "Summon_Toy",
	-- "EquipmentClass" : 8,
	-- "ExplodedResourceID" : "d9a00fe2-1dce-4a32-8ca8-1c1da9189e53",
	-- "ExplosionFX" : "",
	-- "FadeGroup" : "",
	-- "FadeIn" : false,
	-- "Fadeable" : false,
	-- "FileName" : "E:/Spiele/GOG Games/Divinity - Original Sin 2/DefEd/Data/Public/SumImpr_Serp/RootTemplates/6f8db517-f1af-4b47-b095-f239fd2293d0.lsf",
	-- "Flags" : [],
	-- "Floating" : false,
	-- "FootstepWeight" : 1,
	-- "ForceUnsheathSkills" : false,
	-- "GameMasterSpawnSection" : -1,
	-- "GameMasterSpawnSubSection" : "h5b58a9a9g7632g4958g88fagd579fcea5423",
	-- "GeneratePortrait" : "",
	-- "GetColorChoices" : "function: 00007FFED375CD80",
	-- "GetVisualChoices" : "function: 00007FFED375CCC0",
	-- "GhostTemplate" : "",
	-- "GroupID" : 0,
	-- "Handle" : 9823,
	-- "HardcoreOnly" : false,
	-- "HasGameplayValue" : false,
	-- "HasParentModRelation" : false,
	-- "HitFX" : "RS3_FX_GP_Impacts_Sparks_01",
	-- "Icon" : "Portrait_Creatures_Summons_WindUpToy_A",
	-- "Id" : "6f8db517-f1af-4b47-b095-f239fd2293d0",
	-- "InfluenceTreasureLevel" : false,
	-- "InventoryType" : 8,
	-- "IsArenaChampion" : false,
	-- "IsDeleted" : false,
	-- "IsEquipmentLootable" : false,
	-- "IsGlobal" : false,
	-- "IsHuge" : false,
	-- "IsLootable" : false,
	-- "IsPlayer" : false,
	-- "IsReflecting" : false,
	-- "IsShadowProxy" : false,
	-- "ItemList" : [],
	-- "JumpUpLadders" : false,
	-- "LevelName" : "",
	-- "LevelOverride" : 0,
	-- "LightID" : "",
	-- "ModFolder" : "SumImpr_Serp",
	-- "Name" : "Summons_WindUpToy",
	-- "NoRotate" : false,
	-- "NonUniformScale" : false,
	-- "NotHardcore" : false,
	-- "OnDeathActions" : 
	-- [
		-- {
			-- "ExplodeFX" : "",
			-- "TemplateAfterDestruction" : "",
			-- "Type" : "DestroyParameters",
			-- "VisualDestruction" : "a54896bf-526a-4790-9fde-77edb3c83fd3"
		-- }
	-- ],
	-- "Opacity" : 0.5,
	-- "PhysicsTemplate" : "31fd1148-ac0c-4418-8e63-8e7fa2ed946a",
	-- "PickingPhysicsTemplates" : 
	-- {
		-- "CharacterDeadPicking" : "",
		-- "CharacterLyingPicking" : "",
		-- "CharacterSittingPicking" : ""
	-- },
	-- "RagdollTemplate" : "",
	-- "ReceiveDecal" : true,
	-- "RenderChannel" : 4,
	-- "RootTemplate" : "",
	-- "RunSpeed" : 3.75,
	-- "SeeThrough" : false,
	-- "SkillList" : [],
	-- "SkillSet" : "Summon_Bomber",
	-- "SoftBodyCollisionTemplate" : "",
	-- "SoundAttachBone" : "",
	-- "SoundAttenuation" : -1,
	-- "SoundInitEvent" : "",
	-- "SpeakerGroup" : "00efc7b5-aa56-44d2-82f2-eff30e451e1e",
	-- "SpotSneakers" : true,
	-- "Stats" : "Summon_Bomber",
	-- "Tags" : 
	-- [
		-- "SUMMON",
		-- "CONSTRUCT",
		-- "WINDUPTOY",
		-- "INCARNATE_S"
	-- ],
	-- "TradeTreasures" : [],
	-- "Transform" : 
	-- {
		-- "Matrix" : 
		-- [
			-- 1.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 1.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 1.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 1.0
		-- ],
		-- "Rotate" : 
		-- [
			-- 1.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 1.0,
			-- 0.0,
			-- 0.0,
			-- 0.0,
			-- 1.0
		-- ],
		-- "Scale" : 
		-- [
			-- 1.0,
			-- 1.0,
			-- 1.0
		-- ],
		-- "Translate" : 
		-- [
			-- 0.0,
			-- 0.0,
			-- 0.0
		-- ]
	-- },
	-- "Treasures" : 
	-- [
		-- "Empty"
	-- ],
	-- "TrophyID" : "",
	-- "Type" : 0,
	-- "VisualSet" : 
	-- {
		-- "Colors" : 
		-- [
			-- [],
			-- [],
			-- []
		-- ],
		-- "Visuals" : 
		-- [
			-- [],
			-- [],
			-- [],
			-- [],
			-- [],
			-- [],
			-- [],
			-- [],
			-- []
		-- ]
	-- },
	-- "VisualSetIndices" : 
	-- {
		-- "GetColor" : "function: 00007FFED3760230",
		-- "GetVisual" : "function: 00007FFED3760260",
		-- "SetColor" : "function: 00007FFED3760290",
		-- "SetVisual" : "function: 00007FFED37602C0"
	-- },
	-- "VisualSetResourceID" : "",
	-- "VisualTemplate" : "739cf2a0-0694-4ab4-b180-1ba1d0451f60",
	-- "WalkSpeed" : 2.0,
	-- "WalkThrough" : false
-- }




