

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

local function AddTalent(charGUID,Talent,compensateTalentPoint,Tag,char)
  if Talent and Talent~="None" then
    char = char or Ext.Entity.GetCharacter(charGUID)
    Ext.Print("Trying add Talent "..tostring(Talent).." to "..tostring(charGUID),char)
    if char and char.PlayerCustomData then -- most NPC do not have it and therefore can not add Talent here
      if not Tag or Osi.IsTagged(charGUID,Tag)==0 then
        if (char and not char.Stats["TALENT_"..Talent]) or (not char and Osi.CharacterHasTalent(charGUID, Talent) == 0) then
          Osi.CharacterAddTalent(charGUID, Talent)
          Ext.Print("Talent "..tostring(Talent).." was added to "..tostring(charGUID))
        elseif compensateTalentPoint then
          Osi.CharacterAddTalentPoint(charGUID, 1)
          Ext.Print(tostring(charGUID).." already had Talent "..tostring(Talent)..". Got Talentpoints instead")
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


RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  local players = GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    AddTalent(charGUID,"QuickStep",true,"QuickStepForFree_Serp")
  end
end)

RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(objectGUID)
  if Osi.ObjectIsCharacter(objectGUID)==1 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    AddTalent(objectGUID,"QuickStep",true,"QuickStepForFree_Serp")
  end
end)
