
Ext.Require("Shared.lua")

-- TODO:
-- gameScript nochmal genauer unterscheiden zwischen:
-- Neuer Status ersetzt alten Status oder neuer Status wird durch alten Status verhindert (und verhindert und dabei selbst entfernt)


-- Modsettings dazu packen, muss client sein...

-- zu debuff den shifthalten teil fpr codename zufügen

-- Darstellung im Text evlt:
-- Status Chilled (Target)
 -- + Chilled = Frozen
 -- + Warm = - 
 
-- Status Burning (Target):
 -- + Warm = Burning (oder weglassen)
  
  
-- TODO:
-- Das was ein Status so macht doch nicht in die Tooltips schreiben (weil viel zu viel text)
-- sondern stattdessen einen Codex Eintrag im Epip Codex machen, wo alle Stati drinstehen und da ist dann der Tooltip
  
-- logik der tabelle nochmal umkehren ,damit sie auch anzeigen kann, wodurch ein effekt entfernt wird
 -- (je nach dem wie lang dann im status direkt anzeigen oder auch im codex)
  
-- und evlt text nochmal überarbeiten, vllt doch statt - - - - einfach removes X,Y,Z 
 
  
  
Ext.Require("GetSurfaces.lua") -- _GetSurfaces
Ext.Require("gameScriptStatusLogic.lua") -- GetInfoTextForStatus

-- statusses which have no stats
-- but add some known SavingThrow and ImmuneFlag and translation handle to them
local engineStatuses = {
    SOURCE_MUTED = {
        DisplayName = "h534aec4fgecc5g4b34gb0f5g8b08c3c4309e",
        SavingThrow = "MagicArmor",
        ImmuneFlag = "None"
    },
    ADRENALINE = {DisplayName = "h4c891442g3b79g4dbeg906fgf8eeffcf60df"},
    COMBAT = {},
    SPIRIT_VISION = {},
    UNSHEATHED = {},
    CHANNELING = {},
    IDENTIFY = {},
    INSURFACE = {},
    FLOATING = {DisplayName = "h278121a7g2132g4efdgb151g9af722d670dc"},
    THROWN = {DisplayName = "hfa754958gff75g4474g8cd5g508b4fb7a984",ImmuneFlag="ThrownImmunity"},
    INFUSED = {DisplayName = "hae4ca8a4g56feg480eg95c8ge5761ab1eb2e"},
    CLIMBING = {},
    CHARMED = {
        DisplayName = "h30fc0122g6378g408cgac6fg6e3bcb3c852b",
        SavingThrow = "MagicArmor",
        ImmuneFlag = "CharmImmunity"
    },
    LYING = {},
    CLEAN = {DisplayName = "h8fb688afg29efg4804g9d68g955c3c463053"},
    ACTIVE_DEFENSE = {},
    SNEAKING = {DisplayName = "h6bf7caf0g7756g443bg926dg1ee5975ee133"},
    TELEPORT_FALLING = {},
    DYING = {DisplayName = "h2e807311g8c4bg4141g85f3gcc88ee095888"},
    STORY_FROZEN = {},
    FORCE_MOVE = {},
    CONSUME = {},
    BOOST = {},
    DRAIN = {DisplayName = "h9cf08d12gc1b8g4c7cg8662g40d03ca96df5", SavingThrow = "MagicArmor", ImmuneFlag = "None"},
    LINGERING_WOUNDS = {DisplayName = "h3924a821gdb1fg4d6fg920eg62ee3c4586ed"},
    DECAYING_TOUCH = {
        DisplayName = "hbc2789fegb2deg4952ga436ga8a0aad070bf",
        SavingThrow = "PhysicalArmor",
        ImmuneFlag = "DecayingImmunity"
    },
    UNHEALABLE = {DisplayName = "hc33f0ac7gc3f0g47b3gba3cg8c3ddb82508e"},
    STANCE = {},
    INFECTIOUS_DISEASED = {
      SavingThrow = "PhysicalArmor", 
      ImmuneFlag = "InfectiousDiseasedImmunity",
      DisplayName = "h791f1994g94e9g4471g9e10g398f8d194c90"
    },
    SUMMONING = {},
    AOO = {},
    COMBUSTION = {},
    REMORSE = {DisplayName = "h7e0fe51fg9df2g4854gb8f1g183251dcc25b"},
    OVERPOWER = {},
    ENCUMBERED = {DisplayName = "hdc2c6815g4c4fg4e81g94d5g299646e91500"},
    TUTORIAL_BED = {},
    DAMAGE = {},
    FLANKED = {DisplayName = "hd052e4cfg1a83g4ee5g886cgbf15dc656a0b"},
    LEADERSHIP = {DisplayName = "h7c65fe39g1526g427bg8a2dgab7e74c66202"},
    DARK_AVENGER = {DisplayName = "h64892b81g9543g4608ga303gcffa5055d869"},
    SMELLY = {DisplayName = "h312fc6d0gd271g40ffg949dge80fba98335e"},
    MATERIAL = {},
    REPAIR = {},
    SHACKLES_OF_PAIN = {
        DisplayName = "h36a82a09gc2dag46feg990cgf3807db54d54",
        SavingThrow = "PhysicalArmor",
        ImmuneFlag = "ShacklesOfPainImmunity"
    },
    POLYMORPHED = {},
    SPIRIT = {DisplayName = "h90cedca8g690cg4aabg8df0g98da27d72991"},
    CONSTRAINED = {},
    EFFECT = {},
    EXPLODE = {},
    SPARK = {},
    SITTING = {DisplayName = "h33b529f1g6fb3g4210g8b40ga41e4d05c0d0"},
    INCAPACITATED = {},
    UNLOCK = {},
    SHACKLES_OF_PAIN_CASTER = {DisplayName = "h89ad2635gd8acg4dc1gb7f5g2287082b3733"},
    WIND_WALKER = {DisplayName = "hc7566374g36afg4345gaf18gab4ba7d7c809"},
    HIT = {},
    ROTATE = {}
}

function GetTranslation(statsid_or_handle,fallback)
  if not statsid_or_handle then
    return fallback
  end
  local loc = Ext.L10N.GetTranslatedStringFromKey(statsid_or_handle)
  if not loc or loc=="" then
    loc = Ext.L10N.GetTranslatedString(statsid_or_handle,fallback)
  end
  if not loc or loc=="" then
    loc = fallback
  end
  return loc
end

-- opener eg. = "\n<font color='#6EB09D'>Removed by Stati:</font> "
-- desctable = {{chance=100,codename="FEAR",loc="Panisch"}}
function CreateDescrString(opener,desctable,seperator)
  seperator = seperator or ", "
  local IsShift = CurrentPressedKeys["Shift"]
  local desc = opener
  local addedLocs = {}
  for _,info in ipairs(desctable) do
    local loc,codename,chance
    if type(info)=="table" then
      codename = info.codename
      loc = info.loc
      chance = info.chance
    else
      codename = info
      loc = StatusLocs[codename] 
      if not loc or loc=="" then
        local stat = not engineStatuses[codename] and Ext.Stats.Get(codename) or engineStatuses[codename]
        loc = stat and GetTranslation(stat.DisplayName,codename) or codename
      end
    end
    if not loc then
      print("CreateDescrString loc is nil?",opener,info)
    end
    if not chance or chance~=0 then
      if not addedLocs[loc] or IsShift then -- only add stati with exact same translation only once, unless we hold Shift
        local chancetxt = chance and chance<100 and " "..tostring(chance).."%" or ""
        local brackets = loc~=codename and IsShift and " ("..codename..")" or ""
        desc = desc..loc..chancetxt..brackets
        if next(desctable,_) then
          desc = desc..seperator
        end
        addedLocs[loc] = true
      end
    end
  end
  return desc
end

