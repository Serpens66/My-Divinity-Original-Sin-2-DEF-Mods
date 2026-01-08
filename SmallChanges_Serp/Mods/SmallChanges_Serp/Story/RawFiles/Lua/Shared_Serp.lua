-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md and the changelogs for v56 onwards, because they are not included in docu

-- Version in meta.lsx:
-- Major +268.435.456
-- Minor +16.777.216
-- Revision +65536
-- Build +1
-- 1.0.0.0 -> 268.435.456
-- 1.1.0.0 -> 285.212.672
-- 1.2.0.0	-> 301.989.888	
-- 1.3.0.0	-> 318.767.104
-- 1.0.1.0 -> 268500992
-- 1.0.3.0 -> 268632064

-- dump a table: _D(table)

-- TODO:
-- evlt. nochmal giftbag CMP_SummoningImproved_Kamil durchgucken ob ein paar skills davon zufügen zu anysummon mod



SharedFns = {}

-- Immortal_Segeant_Redux and Gwydian
SharedFns.MakeImmortalcharGUIDs = {"S_GLO_LV_HenchmenRecruiter_ed64ea06-9060-4b29-88dd-623ab008fae6",
  "S_GLO_LV_HenchmenRecruiter_ed64ea06-9060-4b29-88dd-623ab008fae6",
  "CHARACTERGUID_S_RC_OIL_InnerField_Sourcerer_632e47f2-22c3-4342-b3f7-152dd3534f3b",
  "CHARACTERGUID_S_RC_OIL_InnerField_Sourcerer_632e47f2-22c3-4342-b3f7-152dd3534f3b",
}

-- Ext.Print("Shared Script Started Serp66 Mod Collection")



-- TODO:
-- gucken ob der hier antwortet wie man eingige der ungenutzten Talente ins UI bekommt um sie selbst wählen zu können:
-- https://discord.com/channels/98922182746329088/991371940201766932/1441427242852024534
-- TODO: obwohl Divine Talents code auto-aktiviert wird, sind die Talente nicht in Talentliste sichtbar... also diese dann auch sichtbar machen



-- ##########################################################
-- ##################  helpers  #############################
-- ##########################################################
-- 

-- choices = {choice1={weight=10},choice2={weight=20}} --> choice2 as double chance to be chosen.
-- the same choice can be chosen multiple times
SharedFns.weighted_random_choices = function(choices, num_choices)
  local function weighted_total(choices)
    local total = 0
    for choice, v in pairs(choices) do
      total = total + v.weight
    end
    return total
  end
  local picks = {}
  for i = 1, num_choices do
    local pick
    local threshold = Ext.Random() * weighted_total(choices)
    for choice, v in pairs(choices) do
      threshold = threshold - v.weight
      pick = choice
      if threshold <= 0 then
        break
      end
    end
    table.insert(picks, pick)
  end
  return picks
