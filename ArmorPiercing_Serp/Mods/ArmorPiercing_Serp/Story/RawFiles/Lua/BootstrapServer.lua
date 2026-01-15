
-- convert damage of every attack to x % of Piercing
XConvertPiercing = 10
-- dont convert direct armor damage that is meant to just hit armor
everyDamageExcept = {"Magic","Corrosive"}





-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end


-- dType is the current damagetype. we want to convert it to sth else, if this damagetype is/is not in damageTypes table
local function AllowedDamageType(damageTypes,dType,negate)
  if damageTypes==nil then -- then allow everything
    return true
  end
  if type(damageTypes)~="table" then
    damageTypes = {damageTypes}
  end
  local contains = table_contains_value(damageTypes,dType)
  -- print("AllowedDamageType",contains,negate)
  return not negate and contains or negate and not contains
end

-- From LeaderLib, but fixed and slightly adjusted (in LeaderLib it is damageList:Add(v.DamageType, amount) which is wrong)
---Converts specific damage types to another.
---@param damageTypes Damage type to convert. can be nil to convert from every damage entry ir also a table
---@param toDamageType string Damage type to convert to.
---@param aggregate? boolean Combine multiple entries for the same damage types into one.
---@param percentage? number How much of the damage amount to convert, from 0 to 1.
---@param negate? boolean If true, convert damage types that *don't* match the damageType param.
---@param mathRoundFunction? HitData.ConvertDamageTypeTo.MathRoundFunction Optional function to use when rounding amounts (Ext.Utils.Round, math.ceil, etc)
function ConvertDamageTypeTo(hit, damageTypes, toDamageType, aggregate, percentage, negate, mathRoundFunction)
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
    -- print("check ConvertDamageTypeTo",dType,v.Amount)
		if AllowedDamageType(damageTypes,dType,negate) and dType~=toDamageType then
			-- print("ConvertDamageTypeTo",dType,restamount,toDamageType,amount)
			-- print("ConvertDamageTypeTo",_D(damageTypes),negate,AllowedDamageType(damageTypes,dType,negate))
      damageList:Add(toDamageType, amount)
			damageList:Add(dType, restamount)
		else
			damageList:Add(dType, v.Amount)
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
    ConvertDamageTypeTo(ev.Hit,everyDamageExcept,"Piercing",true,XConvertPiercing/100,true)
  end
end,{Priority=-201})


-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#computecharacterhit-s
-- No clue how this should work, my new DamageList is never used.., but we use BeforeCharacterApplyDamage instead anyway
-- The function should update and return the hit table if it wishes to override the built-in hit simulation formula, or return nothing if the engine formula should be used.
-- Ext.Events.ComputeCharacterHit:Subscribe(function(ev)
	-- if ev.Target then
    -- ConvertDamageTypeTo(ev,nil,"Piercing",true,XConvertPiercing/100)
    -- ev.Hit.DamageList:CopyFrom(ev.DamageList)
    -- return ev.Hit
	-- end
-- end,{Priority=-201})

-- ######################################

-- LeaderLib Settings
Ext.Events.SessionLoaded:Subscribe(function (ev)
  if Mods.LeaderLib then -- LeaderLib (outside of SessionLoaded it is nil if LeaderLib is not loaded first..)
    
    -- also called on game load with current settings
    Mods.LeaderLib.Events.ModSettingsChanged:Subscribe(function (e)
      -- print("ArmorPiercing settings changed to ")
      -- _D(e)
      if e.ID=="AmorPiercing%" then
        XConvertPiercing = e.Value
        print("ArmorPiercing_Serp: settings changed",e.ID,"to",e.Value)
      end
    end, {MatchArgs={ModuleUUID=ModuleUUID}})
    
  else
    print("ArmorPiercing did not find LeaderLib for modsettings")
  end
end)