Ext.Require("Shared_Serp.lua")


-- (GUIDSTRING)_Object, (INTEGER)_CombatID 
SharedFns.RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(objectGUID, combatID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnUnitCombatEntered(objectGUID,combatID)
  end
end)