end
-- choices = {"a","b","c"}
SharedFns.random_choice = function(choices)
  return choices[Ext.Random(#choices)]
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
SharedFns.table_removetablevalue = function(t, lookup_value, removeall)
  for k, v in pairs(t) do
    if v == lookup_value then
      t[k] = nil
      if not removeall then
        break
      end
    end
  end
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

function SharedFns.RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.Osiris.RegisterListener(event, arity, state, function(...)
		if Ext.Server.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError("ERROR: ",err)
			end
		end
	end)
end

-- important when comparing charGUID or using as key. all game/extender functions can handel both
local function UnifycharGuid(charGUID)
  local char = Ext.Entity.GetCharacter(charGUID)
  return char and char.MyGuid or charGUID,char -- looks slightly different..: Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd vs c451954c-73bf-46ce-a1d1-caa9bbdc3cfd
end

---Returns the currently-controlled character on the client.  
---@param playerIndex integer? Defaults to 1.
---@return EclCharacter
local function Client_GetCharacter(playerIndex)
  playerIndex = playerIndex or 1
  local playerManager = Ext.Entity.GetPlayerManager()
  local char = Ext.Entity.GetCharacter(playerManager.ClientPlayerData[playerIndex].CharacterNetId) ---@type EclCharacter
  return char
end

local SkillbookTemplates = Mods and Mods.EpipEncounters and Mods.EpipEncounters.Epip and Mods.EpipEncounters.Epip.GetFeature("SkillbookTemplates")
SharedFns.GetSkillbooksForSkill = function(skill)
  local skillbooks = {} -- most of the time 1 but could be more than 1
  if SkillbookTemplates then -- requires Epip installed
    local skillbook_templates = SkillbookTemplates and SkillbookTemplates.GetForSkill(skill) or nil
    for _,template in ipairs(skillbook_templates) do
      local root = Ext.Template.GetTemplate(template)
      if root and root.Stats then
        table.insert(skillbooks,root.Stats)
      end
    end
  end
  return skillbooks
end


-- ##################################################################
-- ##################################################################
-- ##################################################################


-- eg. heal enemies when starting combat when they are below 55% health because of mods changing their HP
SharedFns.DoHeal = function(charGUID,healPlayer,healOthers,ifbelowhealthpercent,healtopercent,char)
  ifbelowhealthpercent = ifbelowhealthpercent or 100
  healtopercent = healtopercent or 100
  char = char or Ext.Entity.GetCharacter(charGUID)
  if char~=nil and not char.Dead and Osi.CharacterGetHitpointsPercentage(charGUID)<ifbelowhealthpercent and ((healPlayer and char.IsPlayer) or (healOthers and not char.IsPlayer)) then 
    Osi.CharacterSetHitpointsPercentage(charGUID,healtopercent) -- (CHARACTERGUID)_Character, (INTEGER)_Percentage
  end
end

-- lua can fetch and add/delete information from database (DB), but can not create new entries.
-- So one still needs an osiris script to init new DB tables (eg. DB_CheckedPawn from MobilityRedux)
-- Alternativ Tags (Osiris) nutzen, aber diese sind langsam, also nur selten nutzen
-- SetTag 	(GUIDSTRING)_Source, (STRING)_Tag
-- IsTagged 	[in](GUIDSTRING)_Target, [in](STRING)_Tag, [out](INTEGER)_Bool
-- ClearTag 	(GUIDSTRING)_Source, (STRING)_Tag
-- TODO sicherstellen, dass Talentpoint nicht mehrfach geaddet wird
SharedFns.AddTalent = function(charGUID,Talent,compensateTalentPoint,Tag,char)
  local BuggedTalents = {"Throwing", "WandCharge","BeastMaster","PainDrinker","DeathfogResistant","Sourcerer","Rag"} -- talents which dont work properly with CharacterAddTalent (noticeable that they have no effect, not displayed and also not removeable). But as Boost they seem to work (at least tested with BeastMaster): only the first 3 are added at all, while most likely only BeastMaster works.
  if Talent and Talent~="None" then
    char = char or Ext.Entity.GetCharacter(charGUID)
    Ext.Print("Trying add Talent "..tostring(Talent).." to "..tostring(charGUID))
    if not Tag or Osi.IsTagged(charGUID,Tag)==0 then
      if (char and not char.Stats["TALENT_"..Talent]) or (not char and Osi.CharacterHasTalent(charGUID, Talent) == 0) then
        if char.PlayerCustomData==nil or SharedFns.table_contains_value(BuggedTalents,Talent) then -- NPC
          Osi.NRD_CharacterSetPermanentBoostTalent(charGUID,Talent,1)--(CHARACTERGUID)_Character, (STRING)_Talent, (INTEGER)_HasTalent (_HasTalent=0 heißt entfernen und =1 heißt zufügen) -- der char TALENT_ check kann dies auch finden, der CharacterHasTalent nicht
          Osi.CharacterAddAttribute(charGUID, "Dummy", 0) -- to sync to clients
        elseif char.PlayerCustomData then
          Osi.CharacterAddTalent(charGUID, Talent)
        end
        Ext.Print("Talent "..tostring(Talent).." was added to "..tostring(charGUID))
      elseif compensateTalentPoint then
        Osi.CharacterAddTalentPoint(charGUID, 1)
        Ext.Print(tostring(charGUID).." already had Talent "..tostring(Talent)..". Got Talentpoints instead")
      end
      if Tag then
        Osi.SetTag(charGUID,Tag)
      end
    end
  end
end

-- MyStat is the return of eg. Ext.Stat.GetRaw("_Hero")
SharedFns.HasAnyAbility = function(char,abilities,MyStat)
  if MyStat then
    for _,ability in ipairs(abilities) do
      if MyStat[ability]>0 then
        return true
      end
    end
  elseif char then
    for _,ability in ipairs(abilities) do
      if char.Stats[ability]>0 then
        return true
      end
    end
  end
  return false
end

-- only character main chars (current Party) (not sure yet if controllable has any effect or if currently in party)
-- returned nicht dasselbe wie Osi.CharacterIsPlayer (denn das nimmt zb auch incarnation mit auf)
SharedFns.GetAllPlayerChars = function()
  local _players = Osi.DB_IsPlayer:Get(nil) -- Will return a list of tuples of all player characters
  local players = {}
  for _,tupl in ipairs(_players) do
    local _charGUID = tupl[1]
    local charGUID,char = UnifycharGuid(_charGUID)
    table.insert(players,charGUID)
  end
  return players
end
SharedFns.GetAnyPlayerControlled = function()
  return Osi.DB_IsPlayer:Get(nil)[1][1]
end

SharedFns.IsPlayerEnemy = function(charGUID,playercharGUID)
  if charGUID then
    playercharGUID = playercharGUID or SharedFns.GetAnyPlayerControlled()
    if Osi.CharacterIsEnemy(playercharGUID,charGUID)==1 then -- [in](CHARACTERGUID)_Character, [in](CHARACTERGUID)_OtherCharacter, [out](INTEGER)_Bool 
      return true
    else
      return false
    end
  end
  return nil
end
-- you are also ally to yourself, so fine if both GUID are the same
SharedFns.IsPlayerAlly = function(charGUID,playercharGUID)
  if charGUID then
    playercharGUID = playercharGUID or SharedFns.GetAnyPlayerControlled()
    if Osi.CharacterIsAlly(playercharGUID,charGUID)==1 then -- [in](CHARACTERGUID)_Character, [in](CHARACTERGUID)_OtherCharacter, [out](INTEGER)_Bool 
      return true
    else
      return false
    end
  end
  return nil
end
-- IsPlayer and CharacterIsPlayer return true for the incarnation summon
-- Don't know yet how player character which are temporary controlled by AI (eg. via mods) will evaluate with this?
-- And TODO: aktuell kein Weg um bei Totem rauszufinden obs ein eigenes oder ein ally ist
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_2f9631e5-0a10-4376-87cc-dffef203f44e").Summon) -- false...
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_2f9631e5-0a10-4376-87cc-dffef203f44e").IsPet) -- false...
-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").HasOwner) -- false
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_2f9631e5-0a10-4376-87cc-dffef203f44e").HasOwner) -- true
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_64018dfd-fd90-4004-bb6e-9ea3de017c50").HasOwner) -- true
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_2f9631e5-0a10-4376-87cc-dffef203f44e").InParty) -- true
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_64018dfd-fd90-4004-bb6e-9ea3de017c50").InParty) -- false
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_2f9631e5-0a10-4376-87cc-dffef203f44e").IsPlayer) -- true
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_64018dfd-fd90-4004-bb6e-9ea3de017c50").IsPlayer) -- false
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_64018dfd-fd90-4004-bb6e-9ea3de017c50").PartyFollower) -- false
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_c9eac4b1-9391-4f12-b871-49db5c50239f").PartyFollower) -- false
-- char.CharacterControl returned im Kampf true für den, der gerade dran ist.
-- return char.IsPlayer and char.InParty and not char.HasOwner and not char.Summon and not char.PartyFollower and not char.Totem and not char.IsPet
SharedFns.IsPlayerMainChar = function(charGUID)
  local players = SharedFns.GetAllPlayerChars()
  return SharedFns.table_contains_value(players,charGUID)
end
-- Main char or summon/totem/Follower from char
-- not possible to differentiate between own and allied totem
-- SharedFns.IsCharFromPlayer = function(charGUID,char)
  -- char = char or Ext.Entity.GetCharacter(charGUID)
  -- if SharedFns.IsPlayerAlly(charGUID) then
    -- return SharedFns.IsPlayerMainChar(charGUID) -- or .. nur weil allied und Totem, ists ja nicht das eigene...
  -- end
  -- return false
-- end
-- TODO: keine ahnung ob sicher so... Totem gilt dadurch wohl auch als NPC
SharedFns.IsNPCChar = function(charGUID,char)
  char = char or Ext.Entity.GetCharacter(charGUID)
  return not char.PlayerCustomData and not char.IsPlayer
end

SharedFns.IsAnySummonSkill = function(skill,MyStat)
  if MyStat.SkillType=="Summon" then
    return true
  end
  if MyStat.SpawnObject~="" and MyStat.SpawnLifetime>0 and MyStat.ProjectileType~="Grenade" then
    return true
  end
  local SkillProperties = MyStat.SkillProperties
  if SkillProperties and type(SkillProperties)=="table" then
    for _,entry in pairs(SkillProperties) do
      if entry.Type=="Summon" then
        return true
      end
    end
  end
  return false
end
-- for _,entry in pairs(Ext.Stats.Get("Target_BloatedCorpse").SkillProperties) do for k,v in pairs(entry) do print(k,v) end end


SharedFns.GetExtType = function(obj)
  local objType
  if type(obj) == "userdata" then
    objType = getmetatable(obj)
  end
  return objType
end

-- ##################################################################
-- ###################   Events   ###################################
-- ##################################################################


-- Random CRASH (extender v60) and may break sills: Do NOT call Ext.Stats.Sync while looping over Ext.Stats.GetStats("SkillData") (or most likely an other Ext.Stats.GetStats(...)). Instead save the names of the entries you changed while looping and then do a seperate loop after the GetStats loop to call Sync for these
-- Solution: Sync is not needed within StatsLoaded
SharedFns.OnStatsLoaded = function(e)
  Ext.Print("OnStatsLoadedSerpSmallChanges_Serp Start")
      
  -- (changing _Hero directly does not work, because it is used for inheritance, which is already done on statsloaded)
  -- Half movement for Player characters (affects all player controlled units, so also summons)
  -- Movement Wert für StoryPlayer usw kommt anscheinend on top auf _Base, ist also ein Bonus für die Schwierigkeit. also einfach alle werte halbieren (vanilla sind die Player werte 0)

  
  -- DivineTalentsGiftpackMod (do a bit more than in BalancedIndomitableForAll Mod)
  Stats_Indomitable_Flags = Ext.Stats.GetRaw("Stats_Indomitable")["Flags"]
  for _,flag in ipairs({"ChickenImmunity","CrippledImmunity","FearImmunity","FreezeImmunity","KnockdownImmunity","PetrifiedImmunity","StunImmunity","MadnessImmunity","CharmImmunity"}) do
    if not SharedFns.table_contains_value(Stats_Indomitable_Flags,flag) then
      table.insert(Stats_Indomitable_Flags,flag)
    end
  end
  Ext.Stats.GetRaw("Stats_Indomitable")["Flags"] = Stats_Indomitable_Flags
  Ext.Stats.GetRaw("MADNESS")["ImmuneFlag"] = "MadnessImmunity" 
  
  
  -- ImprovedDoorOfEternity
  Ext.Stats.GetRaw("Shout_CloseTheDoor")["ActionPoints"] = 2
  local MyStat = Ext.Stats.Get("Shout_CloseTheDoor")
  MyStat["TargetConditions"] = "Ally&Summon&!Spirit" -- MySummon&!Spirit -- GetRaw does not work for TargetConditions
  local SkillProperties = MyStat["SkillProperties"] -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
  if SkillProperties and type(SkillProperties)=="table" then
    for _,entry in pairs(SkillProperties) do
      if entry.Action=="ETERNITY_DOOR" then
        entry.Duration = 5*6 -- from 3 to 5 rounds
        break
      end
    end
    Ext.Stats.Get("Shout_CloseTheDoor")["SkillProperties"] = SkillProperties
  end
  
  -- infinite Shout_SpiritVision
  local SkillProperties = Ext.Stats.Get("Shout_SpiritVision")["SkillProperties"]
  if SkillProperties and type(SkillProperties)=="table" then
    for _,entry in pairs(SkillProperties) do
      if entry.Action=="SPIRIT_VISION" then
        entry.Duration = -1
        break
      end
    end
    Ext.Stats.Get("Shout_SpiritVision")["SkillProperties"] = SkillProperties
  end
  
  -- ViableGateway
  Ext.Stats.GetRaw("UNI_PlanarGateway")["UseAPCost"] = 1
  local MyStat = Ext.Stats.GetRaw("Summon_PlanarGateway")
  MyStat["ActionPoints"] = 3
  MyStat["Cooldown"] = 10
  MyStat["Lifetime"] = 4
  MyStat["Memory Cost"] = 1
  MyStat["Magic Cost"] = 0
  MyStat["TeleportsUseCount"] = 10
  MyStat["Tier"] = "Novice"
  
  -- infinite InnateBlessBalanced
  local MyStat = Ext.Stats.GetRaw("Target_Bless")
  MyStat["ActionPoints"] = 2
  MyStat["Cooldown"] = 5
  MyStat["Memory Cost"] = 0
  MyStat["Magic Cost"] = 0
  local MyStat = Ext.Stats.GetRaw("Target_Curse")
  MyStat["ActionPoints"] = 2
  MyStat["Cooldown"] = 5
  MyStat["Memory Cost"] = 0
  MyStat["Magic Cost"] = 0
  
  -- Sneak 2AP
  Ext.ExtraData["SneakDefaultAPCost"] = 2
  
  -- from 4 to 10
  Ext.ExtraData["MaximumSummonsInCombat"] = 10
  
  -- MiniMemoryBuff from 3 to 5
  Ext.ExtraData["CharacterBaseMemoryCapacity"] = 5
  
  -- less powerful lifesteal through necromacy from 10 to 7
  Ext.ExtraData["SkillAbilityLifeStealPerPoint"] = 7
  
  -- from 8. 
  Ext.ExtraData["LeadershipRange"] = 12
  -- TODO: evlt noch gucken ob wir demjenigen mit leadership den boost auch geben.. geht nur mit externen buff den wir selbst managen..
  -- gibt leider 0: Osi.ApplyStatus("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","LEADERSHIP",-1,1,"Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd")


  -- Taunt_Range_Increased
  Ext.Stats.GetRaw("Shout_Taunt")["AreaRadius"] = 8
  Ext.Stats.GetRaw("Shout_WolfTaunt")["AreaRadius"] = 8
  Ext.Stats.GetRaw("Shout_EnemyTaunt")["AreaRadius"] = 8
  Ext.Stats.GetRaw("Shout_IncarnateTaunt")["AreaRadius"] = 8
  
  
  
  
  -- Controls are Back! StunnableMobs: reduce armor, but higher HP to not punish too much for doing differnent damage types
  local MyStat = Ext.Stats.GetRaw("CasualNPC")
  MyStat["ArmorBoost"] = -50
  MyStat["MagicArmorBoost"] = -50
  MyStat["Vitality"] = -15
  MyStat["MovementSpeedBoost"] = 25
  local MyStat = Ext.Stats.GetRaw("NormalNPC")
  MyStat["ArmorBoost"] = -25
  MyStat["MagicArmorBoost"] = -25
  MyStat["Vitality"] = 33
  MyStat["MovementSpeedBoost"] = 25
  local MyStat = Ext.Stats.GetRaw("HardcoreNPC")
  MyStat["ArmorBoost"] = 0
  MyStat["MagicArmorBoost"] = 0
  MyStat["Vitality"] = 100
  MyStat["MovementSpeedBoost"] = 25
  
  -- based on idea: Make Grenades Great again GrenadesImproved, nur die grenade buffs, nicht die 2 neuen grenades
  -- not 1:1 the same changes, but on rough rules to automate it
  -- local grenades = {"Projectile_Grenade_Nailbomb","Projectile_Grenade_Molotov","Projectile_Grenade_CursedMolotov","Projectile_Grenade_ChemicalWarfare","Projectile_Grenade_Ice","Projectile_Grenade_BlessedIce","Projectile_Grenade_Holy","Projectile_Grenade_Taser","Projectile_Grenade_Tremor","Projectile_Grenade_SmokeBomb","Projectile_Grenade_WaterBlessedBalloon","Projectile_Grenade_PoisonFlask","Projectile_Grenade_CursedPoisonFlask","Projectile_Grenade_Love","Projectile_Grenade_ArmorPiercing","ProjectileStrike_Grenade_ClusterBomb","ProjectileStrike_Grenade_CursedClusterBomb"}
  -- for _,grenade in ipairs(grenades) do
  for i,skill in pairs(Ext.Stats.GetStats("SkillData")) do
    local MyRawStat = Ext.Stats.GetRaw(skill)
    local MyStat = Ext.Stats.Get(skill)
    if MyRawStat.ProjectileType=="Grenade" then
      MyRawStat.Ability = "Ranger" -- make it scale with finesse
      local DamageMultiplier = MyStat["Damage Multiplier"]
      local DamageRange = MyStat["Damage Range"]
      if DamageMultiplier and DamageMultiplier>0 then
        MyRawStat.ActionPoints = 2 -- 1 more expensive, since they are stronger now
        MyRawStat["Damage Multiplier"] = DamageMultiplier and DamageMultiplier * 0.8 or 0
        MyRawStat["Damage Range"] = DamageRange and DamageRange * 3 or 0
      end
    -- make every summoning skill require at least Summoning 1
    elseif SharedFns.IsAnySummonSkill(skill,MyStat) and not skill:find("Enemy",1,true) then
      local Requirements = MyStat.MemorizationRequirements
      local summonreq = false
      local anyreq = nil
      for i,Requirement in ipairs(Requirements) do
        anyreq = Requirement
        if Requirement.Requirement=="Summoning" then
          summonreq = true
        end
      end
      if not summonreq and anyreq then
        local newreq = deepcopy(anyreq)
        newreq.Requirement = "Summoning"
        newreq.Param = 1
        table.insert(Requirements,newreq)
      end
      MyStat.MemorizationRequirements = Requirements
      local skillbooks = SharedFns.GetSkillbooksForSkill(skill)
      for _,skillbook in ipairs(skillbooks) do
        local skillbookstat = Ext.Stats.Get(skillbook) -- not using Raw, so it is a table we can easily add stuff to
        if skillbookstat then
          local reqabilitiesbook = skillbookstat.Requirements
          local anyreq = nil
          local summonreq = false
          for i,Requirement in ipairs(reqabilitiesbook) do
            anyreq = Requirement
            if Requirement.Requirement=="Summoning" then
              summonreq = true
            end
          end
          if not summonreq and anyreq then
            local newreq = deepcopy(anyreq)
            newreq.Requirement = "Summoning"
            newreq.Param = 1
            table.insert(reqabilitiesbook,newreq)
          end
          skillbookstat.Requirements = reqabilitiesbook
        end
      end
    end
  end
  -- reduce weight of grenades
  for i,obj in pairs(Ext.Stats.GetStats("Object")) do
    if obj:find("Grenade",1,true) then
      local MyStat = Ext.Stats.GetRaw(obj)
      MyStat.Weight = MyStat.Weight / 2 -- half weight
    end
  end
  
  -- SkillsScaleWithWeaponStat -- also means with a lvl 1 weapon you also do at lvl 20 nearly no damage with spells..
   -- and with strong weapon spells do much more damage than without weapon scaling..
  -- for i,skill in pairs(Ext.Stats.GetStats("SkillData")) do
    -- Ext.Stats.GetRaw(skill).UseWeaponDamage = "Yes"
    -- Ext.Stats.GetRaw(skill).UseCharacterStats = "Yes"
    ------------ Ext.Stats.GetRaw(skill).UseWeaponProperties = "Yes"
  -- end
  
  -- NoPsychicEnemies (reduce Loremaster for enemies)
  for i,char in pairs(Ext.Stats.GetStats("Character")) do
    local MyStat = Ext.Stats.GetRaw(char)
    local Loremaster = MyStat.Loremaster
    if Loremaster and Loremaster>0 then
      local Repair = MyStat.Repair
      if not Repair or Repair==0 then -- the ones who can Repair are usually merchants which should be able to identify your items, so not change Loremaster for them
        MyStat.Loremaster = math.max(Loremaster-2,0)
      end
    end
  end
  
  -- Make Spears scale with Strength instead Finesse
  for i,obj in pairs(Ext.Stats.GetStats("Weapon")) do
    local MyStat = Ext.Stats.Get(obj)
    if MyStat.ItemGroup:find("Spear",1,true) then
      local Requirements = MyStat.Requirements
      for i,Requirement in ipairs(Requirements) do
        if Requirement.Requirement=="Finesse" then
          Requirement.Requirement = "Strength"
        end
      end
      MyStat.Requirements = Requirements
    end
  end
  
  
  -- make giftbag containers dropable
  -- coutcommented, because they really loose their function this way ?!
   -- workaround: Epip multi select: this way can be moved to other char and also marked as Ware. and Ware can be sold
  -- local giftbagtemplates = {"7fee91ba-fa82-4928-8bab-886a0d84ad0e","f5874b2d-ee95-45af-bd87-f37fc6803ef8","39715850-1093-423c-b116-91d5df2df8e5","b5fa4223-7951-4800-a943-4f9f40147615","099c3bb5-c32a-4b83-9d45-dae44387ce5f","b17d8d2a-14cc-48b0-b477-5e53d7abd2eb","2060995e-255e-48cb-b292-095eb871e2fc","47838f1d-479b-4c5d-84f2-fee6eff4dc38","d23d4797-6d6c-4793-b5c3-e6ed000a64b7","5675f53c-b2d7-4ce7-b6b4-967f62573937","612bc443-f654-4116-9419-d298ae2f9bcf","cdef1bc4-df4e-4d51-af18-f0094cab6e43","7a200322-3802-4f62-b3ff-48cd426be43a","40553018-7036-4bb6-9905-7058dcaf0a41","30a59c9f-873f-4137-a2ea-6154e12645aa","93b6ae3d-5733-4a38-bb48-80e913f2f21c","001c7951-f98b-4739-adae-1a66ca9bf838","1278faf7-5a91-499b-a2c6-6c1922243690","490e500a-ba71-45b2-a602-cf46e71e42ac","e676d5f0-8aa2-4a1e-934b-48626bfb9773","c7804224-080e-46d0-bab4-03fbfd0f9e8e","69d2ec50-1e00-44d6-8dad-8c360c122060","d9da5d77-6833-4338-ad70-a2a2e28e550e"}
  -- for _,templateid in ipairs(giftbagtemplates) do
    -- local template = Ext.Template.GetTemplate(templateid)
    -- if template then
      -- template.IsPinnedContainer = false
    -- end
  -- end
  
  -- make food last longer (vanilla 3 turns)
  for i,obj in pairs(Ext.Stats.GetStats("Potion")) do
    local MyStat = Ext.Stats.Get(obj)
    if MyStat then
      if MyStat.ObjectCategory=="Food" then
        MyStat.Duration = MyStat.Duration * 3
      end
    end
  end
 
  
  Ext.Print("OnStatsLoadedSerpSmallChanges_Serp Ende")
  
end



-- Give BeastMaster talent to ever player with Summoning>=3
SharedFns.ChangeBeastMaster = function(charGUID,summoninglevel)
  summoninglevel = summoninglevel or Osi.CharacterGetAbility(charGUID,"Summoning")
  if summoninglevel>=3 then
    SharedFns.AddTalent(charGUID,"BeastMaster",false,"BeastMaster_Serp") -- 1 extra summon
  else
    if Osi.CharacterHasTalent(charGUID,"BeastMaster")==1 then
      Osi.CharacterRemoveTalent(charGUID,"BeastMaster")
      Osi.ClearTag(charGUID,"BeastMaster_Serp")
    end
  end
end

-- #############
-- Server

SharedFns.OnSaveLoaded = function(major, minor, patch, build)
  local players = SharedFns.GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    
    Ext.Print("OnSaveLoaded",charGUID)
    SharedFns.AddTalent(charGUID,"InventoryAccess",false,"InventoryAccess_Serp") -- cheaper changing equipment during fight
    Osi.RemoveStatus(charGUID,"MOVEMENTSPEED_REDUCE_SERP") -- remove it, no longer needed
    if Osi.CharacterHasSkill(charGUID,"Target_LLDUMMY_TrainingDummy")==0 then
      Osi.CharacterAddSkill(charGUID,"Target_LLDUMMY_TrainingDummy")
    end
    SharedFns.ChangeBeastMaster(charGUID)
    Osi.NRD_CharacterDisableTalent(charGUID,"Indomitable", 1) -- disable vanilla Indomitable, we will use our balanced mod
    
    if Osi.CharacterHasSkill(charGUID,"Target_Bless")==1 then
      if Osi.CharacterHasSkill(charGUID,"Target_Curse")==0 then
        Osi.CharacterAddSkill(charGUID,"Target_Curse")
      end
    elseif Osi.CharacterHasSkill(charGUID,"Target_Curse")==1 then
      if Osi.CharacterHasSkill(charGUID,"Target_Bless")==0 then
        Osi.CharacterAddSkill(charGUID,"Target_Bless")
      end
    end
    
  end
  
  -- Immortal_Segeant_Redux and Gwydian
  for _,charGUID in ipairs(SharedFns.MakeImmortalcharGUIDs) do
    Osi.CharacterSetImmortal(charGUID,1)
  end
  
end
-- Osi.CharacterHasSkill("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Target_LLDUMMY_TrainingDummy")
-- Osi.CharacterAddSkill("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Target_LLDUMMY_TrainingDummy")



-- already made sure it only forwards units, not items
SharedFns.OnUnitCombatEntered = function(_charGUID,combatID)
  local charGUID,char = UnifycharGuid(_charGUID)
  Ext.Print("SmallChanges_Serp: OnUnitCombatEntered ",charGUID,_charGUID)
  
  -- Full Heal of NPCS
  SharedFns.DoHeal(charGUID,false,true,55,100,char)
  
  -- Immortal_Segeant_Redux and Gwydian
  if SharedFns.table_contains_value(SharedFns.MakeImmortalcharGUIDs,charGUID) then
    if SharedFns.IsPlayerEnemy(charGUID) then
      Osi.CharacterSetImmortal(charGUID,0)
    elseif SharedFns.IsPlayerAlly(charGUID) then
      Osi.CharacterSetImmortal(charGUID,1)
    end
  end
  
end

SharedFns.OnCharacterResurrected = function(_charGUID)
  -- local charGUID,char = UnifycharGuid(_charGUID)
end
-- also called for summons!
SharedFns.OnCharacterJoinedParty = function(_charGUID)
  local charGUID,char = UnifycharGuid(_charGUID)
  Ext.Print("CharacterJoinedParty",charGUID)
  if SharedFns.IsPlayerMainChar(charGUID) then
    SharedFns.AddTalent(charGUID,"InventoryAccess",false,"InventoryAccess_Serp") -- cheaper changing equipment during fight
    
  end
end
-- Ext.Stats.EnumLabelToIndex("AbilityType","RangerLore")
-- Ext.Stats.EnumIndexToLabel("AbilityType",2)
-- (CHARACTERGUID)_Character, (STRING)_Ability, (INTEGER)_OldBaseValue, (INTEGER)_NewBaseValue)
-- Is not called for changes by equipment
SharedFns.OnCharacterBaseAbilityChanged = function(_charGUID,ability,old,new)
  local charGUID,char = UnifycharGuid(_charGUID)
  Ext.Print("OnCharacterBaseAbilityChanged",charGUID,ability,old,new)
  -- local ability = Ext.Stats.EnumIndexToLabel("AbilityType",ability) # ist schon string
  if ability=="Summoning" then
    SharedFns.ChangeBeastMaster(charGUID,new)
  end
end

SharedFns.OnCharacterLeftParty = function(_charGUID)
  -- local charGUID,char = UnifycharGuid(_charGUID)
end

SharedFns.OnCharacterLeveledUp = function(_charGUID)
  -- local charGUID,char = UnifycharGuid(_charGUID)
end

-- Learn Bless and Curse
SharedFns.OnCharacterLearnedSkill = function(_charGUID,skill)
  local charGUID,char = UnifycharGuid(_charGUID)
  if skill=="Target_Bless" then
    if Osi.CharacterHasSkill(charGUID,"Target_Curse")==0 then
      Osi.CharacterAddSkill(charGUID,"Target_Curse")
    end
  elseif skill=="Target_Curse" then
    if Osi.CharacterHasSkill(charGUID,"Target_Bless")==0 then
      Osi.CharacterAddSkill(charGUID,"Target_Bless")
    end
  end
end


-- ################################
 -- DivineTalentsGiftpackMod (do a bit more than in BalancedIndomitableForAll Mod)
-- Give everyone a nerfed (better balanced) version Indomitable status:
-- Give the Status AFTER the CC-status wered off for 3 turns and then you are immune to CC for these 3 turns.
-- Revert overrides in Skill_Projectile of Projectile_DimensionalBolt (were no changes compared to vanilla, so unneeded overwrite) 
-- CMP_Talents_override is mostly the same, but added CHARM and MADNESS and increased the CD from 2 to 3 rounds (the time where you are vulnerable to CC)

local giftBagTextFiles = {
    ["Mods/CMP_DivineTalents_Kamil/Story/RawFiles/Goals/CMP_Talents.txt"] = "Mods/SmallChanges_Serp/Story/RawFiles/Goals/CMP_Talents_override.txt",
    ["Public/CMP_DivineTalents_Kamil/Stats/Generated/Data/Skill_Projectile.txt"] = "Public/SmallChanges_Serp/Stats/Generated/Data/Skill_Projectile.txt",
}

for file,override in pairs(giftBagTextFiles) do
    Ext.IO.AddPathOverride(file, override)
end



SharedFns.OnObjectTurnStarted = function(_charGUID)
  -- local charGUID,char = UnifycharGuid(_charGUID)
end
-- Also called for standing in surface, cause ist verursacher charGUID und bei surface der dem das surface gehört, bzw. der es erzeugt hat. 
-- In surface hin und her gehen triggert es nicht erneut (wie der surface schaden), triggert auch nur einmal pro sekunde oderso, dh. wenn surface schnell gewechselt wird, triggert es für eins davon garnicht, aber wir nehmen auch OnObjectTurnStarted dazu, dann passt das
SharedFns.OnCharacterStatusApplied = function(_charGUID, status, cause)
  -- local charGUID,char = UnifycharGuid(_charGUID)
end
SharedFns.OnCharacterStatusRemoved = function(_charGUID, status, nilSource)
  local charGUID,char = UnifycharGuid(_charGUID)
  if status=="CHARMED" or status=="CHICKEN" then -- trigger Perseverance for more stati
    Osi.ApplyStatus(charGUID,"POST_MAGIC_CONTROL",0,1)
  elseif status=="SLEEPING" or status=="CRIPPLED" then
    Osi.ApplyStatus(charGUID,"POST_PHYS_CONTROL",0,1)
  end
end

-- ################################################

-- console testing

-- to make the extender show the console when starting the game: open (or create) a OsirisExtenderSettings.json in the game installation folder (where you also put the extender dll) and put into it:
-- {
  -- "CreateConsole": true
-- }
-- and save the file. Now when you start the game, the console should pop up in another window. When you loaded the savegame, open the console, hit Enter one time and copy paste this into it and hit enter:


-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").Stats.OffHandWeapon)
-- Ext.Print(Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb").Stats:GetItemBySlot("Shield").WeaponType)

-- Ext.Print(Osi.CharacterIsControlled("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd"))
-- Ext.Print(Osi.CharacterIsControlled("Summons_Ward_Wood_fa993de4-1957-4bfd-812d-4e53ac00fb54"))
-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PartyFollower)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_a5be97c8-563d-4995-a326-77fb783c0c0d").PartyFollower)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_03cb8837-5d3c-4bee-abc1-fabbf836f73e").PartyFollower)
-- Ext.Print(Ext.NRD_CharacterSetPermanentBoostTalent)

