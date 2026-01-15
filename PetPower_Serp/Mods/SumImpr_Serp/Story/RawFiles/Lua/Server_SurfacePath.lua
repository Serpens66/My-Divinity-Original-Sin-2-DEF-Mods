-- Does not work reliable enough ... so we will have to stick to the vanilla charScript, which only can be added to templates by overwriting them completey...

-- Aim was to replace the vanilla CMP_Slugs.charScript with lua

-- ChangeSurfaceOnPath PROBLEM
-- 1) The Duration you set is displayed in the surface tooltip, but does not tick down. Only after the action is cancelled the surface time jumps to the surface default and then goes away. 
-- 1.5) If you dont define duration (default 0) , the surface default time is used and it also ticks down. But when you cancel the action it leaves a small spot of surface forever (solution: set duration to 1 before canceling).
-- 2) While Duration~=0 : SurfaceWaterFrozen does not create Ice while on Water, regardless of value of "CheckExistingSurfaces" (not sure what this is supposed to do?!)  But it continues creating ice as soon as no longer on Water. 
-- While Duration==0: Same like above, but as soon as the Ice melted, it will continue to create Water instead of Ice, even if leaving the water surface.
-- 2.5) A bit different with Fire: As soon as the default duration of fire ticked out, the char will continue to create new fire, but this time with infinite duration...
-- 3) What is "IgnoreIrreplacableSurfaces" supposed to do? In Leaderlib I see a comment it is related to cursed surfaces, but when I curse a surface and walk over it while using ChangeSurfaceOnPath it always replaces the cursed surface.
-- Also changing Duration/SurfaceType frequently, does not resolve the endless fire from 2.5
-- Zu unreliable. nur für summons nutzen, wenn überhaupt, nicht für npcs

Ext.Require("Shared_Serp.lua")

Ext.Print("PetPowerSerp: SurfacePath lua script loaded")

SlugSurfaceDisable=false
SlugSurfaceRadius = 0.7


-- TODO:
-- Wenn Slug brennt oder auf feuer surface ist, dann surface erstellung einstellen
 -- und wieder anfangen wenn runter.
 -- dazu geht StatusApplied event auch mit INSURFACE

-- ((CHARACTERGUID)_Character, (STRING)_Status, (GUIDSTRING)_Causee)
SharedFns.RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", function(charGUID,status,causee)
  if SharedFns.InfusionToStatus[status] then -- to make sure it is a infusion status
    local char = Ext.Entity.GetCharacter(charGUID)
    if char then
      local template = char.RootTemplate
      if template then
        local templateid = template.Id
        if templateid then
            if SharedFns.SlugsToSurface[templateid] then -- to make sure it is a slug
              local x,y,z = table.unpack(char.WorldPos)
              Osi.CreateSurfaceAtPosition(x,y,z,"SurfaceNone", 1.25, 1.0)
              if SharedFns.InfusionToSurface[status] and not SlugSurfaceDisable then
                ChangeFollowSurfaceType(charGUID,SharedFns.InfusionToSurface[status],true)
              end
            end
          end
        end
      end
    end
  end
end)



function CreateFollowSurfaceAction(charGUID,SurfaceType,Radius,char)
  char = char or Ext.Entity.GetCharacter(charGUID)
  if char then
    local surf = Ext.Surface.Action.Create("ChangeSurfaceOnPathAction")
    SurfaceType = SurfaceType:gsub("Surface","") -- without Surface in front
    surf.SurfaceType = SurfaceType
    surf.FollowObject = char.Handle
    -- surf.Duration = 12 -- dont use this, leave default of 0 (change it to 1 before cancelling to prevent a small infinite spot!), which will use the surface default. Because if ~=0 it will display duration in surface tooltip, but not tick down! only after action is cancelled it will change to surface default and finally tick down.
    surf.Radius = Radius
    -- surf.CheckExistingSurfaces = false -- default true, keine ahnung was es macht, den Eis auf Wasser bug fixed es nicht..
    -- surf.IgnoreIrreplacableSurfaces = true -- default false -- bei true hat er cursed überschrieben und bei false auch... keine ahnung was es macht, also nicht definieren ums auf default zu lassen
    Ext.Surface.Action.Execute(surf);
    return surf -- use Ext.Surface.Action.Cancel(surf.MyHandle) to cancel it
  end
