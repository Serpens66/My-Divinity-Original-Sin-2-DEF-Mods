

-- StatsLoaded is Client only. Stats changes. Most compatible this way, since only this specific stat is overwritten, instead of all of this object
Ext.Events.StatsLoaded:Subscribe(function(e)
  for i,weapon in pairs(Ext.Stats.GetStats("Weapon")) do
    local MyStat = Ext.Stats.GetRaw(weapon) -- just "Get()" does not seem to work, since setting it to Strength has no effect (does not change)
    if (weapon=="_Crossbows" or MyStat.Using=="_Crossbows") and MyStat and MyStat.Requirements then
      for _,requirement in pairs(MyStat.Requirements) do
        if requirement.Requirement=="Finesse" then
          MyStat.Requirements[_].Requirement = "Strength"
        end
      end
    end
  end
  local deltamods = Ext.Stats.GetStats("DeltaMod") -- make them give Strenght as bonus instead of Finesse
	for _,v in pairs(deltamods) do
    local deltamod = Ext.Stats.DeltaMod.GetLegacy(v.Name, v.ModifierType)
    if deltamod.WeaponType=="Crossbow" then
      for __,boost in ipairs(deltamod["Boosts"]) do
        if boost["Boost"]:find("Finesse",1,true) then
          boost["Boost"] = string.gsub(boost["Boost"], "Finesse", "Strength") -- replace Finesse with Strength (hoping that the boost names are the same just with Strength)
          print("found",v.Name,"changed Boost to",boost["Boost"])
        end
      end
      Ext.Stats.DeltaMod.Update(deltamod)
    end
  end
end)

-- console command give crossbow for testing: 
-- Osi.ItemTemplateAddTo("1bf8d23b-4f71-4e2b-ab26-8dc179968f0b",Osi.CharacterGetHostCharacter(),1,1)