-- Osi.ApplyStatus("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","VAMPIRISM",4,1)


-- Osi.CharacterAddTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","SurpriseAttack")
-- Osi.CharacterAddTalent("Summons_Incarnate_f54a7611-b46b-4bf5-837c-31d1815ae90a","Vitality")
-- Osi.CharacterAddTalent("S_FTJ_Brute_001_94131f94-2152-49f2-8ee2-9832263eec05","Vitality")
-- Osi.CharacterAddTalent("S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f","Gladiator")
-- Osi.CharacterAddTalent("Humans_Hero_Female_7b6c1f26-fe4e-40bd-a5d0-e6ff58cef4fe","Gladiator")


-- Osi.CharacterAddTalent("S_FTJ_CourtRoomGuard_002_bb9fd6c4-4231-44ac-a24d-5955dc300147","QuickStep")
-- Osi.CharacterAddTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Indomitable")
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_002_1832a661-0e21-421f-acaa-a7e66e813b14","Indomitable",1)
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_001_08348b3a-bded-4811-92ce-f127aa4310e0","Indomitable",1)
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_AlcovePrisoner_001_11cddbdf-40b8-4ce5-8ea8-e5f1ca8ac2e0","Indomitable",1)

-- Ext.Print(Osi.CharacterAddTalent)

