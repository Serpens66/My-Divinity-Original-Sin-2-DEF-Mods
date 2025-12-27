

Ext.Events.StatsLoaded:Subscribe(function(e)
  
  
  -- crashed
  for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    if name=="Target_RangedInfusion" then
      Ext.Stats.Sync(name,false) 
    end
  end
  
  
  -- no crash
  -- local names = {"Target_RangedInfusion"}
  -- for _,name in ipairs(names) do
    -- Ext.Stats.Sync(name,false)
  -- end
  

  -- no crash
  -- local need_sync = {}
  -- for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    -- if name=="Target_RangedInfusion" then
      -- table.insert(need_sync,name)
    -- end
  -- end
  -- for _,name in ipairs(need_sync) do
    -- Ext.Stats.Sync(name,false)
  -- end
  
  -- no crash
  -- local need_sync = {}
  -- for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    -- if name=="Target_RangedInfusion" then
      -- table.insert(need_sync,name)
      -- Ext.Stats.Sync(name,false)
    -- end
  -- end
  
  -- crashed
  -- local need_sync = {}
  -- for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    -- if name=="Target_RangedInfusion" then
      -- Ext.Print("SERPSTATSLOADED",name)
      -- Ext.Stats.Sync(name,false)
    -- end
  -- end
  
  -- no crash
  -- for i,name in pairs(Ext.Stats.GetStats("SkillData")) do
    -- Ext.Stats.Sync(name,false)
  -- end
  
  
  Ext.Print("SERPSTATSLOADED")
  
end)