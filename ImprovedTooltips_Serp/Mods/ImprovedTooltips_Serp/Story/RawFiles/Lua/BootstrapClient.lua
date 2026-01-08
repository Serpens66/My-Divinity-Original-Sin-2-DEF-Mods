

local MissingExtenderSurfaces = {DeathfogCloud="c651b724-32e2-4e34-99b4-272826ac3e37"}

-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Epip uses skill tooltips to display some tooltips, ignore them by checking if the tooltip has Cooldown
-- must load after Epip to notice this
local function IsValidSkillTooltip(tooltip)
  if tooltip and tooltip.Data then
    for _, entry in ipairs(tooltip.Data) do
      if entry["Type"]=="SkillCooldown" then
        return true
      end
    end
  end
  return false
end

-- Tooltip improvements
-- Game.Tooltip.Register
-- {
	-- "Ability" : "function: 00007FF473BEFE28",
	-- "CustomStat" : "function: 00007FF473C74848",
	-- "Generic" : "function: 00007FF473C74870",
	-- "Global" : "function: 00007FF473BEFE00",
	-- "Item" : "function: 00007FF473C74898",
	-- "PlayerPortrait" : "function: 00007FF473C748C0",
	-- "Pyramid" : "function: 00007FF473C748E8",
	-- "Rune" : "function: 00007FF473C74910",
	-- "Skill" : "function: 00007FF473C74938",
	-- "Stat" : "function: 00007FF473C74960",
	-- "Status" : "function: 00007FF473C74988",
	-- "Surface" : "function: 00007FF473C749B0",
	-- "Tag" : "function: 00007FF473C749D8",
	-- "Talent" : "function: 00007FF473C74A00",
	-- "World" : "function: 00007FF473C74A28"
-- }

