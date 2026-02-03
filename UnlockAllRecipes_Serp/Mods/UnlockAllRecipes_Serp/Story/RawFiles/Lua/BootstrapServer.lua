
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


RegisterProtectedOsirisListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
  for i,combo in pairs(Ext.Stats.GetStats("ItemCombination")) do
    local recipe = Ext.Stats.ItemCombo.GetLegacy(combo)
    -- Osi.UnlockJournalRecipe(recipe.Name) -- seems not to work
    Osi.CharacterUnlockRecipe(Osi.CharacterGetHostCharacter(),recipe.Name,1) -- seems still every char learns it this way
  end
end)

