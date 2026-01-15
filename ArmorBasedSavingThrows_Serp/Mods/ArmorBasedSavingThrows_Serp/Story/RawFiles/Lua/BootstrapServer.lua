-- Mod by Pencey
-- https://steamcommunity.com/workshop/filedetails/discussion/1505329732/2590022385656340131/
-- not using exact same rules like him. 100% rewritten inlua with script extender v60

-- statusses which have no stats
local engineStatuses = {
	CLEAN=true,
  CLIMBING=true,
  SOURCE_MUTED=true,
  DRAIN=true,
  POLYMORPHED=true,
  CHARMED=true,
  INFUSED=true,
  HIT=true,
  IDENTIFY=true,
  DYING=true,
  THROWN=true,
  LYING=true,
  SNEAKING=true,
  CONSUME=true,
  ROTATE=true,
  SHACKLES_OF_PAIN=true,
  UNSHEATHED=true,
  WIND_WALKER=true,
  DARK_AVENGER=true,
  AOO=true,
  SHACKLES_OF_PAIN_CASTER=true,
  SITTING=true,
  FLANKED=true,
  LINGERING_WOUNDS=true,
  CHANNELING=true,
  DAMAGE=true,
  EXPLODE=true,
  SMELLY=true,
  SPIRIT_VISION=true,
  INCAPACITATED=true,
  SPARK=true,
  UNLOCK=true,
  EFFECT=true,
  STANCE=true,
  FORCE_MOVE=true,
  SPIRIT=true,
  FLOATING=true,
  CONSTRAINED=true,
  SUMMONING=true,
  MATERIAL=true,
  LEADERSHIP=true,
  COMBUSTION=true,
  TUTORIAL_BED=true,
  TELEPORT_FALLING=true,
  INFECTIOUS_DISEASED=true,
  OVERPOWER=true,
  REMORSE=true,
  REPAIR=true,
  ENCUMBERED=true,
  UNHEALABLE=true,
  ACTIVE_DEFENSE=true,
  DECAYING_TOUCH=true,
  ADRENALINE=true,
  INSURFACE=true,
  BOOST=true,
  COMBAT=true,
  STORY_FROZEN=true,
}

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
    if statusname and not engineStatuses[statusname] and status.LifeTime>0 then -- aura effects have a LifeTime of -1 and are applied hundred of times, so do not add any rules to them
      -- if statusname=="POISONED" then
        -- Ext.Print("ArmorBasedSavingThrows_Serp: BeforeStatusApply",statusname,sourcetype,status.LifeTime)
      -- end
      if Ext.Utils.GetHandleType(status.OwnerHandle)=="ServerCharacter" then -- only for characters, we do not care for items
        local source = Ext.Utils.GetHandleType(status.StatusSourceHandle)=="ServerCharacter" and Ext.Entity.GetCharacter(status.StatusSourceHandle) or nil ---@type EsvCharacter
        local target = Ext.Entity.GetCharacter(status.OwnerHandle) ---@type EsvCharacter .. 
        local sourceTorturer = source and source.Stats.TALENT_Torturer or false -- effects from him are not blocked. talent does not work for SurfaceStatus
        local targetGuid = target and target.MyGuid
        local FromSurface = sourcetype=="SurfaceStatus" or sourcetype=="SurfaceMove" or sourcetype=="SurfaceCreate"
        if not (not FromSurface and sourceTorturer and table_contains_value(TorturerStati,statusname)) and status.ForceStatus==false and target then
          local StatusStat = Ext.Stats.Get(statusname)
          local Raistlin = target and target.Stats.TALENT_Raistlin -- targets with this talent are not safe by armor
          if StatusStat and not Raistlin then
            local ImmuneFlag = StatusStat.ImmuneFlag -- dont apply this status, if the character has this ImmuneFlag eg. "KnockdownImmunity"
            if ImmuneFlag=="None" or not target.Stats[ImmuneFlag] then
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
                local statusname_loc = Ext.L10N.GetTranslatedStringFromKey(StatusStat.DisplayName,statusname)
                if resisted then
                  if IsPlayerEnemy(targetGuid) then
                    colour = "#c80030" -- red
                  end
                  Osi.CharacterStatusText(targetGuid,"<font color='"..colour.."'>Resisted</font> "..statusname_loc..": "..tostring(math.max(0,round(savingchance*100,2))).."%")
                  ev.PreventStatusApply = true
                elseif not resisted then
                  status.ForceStatus = true -- force it to go through armor
                  -- if SavingThrow=="PhysicalArmor" and target.Stats.CurrentArmor > 0 or SavingThrow=="MagicArmor" and target.Stats.CurrentMagicArmor > 0 then -- if 0 armor, no need to mention that resist failed
                    if not IsPlayerEnemy(targetGuid) then
                      colour = "#c80030" -- red
                    end
                    Osi.CharacterStatusText(targetGuid,"<font color='"..colour.."'>Resist Failed</font> "..statusname_loc..": "..tostring(math.max(0,round(savingchance*100,2))).."%")
                  -- end
                end
              end
            else
              local colour = "#40b606" -- green
              if IsPlayerEnemy(targetGuid) then
                colour = "#c80030" -- red
              end
              Osi.CharacterStatusText(targetGuid,"<font color='"..colour.."'>"..ImmuneFlag.."</font> ")
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
    if statusname and not engineStatuses[statusname] and status.LifeTime>0 then -- aura effects have a LifeTime of -1 and are applied hundred of times, so do not add any rules to them
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
