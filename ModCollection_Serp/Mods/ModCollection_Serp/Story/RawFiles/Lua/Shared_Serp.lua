-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md and the changelogs for v56 onwards, because they are not included in docu

-- Version in meta.lsx:
-- Major +268.435.456
-- Minor +16.777.216
-- Revision +65.536
-- Build +1
-- 1.0.0.0 -> 268.435.456
-- 1.1.0.0 -> 285.212.672
-- 1.2.0.0	-> 301.989.888	
-- 1.3.0.0	-> 318.767.104
-- 1.0.1.0 -> 268500992
-- 1.0.3.0 -> 268632064


SharedFns = {}

Ext.Print("Shared Script Started Serp66")


-- Status INVULNERABLE gibts auch

-- Evtl. in ExtraData (Data.txt) den Wert MaximumSummonsInCombat erhöhen (ist 4)? -> ist schon in Summoning Tweaks mod

-- TODO:
-- Savegame mit Martin nochmal mit selben Mods wie bei save erstellung laden und via Console
 -- die Tags für alle Charactere setzen: QuickStepForFree_Serp


-- Von Shout_SpiritVision in SkillProperties den dritten wert von 10 auf -1 ändern (dauerhaft)
 -- und evtl. noch AreaRadius von 20 auf 40, aber ich denke der vanilla radius ist ok

-- TODO:
-- Bei Ende von Combat oder LEaveCombat den NPCs die Talente entweder wieder entfernen,
 -- oder evtl. besser, ihnen beim vertilen Tags geben, damit bei erneutem Kampf keine weiteren Talents verteilt werden

-- TODO:
-- gucken ob der hier antwortet wie man eingige der ungenutzten Talente ins UI bekommt um sie selbst wählen zu können:
-- https://discord.com/channels/98922182746329088/991371940201766932/1441427242852024534
-- Dann zumindest BeastMaster dort wählbar machen (anstatt automatisch zu geben)
-- TODO: obwohl Divine Talents code auto-aktiviert wird, sind die Talente nicht in Talentliste sichtbar... also diese dann auch sichtbar machen


