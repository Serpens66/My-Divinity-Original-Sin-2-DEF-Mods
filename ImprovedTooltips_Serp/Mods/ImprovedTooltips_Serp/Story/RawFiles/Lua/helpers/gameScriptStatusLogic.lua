-- Based on vanilla \Public\Shared\Scripts\Game\Statuses.gameScript
-- first asked ChatGPT to convert this into a useable table, but result was not good.
-- Manually changed the gameScript into lua, by mass replacing parts with text-editor -> gamescript.lua
-- tried for hours to somehow convert this into a useable table, but failed :D
-- then asked again ChatGPT with this lua script, which had a much better result, but nearly all special cases were wrong.
-- asked ChatGPT to correct these cases and add the stati it missed
-- the more you ask ChatGPT in the same conversation, the worse it gets, simply adding random words to the result :D
-- fixed some errors manually
-- finally after like 10 hours I had this table (would have been faster if I had just manually written it :D)


-- if_has = hat alle der gelisteten statie
-- if_has_any = hat mind. einen der stati
-- if_not = hat keinen der gelisteten stati
-- possible_results[1] ist immer das result, wenn conditional leer oder keine davon zutrifft, also ELSE

-- if not mentioned otherwise in the condition, all conditions are exclusive to eachother (if elseif else end)


local function tabletostring(b)if type(b)~="table"then error("tableToString expects a table")end;local c={}local function d(e)local f=0;local g=0;for h in pairs(e)do if type(h)~="number"or h<=0 or h%1~=0 then return false end;if h>f then f=h end;g=g+1 end;return f==g,f end;local function i(j,k)local e=type(j)local l=string.rep("    ",k)local m=string.rep("    ",k+1)if e=="number"or e=="boolean"then return tostring(j)elseif e=="string"then return string.format("%q",j)elseif e=="nil"then return"nil"elseif e=="table"then if c[j]then error("Cannot serialize table with cyclic reference")end;c[j]=true;local n,o=d(j)local p="{\n"if n then for q=1,o do p=p..m..i(j[q],k+1)..",\n"end else for h,r in pairs(j)do local s;if type(h)=="string"and h:match("^[_%a][_%w]*$")then s=h else s="["..i(h,k+1).."]"end;p=p..m..s.." = "..i(r,k+1)..",\n"end end;p=p..l.."}"c[j]=nil;return p else error("Unsupported type: "..e)end end;return i(b,0)end


-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return true
    end
  end
  return false
end