-- Improve skill tooltips
-- Add Info about who can be targeted with a Skill
-- using color does not seem to work.. <font color='5ec2ffff'>
Game.Tooltip.Register.Skill(function(char, skill, tooltip)
  if IsValidSkillTooltip(tooltip) then
    local charGuid = char.MyGuid
    local MyStat = Ext.Stats.Get(skill)
    if MyStat then
      
      -- Info about surface a skill creates
      local surfaces = {}
      local SkillProperties = MyStat["SkillProperties"] -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
      if SkillProperties and type(SkillProperties)=="table" then
        -- Ext.Print("ImprovedTooltips Skill Tooltip SkillProperties",skill,_D(SkillProperties))
      -- [{	"Action" : "CreateSurface",
      -- "Arg1" : 3.0,
      -- "Arg2" : 0.0,
      -- "Arg3" : "Oil",
      -- "Arg4" : 1.0,
      -- "Arg5" : 0.0,
      -- "Context" : ["Target","AoE"],
      -- "StatusHealType" : "None",
      -- "Type" : "GameAction"}]
      -- Shout_PoisonWave
      -- [{"Action" : "TargetCreateSurface",
        -- "Arg1" : 4.0,
        -- "Arg2" : 0.0,
        -- "Arg3" : "PoisonCloud",
        -- "Arg4" : 1.0,
        -- "Arg5" : 1.0,
        -- "Context" :
        -- ["Self"],
        -- "StatusHealType" : "None",
        -- "Type" : "GameAction"}]
        for _,entry in pairs(SkillProperties) do
          if entry.Action=="CreateSurface" or entry.Action=="TargetCreateSurface" then
            table.insert(surfaces,{SurfaceType=entry.Arg3,SurfaceLifetime=entry.Arg2~=0 and entry.Arg2/6,SurfaceRadius=entry.Arg1,SurfaceStatusChance=nil})
          end
        end
      end
      local StatSurfaceType = MyStat.SurfaceType
      if StatSurfaceType and StatSurfaceType~="None" then
        table.insert(surfaces,{SurfaceType=StatSurfaceType,SurfaceLifetime=MyStat.SurfaceLifetime,SurfaceRadius=MyStat.SurfaceRadius,SurfaceStatusChance=MyStat.SurfaceStatusChance})
      end
      for _,surfaceinfo in ipairs(surfaces) do
        local SurfaceRadius = surfaceinfo.SurfaceRadius
        local SurfaceLifetime = surfaceinfo.SurfaceLifetime
        local SurfaceType = surfaceinfo.SurfaceType
        local SurfaceStatusChance = surfaceinfo.SurfaceStatusChance
        local SurfaceText = ""
        if SurfaceRadius and SurfaceRadius>0 then -- else it will be the AreaRadius/affected radius of the skill
          SurfaceText = SurfaceText.."SurfaceRadius: "..tostring(SurfaceRadius).." m\n"
        end
        if SurfaceLifetime and SurfaceLifetime>0 then
          SurfaceText = SurfaceText.."SurfaceLifetime: "..tostring(round(SurfaceLifetime/6,1)).." turns\n"
        elseif SurfaceType~="DamageType" then
          local status,template = pcall(Ext.Surface.GetTemplate,SurfaceType) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
          if status==false and MissingExtenderSurfaces[SurfaceType] then
            template = Ext.Template.GetTemplate(MissingExtenderSurfaces[SurfaceType])
            if not template then
              Ext.Print("ImprovedTooltips: Surface.GetTemplate faild (add it manually to MissingExtenderSurfaces) to get template for:",SurfaceType)
            end
          end
          if template then
            local DefaultLifeTime = template.DefaultLifeTime
            if DefaultLifeTime and DefaultLifeTime>0 then
              SurfaceText = SurfaceText.."SurfaceLifetime: "..tostring(round(DefaultLifeTime/6,1)).." turns\n"
            end
          end
        end
        if SurfaceStatusChance and SurfaceStatusChance>0 then
          SurfaceText = SurfaceText.."SurfaceStatusChance: "..tostring(SurfaceStatusChance).." %"
        end
        -- "\nSurfaceGrowStep: "..tostring(SurfaceGrowStep).."\nSurfaceGrowInterval: "..tostring(SurfaceGrowInterval) -- dont think Grow is important to know?
        local entry = {Type="SkillExplodeRadius",Label="Creates Surface "..tostring(SurfaceType).."\n"..SurfaceText}
        table.insert(tooltip.Data,entry)
      end
      
      local TargetConditions = MyStat["TargetConditions"]
      if TargetConditions then
        TargetConditions = TargetConditions:gsub("&!Spirit", "") -- remove this because true for nearly all skills
        TargetConditions = TargetConditions:gsub("!Spirit", "")
        if TargetConditions=="" then
          TargetConditions = "All"
        end
        local CanTarget = {}
        if MyStat.CanTargetCharacters=="Yes" then
          table.insert(CanTarget,"Char")
        end
        if MyStat.CanTargetTerrain=="Yes" then
          table.insert(CanTarget,"Ground")
        end
        if MyStat.CanTargetItems=="Yes" then
          table.insert(CanTarget,"Item")
        end
        local AreaRadius = MyStat.AreaRadius
        AreaRadius = AreaRadius and AreaRadius>0 and tostring(AreaRadius) or ""
        if AreaRadius~="" then
          local entry = {Type="SkillExplodeRadius",Value=tostring(AreaRadius).."m",Label="Area Radius:"} -- will display 2 times SkillExplodeRadius if it also has a vanilla exploderadius
          table.insert(tooltip.Data,entry)
        end
        local GroundSkillTypes = {"Path","Rain","Cone","Dome","Jump","Quake","Shout","Storm","Summon","Tornado","Wall","Zone"}
        if table_contains_value(GroundSkillTypes,MyStat.SkillType) then
          if not table_contains_value(CanTarget,"Ground") then
            table.insert(CanTarget,"Ground")
          end
        end
        
        local entry = {Type="SkillExplodeRadius",Label="Target Conditions: "..TargetConditions} -- not using Value here, because it is limited in characters, to many will not be displayed
        table.insert(tooltip.Data,entry)
        if #CanTarget>0 then
          local entry = {Type="SkillExplodeRadius",Value=table.concat(CanTarget, ","),Label="Can Target:"} -- will display 2 times SkillExplodeRadius if it also has a vanilla exploderadius
          table.insert(tooltip.Data,entry)
        end    
      end
      for _, entry in ipairs(tooltip.Data) do -- display left cooldown in tooltip, because icon does not display properly for higher than 99
        if entry.Type=="SkillRequiredEquipment" and entry.RequirementMet==false and char.SkillManager.Skills[skill] then
          local cooldownleft = char.SkillManager.Skills[skill].ActiveCooldown -- in seconds, not turns. 1 turn=6 seconds
          if cooldownleft~=0 then
            cooldownleft = tostring( math.ceil(cooldownleft / 6) )
            entry.Label = "("..cooldownleft..") "..entry.Label
          end
        end
      end
      -- for _, entry in ipairs(tooltip.Data) do
        -- for k,v in pairs(entry) do
          -- print(charGuid,skill,k,v)
        -- end
        -- print("...")
      -- end
      -- print("####")
    end
  end
end)


