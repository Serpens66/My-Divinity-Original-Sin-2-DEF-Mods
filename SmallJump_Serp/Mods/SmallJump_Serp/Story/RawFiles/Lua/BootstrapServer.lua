
-- give everyone, also npcs (when they enter combat) the cat jump

AddForPlayer = 1
AddForNPC = 1
AddForSummons = 1

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

local function GiveRemoveJump(charGUID)
  local add = true
  if IsPlayerMainChar(charGUID) then
    add = AddForPlayer==1
  elseif Osi.CharacterIsPlayer(charGUID) then -- includes everything controllable by player
    add = AddForSummons==1
  else
    add = AddForNPC==1
  end
  -- Ext.Print("SmallJump_Serp, GiveRemoveJump:",charGUID,add,AddForPlayer,AddForSummons,AddForNPC)
  if add then
    if Osi.CharacterHasSkill(charGUID,"Projectile_CatFlight_Serp")==0 then
      Osi.CharacterAddSkill(charGUID,"Projectile_CatFlight_Serp")
    end
    -- Ext.Print("SmallJump_Serp NRD_SkillBarFindSkill",charGUID,Osi.NRD_SkillBarFindSkill(charGUID,"Projectile_CatFlight_Serp"),NRD_SkillBarGetSkill(charGUID,0))
    if Osi.CharacterIsPlayer(charGUID) and Osi.NRD_SkillBarFindSkill(charGUID,"Projectile_CatFlight_Serp")==nil then -- sometimes it is not added to hotbar for summons
      for i=0,40 do
        if Osi.NRD_SkillBarGetSkill(charGUID,i)==nil then
          -- Ext.Print("SmallJump_Serp, Add Jump to Hotbar Position",charGUID,i)
          Osi.NRD_SkillBarSetSkill(charGUID,i,"Projectile_CatFlight_Serp")
          break
        end
      end
    end
  else
    if Osi.CharacterHasSkill(charGUID,"Projectile_CatFlight_Serp")==1 then
      Osi.CharacterRemoveSkill(charGUID,"Projectile_CatFlight_Serp")
    end
  end
  
  
end

RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  local players = GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    GiveRemoveJump(charGUID)
  end
end)

RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    GiveRemoveJump(charGUID)
  end
end)

-- (GUIDSTRING)_Object, (INTEGER)_CombatID 
RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(charGUID, combatID)
  -- Ext.Print("ObjectEnteredCombat: ",charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    GiveRemoveJump(charGUID)
  end
end)



-- ######################################

-- LeaderLib Settings
Ext.Events.SessionLoaded:Subscribe(function (ev)
  if Mods.LeaderLib then -- LeaderLib (outside of SessionLoaded it is nil if LeaderLib is not loaded first..)
    
    -- also called on game load with current settings
    Mods.LeaderLib.Events.ModSettingsChanged:Subscribe(function (e)
      print("SmallJump_Serp: ModSettingsChanged",e.ID,e.Value)
      local stats = Ext.Stats.Get("Projectile_CatFlight_Serp")
      if e.ID=="Cooldown" then
        stats.Cooldown = e.Value
        Ext.Stats.Sync("Projectile_CatFlight_Serp",false)
      elseif e.ID=="TargetRadius" then
        stats.TargetRadius = e.Value
        Ext.Stats.Sync("Projectile_CatFlight_Serp",false)
      elseif e.ID=="ActionPoints" then
        stats.ActionPoints = e.Value
        Ext.Stats.Sync("Projectile_CatFlight_Serp",false)
      elseif e.ID=="AddForSummons" then
        AddForSummons = e.Value
        local players = GetAllPlayerChars()
        for _,charGUID in ipairs(players) do
          GiveRemoveJump(charGUID)
        end
      elseif e.ID=="AddForNPC" then
        AddForNPC = e.Value
        local players = GetAllPlayerChars()
        for _,charGUID in ipairs(players) do
          GiveRemoveJump(charGUID)
        end
      elseif e.ID=="AddForPlayer" then
        AddForPlayer = e.Value
        local players = GetAllPlayerChars()
        for _,charGUID in ipairs(players) do
          GiveRemoveJump(charGUID)
        end
      end
    end, {MatchArgs={ModuleUUID=ModuleUUID}})

  end
end)
