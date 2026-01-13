-- Code to persistent "change damageType" of a weapon in a running game, basically by destroying and spawning a new weapon with the new damageType
-- since weapon.DynamicStats[1].DamageType is neither synced to client nor persistent in savegame

-- ##

-- local EsvReforger=Mods["SummoningImproved_Serp"].EsvReforger;
-- local char = Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb");
-- local weapon = char.Stats.MainWeapon.GameObject;
-- local damageType="Poison"
-- optional: char : the char that should get the weapon in inventory
-- optional equip : if the char should equip the new weapon
-- EsvReforger:ChangeDamageType(weapon,damageType,char,equip)


-- local EsvReforger=Mods["SummoningImproved_Serp"].EsvReforger;local char = Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb");local weapon = char.Stats.MainWeapon.GameObject;EsvReforger:SetEsvItem(weapon);EsvReforger:SetEsvDamageType("Poison");EsvReforger:Finalize(char.MyGuid);


-- ####################

-- Code extracted from Reforge Mod from Focus:  https://steamcommunity.com/sharedfiles/filedetails/?id=2812405286

--[[
    The EsvReforger makes changes to an item's stats. This is accomplished through changes to an ItemDefinition or through changes to DynamicStats.
    Changes that utilize an ItemDefinition must InitConstructor() first, make the change, and then Bake().
    Changes that utilize DynamicStats can make the change and then Bake().

    For dynamic stats, see https://github.com/Norbyte/ositools/blob/a8cf974236cf9bd3e39725dd2cc785d993e2727f/OsiInterface/Misc/ExtIdeHelpers.lua#L1147
--]]


---Helper to easily add boosts to items.
---@class Reforger
Reforger = {
    ---@type EsvItem|EclItem
    Item = nil,
}

---Creates a new Reforger object
---@param o? table
---@return Reforger
function Reforger:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---Sets an item in the reforger
---@param item EsvItem|EclItem
function Reforger:SetItem(item)
    self.Item = item
end


---Helper to easily manipulate items on the server.
---@class EsvReforger
---@type Reforger
EsvReforger = Reforger:New{
    ---@type ItemConstructor
    Constructor = nil,
    ---@type ItemDefinition
    ItemDefinition = nil,
    ---@type EsvItem
    NewItem = nil,
}

---Sets an item to be reforged
---@param item EsvItem
function EsvReforger:SetEsvItem(item)
    self:SetItem(item)
end

---Initializes a construction of a new item based on another item
function EsvReforger:InitConstructor()
    self.Constructor = self.Constructor or Ext.CreateItemConstructor(self.Item)
    self.ItemDefinition = self.ItemDefinition or self.Constructor[1]
end

---Bakes in a change to the EsvReforger's item.
function EsvReforger:Bake()
    self:InitConstructor()
    self.ItemDefinition.GMFolding = false -- This gets set to true after a Construct() call.
    self.ItemDefinition.GenerationItemType = self.ItemDefinition.ItemType -- This can drop a tier after a Construct() call.
    self.NewItem = self.Constructor:Construct()
    Osi.ItemDestroy(self.Item.MyGuid)
    self.Item = self.NewItem
    self.Constructor = nil
    self.ItemDefinition = nil
end

---Changes the damagetype of the reforger's item
---@param damageType string
function EsvReforger:SetEsvDamageType(damageType)
    self:InitConstructor()
    self.ItemDefinition.DamageTypeOverwrite = damageType
    self:Bake()
end

---Moves the reforged item to a character's inventory
---@param character string GUID
---@return EsvItem new item
function EsvReforger:Finalize(charGUID,equip)
    if equip then
      Osi.CharacterEquipItem(charGUID,self.NewItem.MyGuid)
    else
      Osi.ItemToInventory(self.NewItem.MyGuid,charGUID, 1, 0, 1)
    end
    return self.NewItem
end

-- char : the char that should get the weapon in inventory
-- optional: boolean equip : if the char should equip the new weapon (default no)
function EsvReforger:ChangeDamageType(weapon,damageType,char,equip)
  self:SetEsvItem(weapon);
  self:SetEsvDamageType(damageType);
  if char then
    self:Finalize(char.MyGuid,equip);
  end
  return self.NewItem
end

