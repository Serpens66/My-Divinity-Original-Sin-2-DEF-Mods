
Ext.Require("Shared.lua")

if Mods and Mods.EpipEncounters then
  Ext.Require("EpipCodex/Stati.lua")
end
  
-- current version of Epip is preventing Game.Tooltip.Register.Surface from working, but using the one from Epip itself works
local EpipSurfaceTooltips = Mods and Mods.EpipEncounters and Mods.EpipEncounters.Client.Tooltip.Hooks.RenderSurfaceTooltip



-- Add StackId to Foods/Potions
-- add applies effects to items (potions)
-- Osi.ItemTemplateAddTo("37535d5c-3262-4d2d-bcbc-c940e33ec2ca",Osi.CharacterGetHostCharacter(),1,1) -- healing elixir
Game.Tooltip.Register.Item(function(item,tooltip)
  -- _D(item)
  local addstringtodesc = CreateItemTooltipAddition(item,tooltip,true)
  
  -- print("Tooltip Item:",addstringtodesc)
  if addstringtodesc~="" then
    local found = false
    for __,tentry in ipairs(tooltip.Data) do
      if tentry.Type=="SkillDescription" then -- adding to SkillDescription instead of ItemDescription, because ItemDescription is on the bottom, which looks bad
        tentry.Label = tentry.Label..addstringtodesc
        found = true
        break
      end
    end
    if not found then
      local entry = {Type="SkillDescription",Label=addstringtodesc}
      table.insert(tooltip.Data,entry)
    end
  end
end)

-- Improve skill tooltips
-- Add Info about who can be targeted with a Skill
Game.Tooltip.Register.Skill(function(char, skill, tooltip)
  if IsValidSkillTooltip(tooltip) then
    local skilldesc = CreateSkillToolipAddition(skill,char)
    AddToTooltip(tooltip,skilldesc)
  end
end)


if EpipSurfaceTooltips then
  EpipSurfaceTooltips:Subscribe(function (ev)
    if ev.Type=="Surface" then -- SurfaceIndex in ev.UI is totally wrong unfortunately 
      local tooltip = ev.Tooltip
      tooltip.Data = tooltip.Elements
      -- local cc = Ext.UI.GetCursorControl();_D(Ext.UI.GetByHandle(cc.TextDisplayUIHandle))
      -- print(ev.UI.SurfaceIndex,_GetSurfaceNameByTypeIndex(ev.UI.SurfaceIndex)) -- also wrong
      -- print(ev.UI.SurfaceIndex2,_GetSurfaceNameByTypeIndex(ev.UI.SurfaceIndex2))
      local cursor = Ext.UI.GetPickingState()
      if cursor and cursor.WalkablePosition then
        local x,y,z = table.unpack(cursor.WalkablePosition)
        local surfaces = _GetSurfaces(x, z, Ext.Entity.GetAiGrid())
        AdjustSurfaceTooltip(surfaces.Ground,tooltip)
        AdjustSurfaceTooltip(surfaces.Cloud,tooltip)
      end
    end
  end)
else
  Game.Tooltip.Register.Surface(function(char,SurfaceType,tooltip)
    AdjustSurfaceTooltip(SurfaceType,tooltip)
  end)
end


-- Game.Tooltip.RegisterListener(function(request, tooltip)
  -- print("TOOLTIP",request.Type)
  -- _D(request)
  -- _D(tooltip.Data)
-- end)


Ext.Events.StatsLoaded:Subscribe(function(e)
  -- from Vanilla Plus mod by Luxem, lua code updated to newest extender version, also updated ImprovedTooltips_Serp\Mods\ImprovedTooltips_Serp\Localization german and english for this
  local skillList = {
		Shout_SparkingSwings = "Skill:Projectile_Status_Spark:Damage",
		Target_MasterOfSparks = "Skill:Projectile_Status_GreaterSpark:Damage",
		Target_CorpseExplosion = "Skill:Projectile_CorpseExplosion_Explosion:Damage",
		Shout_MassCorpseExplosion = "Skill:Projectile_CorpseExplosion_Explosion:Damage",
		Projectile_LaunchExplosiveTrap = "Skill:Projectile_TrapLaunched:Damage",
		Projectile_DeployMassTraps = "Skill:Projectile_TrapLaunched:Damage",
	}
	for skill,description in pairs(skillList) do
		local stat = Ext.Stats.Get(skill)
    if stat then
      local statDesc = stat["StatsDescriptionParams"]
      if statDesc ~= "" and statDesc ~= nil then
        stat["StatsDescriptionParams"] = statDesc..";"..description
      else
        stat["StatsDescriptionParams"] = description
      end
    end
	end
  
end)
  


-- ecl::StatusConsumeBase (00007FF44AB8A900)
Game.Tooltip.Register.Status(function(char,StatusConsumeBase,tooltip)
  -- print("STATUS tooltips")
  -- _D(tooltip)
  local status = StatusConsumeBase.StatusId
  if status and status~="" then
    local addstringtodesc = CreateStatusRemoveTooltip(status)
    addstringtodesc = addstringtodesc..CreateStatusStackIdSavingThowTooltip(status)
    if addstringtodesc~="" then
      for _,entry in ipairs(tooltip.Data) do
        if entry.Type=="StatusDescription" then
          entry.Label = entry.Label..addstringtodesc
          break
        end
      end
    end
    
  end
end)

-- CurrentPressedKeys["Shift"]
CurrentPressedKeys = {}
-- https://gist.github.com/PinewoodPip/57e20c3239eb45c26a04499b189cc744#file-ext-lua-L3250
Ext.Events.RawInput:Subscribe(function(e)
  local inputEventData = e.Input
  local id = tostring(inputEventData.Input.InputId)
  local deviceType = tostring(inputEventData.Input.DeviceId)
  if id == "" then return end -- Happens for unsupported keys, ex. media keys.
  if deviceType=="Key" and (id=="lshift" or od=="rshift") then -- currently we only care for them
    if inputEventData.Value.State == "Pressed" then
      CurrentPressedKeys["Shift"] = true
      -- updating currently shown tooltip is too complicated (hide and show again, but I need all the info of current tooltip, no clue how to easily get them)
      -- so only works if first holding Shift and then hovering over object to show tooltip
    else
      CurrentPressedKeys["Shift"] = nil
    end
  end
end)




