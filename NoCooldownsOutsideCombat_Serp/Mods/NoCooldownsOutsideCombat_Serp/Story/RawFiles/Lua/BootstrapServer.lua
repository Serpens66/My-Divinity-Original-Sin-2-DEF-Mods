
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


-- SkillCast((CHARACTERGUID)_Character, (STRING)_Skill, (STRING)_SkillType, (STRING)_SkillElement)
RegisterProtectedOsirisListener("SkillCast", 4, "after", function(charGUID, skill, skilltype, skillelement)
  if Osi.ObjectIsCharacter(charGUID)==1 and Osi.CharacterIsInCombat(charGUID)==0 then -- [in](GUIDSTRING)_Object, [out](INTEGER)_Bool 
    local cooldown = Osi.NRD_SkillGetCooldown(charGUID,skill) -- in seconds
    if cooldown and cooldown~=0 and cooldown<=60 then -- only for cooldowns <= 10 turns
      Osi.NRD_SkillSetCooldown(charGUID,skill, 0.0)
    end
  end
end)
