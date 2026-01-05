-- https://www.pinewood.team/epip/Features/CustomScripts/

-- When unlearning a skill via rightclick with Epip, get a Skillbook of this skill in the inventory (if a skillbook for this exists)
-- Load this script at least as server (will give skillbook back). Epip Modsettings CustomScripts enter "UnlearnSkillbook"
-- Load also as client (Shared) if you want the hovering tooltip show if you will get a skillbook for the specific skill or not


-- ################################################


local Unlearn = Mods and Mods.EpipEncounters and Mods.EpipEncounters.Epip and Mods.EpipEncounters.Epip.GetFeature("Features.UnlearnSkills")
if Unlearn then
  local SkillbookTemplates = Mods.EpipEncounters.Epip.GetFeature("SkillbookTemplates")
  -- hint when hovering over skill if you will get a skillbook back
  Game.Tooltip.Register.Skill(function(char, skill, tooltip)
    -- Ext.Print("Tooltip Skill",char, skill, tooltip)
    
    if char and char.SkillManager and char.SkillManager.Skills and char.SkillManager.Skills[skill] then
      local canUnlearn, _ = Unlearn.CanUnlearn(char, skill)
      if canUnlearn then
        local skillbook_template = SkillbookTemplates.GetForSkill(skill)
        local getbook = false
        if skillbook_template and type(skillbook_template)=="table" and skillbook_template[1] then
          getbook = true
        end
        local addtext = getbook and " (Get Skillbook)" or " (NO Skillbook)"
        for _, entry in ipairs(tooltip.Data) do
          if entry.Type=="Engraving" then
            entry.Label = entry.Label..addtext
            break
          end
        end
      end
    end
  end)
  
end