-- https://docs.larian.game/Talent_list
local num_talents = 2
local RandomTalents = {
  Ambidextrous={weight=2,reqWeaponTypes={"None"}}, -- Offhand must be free
  AttackOfOpportunity={weight=5,reqWeaponTypes={"None","Knife","Sword","Axe","Club","Spear","Staff"}}, -- any melee
  ViolentMagic={weight=4,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist","Necromancy","Summoning"}},
  ResistDead={weight=1},
  QuickStep={weight=1},
  Demon={weight=2},
  IceKing={weight=2},
  NoAttackOfOpportunity={weight=3},
  ElementalAffinity={weight=3,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist"}},
  WhatARush={weight=3},
  WalkItOff={weight=2},
  ElementalRanger={weight=3,reqAbilities={"RangerLore"},reqWeaponTypes={"Bow","Crossbow"}},
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
  Sadist={weight=2,reqWeaponTypes={"None","Knife","Sword","Axe","Club","Spear","Staff"}}, -- any melee
  MagicCycles={weight=3,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist"}},
  Haymaker={weight=1},
  Gladiator={weight=1},
  Soulcatcher={weight=1},
  Indomitable={weight=5},
  -- Story Talents
  Vitality ={weight= 2}, -- +20%HP
  BeastMaster ={weight=4,reqAbilities={"Summoning"}},
  Criticals={weight=2},
  IncreasedArmor={weight=2},
  Damage={weight=2},
  ResistStun={weight=2},
  ResistKnockdown={weight=2},
  ResistFear={weight=2},
  ActionPoints={weight=3},
  ActionPoints2={weight=2},
  ChanceToHitMelee={weight=2,reqWeaponTypes={"None","Knife","Sword","Axe","Club","Spear","Staff"}}, -- any melee
  ChanceToHitRanged={weight=2,reqWeaponTypes={"Bow","Crossbow","Wand"}}, -- ranged
  Backstab={weight=2,reqWeaponTypes={"None","Sword","Axe","Club","Spear","Staff"}}, -- any melee except Knife, since this allows Backstab with other weapons than knife
  RogueLoreGrenadePrecision={weight=2},
  RogueLoreMovementBonus={weight=2},
  RogueLoreHoldResistance={weight=1},
  RogueLoreDaggerBackStab={weight=2,reqWeaponTypes={"Knife"}},
  RogueLoreDaggerAPBonus={weight=2,reqWeaponTypes={"Knife"}},
  Sight={weight=2,reqWeaponTypes={"Bow","Crossbow","Wand"}}, -- ranged
  RangerLoreRangedAPBonus={weight=2,reqWeaponTypes={"Bow","Crossbow","Wand"}}, -- ranged
  RangerLoreEvasionBonus={weight=2},
  WarriorLoreNaturalResistance={weight=2,reqAbilities={"WarriorLore"}},
  WarriorLoreNaturalArmor={weight=2,reqAbilities={"WarriorLore"}},
  WarriorLoreNaturalHealth={weight=2,reqAbilities={"WarriorLore"}},
  GoldenMage={weight=2,reqAbilities={"EarthSpecialist","AirSpecialist","WaterSpecialist","FireSpecialist","Necromancy","Summoning"}},
  Courageous={weight=1},
  StandYourGround={weight=2},
  Bully={weight=2},
  WarriorLoreGrenadeRange={weight=2},
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


SharedFns.GetRandomTalents = function(charGUID,char,num)
  local chosen = {}
  notstop = 0
  while #chosen < num do
    notstop = notstop + 1
    Talent = SharedFns.weighted_random_choices(RandomTalents, 1)[1]
    if Talent~="None" and not char.Stats["TALENT_"..Talent] then
      reqAbilities = RandomTalents[Talent].reqAbilities -- WarriorLore,RangerLore,FireSpecialist,WaterSpecialist,AirSpecialist,EarthSpecialist,Necromancy,Summoning
      reqWeaponTypes = RandomTalents[Talent].reqWeaponTypes -- None,Wand,Knife,Sword,Axe,Club,Spear,Staff,Bow,Crossbow, Sentinel (Schild)
      if (not reqAbilities or SharedFns.HasAnyAbility(char,reqAbilities) and 
          (not reqWeaponTypes or (SharedFns.table_contains_value(reqWeaponTypes,char.Stats.MainWeapon.WeaponType) or 
          (char.Stats:GetItemBySlot("Shield")==nil and SharedFns.table_contains_value(reqWeaponTypes,"None")) or
          (char.Stats:GetItemBySlot("Shield") and SharedFns.table_contains_value(reqWeaponTypes,char.Stats:GetItemBySlot("Shield").WeaponType))))) then
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
				Ext.PrintError(err)
			end
		end
	end)
end

-- ##################################################################
-- ##################################################################
-- ##################################################################

-- info: gibt auch sowas, dann brauchts die txt Dateien nicht:  local status = CreateNewStatus("AimedShot_"..tostring(accuracyBoost), "DGM_Potion_Base", {AccuracyBoost = accuracyBoost, CriticalChance = char.Stats.Strength}, "DGM_AIMEDSHOT", {StackId = "Stack_LX_AimedShot"}, false)
SharedFns.ReducePlayerSpeedStatus = function(charGUID,char)
  char = char or Ext.Entity.GetCharacter(charGUID)
  if char~=nil and SharedFns.IsPlayerMainChar(charGUID,char) and Osi.HasActiveStatus(charGUID,"MOVEMENTSPEED_REDUCE_SERP")==0 then
    Ext.Print("ReducePlayerSpeedStatus",charGUID)
    Osi.ApplyStatus(charGUID,"MOVEMENTSPEED_REDUCE_SERP",-1.0,1)
  end
end

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
  if Talent and Talent~="None" then
    char = char or Ext.Entity.GetCharacter(charGUID)
    Ext.Print("Trying add Talent "..tostring(Talent).." to "..tostring(charGUID))
    
    -- TODO: noch rausfinden wie wirs dennoch anzeigen können (am besten Status machen der beschreibung und icon usw von denen verwendet, muss man aber viele machen...)
    if char.PlayerCustomData==nil then -- NRD_CharacterSetPermanentBoostTalent fügt Talent zwar zu, aber es wird nicht in UI angezeigt
      Osi.NRD_CharacterSetPermanentBoostTalent(charGUID,Talent,1)--(CHARACTERGUID)_Character, (STRING)_Talent, (INTEGER)_HasTalent (_HasTalent=0 heißt entfernen und =1 heißt zufügen)
      Osi.CharacterSetForceSynch(charGUID,1)
      Ext.Print("Talent "..tostring(Talent).." was added (invisible..) to NPC "..tostring(charGUID))
    else
      if not Tag or Osi.IsTagged(charGUID,Tag)==0 then
        if (char and not char.Stats["TALENT_"..Talent]) or (not char and Osi.CharacterHasTalent(charGUID, Talent) == 0) then
          Osi.CharacterAddTalent(charGUID, Talent)
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
end

SharedFns.HasAnyAbility = function(char,abilities)
  for _,ability in ipairs(abilities) do
    if char.Stats[ability]>0 then
      return true
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

-- ##################################################################
-- ###################   Events   ###################################
-- ##################################################################

-- Ext.Stats.SetAttribute(stat, attribute, value)
-- Updates the specified attribute of the stat entry. 
-- This essentially allows on-the-fly patching of stat .txt files from script without having to override the whole stat entry. 
-- If the function is called while the module is loading (i.e. from a ModuleLoading/StatsLoaded listener) no additional calls are needed. 
-- If the function is called after module load, the stats entry must be synchronized with the client via the Ext.Stats.Sync(stat,false) call.
-- Alternativ zb: Ext.Stats.GetRaw("Summon_Incarnate")["ActionPoints"] = 1

-- Client only
-- Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
-- note that StatsLoaded is not thrown every time you load into a session, iirc it only triggers when loading mods or going from title screen -> session
-- Does not help to edit _Base and _Hero here, because the inheritance from these is only done once and BEFORE StatsLoaded

-- Random CRASH (extender v60) and may break sills: Do NOT call Ext.Stats.Sync while looping over Ext.Stats.GetStats("SkillData") (or most likely an other Ext.Stats.GetStats(...)). Instead save the names of the entries you changed while looping and then do a seperate loop after the GetStats loop to call Sync for these
-- Solution: Sync is not needed within StatsLoaded
SharedFns.OnStatsLoaded = function(e)
  Ext.Print("OnStatsLoadedSerpCollection Start")
      
  -- Outcommented, because this also hits my summones, not only the main characters (_Hero does not work, because it is used for inheritance, which is already done on statsloaded)
  -- Half movement for Player characters. "_Base" is used for many units, so dont change it
  -- Movement Wert für StoryPlayer usw kommt anscheinend on top auf _Base, ist also ein Bonus für die Schwierigkeit. also einfach alle werte halbieren (vanilla sind die Player werte 0)
  -- basemovement = Ext.Stats.GetRaw("_Base")["Movement"]
  -- for _,name in ipairs({"StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer"}) do
    -- summe = basemovement + Ext.Stats.GetRaw(name)["Movement"]
    -- Ext.Stats.GetRaw(name)["Movement"] = summe/2 - basemovement
  -- end
  
  -- half movement speed of everyone and give everyone The Pawn talent
  local difficulty = {"StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer","StoryNPC_Character","CasualNPC","NormalNPC","HardcoreNPC"}
  
  for i,name in ipairs(difficulty) do
      Ext.Stats.GetRaw(name)["MovementSpeedBoost"] = -50 -- half movement speed
      if string.find(name,"NPC") then -- for fixed Talents and NPC here, but players in OnSaveLoaded and so on, to also grant a talent point for free, in case they already had the talent
        talents = Ext.Stats.GetRaw(name)["Talents"] or ""
        newtalents = {"QuickStep"}
        for _,newtalent in ipairs(newtalents) do
          if not string.find(talents,newtalent) then
            talents = tostring(talents)..";"..tostring(newtalent)
          end
        end
        Ext.Stats.GetRaw(name)["Talents"] = talents --"Zombie;WalkItOff"
      end
  end
  
  -- DivineTalentsGiftpackMod
  Stats_Indomitable_Flags = Ext.Stats.GetRaw("Stats_Indomitable")["Flags"]
  for _,flag in ipairs({"ChickenImmunity","CrippledImmunity","FearImmunity","FreezeImmunity","KnockdownImmunity","PetrifiedImmunity","StunImmunity","MadnessImmunity","CharmImmunity"}) do
    if not SharedFns.table_contains_value(Stats_Indomitable_Flags,flag) then
      table.insert(Stats_Indomitable_Flags,flag)
    end
  end
  Ext.Stats.GetRaw("Stats_Indomitable")["Flags"] = Stats_Indomitable_Flags
  Ext.Stats.GetRaw("MADNESS")["ImmuneFlag"] = "MadnessImmunity" 
  
  -- ImprovedDoorOfEternity
  
  for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    if name=="Shout_CloseTheDoor" then
      Ext.Stats.GetRaw(name)["ActionPoints"] = 2
      local MyStat = Ext.Stats.Get(name)
      MyStat["TargetConditions"] = "Ally&Summon&!Spirit" -- MySummon&!Spirit -- GetRaw does not work for TargetConditions
      local SkillProperties = MyStat["SkillProperties"] -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
      if SkillProperties and type(SkillProperties)=="table" then
        -- for _,entry in pairs(SkillProperties) do
          -- if entry.Action=="ETERNITY_DOOR" then
            -- entry.Duration = 5*6 -- from 3 to 5 rounds
            -- break
          -- end
        -- end
        MyStat["SkillProperties"] = SkillProperties
      end
    end
  end
  
  -- Ext.Stats.GetRaw("Shout_CloseTheDoor")["ActionPoints"] = 2
  -- local MyStat = Ext.Stats.Get("Shout_CloseTheDoor")
  -- MyStat["TargetConditions"] = "Ally&Summon&!Spirit" -- MySummon&!Spirit -- GetRaw does not work for TargetConditions
  -- local SkillProperties = MyStat["SkillProperties"] -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
  -- if SkillProperties and type(SkillProperties)=="table" then
    -- for _,entry in pairs(SkillProperties) do
      -- if entry.Action=="ETERNITY_DOOR" then
        -- entry.Duration = 5*6 -- from 3 to 5 rounds
        -- break
      -- end
    -- end
    -- Ext.Stats.Get("Shout_CloseTheDoor")["SkillProperties"] = SkillProperties
  -- end
  
  
  Ext.ExtraData["TalentQuickStepPartialApBonus"] = 4 -- make Pawn provide 10 meter (with halfed Movement in mind, since this also affects The Pawn)
  
  
  -- doing it OnUnitCombatEntered instead, works now with NRD_CharacterSetPermanentBoostTalent
  -- local exclude = {"_Hero","StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer","StoryNPC_Character","CasualNPC","NormalNPC","HardcoreNPC"}
  -- for i,name in pairs(Ext.Stats.GetStats("Character")) do
    -- if not SharedFns.table_contains_value(exclude,name) then
      -- talents = Ext.Stats.GetRaw(name)["Talents"]
      -- newtalents = SharedFns.weighted_random_choices(RandomTalents, 2)
      -- SharedFns.table_removearrayvalue(newtalents,"None",true)
      -- if #newtalents>0 then
        -- newtalents = table.concat(newtalents, ";")
        -- if not string.find(talents,newtalents) then
          -- if talents and talents~="" then
            -- newtalents = tostring(talents)..";"..tostring(newtalents)
          -- end
          -- Ext.Stats.GetRaw(name)["Talents"] = newtalents--"Zombie;WalkItOff"
          -- Ext.Print("Added Talents to",name,newtalents)
        -- end
      -- end
    -- end
  -- end
    
  
  Ext.Print("OnStatsLoadedSerpCollection Ende")
  
end


-- #############
-- Server

SharedFns.OnSaveLoaded = function(major, minor, patch, build)
  local players = SharedFns.GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    SharedFns.AddTalent(charGUID,"QuickStep",true,"QuickStepForFree_Serp")
    SharedFns.AddTalent(charGUID,"InventoryAccess",false) -- cheaper changing equipment during fight
    -- SharedFns.AddTalent(charGUID,"BeastMaster",false) -- 1 extra summon
    Osi.RemoveStatus(charGUID,"MOVEMENTSPEED_REDUCE_SERP") -- remove it, no longer needed
    if Osi.IsTagged(charGUID,"PETPAL")==0 then
      Osi.SetTag(charGUID,"PETPAL") -- allows speaking with animals, even without the talent
    end
  end
end



-- TODO: checken welche fähigkeiten, also Pyrokinetic usw char hat bzw. Summonist und pb Talent dazu passt
-- Auch statuseffekte wie vampirism bei kampfbeginn zufügen, aber nur eher schwächere, vampirism ist schon zu stark




-- CharacterGetEquippedWeapon [in](CHARACTERGUID)_Character, [out](GUIDSTRING)_ItemGUID
-- bzw besser:
-- char.Stats.TALENT_...
-- char.Stats.







-- already made sure it only forwards units, not items
SharedFns.OnUnitCombatEntered = function(charGUID,combatID)
  Ext.Print("OnUnitCombatEntered "..tostring(charGUID))
  local char = Ext.Entity.GetCharacter(charGUID)
  
  -- slow down player main chars in exchange for the Pawn talent they got
  -- SharedFns.ReducePlayerSpeedStatus(charGUID)
  
  -- Full Heal of NPCS
  SharedFns.DoHeal(charGUID,false,true,55,100,char)
  
  -- Random Talents/Status for not-ally
  if char and not SharedFns.IsPlayerAlly(charGUID) then -- neutral NPC and Enemies
    Ext.Print("Try adding Talents/Status to non Ally: "..tostring(charGUID))
    chosen = SharedFns.GetRandomTalents(charGUID,char,num_talents)
    for _,Talent in ipairs(chosen) do
      SharedFns.AddTalent(charGUID,Talent,false,nil,char)
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
          duration = Ext.Random(1,maxdur) * 6 -- it is in seconds and one combar round is 6 seconds
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

SharedFns.OnCharacterResurrected = function(charGUID)
  -- SharedFns.ReducePlayerSpeedStatus(charGUID)
end
-- also called for summons!
SharedFns.OnCharacterJoinedParty = function(charGUID)
  Ext.Print("CharacterJoinedParty",charGUID)
  if SharedFns.IsPlayerMainChar(charGUID) then
    SharedFns.AddTalent(charGUID,"QuickStep",true,"QuickStepForFree_Serp")
    SharedFns.AddTalent(charGUID,"InventoryAccess",false) -- cheaper changing equipment during fight
    -- SharedFns.AddTalent(charGUID,"BeastMaster",false) -- 1 extra summon
    if Osi.IsTagged(charGUID,"PETPAL")==0 then
      Osi.SetTag(charGUID,"PETPAL") -- allows speaking with animals, even without the talent
    end
    -- SharedFns.ReducePlayerSpeedStatus(charGUID)
  end
end
SharedFns.OnCharacterLeftParty = function(charGUID)
  -- Osi.RemoveStatus(charGUID,"MOVEMENTSPEED_REDUCE_SERP")
  -- Osi.CharacterRemoveTalent(charGUID,"QuickStep")
end
-- ################################
 -- DivineTalentsGiftpackMod
-- Give everyone a nerfed (better balanced) version Indomitable status:
-- Give the Status AFTER the CC-status wered off for 3 turns and then you are immune to CC for these 3 turns.
-- Revert overrides in Skill_Projectile of Projectile_DimensionalBolt (were no changes compared to vanilla, so unneeded overwrite) 
-- CMP_Talents_override is mostly the same, but added CHARM and MADNESS and increased the CD from 2 to 3 rounds (the time where you are vulnerable to CC)

-- TODO:
 -- add to Indomitable Tooltip (or at least for my status) that Charmend and Madness are also added


local giftBagTextFiles = {
    ["Mods/CMP_DivineTalents_Kamil/Story/RawFiles/Goals/CMP_Talents.txt"] = "Mods/ModCollection_Serp/Story/RawFiles/Goals/CMP_Talents_override.txt",
    ["Public/CMP_DivineTalents_Kamil/Stats/Generated/Data/Skill_Projectile.txt"] = "Public/ModCollection_Serp/Stats/Generated/Data/Skill_Projectile.txt",
}

for file,override in pairs(giftBagTextFiles) do
    Ext.IO.AddPathOverride(file, override)
end

-- der IndomitableForAll Mod looped durch alle Stati die die entsprechenden ImmuneFlagg hat um alle Stati zu finden,vorallem auch welche von Mods.
-- Allerdings warum sollte ein Mod einen Status zufügen, der die ImmuneFlag KnockedDown hat? Mods die neue CC Stati zufügen, werden so doch auch nicht erkannt.
-- Sehe ich nicht, also hardcode ich die Stati stattdessen (offenbar kann man auch weder aus status noch aus dazugehörigem potion rauslesen, welche Stati die Runde skippen lassen?! sonst hätte er das ja genommen und ich find auch nichts)
SharedFns.Indomitable_Block_Stati = {"CHICKEN","FROZEN","PETRIFIED","STUNNED","KNOCKED_DOWN","CRIPPLED","CHARMED","MADNESS"}
SharedFns.Indomitable_Duration = 3
SharedFns.OnCharacterStatusRemoved = function(target, status, nilSource)
  -- if SharedFns.table_contains_value(SharedFns.Indomitable_Block_Stati,status) and Osi.HasActiveStatus(target,"INDOMITABLE")==0 then
    -- if Osi.CharacterIsDead(target)==0 and Osi.ObjectIsOnStage(target)==1 then
      -- local char =Ext.Entity.GetCharacter(target) -- using the TALENT check instead of Osi.CharacterHasTalent, because the Osi one fails for Giftbag talent while the giftbag is not enabled...
      -- if char.Stats["TALENT_Indomitable"] then
        -- Osi.ApplyStatus(target,"INDOMITABLE",SharedFns.Indomitable_Duration*6,1)
        -- Ext.Print("OnCharacterStatusRemoved added INDOMITABLE",target)
      -- end
    -- end
  -- end
  
  if SharedFns.table_contains_value(SharedFns.Indomitable_Block_Stati,status) and Osi.HasActiveStatus(target,"INDOMITABLE_SERP")==0 then
    if Osi.CharacterIsDead(target)==0 and Osi.ObjectIsOnStage(target)==1 then
      Osi.ApplyStatus(target,"INDOMITABLE_SERP",SharedFns.Indomitable_Duration*6,1)
      Ext.Print("OnCharacterStatusRemoved added INDOMITABLE",target)
    end
  end
end




-- ################################################

-- !test
-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#console
local function test()
  Ext.Print("TEST")
  local players = SharedFns.GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    local char = Ext.Entity.GetCharacter(charGUID)
    Ext.Print("charGUID:",charGUID)
    -- Ext.Print(char.Stats["TALENT_QuickStep"]) -- returned true/false
    -- Ext.Print(char.Stats["Summoning"]) -- returned int, also das level der ability
    -- Ext.Print(char.Stats.MainWeapon)
    -- Ext.Print(char.Stats.MainWeapon.WeaponType) -- None,Wand,Knife,Sword,Axe,Club,Spear,Staff,Bow,Crossbow
    -- Ext.Print(char.Stats.OffHandWeapon.WeaponRange) -- OffHandWeapon can be nil ! if no weapon (shields are also nil!)
    -- Ext.Print(char.Stats:GetItemBySlot("Shield")) -- shield slot, better use this since it can find weapons and shieds, while OffHandWeapon only finds weapon
    -- Ext.Print(char.Stats:GetItemBySlot("Shield").WeaponType) -- Schild heißt immer Sentinel
  end
end
Ext.RegisterConsoleCommand("test", test)

-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").Stats.OffHandWeapon)
-- Ext.Print(Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb").Stats:GetItemBySlot("Shield").WeaponType)

-- Ext.Print(Osi.CharacterIsControlled("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd"))
-- Ext.Print(Osi.CharacterIsControlled("Summons_Ward_Wood_fa993de4-1957-4bfd-812d-4e53ac00fb54"))
-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PartyFollower)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_a5be97c8-563d-4995-a326-77fb783c0c0d").PartyFollower)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_03cb8837-5d3c-4bee-abc1-fabbf836f73e").PartyFollower)
-- Ext.Print(Ext.NRD_CharacterSetPermanentBoostTalent)

-- Osi.ApplyStatus("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","VAMPIRISM",4,1)


-- Osi.CharacterAddTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Vitality")
-- Osi.CharacterAddTalent("Summons_Incarnate_f54a7611-b46b-4bf5-837c-31d1815ae90a","Vitality")
-- Osi.CharacterAddTalent("S_FTJ_Brute_001_94131f94-2152-49f2-8ee2-9832263eec05","Vitality")


-- Osi.CharacterAddTalent("S_FTJ_CourtRoomGuard_002_bb9fd6c4-4231-44ac-a24d-5955dc300147","QuickStep")
-- Osi.CharacterAddTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Indomitable")
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_002_1832a661-0e21-421f-acaa-a7e66e813b14","Indomitable",1)
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_001_08348b3a-bded-4811-92ce-f127aa4310e0","Indomitable",1)
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_AlcovePrisoner_001_11cddbdf-40b8-4ce5-8ea8-e5f1ca8ac2e0","Indomitable",1)

-- Ext.Print(Osi.CharacterAddTalent)

-- Ext.Print(Osi.NRD_CharacterSetPermanentBoostTalent)
-- Osi.NRD_CharacterSetPermanentBoostTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Zombie",0)
-- Osi.NRD_CharacterSetPermanentBoostTalent("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","Zombie",1)
-- Osi.NRD_CharacterSetPermanentBoostTalent("S_FTJ_BeachVw_001_08348b3a-bded-4811-92ce-f127aa4310e0","Zombie",1)
-- Osi.CharacterSetForceSynch("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd",0)

-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PlayerCustomData.OwnerProfileID)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_c9eac4b1-9391-4f12-b871-49db5c50239f").PlayerCustomData.OwnerProfileID)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Ward_Wood_64018dfd-fd90-4004-bb6e-9ea3de017c50").PlayerCustomData.OwnerProfileID)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_c9eac4b1-9391-4f12-b871-49db5c50239f").PlayerCustomData.AiPersonality)
-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PlayerCustomData.AiPersonality)
-- Ext.Print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").PlayerCustomData.Name)
-- Ext.Print(Ext.Entity.GetCharacter("Summons_Incarnate_c9eac4b1-9391-4f12-b871-49db5c50239f").PlayerCustomData.Name)
-- Ext.Print(Ext.Entity.GetCharacter("S_FTJ_BeachVw_002_1832a661-0e21-421f-acaa-a7e66e813b14").PlayerCustomData.Name)



-- local _players = Osi.DB_IsPlayer:Get(nil);for _,tupl in ipairs(_players) do local charGUID = tupl[1];Osi.SetTag(charGUID,"QuickStepForFree_Serp");end
-- local _players = Osi.DB_IsPlayer:Get(nil);for _,tupl in ipairs(_players) do local charGUID = tupl[1];Ext.Print(Osi.IsTagged(charGUID,"QuickStepForFree_Serp"));end

