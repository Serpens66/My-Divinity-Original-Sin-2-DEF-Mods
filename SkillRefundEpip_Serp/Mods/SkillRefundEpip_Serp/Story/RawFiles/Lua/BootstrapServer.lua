-- https://www.pinewood.team/epip/Features/CustomScripts/

-- When unlearning a skill via rightclick with Epip, get a Skillbook of this skill in the inventory (if a skillbook for this exists)
-- Load this script at least as server (will give skillbook back). Epip Modsettings CustomScripts enter "UnlearnSkillbook"
-- Load also as client (Shared) if you want the hovering tooltip show if you will get a skillbook for the specific skill or not

-- Ext.Print("SkillRefundBook Server")

-- ################################################



local Unlearn = Mods and Mods.EpipEncounters and Mods.EpipEncounters.Epip and Mods.EpipEncounters.Epip.GetFeature("Features.UnlearnSkills")
if Unlearn then
  
  local SkillbookTemplates = Mods.EpipEncounters.Epip.GetFeature("SkillbookTemplates")
  
  Unlearn.GiveSkillbook = function(char,skill)
    local charGUID = char.MyGuid
    local skillbook_template = SkillbookTemplates.GetForSkill(skill)
    if skillbook_template and type(skillbook_template)=="table" and skillbook_template[1] then
      Osi.ItemTemplateAddTo(skillbook_template[1],charGUID,1,1) -- (STRING)_ItemTemplate, (GUIDSTRING)_Object, (INTEGER)_Count, (INTEGER)_ShowNotification 
    end
  end
  
  local old_UnlearnSkill = Unlearn.UnlearnSkill
   Unlearn.UnlearnSkill = function(char, skill,...)
    if old_UnlearnSkill and type(old_UnlearnSkill=="function") then
      old_UnlearnSkill(char, skill,...)
    end
    
    Unlearn.GiveSkillbook(char,skill)
    
  end
else
  Ext.Print("SkillRefundBook did not find Epip Unlearn")  
end