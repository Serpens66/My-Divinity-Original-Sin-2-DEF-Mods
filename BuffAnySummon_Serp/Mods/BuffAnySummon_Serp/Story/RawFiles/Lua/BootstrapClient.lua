Ext.Require("Shared_Serp.lua")


-- Ext.Print("CLient Script Started Serp66")


-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
Ext.Events.StatsLoaded:Subscribe(function(e)
  SharedFns.OnStatsLoaded(e)
end)


--Update tooltips
Game.Tooltip.Register.Skill(function(char, skill, tooltip)
  -- Ext.Print("Tooltip Skill: ",char, skill, tooltip)
  if skill:find("Infusion",1,true) then
    for _, entry in ipairs(tooltip.Data) do
      if entry.Type=="SkillDescription" then
        entry.Label = entry.Label.."\n(Can target any Summon)\n"
      end
      -- for k,v in pairs(entry) do
        -- Ext.Print(k,v)
      -- end
    end
  end
end)
-- Label	Fernsichtdurchtränkung
-- Type	SkillName
-- Label	Skill_Summoning_RangedInfusion
-- Type	SkillIcon
-- Label	<font color="#7F25D4">Beschwören</font>
-- Icon	11.0
-- Type	SkillSchool
-- Label	Anfänger
-- Type	SkillTier
-- Label	Erfordert Beschwören 1<br>
-- RequirementMet	true
-- Type	SkillRequiredEquipment
-- Warning	
-- RequirementMet	true
-- Type	SkillAPCost
-- Label	Benutzen
-- Value	1.0
-- Warning	
-- Type	SkillCooldown
-- Label	Abklingzeit
-- ValueText	3 Runde(n)
-- Value	3.0
-- Label	Schaltet den Fernkampfangriff für deine Inkarnation frei. Bietet <font color="#97FBFF">16 Magische Rüstung</font> (die Höhe hängt von deiner Stufe ab). Erhöht Schaden um 25 %.
-- Type	SkillDescription
-- Properties	table: 00007FF3E094D308
-- Resistances	table: 00007FF3E094D340
-- Type	SkillProperties
-- Label	Reichweite
-- Value	15m
-- Type	SkillRange