-- created by ChatGPT based on \Public\Shared\Scripts\Game\Statuses.gameScript
-- Scripted Status removals
-- StatusRemovesStati={WARM={"WET","CHILLED","FROZEN"},BURNING={"WARM","WET","CHILLED","FROZEN","WEB"},NECROFIRE={"WARM","BURNING","CHILLED","WET","FROZEN","HOLY_FIRE","BLESSED","QUEST_OVERGROWN","WEB"},HOLY_FIRE={"WARM","BURNING","CHILLED","WET","FROZEN","NECROFIRE","WEB"},WET={"WARM","INVISIBLE","QUEST_SUNSHINE","BURNING","HOLY_FIRE"},CHILLED={"BURNING","HOLY_FIRE","WARM","WET"},FROZEN={"CHILLED","WET","INVISIBLE","SLEEPING","MAGIC_SHELL","BURNING","HOLY_FIRE","WARM"},PETRIFIED={"MAGIC_SHELL","BLESSED","STUNNED","SHOCKED","BLEEDING","CRIPPLED","BURNING","POISONED","INVISIBLE","SLEEPING"},SHOCKED={"MAGIC_SHELL","INVISIBLE","SLEEPING"},STUNNED={"SHOCKED","PETRIFIED","WET","INVISIBLE","SLEEPING","MAGIC_SHELL","BLESSED"},DRUNK={"CLEAR_MINDED"},SLOWED={"HASTED"},HASTED={"SLOWED","CRIPPLED"},FEAR={"CLEAR_MINDED","ENRAGED","CHARMED","TAUNTED","SLEEPING","MADNESS"},CHARMED={"CLEAR_MINDED","ENRAGED","FEAR","TAUNTED","SLEEPING","MADNESS"},TAUNTED={"INVISIBLE","CLEAR_MINDED","ENRAGED","CHARMED","FEAR","SLEEPING","MADNESS"},SLEEPING={"INVISIBLE","CLEAR_MINDED","ENRAGED","CHARMED","TAUNTED","FEAR","MADNESS"},MADNESS={"CLEAR_MINDED"},CLEAR_MINDED={"FEAR","CHARMED","TAUNTED","SLEEPING","ENRAGED","BLIND","DRUNK","MADNESS"},ENRAGED={"FEAR","CHARMED","TAUNTED","SLEEPING","MADNESS","CLEAR_MINDED"},RESTED={"MUTED","BLIND","CRIPPLED","KNOCKED_DOWN","BLEEDING","PLAGUE","INFESTED"},MUTED={"RESTED"},BLIND={"RESTED"},CRIPPLED={"RESTED","HASTED"},KNOCKED_DOWN={"INVISIBLE","SLEEPING","RESTED"},REGENERATION={"ACID","POISONED","BLEEDING","SUFFOCATING","BURNING","INFESTED"},FORTIFIED={"ACID","POISONED","BURNING","BLEEDING","DISEASED","INFECTIOUS_DISEASED","DECAYING_TOUCH"},ACID={"FORTIFIED"},BLEEDING={"REGENERATION","FORTIFIED"},BLESSED={"DISEASED","INFECTIOUS_DISEASED","DECAYING_TOUCH","PETRIFIED","STUNNED","FROZEN","INFESTED","PLAGUE","BURNING","NECROFIRE","CURSED","VOIDHOWL"},MAGIC_SHELL={"FROZEN","STUNNED","PETRIFIED","PLAGUE","SUFFOCATING","POISONED","BURNING"},CURSED={"BLESSED","CHILLED","QUEST_OVERGROWN","BURNING","WARM","HOLY_FIRE"},DISEASED={"FORTIFIED","BLESSED"},INFECTIOUS_DISEASED={"FORTIFIED","BLESSED"},DECAYING_TOUCH={"FORTIFIED","BLESSED"},INVISIBLE={"WET"},CHICKEN={"WINGS"},HEALING_ELIXIR={"WEAK","SLOWED","DISEASED","POISONED","BLEEDING","CRIPPLED","CURSED","CHILLED","DRUNK","BURNING","NECROFIRE","ACID","SUFFOCATING","DECAYING_TOUCH","INFECTIOUS_DISEASED","PLAGUE"},CHAIN_HEAL={"INFESTED"},CLEANSE_WOUNDS={"INFESTED","PLAGUE","DISEASED","INFECTIOUS_DISEASED"},STEAM_LANCE={"FROZEN","CHILLED","DISEASED","INFECTIOUS_DISEASED","DECAYING_TOUCH","PLAGUE","INFESTED"},WEB={"HASTED"},SPIDER_LEGS={"WEB"}}
-- StatusRemovedByStatiWithWorseStatus={FROZEN={"WARM","NECROFIRE","BURNING","STEAM_LANCE","MAGIC_SHELL","HOLY_FIRE","BLESSED"},BLESSED={"STUNNED","INFECTIOUS_DISEASED","PETRIFIED","NECROFIRE","DECAYING_TOUCH","DISEASED","CURSED"},WEAK={"HEALING_ELIXIR"},STUNNED={"PETRIFIED","MAGIC_SHELL","BLESSED"},RESTED={"KNOCKED_DOWN","MUTED","CRIPPLED","BLIND"},INVISIBLE={"FROZEN","STUNNED","KNOCKED_DOWN","PETRIFIED","TAUNTED","SHOCKED","SLEEPING","WET"},KNOCKED_DOWN={"RESTED"},PLAGUE={"CLEANSE_WOUNDS","RESTED","STEAM_LANCE","HEALING_ELIXIR","MAGIC_SHELL","BLESSED"},MUTED={"RESTED"},HASTED={"SLOWED","CRIPPLED","WEB"},INFECTIOUS_DISEASED={"CLEANSE_WOUNDS","STEAM_LANCE","HEALING_ELIXIR","BLESSED","FORTIFIED"},SLOWED={"HASTED","HEALING_ELIXIR"},PETRIFIED={"STUNNED","MAGIC_SHELL","BLESSED"},SUFFOCATING={"HEALING_ELIXIR","MAGIC_SHELL","REGENERATION"},TAUNTED={"CLEAR_MINDED","FEAR","CHARMED","SLEEPING","ENRAGED"},CRIPPLED={"RESTED","HASTED","PETRIFIED","HEALING_ELIXIR"},BLIND={"RESTED","CLEAR_MINDED"},CLEAR_MINDED={"DRUNK","TAUNTED","FEAR","CHARMED","SLEEPING","MADNESS","ENRAGED"},FEAR={"TAUNTED","CLEAR_MINDED","CHARMED","SLEEPING","ENRAGED"},BURNING={"FROZEN","PETRIFIED","NECROFIRE","CHILLED","HEALING_ELIXIR","MAGIC_SHELL","CURSED","HOLY_FIRE","BLESSED","FORTIFIED","REGENERATION","WET"},QUEST_SUNSHINE={"WET"},CHARMED={"TAUNTED","CLEAR_MINDED","FEAR","SLEEPING","ENRAGED"},CHILLED={"FROZEN","WARM","NECROFIRE","BURNING","STEAM_LANCE","HEALING_ELIXIR","CURSED","HOLY_FIRE","WET"},WINGS={"CHICKEN"},WEB={"SPIDER_LEGS","NECROFIRE","BURNING","HOLY_FIRE"},BLEEDING={"RESTED","PETRIFIED","HEALING_ELIXIR","FORTIFIED","REGENERATION"},VOIDHOWL={"BLESSED"},WARM={"FROZEN","WARM","NECROFIRE","BURNING","CHILLED","CURSED","HOLY_FIRE","WET"},NECROFIRE={"HEALING_ELIXIR","HOLY_FIRE","BLESSED"},CURSED={"HEALING_ELIXIR","BLESSED"},DECAYING_TOUCH={"STEAM_LANCE","HEALING_ELIXIR","BLESSED","FORTIFIED"},MAGIC_SHELL={"FROZEN","STUNNED","PETRIFIED","SHOCKED"},REGENERATION={"BLEEDING"},DRUNK={"CLEAR_MINDED","HEALING_ELIXIR"},QUEST_OVERGROWN={"NECROFIRE","CURSED"},SHOCKED={"STUNNED","PETRIFIED","WET"},HOLY_FIRE={"FROZEN","NECROFIRE","CHILLED","CURSED","WET"},DISEASED={"CLEANSE_WOUNDS","STEAM_LANCE","HEALING_ELIXIR","BLESSED","FORTIFIED"},INFESTED={"CLEANSE_WOUNDS","RESTED","CHAIN_HEAL","STEAM_LANCE","BLESSED","REGENERATION"},ACID={"HEALING_ELIXIR","FORTIFIED","REGENERATION"},SLEEPING={"FROZEN","STUNNED","KNOCKED_DOWN","PETRIFIED","TAUNTED","CLEAR_MINDED","FEAR","CHARMED","SHOCKED","ENRAGED"},FORTIFIED={"INFECTIOUS_DISEASED","BLEEDING","DECAYING_TOUCH","DISEASED","ACID"},POISONED={"PETRIFIED","HEALING_ELIXIR","MAGIC_SHELL","FORTIFIED","REGENERATION"},WET={"FROZEN","STUNNED","WARM","NECROFIRE","BURNING","CHILLED","INVISIBLE","HOLY_FIRE"},MADNESS={"TAUNTED","CLEAR_MINDED","FEAR","CHARMED","SLEEPING","ENRAGED"},ENRAGED={"TAUNTED","CLEAR_MINDED","FEAR","CHARMED","SLEEPING"}}
StatusRemovedByStati={FROZEN={"WARM","NECROFIRE","BURNING","STEAM_LANCE","MAGIC_SHELL","HOLY_FIRE","BLESSED"},BLESSED={"STUNNED","INFECTIOUS_DISEASED","PETRIFIED","NECROFIRE","DECAYING_TOUCH","DISEASED","CURSED"},WEAK={"HEALING_ELIXIR"},STUNNED={"PETRIFIED","MAGIC_SHELL","BLESSED"},RESTED={"KNOCKED_DOWN","MUTED","CRIPPLED","BLIND"},INVISIBLE={"FROZEN","STUNNED","KNOCKED_DOWN","PETRIFIED","TAUNTED","SHOCKED","SLEEPING","WET"},KNOCKED_DOWN={"RESTED"},PLAGUE={"CLEANSE_WOUNDS","RESTED","STEAM_LANCE","HEALING_ELIXIR","MAGIC_SHELL","BLESSED"},MUTED={"RESTED"},HASTED={"SLOWED","CRIPPLED","WEB"},INFECTIOUS_DISEASED={"CLEANSE_WOUNDS","STEAM_LANCE","HEALING_ELIXIR","BLESSED","FORTIFIED"},SLOWED={"HASTED","HEALING_ELIXIR"},PETRIFIED={"STUNNED","MAGIC_SHELL","BLESSED"},SUFFOCATING={"HEALING_ELIXIR","MAGIC_SHELL","REGENERATION"},TAUNTED={"CLEAR_MINDED","FEAR","CHARMED","SLEEPING","ENRAGED"},CRIPPLED={"RESTED","HASTED","PETRIFIED","HEALING_ELIXIR"},BLIND={"RESTED","CLEAR_MINDED"},CLEAR_MINDED={"DRUNK","TAUNTED","FEAR","CHARMED","SLEEPING","MADNESS","ENRAGED"},FEAR={"TAUNTED","CLEAR_MINDED","CHARMED","SLEEPING","ENRAGED"},BURNING={"FROZEN","PETRIFIED","CHILLED","HEALING_ELIXIR","MAGIC_SHELL","HOLY_FIRE","BLESSED","FORTIFIED","REGENERATION","WET"},QUEST_SUNSHINE={"WET"},CHARMED={"TAUNTED","CLEAR_MINDED","FEAR","SLEEPING","ENRAGED"},CHILLED={"WARM","STEAM_LANCE","HEALING_ELIXIR","HOLY_FIRE","WET"},WINGS={"CHICKEN"},WEB={"SPIDER_LEGS","NECROFIRE","BURNING","HOLY_FIRE"},BLEEDING={"RESTED","PETRIFIED","HEALING_ELIXIR","FORTIFIED","REGENERATION"},VOIDHOWL={"BLESSED"},WARM={"WARM","CHILLED","HOLY_FIRE","WET"},NECROFIRE={"HEALING_ELIXIR","HOLY_FIRE","BLESSED"},CURSED={"HEALING_ELIXIR","BLESSED"},DECAYING_TOUCH={"STEAM_LANCE","HEALING_ELIXIR","BLESSED","FORTIFIED"},MAGIC_SHELL={"FROZEN","STUNNED","PETRIFIED","SHOCKED"},REGENERATION={"BLEEDING"},DRUNK={"CLEAR_MINDED","HEALING_ELIXIR"},QUEST_OVERGROWN={"NECROFIRE","CURSED"},SHOCKED={"STUNNED","PETRIFIED"},HOLY_FIRE={"FROZEN","NECROFIRE","CHILLED","CURSED","WET"},DISEASED={"CLEANSE_WOUNDS","STEAM_LANCE","HEALING_ELIXIR","BLESSED","FORTIFIED"},INFESTED={"CLEANSE_WOUNDS","RESTED","CHAIN_HEAL","STEAM_LANCE","BLESSED","REGENERATION"},ACID={"HEALING_ELIXIR","FORTIFIED","REGENERATION"},SLEEPING={"FROZEN","STUNNED","KNOCKED_DOWN","PETRIFIED","TAUNTED","CLEAR_MINDED","FEAR","CHARMED","SHOCKED","ENRAGED"},FORTIFIED={"INFECTIOUS_DISEASED","BLEEDING","DECAYING_TOUCH","DISEASED","ACID"},POISONED={"PETRIFIED","HEALING_ELIXIR","MAGIC_SHELL","FORTIFIED","REGENERATION"},WET={"STUNNED","WARM","CHILLED","INVISIBLE","HOLY_FIRE"},MADNESS={"TAUNTED","CLEAR_MINDED","FEAR","CHARMED","SLEEPING","ENRAGED"},ENRAGED={"TAUNTED","CLEAR_MINDED","FEAR","CHARMED","SLEEPING"}}
StatusCleansedBySkills = {} -- will be filled StatsLoaded
SkillCleanseStati = {} -- doing this skill on a target, will remove the stati from the target, will be filled StatsLoaded


local function deepcopy(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      if copies[orig] then
          copy = copies[orig]
      else
          copy = {}
          copies[orig] = copy
          for orig_key, orig_value in next, orig, nil do
              copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
          end
          setmetatable(copy, deepcopy(getmetatable(orig), copies))
      end
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

-- ###########################################################################
-- ###########################################################################
-- ###########################################################################


-- current version of Epip is preventing Game.Tooltip.Register.Surface from working, but using the one from Epip itself works
local EpipSurfaceTooltips = Mods and Mods.EpipEncounters and Mods.EpipEncounters.Client.Tooltip.Hooks.RenderSurfaceTooltip

local MissingExtenderSurfaces = {DeathfogCloud="c651b724-32e2-4e34-99b4-272826ac3e37"} -- or must change it to "Deathfog" instead

-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

---@param o1 any|table First object to compare
---@param o2 any|table Second object to compare
-- ignores metatables
local function equals(o1, o2)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end
    local keySet = {}
    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2) == false then
            return false
        end
        keySet[key1] = true
    end
    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

-- Osi.GetSurfaceNameByTypeIndex is not available on client..
local function _GetSurfaceNameByTypeIndex(s_index)
  return Ext.Enums.SurfaceType[s_index] and tostring(Ext.Enums.SurfaceType[s_index]) or "Unknown"
  -- for index,surface in pairs(Ext.Enums.SurfaceType) do
    -- print("_GetSurfaceNameByTypeIndex iterating..",surface,index,type(s_index),type(index))
    -- if s_index==index then
      -- return tostring(surface)
    -- end
  -- end
  -- return "Unknown"
