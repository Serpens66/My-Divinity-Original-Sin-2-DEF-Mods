-- eg quest skills or skill you only should learn by progress 
NoSkillAutoLearn_Serp = {}--{"Target_VoidwokenCharm","Shout_InnerDemon","Summon_Cat","Summon_BlackCat"}
-- Set UseAPCost for your skillbook to >0 (eg. 1) to prevent autolearn or add your skill via lua to this table (dont know how to access variables from other mods)

-- Target_VoidwokenCharm SKILLBOOK_Source_VoidwokenCharm ARX_Windego_Reward

-- #############

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end


local CacheSkillsAutoLearn = {} -- will be filled in StatsLoaded: {{skill=minlevel},}
local CacheSkillBookIsInTreasure = {}
local CacheCraftableSkillbooks = {}

-- ###########################################################################

local function RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.Osiris.RegisterListener(event, arity, state, function(...)
		if Ext.Server.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError("ERROR: ",err)
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
-- only character main chars (current Party) (not sure yet if controllable has any effect or if currently in party)
-- returned nicht dasselbe wie Osi.CharacterIsPlayer (denn das nimmt zb auch incarnation mit auf)
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

-- autolearnskills
local SkillbookTemplates = Mods and Mods.EpipEncounters and Mods.EpipEncounters.Epip and Mods.EpipEncounters.Epip.GetFeature("SkillbookTemplates")
local function GetSkillbooksForSkill(skill)
  local skillbooks = {} -- most of the time 1 but could be more than 1
  if SkillbookTemplates then -- requires Epip installed
    local skillbook_templates = SkillbookTemplates and SkillbookTemplates.GetForSkill(skill) or nil
    for _,template in ipairs(skillbook_templates) do
      local root = Ext.Template.GetTemplate(template)
      if root and root.Stats then
        table.insert(skillbooks,root.Stats)
      end
    end
  end
  return skillbooks
end

-- TODO: also learn and unlearn on ability change
-- und iwie merken, wenn ein spieler ein skill unlearned hat?
-- bzw. allgemein jeden skill nur einmal geben? dazu müssten wir eigene DB erstellen zum speichern
-- und resetten nur bei respec?
-- andererseits kann auch durch ausrüstung die ability ändern... hmm
-- also nur alle die man mit Epip unlearned merken, bis zum respec

-- limit the amount of skill learned at a time, to not crash the game
local skills_pertime = {amount=50,intervall=500}
local SkillsToLearn = {} -- will be filled below
local currentindex = {}
local function LearnNextXSkills(charGUID)
  local allskillslearned = false
  for i,skill in ipairs(SkillsToLearn[charGUID]) do
    if i >= currentindex[charGUID] and i<=currentindex[charGUID]+skills_pertime.amount then
      if Osi.CharacterHasSkill(charGUID,skill)==0 then
        Osi.CharacterAddSkill(charGUID,skill)
      end
    elseif i>currentindex[charGUID]+skills_pertime.amount then
      currentindex[charGUID] = i
      break
    end
    if currentindex[charGUID]>=#SkillsToLearn[charGUID] then
      allskillslearned = true
    end
  end
  if not allskillslearned then
    Osi.ProcObjectTimer(charGUID, "LearnNextXSkills", skills_pertime.intervall)
  else
    Ext.Print("Done learning all skills for ",charGUID)
  end
end
Ext.Osiris.RegisterListener("ProcObjectTimerFinished", 2, "after", function(charGUID, event)
	if event == "LearnNextXSkills" then
		LearnNextXSkills(charGUID)
	end
end)


-- checks charlevel vs skillbooklevel, ability requirements and sourcepoint requirements
local function LearnAllFittingSkills(charGUID)
  SkillsToLearn[charGUID] = {}
  currentindex[charGUID] = 1
  local charlevel = Osi.CharacterGetLevel(charGUID)
  -- Ext.Print("OnSaveLoaded charlevel",charGUID,charlevel)
  for skill,reqs in pairs(CacheSkillsAutoLearn) do
    if charlevel >= reqs.minlevel then
      local canlearn = true
      for i,reqabilitiesbook in ipairs(reqs.reqabilitiesbook) do
        if Osi.CharacterGetAbility(charGUID,reqabilitiesbook.Requirement) < reqabilitiesbook.Param then
          canlearn = false
        end
      end
      for i,reqabilitiesmem in ipairs(reqs.reqabilitiesmem) do
        if Osi.CharacterGetAbility(charGUID,reqabilitiesmem.Requirement) < reqabilitiesmem.Param then
          canlearn = false
        end
      end
      local maxsourcepoints = Osi.HasActiveStatus(charGUID,"SOURCE_MUTED")==1 and 0 or Osi.CharacterGetMaxSourcePoints(charGUID)
      local skillstat = Ext.Stats.Get(skill)
      local sourcecategory = skillstat and skillstat.Ability=="Source" -- eg source vampirms
      if canlearn and maxsourcepoints>=reqs.reqsourcepoints and (maxsourcepoints>0 or not sourcecategory) and Osi.CharacterHasSkill(charGUID,skill)==0 then
        table.insert(SkillsToLearn[charGUID],skill)
        -- Osi.CharacterAddSkill(charGUID,skill) -- learning to many skill at once can crash the game
      end
    end
  end
  LearnNextXSkills(charGUID)
  
end


RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  
  if next(CacheSkillsAutoLearn)==nil then -- only needed once per saveload
    
    for i,combo in pairs(Ext.Stats.GetStats("ItemCombination")) do
      for k,v in pairs(Ext.Stats.ItemCombo.GetLegacy(combo)) do -- Ext.Stats.Get/Raw does not work
        if k=="Results" then
          for kk,results in pairs(v) do
            for _,result in pairs(results) do
              if _=="Results" then
                for _,finalresult in pairs(result) do
                  if finalresult.Result and finalresult.Result:find("SKILLBOOK_") then
                    CacheCraftableSkillbooks[finalresult.Result] = true
                  end
                end
              end
            end
          end
        end
      end
    end
    
    -- TreasureTable
    for i,Trstable in pairs(Ext.Stats.GetStats("TreasureTable")) do
      if not Trstable:find("Reward") then -- assuming that these are Quest Rewards
        local Stat = Ext.Stats.TreasureTable.GetLegacy(Trstable)
        if Stat then
          for _,subtable in ipairs(Stat.SubTables) do
            for __,category in ipairs(subtable.Categories) do
              local TreasureCategory = category.TreasureCategory
              if TreasureCategory and category.Unique==0 and category.Divine==0 and category.Frequency~=0 then -- skip these ?
                if TreasureCategory:find("Skillbook") then
                  CacheSkillBookIsInTreasure[TreasureCategory] = true -- a ObjectCategory
                elseif TreasureCategory:find("SKILLBOOK") then -- a skillbook I_SKILLBOOK_Air_ShockingTouch
                  local skillbook = TreasureCategory:gsub("I_","") -- remove the I_ in front
                  -- if skillbook=="SKILLBOOK_Source_VoidwokenCharm" then
                    -- Ext.Print("SKILLBOOK_Source_VoidwokenCharm",Trstable)
                  -- end
                  CacheSkillBookIsInTreasure[skillbook] = true
                end
              end
            end
          end
        end
      end
    end
    
    
    for i,skill in pairs(Ext.Stats.GetStats("SkillData")) do
      if not table_contains_value(NoSkillAutoLearn_Serp,skill) then
        local skillbooks = GetSkillbooksForSkill(skill)
        if #skillbooks>0 then
          local skillstat = Ext.Stats.GetRaw(skill)
          if skillstat then
            local reqsourcepoints = skillstat["Magic Cost"]
            local reqabilitiesmem = skillstat.MemorizationRequirements
            for _,skillbook in ipairs(skillbooks) do
              local skillbookstat = Ext.Stats.GetRaw(skillbook)
              if skillbookstat then
                local UseAPCost = skillbookstat.UseAPCost
                if UseAPCost<=0 and (CacheSkillBookIsInTreasure[skillbook] or CacheSkillBookIsInTreasure[skillbookstat.ObjectCategory] or CacheCraftableSkillbooks[skillbook]) then -- in any TreasureTable or craftable
                  -- if skillbook=="SKILLBOOK_Source_VoidwokenCharm" or skill=="Target_VoidwokenCharm" then
                    -- Ext.Print(skillbook,skill,CacheSkillBookIsInTreasure[skillbook],CacheSkillBookIsInTreasure[skillbookstat.ObjectCategory],CacheCraftableSkillbooks[skillbook])
                  -- end
                  local minlevel = skillbookstat.MinLevel
                  local category = skillbookstat.ObjectCategory -- SkillbookAirStarter relevant for TreasureTable
                  minlevel = minlevel==4 and 5 or minlevel -- should be 5, not 4, fits better with the scaling: 1,5,9,13,16
                  minlevel = minlevel==0 and skillbookstat["Act part"] or minlevel -- Act part is most of the time identical to MinLevel, but its 5 while MinLevel is 4, and I think 5 fits better. And sometimes MinLevel does not exist (0)
                  minlevel = tonumber(minlevel)
                  if minlevel>0 then -- without MinLevel are often Quest or Cheat skillbooks
                    local reqabilitiesbook = skillbookstat.Requirements
                    skillbookstat["Value"] = 0 -- TODO Sync
                    CacheSkillsAutoLearn[skill] = {minlevel=skillbookstat.MinLevel,reqabilitiesmem=reqabilitiesmem,reqabilitiesbook=reqabilitiesbook,reqsourcepoints=reqsourcepoints}
                    -- Ext.Print("CacheSkillsAutoLearn",skill,skillbookstat.MinLevel,reqsourcepoints)
                  end
                elseif not (CacheSkillBookIsInTreasure[skillbook] or CacheSkillBookIsInTreasure[skillbookstat.ObjectCategory]) then
                  Ext.Print("Not allow auto learn skill, because skillbook is in no TreasureTable (~=Reward) and not craftable:",skill,skillbook,UseAPCost)
                end
              end
            end
          end
        else
          Ext.Print("Not allow auto learn skill, it has not skillbook: ",skill)
        end
      else
        Ext.Print("Not allow auto learn skill, because it is in NoSkillAutoLearn_Serp: ",skill)
      end
    end
  end
  local players = GetAllPlayerChars()
  for _,charGUID in ipairs(players) do
    LearnAllFittingSkills(charGUID)
  end
  
end)


