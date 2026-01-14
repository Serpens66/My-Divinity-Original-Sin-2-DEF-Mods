print("Called DebuffInsteadChainCC_Serp")

Duration = 2

-- statusses which have no stats
local engineStatuses = {
	CLEAN=true,
  CLIMBING=true,
  SOURCE_MUTED=true,
  DRAIN=true,
  POLYMORPHED=true,
  CHARMED=true,
  INFUSED=true,
  HIT=true,
  IDENTIFY=true,
  DYING=true,
  THROWN=true,
  LYING=true,
  SNEAKING=true,
  CONSUME=true,
  ROTATE=true,
  SHACKLES_OF_PAIN=true,
  UNSHEATHED=true,
  WIND_WALKER=true,
  DARK_AVENGER=true,
  AOO=true,
  SHACKLES_OF_PAIN_CASTER=true,
  SITTING=true,
  FLANKED=true,
  LINGERING_WOUNDS=true,
  CHANNELING=true,
  DAMAGE=true,
  EXPLODE=true,
  SMELLY=true,
  SPIRIT_VISION=true,
  INCAPACITATED=true,
  SPARK=true,
  UNLOCK=true,
  EFFECT=true,
  STANCE=true,
  FORCE_MOVE=true,
  SPIRIT=true,
  FLOATING=true,
  CONSTRAINED=true,
  SUMMONING=true,
  MATERIAL=true,
  LEADERSHIP=true,
  COMBUSTION=true,
  TUTORIAL_BED=true,
  TELEPORT_FALLING=true,
  INFECTIOUS_DISEASED=true,
  OVERPOWER=true,
  REMORSE=true,
  REPAIR=true,
  ENCUMBERED=true,
  UNHEALABLE=true,
  ACTIVE_DEFENSE=true,
  DECAYING_TOUCH=true,
  ADRENALINE=true,
  INSURFACE=true,
  BOOST=true,
  COMBAT=true,
  STORY_FROZEN=true,
}


-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end


---- Hard CCs rework ----
blockedStatuses = {
  KNOCKED_DOWN = true,
  CHICKEN = true,
  STUNNED = true,
  FROZEN = true,
  PETRIFIED = true,
  MADNESS = true,
  FEAR = true,
  DEMONIC_POSSESSION = true,
  SLEEPING = true
}
concernedTypes = {
	KNOCKED_DOWN = true,
	INCAPACITATED = true,
	CHARMED = true,
	CONSUME = true, -- needs extra check for stat LoseControl
	FEAR = true,
	-- POLYMORPHED = true, -- can also be shapeshift into human, which is no cc, so dont check
}

local ReplacingStatus = {
  LX_MOMENTUM_Serp={"LX_STAGGERED1_Serp","LX_STAGGERED2_Serp","LX_STAGGERED3_Serp"},
  LX_LINGERING_Serp={"LX_CONFUSED1_Serp","LX_CONFUSED2_Serp","LX_CONFUSED3_Serp"},
}

local function OnCharacterStatusRemoved(charGUID, statusname, causee)
	if not engineStatuses[statusname] then
    local StatusStat = Ext.Stats.Get(statusname)
    local StatusType = StatusStat.StatusType
    if blockedStatuses[statusname] or (concernedTypes[StatusType] and (StatusType~="CONSUME" or StatusStat.LoseControl=="Yes")) then
      local SavingThrow = StatusStat.SavingThrow
      local duration = Duration
      if Osi.CharacterHasTalent(charGUID, "WalkItOff") == 1 then
        duration = duration + 1
      end
      local applyStatus = "LX_MOMENTUM_Serp" -- use LX_MOMENTUM_Serp if no SavingThrow
      if SavingThrow == "PhysicalArmor" then
        applyStatus = "LX_MOMENTUM_Serp"
      elseif SavingThrow == "MagicArmor" then
        applyStatus = "LX_LINGERING_Serp"
      end
      Osi.ApplyStatus(charGUID,applyStatus,duration*6,1)
    end
  end
end
if Ext.IsServer() then
  Ext.Osiris.RegisterListener("CharacterStatusRemoved", 3, "after", OnCharacterStatusRemoved)
end


local TorturerStati = {"BURNING","POISONED","BLEEDING","NECROFIRE","ACID","SUFFOCATING","ENTANGLED","DEATH_WISH","DAMAGE_ON_MOVE"} -- stati which are not blocked by armor if Torturer apllies them