end

-- Epip uses skill tooltips to display some tooltips, ignore them by checking if the tooltip has Cooldown
-- must load after Epip to notice this
local function IsValidSkillTooltip(tooltip)
  if tooltip and tooltip.Data then
    for _, entry in ipairs(tooltip.Data) do
      if entry["Type"]=="SkillCooldown" then
        return true
      end
    end
  end
  return false
end

-- Tooltip improvements
-- Game.Tooltip.Register
-- {
	-- "Ability" : "function: 00007FF473BEFE28",
	-- "CustomStat" : "function: 00007FF473C74848",
	-- "Generic" : "function: 00007FF473C74870",
	-- "Global" : "function: 00007FF473BEFE00",
	-- "Item" : "function: 00007FF473C74898",
	-- "PlayerPortrait" : "function: 00007FF473C748C0",
	-- "Pyramid" : "function: 00007FF473C748E8",
	-- "Rune" : "function: 00007FF473C74910",
	-- "Skill" : "function: 00007FF473C74938",
	-- "Stat" : "function: 00007FF473C74960",
	-- "Status" : "function: 00007FF473C74988",
	-- "Surface" : "function: 00007FF473C749B0",
	-- "Tag" : "function: 00007FF473C749D8",
	-- "Talent" : "function: 00007FF473C74A00",
	-- "World" : "function: 00007FF473C74A28"
-- }


-- Item Tooltip
-- [
	-- {
		-- "Label" : "<font color=\"#ffffff\">Kleiner Heiltrank</font> ",
		-- "Type" : "ItemName"
	-- },
	-- {
		-- "Label" : "0.25",
		-- "Type" : "ItemWeight"
	-- },
	-- {
		-- "Label" : "<font color=\"#C7A758\">20</font>",
		-- "Type" : "ItemGoldValue"
	-- },
	-- {
		-- "Label" : "Trank, der deine Lebenskraft wiederherstellt. Klimpert leise, wenn man ihn sch\u00fcttelt.",
		-- "Type" : "ItemDescription"
	-- },
	-- {
		-- "Label" : "Verzehren",
		-- "RequirementMet" : true,
		-- "Type" : "ItemUseAPCost",
		-- "Value" : 1.0
	-- },
	-- {
		-- "Label" : "Heilt 30 Lebenskraft.",
		-- "Type" : "ConsumableEffect",
		-- "Value" : ""
	-- }
-- ]

-- Add StackId to Foods/Potions
-- add applies effects to items (potions)
-- Osi.ItemTemplateAddTo("37535d5c-3262-4d2d-bcbc-c940e33ec2ca",Osi.CharacterGetHostCharacter(),1,1) -- healing elixir
Game.Tooltip.Register.Item(function(item,tooltip)
  -- _D(item)
  local addstringtodesc = ""

  local ExtraProperties = item.StatsFromName.PropertyLists and item.StatsFromName.PropertyLists.ExtraProperties and item.StatsFromName.PropertyLists.ExtraProperties.Properties and item.StatsFromName.PropertyLists.ExtraProperties.Properties.Elements
  local appliesStati = {}
  local createssurfaces = {}
  if ExtraProperties then
    for _,property in ipairs(ExtraProperties) do
      if property.TypeId=="Status" then
        local Context = {"Self"} -- I think these effects are always Self, regardless what is written in them
        appliesStati[property.Status] = {chance=property.StatusChance*100,duration=property.Duration,Context=Context}
      end
    end
  end
  if item.CurrentTemplate and item.CurrentTemplate.OnUsePeaceActions then
    for _,useaction in pairs(item.CurrentTemplate.OnUsePeaceActions) do
      if useaction.Type=="UseSkill" then
        local skill = useaction.SkillID
        local skilldesc = CreateSkillToolipAddition(skill)
        AddToTooltip(tooltip,skilldesc)
      end
    end
  end
  
  
  for status,info in pairs(appliesStati) do
    local chance = info.chance
    local duration = info.duration
    local Context = info.Context
    local stat = not engineStatuses[status] and Ext.Stats.Get(status) or engineStatuses[status]
    local status_loc = StatusLocs[status] or stat and GetTranslation(stat.DisplayName,status) or status
    if chance and chance>0 then
      local codename = " ("..status..") "
      if StatusScriptRules[status] then
        addstringtodesc = addstringtodesc..CreateStatusTooltip(status,Context)
      end
      if next(appliesStati,status) then
        addstringtodesc = addstringtodesc.." | "
      end
    end
  end
  
  if item and item.StatsFromName and item.StatsFromName.ModifierList=="Potion" then
    local StackId = item.StatsFromName.StatsEntry.StackId
    local StackPriority = item.StatsFromName.StatsEntry.Priority
    local ObjectCategory = item.StatsFromName.StatsEntry.ObjectCategory
    local Duration = item.StatsFromName.StatsEntry.Duration
    if StackId and StackId~="" and Duration>0 then
      addstringtodesc = addstringtodesc.."\n(StackId: "..tostring(StackId).." Category:"..tostring(ObjectCategory).." "..tostring(StackPriority)..")"
    end
  end
  
  -- print("Tooltip Item:",addstringtodesc)
  if addstringtodesc~="" then
    local found = false
    for __,tentry in ipairs(tooltip.Data) do
      if tentry.Type=="SkillDescription" then -- adding to SkillDescription instead of ItemDescription, because ItemDescription is on the bottom, which looks bad
        tentry.Label = tentry.Label..addstringtodesc
        found = true
        break
      end
    end
    if not found then
      local entry = {Type="SkillDescription",Label=addstringtodesc}
      table.insert(tooltip.Data,entry)
    end
  end
end)

function CreateCreatesSurfaceTooltip(surfaceinfo)
  local SurfaceRadius = surfaceinfo.SurfaceRadius
  local SurfaceLifetime = surfaceinfo.SurfaceLifetime
  local SurfaceType = surfaceinfo.SurfaceType
  local SurfaceStatusChance = surfaceinfo.SurfaceStatusChance
  local SurfaceText = ""
  if SurfaceRadius and SurfaceRadius>0 then -- else it will be the AreaRadius/affected radius of the skill
    SurfaceText = SurfaceText.."SurfaceRadius: "..tostring(SurfaceRadius).." m\n"
  end
  if SurfaceLifetime and SurfaceLifetime>0 then
    SurfaceText = SurfaceText.."SurfaceLifetime: "..tostring(round(SurfaceLifetime/6,1)).." turns\n"
  elseif SurfaceType~="DamageType" then
    local SurfaceTypeForTemplate = SurfaceType=="DeathfogCloud" and "Deathfog" or SurfaceType
    local status,template = pcall(Ext.Surface.GetTemplate,SurfaceTypeForTemplate) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
    if status==false and MissingExtenderSurfaces[SurfaceType] then
      template = Ext.Template.GetTemplate(MissingExtenderSurfaces[SurfaceType])
      if not template then
        Ext.Print("ImprovedTooltips: Surface.GetTemplate faild (add it manually to MissingExtenderSurfaces) to get template for:",SurfaceType)
      end
    end
    if template then
      local DefaultLifeTime = template.DefaultLifeTime
      if DefaultLifeTime and DefaultLifeTime>0 then
        SurfaceText = SurfaceText.."SurfaceLifetime: "..tostring(round(DefaultLifeTime/6,1)).." turns\n"
      end
    end
  end
  if SurfaceStatusChance and SurfaceStatusChance>0 then
    SurfaceText = SurfaceText.."SurfaceStatusChance: "..tostring(SurfaceStatusChance).." %"
  end
  return SurfaceText
end

function CreateStatusTooltip(status,Context,withoutheader,prefix)
  -- Adding info what the applied appliedstati may cleanse (chance and duration is already in tooltip)
  prefix = prefix or ""
  local desc = ""
  local stat = not engineStatuses[status] and Ext.Stats.Get(status) or engineStatuses[status]
  local status_loc = StatusLocs[status] or stat and GetTranslation(stat.DisplayName,status) or status
  local codename = " ("..status..") "
  if not withoutheader then
    desc = desc.."\n"..prefix.."<font color='#6EB09D'>Status "..status_loc..(CurrentPressedKeys["Shift"] and codename or "").."</font> "..(Context and "("..table.concat(Context,",")..")" or "")
  end
  if StatusScriptRules[status] then
    desc = desc.."\n".."<font color='#D2D2D2'>"..GetInfoTextForStatus(status,StatusLocs," ").."</font>"
  end
  if StatusProvidesImmunityAgainstStati[status] then
    local opener = "\n"..prefix.."<font color='#6EB09D'>Provides Immunities</font>: "
    desc = desc..CreateDescrString(opener,StatusProvidesImmunityAgainstStati[status])
  end
  -- StackId
  if not engineStatuses[status] then
    local stat = Ext.Stats.Get(status)
    if stat then
      local StackId = stat.StackId
      local StackPriority = stat.StackPriority
      if StackId and StackId~="" then
        desc = desc.."\n"..prefix.."(StackId: "..tostring(StackId).." "..tostring(StackPriority)..")"
      end
    end
  end
  return desc
end

