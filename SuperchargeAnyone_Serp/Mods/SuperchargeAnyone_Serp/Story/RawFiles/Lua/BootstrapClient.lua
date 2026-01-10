Ext.Events.StatsLoaded:Subscribe(function(e)
  
  local Stat = Ext.Stats.Get("Target_Supercharge")
  if Stat then
    Stat.TargetConditions = "Character&!Dead" -- instead of Summon&!Dead
  end
  
end)