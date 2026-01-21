
-- TODO:
 -- beim Bogen aus dem lastsave test von Fane steht er macht bleeding und shocked.
 -- mein tolltip zeigt nur für bleeding was an (nicht shocked), und das ist auch noch falsch, denn es behauptet Target sei Self

-- evlt status colours usw zufügen?
-- GetFormatColour
    
  
Ext.Require("helpers/GetSurfaces.lua") -- _GetSurfaces
Ext.Require("helpers/gameScriptStatusLogic.lua") -- GetInfoTextForStatus

-- statusses which have no stats
-- but add some known SavingThrow and ImmuneFlag and translation handle to them
engineStatuses = {
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


function deepcopy(orig, copies)
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


local MissingExtenderSurfaces = {DeathfogCloud="c651b724-32e2-4e34-99b4-272826ac3e37"} -- or must change it to "Deathfog" instead

-- returns the first key from table with value x
function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

---@param o1 any|table First object to compare
---@param o2 any|table Second object to compare
-- ignores metatables
function equals(o1, o2)
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

-- "<font color='"..colourcode.."'>"..statusname_loc.."</font>"
function GetFormatColour(FormatColor) -- not all but most in LeaderLib
  local colourcode
  if FormatColor and Mods.LeaderLib then
    if Mods.LeaderLib.LocalizedText.DamageTypeHandles[FormatColor] then
      colourcode = Mods.LeaderLib.LocalizedText.DamageTypeHandles[FormatColor].Color
    elseif Mods.LeaderLib.Data.Colors.Common[FormatColor] then
      colourcode = Mods.LeaderLib.Data.Colors.Common[FormatColor]
    end
  end
  return colourcode
end

-- Osi.GetSurfaceNameByTypeIndex is not available on client..
function _GetSurfaceNameByTypeIndex(s_index)
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
function IsValidSkillTooltip(tooltip)
  if tooltip and tooltip.Data then
    for _, entry in ipairs(tooltip.Data) do
      if entry["Type"]=="SkillCooldown" then
        return true
      end
    end
  end
  return false
end


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

-- recreate the info about stats
function CreateStatusStatsTooltip(status)
  
end

function CreateStatusRemoveTooltip(status)
  local addstringtodesc = ""
  local addID = CurrentPressedKeys["Shift"]
  if StatusCleansedBySkills[status] then
    local opener = "\n<font color='#6EB09D'>Cleansed by Skills:</font> "
    addstringtodesc = addstringtodesc..CreateDescrString(opener,StatusCleansedBySkills[status])
  end
  -- if StatusRemovedByStati[status] then
    -- local opener = "\n<font color='#6EB09D'>Removed by Stati:</font> "
    -- addstringtodesc = addstringtodesc..CreateDescrString(opener,StatusRemovedByStati[status])
  -- end
  if StatusScriptRemovalRules[status] then
    addstringtodesc = addstringtodesc.."\n<font color='#6EB09D'>Removed by Stati:</font>\n"
    addstringtodesc = addstringtodesc..GetInfoTextForStatusRemoval(status,StatusLocs,"")
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
  return addstringtodesc
end

function CreateStatusApplyTooltip(status,Context,withoutheader,prefix)
  -- Adding info what the applied appliedstati may cleanse (chance and duration is already in tooltip)
  prefix = prefix or ""
  local desc = ""
  local stat = not engineStatuses[status] and Ext.Stats.Get(status) or engineStatuses[status]
  local status_loc = StatusLocs[status] or stat and GetTranslation(stat.DisplayName,status) or status
  local codename = " ("..status..") "
  if not withoutheader then
    local colourcode = GetFormatColour(stat.FormatColor)
    if colourcode then
      status_loc = "<font color='"..colourcode.."'>"..status_loc.."</font>"
    end
    -- desc = desc.."\n"..prefix.."<font color='#6EB09D'>Status "..status_loc..(CurrentPressedKeys["Shift"] and codename or "").."</font> "..(Context and "("..table.concat(Context,",")..")" or "")
    desc = desc.."\n"..prefix.."<font color='#DCDCCC'>Status</font> "..status_loc..(CurrentPressedKeys["Shift"] and codename or "")..(Context and "("..table.concat(Context,",")..")" or "")
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
    local addcleansestringtoskill = ""
    for i,info in ipairs(appliedstati) do
      local status = info.status
      local Context = info.Context or {}
      addcleansestringtoskill = addcleansestringtoskill..CreateStatusApplyTooltip(status,Context)
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

function _AddToTooltip(tooltip,Type,info)
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
            local colourcode = GetFormatColour(SStat.FormatColor)
            if colourcode then
              statusname_loc = "<font color='"..colourcode.."'>"..statusname_loc.."</font>"
            end
            -- addremove = "\n<font color='#6EB09D'>"..(statusinfo.RemoveStatus and "Removes " or "Applies ").."</font> "..statusname_loc..(CurrentPressedKeys["Shift"] and statusinfo.StatusId or "")
            addremove = "\n<font color='#DCDCCC'>"..(statusinfo.RemoveStatus and "Removes " or "Applies ").."</font> "..statusname_loc..(CurrentPressedKeys["Shift"] and statusinfo.StatusId or "")
            local IgnoresArmor = statusinfo.ForceStatus and "\n  Ignores Armor" or ""
            local KeepAlive = statusinfo.KeepAlive and "\n  Stays Active" or ""
            local OnlyWhileMoving = statusinfo.OnlyWhileMoving and "\n  Only While Moving" or ""
            local VanishOnReapply = statusinfo.VanishOnReapply and "\n  Removes Surface" or ""
            SurfaceStatusText = SurfaceStatusText..addremove.."\n  Chance: "..tostring(round(statusinfo.Chance*100,2)).." %\n  Duration: "..tostring(round(statusinfo.Duration/6,1)).." turns"..IgnoresArmor..KeepAlive..VanishOnReapply
            if not statusinfo.RemoveStatus then -- no need to say what a status does, if it is removed
              SurfaceStatusText = SurfaceStatusText..CreateStatusApplyTooltip(statusinfo.StatusId,nil,true,"  ")
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
StatusLocs = {NULLL="Ø"} -- translation in local language
StatusSources = {} -- weapons,potions,skill which can apply a status
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
    if info.DisplayName then
      local status_loc = GetTranslation(info.DisplayName,statusname)
      StatusLocs[statusname] = status_loc
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


-- from "\Public\Shared\Stats\Generated\Structure\Modifiers.txt"
Potion_Modifiers = {"ModifierType","VitalityBoost","Strength","Finesse","Intelligence","Constitution","Memory","Wits","SingleHanded","TwoHanded","Ranged","DualWielding","RogueLore","WarriorLore","RangerLore","FireSpecialist","WaterSpecialist","AirSpecialist","EarthSpecialist","Sourcery","Necromancy","Polymorph","Summoning","PainReflection","Perseverance","Leadership","Telekinesis","Sneaking","Thievery","Loremaster","Repair","Barter","Persuasion","Luck","FireResistance","EarthResistance","WaterResistance","AirResistance","PoisonResistance","PhysicalResistance","PiercingResistance","Sight","Hearing","Initiative","Vitality","VitalityPercentage","MagicPoints","ActionPoints","ChanceToHitBoost","AccuracyBoost","DodgeBoost","DamageBoost","APCostBoost","SPCostBoost","APMaximum","APStart","APRecovery","Movement","MovementSpeedBoost","Gain","Armor","MagicArmor","ArmorBoost","MagicArmorBoost","CriticalChance","Act","Act part","Duration","UseAPCost","ComboCategory","StackId","BoostConditions","Flags","StatusMaterial","StatusEffect","StatusIcon","SavingThrow","Weight","Value","InventoryTab","UnknownBeforeConsume","Reflection","Damage","Damage Multiplier","Damage Range","DamageType","AuraRadius","AuraSelf","AuraAllies","AuraEnemies","AuraNeutrals","AuraItems","AuraFX","RootTemplate","ObjectCategory","MinAmount","MaxAmount","Priority","Unique","MinLevel","MaxLevel","BloodSurfaceType","MaxSummons","AddToBottomBar","SummonLifelinkModifier","IgnoredByAI","RangeBoost","BonusWeapon","AiCalculationStatsOverride","RuneEffectWeapon","RuneEffectUpperbody","RuneEffectAmulet","RuneLevel","LifeSteal","IsFood","IsConsumable"}


