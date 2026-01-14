
-- convert damage of every attack to x % of Piercing
local XConvertPiercing = 0.1
-- dont convert direct armor damage that is meant to just hit armor
everyDamageExcept = {"Magic","Corrosive"}



local function CheckDamageType(damageTypes,dType,negate)
  if type(damageTypes)~="table" then
    damageTypes = {damageTypes}
  end
  for _,damageType in ipairs(damageTypes) do
    if not damageType or not negate and dType==damageType or negate and dType~=damageType then
      return true
    end
  end
  return false
end

-- From LeaderLib, but fixed and slightly adjusted (in LeaderLib it is damageList:Add(v.DamageType, amount) which is wrong)
---Converts specific damage types to another.
---@param damageType DamageType Damage type to convert. can be nil to convert from every damage entry
---@param toDamageType string Damage type to convert to.
---@param aggregate? boolean Combine multiple entries for the same damage types into one.
---@param percentage? number How much of the damage amount to convert, from 0 to 1.
---@param negate? boolean If true, convert damage types that *don't* match the damageType param.
---@param mathRoundFunction? HitData.ConvertDamageTypeTo.MathRoundFunction Optional function to use when rounding amounts (Ext.Utils.Round, math.ceil, etc)
function ConvertDamageTypeTo(hit, damageType, toDamageType, aggregate, percentage, negate, mathRoundFunction)
	if aggregate then
		hit.DamageList:AggregateSameTypeDamages()
	end
	percentage = percentage or 1
	mathRoundFunction = mathRoundFunction or Ext.Utils.Round
	local damages = hit.DamageList:ToTable()
	local damageList = Ext.Stats.NewDamageList()
	for k,v in pairs(damages) do
		local dType = v.DamageType
		local amount = mathRoundFunction(v.Amount * percentage)
    local restamount = v.Amount - amount
		if CheckDamageType(damageTypes,dType,negate) and dType~=toDamageType then
			print("ConvertDamageTypeTo",dType,restamount,toDamageType,amount)
      damageList:Add(toDamageType, amount)
			damageList:Add(dType, restamount)
		else
			damageList:Add(dType, restamount)
		end
	end
	hit.DamageList:Clear()
	hit.DamageList:Merge(damageList)
end


-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#beforecharacterapplydamage-s
-- AFTER all calulations and damagetype boni. and wont update the UI damage numbers for client
-- ev.Cause
---|"None" # 0
---|"SurfaceMove" # 1
---|"SurfaceCreate" # 2
---|"SurfaceStatus" # 3
---|"StatusEnter" # 4
---|"StatusTick" # 5
---|"Attack" # 6
---|"Offhand" # 7
---|"GM" # 8
-- ev.Hit , ev.Target, ev.Attacker
Ext.Events.BeforeCharacterApplyDamage:Subscribe(function(ev)
	if ev.Target then
    ConvertDamageTypeTo(ev.Hit,everyDamageExcept,"Piercing",true,XConvertPiercing,true)
  end
end,{Priority=-201})


-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#computecharacterhit-s
-- No clue how this should work, my new DamageList is never used.., but we use BeforeCharacterApplyDamage instead anyway
-- The function should update and return the hit table if it wishes to override the built-in hit simulation formula, or return nothing if the engine formula should be used.
-- Ext.Events.ComputeCharacterHit:Subscribe(function(ev)
	-- if ev.Target then
    -- ConvertDamageTypeTo(ev,nil,"Piercing",true,XConvertPiercing)
    -- ev.Hit.DamageList:CopyFrom(ev.DamageList)
    -- return ev.Hit
	-- end
-- end,{Priority=-201})
