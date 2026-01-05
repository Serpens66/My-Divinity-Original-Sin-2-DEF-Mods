
-- give everyone, also npcs (when they enter combat) the cat jump

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

-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end


local function GetAllPlayerChars()
  local _players = Osi.DB_IsPlayer:Get(nil) -- Will return a list of tuples of all player characters
  local players = {}
  for _,tupl in ipairs(_players) do
    local charGUID = tupl[1]
    table.insert(players,charGUID)
  end
  return players
end
local function IsPlayerMainChar(charGUID)
  local players = GetAllPlayerChars()
  return table_contains_value(players,charGUID)
end


RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  local players = GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    if Osi.CharacterHasSkill(charGUID,"Projectile_CatFlight_Serp")==0 then
      Osi.CharacterAddSkill(charGUID,"Projectile_CatFlight_Serp")
    end
  end
end)

RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    if Osi.CharacterHasSkill(charGUID,"Projectile_CatFlight_Serp")==0 then
      Osi.CharacterAddSkill(charGUID,"Projectile_CatFlight_Serp")
    end
  end
end)

-- (GUIDSTRING)_Object, (INTEGER)_CombatID 
RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(charGUID, combatID)
  -- Ext.Print("ObjectEnteredCombat: ",charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    if Osi.CharacterHasSkill(charGUID,"Projectile_CatFlight_Serp")==0 then
      Osi.CharacterAddSkill(charGUID,"Projectile_CatFlight_Serp")
    end
  end
end)