StatusScriptRules = {

  WARM = {
    possible_results = { "WARM","BURNING","CHILLED","NULLL" },
    always_remove = { "WET" },
    conditional = {
      { if_has = { "WARM" }, remove = { "WARM" }, result = "BURNING" },
      { if_has_any = { "BURNING","NECROFIRE","HOLY_FIRE" }, result = "NULLL" },
      { if_has = { "CHILLED" }, remove = { "CHILLED" }, result = "NULLL" },
      { if_has = { "FROZEN" }, remove = { "FROZEN" }, result = "CHILLED" },
    }
  },

  WET = {
    possible_results = { "WET","WARM","FROZEN","STUNNED","NULLL" },
    always_remove = { "WARM","INVISIBLE" },
    conditional = {
      { if_has = { "BURNING" }, remove = { "BURNING" }, result = "WARM" },
      { if_has = { "HOLY_FIRE" }, remove = { "HOLY_FIRE" }, result = "WARM" },
      { if_has = { "CHILLED" }, remove = { "CHILLED" }, result = "FROZEN" },
      { if_has_any = { "FROZEN","NECROFIRE","HOLY_FIRE" }, result = "NULLL" },
      { if_has = { "SHOCKED" }, remove = { "SHOCKED" }, result = "STUNNED" },
    }
  },
  
  CHILLED = {
    possible_results = { "CHILLED", "WARM", "FROZEN", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "BURNING" }, remove = { "BURNING" }, result = "WARM" },
      { if_has = { "HOLY_FIRE" }, remove = { "HOLY_FIRE" }, result = "WARM" },
      { if_has = { "WARM" }, remove = { "WARM" }, result = "NULLL" },
      { if_has_any = { "CHILLED", "WET" }, remove = { "CHILLED", "WET" }, result = "FROZEN" },
      { if_has_any = { "FROZEN", "NECROFIRE", "HOLY_FIRE" }, result = "NULLL" },
    }
  },

  FROZEN = {
    possible_results = { "FROZEN", "WET", "CHILLED", "NULLL" },
    always_remove = { "CHILLED", "WET", "INVISIBLE", "SLEEPING" },
    conditional = {
      { if_has = { "MAGIC_SHELL" }, remove = { "MAGIC_SHELL" }, result = "NULLL" },
      { if_has = { "BURNING" }, remove = { "BURNING" }, result = "WET" },
      { if_has = { "HOLY_FIRE" }, remove = { "HOLY_FIRE" }, result = "WET" },
      { if_has_any = { "NECROFIRE", "HOLY_FIRE" }, result = "NULLL" },
      { if_has = { "WARM" }, remove = { "WARM" }, result = "CHILLED" },
    }
  },
  
  BURNING = {
    possible_results = { "BURNING", "WARM", "WET", "NULLL" },
    always_remove = { "WEB" },
    conditional = { -- WET and WARM exclude eachother, so can not happen at the same time
      {if_has = { "WARM" },remove = { "WARM" },result = "BURNING"},
      {if_has = { "WET" },remove = { "WET" },result = "WARM"},
      -- {if_has = { "WARM" },if_not = { "WET" },remove = { "WARM" },result = "BURNING"},
      -- {if_has = { "WET" },if_not = { "WARM" },remove = { "WET" },result = "WARM"},
      -- {if_has = { "WET", "WARM" },remove = { "WET" },result = "BURNING"},
      {if_has = { "CHILLED" },remove = { "CHILLED" },result = "WARM"},
      {if_has = { "FROZEN" },remove = { "FROZEN" },result = "WET"},
      {if_has_any = { "NECROFIRE", "HOLY_FIRE" },result = "NULLL"}
    }
  },

  NECROFIRE = {
    possible_results = { "NECROFIRE", "BURNING", "NULLL" },
    always_remove = { "WEB" },
    conditional = {
      {if_has = { "PETRIFIED" },result = "NULLL"},
      {["else"]=true,remove = { "WARM", "BURNING", "CHILLED", "WET", "FROZEN" }},
      {if_has = { "HOLY_FIRE" },remove = { "HOLY_FIRE" },result = "BURNING",_if=" if ",indent="  "},
      {if_has = { "BLESSED" },if_not = { "HOLY_FIRE" },remove = { "BLESSED" },result = "BURNING",indent="  "}
    }
  },

  HOLY_FIRE = {
    possible_results = { "HOLY_FIRE", "BURNING", "NULLL" },
    always_remove = { "WEB" },
    conditional = {
      {if_has = { "PETRIFIED" },result = "NULLL"},
      {["else"]=true,remove = { "WARM", "BURNING", "CHILLED", "WET", "FROZEN" }},
      {if_has = { "NECROFIRE" },remove = { "NECROFIRE" },result = "BURNING",_if=" if ",indent="  "}
    }
  },
  
  SHOCKED = {
    possible_results = { "SHOCKED", "STUNNED", "NULLL" },
    always_remove = { "INVISIBLE", "SLEEPING" },
    conditional = {
      { if_has = { "MAGIC_SHELL" }, remove = { "MAGIC_SHELL" }, result = "NULLL" },
      { if_has = { "STUNNED" }, remove = { "SHOCKED" }, result = "NULLL" },
      { if_has_any = { "SHOCKED", "WET" }, remove = { "SHOCKED" }, result = "STUNNED" },
    }
  },

  STUNNED = {
    possible_results = { "STUNNED", "NULLL" },
    always_remove = { "SHOCKED", "PETRIFIED", "WET", "INVISIBLE", "SLEEPING" },
    conditional = {
      { if_has = { "MAGIC_SHELL" }, remove = { "MAGIC_SHELL" }, result = "NULLL" },
      { if_has = { "BLESSED" }, remove = { "BLESSED" }, result = "NULLL" },
    }
  },
  
  DRUNK = {
    possible_results = { "DRUNK", "NULLL", "SLEEPING" },
    always_remove = {},
    conditional = {
      { if_has = { "CLEAR_MINDED" }, remove = { "CLEAR_MINDED" }, result = "NULLL" },
      { if_has = { "DRUNK" }, remove = { "DRUNK" }, result = "SLEEPING" },
    }
  },
  
  SLOWED = {
    possible_results = { "SLOWED", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "HASTED" }, remove = { "HASTED" }, result = "NULLL" },
    }
  },
  
  PETRIFIED = {
    possible_results = { "PETRIFIED", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "MAGIC_SHELL" }, remove = { "MAGIC_SHELL" }, result = "NULLL"},
      { if_has = { "BLESSED" }, remove = { "BLESSED" }, result = "NULLL"},
      { ["else"]=true ,remove = {"STUNNED","SHOCKED","BLEEDING","CRIPPLED","BURNING","POISONED","INVISIBLE","SLEEPING"}}
    }
  },

  FEAR = {
    possible_results = { "FEAR", "NULLL" },
    always_remove = {},
    conditional = {
      {if_has_any = { "CLEAR_MINDED", "ENRAGED" },remove = { "CLEAR_MINDED", "ENRAGED" },result = "NULLL"},
      {["else"]=true ,remove = {"CHARMED","TAUNTED","SLEEPING","MADNESS"},result = "FEAR"}
    }
  },

  CHARMED = {
    possible_results = { "CHARMED", "NULLL" },
    always_remove = {},
    conditional = {
      {if_has_any = { "CLEAR_MINDED", "ENRAGED" },remove = { "CLEAR_MINDED", "ENRAGED" },result = "NULLL"},
      {["else"]=true ,remove = {"FEAR","TAUNTED","SLEEPING","MADNESS"},result = "CHARMED"}
    }
  },
  
  TAUNTED = {
    possible_results = { "TAUNTED", "NULLL" },
    always_remove = {},
    conditional = {
      {if_has_any = { "CLEAR_MINDED", "ENRAGED" },remove = { "CLEAR_MINDED", "ENRAGED" },result = "NULLL"},
      {["else"]=true ,remove = {"INVISIBLE", "CHARMED", "FEAR", "SLEEPING", "MADNESS"},result = "TAUNTED"}
    }
  },
  
  SLEEPING = {
    possible_results = { "SLEEPING", "NULLL" },
    always_remove = {},
    conditional = {
      {if_has_any = { "CLEAR_MINDED", "ENRAGED" },remove = { "CLEAR_MINDED", "ENRAGED" },result = "NULLL"},
      {  ["else"] = true,remove = {"INVISIBLE","CHARMED","TAUNTED","FEAR","MADNESS"},result = "SLEEPING"}
    }
  },
  
  MADNESS = {
    possible_results = { "MADNESS", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "CLEAR_MINDED" }, remove = { "CLEAR_MINDED" }, result = "NULLL" },
    }
  },
  
  CLEAR_MINDED = {
    possible_results = { "CLEAR_MINDED", "NULLL" },
    always_remove = {},
    conditional = {
      {if_has = { "POSSESSED" },result = "NULLL"},
      {["else"]=true ,remove = {"CHARMED","TAUNTED","FEAR","MADNESS","SLEEPING","BLIND","ENRAGED","DRUNK"},result = "CLEAR_MINDED"}
    }
  },
  
  ENRAGED = {
    possible_results = { "ENRAGED" },
    always_remove = { "FEAR","CHARMED","TAUNTED","SLEEPING","MADNESS","CLEAR_MINDED" },
    conditional = {}
  },
  
  RESTED = {
    possible_results = { "RESTED" },
    always_remove = {"MUTED","BLIND","CRIPPLED","KNOCKED_DOWN","BLEEDING","PLAGUE","INFESTED"},
    conditional = {}
  },
  
  MUTED = {
    possible_results = { "MUTED", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "RESTED" }, remove = { "RESTED" }, result = "NULLL" },
    }
  },
  
  DISEASED = {
    possible_results = { "DISEASED", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "FORTIFIED"}, remove = { "FORTIFIED" }, result = "NULLL" },
      { if_has = { "BLESSED"}, remove = { "BLESSED" }, result = "NULLL" },
    }
  },
  
  INFECTIOUS_DISEASED = {
    possible_results = { "INFECTIOUS_DISEASED", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "FORTIFIED"}, remove = { "FORTIFIED" }, result = "NULLL" },
      { if_has = { "BLESSED"}, remove = { "BLESSED" }, result = "NULLL" },
    }
  },
  
  DECAYING_TOUCH = {
    possible_results = { "DECAYING_TOUCH", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "FORTIFIED"}, remove = { "FORTIFIED" }, result = "NULLL" },
      { if_has = { "BLESSED"}, remove = { "BLESSED" }, result = "NULLL" },
    }
  },
    
  HASTED = {
    possible_results = { "HASTED" },
    always_remove = { "SLOWED", "CRIPPLED" },
    conditional = {}
  },

  STEAM_LANCE = {
    possible_results = { "STEAM_LANCE", "NULLL" },
    always_remove = { "FROZEN", "CHILLED", "DISEASED", "INFECTIOUS_DISEASED", "DECAYING_TOUCH", "PLAGUE", "INFESTED" },
    conditional = {
      { if_has = { "PLAGUE" }, remove = { "PLAGUE" }, result = "NULLL" }
    }
  },

  HEALING_ELIXIR = {
    possible_results = { "HEALING_ELIXIR" },
    always_remove = {
      "WEAK","SLOWED","DISEASED","POISONED","BLEEDING",
      "CRIPPLED","CURSED","CHILLED","DRUNK","BURNING",
      "NECROFIRE","ACID","SUFFOCATING","DECAYING_TOUCH",
      "INFECTIOUS_DISEASED","PLAGUE"
    },
    conditional = {}
  },

  MAGIC_SHELL = {
    possible_results = { "MAGIC_SHELL" },
    always_remove = {"FROZEN","STUNNED","PETRIFIED","PLAGUE","SUFFOCATING","POISONED","BURNING"},
    conditional = {}
  },

  INVISIBLE = {
    possible_results = { "INVISIBLE", "NULLL" },
    always_remove = { "WET" },
    conditional = {
      { if_has = { "MARKED" }, remove = { "INVISIBLE" }, result = "NULLL" }
    }
  },

  CHICKEN = {
    possible_results = { "CHICKEN", "NULLL" },
    always_remove = { "WINGS" },
    conditional = {
      { if_has = { "CHICKEN" }, remove = {}, result = "NULLL" }
    }
  },

  BLIND = {
    possible_results = { "BLIND", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "RESTED" }, remove = { "RESTED" }, result = "NULLL" }
    }
  },

  CHAIN_HEAL = {
    possible_results = { "CHAIN_HEAL" },
    always_remove = { "INFESTED" },
    conditional = {}
  },
  
  CLEANSE_WOUNDS = {
    possible_results = { "CLEANSE_WOUNDS" },
    always_remove = { "INFESTED","PLAGUE","DISEASED","INFECTIOUS_DISEASED" },
    conditional = {}
  },

  SPIDER_LEGS = {
    possible_results = { "SPIDER_LEGS" },
    always_remove = { "WEB" },
    conditional = {}
  },

  CURSED = {
    possible_results = { "CURSED", "FROZEN", "NECROFIRE", "BURNING", "NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "BLESSED" }, remove = { "BLESSED" }, result = "NULLL" },
      { if_has = { "CHILLED" }, remove = { "CHILLED" }, result = "FROZEN" },
      { if_has = { "BURNING" }, remove = { "BURNING" }, result = "NECROFIRE", _if=" if " },
      { if_has_any = { "WARM","HOLY_FIRE" }, remove = { "WARM","HOLY_FIRE" }, result = "BURNING", _if=" if " }
    }
  },

  BLESSED = {
    possible_results = { "BLESSED", "CHILLED", "HOLY_FIRE", "BURNING", "NULLL" },
    always_remove = {"DISEASED","INFECTIOUS_DISEASED","DECAYING_TOUCH","PETRIFIED","STUNNED","FROZEN","INFESTED","PLAGUE"},
    conditional = {
      { if_has = { "FROZEN" }, remove = { "FROZEN" }, result = "CHILLED",_if=" if "},
      { if_has = { "BURNING" }, remove = { "BURNING" }, result = "HOLY_FIRE",_if=" if "},
      { if_has = { "NECROFIRE" }, remove = { "NECROFIRE" }, result = "BURNING",_if=" if "},
      { if_has = { "CURSED" }, remove = { "CURSED" }, result = "NULLL",_if=" if "},
      { if_has = { "PERMANENTLY_CURSED" }, result = "NULLL",_if=" if "},
      { if_has = { "VOIDHOWL" }, remove = { "VOIDHOWL" }, result = "NULLL",_if=" if "}
    }
  },

  WEB = {
    possible_results = { "WEB","HASTED","NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "SPIDER_LEGS" }, if_not = { "HASTED" }, result = "HASTED" },
      { if_has = { "SPIDER_LEGS" }, result = "NULLL" },
      { if_has = { "HASTED" }, if_not = { "SPIDER_LEGS" }, remove = { "HASTED" } }
    }
  },

  CRIPPLED = {
    possible_results = { "CRIPPLED","NULLL" },
    always_remove = {},
    conditional = {
      { if_has = { "RESTED" }, result = "NULLL",_if=" if "},
      { if_has = { "HASTED" }, result = "NULLL",_if=" if "},
    }
  },
  
  KNOCKED_DOWN = {
    possible_results = { "KNOCKED_DOWN", "NULLL" },
    always_remove = {"INVISIBLE","SLEEPING"},
    conditional = {
      {if_has = { "RESTED" },result = "RESTED"},
    }
  },
  
  REGENERATION = {
    possible_results = { "REGENERATION"},
    always_remove = {"ACID","POISONED","BLEEDING","SUFFOCATING","BURNING","INFESTED",},
    conditional = {}
  },
  
  FORTIFIED = {
    possible_results = { "FORTIFIED" },
    always_remove = {"BLEEDING","POISONED","BURNING","ACID","DECAYING_TOUCH","INFECTIOUS_DISEASED","DISEASED"},
    conditional = {}
  },
  
  ACID = {
    possible_results = { "ACID", "NULLL" },
    always_remove = {},
    conditional = {
      {if_has = { "FORTIFIED" },remove = {"FORTIFIED"},result = "NULLL"},
    }
  },
  
  BLEEDING = {
    possible_results = { "BLEEDING", "NULLL" },
    always_remove = {},
    conditional = {
      {if_has = { "FORTIFIED" },remove = {"FORTIFIED"},result = "NULLL"},
      {if_has = { "REGENERATION" },remove = {"REGENERATION"},result = "NULLL"}
    }
  },

}




