Ext.Require("Shared_Serp.lua")


-- Ext.Print("Client Script Started Serp66 Mod Collection")


-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
Ext.Events.StatsLoaded:Subscribe(function(e)
  SharedFns.OnStatsLoaded(e)
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


-- _D(Game.Tooltip.Register)
