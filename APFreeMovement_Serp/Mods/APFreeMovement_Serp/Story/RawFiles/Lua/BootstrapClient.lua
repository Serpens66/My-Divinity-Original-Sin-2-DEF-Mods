local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
-- Sync is not needed (and may cause bugs) within StatsLoaded
Ext.Events.StatsLoaded:Subscribe(function(e)
  
  Ext.ExtraData["TalentQuickStepPartialApBonus"] = 4 -- make Pawn provide 10 meter (with halfed Movement in mind 4AP, since this also affects The Pawn)

  Ext.ExtraData["SkillAbilityMovementSpeedPerPoint"] = Ext.ExtraData["SkillAbilityMovementSpeedPerPoint"] / 2
  Ext.ExtraData["SneakingAbilityMovementSpeedPerPoint"] = Ext.ExtraData["SneakingAbilityMovementSpeedPerPoint"] / 2

  
  -- half the absolute +- Movement values of Statusses, Equipment and other sources
  local datas = {"Armor","Shield","Weapon","Potion"}
  for _,data in ipairs(datas) do
    for i,obj in pairs(Ext.Stats.GetStats(data)) do
      local MyStat = Ext.Stats.GetRaw(obj)
      if MyStat and MyStat.Movement and (MyStat.Movement>1 or MyStat.Movement<-1) then -- not round 0...
        local status,returning = pcall(function() MyStat.Movement = round(MyStat.Movement / 2) end) -- does not suppoer decimal
        if status==false then
          print("APFreeMovement: Changing Movement failed for",data,obj,returning)
        end
      end
    end
  end
  
  -- give talent QuickStep to all NPCs (to players is done elsewhere, so we can give free talent point if he already has)
  local npc_difficulties = {"StoryNPC_Character","CasualNPC","NormalNPC","HardcoreNPC"}
  for i,name in ipairs(npc_difficulties) do
    talents = Ext.Stats.GetRaw(name)["Talents"] or ""
    newtalents = {"QuickStep"}
    for _,newtalent in ipairs(newtalents) do
      if not string.find(talents,newtalent,1,true) then
        talents = tostring(talents)..";"..tostring(newtalent)
      end
    end
    Ext.Stats.GetRaw(name)["Talents"] = talents
  end
  
  
  
--[[
  -- MovementSpeedBoost halbiert auch die Laufgeschwindigkeit, also die Animation noch verdoppeln
  -- und die chars gehen nur noch hinterher und laufen nicht?!
  -- Mit Movement = Movement/2 ist animation gut und hinterher laufen auch
  -- aber KI läuft dennoch deutlich kürzer als ich...
  -- wobei einer der KIs vernünftig läuft, aber die andern nicht, obwohl alle das Talent haben..
  -- So not using MovementSpeedBoost and leave NPC Movement unchanged (but still give them QuickStep to not have too much advantage over them)
  -- (changing it for "Hero" containing Chracters only, does not change it for Story character)
  
  -- bad to change absolute values for Movement, because these Player stats are used for all player controlled, also summons.
   -- and we dont know which basemovement all the player controlled units used, so we can not calcualte a proper absolute reduction
  -- local basemovement = Ext.Stats.GetRaw("_Hero")["Movement"] -- usually 500
  -- for _,name in ipairs({"StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer"}) do -- difficulty addition
    -- summe = basemovement + Ext.Stats.GetRaw(name)["Movement"] -- usually 500 + 0
    -- Ext.Stats.GetRaw(name)["Movement"] = summe/2 - basemovement -- usually -250 on top, so halfed movement
  -- end
  
  -- newspeed = speed * (1+boost/100)
  -- newspeed = speed * (1+100/100) = speed * 2
  -- newspeed = speed * (1+50/100) = speed * 1.5
  -- newspeed = speed * (1-50/100) = speed * 0.5
  -- (newspeed / speed * 100) - 100 = boost
  -- mult = 1+boost/100
  -- mult / 2 = 1+boost*X/100
  -- (1+boost/100) / 2 = 1 + boost*X/100 
  -- (1+boost/100) / 2 * 100 = 100 + boost*X 
  -- ((1+boost/100) / 2 * 100) -100 = boost*X 
  -- (((1+boost/100) / 2 * 100) -100) / boost = X
  -- (((1+MovementSpeedBoost/100)/2*100)-100) / MovementSpeedBoost

  -- give a MovementSpeedBoost that results in halfed speed multiplier compared to the currently set one (usually 0)
  -- to compensate for the slower moving, we give all player controlled characters char.RunSpeedOverride and WalkSpeedOverride
  -- for _,name in ipairs({"StoryPlayer","CasualPlayer","NormalPlayer","HardcorePlayer"}) do -- difficulty addition
    -- local MovementSpeedBoost = Ext.Stats.GetRaw(name)["MovementSpeedBoost"]
    -- if MovementSpeedBoost==0 then
      -- Ext.Stats.GetRaw(name)["MovementSpeedBoost"] = -50
    -- else
      -- Ext.Stats.GetRaw(name)["MovementSpeedBoost"] = MovementSpeedBoost * ((((1+MovementSpeedBoost/100)/2*100)-100) / MovementSpeedBoost)
    -- end
  -- end

--]]
  
  
  
end)