function GetInfoTextForStatus(status,StatusLocs,orig_indent,colourize)
  -- if not StatusLocs then print("GetInfoTextForStatus StatusLocs nil?!",StatusLocs,status,StatusLocs[status]) end
  local s = ""
  local info = deepcopy(StatusScriptRules[status]) -- so we can alter the list without altering the original...
  if info and info.possible_results and next(info.possible_results) then
    local result_status = info.possible_results[1]
    local conditiontext = ""
    local _if = " if "
    local indent = orig_indent
    if info.conditional and next(info.conditional) then
      for _,condition in ipairs(info.conditional) do
        _if = condition._if or _if
        indent = condition.indent and orig_indent..condition.indent or orig_indent
        conditiontext = conditiontext..indent
        if condition.if_has then
          for __,con_status in ipairs(condition.if_has) do
            local con_status_loc = StatusLocs and StatusLocs[con_status] or con_status
            con_status_loc = ColourizeStatus(con_status,con_status_loc,colourize)
            conditiontext = conditiontext.._if..con_status_loc..(CurrentPressedKeys["Ctrl"] and " ("..con_status..")" or "")
          end
        end
        if condition.if_has_any then
          conditiontext = conditiontext.._if
          for __,con_status in ipairs(condition.if_has_any) do
            local con_status_loc = StatusLocs and StatusLocs[con_status] or con_status
            con_status_loc = ColourizeStatus(con_status,con_status_loc,colourize)
            conditiontext = conditiontext..con_status_loc..(CurrentPressedKeys["Ctrl"] and " ("..con_status..")" or "")
            if next(condition.if_has_any,__) then
              conditiontext = conditiontext.." / "
            end
          end
        end
        if condition.if_not then
          conditiontext = conditiontext.._if
          for __,con_status in ipairs(condition.if_not) do
            local con_status_loc = StatusLocs and StatusLocs[con_status] or con_status
            con_status_loc = ColourizeStatus(con_status,con_status_loc,colourize)
            conditiontext = conditiontext.."not "..con_status_loc..(CurrentPressedKeys["Ctrl"] and " ("..con_status..")" or "")
            if next(condition.if_not,__) then
              conditiontext = conditiontext.." and "
            end
          end
        end
        if condition["else"] then
          conditiontext = conditiontext.." else"
        end
        if conditiontext~="" then
          local r_status = condition.result or result_status
          local r_status_loc = StatusLocs and StatusLocs[r_status] or r_status
          r_status_loc = ColourizeStatus(r_status,r_status_loc,colourize)
          conditiontext = conditiontext.." = "..r_status_loc..(CurrentPressedKeys["Ctrl"] and " ("..r_status..")" or "")
          if condition.remove and next(condition.remove) then
            for ___,conrem in ipairs(condition.remove) do
              local status_loc = StatusLocs and StatusLocs[conrem] or conrem
              status_loc = ColourizeStatus(conrem,status_loc,colourize)
              condition.remove[___] = status_loc
            end
            conditiontext = conditiontext..", <font color='#DCDCCC'>removes:</font> "..table.concat(condition.remove,", ")
          end
        end
        if next(info.conditional,_) then
          conditiontext = conditiontext.."\n"
        end
        _if = " elif "
        indent = orig_indent
      end
    end

    if info.always_remove and next(info.always_remove) then
      for ___,conrem in ipairs(info.always_remove) do
        local status_loc = StatusLocs and StatusLocs[conrem] or conrem
        status_loc = ColourizeStatus(conrem,status_loc,colourize)
        info.always_remove[___] = status_loc..(CurrentPressedKeys["Ctrl"] and " ("..conrem..")" or "")
      end
      s = s..orig_indent.."<font color='#DCDCCC'>Removes:</font> "..table.concat(info.always_remove,", ")
    end
    if info.always_remove and next(info.always_remove) and conditiontext~="" then
      s=s.."\n"
    end
    local result_loc = StatusLocs and StatusLocs[result_status] or result_status
    result_loc = ColourizeStatus(result_status,result_loc,colourize)
    if conditiontext~="" then
      s=s..conditiontext
      if not conditiontext:find(" else ",1,true) then
        s=s.."\n"..orig_indent.." else = "..result_loc..(CurrentPressedKeys["Ctrl"] and " ("..result_status..")" or "")
      end
    else
      s=s.."\n"..orig_indent.." = "..result_loc..(CurrentPressedKeys["Ctrl"] and " ("..result_status..")" or "")
    end
  else -- just applying the status without other effects
    local status_loc = StatusLocs and StatusLocs[status] or status
    status_loc = ColourizeStatus(status,status_loc,colourize)
    s=s..status_loc..(CurrentPressedKeys["Ctrl"] and " ("..status..")" or "")
  end
  return s
