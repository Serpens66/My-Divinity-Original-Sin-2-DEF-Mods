



Game.Tooltip.Register.Ability(function(char, ability, tooltip)
  if ability=="Perseverance" then
    for _, entry in ipairs(tooltip.Data) do
      if entry.Type=="AbilityDescription" then
        entry.Description2 = entry.Description2.."Also increases the chance to resist a status via armor by +1% per point, even if you have no armor left."
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