function CreateSkillToolipAddition(skill,char)
  local skilldesc = {}
  local MyStat = Ext.Stats.Get(skill)
  if MyStat then
    local AreaRadius = MyStat.AreaRadius
    -- Info about surface a skill creates
    local createssurfaces = {}
    local appliedstati = {}
    local SkillProperties = MyStat["SkillProperties"] -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
    if SkillProperties and type(SkillProperties)=="table" then
      -- Ext.Print("ImprovedTooltips Skill Tooltip SkillProperties",skill,_D(SkillProperties))
    -- [{	"Action" : "CreateSurface",
    -- "Arg1" : 3.0,
    -- "Arg2" : 0.0,
    -- "Arg3" : "Oil",
    -- "Arg4" : 1.0,
    -- "Arg5" : 0.0,
    -- "Context" : ["Target","AoE"],
    -- "StatusHealType" : "None",
    -- "Type" : "GameAction"}]
    -- Shout_PoisonWave
    -- [{"Action" : "TargetCreateSurface",
      -- "Arg1" : 4.0,
      -- "Arg2" : 0.0,
      -- "Arg3" : "PoisonCloud",
      -- "Arg4" : 1.0,
      -- "Arg5" : 1.0,
      -- "Context" :
      -- ["Self"],
      -- "StatusHealType" : "None",
      -- "Type" : "GameAction"}]
      -- Encourage:
        -- {"Action" : "ENCOURAGED2",
        -- "Arg4" : -1,
        -- "Arg5" : -1,
        -- "Context" :["Target","AoE"],
        -- "Duration" : 18.0,
        -- "StatsId" : "",
        -- "StatusChance" : 1.0,
        -- "SurfaceBoost" : false,
        -- "SurfaceBoosts" : {},
        -- "Type" : "Status"}
        -- {"Action" : "TryKill",
              -- "Arg4" : 10,
              -- "Arg5" : -1,
              -- "Context" :["Target","AoE"],
              -- "Duration" : 6.0,
              -- "StatsId" : "FROZEN",
              -- "StatusChance" : 1.0,
              -- "SurfaceBoost" : false,
              -- "SurfaceBoosts" : {},
              -- "Type" : "Status"}
      for _,entry in pairs(SkillProperties) do
        if entry.Type=="GameAction" and (entry.Action=="CreateSurface" or entry.Action=="TargetCreateSurface") then
          table.insert(createssurfaces,{SurfaceType=entry.Arg3,SurfaceLifetime=entry.Arg2~=0 and entry.Arg2/6,SurfaceRadius=entry.Arg1,SurfaceStatusChance=nil})
        elseif entry.Type=="Status" and entry.StatsId=="" then
          local status = entry.Action
          local Context = {} -- transform from lightC to table
          for k,v in pairs(entry.Context) do
            if v~="AoE" or (AreaRadius and AreaRadius>0) then -- not including AoE if it has no AreaRadius
              Context[k]=v
            end
          end
          table.insert(appliedstati,{status=status,Context=Context})
        end
      end
    end
    -- [{"Label" : "Ermutigung",
              -- "Type" : "SkillName"},
      -- {"Label" : "Skill_Warrior_Inspire",
              -- "Type" : "SkillIcon"},
      -- {"Icon" : 2.0,
              -- "Label" : "<font color=\"#DA2512\">Kriegf\u00fchrung</font>",
              -- "Type" : "SkillSchool"},
      -- {"Label" : "Novize",
              -- "Type" : "SkillTier"},
      -- {"Label" : "Erfordert Kriegf\u00fchrung 1<br>",
              -- "RequirementMet" : true,
              -- "Type" : "SkillRequiredEquipment"},
      -- {"Label" : "Benutzen",
              -- "RequirementMet" : true,
              -- "Type" : "SkillAPCost",
              -- "Value" : 1.0,
              -- "Warning" : ""},
      -- {"Label" : "Abklingzeit",
              -- "Type" : "SkillCooldown",
              -- "Value" : 6.0,
              -- "ValueText" : "6 Runde(n)",
              -- "Warning" : ""},
      -- {"Label" : "Ermutigt Verb\u00fcndete in deiner N\u00e4he.",
              -- "Type" : "SkillDescription"},
      -- {
          -- "Properties" :
          -- [
                          -- {
                                  -- "Label" : "Lege Combo Bonus II f\u00fcr 2 Runde(n) fest.",
                                  -- "Warning" : ""
                          -- },
                          -- {
                                  -- "Label" : "Lege Second Impact Chain f\u00fcr 2 Runde(n) fest.",
                                  -- "Warning" : ""
                          -- },
                          -- {
                                  -- "Label" : "Der Schaden basiert auf deinem Basisangriff plus Bonus durch Finesse.",
                                  -- "Warning" : ""
                          -- }
                  -- ],
                  -- "Resistances" : {},
                  -- "Type" : "SkillProperties"
          -- }]
    local addcleansestringtoskill = ""
    for i,info in ipairs(appliedstati) do
      local status = info.status
      local Context = info.Context or {}
      addcleansestringtoskill = addcleansestringtoskill..CreateStatusTooltip(status,Context)
    end
    -- add info to skills which stati they clean (is hardcoded in vanilla text...)
    local skillcleantext = ""
    if SkillCleanseStati[skill] and SkillCleanseStati[skill].stati and next(SkillCleanseStati[skill].stati) and SkillCleanseStati[skill].chance>0 then
      local chancetxt = SkillCleanseStati[skill].chance<100 and "("..tostring(SkillCleanseStati[skill].chance).."%) " or ""
      local opener = "\n<font color='#6EB09D'>Cleanse Stati</font>"..chancetxt..": "
      skillcleantext = CreateDescrString(opener,SkillCleanseStati[skill].stati)
    end
    
    skilldesc["SkillDescription"] = (skilldesc["SkillDescription"] or {})
    table.insert(skilldesc["SkillDescription"],{Label=skillcleantext..addcleansestringtoskill,firstfound=true})
    
    
    local StatSurfaceType = MyStat.SurfaceType
    if StatSurfaceType and StatSurfaceType~="None" then
      table.insert(createssurfaces,{SurfaceType=StatSurfaceType,SurfaceLifetime=MyStat.SurfaceLifetime,SurfaceRadius=MyStat.SurfaceRadius,SurfaceStatusChance=MyStat.SurfaceStatusChance})
    end
    for _,surfaceinfo in ipairs(createssurfaces) do
      local SurfaceType = surfaceinfo.SurfaceType
      local SurfaceText = CreateCreatesSurfaceTooltip(surfaceinfo)
      skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
      table.insert(skilldesc["SkillExplodeRadius"],{Label="<font color='#6EB09D'>Creates Surface</font> "..tostring(SurfaceType).."\n"..SurfaceText,createnewentry=true})
    end
    
    local TargetConditions = MyStat["TargetConditions"]
    if TargetConditions then
      TargetConditions = TargetConditions:gsub("&!Spirit", "") -- remove this because true for nearly all skills
      TargetConditions = TargetConditions:gsub("!Spirit", "")
      if TargetConditions=="" then
        TargetConditions = "All"
      end
      local CanTarget = {}
      if MyStat.CanTargetCharacters=="Yes" then
        table.insert(CanTarget,"Char")
      end
      if MyStat.CanTargetTerrain=="Yes" then
        table.insert(CanTarget,"Ground")
      end
      if MyStat.CanTargetItems=="Yes" then
        table.insert(CanTarget,"Item")
      end
      local AreaRadius = MyStat.AreaRadius
      AreaRadius = AreaRadius and AreaRadius>0 and tostring(AreaRadius) or ""
      if AreaRadius~="" then
        skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
        table.insert(skilldesc["SkillExplodeRadius"],{Value=tostring(AreaRadius).."m",Label="Area Radius:",createnewentry=true})
        -- local entry = {Type="SkillExplodeRadius",Value=tostring(AreaRadius).."m",Label="Area Radius:"} -- will display 2 times SkillExplodeRadius if it also has a vanilla exploderadius
        -- table.insert(tooltip.Data,entry)
      end
      local GroundSkillTypes = {"Path","Rain","Cone","Dome","Jump","Quake","Shout","Storm","Summon","Tornado","Wall","Zone"}
      if table_contains_value(GroundSkillTypes,MyStat.SkillType) then
        if not table_contains_value(CanTarget,"Ground") then
          table.insert(CanTarget,"Ground")
        end
      end
      
      skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
      table.insert(skilldesc["SkillExplodeRadius"],{Label="Target Conditions: "..TargetConditions,createnewentry=true}) -- not using Value here, because it is limited in characters, to many will not be displayed
      -- local entry = {Type="SkillExplodeRadius",Label="Target Conditions: "..TargetConditions} -- not using Value here, because it is limited in characters, to many will not be displayed
      -- table.insert(tooltip.Data,entry)
      if #CanTarget>0 then
        skilldesc["SkillExplodeRadius"] = (skilldesc["SkillExplodeRadius"] or {})
        table.insert(skilldesc["SkillExplodeRadius"],{Value=table.concat(CanTarget, ","),Label="Can Target:",createnewentry=true}) -- not using Value here, because it is limited in characters, to many will not be displayed
        -- local entry = {Type="SkillExplodeRadius",Value=table.concat(CanTarget, ","),Label="Can Target:"} -- will display 2 times SkillExplodeRadius if it also has a vanilla exploderadius
        -- table.insert(tooltip.Data,entry)
      end    
    end
    
    
    if char and char.SkillManager.Skills[skill] then
      local cooldownleft = char.SkillManager.Skills[skill].ActiveCooldown -- in seconds, not turns. 1 turn=6 seconds
      if cooldownleft~=0 then
        cooldownleft = tostring( math.ceil(cooldownleft / 6) )
        skilldesc["SkillRequiredEquipment"] = (skilldesc["SkillRequiredEquipment"] or {})
        table.insert(skilldesc["SkillRequiredEquipment"],{Label="("..cooldownleft..") ",createnewentry=false,addinfront=true,firstfound=true})
      end
    end
      
      -- for _, entry in ipairs(tooltip.Data) do -- display left cooldown in tooltip, because icon does not display properly for higher than 99
        -- if entry.Type=="SkillRequiredEquipment" and entry.RequirementMet==false and char.SkillManager.Skills[skill] then
          -- local cooldownleft = char.SkillManager.Skills[skill].ActiveCooldown -- in seconds, not turns. 1 turn=6 seconds
          -- if cooldownleft~=0 then
            -- cooldownleft = tostring( math.ceil(cooldownleft / 6) )
            -- entry.Label = "("..cooldownleft..") "..entry.Label
          -- end
        -- end
      -- end
  end
  return skilldesc
end

local function _AddToTooltip(tooltip,Type,info)
  if info.createnewentry then
    local entry = {Type=Type,Value=info.Value,Label=info.Label}
    table.insert(tooltip.Data,entry)
  else
    for _,entry in ipairs(tooltip.Data) do
      -- print("_AddToTooltip",entry.Type,Type,info.Label)
      if entry.Type==Type  then
        if info.Value then
          if info.addinfront then
            entry.Value = info.Value..entry.Value
          else
            entry.Value = entry.Value..info.Value
          end
        end
        if info.Label then
          if info.addinfront then
            entry.Label = info.Label..entry.Label
          else
            entry.Label = entry.Label..info.Label
          end
        end
        if info.firstfound then
          break
        end
      end
    end
  end
end
function AddToTooltip(tooltip,desctable)
  for Type,infos in pairs(desctable) do
    for _,info in ipairs(infos) do
      _AddToTooltip(tooltip,Type,info)
    end
  end
end

-- Improve skill tooltips
-- Add Info about who can be targeted with a Skill
-- using color does not seem to work.. <font color='5ec2ffff'>
Game.Tooltip.Register.Skill(function(char, skill, tooltip)
  if IsValidSkillTooltip(tooltip) then
    local skilldesc = CreateSkillToolipAddition(skill,char)
    AddToTooltip(tooltip,skilldesc)
  end
end)


-- Surface Tooltip anpassen:
-- 1) Wasserschaden header von wasserfläche in Wasser umwandeln
-- 2) Stati die verursacht werden können mit Chance zufügen
-- Statuschance can be overriden by skill which caused it with SurfaceType SurfaceStatusChance, dont think we can catch it here..
local previoustooltipdata = nil
local previoussurface = nil
function AdjustSurfaceTooltip(SurfaceType,tooltip)
  if SurfaceType and SurfaceType~="Unknown" then
    -- print(SurfaceType)
    -- _D(tooltip.Data)
    
    local issecondsurfaceofdouble = false -- Game.Tooltip.Register.Surface gets complicated for double surfaces, because its called twice, but tooltip.data already contains both surfaces
    if equals(previoustooltipdata,tooltip.Data) and previoussurface~=SurfaceType then
      issecondsurfaceofdouble = true
      -- print("issecondsurfaceofdouble",previoussurface,SurfaceType)
    end
    
    -- fix german surface titles saying "Water Damage" instead of "Water" (Wasserschaden instead of Wasser)
    for _,entry in ipairs(tooltip.Data) do
      if entry.Type=="Title" and entry.Label:find("schaden",1,true) then
        entry.Label = entry.Label:gsub("schaden","") -- remove the word "schaden" from the title of surfaces
      end
    end
    
    -- add status
    local status,template = pcall(Ext.Surface.GetTemplate,SurfaceType) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
    if status==false and MissingExtenderSurfaces[SurfaceType] then
      template = Ext.Template.GetTemplate(MissingExtenderSurfaces[SurfaceType])
      if not template then
        Ext.Print("ImprovedTooltips: Surface.GetTemplate failed (add it manually to MissingExtenderSurfaces) to get template for:",SurfaceType)
      end
    end
    if template then
      local Statuses = template.Statuses
      if Statuses then
        SurfaceStatusText = ""
        for _,statusinfo in pairs(Statuses) do
          if (statusinfo.StatusId~="FOGBLIND_SERP" or statusinfo.RemoveStatus==false) and statusinfo.ApplyToCharacters then -- I added in my mod MoreSurfaceEffects to all surfaces that they remove my status, that is not important to show
            local SStat = not engineStatuses[statusinfo.StatusId] and Ext.Stats.Get(statusinfo.StatusId) or engineStatuses[statusinfo.StatusId]
            local statusname_loc = SStat and GetTranslation(SStat.DisplayName,statusinfo.StatusId) or statusinfo.StatusId
            addremove = "\n<font color='#6EB09D'>"..(statusinfo.RemoveStatus and "Removes " or "Applies ").." "..statusname_loc..(CurrentPressedKeys["Shift"] and statusinfo.StatusId or "").."</font>"
            local IgnoresArmor = statusinfo.ForceStatus and "\n  Ignores Armor" or ""
            local KeepAlive = statusinfo.KeepAlive and "\n  Stays Active" or ""
            local OnlyWhileMoving = statusinfo.OnlyWhileMoving and "\n  Only While Moving" or ""
            local VanishOnReapply = statusinfo.VanishOnReapply and "\n  Removes Surface" or ""
            SurfaceStatusText = SurfaceStatusText..addremove.."\n  Chance: "..tostring(round(statusinfo.Chance*100,2)).." %\n  Duration: "..tostring(round(statusinfo.Duration/6,1)).." turns"..IgnoresArmor..KeepAlive..VanishOnReapply
            if not statusinfo.RemoveStatus then -- no need to say what a status does, if it is removed
              SurfaceStatusText = SurfaceStatusText..CreateStatusTooltip(statusinfo.StatusId,nil,true,"  ")
            end
          end
        end
        if SurfaceStatusText~="" then
          local ignoredfirst = false
          for _,entry in ipairs(tooltip.Data) do
            if entry.Type=="SurfaceDescription" and not entry.Label:find(SurfaceStatusText,1,true) then
              if issecondsurfaceofdouble then
                if ignoredfirst then
                  entry.Label = entry.Label..SurfaceStatusText
                  break
                else
                  ignoredfirst = true
                end
              else
                entry.Label = entry.Label..SurfaceStatusText
                break
              end
            end
          end
        end
      end
      previoustooltipdata = tooltip.Data
      previoussurface = SurfaceType
    end
    
  end