end


-- local Stati={"POSSESSED","HASTED","STUNNED","STEAM_LANCE","FEAR","SUFFOCATING","POISONED","HEALING_ELIXIR","RESTED","NECROFIRE","MAGIC_SHELL","INVISIBLE","BLIND","VOIDWOKEN","MARKED","CHAIN_HEAL","SPIDER_LEGS","PERMANENTLY_CURSED","CHARMED","CURSED","BLESSED","WET","PETRIFIED","SHOCKED","WEAK","CHILLED","CHICKEN","DISEASED","INFECTIOUS_DISEASED","KNOCKED_DOWN","DEATH_FOG","FORTIFIED","BURNING","CLEAR_MINDED","WINGS","MUTED","REGENERATION","CLEANSE_WOUNDS","CRIPPLED","PLAGUE","WEB","DECAYING_TOUCH","ACID","DRUNK","BLEEDING","FROZEN","ENRAGED","TAUNTED","MADNESS","SLOWED","HOLY_FIRE","VOIDHOWL","INFESTED","WARM","SLEEPING",}
-- for ii,status in ipairs(Stati) do
  -- print(status)
  -- local s = GetInfoTextForStatus(status,nil,"  ")
  -- if s~="" then
    -- print(s)
    -- print("---------")
  -- end
