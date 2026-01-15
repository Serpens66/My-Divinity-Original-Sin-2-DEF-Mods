-- Dont know how the SLEEPING status is broken on damage... seems to be hardcoded outside of accessable code (also not found in any scripts)
-- so do this by script for out status

local StatiRemoveOnDamage = {METEORBOOST=0.5,BLOOD_AURA=0.5}
local StatiRemoveOnAttacked = {SLEEPING_PIERCE=1,SLEEPING_PHYSICAL=1}
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

-- print(Ext.Entity.GetStatus(Osi.CharacterGetHostCharacter(), Osi.NRD_StatusGetHandle(Osi.CharacterGetHostCharacter(),"ENCOURAGED")))
-- print(Ext.Entity.GetStatus(Osi.CharacterGetHostCharacter(), Osi.NRD_StatusGetHandle(Osi.CharacterGetHostCharacter(),"SLEEPING_PHYSICAL")))

local function LooseStatusWithChance(charGUID,status,chance)
  if chance>0 and Osi.HasActiveStatus(charGUID,status)==1 and (chance>=1 or Ext.Random()<=chance) then
    local statusHandle = Osi.NRD_StatusGetHandle(charGUID,status)
    local statusobj = Ext.Entity.GetStatus(charGUID, statusHandle)
    if statusobj then
      -- Ext.Print("LooseStatusWithChance:",status,_D(statusobj))
      if statusobj.Turn>0 or statusobj.TurnTimer>0.5 then -- if Turn 0 and TurnTimer <= 0.5 then this status was just applied with this attack, so dont remove it 
        Osi.RemoveStatus(charGUID,status)
        local statusname_loc = Ext.L10N.GetTranslatedStringFromKey(Ext.Stats.Get(status).DisplayName,status)
        Osi.CharacterStatusText(charGUID,"<font color='#c80030'>Lost Status</font>: "..statusname_loc)
      end
    end
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




