-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md and the changelogs for v56 onwards, because they are not included in docu

SharedFns = {}

function SharedFns.RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.Osiris.RegisterListener(event, arity, state, function(...)
		if Ext.Server.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError(err)
			end
		end
	end)
end

-- returns the first key from table with value x
SharedFns.table_contains_value = function(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end

-- ##################################################


SharedFns.OnStatsLoaded = function(e)
  Ext.Stats.GetRaw("MADNESS")["ImmuneFlag"] = "MadnessImmunity" -- to allow immunity against Madness 
  Ext.Stats.Sync("MADNESS",false) -- sync to all clients
end



-- der IndomitableForAll Mod looped durch alle Stati die die entsprechenden ImmuneFlagg hat um alle Stati zu finden,vorallem auch welche von Mods.
-- Allerdings warum sollte ein Mod einen Status zufügen, der die ImmuneFlag KnockedDown hat? Mods die neue CC Stati zufügen, werden so doch auch nicht erkannt.
-- Sehe ich nicht, also hardcode ich die Stati stattdessen (offenbar kann man auch weder aus status noch aus dazugehörigem potion rauslesen, welche Stati die Runde skippen lassen?! sonst hätte er das ja genommen und ich find auch nichts)
SharedFns.Indomitable_Block_Stati = {"CHICKEN","FROZEN","PETRIFIED","STUNNED","KNOCKED_DOWN","CRIPPLED","CHARMED","MADNESS"}
SharedFns.Indomitable_Duration = 3 -- turns
SharedFns.OnCharacterStatusRemoved = function(target, status, nilSource)
  if SharedFns.table_contains_value(SharedFns.Indomitable_Block_Stati,status) and Osi.HasActiveStatus(target,"INDOMITABLE_SERP")==0 then
    if Osi.CharacterIsDead(target)==0 and Osi.ObjectIsOnStage(target)==1 then
      Osi.ApplyStatus(target,"INDOMITABLE_SERP",SharedFns.Indomitable_Duration*6,1)
      -- Ext.Print("OnCharacterStatusRemoved added INDOMITABLE",target)
    end
  end
end


