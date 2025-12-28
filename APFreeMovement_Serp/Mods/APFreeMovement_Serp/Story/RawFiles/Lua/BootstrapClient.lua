
-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
-- Sync is not needed (and may cause bugs) within StatsLoaded
Ext.Events.StatsLoaded:Subscribe(function(e)
  
  Ext.ExtraData["TalentQuickStepPartialApBonus"] = 4 -- make Pawn provide 10 meter (with halfed Movement in mind 4AP, since this also affects The Pawn)

  -- MovementSpeedBoost halbiert auch die Laufgeschwindigkeit, also die Animation noch verdoppeln
  -- und die chars gehen nur noch hinterher und laufen nicht?!
  -- Mit Movement = Momvement/2 ist animation gut und hinterher laufen auch
  -- aber KI läuft dennoch deutlich kürzer als ich...
  -- wobei einer der KIs vernünftig läuft, aber die andern nicht, obwohl alle das Talent haben..
  -- So not using MovementSpeedBoost and leave NPC Movement unchanged (but still give them QuickStep to not have too much advantage over them)
  -- (achging it for "Hero" containing Chracters only, does not change it for Story character)
  local basemovement = Ext.Stats.GetRaw("_Hero")["Movement"]
  for _,name in ipairs({"StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer"}) do
    summe = basemovement + Ext.Stats.GetRaw(name)["Movement"]
    Ext.Stats.GetRaw(name)["Movement"] = summe/2 - basemovement
  end
  
  -- give talent QuickStep to all NPCs (to players is done elsewhere, so we can gibe free talent point if he already has)
  local npc_difficulties = {"StoryNPC_Character","CasualNPC","NormalNPC","HardcoreNPC"}
  for i,name in ipairs(npc_difficulties) do
    talents = Ext.Stats.GetRaw(name)["Talents"] or ""
    newtalents = {"QuickStep"}
    for _,newtalent in ipairs(newtalents) do
      if not string.find(talents,newtalent) then
        talents = tostring(talents)..";"..tostring(newtalent)
      end
    end
    Ext.Stats.GetRaw(name)["Talents"] = talents
  end
  
end)