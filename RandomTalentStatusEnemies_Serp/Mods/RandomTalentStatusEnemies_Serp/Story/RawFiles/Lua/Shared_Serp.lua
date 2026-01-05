-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md and the changelogs for v56 onwards, because they are not included in docu


SharedFns = {}

SharedFns.HowToAddRandomTalents = "Live" 
-- OnStats: on game load and all units sharing the same stats will have the same talents,
-- Live: on savegame load, but every unit get their own random talents TODO how to loop over everyone?!
-- OnCombat: when entering combat with the units they get their own random talents


-- https://docs.larian.game/Talent_list
-- coutcommended most Weapon requirements, since 1) in stats we see no weapon and 2) slimes or so also dont use weapons (but they also dont have any ability..)
SharedFns.num_talents = 2
local RandomTalents = {
  Ambidextrous={weight=2,reqWeaponTypes={"None"}}, -- Offhand must be free
  AttackOfOpportunity={weight=5,reqAbilities={"WarriorLore"} },--,reqWeaponTypes={"None","Knife","Sword","Axe","Club","Spear","Staff"}}, -- any melee
  ViolentMagic={weight=4,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist","Necromancy","Summoning"}},
  ResistDead={weight=1},
  QuickStep={weight=1},
  Demon={weight=2},
  IceKing={weight=2},
  NoAttackOfOpportunity={weight=3},
  ElementalAffinity={weight=3,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist"}},
  WhatARush={weight=3},
  WalkItOff={weight=2},
  ElementalRanger={weight=3,reqAbilities={"RangerLore"} },--,reqWeaponTypes={"Bow","Crossbow"}},
  Executioner={weight=4},
  FaroutDude={weight=4},
  Raistlin={weight=1}, -- glass canon
  Leech={weight=2},
  Torturer={weight=2},
  LivingArmor={weight=2},
  Perfectionist={weight=4},
  Human_Inventive={weight=2},
  Dwarf_Sturdy={weight=2},
  Lizard_Resistance={weight=2},
  -- gift bag, TODO: evtl. check obs Talent gibt? Geht das? nicht nur ob giftbag aktiv, kann ja auch via mod geaddet sein
  Sadist={weight=2,reqAbilities={"WarriorLore"} },--,reqWeaponTypes={"None","Knife","Sword","Axe","Club","Spear","Staff"}}, -- any melee
  MagicCycles={weight=3,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist"}},
  Haymaker={weight=1},
  Gladiator={weight=1},
  Soulcatcher={weight=1},
  Indomitable={weight=5},
  -- Story Talents
  Vitality ={weight= 2}, -- +20%HP
  BeastMaster ={weight=4,reqAbilities={"Summoning"}},
  Criticals={weight=2},
  IncreasedArmor={weight=3},
  Damage={weight=2},
  ResistStun={weight=2},
  ResistKnockdown={weight=2},
  ResistFear={weight=2},
  ActionPoints={weight=3},
  ActionPoints2={weight=2},
  ChanceToHitMelee={weight=2,reqAbilities={"WarriorLore"} },--,reqWeaponTypes={"None","Knife","Sword","Axe","Club","Spear","Staff"}}, -- any melee
  ChanceToHitRanged={weight=2,reqAbilities={"RangerLore"} },--,reqWeaponTypes={"Bow","Crossbow","Wand"}}, -- ranged
  Backstab={weight=2,reqAbilities={"WarriorLore"} },--,reqWeaponTypes={"None","Sword","Axe","Club","Spear","Staff"}}, -- any melee except Knife, since this allows Backstab with other weapons than knife
  RogueLoreGrenadePrecision={weight=2,reqAbilities={"RogueLore"}},
  RogueLoreMovementBonus={weight=2,reqAbilities={"RogueLore"}},
  RogueLoreHoldResistance={weight=1,reqAbilities={"RogueLore"}},
  RogueLoreDaggerBackStab={weight=2,reqAbilities={"RogueLore"} },--,reqWeaponTypes={"Knife"}},
  RogueLoreDaggerAPBonus={weight=2,reqAbilities={"RogueLore"} },--,reqWeaponTypes={"Knife"}},
  Sight={weight=2,reqAbilities={"RangerLore"} },--,reqWeaponTypes={"Bow","Crossbow","Wand"}}, -- ranged
  RangerLoreRangedAPBonus={weight=2,reqAbilities={"RangerLore"} },--,reqWeaponTypes={"Bow","Crossbow","Wand"}}, -- ranged
  RangerLoreEvasionBonus={weight=2,reqAbilities={"RangerLore"}},
  WarriorLoreNaturalResistance={weight=2,reqAbilities={"WarriorLore"}},
  WarriorLoreNaturalArmor={weight=2,reqAbilities={"WarriorLore"}},
  WarriorLoreNaturalHealth={weight=2,reqAbilities={"WarriorLore"}},
  GoldenMage={weight=2,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist","Necromancy","Summoning"}},
  Courageous={weight=1},
  StandYourGround={weight=2},
  Bully={weight=2},
  WarriorLoreGrenadeRange={weight=2,reqAbilities={"WarriorLore"}},
  Unstable={weight=1},
  EarthSpells={weight=3,reqAbilities={"EarthSpecialist"}},
  AirSpells={weight=3,reqAbilities={"AirSpecialist"}},
  WaterSpells={weight=3,reqAbilities={"WaterSpecialist"}},
  FireSpells={weight=3,reqAbilities={"FireSpecialist"}},
  None={weight=50},
}

