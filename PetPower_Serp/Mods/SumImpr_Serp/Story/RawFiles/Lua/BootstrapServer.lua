Ext.Require("Shared_Serp.lua")

-- Ext.Require("Server_SurfacePath.lua") -- does not work good enough..

SharedFns.RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  SharedFns.OnSaveLoaded(major, minor, patch, build)
end)

SharedFns.RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(objectGUID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterJoinedParty(objectGUID)
  end
end)
-- (CHARACTERGUID)_Character, (STRING)_Ability, (INTEGER)_OldBaseValue, (INTEGER)_NewBaseValue)
SharedFns.RegisterProtectedOsirisListener("CharacterBaseAbilityChanged", 4, "after", function(charGUID,ability,old,new)
  SharedFns.OnCharacterBaseAbilityChanged(charGUID,ability,old,new)
end)
-- ((CHARACTERGUID)_Character, (STRING)_Status, (GUIDSTRING)_Causee)
SharedFns.RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", function(charGUID,status,causee)
  SharedFns.OnCharacterStatusApplied(charGUID,status,causee)
end)
