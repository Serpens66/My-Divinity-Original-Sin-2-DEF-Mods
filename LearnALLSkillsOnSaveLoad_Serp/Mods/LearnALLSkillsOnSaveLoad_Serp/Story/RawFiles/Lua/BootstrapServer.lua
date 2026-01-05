-- Learning too many skills at the time lags or might crash the game. So doing a fixed amount per Tick instead

local skillamount_pertick = 50


local SkillsToLearn = {} -- will be filled below
local currentindex = {}

local function LearnNextXSkills(charGUID)
  local allskillslearned = false
  for i,skill in ipairs(SkillsToLearn) do
    if i >= currentindex[charGUID] and i<=currentindex[charGUID]+skillamount_pertick then
      if Osi.CharacterHasSkill(charGUID,skill)==0 then
        Osi.CharacterAddSkill(charGUID,skill)
      end
    elseif i>currentindex[charGUID]+skillamount_pertick then
      currentindex[charGUID] = i
      break
    end
    if currentindex[charGUID]>=#SkillsToLearn then
      allskillslearned = true
    end
  end
  if not allskillslearned then
    Osi.ProcObjectTimer(charGUID, "LearnNextXSkills", 500)
  else
    Ext.Print("Done learning all skills")
  end
end

Ext.Osiris.RegisterListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  for i,skill in pairs(Ext.Stats.GetStats("SkillData")) do
    table.insert(SkillsToLearn,skill)
  end
  
  local _players = Osi.DB_IsPlayer:Get(nil) -- Will return a list of tuples of all player characters
  for _,tupl in ipairs(_players) do
    local charGUID = tupl[1]
    currentindex[charGUID] = 1
    LearnNextXSkills(charGUID)
  end
  
end)


Ext.Osiris.RegisterListener("ProcObjectTimerFinished", 2, "after", function(charGUID, event)
	if event == "LearnNextXSkills" then
		LearnNextXSkills(charGUID)
	end
end)
