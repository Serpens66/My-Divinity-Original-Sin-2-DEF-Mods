Ext.Require("Shared.lua")

local function RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.Osiris.RegisterListener(event, arity, state, function(...)
		if Ext.Server.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError("AutoLearnSkill_Serp: ERROR: ",err)
			end
		end
	end)
end



-- ######################################

-- LeaderLib Settings
Ext.Events.SessionLoaded:Subscribe(function (ev)
  if Mods.LeaderLib then -- LeaderLib (outside of SessionLoaded it is nil if LeaderLib is not loaded first..)
    
    -- also called on game load with current settings
    Mods.LeaderLib.Events.ModSettingsChanged:Subscribe(function (e)
      print("Server ImprovedTooltips_Serp: settings changed",e.ID,"to",e.Value)
      
      Ext.Net.BroadcastMessage("ImprovedTooltips_Serp_ModSettings",Ext.Json.Stringify({ID=e.ID,Value=e.Value}))
    end, {MatchArgs={ModuleUUID=ModuleUUID}})
    
  end
end)