local num_status = 1
local RandomStatus = {
  BLESSED={weight=2,maxrounds=5},
  HASTED={weight=2,maxrounds=5},
  CLEAR_MINDED={weight=2,maxrounds=5},
  ETHEREAL_SOLES={weight=2,maxrounds=5},
  RESTED={weight=2,maxrounds=5},
  IMMUNE_TO_FREEZING={weight=2,maxrounds=5},
  IMMUNE_TO_BURNING={weight=2,maxrounds=5},
  IMMUNE_TO_ELECTRIFYING={weight=2,maxrounds=5},
  IMMUNE_TO_POISONING={weight=2,maxrounds=5},
  MAGIC_SHELL={weight=2,maxrounds=5},
  FORTIFIED={weight=2,maxrounds=5},
  BLINDING_RADIANCE={weight=2,maxrounds=5},
  FIREBLOOD={weight=2,maxrounds=5},
  BlockSummon={weight=2,maxrounds=5}, -- summons can not attack this unit
  ETERNITY_DOOR={weight=2,maxrounds=2},
  EVADING={weight=2,maxrounds=2},
  DEFLECTING={weight=2,maxrounds=3},
  PHYSICAL_IMMUNITY={weight=2,maxrounds=2},
  FARSIGHT={weight=2,maxrounds=5},
  BREATHING_BUBBLE={weight=2,maxrounds=5},
  VAMPIRISM={weight=2,maxrounds=2},
  GROUNDED={weight=2,maxrounds=5},
  DOUBLE_DAMAGE={weight=2,maxrounds=2},
  ENRAGED={weight=2,maxrounds=2},
  REGENERATION={weight=2,maxrounds=5},
  FROST_AURA={weight=2,maxrounds=5},
  STEEL_SKIN={weight=2,maxrounds=5},
  PROTECTION_CIRCLE={weight=2,maxrounds=2},
  EXTRA_TURN={weight=2,maxrounds=1},
  INVISIBLE={weight=2,maxrounds=1},
  BLESSED={weight=2,maxrounds=5},
  BLESSED={weight=2,maxrounds=5},
  None={weight=15},
}

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
SharedFns.IsPlayerMainChar = function(charGUID)
  local players = SharedFns.GetAllPlayerChars()
  return SharedFns.table_contains_value(players,charGUID)
end


-- #################

-- if MyStat then we dont have a charGUID/char, but changing Stats in StatsLoaded instead
SharedFns.GetRandomTalents = function(charGUID,char,num,MyStat)
  local chosen = {}
  notstop = 0
  local StatTalents = MyStat and MyStat["Talents"] or ""
  while #chosen < num do
    notstop = notstop + 1
    Talent = SharedFns.weighted_random_choices(RandomTalents, 1)[1]
    if Talent~="None" and (not MyStat and not char.Stats["TALENT_"..Talent] or MyStat and not string.find(StatTalents,Talent)) then
      reqAbilities = RandomTalents[Talent].reqAbilities -- WarriorLore,RangerLore,FireSpecialist,WaterSpecialist,AirSpecialist,EarthSpecialist,Necromancy,Summoning
      reqWeaponTypes = RandomTalents[Talent].reqWeaponTypes -- None,Wand,Knife,Sword,Axe,Club,Spear,Staff,Bow,Crossbow, Sentinel (Schild)
      if (not reqAbilities or SharedFns.HasAnyAbility(char,reqAbilities,MyStat) and 
          (not reqWeaponTypes or (char and (SharedFns.table_contains_value(reqWeaponTypes,char.Stats.MainWeapon.WeaponType) or 
          (char.Stats:GetItemBySlot("Shield")==nil and SharedFns.table_contains_value(reqWeaponTypes,"None")) or
          (char.Stats:GetItemBySlot("Shield") and SharedFns.table_contains_value(reqWeaponTypes,char.Stats:GetItemBySlot("Shield").WeaponType)))))) then
        table.insert(chosen,Talent)
      end
    elseif Talent=="None" then
      table.insert(chosen,Talent)
    end
    if notstop > 100 then
      Ext.Print("notstop Talent für "..tostring(charGUID))
      break
    end
  end
  SharedFns.table_removearrayvalue(chosen,"None",true)
  return chosen
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


