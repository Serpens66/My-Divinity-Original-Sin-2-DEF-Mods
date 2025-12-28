
-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
-- Sync is not needed (and may cause bugs) within StatsLoaded
Ext.Events.StatsLoaded:Subscribe(function(e)
  
  Ext.ExtraData["TalentQuickStepPartialApBonus"] = 4 -- make Pawn provide 10 meter (with halfed Movement in mind 4AP, since this also affects The Pawn)
  
  -- half movement speed of everyone and give everyone The Pawn talent
  local difficulty = {"StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer","StoryNPC_Character","CasualNPC","NormalNPC","HardcoreNPC"}
  for i,name in ipairs(difficulty) do
    local msb = Ext.Stats.GetRaw(name)["MovementSpeedBoost"] -- half movement speed
    if msb==0 then
      Ext.Stats.GetRaw(name)["MovementSpeedBoost"] = -50
    elseif msb>0 then
      Ext.Stats.GetRaw(name)["MovementSpeedBoost"] = msb/2 -- +50 becomes +25
    elseif msb<0 then
      Ext.Stats.GetRaw(name)["MovementSpeedBoost"] = msb + msb/2 --  -50 becomes -75
    end
    
    if string.find(name,"NPC") then -- for fixed Talents and NPC here, but players in OnSaveLoaded and so on, to also grant a talent point for free, in case they already had the talent
      talents = Ext.Stats.GetRaw(name)["Talents"] or ""
      newtalents = {"QuickStep"}
      for _,newtalent in ipairs(newtalents) do
        if not string.find(talents,newtalent) then
          talents = tostring(talents)..";"..tostring(newtalent)
        end
      end
      Ext.Stats.GetRaw(name)["Talents"] = talents
    end
  end
  
end)