end

if EpipSurfaceTooltips then
  EpipSurfaceTooltips:Subscribe(function (ev)
    if ev.Type=="Surface" then -- SurfaceIndex in ev.UI is totally wrong unfortunately 
      local tooltip = ev.Tooltip
      tooltip.Data = tooltip.Elements
      -- local cc = Ext.UI.GetCursorControl();_D(Ext.UI.GetByHandle(cc.TextDisplayUIHandle))
      -- print(ev.UI.SurfaceIndex,_GetSurfaceNameByTypeIndex(ev.UI.SurfaceIndex)) -- also wrong
      -- print(ev.UI.SurfaceIndex2,_GetSurfaceNameByTypeIndex(ev.UI.SurfaceIndex2))
      local cursor = Ext.UI.GetPickingState()
      if cursor and cursor.WalkablePosition then
        local x,y,z = table.unpack(cursor.WalkablePosition)
        local surfaces = _GetSurfaces(x, z, Ext.Entity.GetAiGrid())
        AdjustSurfaceTooltip(surfaces.Ground,tooltip)
        AdjustSurfaceTooltip(surfaces.Cloud,tooltip)
        -- {
          -- "Cell" : 
          -- {
            -- "AiFlags" : 
            -- [
              -- "Water",
              -- "WaterCloud"
            -- ],
            -- "CloudSurfaceType" : "WaterCloud",
            -- "Flags" : 68753031168,
            -- "GroundSurfaceType" : "Water",
            -- "Height" : -5.25,
            -- "Objects" : {}
          -- },
          -- "Cloud" : "WaterCloud",
          -- "Ground" : "Water"
        -- }
      end
    end
  end)
else
  Game.Tooltip.Register.Surface(function(char,SurfaceType,tooltip)
    AdjustSurfaceTooltip(SurfaceType,tooltip)
  end)
end
-- Surface
-- {
	-- "ControllerEnabled" : false,
	-- "Data" : 
	-- [
		-- {
			-- "Label" : "Blut",
			-- "Type" : "Title"
		-- },
		-- {
			-- "Label" : "Kann unter Strom gesetzt und eingefroren werden.",
			-- "Type" : "SurfaceDescription"
		-- }
	-- ],
	-- "TooltipUIType" : 43,
	-- "UIType" : 43
-- }


-- Surface template
-- "Statuses" :
  -- [
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : false,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : true,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : false,
                  -- "StatusId" : "INVISIBLE",
                  -- "VanishOnReapply" : false
          -- },
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : true,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : false,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : true,
                  -- "StatusId" : "MUTED",
                  -- "VanishOnReapply" : false
          -- }
  -- ],


-- Game.Tooltip.Register.Surface: double surface tooltip.Data and the event is called twice:
-- [
	-- {
		-- "Label" : "Wasserschaden",
		-- "Type" : "Title"
	-- },
	-- {
		-- "Label" : "Kann unter Strom gesetzt und eingefroren werden.",
		-- "Type" : "SurfaceDescription"
	-- },
	-- {
		-- "Label" : "Dauer: 7 Runden",
		-- "Type" : "Duration"
	-- },
	-- {
		-- "Type" : "Splitter"
	-- },
	-- {
		-- "Label" : "Dampfwolke",
		-- "Type" : "Title"
	-- },
	-- {
		-- "Label" : "Hebt den Brennend-Statuseffekt auf.",
		-- "Type" : "SurfaceDescription"
	-- }
-- ]


-- EpipSurfaceTooltips
-- EpipSurfaceTooltips
-- {
	-- "Prevented" : true,
	-- "Tooltip" : 
	-- {
		-- "Data" : "*RECURSION*",
		-- "Elements" : 
		-- [
			-- {
				-- "Label" : "Wasserschaden",
				-- "Type" : "Title"
			-- },
			-- {
				-- "Label" : "Kann unter Strom gesetzt und eingefroren werden.",
				-- "Type" : "SurfaceDescription"
			-- },
			-- {
				-- "Label" : "Dauer: 10 Runden",
				-- "Type" : "Duration"
			-- },
			-- {
				-- "Type" : "Splitter"
			-- },
			-- {
				-- "Label" : "Dampfwolke",
				-- "Type" : "Title"
			-- },
			-- {
				-- "Label" : "Hebt den Brennend-Statuseffekt auf.",
				-- "Type" : "SurfaceDescription"
			-- }
		-- ]
	-- },
	-- "Type" : "Surface",
	-- "UI" : 
	-- {
		-- "AnchorId" : "",
		-- "AnchorObjectName" : "textDisplay_1",
		-- "AnchorPos" : "",
		-- "AnchorTPos" : "",
		-- "AnchorTarget" : "",
		-- "CaptureExternalInterfaceCalls" : "function: 00007FFE2F4F5980",
		-- "CaptureInvokes" : "function: 00007FFE2F4F59C0",
		-- "ChildUIHandle" : "userdata: 0000000000000000",
		-- "ClearCustomIcon" : "function: 00007FFE2F4F5B00",
		-- "CustomScale" : 1.0,
		-- "Destroy" : "function: 00007FFE2F4F58B0",
		-- "EnableCustomDraw" : "function: 00007FFE2F4F5A00",
		-- "ExternalInterfaceCall" : "function: 00007FFE2F4F58F0",
		-- "Flags" : 
		-- [
			-- "OF_DeleteOnChildDestroy",
			-- "OF_Loaded",
			-- "OF_Visible"
		-- ],
		-- "FlashMovieSize" : 
		-- [
			-- 1920.0,
			-- 1080.0
		-- ],
		-- "FlashSize" : 
		-- [
			-- 1920.0,
			-- 1080.0
		-- ],
		-- "ForceClearTooltipText" : false,
		-- "GetHandle" : "function: 00007FFE2F4F56D0",
		-- "GetPlayerHandle" : "function: 00007FFE2F4F5750",
		-- "GetPosition" : "function: 00007FFE2F4F5170",
		-- "GetRoot" : "function: 00007FFE2F4F5840",
		-- "GetTypeId" : "function: 00007FFE2F4F57E0",
		-- "GetUIScaleMultiplier" : "function: 00007FFE2F4F5B90",
		-- "GetValue" : "function: 00007FFE2F4F5610",
		-- "GotoFrame" : "function: 00007FFE2F4F5510",
		-- "HasAnchorPos" : false,
		-- "HasSurfaceText" : true,
		-- "Hide" : "function: 00007FFE2F4F5430",
		-- "InputFocused" : false,
		-- "Invoke" : "function: 00007FFE2F4F5470",
		-- "IsActive" : true,
		-- "IsDragging" : false,
		-- "IsDragging2" : false,
		-- "IsMoving2" : false,
		-- "IsUIMoving" : false,
		-- "Layer" : 11,
		-- "Left" : 0.0,
		-- "MinSize" : 
		-- [
			-- 0.0,
			-- 0.0
		-- ],
		-- "MovieLayout" : 6,
		-- "OF_Activated" : false,
		-- "OF_DeleteOnChildDestroy" : true,
		-- "OF_DontHideOnDelete" : false,
		-- "OF_FullScreen" : false,
		-- "OF_KeepCustomInScreen" : false,
		-- "OF_KeepInScreen" : false,
		-- "OF_Load" : false,
		-- "OF_Loaded" : true,
		-- "OF_PauseRequest" : false,
		-- "OF_PlayerInput1" : false,
		-- "OF_PlayerInput2" : false,
		-- "OF_PlayerInput3" : false,
		-- "OF_PlayerInput4" : false,
		-- "OF_PlayerModal1" : false,
		-- "OF_PlayerModal2" : false,
		-- "OF_PlayerModal3" : false,
		-- "OF_PlayerModal4" : false,
		-- "OF_PlayerTextInput1" : false,
		-- "OF_PlayerTextInput2" : false,
		-- "OF_PlayerTextInput3" : false,
		-- "OF_PlayerTextInput4" : false,
		-- "OF_PrecacheUIData" : false,
		-- "OF_PreventCameraMove" : false,
		-- "OF_RequestDelete" : false,
		-- "OF_SortOnAdd" : false,
		-- "OF_Visible" : true,
		-- "ParentUIHandle" : "userdata: 0000000000000000",
		-- "Path" : "E:/Spiele/GOG Games/Divinity - Original Sin 2/DefEd/Data/Public/Game/GUI/textDisplay.swf",
		-- "PlayerId" : 1,
		-- "RenderDataPrepared" : true,
		-- "RenderOrder" : 26,
		-- "RequestClearTooltipText" : false,
		-- "Resize" : "function: 00007FFE2F4F5310",
		-- "Right" : 0.0,
		-- "SetCustomIcon" : "function: 00007FFE2F4F5A40",
		-- "SetCustomPortraitIcon" : "function: 00007FFE2F4F5AA0",
		-- "SetPosition" : "function: 00007FFE2F4F5210",
		-- "SetValue" : "function: 00007FFE2F4F5670",
		-- "Show" : "function: 00007FFE2F4F53F0",
		-- "SurfaceIndex" : 8,
		-- "SurfaceIndex2" : 6,
		-- "SurfaceTurns" : 10,
		-- "SurfaceTurns2" : 0,
		-- "SysPanelPosition" : 
		-- [
			-- 0,
			-- 0
		-- ],
		-- "SysPanelSize" : 
		-- [
			-- -1.0,
			-- -1.0
		-- ],
		-- "Text" : "",
		-- "TooltipArrayUpdated" : true,
		-- "Top" : 0.0,
		-- "Type" : 43,
		-- "UIObjectHandle" : "userdata: 00C000020000002D",
		-- "UIScale" : 1.0,
		-- "UIScaling" : false,
		-- "WorldScreenPositionX" : 772,
		-- "WorldScreenPositionY" : 743
	-- }
-- }




-- Game.Tooltip.RegisterListener(function(request, tooltip)
  -- print("TOOLTIP",request.Type)
  -- _D(request)
  -- _D(tooltip.Data)
-- end)

