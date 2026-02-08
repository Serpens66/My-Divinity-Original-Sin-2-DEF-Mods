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
      -- print("SmallChanges_Serp: ModSettingsChanged",e.ID,e.Value)
      
      if e.ID=="HealNPCIfBelow" then
        HealNPCIfBelow = e.Value
      elseif e.ID=="SkillbooskLvl5Not4" then
        for i,obj in pairs(Ext.Stats.GetStats("Object")) do
          if obj:lower():find("skillbook",1,true) then
            local stat = Ext.Stats.Get(obj)
            if stat then
              if e.Value==1 and stat.MinLevel==4 then
                stat.MinLevel = 5
                Ext.Stats.Sync(obj,false)
              elseif e.Value==0 and stat.MinLevel==5 then
                stat.MinLevel = 4
                Ext.Stats.Sync(obj,false)
              end
            end
          end
        end
      elseif e.ID=="DisableIndomiteable" then
        local players = SharedFns.GetAllPlayerChars()
        for _,charGUID in ipairs(players) do
          Osi.NRD_CharacterDisableTalent(charGUID,"Indomitable", e.Value) -- 1 means disabling
        end
      elseif e.ID=="AddFreeEquipTalent" then
        local players = SharedFns.GetAllPlayerChars()
        for _,charGUID in ipairs(players) do
          if e.Value==1 then
            SharedFns.AddTalent(charGUID,"InventoryAccess",false,"InventoryAccess_Serp") -- cheaper changing equipment during fight
          else
            Osi.CharacterRemoveTalent(charGUID,"InventoryAccess")
            Osi.ClearTag(charGUID,"InventoryAccess_Serp")
          end
        end
      elseif e.ID=="LeaderGetsLeaderBuff" then
        LeaderGetsLeaderBuff = e.Value==1
        local players = SharedFns.GetAllPlayerChars()
        for _,charGUID in ipairs(players) do
          if e.Value==0 then
            Osi.RemoveStatus(charGUID,"LEADERSHIP_SERP")
          elseif e.Value==1 then
            AdjustLeaderLeadership(charGUID)
          end
        end
      end
    end, {MatchArgs={ModuleUUID=ModuleUUID}})

  end
end)


