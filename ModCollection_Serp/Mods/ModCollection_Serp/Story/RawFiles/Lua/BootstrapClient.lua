Ext.Require("Shared_Serp.lua")


-- Ext.Print("Client Script Started Serp66 Mod Collection")


-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
Ext.Events.StatsLoaded:Subscribe(function(e)
  SharedFns.OnStatsLoaded(e)
end)



-- Improve skill tooltips
-- Add Info about who can be targeted with a Skill
Game.Tooltip.Register.Skill(function(char, skill, tooltip)
  local charGuid = char.MyGuid
  local MyStat = Ext.Stats.Get(skill)
  if MyStat then
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
      if SharedFns.table_contains_value(GroundSkillTypes,MyStat.SkillType) then
        if not SharedFns.table_contains_value(CanTarget,"Ground") then
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
end)

Game.Tooltip.Register.Ability(function(char, ability, tooltip)
  local charGuid = char.MyGuid
  if ability=="Summoning" then
    for _, entry in ipairs(tooltip.Data) do
      if entry.Type=="AbilityDescription" then
        entry.Description2 = entry.Description2.."Get one extra summon with Summoning 3"
        break
      end
    end
  elseif ability=="Perseverance" then
    for _, entry in ipairs(tooltip.Data) do
      if entry.Type=="AbilityDescription" then
        entry.Description = entry.Description.." Triggers also for: Charmed, Chicken Form, Crippled and Sleep."
        entry.Description2 = entry.Description2.."Also increases the chance to resist a status via armor by +1% per point, even if you have no armor left."
        break
      end
    end
  elseif ability=="Leadership" then -- change range to new value
    for _, entry in ipairs(tooltip.Data) do
      if entry.Type=="AbilityDescription" then
        entry.Description = entry.Description:gsub(" 8m ", " 12m ")
        entry.Description = entry.Description:gsub(" 8 m ", " 12 m ")
        break
      end
    end
  end
  -- for _, entry in ipairs(tooltip.Data) do
    -- for k,v in pairs(entry) do
      -- print(ability,k,v)
    -- end
    -- print("...")
  -- end
  -- print("####")
end)



