

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

local function AddTalent(charGUID,Talent,compensateTalentPoint,Tag,char)
  if Talent and Talent~="None" then
    char = char or Ext.Entity.GetCharacter(charGUID)
    if char and char.PlayerCustomData then -- most NPC do not have it and therefore can not add Talent here
      -- Ext.Print("Trying add Talent "..tostring(Talent).." to "..tostring(charGUID),char)
      if not Tag or Osi.IsTagged(charGUID,Tag)==0 then
        if (char and not char.Stats["TALENT_"..Talent]) or (not char and Osi.CharacterHasTalent(charGUID, Talent) == 0) then
          Osi.CharacterAddTalent(charGUID, Talent)
          -- Ext.Print("Talent "..tostring(Talent).." was added to "..tostring(charGUID))
        elseif compensateTalentPoint then
          Osi.CharacterAddTalentPoint(charGUID, 1)
          -- Ext.Print(tostring(charGUID).." already had Talent "..tostring(Talent)..". Got Talentpoints instead")
        end
        if Tag then
          Osi.SetTag(charGUID,Tag)
        end
      end
    end
  end
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

-- print(Osi.HasActiveStatus("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd","MOVEMENTSPEED_HALF_SERP"))
-- print(Osi.HasActiveStatus("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb","MOVEMENTSPEED_HALF_SERP"))
-- print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd"):GetStatus("MOVEMENTSPEED_HALF_SERP"))
-- print(Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb"):GetStatus("MOVEMENTSPEED_HALF_SERP").StatsMultiplier)
local function ApplyMovementStatus(charGUID,char)
  local statusname = "MOVEMENTSPEED_HALF_SERP"
  if Osi.HasActiveStatus(charGUID,statusname)==0 then
    Osi.ApplyStatus(charGUID,statusname,-1,1)
    char = char or Ext.Entity.GetCharacter(charGUID)
    if char then
      local status = char:GetStatus(statusname)
      if status then
        status.StatsMultiplier = char.Stats.DynamicStats[1].Movement / 2 -- reduce half of the base movement of this char (not really makeable to half also all boost effects all the time, since we would have to adjust it all the time on countless events)
      else
        Ext.Print("APFreeMovement_Serp: Did not find status to change StatsMultiplier",charGUID,statusname)
        Osi.RemoveStatus(charGUID,statusname) -- try next time this is called..
      end
    end
  end
end

-- Wenn ToggleSprint Mod aktiv, dann nicht bei SavegameLoaded machen,weil sonst zuviel? TODO
RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  local players = GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    local char = Ext.Entity.GetCharacter(charGUID)
    ApplyMovementStatus(charGUID,char)
    AddTalent(charGUID,"QuickStep",true,"QuickStepForFree_Serp",char)
  end
end)


-- print(Ext.Entity.GetCharacter("Elves_Hero_Female_c451954c-73bf-46ce-a1d1-caa9bbdc3cfd").RunSpeedOverride)

RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    local char = Ext.Entity.GetCharacter(charGUID)
    ApplyMovementStatus(charGUID,char)
    AddTalent(charGUID,"QuickStep",true,"QuickStepForFree_Serp",char)
  end
end)

-- (GUIDSTRING)_Object, (INTEGER)_CombatID 
RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(charGUID, combatID)
  -- Ext.Print("ObjectEnteredCombat: ",charGUID)
  if Osi.ObjectIsCharacter(charGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    if not IsPlayerMainChar(charGUID) and Osi.CharacterIsPlayer(charGUID) then -- CharacterIsPlayer is also true for summons
      ApplyMovementStatus(charGUID,char)
      AddTalent(charGUID,"QuickStep",false,"QuickStepForFree_Serp") -- give eg summones quickstep, for them it works here, they have PlayerCustomData
    end
  end
end)



-- ################################

-- old code which changes Anim Speed to compensate for MovementSpeedBoost. 
-- But not using MovementSpeedBoost because it also makes all following characters always Walk instead of Run...

--[[

local function MultAnimWalkSpeed(charGUID,char,ignoretag)
  char = char or Ext.Entity.GetCharacter(charGUID)
  if char.IsPlayer and (ignoretag or Osi.IsTagged(charGUID,"WalkSpeedOverride_Serp")==0) then -- also for summons and other player controlled
    char.WalkSpeedOverride = char.WalkSpeedOverride * 2 -- is saved!, so dont do this multiple times on a char
    Osi.SetTag(charGUID,"WalkSpeedOverride_Serp")
  end
end
local function MultAnimRunSpeed(charGUID,char,ignoretag,anim)
  char = char or Ext.Entity.GetCharacter(charGUID)
  if char.IsPlayer and (ignoretag or Osi.IsTagged(charGUID,"RunSpeedOverride_Serp")==0) then -- also for summons and other player controlled
    char.RunSpeedOverride = char.RunSpeedOverride * 2 -- speed up animation to compensate for MovementSpeedBoost. is saved!, so dont do this multiple times on a char
    Osi.SetTag(charGUID,"RunSpeedOverride_Serp")
  end
end

-- support for ToggleSprint Mod from LaughingLeader, which also changes the Override
RegisterProtectedOsirisListener("ObjectFlagSet", 3, "after", function(flagname,charGUID, DialogInstance)
  -- print("ObjectFlagSet",flagname,charGUID)
  if flagname=="ToggleSprint_SprintingEnabled" and Osi.ObjectIsCharacter(charGUID)==1 then
    MultAnimRunSpeed(charGUID,char,true)
  end
  if flagname=="ToggleSprint_WalkSpeedOverrideEnabled" and Osi.ObjectIsCharacter(charGUID)==1 then
    MultAnimWalkSpeed(charGUID,char,true)
  end
end)
RegisterProtectedOsirisListener("ObjectFlagCleared", 3, "after", function(flagname,charGUID, DialogInstance)
  -- print("ObjectFlagCleared",flagname,charGUID)
  if flagname=="ToggleSprint_SprintingEnabled" and Osi.ObjectIsCharacter(charGUID)==1 then
    MultAnimRunSpeed(charGUID,char,true)
  end
  if flagname=="ToggleSprint_WalkSpeedOverrideEnabled" and Osi.ObjectIsCharacter(charGUID)==1 then
    MultAnimWalkSpeed(charGUID,char,true)
  end
end)
RegisterProtectedOsirisListener("StoryEvent", 2, "after", function(charGUID,event)
  -- print("StoryEvent",event,charGUID)
  if event=="ToggleSprint_Commands_UpdateSpeed" and Osi.ObjectIsCharacter(charGUID)==1 then
    MultAnimRunSpeed(charGUID,char,true)
  end
  if event=="ToggleSprint_SetWalkingSpeed" and Osi.ObjectIsCharacter(charGUID)==1 then
    MultAnimWalkSpeed(charGUID,char,true)
  end
end)

--]]