-- Ext.Print(Osi.NRD_CharacterSetPermanentBoostTalent)
-- Osi.NRD_CharacterSetPermanentBoostTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Zombie",0)
-- Osi.NRD_CharacterSetPermanentBoostTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Zombie",1);Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_001_08348b3a-bded-4811-92ce-f127aa4310e0","Zombie",1)
-- Osi.CharacterSetForceSynch("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",0)
-- Osi.CharacterSetForceSynch("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",1)
-- Osi.CharacterSetForceUpdate("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",1)

-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PlayerCustomData.OwnerProfileID)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_c9eac4b1-9391-4f12-b871-49db5c50239f").PlayerCustomData.OwnerProfileID)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_64018dfd-fd90-4004-bb6e-9ea3de017c50").PlayerCustomData.OwnerProfileID)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_c9eac4b1-9391-4f12-b871-49db5c50239f").PlayerCustomData.AiPersonality)
-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PlayerCustomData.AiPersonality)
-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PlayerCustomData.Name)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_c9eac4b1-9391-4f12-b871-49db5c50239f").PlayerCustomData.Name)
-- Ext.Print(Ext.Entity.GetCharacter("S_FTJ_BeachVw_002_1832a661-0e21-421f-acaa-a7e66e813b14").PlayerCustomData.Name)