-- return true to allow and false to not allow skill
-- filter out eg. enemy/quest skills and so on, to only leave the ones the player might have
function FilterSkills(skill,stat)
  -- stat.IsEnemySkill=="Yes" -- dont include enemy exclusive skills ... nearly all mods and even part of vanilla, especially gift bags, failed to properly mark skills which are Enemy-only (many do Yes for player skills) -.-
  if skill:lower():find("enemy",1,true) or skill:lower():find("quest",1,true) or skill:lower():find("dummy",1,true) or skill:lower():find("script",1,true) then
    return false
  end
  if not stat.Icon or stat.Icon=="" or not stat.Description or stat.Description=="" or not stat.DisplayName or stat.DisplayName=="" then
    return false
  end -- MemorizationRequirements can not be securely used, since also several inate or weapon skills dont require memory.. and have no Ability type defined
  return true
end

Ext.Events.StatsLoaded:Subscribe(function(e)
  -- from Vanilla Plus mod by Luxem, lua code updated to newest extender version, also updated ImprovedTooltips_Serp\Mods\ImprovedTooltips_Serp\Localization german and english for this
  local skillList = {
		Shout_SparkingSwings = "Skill:Projectile_Status_Spark:Damage",
		Target_MasterOfSparks = "Skill:Projectile_Status_GreaterSpark:Damage",
		Target_CorpseExplosion = "Skill:Projectile_CorpseExplosion_Explosion:Damage",
		Shout_MassCorpseExplosion = "Skill:Projectile_CorpseExplosion_Explosion:Damage",
		Projectile_LaunchExplosiveTrap = "Skill:Projectile_TrapLaunched:Damage",
		Projectile_DeployMassTraps = "Skill:Projectile_TrapLaunched:Damage",
	}
	for skill,description in pairs(skillList) do
		local stat = Ext.Stats.Get(skill)
    if stat then
      local statDesc = stat["StatsDescriptionParams"]
      if statDesc ~= "" and statDesc ~= nil then
        stat["StatsDescriptionParams"] = statDesc..";"..description
      else
        stat["StatsDescriptionParams"] = description
      end
    end
	end
  
end)
  
-- _D(Mods.ImprovedTooltips_Serp.SkillCleanseStati)
-- _D(Mods.ImprovedTooltips_Serp.StatusRequiresImmunity)
-- _D(Mods.ImprovedTooltips_Serp.StatsIdToStati)
-- _D(Mods.ImprovedTooltips_Serp.ImmunityFromStati)
-- _D(Mods.ImprovedTooltips_Serp.StatusRequiresImmunity_REV)
-- _D(Mods.ImprovedTooltips_Serp.StatusProvidesImmunityAgainstStati)
-- helper tables to fill StatusRemovedByStati
StatusRequiresImmunity = {} -- the immunity which is required to be immune against this status
StatusRequiresImmunity_REV = {} -- 
StatsIdToStati = {}
ImmunityFromStats = {} -- a list per immunity, which stats provide this immunity
ImmunityFromStati = {} -- a list per immunity, which stati provide this immunity
StatusProvidesImmunityAgainstStati = {}
StatusLocs = {NULL="X"} -- translation in local language
Ext.Events.SessionLoaded:Subscribe(function(_)
  -- Ext.Print("ImprovedTooltips_Serp SessionLoaded Start")
  for i,skill in pairs(Ext.Stats.GetStats("SkillData")) do
    local stat = Ext.Stats.Get(skill)
    if FilterSkills(skill,stat) then
      local CleanseStatuses = stat.CleanseStatuses -- string FROZEN;STUNNED;PETRIFIED;PLAGUE;SUFFOCATING;POISONED;BURNING;NECROFIRE;FEAR;MUTED;TAUNTED;MADNESS
      local StatusClearChance = stat.StatusClearChance
      local skill_loc = GetTranslation(stat.DisplayName,skill)
      SkillCleanseStati[skill] = {stati={},loc=skill_loc,chance=StatusClearChance}
      for status in string.gmatch(CleanseStatuses, "([^;]+)") do -- seperate by ;
        StatusCleansedBySkills[status] = StatusCleansedBySkills[status] or {}
        table.insert(StatusCleansedBySkills[status],{codename=skill,loc=skill_loc,chance=StatusClearChance})
        table.insert(SkillCleanseStati[skill].stati,status)
      end
    end
  end
  
  for i,statusname in pairs(Ext.Stats.GetStats("StatusData")) do
    local stat = Ext.Stats.Get(statusname)
    local status_loc = GetTranslation(stat.DisplayName,statusname)
    StatusLocs[statusname] = status_loc
    local ImmuneFlag = stat.ImmuneFlag -- ist nur eine immunity als string und bedeuted wenn du die hast, bist du immun gegen status
    if ImmuneFlag and ImmuneFlag~="None" then
      StatusRequiresImmunity[statusname] = ImmuneFlag
      StatusRequiresImmunity_REV[ImmuneFlag] = StatusRequiresImmunity_REV[ImmuneFlag] or {}
      if not table_contains_value(StatusRequiresImmunity_REV[ImmuneFlag],statusname) then
        table.insert(StatusRequiresImmunity_REV[ImmuneFlag],statusname)
      end
    end
    local StatsId = stat.StatsId
    if StatsId and StatsId~="" then
      StatsIdToStati[StatsId] = StatsIdToStati[StatsId] or {}
      if not table_contains_value(StatsIdToStati[StatsId],statusname) then
        table.insert(StatsIdToStati[StatsId],statusname) -- one StatsId can be used by multiple Stati
      end
    end
  end
  for statusname,info in pairs(engineStatuses) do
    if info.ImmuneFlag and info.ImmuneFlag~="None" then
      StatusRequiresImmunity[statusname] = info.ImmuneFlag
    end
  end
  
  for i,StatsId in pairs(Ext.Stats.GetStats("Potion")) do
    local stat = Ext.Stats.Get(StatsId)
    
    local immunitiesFromCurrentStatsId = {}
    local flags = stat.Flags -- a table, can contain Immunity, but not only this
    for _,flag in pairs(flags) do
      if flag:lower():find("immunity",1,true) then
        ImmunityFromStats[flag] = ImmunityFromStats[flag] or {}
        table.insert(ImmunityFromStats[flag],StatsId) -- several stats can provide the same immunity
        table.insert(immunitiesFromCurrentStatsId,flag)
      end
    end
    
    if StatsIdToStati[StatsId] and next(immunitiesFromCurrentStatsId) then
      for _,statusname in ipairs(StatsIdToStati[StatsId]) do
        local status_stat = not engineStatuses[statusname] and Ext.Stats.Get(statusname)
        local StatusType = status_stat and status_stat.StatusType or statusname
        if StatusType~="KNOCKED_DOWN" then -- game bug that this StatusType ignores immunities set in the files...
          for __,immunity in ipairs(immunitiesFromCurrentStatsId) do
            ImmunityFromStati[immunity] = ImmunityFromStati[immunity] or {}
            if not table_contains_value(ImmunityFromStati[immunity],statusname) then
              table.insert(ImmunityFromStati[immunity],statusname)
            end
            if StatusRequiresImmunity_REV[immunity] then
              for ___,immunestatus in ipairs(StatusRequiresImmunity_REV[immunity]) do
                StatusProvidesImmunityAgainstStati[statusname] = StatusProvidesImmunityAgainstStati[statusname] or {}
                if not table_contains_value(StatusProvidesImmunityAgainstStati[statusname],immunestatus) then
                  table.insert(StatusProvidesImmunityAgainstStati[statusname],immunestatus)
                end
              end
            end
          end
        end
      end
    end
    
  end
  
  -- for immunity,StatsIds in pairs(ImmunityFromStats) do
    -- ImmunityFromStati[immunity] = ImmunityFromStati[immunity] or {}
    -- for _,StatsId in ipairs(StatsIds) do
      -- if StatsIdToStati[StatsId] then
        -- for __,status in ipairs(StatsIdToStati[StatsId]) do
          -- if not table_contains_value(ImmunityFromStati[immunity],status) then
            -- table.insert(ImmunityFromStati[immunity],status)
          -- end
        -- end
      -- end
    -- end
  -- end
  
  -- not adding ImmunityFromStati to StatusRemovedByStati, but in a new table
  -- for status,immunity in pairs(StatusRequiresImmunity) do
    -- if ImmunityFromStati[immunity] then
      -- for _,removerstatus in ipairs(ImmunityFromStati[immunity]) do
        -- StatusRemovedByStati[status] = StatusRemovedByStati[status] or {}
        -- StatusRemovesStati[removerstatus] = StatusRemovesStati[removerstatus] or {}
        -- if not table_contains_value(StatusRemovedByStati[status],removerstatus) then
          -- table.insert(StatusRemovedByStati[status],removerstatus)
        -- end
        -- if not table_contains_value(StatusRemovesStati[removerstatus],status) then
          -- table.insert(StatusRemovesStati[removerstatus],status)
        -- end
      -- end
    -- end
  -- end
  
  
  -- Ext.Print("ImprovedTooltips_Serp SessionLoaded Ende")

end)


-- ecl::StatusConsumeBase (00007FF44AB8A900)
Game.Tooltip.Register.Status(function(char,StatusConsumeBase,tooltip)
  local status = StatusConsumeBase.StatusId
  -- _D(StatusConsumeBase)
  -- _D(tooltip)
  -- print("StatusTooltip",char,status,_D(tooltip.Data))
  
  -- [{            "Label" : "Ermutigt",
                -- "Type" : "StatName"
        -- },{
                -- "Label" : "Prim\u00e4re Attribute des Charakter sind erh\u00f6ht.",
                -- "Type" : "StatusDescription"
        -- },{
                -- "Label" : "St\u00e4rke: +3",
                -- "Type" : "StatusBonus"
        -- },{
                -- "Label" : "Finesse: +3",
                -- "Type" : "StatusBonus"
        -- },{
                -- "Label" : "Intelligenz: +3",
                -- "Type" : "StatusBonus"
        -- },{
                -- "Label" : "Konstitution: +5",
                -- "Type" : "StatusBonus"
        -- },{
                -- "Label" : "Dauer: 3 Runden<br><font face='Averia Serif' color='DBDBDB'>Applied by Lohse</font>",
                -- "Type" : "StatusDescription"}]
                
  if status and status~="" then
    local addstringtodesc = ""
    local addID = CurrentPressedKeys["Shift"]
    if StatusCleansedBySkills[status] then
      local opener = "\n<font color='#6EB09D'>Cleansed by Skills:</font> "
      addstringtodesc = addstringtodesc..CreateDescrString(opener,StatusCleansedBySkills[status])
    end
    if StatusRemovedByStati[status] then
      local opener = "\n<font color='#6EB09D'>Removed by Stati:</font> "
      addstringtodesc = addstringtodesc..CreateDescrString(opener,StatusRemovedByStati[status])
    end
    if not engineStatuses[status] then -- Food status is CONSUME
      local stat = Ext.Stats.Get(status)
      if stat then
        local StackId = stat.StackId
        local StackPriority = stat.StackPriority
        local SavingThrow = stat.SavingThrow
        if SavingThrow and SavingThrow~="None" then
          addstringtodesc = addstringtodesc.."\n<font color='#6EB09D'>SavingTrow:</font> "..tostring(SavingThrow)
        end
        if StackId and StackId~="" then
          addstringtodesc = addstringtodesc.."\n(StackId: "..tostring(StackId).." "..tostring(StackPriority)..")"
        end
      end
    elseif engineStatuses[status] and engineStatuses[status].SavingThrow and engineStatuses[status].SavingThrow~="None" then
      addstringtodesc = addstringtodesc.."\n<font color='#6EB09D'>SavingTrow:</font> "..tostring(engineStatuses[status].SavingThrow)
    end
    if addstringtodesc~="" then
      for _,entry in ipairs(tooltip.Data) do
        if entry.Type=="StatusDescription" then
          entry.Label = entry.Label..addstringtodesc
          break
        end
      end
    end
    
  end
end)

