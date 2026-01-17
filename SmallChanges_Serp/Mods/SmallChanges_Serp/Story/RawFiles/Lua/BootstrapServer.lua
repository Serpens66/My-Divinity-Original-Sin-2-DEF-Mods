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

-- event ItemEquipped((ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,518,1)
SharedFns.RegisterProtectedOsirisListener("ItemEquipped", 2, "after", function(item,charGUID)
  SharedFns.OnItemEquipped(item,charGUID)
end)

-- event ItemUnEquipped((ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,519,1)
SharedFns.RegisterProtectedOsirisListener("ItemUnEquipped", 2, "after", function(item,charGUID)
  SharedFns.OnItemUnEquipped(item,charGUID)
end)

SharedFns.RegisterProtectedOsirisListener("CharacterResurrected", 1, "after", function(charGUID)
  SharedFns.OnCharacterResurrected(item,charGUID)
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




-- ######################################

-- LeaderLib Settings
Ext.Events.SessionLoaded:Subscribe(function (ev)
  if Mods.LeaderLib then -- LeaderLib (outside of SessionLoaded it is nil if LeaderLib is not loaded first..)
    -- also called on game load with current settings
    Mods.LeaderLib.Events.ModSettingsChanged:Subscribe(function (e)
      print("SmallChanges_Serp: ModSettingsChanged",e.ID,e.Value)
      
      -- local ModVars = Ext.Vars.GetModVariables(ModuleUUID)
      -- ModVars.NPCDifficultySettings = ModVars.NPCDifficultySettings or {
        -- CasualArmorNPCDiff=-50,
        -- CasualMagicArmorNPCDiff=-50,
        -- CasualVitalityNPCDiff=-15,
        -- CasualMovementNPCDiff=0,
        -- NormalArmorNPCDiff=-25,
        -- NormalMagicArmorNPCDiff=-25,
        -- NormalVitalityNPCDiff=33,
        -- NormalMovementNPCDiff=10,
        -- HardcoreArmorNPCDiff=0,
        -- HardcoreMagicArmorNPCDiff=0,
        -- HardcoreVitalityNPCDiff=100,
        -- HardcoreMovementNPCDiff=25,
      -- }
      
      if e.ID=="HealNPCIfBelow" then
        HealNPCIfBelow = e.Value
        
      -- elseif e.ID=="CasualArmorNPC" then
        -- local stat = Ext.Stats.GetRaw("CasualNPC")
        -- stat.ArmorBoost = e.Value
        -- Ext.Stats.Sync("CasualNPC",true)
      -- elseif e.ID=="CasualMagicArmorNPC" then
        -- local stat = Ext.Stats.GetRaw("CasualNPC")
        -- stat.MagicArmorBoost = e.Value
        -- Ext.Stats.Sync("CasualNPC",true)
      -- elseif e.ID=="CasualVitalityNPC" then
        -- local stat = Ext.Stats.GetRaw("CasualNPC")
        -- stat.Vitality = e.Value
        -- Ext.Stats.Sync("CasualNPC",true)
      -- elseif e.ID=="CasualMovementNPC" then
        -- local stat = Ext.Stats.GetRaw("CasualNPC")
        -- stat.MovementSpeedBoost = e.Value
        -- Ext.Stats.Sync("CasualNPC",true)
        
      -- elseif e.ID=="NormalArmorNPC" then
        -- local stat = Ext.Stats.GetRaw("NormalNPC")
        -- stat.ArmorBoost = e.Value
        -- Ext.Stats.Sync("NormalNPC",true)
      -- elseif e.ID=="NormalMagicArmorNPC" then
        -- local stat = Ext.Stats.GetRaw("NormalNPC")
        -- stat.MagicArmorBoost = e.Value
        -- Ext.Stats.Sync("NormalNPC",true)
      -- elseif e.ID=="NormalVitalityNPC" then
        -- local stat = Ext.Stats.GetRaw("NormalNPC")
        -- stat.Vitality = e.Value
        -- Ext.Stats.Sync("NormalNPC",true)
      -- elseif e.ID=="NormalMovementNPC" then
        -- local stat = Ext.Stats.GetRaw("NormalNPC")
        -- stat.MovementSpeedBoost = e.Value
        -- Ext.Stats.Sync("NormalNPC",true)
        
      -- elseif e.ID=="HardcoreArmorNPC" then
        -- local stat = Ext.Stats.GetRaw("HardcoreNPC")
        -- stat.ArmorBoost = e.Value
        -- Ext.Stats.Sync("HardcoreNPC",true)
      -- elseif e.ID=="HardcoreMagicArmorNPC" then
        -- local stat = Ext.Stats.GetRaw("HardcoreNPC")
        -- stat.MagicArmorBoost = e.Value
        -- Ext.Stats.Sync("HardcoreNPC",true)
      -- elseif e.ID=="HardcoreVitalityNPC" then
        -- local stat = Ext.Stats.GetRaw("HardcoreNPC")
        -- stat.Vitality = e.Value
        -- Ext.Stats.Sync("HardcoreNPC",true)
      -- elseif e.ID=="HardcoreMovementNPC" then
        -- local stat = Ext.Stats.GetRaw("HardcoreNPC")
        -- stat.MovementSpeedBoost = e.Value
        -- Ext.Stats.Sync("HardcoreNPC",true)
        
      -- elseif e.ID:find("NPCDiff",1,true) then -- NPC difficulty settings, need a save+load to take effect
        -- ModVars.NPCDifficultySettings[e.ID] = e.Value
        -- Ext.Vars.SyncModVariables(ModuleUUID)
        
      end
    end, {MatchArgs={ModuleUUID=ModuleUUID}})

  end
end)


