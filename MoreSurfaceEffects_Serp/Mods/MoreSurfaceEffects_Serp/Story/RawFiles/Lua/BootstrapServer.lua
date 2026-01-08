
-- PROBLEM:
-- template Statuses is not writeable, although it should be according to documentation.
-- So it does not work this way... alternative is to either use my old code below or alter the templates the old way
 -- by overwriting the templates completely

--[[

-- SurfaceWater={s="WET",c=0.30,d=6,f=0,chancex2if="BURNING",forceif="BURNING"},SurfaceBlood={s="WET",c=0.20,d=6,f=0,chancex2if="BURNING",forceif="BURNING"},
  -- SurfaceWaterFrozen={s="CHILLED",c=0.20,d=6,f=0,chancex2if="WET",forceif="WET"},SurfaceBloodFrozen={s="CHILLED",c=0.20,d=6,f=0,chancex2if="WET",forceif="WET"},
  -- AnyCloud={s="FOGBLIND_SERP",c=1.0,d=6,f=1},
-- für clouds: KeepAlive=false

-- https://github.com/Norbyte/ositools/blob/master/Docs/LuaAPIDocs.md#surface-template-status
SurfaceBasedStati = {
  Blood = {{StatusId="WET",RemoveStatus=false,Chance=0.2,Duration=6,ForceStatus=0,ApplyToCharacters=true,ApplyToItems=true,OnlyWhileMoving=false,KeepAlive=true,VanishOnReapply=false},{StatusId="BURNING",RemoveStatus=true,Chance=0.6,Duration=6,ForceStatus=0,ApplyToCharacters=true,ApplyToItems=true,OnlyWhileMoving=false,KeepAlive=true,VanishOnReapply=false}},
	BloodBlessed = {},
	BloodCloud = {},
	BloodCloudBlessed = {},
	BloodCloudCursed = {},
	BloodCloudElectrified = {},
	BloodCloudElectrifiedBlessed = {},
	BloodCloudElectrifiedCursed = {},
	BloodCloudElectrifiedPurified = {},
	BloodCloudPurified = {},
	BloodCursed = {},
	BloodElectrified = {},
	BloodElectrifiedBlessed = {},
	BloodElectrifiedCursed = {},
	BloodElectrifiedPurified = {},
	BloodFrozen = {},
	BloodFrozenBlessed = {},
	BloodFrozenCursed = {},
	BloodFrozenPurified = {},
	BloodPurified = {},
	DeathfogCloud = {},
	Deepwater = {},
	ExplosionCloud = {},
	Fire = {},
	FireBlessed = {},
	FireCloud = {},
	FireCloudBlessed = {},
	FireCloudCursed = {},
	FireCloudPurified = {},
	FireCursed = {},
	FirePurified = {},
	FrostCloud = {},
	Lava = {},
	Oil = {},
	OilBlessed = {},
	OilCursed = {},
	OilPurified = {},
	Poison = {},
	PoisonBlessed = {},
	PoisonCloud = {},
	PoisonCloudBlessed = {},
	PoisonCloudCursed = {},
	PoisonCloudPurified = {},
	PoisonCursed = {},
	PoisonPurified = {},
	SmokeCloud = {},
	SmokeCloudBlessed = {},
	SmokeCloudCursed = {},
	SmokeCloudPurified = {},
	Source = {},
	SourceBlessed = {},
	SourceCursed = {},
	SourcePurified = {},
	Sulfuric = {},
	Water = {{StatusId="WET",RemoveStatus=false,Chance=1.0,Duration=6,ForceStatus=0,ApplyToCharacters=true,ApplyToItems=true,OnlyWhileMoving=false,KeepAlive=true,VanishOnReapply=false},{StatusId="BURNING",RemoveStatus=true,Chance=1.0,Duration=6,ForceStatus=0,ApplyToCharacters=true,ApplyToItems=true,OnlyWhileMoving=false,KeepAlive=true,VanishOnReapply=false}},
	WaterBlessed = {},
	WaterCloud = {},
	WaterCloudBlessed = {},
	WaterCloudCursed = {},
	WaterCloudElectrified = {},
	WaterCloudElectrifiedBlessed = {},
	WaterCloudElectrifiedCursed = {},
	WaterCloudElectrifiedPurified = {},
	WaterCloudPurified = {},
	WaterCursed = {},
	WaterElectrified = {},
	WaterElectrifiedBlessed = {},
	WaterElectrifiedCursed = {},
	WaterElectrifiedPurified = {},
	WaterFrozen = {},
	WaterFrozenBlessed = {},
	WaterFrozenCursed = {},
	WaterFrozenPurified = {},
	WaterPurified = {},
	Web = {},
	WebBlessed = {},
	WebCursed = {},
	WebPurified = {},
}
-- to find the TemplateID search the vanilla RootTemplates _merged.lxs for : <attribute id="Name" type="23" value="Surface
local MissingExtenderSurfaces = {DeathfogCloud="c651b724-32e2-4e34-99b4-272826ac3e37"}



-- Ext.Events.StatsLoaded:Subscribe(function(e)
Ext.Events.SessionLoaded:Subscribe(function (e)

  -- change surface
  for surface,stati in pairs(SurfaceBasedStati) do
    if stati and next(stati) then
      local status,template = pcall(Ext.Surface.GetTemplate,surface) -- throws error if can not find -- local template = Ext.Surface.GetTemplate(surface)
      if status==false and MissingExtenderSurfaces[surface] then
        template = Ext.Template.GetTemplate(MissingExtenderSurfaces[surface])
        if not template then
          Ext.Print("MoreSurfaceEffects_Serp: Surface.GetTemplate faild (add it manually to MissingExtenderSurfaces) to get template for:",surface)
        end
      end
      if template and template.Statuses then
        -- Ext.Print("Surface Template",surface,_D(template))
        for _,status in ipairs(stati) do
          template.Statuses[#template.Statuses+1] = status -- does not work: table.insert(template.Statuses,status)
          Ext.Print("MoreSurfaceEffects_Serp: Add to surface",surface,"status :",_D(status))
        end
      end
    end
  end
  
  -- Ext.Surface.GetTemplate("Water").Statuses[#Ext.Surface.GetTemplate("Water").Statuses+1] = {Chance=1,Duration = 12.0,KeepAlive = true,StatusId = "WET"}
  -- Ext.Surface.GetTemplate("Water").Statuses = {{Chance=1,Duration = 12.0,KeepAlive = true,StatusId = "WET"}}
  
    
end)

--]]--


-- Surface Template:
-- {
  -- "AllowReceiveDecalWhenAnimated" : false,
  -- "AlwaysUseDefaultLifeTime" : false,
  -- "CameraOffset" :
  -- [
          -- 0.0,
          -- 0.0,
          -- 0.0
  -- ],
  -- "CanEnterCombat" : true,
  -- "CanSeeThrough" : false,
  -- "CanShootThrough" : true,
  -- "CastShadow" : true,
  -- "DamageCharacters" : false,
  -- "DamageItems" : false,
  -- "DamageTorches" : false,
  -- "DamageWeapon" : "",
  -- "DecalMaterial" : "b279a93b-4833-40e6-85ac-75766f22dffc",
  -- "DefaultLifeTime" : 12.0,
  -- "Description" : "h6a438f0egdb7ag4073g9fadg74768a86aaa0",
  -- "DisplayName" : "hbf02846cg1055g428dgb753gbfdd15ac3ee6",
  -- "FX" : [],
  -- "FadeInSpeed" : 5.0,
  -- "FadeOutSpeed" : 1.0,
  -- "FileName" : "E:/Spiele/GOG Games/Divinity - Original Sin 2/DefEd/Data/Public/Shared/RootTemplates/_merged.lsf",
  -- "Flags" : [],
  -- "GroupID" : 0,
  -- "Handle" : 6709,
  -- "HasGameplayValue" : false,
  -- "HasParentModRelation" : false,
  -- "Id" : "d17538e1-b1f2-439f-b198-2c1ce19c6ff2",
  -- "InstanceVisual" :
  -- [
          -- {
                  -- "GridSize" : 4.0,
                  -- "Height" : 1.5,
                  -- "RandomPlacement" : 0.30000001192092896,
                  -- "Rotation" :
                  -- [
                          -- 0,
                          -- 0
                  -- ],
                  -- "Scale" :
                  -- [
                          -- 4.0,
                          -- 6.0
                  -- ],
                  -- "SpawnCell" : 100,
                  -- "SurfaceNeeded" : 0.10000000149011612,
                  -- "SurfaceRadiusMax" : 0.0,
                  -- "Visual" : "7d0def0b-e1c8-438d-9d96-e5edbd1bc455"
          -- },
          -- {
                  -- "GridSize" : 3.5,
                  -- "Height" : 0.5,
                  -- "RandomPlacement" : 1.0,
                  -- "Rotation" :
                  -- [
                          -- 0,
                          -- 360
                  -- ],
                  -- "Scale" :
                  -- [
                          -- 5.0,
                          -- 8.0
                  -- ],
                  -- "SpawnCell" : 50,
                  -- "SurfaceNeeded" : 0.0,
                  -- "SurfaceRadiusMax" : 0.0,
                  -- "Visual" : "172731d9-2fab-4052-875b-59ef9634f7e4"
          -- },
          -- {
                  -- "GridSize" : 1.0,
                  -- "Height" : 1.0,
                  -- "RandomPlacement" : 0.20000000298023224,
                  -- "Rotation" :
                  -- [
                          -- 0,
                          -- 0
                  -- ],
                  -- "Scale" :
                  -- [
                          -- 0.5,
                          -- 2.0
                  -- ],
                  -- "SpawnCell" : 100,
                  -- "SurfaceNeeded" : 0.0,
                  -- "SurfaceRadiusMax" : 1.0,
                  -- "Visual" : "9bf5c002-7013-40fb-844d-b592a125c3db"
          -- }
  -- ],
  -- "IntroFX" : [],
  -- "IsDeleted" : false,
  -- "IsGlobal" : false,
  -- "IsReflecting" : false,
  -- "IsShadowProxy" : false,
  -- "LevelName" : "",
  -- "ModFolder" : "Shared",
  -- "Name" : "SurfaceSmokeCloudBlessed",
  -- "NonUniformScale" : true,
  -- "PhysicsTemplate" : "",
  -- "ReceiveDecal" : true,
  -- "RemoveDestroyedItems" : false,
  -- "RenderChannel" : 4,
  -- "RootTemplate" : "",
  -- "Seed" : 0,
  -- "Statuses" :
  -- [
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : false,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : true,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : false,
                  -- "StatusId" : "INVISIBLE",
                  -- "VanishOnReapply" : false
          -- },
          -- {
                  -- "ApplyToCharacters" : true,
                  -- "ApplyToItems" : true,
                  -- "Chance" : 1.0,
                  -- "Duration" : 6.0,
                  -- "ForceStatus" : false,
                  -- "KeepAlive" : false,
                  -- "OnlyWhileMoving" : false,
                  -- "RemoveStatus" : true,
                  -- "StatusId" : "MUTED",
                  -- "VanishOnReapply" : false
          -- }
  -- ],
  -- "Summon" : "",
  -- "SurfaceGrowTimer" : 0.019999999552965164,
  -- "SurfaceType" : "SurfaceSmokeCloudBlessed",
  -- "SurfaceTypeId" : 72,
  -- "Tags" : [],
  -- "Transform" :
  -- {
          -- "Matrix" :
          -- [
                  -- 1.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 1.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 1.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 1.0
          -- ],
          -- "Rotate" :
          -- [
                  -- 1.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 1.0,
                  -- 0.0,
                  -- 0.0,
                  -- 0.0,
                  -- 1.0
          -- ],
          -- "Scale" :
          -- [
                  -- 1.0,
                  -- 1.0,
                  -- 1.0
          -- ],
          -- "Translate" :
          -- [
                  -- 0.0,
                  -- 0.0,
                  -- 0.0
          -- ]
  -- },
  -- "Type" : 0,
  -- "VisualTemplate" : ""
-- }

-- ##########################################################

-- old code which applies stati via lua. But I think its better to use the vanilla mechnics
-- if used, would need to check if the INSURFACE also applies while the character is hovering and should not be affected by surfaces

-- function SharedFns.RegisterProtectedOsirisListener(event, arity, state, callback)
	-- Ext.Osiris.RegisterListener(event, arity, state, function(...)
		-- if Ext.Server.GetGameState() == "Running" then
			-- local b,err = xpcall(callback, debug.traceback, ...)
			-- if not b then
				-- Ext.PrintError("ERROR: ",err)
			-- end
		-- end
	-- end)
-- end

--[[
-- SurfaceBasedStati
-- gucken wie WaterFrozenBlessed Surfaces stati geben, vllt auch einfach so machen? hm scheint hardcoded iwo
SharedFns.ApplyStatusWithChance = function(charGUID,status,chance,duration,force)
  duration = duration or 6 -- 6==1 turn
  force = force or 0
  if chance>0 and Osi.HasActiveStatus(charGUID,status)==0 and (chance>=1 or Ext.Random()<=chance) then
    Osi.ApplyStatus(charGUID,status,duration,force)
  end
end
SharedFns.SurfaceBasedStati = {
  SurfaceWater={s="WET",c=0.30,d=6,f=0,chancex2if="BURNING",forceif="BURNING"},SurfaceBlood={s="WET",c=0.20,d=6,f=0,chancex2if="BURNING",forceif="BURNING"},
  SurfaceWaterFrozen={s="CHILLED",c=0.20,d=6,f=0,chancex2if="WET",forceif="WET"},SurfaceBloodFrozen={s="CHILLED",c=0.20,d=6,f=0,chancex2if="WET",forceif="WET"},
  AnyCloud={s="FOGBLIND_SERP",c=1.0,d=6,f=1},
}
-- used to apply status either in turn start when standing in surface or the moment you start to stand in surface
SharedFns.HandleSurfaceBasedStatus = function(charGUID)
  local surfaces = {
    Ground = Osi.GetSurfaceGroundAt(charGUID), -- [in](GUIDSTRING)_Target, [out](STRING)_Surface -- SurfaceWater SurfaceWaterFrozen
    Cloud = Osi.GetSurfaceCloudAt(charGUID), -- [in](GUIDSTRING)_Target, [out](STRING)_Surface -- SurfaceWaterCloud
  }
  -- Ext.Print("HandleSurfaceBasedStatus",charGUID,surfaces.Ground,surfaces.Cloud) -- SurfaceNone 
  for kind,surface in pairs(surfaces) do
    local data = SharedFns.SurfaceBasedStati[surface]
    if data then
      local chance = data.c 
      local force = data.f
      if data.chancex2if and Osi.HasActiveStatus(charGUID,data.chancex2if)==1 then
        chance = chance * 2
      end
      if data.forceif and Osi.HasActiveStatus(charGUID,data.forceif)==1 then
        force = 1
      end
      SharedFns.ApplyStatusWithChance(charGUID,data.s,chance,data.d,force) -- status, chance, duration, force
    end
  end
  if surfaces.Cloud~="SurfaceNone" and SharedFns.SurfaceBasedStati["AnyCloud"] then
    local data = SharedFns.SurfaceBasedStati["AnyCloud"]
    SharedFns.ApplyStatusWithChance(charGUID,data.s,data.c,data.d,data.f)
  elseif surfaces.Cloud=="SurfaceNone" and Osi.HasActiveStatus(charGUID,"FOGBLIND_SERP")==1 then
    Osi.RemoveStatus(charGUID,"FOGBLIND_SERP")
  end
end

SharedFns.OnObjectTurnStarted = function(charGUID)
  SharedFns.HandleSurfaceBasedStatus(charGUID) -- SurfaceBasedStati
end
-- Also called for standing in surface, cause ist verursacher charGUID und bei surface der dem das surface gehört, bzw. der es erzeugt hat. 
-- In surface hin und her gehen triggert es nicht erneut (wie der surface schaden), triggert auch nur einmal pro sekunde oderso, dh. wenn surface schnell gewechselt wird, triggert es für eins davon garnicht, aber wir nehmen auch OnObjectTurnStarted dazu, dann passt das
SharedFns.OnCharacterStatusApplied = function(charGUID, status, cause)
  -- Ext.Print("OnCharacterStatusApplied charGUID:",charGUID,"status:",status,"cause:",cause)
  if status=="INSURFACE" then -- Apply Wet with a chance when on water/blood
    SharedFns.HandleSurfaceBasedStatus(charGUID) -- SurfaceBasedStati
  end
end
SharedFns.OnCharacterStatusRemoved = function(charGUID, status, nilSource)
  if status=="INSURFACE" then
    local surfaces = {
      Ground = Osi.GetSurfaceGroundAt(charGUID), -- [in](GUIDSTRING)_Target, [out](STRING)_Surface -- SurfaceWater SurfaceWaterFrozen
      Cloud = Osi.GetSurfaceCloudAt(charGUID), -- [in](GUIDSTRING)_Target, [out](STRING)_Surface -- SurfaceWaterCloud
    }
    if surfaces.Cloud=="SurfaceNone" and Osi.HasActiveStatus(charGUID,"FOGBLIND_SERP")==1 then
      Osi.RemoveStatus(charGUID,"FOGBLIND_SERP") -- SurfaceBasedStati
    end
  end
  
end
--]]--


local function RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.Osiris.RegisterListener(event, arity, state, function(...)
		if Ext.Server.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError("ERROR: ",err)
			end
		end
	end)
end
-- remove FOGBLIND_SERP on surface left (does not trigger when leaving fog and entering water..., only on no-surface it fires)
-- so we will add to every surface in template that it removes FOGBLIND_SERP
RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", function(charGUID, status, nilSource)
  if status=="INSURFACE" then
    local Cloud = Osi.GetSurfaceCloudAt(charGUID)
    if Cloud=="SurfaceNone" and Osi.HasActiveStatus(charGUID,"FOGBLIND_SERP")==1 then
      Osi.RemoveStatus(charGUID,"FOGBLIND_SERP")
    end
  end
end)

-- remove surface (there is also Transform to Freeze and such, but it affects most connected surface and often ignores the radis)
-- local x,y,z=table.unpack(Ext.Entity.GetCharacter("S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb").WorldPos);Osi.CreateSurfaceAtPosition(x,y,z,"SurfaceNone",0.5,1)