-- LooseStatusWithChance:	SLEEPING_PHYSICAL (directly with the hit that appplied it)
-- {
	-- "ApplyStatusOnTick" : "",
	-- "BringIntoCombat" : false,
	-- "CanEnterChance" : 100,
	-- "Channeled" : false,
	-- "CleansedByHandle" : "userdata: 0000000000000000",
	-- "CurrentFreezeTime" : 0.0,
	-- "CurrentLifeTime" : 5.9666657447814941,
	-- "DamageSourceType" : "StatusEnter",
	-- "EffectTime" : 0.0,
	-- "Flags0" : 
	-- [
		-- "InitiateCombat",
		-- "IsLifeTimeSet"
	-- ],
	-- "Flags1" : 
	-- [
		-- "IsHostileAct"
	-- ],
	-- "Flags2" : 
	-- [
		-- "RequestClientSync2",
		-- "ForceStatus",
		-- "Started"
	-- ],
	-- "ForceFailStatus" : false,
	-- "ForceStatus" : true,
	-- "FreezeTime" : 0.0,
	-- "FrozenFlag" : 96,
	-- "HealEffectOverride" : "Unknown4",
	-- "Influence" : false,
	-- "InitiateCombat" : true,
	-- "IsFromItem" : false,
	-- "IsHostileAct" : true,
	-- "IsInvulnerable" : false,
	-- "IsLifeTimeSet" : true,
	-- "IsOnSourceSurface" : false,
	-- "IsResistingDeath" : false,
	-- "ItemHandles" : [],
	-- "Items" : [],
	-- "KeepAlive" : false,
	-- "LifeTime" : 6.0,
	-- "LoseControl" : false,
	-- "NetID" : 131084,
	-- "OriginalWeaponStatsId" : "",
	-- "OverrideWeaponHandle" : "userdata: 0000000000000000",
	-- "OverrideWeaponStatsId" : "",
	-- "OwnerHandle" : "userdata: 0DC000020000006E",
	-- "Poisoned" : false,
	-- "RequestClientSync" : false,
	-- "RequestClientSync2" : true,
	-- "RequestDelete" : false,
	-- "RequestDeleteAtTurnEnd" : false,
	-- "ResetAllCooldowns" : false,
	-- "ResetCooldownsAbilities" : [],
	-- "ResetOncePerCombat" : false,
	-- "SavingThrow" : 33,
	-- "ScaleWithVitality" : false,
	-- "Skill" : [],
	-- "SourceDirection" : 
	-- [
		-- 0.0,
		-- 1.0,
		-- 0.0
	-- ],
	-- "StackId" : "Stack_Sleeping",
	-- "StartTime" : 52.36266683973372,
	-- "StartTimer" : 0.0,
	-- "Started" : true,
	-- "StatsId" : "Stats_Sleeping",
	-- "StatsIds" : 
	-- [
		-- {
			-- "StatsId" : "Stats_Sleeping",
			-- "Turn" : 0
		-- }
	-- ],
	-- "StatsMultiplier" : 1.0,
	-- "StatusHandle" : "userdata: 0000000100000007",
	-- "StatusId" : "SLEEPING_PHYSICAL",
	-- "StatusOwner" : [],
	-- "StatusSourceHandle" : "userdata: 0DC000020000006E",
	-- "StatusType" : "INCAPACITATED",
	-- "Strength" : 0.0,
	-- "SurfaceChanges" : [],
	-- "TargetHandle" : "userdata: 0DC000020000006E",
	-- "Turn" : 0,
	-- "TurnTimer" : 0.033334299921989441
-- }
-- LooseStatusWithChance:	SLEEPING_PHYSICAL
-- {
	-- "ApplyStatusOnTick" : "",
	-- "BringIntoCombat" : false,
	-- "CanEnterChance" : 100,
	-- "Channeled" : false,
	-- "CleansedByHandle" : "userdata: 0000000000000000",
	-- "CurrentFreezeTime" : 0.0,
	-- "CurrentLifeTime" : 3.6332876682281494,
	-- "DamageSourceType" : "StatusEnter",
	-- "EffectTime" : 0.0,
	-- "Flags0" : 
	-- [
		-- "InitiateCombat",
		-- "IsLifeTimeSet"
	-- ],
	-- "Flags1" : 
	-- [
		-- "IsHostileAct"
	-- ],
	-- "Flags2" : 
	-- [
		-- "RequestClientSync2",
		-- "ForceStatus",
		-- "Started"
	-- ],
	-- "ForceFailStatus" : false,
	-- "ForceStatus" : true,
	-- "FreezeTime" : 0.0,
	-- "FrozenFlag" : 96,
	-- "HealEffectOverride" : "Unknown4",
	-- "Influence" : false,
	-- "InitiateCombat" : true,
	-- "IsFromItem" : false,
	-- "IsHostileAct" : true,
	-- "IsInvulnerable" : false,
	-- "IsLifeTimeSet" : true,
	-- "IsOnSourceSurface" : false,
	-- "IsResistingDeath" : false,
	-- "ItemHandles" : [],
	-- "Items" : [],
	-- "KeepAlive" : false,
	-- "LifeTime" : 6.0,
	-- "LoseControl" : false,
	-- "NetID" : 131084,
	-- "OriginalWeaponStatsId" : "",
	-- "OverrideWeaponHandle" : "userdata: 0000000000000000",
	-- "OverrideWeaponStatsId" : "",
	-- "OwnerHandle" : "userdata: 0DC000020000006E",
	-- "Poisoned" : false,
	-- "RequestClientSync" : false,
	-- "RequestClientSync2" : true,
	-- "RequestDelete" : false,
	-- "RequestDeleteAtTurnEnd" : false,
	-- "ResetAllCooldowns" : false,
	-- "ResetCooldownsAbilities" : [],
	-- "ResetOncePerCombat" : false,
	-- "SavingThrow" : 33,
	-- "ScaleWithVitality" : false,
	-- "Skill" : [],
	-- "SourceDirection" : 
	-- [
		-- 0.0,
		-- 1.0,
		-- 0.0
	-- ],
	-- "StackId" : "Stack_Sleeping",
	-- "StartTime" : 52.36266683973372,
	-- "StartTimer" : 0.0,
	-- "Started" : true,
	-- "StatsId" : "Stats_Sleeping",
	-- "StatsIds" : 
	-- [
		-- {
			-- "StatsId" : "Stats_Sleeping",
			-- "Turn" : 0
		-- }
	-- ],
	-- "StatsMultiplier" : 1.0,
	-- "StatusHandle" : "userdata: 0000000100000007",
	-- "StatusId" : "SLEEPING_PHYSICAL",
	-- "StatusOwner" : [],
	-- "StatusSourceHandle" : "userdata: 0DC000020000006E",
	-- "StatusType" : "INCAPACITATED",
	-- "Strength" : 0.0,
	-- "SurfaceChanges" : [],
	-- "TargetHandle" : "userdata: 0DC000020000006E",
	-- "Turn" : 0,
	-- "TurnTimer" : 2.3667118549346924
-- }
-- LooseStatusWithChance:	SLEEPING_PHYSICAL