-- CurrentPressedKeys["Shift"]
CurrentPressedKeys = {}
-- https://gist.github.com/PinewoodPip/57e20c3239eb45c26a04499b189cc744#file-ext-lua-L3250
Ext.Events.RawInput:Subscribe(function(e)
  local inputEventData = e.Input
  local id = tostring(inputEventData.Input.InputId)
  local deviceType = tostring(inputEventData.Input.DeviceId)
  if id == "" then return end -- Happens for unsupported keys, ex. media keys.
  if deviceType=="Key" and (id=="lshift" or od=="rshift") then -- currently we only care for them
    if inputEventData.Value.State == "Pressed" then
      CurrentPressedKeys["Shift"] = true
      -- updating currently shown tooltip is too complicated (hide and show again, but I need all the info of current tooltip, no clue how to easily get them)
      -- so only works if first holding Shift and then hovering over object to show tooltip
    else
      CurrentPressedKeys["Shift"] = nil
    end
  end
end)


-- item data:
-- {
	-- "AI" : null,
	-- "AIBoundSize" : 0.19059762358665466,
	-- "Activated" : false,
	-- "Amount" : 2,
	-- "Base" : 
	-- {
		-- "Component" : 
		-- {
			-- "Handle" : "userdata: 05C0000100000D9D",
			-- "TypeId" : 22
		-- },
		-- "Entity" : "Entity (00000001000063ac)"
	-- },
	-- "BaseWeightOverwrite" : -1,
	-- "CachedItemDescription" : null,
	-- "CanBeMoved" : true,
	-- "CanBePickedUp" : true,
	-- "CanShootThrough" : true,
	-- "CanUse" : true,
	-- "CanUseRemotely" : false,
	-- "CanWalkThrough" : true,
	-- "Consumable" : true,
	-- "CoverAmount" : true,
	-- "CurrentLevel" : "",
	-- "CurrentSlot" : 24,
	-- "CurrentTemplate" : 
	-- {
		-- "AIBoundsAIType" : 1,
		-- "AIBoundsHeight" : 0.47635701298713684,
		-- "AIBoundsMax" : 
		-- [
			-- 0.13810999691486359,
			-- 0.61823999881744385,
			-- 0.13135099411010742
		-- ],
		-- "AIBoundsMin" : 
		-- [
			-- -0.13810999691486359,
			-- 0.001882690005004406,
			-- -0.13135099411010742
		-- ],
		-- "AIBoundsRadius" : 0.15252600610256195,
		-- "ActivationGroupId" : "",
		-- "AllowReceiveDecalWhenAnimated" : false,
		-- "AllowSummonTeleport" : false,
		-- "AltSpeaker" : "",
		-- "Amount" : 1,
		-- "BloodSurfaceType" : -1,
		-- "CameraOffset" : 
		-- [
			-- 0.0,
			-- 0.0,
			-- 0.0
		-- ],
		-- "CanBeMoved" : true,
		-- "CanBePickedUp" : true,
		-- "CanClickThrough" : false,
		-- "CanShootThrough" : true,
		-- "CastShadow" : true,
		-- "CombatComponent" : 
		-- {
			-- "Alignment" : "",
			-- "CanFight" : false,
			-- "CanJoinCombat" : true,
			-- "CombatGroupID" : "",
			-- "IsBoss" : false,
			-- "IsInspector" : false,
			-- "StartCombatRange" : -1.0
		-- },
		-- "CoverAmount" : 0,
		-- "DefaultState" : "",
		-- "Description" : "h8789fd46gae9ag4bbfg84ccg7f4b1c3fe781",
		-- "Destroyed" : false,
		-- "DisplayName" : "ls::TranslatedStringRepository::s_HandleUnknown",
		-- "DropSound" : "098b1399-863e-47bc-b808-7574302d6e90",
		-- "EquipSound" : "098b1399-863e-47bc-b808-7574302d6e90",
		-- "Equipment" : 
		-- {
			-- "EquipmentSlots" : 0,
			-- "SyncAnimationWithParent" : 
			-- [
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false,
				-- false
			-- ],
			-- "VisualResources" : 
			-- [
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- "",
				-- ""
			-- ],
			-- "VisualSetSlots" : 0
		-- },
		-- "FadeGroup" : "",
		-- "FadeIn" : false,
		-- "Fadeable" : false,
		-- "FileName" : "E:/Spiele/GOG Games/Divinity - Original Sin 2/DefEd/Data/Public/Shared/RootTemplates/_merged.lsf",
		-- "Flags" : {},
		-- "Floating" : false,
		-- "FreezeGravity" : false,
		-- "GameMasterSpawnSection" : 6,
		-- "GameMasterSpawnSubSection" : "h87614bc3g6474g4b95gba1dgc62361ed1734",
		-- "GroupID" : 0,
		-- "Handle" : 1782,
		-- "HardcoreOnly" : false,
		-- "HasGameplayValue" : false,
		-- "HasParentModRelation" : false,
		-- "HitFX" : "",
		-- "Hostile" : false,
		-- "Icon" : "Item_CON_PotionII_D_BloodRed_Large",
		-- "Id" : "37535d5c-3262-4d2d-bcbc-c940e33ec2ca",
		-- "InventoryMoveSound" : "098b1399-863e-47bc-b808-7574302d6e90",
		-- "IsBlocker" : false,
		-- "IsDeleted" : false,
		-- "IsGlobal" : false,
		-- "IsHuge" : false,
		-- "IsInteractionDisabled" : false,
		-- "IsKey" : false,
		-- "IsPinnedContainer" : false,
		-- "IsPointerBlocker" : false,
		-- "IsPublicDomain" : false,
		-- "IsReflecting" : false,
		-- "IsShadowProxy" : false,
		-- "IsSourceContainer" : false,
		-- "IsSurfaceBlocker" : false,
		-- "IsSurfaceCloudBlocker" : false,
		-- "IsTrap" : false,
		-- "IsWall" : false,
		-- "ItemList" : {},
		-- "Key" : "",
		-- "LevelName" : "",
		-- "LevelOverride" : 0,
		-- "LockLevel" : 1,
		-- "LoopSound" : "",
		-- "MaxStackAmount" : 100,
		-- "MeshProxy" : "",
		-- "ModFolder" : "Shared",
		-- "Name" : "CON_Potion_A_Healing_Elixir",
		-- "NonUniformScale" : true,
		-- "NotHardcore" : false,
		-- "OnDestroyActions" : {},
		-- "OnUseDescription" : "ls::TranslatedStringRepository::s_HandleUnknown",
		-- "OnUsePeaceActions" : 
		-- [
			-- {
				-- "Consume" : true,
				-- "StatsId" : "",
				-- "Type" : "Consume"
			-- }
		-- ],
		-- "Opacity" : 0.5,
		-- "Owner" : "",
		-- "PhysicsTemplate" : "4ab07902-7398-44b9-bffe-bf6d2937f435",
		-- "PickupSound" : "983328aa-f4de-4b78-aced-999470e72ba8",
		-- "PinnedContainerTags" : {},
		-- "Race" : 4294967295,
		-- "ReceiveDecal" : false,
		-- "RenderChannel" : 4,
		-- "RootTemplate" : "",
		-- "SeeThrough" : false,
		-- "SoundAttachBone" : "",
		-- "SoundAttenuation" : -1,
		-- "SoundInitEvent" : "",
		-- "Speaker" : "",
		-- "SpeakerGroup" : "",
		-- "Stats" : "POTION_Healing_Elixir",
		-- "StoryItem" : false,
		-- "Tags" : 
		-- [
			-- "POTIONS",
			-- "Potion",
			-- "HEALING_POTION",
			-- "DRINK",
			-- "ORGANIZE_POTION"
		-- ],
		-- "Tooltip" : 2,
		-- "Transform" : 
		-- {
			-- "Matrix" : 
			-- [
				-- 1.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 1.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 1.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 1.0
			-- ],
			-- "Rotate" : 
			-- [
				-- 1.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 1.0,
				-- 0.0,
				-- 0.0,
				-- 0.0,
				-- 1.0
			-- ],
			-- "Scale" : 
			-- [
				-- 1.0,
				-- 1.0,
				-- 1.0
			-- ],
			-- "Translate" : 
			-- [
				-- 0.0,
				-- 0.0,
				-- 0.0
			-- ]
		-- },
		-- "TreasureLevel" : -1,
		-- "TreasureOnDestroy" : true,
		-- "Treasures" : {},
		-- "Type" : 0,
		-- "UnequipSound" : "098b1399-863e-47bc-b808-7574302d6e90",
		-- "Unimportant" : false,
		-- "UnknownDescription" : "ls::TranslatedStringRepository::s_HandleUnknown",
		-- "UnknownDisplayName" : "ls::TranslatedStringRepository::s_HandleUnknown",
		-- "UseOnDistance" : false,
		-- "UsePartyLevelForTreasureLevel" : false,
		-- "UseRemotely" : false,
		-- "UseSound" : "3fb0b511-2549-4846-b4e3-86695ee45779",
		-- "VisualTemplate" : "444d36ff-015c-47bb-8843-46b53687c2d7",
		-- "Wadable" : false,
		-- "WalkOn" : false,
		-- "WalkThrough" : true
	-- },
	-- "CustomBookContent" : 
	-- {
		-- "ArgumentString" : 
		-- {
			-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
			-- "ReferenceString" : ""
		-- },
		-- "Handle" : 
		-- {
			-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
			-- "ReferenceString" : ""
		-- }
	-- },
	-- "CustomDescription" : 
	-- {
		-- "ArgumentString" : 
		-- {
			-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
			-- "ReferenceString" : ""
		-- },
		-- "Handle" : 
		-- {
			-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
			-- "ReferenceString" : ""
		-- }
	-- },
	-- "CustomDisplayName" : 
	-- {
		-- "ArgumentString" : 
		-- {
			-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
			-- "ReferenceString" : ""
		-- },
		-- "Handle" : 
		-- {
			-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
			-- "ReferenceString" : ""
		-- }
	-- },
	-- "Destroyed" : false,
	-- "DisplayName" : "Healing Elixir",
	-- "DontAddToBottomBar" : false,
	-- "EnableHighlights" : false,
	-- "Fade" : false,
	-- "FallTimer" : 0.0,
	-- "Flags" : 
	-- [
		-- "Known",
		-- "CanBePickedUp",
		-- "CoverAmount",
		-- "IsCraftingIngredient",
		-- "CanWalkThrough",
		-- "Registered",
		-- "Global",
		-- "CanBeMoved",
		-- "CanShootThrough",
		-- "CanUse"
	-- ],
	-- "Flags2" : 
	-- [
		-- "Consumable",
		-- "UseSoundsLoaded"
	-- ],
	-- "Floating" : false,
	-- "FoldDynamicStats" : false,
	-- "FreezeGravity" : false,
	-- "GetDeltaMods" : "function: 00007FFA751834A0",
	-- "GetInventoryItems" : "function: 00007FFA75183390",
	-- "GetOwnerCharacter" : "function: 00007FFA751833F0",
	-- "GetStatus" : "function: 00007FFA75152400",
	-- "GetStatusByType" : "function: 00007FFA751524B0",
	-- "GetStatusObjects" : "function: 00007FFA75152630",
	-- "GetStatuses" : "function: 00007FFA75152550",
	-- "GetTags" : "function: 00007FFA751515C0",
	-- "Global" : true,
	-- "GoldValueOverride" : -1,
	-- "GravityTimer" : 0.0,
	-- "Handle" : "userdata: 05C0000100000D9D",
	-- "HasPendingNetUpdate" : false,
	-- "HasTag" : "function: 00007FFA75151530",
	-- "Height" : 2.0,
	-- "Hostile" : false,
	-- "Icon" : "",
	-- "InUseByCharacterHandle" : "userdata: 0000000000000000",
	-- "InUseByUserId" : -65536,
	-- "InteractionDisabled" : false,
	-- "InventoryHandle" : "userdata: 0000000000000000",
	-- "InventoryParentHandle" : "userdata: 0740000100000000",
	-- "Invisible" : false,
	-- "Invulnerable" : false,
	-- "IsCraftingIngredient" : true,
	-- "IsDoor" : false,
	-- "IsGrenade" : false,
	-- "IsKey" : false,
	-- "IsLadder" : false,
	-- "IsSecretDoor" : false,
	-- "IsSourceContainer" : false,
	-- "IsTagged" : "function: 00007FFA75151530",
	-- "ItemColorOverride" : "",
	-- "ItemType" : "Common",
	-- "JoinedDialog" : false,
	-- "KeyName" : "",
	-- "Known" : true,
	-- "Level" : 3,
	-- "LockLevel" : 1,
	-- "MovementUpdated" : false,
	-- "MyGuid" : "cf24f68c-4b70-4d10-b39c-34751a946c3a",
	-- "NetID" : 65625,
	-- "OwnerCharacterHandle" : "userdata: 0580000100000134",
	-- "ParentInventoryHandle" : "userdata: 0740000100000000",
	-- "Physics" : null,
	-- "PhysicsDisabled" : true,
	-- "PhysicsFlag1" : false,
	-- "PhysicsFlag2" : false,
	-- "PhysicsFlag3" : false,
	-- "PhysicsFlags" : 
	-- [
		-- "PhysicsDisabled"
	-- ],
	-- "PinnedContainer" : false,
	-- "Registered" : true,
	-- "RequestRaycast" : false,
	-- "RequestWakeNeighbours" : false,
	-- "RootTemplate" : "*RECURSION*",
	-- "Rotation" : 
	-- [
		-- 1.0,
		-- 0.0,
		-- 0.0,
		-- 0.0,
		-- 1.0,
		-- 0.0,
		-- 0.0,
		-- 0.0,
		-- 1.0
	-- ],
	-- "Scale" : 1.0,
	-- "Slot" : 24,
	-- "Stats" : null,
	-- "StatsFromName" : 
	-- {
		-- "AIFlags" : "",
		-- "ComboCategories" : 
		-- [
			-- "PotionHealing"
		-- ],
		-- "DisplayName" : 
		-- {
			-- "ArgumentString" : 
			-- {
				-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
				-- "ReferenceString" : ""
			-- },
			-- "Handle" : 
			-- {
				-- "Handle" : "ls::TranslatedStringRepository::s_HandleUnknown",
				-- "ReferenceString" : ""
			-- }
		-- },
		-- "FS2" : "",
		-- "Handle" : 2932,
		-- "Level" : 3,
		-- "MemorizationRequirements" : {},
		-- "ModId" : "2bd9bdbe-22ae-4aa2-9c93-205880fc6564",
		-- "ModifierList" : "Potion",
		-- "ModifierListIndex" : 3,
		-- "Name" : "POTION_Healing_Elixir",
		-- "PropertyLists" : 
		-- {
			-- "ExtraProperties" : 
			-- {
				-- "AllPropertyContexts" : 
				-- [
					-- "AoE",
					-- "Target"
				-- ],
				-- "Name" : "POTION_Healing_Elixir_ExtraProperties",
				-- "Properties" : 
				-- {
					-- "Elements" : 
					-- [
						-- {
							-- "Arg4" : -1,
							-- "Arg5" : -1,
							-- "Context" : 
							-- [
								-- "AoE",
								-- "Target"
							-- ],
							-- "Duration" : 0.0,
							-- "Name" : "HEALING_ELIXIR_TARGET_AOE",
							-- "StatsId" : "",
							-- "Status" : "HEALING_ELIXIR",
							-- "StatusChance" : 1.0,
							-- "SurfaceBoost" : false,
							-- "SurfaceBoosts" : {},
							-- "TypeId" : "Status"
						-- }
					-- ],
					-- "GetByName" : "function: 00007FFA7519EB60",
					-- "NameToIndex" : 
					-- {
						-- "HEALING_ELIXIR_TARGET_AOE" : 0
					-- }
				-- }
			-- }
		-- },
		-- "Requirements" : {},
		-- "StatsEntry" : 
		-- {
			-- "APCostBoost" : 0,
			-- "APMaximum" : 0,
			-- "APRecovery" : 0,
			-- "APStart" : 0,
			-- "AccuracyBoost" : 0,
			-- "Act" : "1",
			-- "Act part" : "3",
			-- "ActionPoints" : 0,
			-- "AddToBottomBar" : "No",
			-- "AiCalculationStatsOverride" : "",
			-- "AirResistance" : 0,
			-- "AirResistancePenetration" : 0,
			-- "AirSpecialist" : 0,
			-- "Armor" : 0,
			-- "ArmorBoost" : 0,
			-- "AuraAllies" : "",
			-- "AuraEnemies" : "",
			-- "AuraFX" : "",
			-- "AuraItems" : "",
			-- "AuraNeutrals" : "",
			-- "AuraRadius" : 0,
			-- "AuraSelf" : "",
			-- "Barter" : 0,
			-- "BloodSurfaceType" : "",
			-- "BonusWeapon" : "",
			-- "BoostConditions" : "",
			-- "ChanceToHitBoost" : 0,
			-- "ComboCategory" : 
			-- [
				-- "PotionHealing"
			-- ],
			-- "Constitution" : "None",
			-- "CorrosiveResistancePenetration" : 0,
			-- "CriticalChance" : 0,
			-- "Damage" : "None",
			-- "Damage Multiplier" : 0,
			-- "Damage Range" : 0,
			-- "DamageBoost" : 0,
			-- "DamageType" : "None",
			-- "DodgeBoost" : 0,
			-- "DualWielding" : 0,
			-- "Duration" : 0,
			-- "EarthResistance" : 0,
			-- "EarthResistancePenetration" : 0,
			-- "EarthSpecialist" : 0,
			-- "Finesse" : "None",
			-- "FireResistance" : 0,
			-- "FireResistancePenetration" : 0,
			-- "FireSpecialist" : 0,
			-- "Flags" : {},
			-- "Gain" : "None",
			-- "Hearing" : "None",
			-- "IgnoredByAI" : "No",
			-- "Initiative" : 0,
			-- "Intelligence" : "None",
			-- "InventoryTab" : "Consumable",
			-- "IsConsumable" : "Yes",
			-- "IsFood" : "No",
			-- "Leadership" : 0,
			-- "LifeSteal" : 0,
			-- "Loremaster" : 0,
			-- "Luck" : 0,
			-- "MagicArmor" : 0,
			-- "MagicArmorBoost" : 0,
			-- "MagicPoints" : 0,
			-- "MagicResistancePenetration" : 0,
			-- "MaxAmount" : 0,
			-- "MaxLevel" : 0,
			-- "MaxSummons" : 0,
			-- "Memory" : "None",
			-- "MinAmount" : 0,
			-- "MinLevel" : 0,
			-- "ModifierType" : "Item",
			-- "Movement" : 0,
			-- "MovementSpeedBoost" : 0,
			-- "Necromancy" : 0,
			-- "ObjectCategory" : "",
			-- "PainReflection" : 0,
			-- "Perseverance" : 0,
			-- "Persuasion" : 0,
			-- "PhysicalResistance" : 0,
			-- "PhysicalResistancePenetration" : 0,
			-- "PiercingResistance" : 0,
			-- "PiercingResistancePenetration" : 0,
			-- "PoisonResistance" : 0,
			-- "PoisonResistancePenetration" : 0,
			-- "Polymorph" : 0,
			-- "Priority" : 0,
			-- "RangeBoost" : 0,
			-- "Ranged" : 0,
			-- "RangerLore" : 0,
			-- "Reflection" : "",
			-- "Repair" : 0,
			-- "RogueLore" : 0,
			-- "RootTemplate" : "37535d5c-3262-4d2d-bcbc-c940e33ec2ca",
			-- "RuneEffectAmulet" : "",
			-- "RuneEffectUpperbody" : "",
			-- "RuneEffectWeapon" : "",
			-- "RuneLevel" : 0,
			-- "SPCostBoost" : 0,
			-- "SavingThrow" : "None",
			-- "ShadowResistancePenetration" : 0,
			-- "Sight" : 0,
			-- "SingleHanded" : 0,
			-- "Sneaking" : 0,
			-- "Sourcery" : 0,
			-- "StackId" : "Healing",
			-- "StatusEffect" : "",
			-- "StatusIcon" : "",
			-- "StatusMaterial" : "",
			-- "Strength" : "None",
			-- "SummonLifelinkModifier" : 0,
			-- "Summoning" : 0,
			-- "Telekinesis" : 0,
			-- "Thievery" : 0,
			-- "TwoHanded" : 0,
			-- "Unique" : 0,
			-- "UnknownBeforeConsume" : "No",
			-- "UseAPCost" : 1,
			-- "Value" : 80,
			-- "Vitality" : 400,
			-- "VitalityBoost" : 0,
			-- "VitalityPercentage" : 0,
			-- "WarriorLore" : 0,
			-- "WaterResistance" : 0,
			-- "WaterResistancePenetration" : 0,
			-- "WaterSpecialist" : 0,
			-- "Weight" : 250,
			-- "Wits" : "None"
		-- },
		-- "StringProperties1" : {}
	-- },
	-- "StatsId" : "POTION_Healing_Elixir",
	-- "StatusMachine" : 
	-- {
		-- "IsStatusMachineActive" : false,
		-- "OwnerObjectHandle" : "userdata: 05C0000100000D9D",
		-- "PreventStatusApply" : false,
		-- "Statuses" : {}
	-- },
	-- "Sticky" : false,
	-- "Stolen" : false,
	-- "StoryItem" : false,
	-- "Tags" : {},
	-- "TeleportOnUse" : false,
	-- "Translate" : 
	-- [
		-- 0.0,
		-- 0.0,
		-- 0.0
	-- ],
	-- "UnEquipLocked" : false,
	-- "Unimportant" : false,
	-- "UnknownTimer" : 0.0,
	-- "UseSoundsLoaded" : true,
	-- "UserVars" : {},
	-- "Velocity" : 
	-- [
		-- 0.0,
		-- 0.0,
		-- 0.0
	-- ],
	-- "Visual" : null,
	-- "Vitality" : -1,
	-- "Wadable" : false,
	-- "WakePosition" : 
	-- [
		-- 0.0,
		-- 0.0,
		-- 0.0
	-- ],
	-- "Walkable" : false,
	-- "WasOpened" : false,
	-- "WorldPos" : 
	-- [
		-- 0.0,
		-- 0.0,
		-- 0.0
	-- ]
-- }










-- Seems impossible to add proper tooltip information to the Crafting result in recipe menu,
 -- since with all data we get it is impossible to find out what is crafted (language translated string as Label ist the only info we get)
-- request
-- {
	-- "AllowDelay" : true,
	-- "AnchorEnum" : 0.0,
	-- "BackgroundType" : 1.0,
	-- "Height" : 54.000091552734375,
	-- "Side" : "right",
	-- "Text" : "Armbrust",
	-- "Type" : "Generic",
	-- "UIType" : 102,
	-- "Width" : 53.99932861328125,
	-- "X" : 180.94999694824219,
	-- "Y" : 764.0
-- }
-- tooltip
-- [
	-- {
		-- "AllowDelay" : true,
		-- "AnchorEnum" : 0.0,
		-- "BackgroundType" : 1.0,
		-- "Height" : 2597.468505859375,
		-- "Label" : "Armbrust",
		-- "OverrideSize" : false,
		-- "Type" : "GenericDescription",
		-- "Width" : 6708.3779296875,
		-- "X" : 0,
		-- "Y" : 0
	-- }
-- ]