end
-- local objectToFollow = Ext.Entity.GetCharacter(CharacterGetHostCharacter());local surf = Ext.Surface.Action.Create("ChangeSurfaceOnPathAction");surf.SurfaceType = "Poison";surf.FollowObject = objectToFollow.Handle;surf.Radius = 1.0;local handle = surf.MyHandle;Ext.Surface.Action.Execute(surf);surf.SurfaceType="Water";
-- ChangeSurfaceOnPathAction s are saved to savegame (level) and dont stop themself, so we have to remember or fetch them here
function GetFollowSurfaceActions(charGUID,char)
  if charGUID then
    charGUID,char = UnifycharGuid(charGUID,char) -- unify it to the .MyGuid format, to be able to check if they are equal
  end
  local Level = Ext.Entity.GetCurrentLevel()
  local surfaceactions = {}
  if Level then
    local SurfaceActions = Level.SurfaceManager.SurfaceActions
    if SurfaceActions then
      -- _D(SurfaceActions)
      for _,surfaceaction in ipairs(SurfaceActions) do
        local success,FollowObjectHandle = pcall(function() return surfaceaction.FollowObject end) -- can also contain other SurfaceActions and I dont see a way to check the Type, so using pcall: esv::CreateSurfaceAction::FollowObject - property does not exist
        if success and FollowObjectHandle then
          -- Ext.Print("GetFollowSurfaceActions",success,FollowObjectHandle,Ext.Utils.GetHandleType(FollowObjectHandle),Ext.Utils.GetHandleType(char.Handle))
          if not charGUID then
            table.insert(surfaceactions,surfaceaction) 
          elseif Ext.Utils.GetHandleType(FollowObjectHandle)==Ext.Utils.GetHandleType(char.Handle) then
            fchar = Ext.Entity.GetCharacter(FollowObjectHandle)
            local fcharGUID = fchar.MyGuid
            -- Ext.Print("GetFollowSurfaceActions",charGUID,fcharGUID)
            if fchar and fcharGUID==charGUID then
              table.insert(surfaceactions,surfaceaction) 
            end
          end
        end
      end
    end
  end
  -- Ext.Print("GetFollowSurfaceActions",charGUID,#surfaceactions)
  return surfaceactions
end

function ChangeFollowSurfaceType(charGUID,SurfaceType,createifnotexist,surfaceactions)
  surfaceactions = surfaceactions or GetFollowSurfaceActions(charGUID) -- should only be one, unless also another mod added one
  SurfaceType = SurfaceType:gsub("Surface","") -- without "Surface"
  if #surfaceactions>0 then
    for _,surfaceaction in ipairs(surfaceactions) do
      local prevDur = surfaceaction.Duration
      surfaceaction.Duration = 12 -- make the old SurfaceType expire (and not stay forever when action is canceled)
      surfaceaction.SurfaceType = SurfaceType -- seems to be enough to simply change this, I think it actually creates a new action
      surfaceaction.Duration = prevDur
    end
  elseif createifnotexist then
    CreateFollowSurfaceAction(charGUID,SurfaceType,SlugSurfaceRadius)
  end
end

function CancelAllFollowSurfaceActions(charGUID)
  local char = Ext.Entity.GetCharacter(charGUID)
  local surfaceactions = GetFollowSurfaceActions(charGUID,char)
  for _,surfaceaction in ipairs(surfaceactions) do
    -- looks like canceling leaves the rest of the surface forever? but setting Duration to 1 before canceling solves it (or set a Duration>0 on creation)
    -- this Duration Trick only works for the SurfaceType it currently has (so does not work for previous surfacetypes if you changed SurfaceType from a running action. workaround: change Duration shortly before changing SurfaceType)
    surfaceaction.Duration = 6 -- any duration ~=0
    Ext.Surface.Action.Cancel(surfaceaction.MyHandle) -- entfernt action auch aus SurfaceManager, was gut ist 
  end
end



-- using in charScript: CharacterEvent(__Me,"OnSlugShutdown_PetPowerSerp") to fire these StoryEvents
SharedFns.RegisterProtectedOsirisListener("StoryEvent", 2, "before", function(charGUID, event)
  -- print("OnObjectStoryEvent",charGUID, event)
  if Osi.ObjectIsCharacter(charGUID)==1 then
    if event=="OnSlugShutdown_PetPowerSerp" or event=="OnSlugDie_PetPowerSerp" then -- trigger both on die, not sure if shutdown can also happen when not dying? maybe out of screen?
      if not SlugSurfaceDisable then
        CancelAllFollowSurfaceActions(charGUID)
      end
    elseif event=="OnSlugActivate_PetPowerSerp" then
      if not SlugSurfaceDisable then
        local char = Ext.Entity.GetCharacter(charGUID)
        if char then
          local surfaceactions = GetFollowSurfaceActions(charGUID,char)
          if #surfaceactions==0 then -- one surface action per slug is enough..
            local template = char.RootTemplate
            if template then
              local templateid = template.Id
              if templateid and SharedFns.SlugsToSurface[templateid] then
                CreateFollowSurfaceAction(charGUID,SharedFns.SlugsToSurface[templateid],SlugSurfaceRadius,char)
              end
            end
          end
        end
      end
    end
  end
end)






-- S >> _D(Ext.Entity.GetCurrentLevel().SurfaceManager.SurfaceActions)
-- [
        -- {
                -- "CheckExistingSurfaces" : true,
                -- "Duration" : 0.0,
                -- "FollowObject" : "userdata: 0DC0000100000024",
                -- "IgnoreIrreplacableSurfaces" : false,
                -- "IgnoreOwnerCells" : false,
                -- "IsFinished" : false,
                -- "MyHandle" : "userdata: 1000000100000000",
                -- "OwnerHandle" : "userdata: 0000000000000000",
                -- "Position" :
                -- [
                        -- 212.09712219238281,
                        -- -8.0,
                        -- 75.17706298828125
                -- ],
                -- "Radius" : 1.0,
                -- "StatusChance" : 1.0,
                -- "SurfaceCollisionFlags" : 0,
                -- "SurfaceCollisionNotOnFlags" : 0,
                -- "SurfaceHandlesByType" :
                -- [
                        -- "userdata: 0000000000000000",
                        -- "userdata: 0000000000000000",
                -- ],
                -- "SurfaceType" : "Poison"
        -- }
-- ]