-- ###################


-- Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
-- note that StatsLoaded is not thrown every time you load into a session, iirc it only triggers when loading mods or going from title screen -> session
-- Does not help to edit _Base and _Hero here, because the inheritance from these is only done once and BEFORE StatsLoaded

-- Random CRASH (extender v60) and may break sills: Do NOT call Ext.Stats.Sync while looping over Ext.Stats.GetStats("SkillData") (or most likely an other Ext.Stats.GetStats(...)). Instead save the names of the entries you changed while looping and then do a seperate loop after the GetStats loop to call Sync for these
-- Solution: Sync is not needed within StatsLoaded
SharedFns.OnStatsLoaded = function(e)-- Client only
  
  -- RandomTalentStatusEnemies_Serp
  -- Every NPC gets AttackOfOpportunity and ViolentMagic
  local npc_difficulties = {"StoryNPC_Character","CasualNPC","NormalNPC","HardcoreNPC"}
  for i,name in ipairs(npc_difficulties) do
    local MyStat = Ext.Stats.GetRaw(name)
    talents = MyStat["Talents"] or ""
    newtalents = {"AttackOfOpportunity"}
    if SharedFns.HasAnyAbility(nil,{"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist","Necromancy","Summoning"},MyStat) then
      table.insert(newtalents,"ViolentMagic")
    end
    for _,newtalent in ipairs(newtalents) do
      if not string.find(talents,newtalent) then
        talents = tostring(talents)..";"..tostring(newtalent)
      end
    end
    Ext.Stats.GetRaw(name)["Talents"] = talents
  end
  if SharedFns.HowToAddRandomTalents == "OnStats" then
    local exclude = {"_Hero","StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer","StoryNPC_Character","CasualNPC","NormalNPC","HardcoreNPC"}
    for i,name in pairs(Ext.Stats.GetStats("Character")) do
      local MyStat = Ext.Stats.GetRaw(name)
      if not SharedFns.table_contains_value(exclude,name) and not name:find("Hero") and not name:find("Player") then
        talents = MyStat["Talents"]
        newtalents = SharedFns.GetRandomTalents(nil,nil,SharedFns.num_talents,MyStat)
        if #newtalents>0 then
          newtalents = table.concat(newtalents, ";")
          if not string.find(talents,newtalents) then
            if talents and talents~="" then
              newtalents = tostring(talents)..";"..tostring(newtalents)
            end
            Ext.Stats.GetRaw(name)["Talents"] = newtalents--"Zombie;WalkItOff"
          end
        end
      end
    end
  end
end


-- #############
-- Server

-- already made sure it only forwards units, not items
SharedFns.OnUnitCombatEntered = function(charGUID,combatID)
  -- Ext.Print("OnUnitCombatEntered "..tostring(charGUID))
  local char = Ext.Entity.GetCharacter(charGUID)
  -- Random Talents/Status for not-ally
  if char and not SharedFns.IsPlayerAlly(charGUID) then -- neutral NPC and Enemies
    if SharedFns.HowToAddRandomTalents == "OnCombat" then
      chosen = SharedFns.GetRandomTalents(charGUID,char,SharedFns.num_talents)
      for i,Talent in ipairs(chosen) do
        SharedFns.AddTalent(charGUID,Talent,false,"NPCRandomTalent_"..tostring(i),char) -- only added once per NPC by using the Tag. that way no need to remove it on leave combat
      end
    end
    -- Random Status
    local chosen = 0
    notstop = 0
    while chosen < num_status do
      notstop = notstop + 1
      status = SharedFns.weighted_random_choices(RandomStatus, 1)[1]
      if status~="None" then
        if Osi.HasActiveStatus(charGUID,status)==0 then
          maxdur = RandomStatus[status].maxrounds or 2
          duration = Ext.Random(1,maxdur) * 6 -- it is in seconds and one combat round is 6 seconds
          Ext.Print("Apply Status "..tostring(status).." for "..tostring(duration/6).." rounds to "..tostring(charGUID))
          Osi.ApplyStatus(charGUID,status,duration,1) -- (GUIDSTRING)_Object, (STRING)_Status, (REAL)_Duration (-1.0 infinite), (INTEGER)_Force 
        end
        chosen = chosen+1
      elseif status=="None" then
        chosen = chosen+1
      end
      if notstop > 100 then
        Ext.Print("notstop Status für "..tostring(charGUID))
        break
      end
    end    
  end
  
end
