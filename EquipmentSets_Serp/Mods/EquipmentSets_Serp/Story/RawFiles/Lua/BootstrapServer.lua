-- TODO:
-- container items in reihenfolge in ui loopen, istaktuell iwie nach name sortiert oderso..
-- Ext.Utils.GetHandleType(Ext.Entity.GetItem(Osi.GetItemForItemTemplateInInventory(Osi.CharacterGetHostCharacter(),"LLEQSET_BackPack_Serp_Set1_b38b81b8-eb66-42a8-b771-123b5525566e")).InventoryHandle)
-- _D(Ext.Entity.GetItem(Osi.GetItemForItemTemplateInInventory(Osi.CharacterGetHostCharacter(),"LLEQSET_BackPack_Serp_Set1_b38b81b8-eb66-42a8-b771-123b5525566e")).InventoryHandle)




-- The Mod will have one Backpack and one Switch Item.
-- When the Switch Item is used, the current equipment is exchanged with the equipment in the backpack
-- If not equipment for a specific slot is in the backpack, this slot will not be changed (so no support for unequipping slot)
-- This way the code will be super simple and no need to be savegame persistent and will cover most usecases for 2 different equipment sets

-- Osi functions: https://gist.github.com/PinewoodPip/fedf542f4cbf02b7cf91ebed7a71700b

SwitchSetItem_template = "LLEQSET_SetSwitcher_Serp_Set1_6c1877dd-42c8-4514-8472-9aedb6a081b1"
SetBackpack_template = "LLEQSET_BackPack_Serp_Set1_b38b81b8-eb66-42a8-b771-123b5525566e"
emptyitemGUID = "NULL_00000000-0000-0000-0000-000000000000"
CombatInfo = {}
MaxAPCosts = 1 -- set to number higher than slots, to use the equip ap cost for every slot once. if set to 1 it will always cost 1 AP regardless of how many slots are changed
-- (if the char has the InventoryAccess Talent equipping is free and therefore also here it is always free)
EquipCooldown = 1  -- turns cooldown in combat
NewBackpacksOnLoad = 1

local Slots = {
	"Ring2",
	"Ring",
	"Belt",
	"Boots",
	"Leggings",
	"Gloves",
	"Breast",
	"Helmet",
	"Amulet",
	"Shield",
	"Weapon",
}


function GetAllPlayerChars()
  local _players = Osi.DB_IsPlayer:Get(nil) -- Will return a list of tuples of all player characters
  local players = {}
  for _,tupl in ipairs(_players) do
    local charGUID = tupl[1]
    table.insert(players,charGUID)
  end
  return players
end

function GetTranslation(statsid_or_handle,fallback)
  if not statsid_or_handle then
    return fallback
  end
  local loc = Ext.L10N.GetTranslatedStringFromKey(statsid_or_handle,fallback)
  if not loc or loc=="" then
    loc = Ext.L10N.GetTranslatedString(statsid_or_handle,fallback)
  end
  if not loc or loc=="" then
    loc = fallback
  end
  return loc
end

