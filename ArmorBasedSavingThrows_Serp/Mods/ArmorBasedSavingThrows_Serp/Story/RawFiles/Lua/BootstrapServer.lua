-- Mod by Pencey
-- https://steamcommunity.com/workshop/filedetails/discussion/1505329732/2590022385656340131/
-- not using exact same rules like him. 100% rewritten inlua with script extender v60

-- FreezeImmunity,BurnImmunity,StunImmunity,PoisonImmunity,CharmImmunity,FearImmunity,KnockdownImmunity,MuteImmunity,
-- ChilledImmunity,WarmImmunity,WetImmunity,BleedingImmunity,CrippledImmunity,BlindImmunity,CursedImmunity,WeakImmunity,
-- SlowedImmunity,DiseasedImmunity,InfectiousDiseasedImmunity,PetrifiedImmunity,DrunkImmunity,SlippingImmunity,HastedImmunity,
-- TauntedImmunity,SleepingImmunity,AcidImmunity,SuffocatingImmunity,RegeneratingImmunity,DisarmedImmunity,DecayingImmunity,
-- ClairvoyantImmunity,EnragedImmunity,BlessedImmunity,MadnessImmunity,ChickenImmunity,ShockedImmunity,WebImmunity,
-- ShacklesOfPainImmunity,ThrownImmunity,InvisibilityImmunity,

ShowNotificationAboveChar = 1

