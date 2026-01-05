local function GetFormattedSkillID(skillID)
	return string.sub(skillID, 1, string.len(skillID)-3)
end



local function LimitRange()
  -- Ext.Print("Projectile_CatFlight_Serp start")
  local EclCustomSkillState = {}

  -- function EclCustomSkillState:ValidateTargetSight(ev, skillState, targetPos)
      -- OUT_OF_SIGHT = -1,
      -- HIGH_GROUND_BONUS = 0,
      -- IN_SIGHT = 1,
      -- UNKNOWN = 2, -- Purple "+"" signs. Unused?
  -- end
  local maxheigt_extrarange = {height=4,rangepercent=0.5} -- when reaching this height, the max extra range is added (*1.5)
  function EclCustomSkillState:ValidateTarget(ev, skillState, targetHandle, targetPos, snapToGrid, fillInHeight)
    local skill = GetFormattedSkillID(skillState.SkillId)
    if skill == "Projectile_CatFlight_Serp" then
      local char = Ext.Entity.GetCharacter(skillState.CharacterHandle)
      if char then
        local casterPos = char.WorldPos
        local distance = Ext.Math.Distance(targetPos,casterPos)
        if distance > skillState.TargetRadius then
          local heightdiff = casterPos[2]-targetPos[2] -- diff of 4 is already quite big and results in vanilla in like 15 m extra range
          if heightdiff > 0 then -- caster higher than target position
            if distance > skillState.TargetRadius * (1 + (maxheigt_extrarange.rangepercent * (heightdiff/maxheigt_extrarange.height))) then
              ev.PreventDefault = true
              -- ev.StopEvent = true
              return 3 -- TOO_FAR
            end
          else
            -- Ext.Print("ValidateTarget",char.MyGuid,skill,skillState.SkillId,casterPos[1],casterPos[3],casterPos[2],targetPos[1],targetPos[3],targetPos[2],distance)
            ev.PreventDefault = true
            -- ev.StopEvent = true
            return 3 -- TOO_FAR
          end
        end
      end
    end
    return 0
      -- VALID = 0,
      -- INVALID = 1,
      -- TOO_CLOSE = 2,
      -- TOO_FAR = 3,
      -- TOO_HEAVY = 5,
      -- BLOCKED = 6,
      -- INVISIBLE = 7,
      -- OUT_OF_SIGHT = 8,
      -- PATH_INTERRUPTED = 9,
      -- PATH_INTERRUPTED_ROOF = 10,
      -- CANNOT_SWAP = 11,
  end

  return EclCustomSkillState
end
Ext.ClientBehavior.Skill.AddById("Projectile_CatFlight_Serp_-1", LimitRange)
-- Ext.ClientBehavior.Skill.AddByType("Projectile", LimitRange)

-- skillState	HighlightedCharacters	Array<ComponentHandle> (00007FF4499D4C10)
-- skillState	CastingFinished	false
-- skillState	HighlightedItems	Array<ComponentHandle> (00007FF4499D4C30)
-- skillState	TargetRadius	7.0
-- skillState	SkillEffect	nil
-- skillState	WeaponAnimData	Array<WeaponAnimData> (00007FF4499D4C98)
-- skillState	EffectHandlers	Array<ecl::MultiEffectHandler> (00007FF4499D4C58)
-- skillState	BeamEffects	Array<ecl::BeamEffectHandler> (00007FF4499D4C78)
-- skillState	NextWeaponAnimationIndex	0
-- skillState	ProjectileTerrainOffset	0.0
-- skillState	TimeElapsed	0.0
-- skillState	State	PickTargets
-- skillState	SkillId	Projectile_CatFlight_Serp_-1
-- skillState	CharacterHandle	userdata: 0580000100000143
-- skillState	ExplodeRadius	0.0
-- skillState	ItemHandle	userdata: 0000000000000000
-- skillState	IsFromItem	false
-- skillState	ActionMachineTransactionId	1
-- skillState	ChargeDuration	0.0
-- skillState	IsTargeting	true
-- skillState	OwnsActionState	false
-- skillState	Type	Projectile
-- skillState	CanTargetCharacters	false
-- skillState	MovingCaster	true
-- skillState	CanTargetItems	false
-- skillState	CanTargetTerrain	true
-- skillState	CastAnimation	
-- skillState	TargetingObject	false
-- skillState	CasterMovingObject	true
-- skillState	AutoAim	false
-- skillState	AmountOfTargets	1
-- skillState	TargetRadiusSquare	49.0
-- skillState	NextProjectileTargetIndex	0
-- skillState	NextProjectileTimeRemaining	0.0
-- skillState	ProjectileCount	1
-- skillState	AnimationTimeRemaining	0.0
-- skillState	AreaRadius	0.0
-- skillState	Angle	0
-- skillState	TargetConditions	stats::Condition (00007FF4544FC510)
-- skillState	Targets	Array<ecl::SkillStateProjectile::TargetData> (00007FF4499D4DD8)