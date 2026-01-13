-- Dont know how the SLEEPING status is broken on damage... seems to be hardcoded outside of accessable code (also not found in any scripts)
-- so do this by script for out status

local StatiRemoveOnDamage = {METEORBOOST=0.5,BLOOD_AURA=0.5}
local StatiRemoveOnAttacked = {SLEEPING_PIERCE=1}
local StatiMakesPreferredAITarget = {"METEORBOOST"}
local StatiMakesUnpreferredAITarget = {}


local function RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.Osiris.RegisterListener(event, arity, state, function(...)
		if Ext.Server.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError(err)
			end
		end
	end)
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

local function LooseStatusWithChance(charGUID,status,chance)
  if chance>0 and Osi.HasActiveStatus(charGUID,status)==1 and (chance>=1 or Ext.Random()<=chance) then
    Osi.RemoveStatus(charGUID,status)
    local statusname_loc = Ext.L10N.GetTranslatedStringFromKey(Ext.Stats.Get(status).DisplayName,status)
    Osi.CharacterStatusText(charGUID,"<font color='#c80030'>Lost Status</font>: "..statusname_loc)
  end
end

-- CharacterReceivedDamage does only trigger on HP change, not on armor change
-- ((CHARACTERGUID)_Character, (INTEGER)_Percentage, (GUIDSTRING)_Source)
RegisterProtectedOsirisListener("CharacterReceivedDamage", 3, "after", function(charGUID,percentage,source)
  -- print("CharacterReceivedDamage",charGUID,percentage,source)
  for status,chance in pairs(StatiRemoveOnDamage) do
    LooseStatusWithChance(charGUID,status,chance)
  end
end)

-- CharacterReceivedDamage is not good enough, since normal SLEEPING is also removed when only armor is hit 
-- AttackedByObject((GUIDSTRING)_Defender, (GUIDSTRING)_AttackerOwner, (GUIDSTRING)_Attacker, (STRING)_DamageType, (STRING)_DamageSource)
RegisterProtectedOsirisListener("AttackedByObject", 5, "after", function(charGUID,AttackerOwner,Attacker,DamageType,DamageSource)
  -- print("AttackedByObject",charGUID,AttackerOwner,Attacker,DamageType,DamageSource)
  for status,chance in pairs(StatiRemoveOnAttacked) do
    LooseStatusWithChance(charGUID,status,chance)
  end
end)


RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", function(charGUID, ap_status, causee)
  -- if Osi.CharacterIsPlayer(charGUID) then -- execute for everyone, since also AI can be attacked by other AI
    for _,status in ipairs(StatiMakesPreferredAITarget) do
      if ap_status==status then
        Osi.SetTag(charGUID,"AI_PREFERRED_TARGET")
      end
    end
    for _,status in ipairs(StatiMakesUnpreferredAITarget) do
      if ap_status==status then
        Osi.SetTag(charGUID,"AI_UNPREFERRED_TARGET")
      end
    end
  -- end
end)
RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", function(charGUID, ap_status, causee)
  -- if Osi.CharacterIsPlayer(charGUID) then -- execute for everyone, since also AI can be attacked by other AI
    for _,status in ipairs(StatiMakesPreferredAITarget) do
      if ap_status==status then
        Osi.ClearTag(charGUID,"AI_PREFERRED_TARGET")
      end
    end
    for _,status in ipairs(StatiMakesUnpreferredAITarget) do
      if ap_status==status then
        Osi.ClearTag(charGUID,"AI_UNPREFERRED_TARGET")
      end
    end
  -- end
end)