local function ContinueMom(ForceStatus,GoesThroughArmor,SavingThrow,hasMomentum,target)
  local continue = false
  if hasMomentum then
    if ForceStatus or GoesThroughArmor or SavingThrow=="None" then
      continue = true
    elseif SavingThrow=="PhysicalArmor" and target.Stats.CurrentArmor<=0 then
      continue = true
    end
  end
  -- print("DebuffInsteadChainCC_Serp ContinueMom",continue,ForceStatus,GoesThroughArmor,SavingThrow,hasMomentum,target,target.Stats.CurrentArmor)
  return continue
end
local function ContinueLin(ForceStatus,GoesThroughArmor,SavingThrow,hasLingering,target)
  local continue = false
  if hasLingering then
    if ForceStatus or GoesThroughArmor then
      continue = true
    elseif SavingThrow=="MagicArmor" and target.Stats.CurrentMagicArmor<=0 then
      continue = true
    end
  end
  return continue
end

if Ext.IsServer() then

  Ext.Events.BeforeStatusApply:Subscribe(function(ev)
    local status = ev.Status ---@type EsvStatus
    local statusname = status.StatusId
    if not ev.PreventStatusApply then
      if statusname and not engineStatuses[statusname] and status.LifeTime>0 then -- aura effects have a LifeTime of -1 and are applied hundred of times, so do not add any rules to them
        if Ext.Utils.GetHandleType(status.OwnerHandle)=="ServerCharacter" then -- only for characters, we do not care for items
          local target = Ext.Entity.GetCharacter(status.OwnerHandle) ---@type EsvCharacter .. 
          local targetGuid = target and target.MyGuid
          local source = Ext.Utils.GetHandleType(status.StatusSourceHandle)=="ServerCharacter" and Ext.Entity.GetCharacter(status.StatusSourceHandle) or nil ---@type EsvCharacter
          local sourceIsAlly = source and Osi.CharacterIsAlly(targetGuid,source.MyGuid)==1 -- dont care for stati applied by allies, because some benefital skill like permafrost should not prevent the CC
          local StatusStat = Ext.Stats.Get(statusname)
          -- print("DebuffInsteadChainCC_Serp BeforeStatusApply",targetGuid,statusname,sourceIsAlly)
          if not sourceIsAlly and StatusStat and target and targetGuid then
            local StatusType = StatusStat.StatusType
            if blockedStatuses[statusname] or (concernedTypes[StatusType] and (StatusType~="CONSUME" or StatusStat.LoseControl=="Yes")) then
              local ImmuneFlag = StatusStat.ImmuneFlag -- dont apply this status, if the charGUID has this ImmuneFlag eg. "KnockdownImmunity"
              if ImmuneFlag=="None" or not target.Stats[ImmuneFlag] then
                -- print("DebuffInsteadChainCC_Serp BeforeStatusApply",targetGuid,statusname,StatusType,StatusStat.LoseControl)
                local hasMomentum = Osi.HasActiveStatus(targetGuid,"LX_MOMENTUM_Serp")==1 and "LX_MOMENTUM_Serp" or nil
                local hasLingering = Osi.HasActiveStatus(targetGuid,"LX_LINGERING_Serp")==1 and "LX_LINGERING_Serp" or nil
                if hasLingering or hasMomentum then
                  local source = Ext.Utils.GetHandleType(status.StatusSourceHandle)=="ServerCharacter" and Ext.Entity.GetCharacter(status.StatusSourceHandle) or nil ---@type EsvCharacter
                  local sourceIsTorturer = source and source.Stats.TALENT_Torturer or false -- effects from him are not blocked. talent does not work for SurfaceStatus
                  local GoesThroughArmor = status.DamageSourceType~="SurfaceStatus" and sourceIsTorturer and table_contains_value(TorturerStati,statusname)
                  local SavingThrow = StatusStat.SavingThrow
                  if ContinueMom(ForceStatus,GoesThroughArmor,SavingThrow,hasMomentum,target) then
                    print("DebuffInsteadChainCC_Serp BeforeStatusApply: Prevent Applying",statusname,"because of Momentum status")
                    ev.PreventStatusApply = true
                    local hasstatus = 0
                    for i,newstatus in ipairs(ReplacingStatus[hasMomentum]) do
                      if Osi.HasActiveStatus(targetGuid,newstatus)==1 then -- only one of them can be active at a time via StackId
                        hasstatus = i
                        break
                      end
                    end
                    hasstatus = hasstatus>=#ReplacingStatus[hasMomentum] and #ReplacingStatus[hasMomentum]-1 or hasstatus
                    local applynewstatus = ReplacingStatus[hasMomentum][hasstatus+1]
                    Osi.ApplyStatus(targetGuid,applynewstatus,6.0,1)
                  end
                  if ContinueLin(ForceStatus,GoesThroughArmor,SavingThrow,hasLingering,target) then
                    print("DebuffInsteadChainCC_Serp BeforeStatusApply: Prevent Applying",statusname,"because of Lingering status")
                    ev.PreventStatusApply = true
                    local hasstatus = 0
                    for i,newstatus in ipairs(ReplacingStatus[hasLingering]) do
                      if Osi.HasActiveStatus(targetGuid,newstatus)==1 then -- only one of them can be active at a time via StackId
                        hasstatus = i
                        break
                      end
                    end
                    hasstatus = hasstatus>=#ReplacingStatus[hasLingering] and #ReplacingStatus[hasLingering]-1 or hasstatus
                    local applynewstatus = ReplacingStatus[hasLingering][hasstatus+1]
                    Osi.ApplyStatus(targetGuid,applynewstatus,6.0,1)
                  end
                end
              end
            end
          end
        end
      end
    end
    return ev
  end,{Priority = -3000})
  -- call after my ArmorBasedSavingThrows_Serp mod (which does use -200) and at best after all other mods, so extra negativ
  -- and must be lower than 200, because LeaderLib has currently a function that reverts changes made to PreventStatusApply ...
  -- The Priority setting determines the order in which subscribers are called; subscribers with HIGHER priority are called first. The default priority is 100. 


  -- Problem:
  -- If every mod does the CanEnterChance calulation on their own, it will multiply the chance 10%*10% and so on, which falsifies the result
  -- solution:
  -- Set the Chance to 100% if we did the CanEnter check, so mods doing it afterwards dont cause problems
  Ext.Events.BeforeStatusApply:Subscribe(function(ev)
    if not ev.PreventStatusApply then
      local status = ev.Status ---@type EsvStatus
      local statusname = status and status.StatusId
      if statusname and not engineStatuses[statusname] and status.LifeTime>0 then -- aura effects have a LifeTime of -1 and are applied hundred of times, so do not add any rules to them
        if status.CanEnterChance<=0 or (status.CanEnterChance < 100 and (status.CanEnterChance/100) <= math.random()) then
          ev.PreventStatusApply = true
        elseif status.CanEnterChance < 100 then
          status.CanEnterChance = 100 -- set it to 100 to signal other mods that we already did the calc, so mods executing later wont falsify the result
        end
      end
    end
  end,{Priority = 10000})