-- Mods.EquipmentSets_Serp.ExchangeEquipment(Osi.CharacterGetHostCharacter())
function ExchangeEquipment(charGUID)
  local allowswitch = true
  if Osi.CharacterIsInCombat(charGUID)==1 then
    combatID = Osi.CombatGetIDForCharacter(charGUID)
    EsvCombat = Ext.Entity.GetCombat(combatID)
    CombatInfo[charGUID] = CombatInfo[charGUID] or {combatID=combatID,CurrentRound=EsvCombat.CombatRound,LastEquipRound=nil}
    CombatInfo[charGUID].CurrentRound = EsvCombat.CombatRound
    if CombatInfo[charGUID].LastEquipRound then
      cooldown_lasts = CombatInfo[charGUID].LastEquipRound + EquipCooldown - CombatInfo[charGUID].CurrentRound
      if cooldown_lasts>0 then
        allowswitch = false
        Osi.CharacterStatusText(charGUID,"<font color='#c80030'>Set Equip Cooldown ("..tostring(cooldown_lasts)..")</font>")
      end
    end
  else
    CombatInfo[charGUID] = nil
  end
  
  if allowswitch then
    local backpack_itemGUID = Osi.GetItemForItemTemplateInInventory(charGUID, SetBackpack_template)
    if backpack_itemGUID and backpack_itemGUID~=emptyitemGUID then
      local container = Ext.Entity.GetItem(backpack_itemGUID)
      local contents = container:GetInventoryItems()
      local slots_done = {}
      local done_equips = 0
      for _,contentGUID in ipairs(contents) do -- seems to be sorted by name or so ?! not by order in inventory..
        local new_item = Ext.Entity.GetItem(contentGUID)
        if new_item and new_item.Stats and Osi.ItemIsEquipable(contentGUID)==1 and new_item.CurrentTemplate and new_item.CurrentTemplate~=emptyitemGUID and new_item.CurrentTemplate~=SwitchSetItem_template and new_item.Stats.IsIdentified==1 then
          local UseAPCosts = 1 -- boolean
          if done_equips>=MaxAPCosts then
            UseAPCosts = 0
          end
          local slotname = Osi.ItemGetEquipmentSlot(contentGUID)
          if slots_done[slotname] and slotname=="Weapon" and not new_item.Stats.IsTwoHanded then -- then use Shield slot for second weapon
            slotname = "Shield"
          end
          if not slots_done[slotname] then
            local equipped_item_guid = Osi.CharacterGetEquippedItem(charGUID,slotname)
            local do_equip = true
            if equipped_item_guid~=emptyitemGUID then
              local equipped_item = Ext.Entity.GetItem(equipped_item_guid)
              if equipped_item and equipped_item.UnEquipLocked then
                do_equip = false
                slots_done[slotname] = true
              end
            end
            for _,requirement in pairs(new_item.Stats.Requirements) do
              local Attributelevel = Osi.CharacterGetAttribute(charGUID,requirement.Requirement)
              if not requirement.Not then
                if not Attributelevel or Attributelevel < tonumber(requirement.Param) then
                  do_equip = false
                end
              elseif Attributelevel and Attributelevel >= tonumber(requirement.Param) then
                do_equip = false
              end
              if not do_equip then
                Osi.CharacterStatusText(charGUID,"<font color='#c80030'>Requirements not met for item of slot "..tostring(slotname).."</font>")
              end
            end
            if do_equip then
              -- NRD_CharacterEquipItem((CHARACTERGUID)_Character, (ITEMGUID)_Item, (STRING)_Slot, (INTEGER)_ConsumeAP, (INTEGER)_CheckRequirements, (INTEGER)_UpdateVitality, (INTEGER)_UseWeaponAnimType) 
              if slotname=="Weapon" and new_item.Stats.ItemType=="Weapon" and new_item.Stats.IsTwoHanded then -- also unequip object in Shield slot
                local equipped_shield_guid = Osi.CharacterGetEquippedItem(charGUID,"Shield")
                if equipped_shield_guid and equipped_shield_guid~=emptyitemGUID then
                  Osi.CharacterUnequipItem(charGUID,equipped_shield_guid)
                  Osi.ItemToInventory(equipped_shield_guid,backpack_itemGUID,1,0,0) -- make sure to move into backpack
                end
                slots_done["Shield"] = true
              end
              Osi.NRD_CharacterEquipItem(charGUID, contentGUID, slotname, UseAPCosts, 1, 1, 1)
              if equipped_item_guid and equipped_item_guid~=emptyitemGUID then
                Osi.ItemToInventory(equipped_item_guid,backpack_itemGUID,1,0,0) -- make sure to move into backpack
              end
              slots_done[slotname] = true
              done_equips = done_equips + 1
              if CombatInfo[charGUID] then
                CombatInfo[charGUID].LastEquipRound = CombatInfo[charGUID].CurrentRound
              end
            end
          end
        end
      end
      Osi.CharacterStatusText(charGUID,"<font color='#40b606'>Equipping done</font>")
    end
  end
end

Ext.Osiris.RegisterListener("CharacterUsedItemTemplate", 3, "after", function(charGUID,template,itemGUID)
  if template == SwitchSetItem_template then
    ExchangeEquipment(charGUID)
  end
end)

-- Add Set Backpack on SavegameLoaded
Ext.Osiris.RegisterListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  if NewBackpacksOnLoad==1 then
    local players = GetAllPlayerChars()
    for _,charGUID in ipairs(players) do
      if Osi.CharacterGetItemTemplateCount(charGUID,SetBackpack_template) == 0 then
        Osi.ItemTemplateAddTo(SetBackpack_template,charGUID,1,1)
      -- if Osi.CharacterGetItemTemplateCount(charGUID,SwitchSetItem_template) == 0 then -- cant check within container... so assume we also need it again, if we have no backpack
        Osi.ItemTemplateAddTo(SwitchSetItem_template,charGUID,1,1)
        backpack_itemGUID = Osi.GetItemForItemTemplateInInventory(charGUID, SetBackpack_template)
        if backpack_itemGUID and backpack_itemGUID~=emptyitemGUID then
          switcher_GUID = Osi.GetItemForItemTemplateInInventory(charGUID, SwitchSetItem_template)
          if switcher_GUID and switcher_GUID~=emptyitemGUID then -- put switcher item into the backpack
            Osi.ItemToInventory(switcher_GUID,backpack_itemGUID,1,0,1)
          end
        end
      end
    end
  end
end)


-- ######################################

-- LeaderLib Settings
Ext.Events.SessionLoaded:Subscribe(function (ev)
  if Mods.LeaderLib then -- LeaderLib (outside of SessionLoaded it is nil if LeaderLib is not loaded first..)
    
    -- also called on game load with current settings
    Mods.LeaderLib.Events.ModSettingsChanged:Subscribe(function (e)
      if e.ID=="MaxAPCosts" then
        MaxAPCosts = e.Value
      elseif e.ID=="Cooldown" then
        EquipCooldown = e.Value
      elseif e.ID=="NewBackpacksOnLoad" then
        NewBackpacksOnLoad = e.Value
      end
    end, {MatchArgs={ModuleUUID=ModuleUUID}})
    
  end
end)