-- end


-- #####################################################

-- fehlende Logik StatusRemovalRules:
-- Wenn etwas durch Bless entfernt wird, dann muss Bless natürlich auch als Result durchgehen,
 -- was es zb nicht tut wenn PERMANENTLY_CURSED, dh. dass man nicht PERMANENTLY_CURSED ist, wäre eine requirement
  -- für alle Bless Folgen
 -- Will man das mit aufnehmen, oder verweist man dabei dann eben auf die StatusScriptRules ? 
 -- lieber verweisen, wird sonst viel zu kompliziert
StatusScriptRemovalRules = {

  WET = {
    { new_status="WARM", forbidden={}, result="WARM" },
    { new_status="BURNING", forbidden={}, result="WARM" },
    { new_status="NECROFIRE", forbidden={"PETRIFIED"}, result="NECROFIRE" },
    { new_status="HOLY_FIRE", forbidden={"PETRIFIED"}, result="HOLY_FIRE" },
    { new_status="CHILLED", forbidden={"BURNING","HOLY_FIRE","WARM"}, result="FROZEN" },
    { new_status="FROZEN", forbidden={}, result="FROZEN" },
    { new_status="STUNNED", forbidden={}, result="STUNNED" },
    { new_status="INVISIBLE", forbidden={"MARKED"}, result="INVISIBLE" },
  },

  WARM = {
    { new_status="WARM", forbidden={}, result="BURNING" },
    { new_status="BURNING", forbidden={"WET"}, result="BURNING" },
    { new_status="NECROFIRE", forbidden={"PETRIFIED"}, result="NECROFIRE" },
    { new_status="HOLY_FIRE", forbidden={"PETRIFIED"}, result="HOLY_FIRE" },
    { new_status="WET", forbidden={}, result="WET" },
    { new_status="CHILLED", forbidden={"BURNING","HOLY_FIRE"}, result="NULLL" },
    { new_status="FROZEN", forbidden={"MAGIC_SHELL","BURNING","HOLY_FIRE","NECROFIRE","HOLY_FIRE"}, result="CHILLED" },
    { new_status="CURSED", forbidden={}, result="BURNING" },
  },

  BURNING = {
    { new_status="NECROFIRE", forbidden={"PETRIFIED"}, result="NECROFIRE" },
    { new_status="HOLY_FIRE", forbidden={"PETRIFIED"}, result="HOLY_FIRE" },
    { new_status="WET", forbidden={}, result="WARM" },
    { new_status="CHILLED", forbidden={}, result="WARM" },
    { new_status="FROZEN", forbidden={"MAGIC_SHELL"}, result="WET" },
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
    { new_status="REGENERATION", forbidden={}, result="REGENERATION" },
    { new_status="FORTIFIED", forbidden={}, result="FORTIFIED" },
    { new_status="BLESSED", forbidden={}, result="HOLY_FIRE" },
    { new_status="MAGIC_SHELL", forbidden={}, result="MAGIC_SHELL" },
    { new_status="CURSED", forbidden={}, result="NECROFIRE" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },

  CHILLED = {
    { new_status="WARM", forbidden={"WARM","BURNING","NECROFIRE","HOLY_FIRE"}, result="NULLL" },
    { new_status="BURNING", forbidden={"WET","WARM"}, result="WARM" },
    { new_status="NECROFIRE", forbidden={"PETRIFIED"}, result="NECROFIRE" },
    { new_status="HOLY_FIRE", forbidden={"PETRIFIED"}, result="HOLY_FIRE" },
    { new_status="WET", forbidden={"BURNING","HOLY_FIRE"}, result="FROZEN" },
    { new_status="CHILLED", forbidden={"BURNING","HOLY_FIRE","WARM"}, result="FROZEN" },
    { new_status="FROZEN", forbidden={}, result="FROZEN" },
    { new_status="CURSED", forbidden={"BLESSED"}, result="FROZEN" },
    { new_status="STEAM_LANCE", forbidden={}, result="STEAM_LANCE" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },

  FROZEN = {
    { new_status="WARM", forbidden={"WARM","BURNING","NECROFIRE","HOLY_FIRE","CHILLED"}, result="CHILLED" },
    { new_status="BURNING", forbidden={"WET","WARM","CHILLED"}, result="WET" },
    { new_status="NECROFIRE", forbidden={"PETRIFIED"}, result="NECROFIRE" },
    { new_status="HOLY_FIRE", forbidden={"PETRIFIED"}, result="HOLY_FIRE" },
    { new_status="BLESSED", forbidden={}, result="CHILLED" },
    { new_status="MAGIC_SHELL", forbidden={}, result="MAGIC_SHELL" },
    { new_status="STEAM_LANCE", forbidden={}, result="STEAM_LANCE" },
  },

  SHOCKED = {
    { new_status="STUNNED", forbidden={"MAGIC_SHELL"}, result="STUNNED" },
    { new_status="WET", forbidden={"BURNING","HOLY_FIRE","CHILLED","FROZEN","NECROFIRE"}, result="STUNNED" },
    { new_status="SHOCKED", forbidden={"MAGIC_SHELL","STUNNED"}, result="STUNNED" },
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
  },

  STUNNED = {    
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
    { new_status="MAGIC_SHELL", forbidden={}, result="MAGIC_SHELL" },
    { new_status="BLESSED", forbidden={}, result="BLESSED" },
  },

  INVISIBLE = {
    { new_status="WET", forbidden={}, result="WET" },
    { new_status="FROZEN", forbidden={}, result="FROZEN" },
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
    { new_status="SHOCKED", forbidden={}, result="SHOCKED" },
    { new_status="STUNNED", forbidden={}, result="STUNNED" },
    { new_status="KNOCKED_DOWN", forbidden={}, result="KNOCKED_DOWN" },
    { new_status="TAUNTED", forbidden={}, result="TAUNTED" },
    { new_status="SLEEPING", forbidden={}, result="SLEEPING" },
  },

  SLEEPING = {
    { new_status="FROZEN", forbidden={}, result="FROZEN" },
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
    { new_status="SHOCKED", forbidden={}, result="SHOCKED" },
    { new_status="STUNNED", forbidden={}, result="STUNNED" },
    { new_status="FEAR", forbidden={"CLEAR_MINDED","ENRAGED"}, result="FEAR" },
    { new_status="CHARMED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="CHARMED" },
    { new_status="TAUNTED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="TAUNTED" },
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
    { new_status="ENRAGED", forbidden={}, result="ENRAGED" },
    { new_status="KNOCKED_DOWN", forbidden={}, result="KNOCKED_DOWN" },
  },

  DRUNK = {
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
    { new_status="DRUNK", forbidden={"CLEAR_MINDED"}, result="SLEEPING" },
  },

  HASTED = {
    { new_status="SLOWED", forbidden={}, result="NULLL" },
    { new_status="CRIPPLED", forbidden={}, result="NULLL" },
    { new_status="WEB", forbidden={"SPIDER_LEGS"}, result="WEB" },
  },

  CRIPPLED = {
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
    { new_status="RESTED", forbidden={}, result="RESTED" },
    { new_status="HASTED", forbidden={}, result="HASTED" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },

  BLEEDING = {
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
    { new_status="REGENERATION", forbidden={}, result="REGENERATION" },
    { new_status="FORTIFIED", forbidden={}, result="FORTIFIED" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
    { new_status="RESTED", forbidden={}, result="RESTED" },
  },

  POISONED = {
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL","BLESSED"}, result="PETRIFIED" },
    { new_status="REGENERATION", forbidden={}, result="REGENERATION" },
    { new_status="FORTIFIED", forbidden={}, result="FORTIFIED" },
    { new_status="MAGIC_SHELL", forbidden={}, result="MAGIC_SHELL" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },

  DISEASED = {
    { new_status="FORTIFIED", forbidden={}, result="FORTIFIED" },
    { new_status="BLESSED", forbidden={}, result="BLESSED" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
    { new_status="STEAM_LANCE", forbidden={}, result="STEAM_LANCE" },
    { new_status="CLEANSE_WOUNDS", forbidden={}, result="CLEANSE_WOUNDS" },
  },

  INFECTIOUS_DISEASED = {
    { new_status="FORTIFIED", forbidden={}, result="FORTIFIED" },
    { new_status="BLESSED", forbidden={}, result="BLESSED" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
    { new_status="STEAM_LANCE", forbidden={}, result="STEAM_LANCE" },
    { new_status="CLEANSE_WOUNDS", forbidden={}, result="CLEANSE_WOUNDS" },
  },

  PLAGUE = {
    { new_status="BLESSED", forbidden={}, result="BLESSED" },
    { new_status="MAGIC_SHELL", forbidden={}, result="MAGIC_SHELL" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
    { new_status="RESTED", forbidden={}, result="RESTED" },
    { new_status="STEAM_LANCE", forbidden={}, result="NULLL" },
    { new_status="CLEANSE_WOUNDS", forbidden={}, result="CLEANSE_WOUNDS" },
  },
  
  INFESTED = {
    { new_status="BLESSED", forbidden={}, result="BLESSED" },
    { new_status="REGENERATION", forbidden={}, result="REGENERATION" },
    { new_status="RESTED", forbidden={}, result="RESTED" },
    { new_status="CHAIN_HEAL", forbidden={}, result="CHAIN_HEAL" },
    { new_status="CLEANSE_WOUNDS", forbidden={}, result="CLEANSE_WOUNDS" },
    { new_status="STEAM_LANCE", forbidden={}, result="STEAM_LANCE" },
  },

  WEB = {
    { new_status="BURNING", forbidden={}, result="BURNING" },
    { new_status="NECROFIRE", forbidden={}, result="NECROFIRE" },
    { new_status="HOLY_FIRE", forbidden={}, result="HOLY_FIRE" },
    { new_status="SPIDER_LEGS", forbidden={}, result="SPIDER_LEGS" },
  },
  
  FEAR = {
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
    { new_status="ENRAGED", forbidden={}, result="ENRAGED" },
    { new_status="CHARMED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="CHARMED" },
    { new_status="TAUNTED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="TAUNTED" },
    { new_status="SLEEPING", forbidden={"CLEAR_MINDED","ENRAGED"}, result="SLEEPING" },
  },

  CHARMED = {
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
    { new_status="ENRAGED", forbidden={}, result="ENRAGED" },
    { new_status="FEAR", forbidden={"CLEAR_MINDED","ENRAGED"}, result="FEAR" },
    { new_status="TAUNTED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="TAUNTED" },
    { new_status="SLEEPING", forbidden={"CLEAR_MINDED","ENRAGED"}, result="SLEEPING" },
  },

  TAUNTED = {
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
    { new_status="ENRAGED", forbidden={}, result="ENRAGED" },
    { new_status="FEAR", forbidden={"CLEAR_MINDED","ENRAGED"}, result="FEAR" },
    { new_status="CHARMED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="CHARMED" },
    { new_status="SLEEPING", forbidden={"CLEAR_MINDED","ENRAGED"}, result="SLEEPING" },
  },

  MADNESS = {
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
    { new_status="ENRAGED", forbidden={}, result="ENRAGED" },
    { new_status="FEAR", forbidden={"CLEAR_MINDED","ENRAGED"}, result="FEAR" },
    { new_status="CHARMED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="CHARMED" },
    { new_status="TAUNTED", forbidden={"CLEAR_MINDED","ENRAGED"}, result="TAUNTED" },
    { new_status="SLEEPING", forbidden={"CLEAR_MINDED","ENRAGED"}, result="SLEEPING" },
  },
  
  BLIND = {
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
    { new_status="RESTED", forbidden={}, result="RESTED" },
  },

  MUTED = {
    { new_status="RESTED", forbidden={}, result="RESTED" },
  },
  
  PETRIFIED = {
    { new_status="STUNNED", forbidden={}, result="STUNNED" },
    { new_status="MAGIC_SHELL", forbidden={}, result="MAGIC_SHELL" },
    { new_status="BLESSED", forbidden={}, result="BLESSED" },
  },
  
  KNOCKED_DOWN = {
    { new_status="RESTED", forbidden={}, result="RESTED" },
  },
  
  ACID = {
    { new_status="FORTIFIED", forbidden={}, result="FORTIFIED" },
    { new_status="REGENERATION", forbidden={}, result="REGENERATION" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },

  SUFFOCATING = {
    { new_status="REGENERATION", forbidden={}, result="REGENERATION" },
    { new_status="MAGIC_SHELL", forbidden={}, result="MAGIC_SHELL" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },
  
  DECAYING_TOUCH = {
    { new_status="FORTIFIED", forbidden={}, result="FORTIFIED" },
    { new_status="BLESSED", forbidden={}, result="BLESSED" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
    { new_status="STEAM_LANCE", forbidden={}, result="STEAM_LANCE" },
  },

  VOIDHOWL = {
    { new_status="BLESSED", forbidden={}, result="NULLL" },
  },
  
  CLEAR_MINDED = {
    { new_status="DRUNK", forbidden={}, result="NULLL" },
    { new_status="FEAR", forbidden={}, result="NULLL" },
    { new_status="CHARMED", forbidden={}, result="NULLL" },
    { new_status="TAUNTED", forbidden={}, result="NULLL" },
    { new_status="SLEEPING", forbidden={}, result="NULLL" },
    { new_status="MADNESS", forbidden={}, result="NULLL" },
    { new_status="ENRAGED", forbidden={}, result="ENRAGED" },
  },
  
  ENRAGED = {
    { new_status="FEAR", forbidden={}, result="NULLL" },
    { new_status="CHARMED", forbidden={}, result="NULLL" },
    { new_status="TAUNTED", forbidden={}, result="NULLL" },
    { new_status="SLEEPING", forbidden={}, result="NULLL" },
    { new_status="CLEAR_MINDED", forbidden={"POSSESSED"}, result="CLEAR_MINDED" },
  },
  
  BLESSED = {
    { new_status="NECROFIRE", forbidden={"PETRIFIED","HOLY_FIRE"}, result="BURNING" },
    { new_status="PETRIFIED", forbidden={"MAGIC_SHELL"}, result="NULLL" },
    { new_status="STUNNED", forbidden={"MAGIC_SHELL"}, result="NULLL" },
    { new_status="DISEASED", forbidden={"FORTIFIED"}, result="NULLL" },
    { new_status="INFECTIOUS_DISEASED", forbidden={"FORTIFIED"}, result="NULLL" },
    { new_status="DECAYING_TOUCH", forbidden={"FORTIFIED"}, result="NULLL" },
    { new_status="CURSED", forbidden={}, result="NULLL" },
  },
  
  HOLY_FIRE = {
    { new_status="NECROFIRE", forbidden={"PETRIFIED"}, result="BURNING" },
    { new_status="WET", forbidden={"BURNING"}, result="WARM" },
    { new_status="CHILLED", forbidden={"BURNING"}, result="WARM" },
    { new_status="FROZEN", forbidden={"BURNING","MAGIC_SHELL"}, result="WET" },
    { new_status="CURSED", forbidden={}, result="BURNING" },
  },
  
  MAGIC_SHELL = {
    { new_status="FROZEN", forbidden={}, result="NULLL" },
    { new_status="PETRIFIED", forbidden={}, result="NULLL" },
    { new_status="SHOCKED", forbidden={}, result="NULLL" },
    { new_status="STUNNED", forbidden={}, result="NULLL" },
  },
  
  SLOWED = {
    { new_status="HASTED", forbidden={}, result="HASTED" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },
  
  CURSED = {
    { new_status="BLESSED", forbidden={}, result="NULLL" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },
  
  WEAK = {
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },
  
  WINGS = {
    { new_status="CHICKEN", forbidden={}, result="CHICKEN" },
  },
  
  RESTED = {
    { new_status="MUTED", forbidden={}, result="NULLL" },
    { new_status="BLIND", forbidden={}, result="NULLL" },
    { new_status="CRIPPLED", forbidden={}, result="NULLL" },
    { new_status="KNOCKED_DOWN", forbidden={}, result="NULLL" },
  },
  
  FORTIFIED = {
    { new_status="ACID", forbidden={}, result="NULLL" },
    { new_status="BLEEDING", forbidden={"REGENERATION"}, result="NULLL" },
    { new_status="DISEASED", forbidden={}, result="NULLL" },
    { new_status="INFECTIOUS_DISEASED", forbidden={}, result="NULLL" },
    { new_status="DECAYING_TOUCH", forbidden={}, result="NULLL" },
  },
  
  NECROFIRE = {
    { new_status="HOLY_FIRE", forbidden={"PETRIFIED"}, result="BURNING" },
    { new_status="BLESSED", forbidden={}, result="BURNING" },
    { new_status="HEALING_ELIXIR", forbidden={}, result="HEALING_ELIXIR" },
  },
  
  REGENERATION = {
    { new_status="BLEEDING", forbidden={}, result="NULLL" },
  },
  
}

-- Status CHILLED removed by:
-- WARM  while not  WARM,BURNING,NECROFIRE,HOLY_FIRE = NULLL
-- BURNING  while not  WET,WARM = WARM
-- NECROFIRE  while not  PETRIFIED = NECROFIRE
-- HOLY_FIRE  while not  PETRIFIED = HOLY_FIRE
-- WET  while not  BURNING,HOLY_FIRE = FROZEN
-- CHILLED  while not  BURNING,HOLY_FIRE,WARM = FROZEN
-- FROZEN = FROZEN
-- CURSED  while not  BLESSED = FROZEN
-- STEAM_LANCE = STEAM_LANCE
-- HEALING_ELIXIR = HEALING_ELIXIR
function GetInfoTextForStatusRemoval(status,StatusLocs,indent,colourize)
  -- if not StatusLocs then print("GetInfoTextForStatusRemoval StatusLocs nil?!",StatusLocs,status,StatusLocs[status]) end
  indent = indent or ""
  local s = ""
  local info = deepcopy(StatusScriptRemovalRules[status])
  if info then
    for i,entry in ipairs(info) do
      local result_loc = StatusLocs and StatusLocs[entry.result] or entry.result
      result_loc = ColourizeStatus(entry.result,result_loc,colourize)
      local new_status_loc = StatusLocs and StatusLocs[entry.new_status] or entry.new_status
      new_status_loc = ColourizeStatus(entry.new_status,new_status_loc,colourize)
      s = s..indent.."- "..new_status_loc..(CurrentPressedKeys["Ctrl"] and " ("..entry.new_status..")" or "")
      if entry.forbidden and next(entry.forbidden) then
        for _,forbid in ipairs(entry.forbidden) do
          local forb_loc = StatusLocs and StatusLocs[forbid] or forbid
          forb_loc = ColourizeStatus(forbid,forb_loc,colourize)
          entry.forbidden[_] = forb_loc..(CurrentPressedKeys["Ctrl"] and " ("..forbid..")" or "")
        end
        s = s.." <font color='#DCDCCC'>while not</font> "..table.concat(entry.forbidden,", ")
      end
      s = s.." = "..result_loc..(CurrentPressedKeys["Ctrl"] and " ("..entry.result..")" or "")
      if next(info,i) then
        s = s.."\n"
      end
    end
  end
  return s
end
-- print(GetInfoTextForStatusRemoval("CHILLED"))