-- (CHARACTERGUID)_Character
RegisterProtectedOsirisListener("CharacterLeveledUp", 1, "after", function(charGUID)
  if IsPlayerMainChar(charGUID) then
    LearnAllFittingSkills(charGUID)
  end
end)
RegisterProtectedOsirisListener("CharacterCreationFinished", 1, "after", function(charGUID)
  if IsPlayerMainChar(charGUID) then
    LearnAllFittingSkills(charGUID)
  end
end)
RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(charGUID)
  if IsPlayerMainChar(charGUID) then
    LearnAllFittingSkills(charGUID)
  end
end)


-- ItemCombo
-- CraftingStation None
-- Name    BOOK_Skill_Air_Blank_A_SCROLL_Shout_BlindingRadiance
-- Results table: 00007FF4673E6B98
-- zweiter 1       table: 00007FF4673E6BD0
-- dritter PreviewStatsId  SKILLBOOK_Air_BlindingRadiance
-- dritter Results table: 00007FF4673E6C08
-- vierter Result  SKILLBOOK_Air_BlindingRadiance
-- vierter ResultAmount    1
-- vierter Boost
-- dritter Name    BOOK_Skill_Air_Blank_A_SCROLL_Shout_BlindingRadiance_1
-- dritter Requirement     Sentinel
-- dritter PreviewTooltip
-- dritter PreviewIcon
-- dritter ReqLevel        0
-- AutoLevel       false
-- RecipeCategory  Grimoire
-- Ingredients     table: 00007FF4673E68F8
-- zweiter 1       table: 00007FF4673E6930
-- dritter IngredientType  Object
-- dritter Transform       Transform
-- dritter Object  BOOK_Skill_Air_Blank_Step2_A
-- dritter ItemRarity      Sentinel
-- zweiter 2       table: 00007FF4673E6B60
-- dritter IngredientType  Object
-- dritter Transform       Consume
-- dritter Object  SCROLL_Shout_BlindingRadiance
-- dritter ItemRarity      Sentinel


    -- for i,Object in pairs(Ext.Stats.GetStats("Object")) do
      -- for k,v in pairs(Ext.Stats.GetRaw(Object)) do
        -- if Object:find("SKILLBOOK") then
          -- Ext.Print("Raw Object",Object,k,v)
        -- end
        -- Object	SKILLBOOK_Necromancy_BonePile	PropertyLists	Map<FixedString, stats::PropertyList> (00007FF4533128F0)
        -- Object	SKILLBOOK_Necromancy_BonePile	Name	SKILLBOOK_Necromancy_BonePile
        -- Object	SKILLBOOK_Necromancy_BonePile	Handle	2327
        -- Object	SKILLBOOK_Necromancy_BonePile	AIFlags	
        -- Object	SKILLBOOK_Necromancy_BonePile	DisplayName	TranslatedString (00007FF453312838)
        -- Object	SKILLBOOK_Necromancy_BonePile	Level	9
        -- Object	SKILLBOOK_Necromancy_BonePile	ModifierListIndex	4
        -- Object	SKILLBOOK_Necromancy_BonePile	FS2	
        -- Object	SKILLBOOK_Necromancy_BonePile	Requirements	Array<stats::Requirement> (00007FF453312930)
        -- Object	SKILLBOOK_Necromancy_BonePile	MemorizationRequirements	Array<stats::Requirement> (00007FF453312950)
        -- Object	SKILLBOOK_Necromancy_BonePile	StringProperties1	table: 00007FF457D68EE0
        -- Object	SKILLBOOK_Necromancy_BonePile	ComboCategories	table: 00007FF457D66B98
        -- Object	SKILLBOOK_Necromancy_BonePile	ModifierList	Object
        -- Object	SKILLBOOK_Necromancy_BonePile	StatsEntry	StatsEntry (00007FF453312800)
        -- Object	SKILLBOOK_Necromancy_BonePile	ModId	2bd9bdbe-22ae-4aa2-9c93-205880fc6564
      -- end
      -- for k,v in pairs(Ext.Stats.Get(Object)) do
        -- if Object:find("SKILLBOOK") then
          -- Ext.Print("Object",Object,k,v)
          -- Object	SKILLBOOK_Warrior_GroundSmash	ModifierType	Item
          -- Object	SKILLBOOK_Warrior_GroundSmash	Act	1
          -- Object	SKILLBOOK_Warrior_GroundSmash	Act part	1
          -- Object	SKILLBOOK_Warrior_GroundSmash	UseAPCost	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	Value	120
          -- Object	SKILLBOOK_Warrior_GroundSmash	ComboCategory	Array<FixedString> (00007FF4A9C1E5B0)
          -- Object	SKILLBOOK_Warrior_GroundSmash	Weight	500
          -- Object	SKILLBOOK_Warrior_GroundSmash	Strength	None
          -- Object	SKILLBOOK_Warrior_GroundSmash	Finesse	None
          -- Object	SKILLBOOK_Warrior_GroundSmash	Intelligence	None
          -- Object	SKILLBOOK_Warrior_GroundSmash	Constitution	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	Memory	None
          -- Object	SKILLBOOK_Warrior_GroundSmash	Wits	None
          -- Object	SKILLBOOK_Warrior_GroundSmash	Vitality	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	Armor	None
          -- Object	SKILLBOOK_Warrior_GroundSmash	FireResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	EarthResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	WaterResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	AirResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	PoisonResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	PiercingResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	PhysicalResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	ShadowResistance	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	Flags	table: 00007FF4AD608E38
          -- Object	SKILLBOOK_Warrior_GroundSmash	Requirements	Array<stats::Requirement> (00007FF4A9C1E530)
          -- Object	SKILLBOOK_Warrior_GroundSmash	InventoryTab	Magical
          -- Object	SKILLBOOK_Warrior_GroundSmash	RootTemplate	d47a4597-ce6d-4172-b14e-a52228c2df22
          -- Object	SKILLBOOK_Warrior_GroundSmash	ObjectCategory	SkillbookWarriorStarter
          -- Object	SKILLBOOK_Warrior_GroundSmash	MinAmount	1
          -- Object	SKILLBOOK_Warrior_GroundSmash	MaxAmount	1
          -- Object	SKILLBOOK_Warrior_GroundSmash	Priority	1
          -- Object	SKILLBOOK_Warrior_GroundSmash	Unique	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	MinLevel	1
          -- Object	SKILLBOOK_Warrior_GroundSmash	RuneEffectWeapon	
          -- Object	SKILLBOOK_Warrior_GroundSmash	RuneEffectUpperbody	
          -- Object	SKILLBOOK_Warrior_GroundSmash	RuneEffectAmulet	
          -- Object	SKILLBOOK_Warrior_GroundSmash	RuneLevel	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	MaxLevel	0
          -- Object	SKILLBOOK_Warrior_GroundSmash	AddToBottomBar	No
          -- Object	SKILLBOOK_Warrior_GroundSmash	IgnoredByAI	No
        -- end
      -- end
    -- end
    
    
    -- TreasureTable
    -- Object	ST_SkillbookAir	table: 00007FF46EF9B260
    -- 1 Object	ST_SkillbookAir	IgnoreLevelDiff	false
    -- 1 Object	ST_SkillbookAir	CanMerge	false
    -- 1 Object	ST_SkillbookAir	Name	ST_SkillbookAir
    -- 1 Object	ST_SkillbookAir	MinLevel	0
    -- 1 Object	ST_SkillbookAir	SubTables	table: 00007FF46EF9B298
    -- 2 Object	ST_SkillbookAir	1	table: 00007FF46EF9B2D0
    -- 3 Object	ST_SkillbookAir	EndLevel	0
    -- 3 Object	ST_SkillbookAir	Categories	table: 00007FF46EF9B308
    -- 4 Object	ST_SkillbookAir	1	table: 00007FF46EF9B340
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_ShockingTouch
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	2	table: 00007FF46EF9B378
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_FavourableWind
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	3	table: 00007FF46EF9B3B0
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_LightningBolt
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	4	table: 00007FF46EF9B3E8
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_BlindingRadiance
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	5	table: 00007FF46EF9B500
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_EvasiveManeuver
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	6	table: 00007FF46EF9B538
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_Teleportation_FreeFall
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	7	table: 00007FF46EF9B570
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_DazingBolt
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	8	table: 00007FF46EF9B5A8
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_ChainLightning
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	9	table: 00007FF46EF9B5E0
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_Netherswap
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	10	table: 00007FF46EF9B618
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_Apportation
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	11	table: 00007FF46EF9B650
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_PressureSpike
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	12	table: 00007FF46EF9B688
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_ElectricFence
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	13	table: 00007FF46EF9B6C0
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_Tornado
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	14	table: 00007FF46EF9B730
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_Superconductor
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 4 Object	ST_SkillbookAir	15	table: 00007FF46EF9B768
    -- 5 Object	ST_SkillbookAir	Divine	0
    -- 5 Object	ST_SkillbookAir	Uncommon	0
    -- 5 Object	ST_SkillbookAir	TreasureCategory	I_SKILLBOOK_Air_Lightning
    -- 5 Object	ST_SkillbookAir	Common	0
    -- 5 Object	ST_SkillbookAir	Legendary	0
    -- 5 Object	ST_SkillbookAir	Epic	0
    -- 5 Object	ST_SkillbookAir	Frequency	1
    -- 5 Object	ST_SkillbookAir	Unique	0
    -- 5 Object	ST_SkillbookAir	Rare	0
    -- 3 Object	ST_SkillbookAir	DropCounts	table: 00007FF46EF9B7A0
    -- 4 Object	ST_SkillbookAir	1	table: 00007FF46EF9B7D8
    -- 5 Object	ST_SkillbookAir	Chance	1
    -- 5 Object	ST_SkillbookAir	Amount	1
    -- 3 Object	ST_SkillbookAir	StartLevel	0
    -- 3 Object	ST_SkillbookAir	TotalCount	1
    -- 1 Object	ST_SkillbookAir	UseTreasureGroupContainers	false
    -- 1 Object	ST_SkillbookAir	MaxLevel	0