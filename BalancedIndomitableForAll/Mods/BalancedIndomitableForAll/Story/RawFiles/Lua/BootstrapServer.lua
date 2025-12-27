Ext.Require("Shared_Serp.lua")

-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#capturing-eventscalls
SharedFns.RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", function(target, status, nilSource)
  SharedFns.OnCharacterStatusRemoved(target, status, nilSource)
end)
