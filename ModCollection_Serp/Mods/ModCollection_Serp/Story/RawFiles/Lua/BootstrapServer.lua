Ext.Require("Shared_Serp.lua")

-- SharedFns.RegisterProtectedOsirisListener only works on Server.

-- Ext.Print("Server Script Started Serp66")

-- StatsLoaded can not be subscribed at server, do it on client instead and Sync




-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#capturing-eventscalls
SharedFns.RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", function(target, status, nilSource)
  SharedFns.OnCharacterStatusRemoved(target, status, nilSource)
end)

SharedFns.RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  SharedFns.OnSaveLoaded(major, minor, patch, build)
end)


-- (GUIDSTRING)_Object, (INTEGER)_CombatID 
SharedFns.RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(objectGUID, combatID)
  -- Ext.Print("ObjectEnteredCombat: ",objectGUID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnUnitCombatEntered(objectGUID,combatID)
  end
end)
SharedFns.RegisterProtectedOsirisListener("CharacterResurrected", 1, "after", function(objectGUID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterResurrected(objectGUID)
  end
end)
SharedFns.RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(objectGUID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterJoinedParty(objectGUID)
  end
end)
SharedFns.RegisterProtectedOsirisListener("CharacterLeftParty", 1, "after", function(objectGUID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterLeftParty(objectGUID)
  end
end)



