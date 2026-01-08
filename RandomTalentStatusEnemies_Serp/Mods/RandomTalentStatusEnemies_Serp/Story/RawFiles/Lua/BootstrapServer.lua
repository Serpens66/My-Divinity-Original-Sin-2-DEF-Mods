Ext.Require("Shared_Serp.lua")


-- (GUIDSTRING)_Object, (INTEGER)_CombatID 
SharedFns.RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(objectGUID, combatID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    SharedFns.OnUnitCombatEntered(objectGUID,combatID)
  end
end)


-- new Osiris function to provide talents
-- idea was to call this in a charscript for every NPC in OnActivate(), but no clue how to add a charscript to every npc..
SharedFns.OsirisAddTalent = function(charGuid)
  Ext.Print("OsirisAddTalent",charGuid)
  if SharedFns.HowToAddRandomTalents == "Live" and not SharedFns.IsPlayerAlly(charGUID) then
    local char = Ext.Entity.GetCharacter(charGUID)
    chosen = SharedFns.GetRandomTalents(charGUID,char,SharedFns.num_talents)
    for i,Talent in ipairs(chosen) do
      SharedFns.AddTalent(charGUID,Talent,false,"NPCRandomTalent_"..tostring(i),char) -- only added once per NPC by using the Tag. that way no need to remove it on leave combat
    end
  end
end
Ext.Osiris.NewCall(SharedFns.OsirisAddTalent, "SERP_EXT_OsirisAddTalent", "(GUIDSTRING)_Char");