end


-- #########################################################

-- Tooltip adjustments for client

if Ext.IsClient() then

  local StatiBlocked = {LX_MOMENTUM_Serp={},LX_LINGERING_Serp={}}
  local StatiBlockedLoc = {LX_MOMENTUM_Serp={},LX_LINGERING_Serp={}}
  
  Ext.Events.StatsLoaded:Subscribe(function(e)
      
    for i,statusname in pairs(Ext.Stats.GetStats("StatusData")) do
      local StatusStat = Ext.Stats.Get(statusname)
      local StatusType = StatusStat.StatusType
      if blockedStatuses[statusname] or (concernedTypes[StatusType] and (StatusType~="CONSUME" or StatusStat.LoseControl=="Yes")) then
        local SavingThrow = StatusStat.SavingThrow
        if SavingThrow=="MagicArmor" then
          table.insert(StatiBlocked.LX_LINGERING_Serp,statusname)
          local statusname_loc = Ext.L10N.GetTranslatedStringFromKey(StatusStat.DisplayName,statusname) 
          table.insert(StatiBlockedLoc.LX_LINGERING_Serp,statusname_loc)
        elseif SavingThrow=="None" or SavingThrow=="PhysicalArmor" then
          table.insert(StatiBlocked.LX_MOMENTUM_Serp,statusname)
          local statusname_loc = Ext.L10N.GetTranslatedStringFromKey(StatusStat.DisplayName,statusname) 
          table.insert(StatiBlockedLoc.LX_MOMENTUM_Serp,statusname_loc)
        end
      end
    end
    -- print("DebuffInsteadChainCC_Serp StatiBlocked:")
    -- _D(StatiBlocked)
    
  end)

  -- ecl::StatusConsumeBase (00007FF44AB8A900)
  Game.Tooltip.Register.Status(function(char,StatusConsumeBase,tooltip)
    local statusname = StatusConsumeBase.StatusId
    if statusname=="LX_LINGERING_Serp" or statusname=="LX_MOMENTUM_Serp" then
      -- print("DebuffInsteadChainCC_Serp Tooltip",statusname)
      for _,entry in ipairs(tooltip.Data) do
        if entry.Type=="StatusDescription" then
          entry.Label = entry.Label.."<font color='#40b606'>"..table.concat(StatiBlockedLoc[statusname],", ").."</font>".."\n("..table.concat(StatiBlocked[statusname],", ")..")"
          break
        end
      end
    end
  end)

end