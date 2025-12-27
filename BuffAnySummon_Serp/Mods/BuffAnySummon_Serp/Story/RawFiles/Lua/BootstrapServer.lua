Ext.Require("Shared_Serp.lua")

SharedFns.RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  SharedFns.OnSaveLoaded(major, minor, patch, build)
end)

SharedFns.RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(objectGUID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnCharacterJoinedParty(objectGUID)
  end
end)