-- print(Osi.GetSurfaceGroundAt("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd"))
-- print(Osi.GetSurfaceCloudAt("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd"))

-- Osi.NRD_PlayerSetBaseTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd", "AttackOfOpportunity", 1) funzt auf player charactere, aber da sieht man Talent erst bei reload der UI/des savegames. und obwohl es "Base" heißt, kann man es dennoch in resepc entfernen
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_001_08348b3a-bded-4811-92ce-f127aa4310e0", "Zombie", 1)
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_002_1832a661-0e21-421f-acaa-a7e66e813b14", "Zombie", 1)
-- Osi.NRD_CharacterDisableTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd", "QuickStep", 1) disabled (nach save+load,bzw client) und ist dann auch nicht mehr wählbar und nicht aktiv
-- local _players = Osi.DB_IsPlayer:Get(nil);for _,tupl in ipairs(_players) do local charGUID = tupl[1];Osi.SetTag(charGUID,"QuickStepForFree_Serp");end
-- local _players = Osi.DB_IsPlayer:Get(nil);for _,tupl in ipairs(_players) do local charGUID = tupl[1];Ext.Print(Osi.IsTagged(charGUID,"QuickStepForFree_Serp"));end

-- CHARACTERGUID_S_Player_Lohse_bb932b13-8ebf-4ab4-aac0-83e6924e4295
-- S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb
-- CHARACTERGUID_S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f
-- CHARACTERGUID_S_Player_Sebille_c8d55eaf-e4eb-466a-8f0d-6a9447b5b24c