-- TODO:
-- Surface Tooltip anpassen:
-- 1) Wasserschaden header von wasserfläche in Wasser umwandeln
-- 2) Stati die verursacht werden können mit Chance zufügen
-- Statuschance can be overriden by skill which caused it with SurfaceType SurfaceStatusChance, dont think we can catch it here..
Game.Tooltip.Register.Surface(function(char,SurfaceType,tooltip)
  
  if SurfaceType=="Water" then -- fix german Label for Water
    for _,entry in ipairs(tooltip.Data) do
      if entry.Type=="Title" and entry.Label=="Wasserschaden" then
        entry.Label = "Wasser"
      end
    end
  end
  
  local status,template = pcall(Ext.Surface.GetTemplate,SurfaceType) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
  if status==false and MissingExtenderSurfaces[SurfaceType] then
    template = Ext.Template.GetTemplate(MissingExtenderSurfaces[SurfaceType])
    if not template then
      Ext.Print("ImprovedTooltips: Surface.GetTemplate failed (add it manually to MissingExtenderSurfaces) to get template for:",SurfaceType)
    end
  end
  if template then
    local Statuses = template.Statuses
    if Statuses then
      SurfaceStatusText = ""
      for _,statusinfo in pairs(Statuses) do
        if (statusinfo.StatusId~="FOGBLIND_SERP" or statusinfo.RemoveStatus==false) and statusinfo.ApplyToCharacters then -- I added in my mod MoreSurfaceEffects to all surfaces that they remove my status, that is not important to show
          local SStat = Ext.Stats.Get(statusinfo.StatusId)
          local statusname_loc = SStat and Ext.L10N.GetTranslatedStringFromKey(SStat.DisplayName,statusinfo.StatusId) or statusinfo.StatusId
          local addremove = statusinfo.RemoveStatus and "\n Removes " or "\n Adds "
          local IgnoresArmor = statusinfo.ForceStatus and "\n   Ignores Armor" or ""
          local KeepAlive = statusinfo.KeepAlive and "\n   Stays Active" or ""
          local OnlyWhileMoving = statusinfo.OnlyWhileMoving and "\n   Only While Moving" or ""
          local VanishOnReapply = statusinfo.VanishOnReapply and "\n   Removes Surface" or ""
          SurfaceStatusText = SurfaceStatusText..addremove..statusname_loc.."\n   Chance: "..tostring(round(statusinfo.Chance*100,2)).." %\n   Duration: "..tostring(round(statusinfo.Duration/6,1)).." turns"..IgnoresArmor..KeepAlive..VanishOnReapply
        end
      end
      if SurfaceStatusText~="" then
        for _,entry in ipairs(tooltip.Data) do
          if entry.Type=="SurfaceDescription" then
            entry.Label = entry.Label..SurfaceStatusText
          end
        end
      end
    end
  end
end)

-- Surface
-- {
	-- "ControllerEnabled" : false,
	-- "Data" : 
	-- [
		-- {
			-- "Label" : "Blut",
			-- "Type" : "Title"
		-- },
		-- {
			-- "Label" : "Kann unter Strom gesetzt und eingefroren werden.",
			-- "Type" : "SurfaceDescription"
		-- }
	-- ],
	-- "TooltipUIType" : 43,
	-- "UIType" : 43
-- }


-- Surface template
-- "Statuses" :
  -- [
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : false,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : true,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : false,
                  -- "StatusId" : "INVISIBLE",
                  -- "VanishOnReapply" : false
          -- },
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : true,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : false,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : true,
                  -- "StatusId" : "MUTED",
                  -- "VanishOnReapply" : false
          -- }
  -- ],



-- Game.Tooltip.RegisterListener(function(request, tooltip)
  -- print("TOOLTIP",request.Type)
  -- _D(request)
  -- _D(tooltip.Data)
-- end)



