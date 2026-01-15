Ext.Events.StatsLoaded:Subscribe(function(e)
  
  -- make medusa head skill free to cast, but remove the petrifying aura. instead give Shout_PetrifyingVisage_Lesser with no cooldown in low range with no damage
  local stat = Ext.Stats.Get("Shout_MedusaHead")
  if stat then
    stat.ActionPoints = 0
  end
  stat = Ext.Stats.Get("MEDUSA_HEAD")
  if stat then
    stat.AuraRadius = 0
    stat.AuraEnemies = ""
    stat.Skills = stat.Skills..";Shout_PetrifyingVisage_Lesser"
  end
  -- print(Ext.Stats.Get("MEDUSA_HEAD").Skills)
  
  stat = Ext.Stats.Get("SLEEPING")
  if stat then
    stat.StackId = "Stack_Sleeping"
  end
  
  
  stat = Ext.Stats.Get("Quake_Earthquake")
  if stat then
    local SkillProperties = stat.SkillProperties -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
    if SkillProperties and type(SkillProperties)=="table" then
      for _,entry in pairs(SkillProperties) do
        if entry.Action=="KNOCKED_DOWN" then
          entry.Action = "MAGICKNOCKDOWN"
          break
        end
      end
      stat.SkillProperties = SkillProperties
    end
  end
  
  stat = Ext.Stats.Get("Projectile_Chloroform")
  if stat then
    stat.DamageType = "Corrosive"
    local SkillProperties = stat.SkillProperties -- in Stat ists eine table, daher einfacher strukturiert, als die userdata in GetRaw
    if SkillProperties and type(SkillProperties)=="table" then
      for _,entry in pairs(SkillProperties) do
        if entry.Action=="SLEEPING" then
          entry.Action = "SLEEPING_PHYSICAL"
          break
        end
      end
      stat.SkillProperties = SkillProperties
    end
  end
  
  
  
  
  
end)