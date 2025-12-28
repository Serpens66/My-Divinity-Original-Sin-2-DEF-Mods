Ext.Require("Shared_Serp.lua")


-- Ext.Print("CLient Script Started Serp66")


-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
Ext.Events.StatsLoaded:Subscribe(function(e)
  SharedFns.OnStatsLoaded(e)
end)