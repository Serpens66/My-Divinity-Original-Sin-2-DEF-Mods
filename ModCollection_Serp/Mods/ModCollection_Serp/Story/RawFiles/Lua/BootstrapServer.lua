Ext.Require("Shared_Serp.lua")

-- SharedFns.RegisterProtectedOsirisListener only works on Server.

-- Ext.Print("Server Script Started Serp66")

-- StatsLoaded can not be subscribed at server, do it on client instead and Sync




-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#capturing-eventscalls
SharedFns.RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", function(charGUID, status, nilSource)
  SharedFns.OnCharacterStatusRemoved(charGUID, status, nilSource)
end)
-- also called for standing in surface (CHARACTERGUID)_Character, (STRING)_Status, (GUIDSTRING)_Causee
SharedFns.RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", function(charGUID, status, causee)
  SharedFns.OnCharacterStatusApplied(charGUID, status, causee)
end)

SharedFns.RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  SharedFns.OnSaveLoaded(major, minor, patch, build)
end)


-- (GUIDSTRING)_Object, (INTEGER)_CombatID 
SharedFns.RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(charGUID, combatID)
  -- Ext.Print("ObjectEnteredCombat: ",charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnUnitCombatEntered(charGUID,combatID)
  end
end)
SharedFns.RegisterProtectedOsirisListener("ObjectTurnStarted", 1, "after", function(charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object
    SharedFns.OnObjectTurnStarted(charGUID)
  end
end)
SharedFns.RegisterProtectedOsirisListener("CharacterResurrected", 1, "after", function(charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterResurrected(charGUID)
  end
end)
SharedFns.RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterJoinedParty(charGUID)
  end
end)
SharedFns.RegisterProtectedOsirisListener("CharacterLeftParty", 1, "after", function(charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterLeftParty(charGUID)
  end
end)
-- (CHARACTERGUID)_Character, (STRING)_Ability, (INTEGER)_OldBaseValue, (INTEGER)_NewBaseValue)
SharedFns.RegisterProtectedOsirisListener("CharacterBaseAbilityChanged", 4, "after", function(charGUID,ability,old,new)
  SharedFns.OnCharacterBaseAbilityChanged(charGUID,ability,old,new)
end)

-- (CHARACTERGUID)_Character, (INTEGER)_Level 
SharedFns.RegisterProtectedOsirisListener("CharacterLeveledUp", 1, "after", function(charGUID)
  SharedFns.OnCharacterLeveledUp(charGUID,level)
end)

SharedFns.RegisterProtectedOsirisListener("CharacterLearnedSkill", 2, "after", function(charGUID,skill)
  SharedFns.OnCharacterLearnedSkill(charGUID,skill)
end)



-- SharedFns.RegisterProtectedOsirisListener("CharacterWentOnStage", 2, "after", function(charGUID,inte)-- (CHARACTERGUID)_Character, (INTEGER)_Bool 
  -- Ext.Print("CharacterWentOnStage",charGUID,inte)
-- end)
-- SharedFns.RegisterProtectedOsirisListener("CharacterEnteredRegion", 2, "after", function(charGUID,region)-- (CHARACTERGUID)_Character, (STRING)_Region 
  -- Ext.Print("CharacterEnteredRegion",charGUID,region) 
-- end)
-- SharedFns.RegisterProtectedOsirisListener("CharacterCreatedInArena", 2, "after", function(charGUID,team)-- (CHARACTERGUID)_Character, (INTEGER)_Team 
  -- Ext.Print("CharacterCreatedInArena",charGUID,team)
-- end)

-- SharedFns.RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "before", function(charGUID, status, causee)
  -- print("CharacterStatusApplied",charGUID, status, causee)
-- end)