-- statusses which have no stats
-- but add some known SavingThrow and ImmuneFlag and translation handle to them
engineStatuses = {
    SOURCE_MUTED = {
        DisplayName = "h534aec4fgecc5g4b34gb0f5g8b08c3c4309e",
        SavingThrow = "MagicArmor",
        ImmuneFlag = "None",
        FormatColor = "Orange",
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
        ImmuneFlag = "CharmImmunity",
        FormatColor = "Pink",
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
        ImmuneFlag = "DecayingImmunity",
        FormatColor = "Purple",
    },
    UNHEALABLE = {DisplayName = "hc33f0ac7gc3f0g47b3gba3cg8c3ddb82508e"},
    STANCE = {},
    INFECTIOUS_DISEASED = {
      SavingThrow = "PhysicalArmor", 
      ImmuneFlag = "InfectiousDiseasedImmunity",
      DisplayName = "h791f1994g94e9g4471g9e10g398f8d194c90",
      FormatColor = "Purple",
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
        ImmuneFlag = "ShacklesOfPainImmunity",
        FormatColor = "Red",
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

-- "<font color='"..colourcode.."'>"..statusname_loc.."</font>"
-- 6EB09D is greenish
function GetFormatColour(FormatColor) --  in LeaderLib
  local colourcode = "#FFFFFF"
  if FormatColor and Mods.LeaderLib then
    if Mods.LeaderLib.Data.Colors.FormatStringColor[FormatColor] then
      colourcode = Mods.LeaderLib.Data.Colors.FormatStringColor[FormatColor]
    elseif Mods.LeaderLib.LocalizedText.DamageTypeHandles[FormatColor] then
      colourcode = Mods.LeaderLib.LocalizedText.DamageTypeHandles[FormatColor].Color
    elseif Mods.LeaderLib.Data.Colors.Common[FormatColor] then
      colourcode = Mods.LeaderLib.Data.Colors.Common[FormatColor]
    end
  end
  return colourcode
end
function GetStatusColour(StatusId,stat)
  -- print("GetStatusColour",StatusId)
  if not stat then
    if engineStatuses[StatusId] and engineStatuses[StatusId].FormatColor then
      stat = engineStatuses[StatusId]
    elseif not engineStatuses[StatusId] then
      stat = Ext.Stats.Get(StatusId)
    end
  end
  if stat and stat.FormatColor then
    return GetFormatColour(stat.FormatColor)
  end
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

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end


local function GetAnyPlayerControlled()
  return Osi.DB_IsPlayer:Get(nil)[1][1]
end
local function IsPlayerEnemy(charGUID,playercharGUID)
  if charGUID then
    playercharGUID = playercharGUID or GetAnyPlayerControlled()
    if Osi.CharacterIsEnemy(playercharGUID,charGUID)==1 then -- [in](CHARACTERGUID)_Character, [in](CHARACTERGUID)_OtherCharacter, [out](INTEGER)_Bool 
      return true
    else
      return false
    end
  end
  return nil
end
-- you are also ally to yourself, so fine if both GUID are the same
local function IsPlayerAlly(charGUID,playercharGUID)
  if charGUID then
    playercharGUID = playercharGUID or GetAnyPlayerControlled()
    if Osi.CharacterIsAlly(playercharGUID,charGUID)==1 then -- [in](CHARACTERGUID)_Character, [in](CHARACTERGUID)_OtherCharacter, [out](INTEGER)_Bool 
      return true
    else
      return false
    end
  end
  return nil
end

local TorturerStati = {"BURNING","POISONED","BLEEDING","NECROFIRE","ACID","SUFFOCATING","ENTANGLED","DEATH_WISH","DAMAGE_ON_MOVE"} -- stati which are not blocked by armor if Torturer apllies them

-- Osi.ObjectIsCharacter(statusOwnerGUID) == 1
Ext.Events.BeforeStatusApply:Subscribe(function(ev)
  local status = ev.Status ---@type EsvStatus
  local statusname = status.StatusId
  local sourcetype = status.DamageSourceType
  if not ev.PreventStatusApply and sourcetype~="StatusTick" and sourcetype~="GM" then -- StatusTick is aura
    if statusname and (not engineStatuses[statusname] or next(engineStatuses[statusname])) and status.LifeTime>0 then -- aura effects have a LifeTime of -1 and are applied hundred of times, so do not add any rules to them
      if Ext.Utils.GetHandleType(status.OwnerHandle)=="ServerCharacter" then -- only for characters, we do not care for items
        local source = Ext.Utils.GetHandleType(status.StatusSourceHandle)=="ServerCharacter" and Ext.Entity.GetCharacter(status.StatusSourceHandle) or nil ---@type EsvCharacter
        local target = Ext.Entity.GetCharacter(status.OwnerHandle) ---@type EsvCharacter .. 
        local sourceTorturer = source and source.Stats.TALENT_Torturer or false -- effects from him are not blocked. talent does not work for SurfaceStatus
        local targetGuid = target and target.MyGuid
        if statusname=="POISONED" and (Osi.IsTagged(targetGuid,"UNDEAD")==1 or target.Stats.TALENT_Zombie) then -- do nothing for POISONED and Undead
          return
        end
        local FromSurface = sourcetype=="SurfaceStatus" or sourcetype=="SurfaceMove" or sourcetype=="SurfaceCreate"
        if not (not FromSurface and sourceTorturer and table_contains_value(TorturerStati,statusname)) and status.ForceStatus==false and target then
          local StatusStat = engineStatuses[statusname] or Ext.Stats.Get(statusname)
          local Raistlin = target and target.Stats.TALENT_Raistlin -- targets with this talent are not safe by armor
          if StatusStat and not Raistlin then
            local ImmuneFlag = StatusStat.ImmuneFlag -- dont apply this status, if the character has this ImmuneFlag eg. "KnockdownImmunity"
            if not ImmuneFlag or ImmuneFlag=="None" or not target.Stats[ImmuneFlag] then
              local SavingThrow = StatusStat.SavingThrow
              if SavingThrow=="PhysicalArmor" or SavingThrow=="MagicArmor" then
                local resisted = false
                local savingchance = 0.01
                local sourceWits = source and math.max(0,source.Stats.Wits-10) or 0 -- wits over 10
                local Perseverance = target.Stats.Perseverance
                savingchance = savingchance + Perseverance*0.01 - sourceWits*0.005 -- extra chance of 1% to resist also without armor
                if SavingThrow=="PhysicalArmor" and target.Stats.MaxArmor>0 then
                  savingchance = savingchance + target.Stats.CurrentArmor / target.Stats.MaxArmor
                  if sourcetype=="SurfaceStatus" then -- higher resist chance on surface (dont know when SurfaceMove is done, not when moving on surface), because it can trigger often on moving. but only when having some armor
                    savingchance = savingchance + 0.25
                  end
                elseif SavingThrow=="MagicArmor" and target.Stats.MaxMagicArmor>0 then
                  savingchance = savingchance + target.Stats.CurrentMagicArmor / target.Stats.MaxMagicArmor
                  if sourcetype=="SurfaceStatus" then -- higher resist chance on surface (dont know when SurfaceMove is done, not when moving on surface), because it can trigger often on moving. but only when having some armor
                    savingchance = savingchance + 0.25
                  end
                end
                if savingchance > 0 then
                  local Blessed = Osi.HasActiveStatus(targetGuid,"BLESSED")==1 and true or false
                  local Cursed = Osi.HasActiveStatus(targetGuid,"CURSED")==1 and true or false
                  local sourceBlessed = source and Osi.HasActiveStatus(source.MyGuid,"BLESSED")==1 and true or false
                  local sourceCursed = source and Osi.HasActiveStatus(source.MyGuid,"CURSED")==1 and true or false
                  local random = math.random()
                  if (Blessed and not Cursed and not sourceBlessed) or (sourceCursed and not sourceBlessed and not Cursed) then
                    savingchance = savingchance + 0.05
                    random = math.min(random,math.random())
                  elseif (Cursed and not Blessed and not sourceCursed) or (sourceBlessed and not sourceCursed and not Blessed) then
                    savingchance = savingchance - 0.05
                    random = math.max(random,math.random())
                  end
                  if savingchance >= random then -- safe
                    resisted = true
                  end
                end
                local colour = "#40b606" -- green
                local statusname_loc = GetTranslation(StatusStat.DisplayName,statusname)
                local status_col = GetStatusColour(statusname,StatusStat)
                if status_col then
                  statusname_loc = "<font color='"..status_col.."'>"..statusname_loc.."</font>"
                end
                if resisted then
                  if IsPlayerEnemy(targetGuid) then
                    colour = "#c80030" -- red
                  end
                  
                  if ShowNotificationAboveChar==1 then
                    Osi.CharacterStatusText(targetGuid,"<font color='"..colour.."'>Resisted</font> "..statusname_loc..": "..tostring(math.max(0,round(savingchance*100,2))).."%")
                  end
                  ev.PreventStatusApply = true
                elseif not resisted then
                  status.ForceStatus = true -- force it to go through armor
                  -- if SavingThrow=="PhysicalArmor" and target.Stats.CurrentArmor > 0 or SavingThrow=="MagicArmor" and target.Stats.CurrentMagicArmor > 0 then -- if 0 armor, no need to mention that resist failed
                    if not IsPlayerEnemy(targetGuid) then
                      colour = "#c80030" -- red
                    end
                    if ShowNotificationAboveChar==1 then
                      Osi.CharacterStatusText(targetGuid,"<font color='"..colour.."'>Resist Failed</font> "..statusname_loc..": "..tostring(math.max(0,round(savingchance*100,2))).."%")
                    end
                  -- end
                end
              end
            else
              local colour = "#40b606" -- green
              if IsPlayerEnemy(targetGuid) then
                colour = "#c80030" -- red
              end
              if ShowNotificationAboveChar==1 then
                Osi.CharacterStatusText(targetGuid,"<font color='"..colour.."'>"..ImmuneFlag.."</font> ")
              end
            end
          end
        end
      end
    end
  end
end,{Priority = -200})
-- must be lower than 200, because LeaderLib has currently a function that reverts changes made to PreventStatusApply ...
-- The Priority setting determines the order in which subscribers are called; subscribers with HIGHER priority are called first. The default priority is 100. 

-- Problem:
-- If every mod does the CanEnterChance calulation on their own, it will multiply the chance 10%*10% and so on, which falsifies the result
-- solution:
-- Set the Chance to 100% if we did the CanEnter check, so mods doing it afterwards dont cause problems
Ext.Events.BeforeStatusApply:Subscribe(function(ev)
  if not ev.PreventStatusApply then
    local status = ev.Status ---@type EsvStatus
    local statusname = status and status.StatusId
    if statusname and (not engineStatuses[statusname] or next(engineStatuses[statusname])) and status.LifeTime>0 then -- aura effects have a LifeTime of -1 and are applied hundred of times, so do not add any rules to them
      if status.CanEnterChance<=0 or (status.CanEnterChance < 100 and (status.CanEnterChance/100) <= math.random()) then
        ev.PreventStatusApply = true
      elseif status.CanEnterChance < 100 then
        status.CanEnterChance = 100 -- set it to 100 to signal other mods that we already did the calc, so mods executing later wont falsify the result
      end
    end
  end
end,{Priority = 10000})


-- BeforeStatusApply
---@field Owner IGameObject
---@field PreventStatusApply boolean
-- -@field Status EsvStatus
---@class IGameObject
---@field Handle ComponentHandle
---@field Height number
---@field Rotation mat3
---@field Scale number
---@field Translate vec3
---@field Velocity vec3
---@field Visual Visual
---@class EsvStatus
---@field BringIntoCombat boolean
---@field CanEnterChance int32
---@field Channeled boolean
---@field CleansedByHandle ComponentHandle
---@field CurrentLifeTime number
---@field DamageSourceType CauseType
---@field Flags0 ServerStatusFlags
---@field Flags1 ServerStatusFlags1
---@field Flags2 ServerStatusFlags2
---@field ForceFailStatus boolean
---@field ForceStatus boolean
---@field Influence boolean
---@field InitiateCombat boolean
---@field IsFromItem boolean
---@field IsHostileAct boolean
---@field IsInvulnerable boolean
---@field IsLifeTimeSet boolean
---@field IsOnSourceSurface boolean
---@field IsResistingDeath boolean
---@field KeepAlive boolean
---@field LifeTime number
---@field NetID NetId
---@field OwnerHandle ComponentHandle
---@field RequestClientSync boolean
---@field RequestClientSync2 boolean
---@field RequestDelete boolean
---@field RequestDeleteAtTurnEnd boolean
---@field StartTime Double
---@field StartTimer number
---@field Started boolean
---@field StatsMultiplier number
---@field StatusHandle ComponentHandle
---@field StatusId FixedString
---@field StatusOwner ComponentHandle[]
---@field StatusSourceHandle ComponentHandle
---@field StatusType FixedString
---@field Strength number
---@field TargetHandle ComponentHandle
---@field TurnTimer number



-- ######################################

-- LeaderLib Settings
Ext.Events.SessionLoaded:Subscribe(function (ev)
  if Mods.LeaderLib then -- LeaderLib (outside of SessionLoaded it is nil if LeaderLib is not loaded first..)
    
    -- also called on game load with current settings
    Mods.LeaderLib.Events.ModSettingsChanged:Subscribe(function (e)
      print("ArmorBasedSavingThrows: ModSettingsChanged",e.ID,e.Value)
      if e.ID=="ShowNotificationAboveChar" then
        ShowNotificationAboveChar = e.Value
      end
    end, {MatchArgs={ModuleUUID=ModuleUUID}})

  end
end)