-- Osi.CharacterLevelUpTo("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",20)
-- Osi.CharacterLevelUpTo("S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f",20)
-- Osi.CharacterAddAbilityPoint("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",100)
-- Osi.CharacterAddAbilityPoint("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb",100)

-- Osi.CharacterAddSkill("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Target_Custom_MaddeningSongSpell")
-- Osi.CharacterAddSkill("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb","Target_MidnightOilPlayer")

-- print(Osi.CharacterHasTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","BeastMaster"))
-- print(Osi.CharacterHasTalent("Humans_Hero_Female_7b6c1f26-fe4e-40bd-a5d0-e6ff58cef4fe","BeastMaster"))
-- print(Osi.CharacterHasTalent("S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f","BeastMaster"))
-- Osi.CharacterRemoveTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","BeastMaster")

-- Osi.CharacterAddTalent("S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f", "BeastMaster")
 -- print(Osi.CharacterHasTalent("S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f","BeastMaster"))
-- Osi.CharacterRemoveTalent("S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f","BeastMaster")

-- Osi.NRD_CharacterSetPermanentBoostTalent("S_Player_RedPrince_a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f","BeastMaster",1)
-- Osi.NRD_CharacterSetPermanentBoostTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","BeastMaster",1)

-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").Stats.TALENT_BeastMaster)

-- print(Osi.NRD_CharacterGetPermanentBoostInt("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","BeastMaster")) --[in](CHARACTERGUID)_Character, [in](STRING)_Stat, [out](INTEGER)_Value) 

-- Osi.CharacterStatusText("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb","test")

-- Osi.CharacterAddSkill("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb","Teleportation_ResurrectSkillCast")
-- Osi.CharacterAddSkill("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb","Target_NullifyResistance_")


-- local SkillbookTemplates = Mods.EpipEncounters.Epip.GetFeature("SkillbookTemplates"); Osi.ItemTemplateAddTo(SkillbookTemplates.GetForSkill("Target_MutePlayer")[1],"Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",1,1)
-- Osi.ItemTemplateAddTo("45c5bf29-71bc-482f-b371-113717fd223e","Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",1,1)


-- for k,v in pairs(Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb").SkillManager) do print(k,v) end

-- print(Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb").Stats.CurrentArmor)