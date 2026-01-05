-- Mod by Pencey
-- https://steamcommunity.com/workshop/filedetails/discussion/1505329732/2590022385656340131/
-- not using exact same rules like him. 100% rewritten inlua with script extender v60

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


-- TODO:
-- Waffen die zb mit 10% chance den effekt machen, werden hier bei jedem Schlag durchgejagt!
 -- und dadurch eine 100% draus
-- das müssen wir erkennen und entwerder ignorieren oder selbst chance berechnen

Ext.Events.BeforeStatusApply:Subscribe(function(ev)
  local status = ev.Status ---@type EsvStatus
  local statusname = status.StatusId
  if statusname~="INSURFACE" and statusname~="HIT" and status.LifeTime>0 then -- aura effects have a LifeTime of -1 and are applied hundred of times, so do not add any rules to them
    local source = Ext.Entity.GetCharacter(status.StatusSourceHandle) ---@type EsvCharacter
    local target = Ext.Entity.GetCharacter(status.OwnerHandle) ---@type EsvCharacter .. can throw warning in log. see no way to prevent this, but target is just nil in this case: dse::EntityWorldBase<enum dse::esv::EntityComponentIndex>::GetBaseComponent(): Type mismatch! Factory supports 55, got 56
    local sourceTorturer = source and source.Stats.TALENT_Torturer or false -- effects from him are not blocked. talent does not work for SurfaceStatus
    local targetGuid = target and target.MyGuid
    -- Ext.Print("BeforeStatusApply",statusname,targetGuid,status.DamageSourceType,status.IsOnSourceSurface,status.InitiateCombat,status.IsHostileAct,status.CanEnterChance)
    if not (status.DamageSourceType~="SurfaceStatus" and sourceTorturer and table_contains_value(TorturerStati,statusname)) and status.ForceStatus==false and target then
      local StatusStat = Ext.Stats.Get(statusname)
      local Raistlin = target and target.Stats.TALENT_Raistlin -- targets with this talent are not safe by armor
      if StatusStat and not Raistlin then
        local SavingThrow = StatusStat.SavingThrow
        if SavingThrow=="PhysicalArmor" or SavingThrow=="MagicArmor" then
          local resisted = false
          local savingchance = 0.01
          if status.CanEnterChance < 100 and (status.CanEnterChance/100) <= math.random() then
            resisted = "vanillachancefail"
          end
          if resisted~="vanillachancefail" then
            local sourceWits = source and math.max(0,source.Stats.Wits-10) or 0 -- wits over 10
            local Perseverance = target.Stats.Perseverance
            savingchance = savingchance + Perseverance*0.01 - sourceWits*0.005 -- extra chance of 1% to resist also without armor
            if SavingThrow=="PhysicalArmor" and target.Stats.MaxArmor>0 then
              savingchance = savingchance + target.Stats.CurrentArmor / target.Stats.MaxArmor
            elseif SavingThrow=="MagicArmor" and target.Stats.MaxMagicArmor>0 then
              savingchance = savingchance + target.Stats.CurrentMagicArmor / target.Stats.MaxMagicArmor
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
          end
          local colour = "#40b606" -- green
          local statusname_loc = Ext.L10N.GetTranslatedStringFromKey(Ext.Stats.Get(statusname).DisplayName,statusname)
          if resisted==true then
            if IsPlayerEnemy(targetGuid) then
              colour = "#c80030" -- red
            end
            Osi.CharacterStatusText(target.MyGuid,"<font color='"..colour.."'>Resisted</font> "..statusname_loc..": "..tostring(math.max(0,round(savingchance*100,2))).."%")
            ev.PreventStatusApply = true
          elseif resisted==false then
            status.ForceStatus = true -- force it to go through armor
            -- if SavingThrow=="PhysicalArmor" and target.Stats.CurrentArmor > 0 or SavingThrow=="MagicArmor" and target.Stats.CurrentMagicArmor > 0 then -- if 0 armor, no need to mention that resist failed
              if not IsPlayerEnemy(targetGuid) then
                colour = "#c80030" -- red
              end
              Osi.CharacterStatusText(target.MyGuid,"<font color='"..colour.."'>Resist Failed</font> "..statusname_loc..": "..tostring(math.max(0,round(savingchance*100,2))).."%")
            -- end
          elseif resisted=="vanillachancefail" then -- a status that is only applied by chance. We do the chance check here, because not really possible differently
            ev.PreventStatusApply = true
          end
        end
      end
    end
  end
end)



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
