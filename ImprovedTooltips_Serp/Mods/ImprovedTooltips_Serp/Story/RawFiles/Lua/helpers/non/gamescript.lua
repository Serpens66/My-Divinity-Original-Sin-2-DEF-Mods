-- Based on vanilla \Public\Shared\Scripts\Game\Statuses.gameScript
-- first asked ChatGPT to convert this into a useable table, but result was not good.
-- Manually changed the gameScript into lua, by mass replacing parts with text-editor -> gamescript.lua
-- then see gameScriptStatusLogic.lua


local function tabletostring(b)if type(b)~="table"then error("tableToString expects a table")end;local c={}local function d(e)local f=0;local g=0;for h in pairs(e)do if type(h)~="number"or h<=0 or h%1~=0 then return false end;if h>f then f=h end;g=g+1 end;return f==g,f end;local function i(j,k)local e=type(j)local l=string.rep("    ",k)local m=string.rep("    ",k+1)if e=="number"or e=="boolean"then return tostring(j)elseif e=="string"then return string.format("%q",j)elseif e=="nil"then return"nil"elseif e=="table"then if c[j]then error("Cannot serialize table with cyclic reference")end;c[j]=true;local n,o=d(j)local p="{\n"if n then for q=1,o do p=p..m..i(j[q],k+1)..",\n"end else for h,r in pairs(j)do local s;if type(h)=="string"and h:match("^[_%a][_%w]*$")then s=h else s="["..i(h,k+1).."]"end;p=p..m..s.." = "..i(r,k+1)..",\n"end end;p=p..l.."}"c[j]=nil;return p else error("Unsupported type: "..e)end end;return i(b,0)end

-- 43 Fälle

-- else und auch alle and fälle sind nicht abgedeckt

local function table_removearrayvalue(t, valueToRemove)
  for i = #t, 1, -1 do
    if t[i] == valueToRemove then
      table.remove(t, i)
    end
  end
end

local function OrderedTable()
  local key2val, nextkey, firstkey = {}, {}, {}
  nextkey[nextkey] = firstkey
  local function onext(self, key)
    while key ~= nil do
      key = nextkey[key]
      local val = self[key]
      if val ~= nil then return key, val end
    end
  end
  local selfmeta = firstkey
  selfmeta.__nextkey = nextkey
  function selfmeta:__newindex(key, val)
    rawset(self, key, val)
    if nextkey[key] == nil then -- adding a new key
      nextkey[nextkey[nextkey]] = key
      nextkey[nextkey] = key
    end
  end
  function selfmeta:__pairs() return onext, self, firstkey end
  return setmetatable(key2val, selfmeta)
end

local function equals(o1, o2)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end
    local keySet = {}
    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2) == false then
            return false
        end
        keySet[key1] = true
    end
    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

-- local Stati={"NULL","POSSESSED","HASTED","STUNNED","STEAM_LANCE","FEAR","SUFFOCATING","POISONED","HEALING_ELIXIR","RESTED","NECROFIRE","MAGIC_SHELL","INVISIBLE","BLIND","VOIDWOKEN","MARKED","CHAIN_HEAL","SPIDER_LEGS","PERMANENTLY_CURSED","CHARMED","CURSED","BLESSED","WET","PETRIFIED","SHOCKED","WEAK","CHILLED","CHICKEN","DISEASED","INFECTIOUS_DISEASED","KNOCKED_DOWN","DEATH_FOG","FORTIFIED","BURNING","CLEAR_MINDED","WINGS","MUTED","REGENERATION","CLEANSE_WOUNDS","CRIPPLED","PLAGUE","WEB","DECAYING_TOUCH","ACID","DRUNK","BLEEDING","FROZEN","ENRAGED","TAUNTED","MADNESS","SLOWED","HOLY_FIRE","VOIDHOWL","INFESTED","WARM","SLEEPING",}
-- local Stati={"NULL","POSSESSED","HASTED","STUNNED","WEB","SPIDER_LEGS"}
local Stati={"NULL","WARM","WET","BURNING","CHILLED","FROZEN","NECROFIRE","HOLY_FIRE","SHOCKED"}
local NULL="NULL";local WARM="WARM";local WET="WET";local BURNING="BURNING";local NECROFIRE="NECROFIRE";local HOLY_FIRE="HOLY_FIRE";local CHILLED="CHILLED";local FROZEN="FROZEN";local PETRIFIED="PETRIFIED";local WEB="WEB";local INVISIBLE="INVISIBLE";local SLEEPING="SLEEPING";local MAGIC_SHELL="MAGIC_SHELL";local SHOCKED="SHOCKED";local STUNNED="STUNNED";local DRUNK="DRUNK";local CLEAR_MINDED="CLEAR_MINDED";local SLOWED="SLOWED";local HASTED="HASTED";local FEAR="FEAR";local CHARMED="CHARMED";local TAUNTED="TAUNTED";local MADNESS="MADNESS";local ENRAGED="ENRAGED";local RESTED="RESTED";local MUTED="MUTED";local BLIND="BLIND";local CRIPPLED="CRIPPLED";local KNOCKED_DOWN="KNOCKED_DOWN";local BLEEDING="BLEEDING";local POISONED="POISONED";local ACID="ACID";local SUFFOCATING="SUFFOCATING";local REGENERATION="REGENERATION";local FORTIFIED="FORTIFIED";local DISEASED="DISEASED";local INFECTIOUS_DISEASED="INFECTIOUS_DISEASED";local DECAYING_TOUCH="DECAYING_TOUCH";local INFESTED="INFESTED";local PLAGUE="PLAGUE";local BLESSED="BLESSED";local CURSED="CURSED";local PERMANENTLY_CURSED="PERMANENTLY_CURSED";local VOIDHOWL="VOIDHOWL";local DEATH_FOG="DEATH_FOG";local CHICKEN="CHICKEN";local WINGS="WINGS";local HEALING_ELIXIR="HEALING_ELIXIR";local WEAK="WEAK";local CHAIN_HEAL="CHAIN_HEAL";local CLEANSE_WOUNDS="CLEANSE_WOUNDS";local STEAM_LANCE="STEAM_LANCE";local SPIDER_LEGS="SPIDER_LEGS";local MARKED="MARKED";local POSSESSED="POSSESSED";local VOIDWOKEN="VOIDWOKEN";


local null = "null"
local _Result = "_Result"
local Result = nil
local RemoveList = {}
local CharacterStatus = nil
local CharacterStatus2 = nil
local char2waschecked = nil
local Checks = {}

local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end
local function Set_Result(status)
  Result = status
end
local function ListClear_RemoveList()
  RemoveList = {}
end
local function ListAdd(list,add)
  if not table_contains_value(list,add) then
    table.insert(list,add)
  end
end
local function CharacterHasStatus(check,char,status)
  local ret
  if check~="or" then
    ret = CharacterStatus2==status
    char2waschecked = true
  else
    ret = CharacterStatus==status
  end
  table.insert(Checks,{status=status,check=check,ret=ret})
  return ret
end

local finalresult = {}
local function StatusAdded(char,status)
  if status==NULL then return end
  finalresult[status] = OrderedTable()
  for _,charstatus in pairs(Stati) do
    dobreak = false
  for _,charstatus2 in pairs(Stati) do
    CharacterStatus = charstatus
    CharacterStatus2 = charstatus2
    Result = nil
    char2waschecked = nil
    RemoveList = {}
    Checks = {}
    if status==WARM then
      Set_Result(WARM)
      ListClear_RemoveList()
      ListAdd(RemoveList,WET)
      if CharacterHasStatus("or",_Character, WARM) then
        ListAdd(RemoveList,WARM)
        Set_Result(BURNING)    
      elseif CharacterHasStatus("or",_Character, BURNING) or CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then
        Set_Result(null) 
      elseif CharacterHasStatus("or",_Character, CHILLED) then
        ListAdd(RemoveList,CHILLED)
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, FROZEN) then
        ListAdd(RemoveList,FROZEN)   
        Set_Result(CHILLED)    
      end
  
    elseif status==BURNING then
      Set_Result(BURNING)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, WARM) and not CharacterHasStatus("andnot",_Character, WET) then
        ListAdd(RemoveList,WARM)
      elseif CharacterHasStatus("or",_Character, WET) and not CharacterHasStatus("andnot",_Character, WARM) then
        ListAdd(RemoveList,WET)
        Set_Result( WARM)
      elseif CharacterHasStatus("or",_Character, WET) and CharacterHasStatus("and",_Character, WARM) then
        ListAdd(RemoveList,WET)
      elseif CharacterHasStatus("or",_Character, CHILLED) then
        ListAdd(RemoveList,CHILLED)
        Set_Result( WARM)
      elseif CharacterHasStatus("or",_Character, FROZEN) then
        ListAdd(RemoveList,FROZEN)
        Set_Result( WET)
      elseif CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then
        Set_Result(null)
      end
      ListAdd(RemoveList,WEB)
      
    elseif status==NECROFIRE then
      Set_Result(NECROFIRE)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, PETRIFIED) then
        Set_Result(null)
      else
        ListAdd(RemoveList,WARM)
        ListAdd(RemoveList,BURNING)
        ListAdd(RemoveList,CHILLED)
        ListAdd(RemoveList,WET)
        ListAdd(RemoveList,FROZEN)
        if CharacterHasStatus("or",_Character, HOLY_FIRE) then
          ListAdd(RemoveList,HOLY_FIRE)   
          Set_Result( BURNING)
        elseif CharacterHasStatus("or",_Character, BLESSED) then
          ListAdd(RemoveList,BLESSED)   
          Set_Result( BURNING)   
        end
      end
      ListAdd(RemoveList,WEB)
      
    elseif status==HOLY_FIRE then
      Set_Result(HOLY_FIRE)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, PETRIFIED) then
        Set_Result(null)
      else
        ListAdd(RemoveList,WARM)
        ListAdd(RemoveList,BURNING)
        ListAdd(RemoveList,CHILLED)
        ListAdd(RemoveList,WET)
        ListAdd(RemoveList,FROZEN)
        if CharacterHasStatus("or",_Character, NECROFIRE) then
          ListAdd(RemoveList,NECROFIRE) 
          Set_Result( BURNING)
        end
      end
      ListAdd(RemoveList,WEB)
      
    elseif status==WET then
      Set_Result(WET)
      ListClear_RemoveList()
      ListAdd(RemoveList,WARM)
      ListAdd(RemoveList,INVISIBLE)
      if CharacterHasStatus("or",_Character, BURNING) then
        ListAdd(RemoveList,BURNING)
        Set_Result( WARM)
      elseif CharacterHasStatus("or",_Character, HOLY_FIRE) then
        ListAdd(RemoveList,HOLY_FIRE)
        Set_Result( WARM)
      elseif CharacterHasStatus("or",_Character, CHILLED) then
        ListAdd(RemoveList,CHILLED)
        Set_Result(FROZEN)
      elseif CharacterHasStatus("or",_Character, FROZEN) or CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, SHOCKED) then
        ListAdd(RemoveList,SHOCKED)
        Set_Result(STUNNED)
      end
      
    elseif status==CHILLED then
      Set_Result(CHILLED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, BURNING) then
        ListAdd(RemoveList,BURNING)
        Set_Result( WARM)
      elseif CharacterHasStatus("or",_Character, HOLY_FIRE) then
        ListAdd(RemoveList,HOLY_FIRE)
        Set_Result( WARM)
      elseif CharacterHasStatus("or",_Character, WARM) then
        ListAdd(RemoveList,WARM)    
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, CHILLED) or CharacterHasStatus("or",_Character, WET) then
        ListAdd(RemoveList,CHILLED)
        ListAdd(RemoveList,WET)
        Set_Result( FROZEN)
      elseif CharacterHasStatus("or",_Character, FROZEN) or CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then    
        Set_Result(null)
      end
      
    elseif status==FROZEN then
      Set_Result(FROZEN)
      ListClear_RemoveList()
      ListAdd(RemoveList,CHILLED)
      ListAdd(RemoveList,WET)
      ListAdd(RemoveList,INVISIBLE)
      ListAdd(RemoveList,SLEEPING)
      if CharacterHasStatus("or",_Character, MAGIC_SHELL) then
        ListClear_RemoveList()
        ListAdd(RemoveList,MAGIC_SHELL) 
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, BURNING) then
        ListAdd(RemoveList,BURNING)
        Set_Result( WET)
      elseif CharacterHasStatus("or",_Character, HOLY_FIRE) then
        ListAdd(RemoveList,HOLY_FIRE)
        Set_Result( WET)
      elseif CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, WARM) then
        ListAdd(RemoveList,WARM)
        Set_Result( CHILLED)
      end
      
    elseif status==PETRIFIED then
      Set_Result(PETRIFIED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, MAGIC_SHELL) then
        ListClear_RemoveList()
        ListAdd(RemoveList,MAGIC_SHELL) 
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, BLESSED) then
        ListClear_RemoveList()
        ListAdd(RemoveList,BLESSED)   
        Set_Result(null)
      end
      if Result==PETRIFIED then
        ListAdd(RemoveList,STUNNED) 
        ListAdd(RemoveList,SHOCKED)
        ListAdd(RemoveList,BLEEDING)
        ListAdd(RemoveList,CRIPPLED)
        ListAdd(RemoveList,BURNING)
        ListAdd(RemoveList,POISONED)
        ListAdd(RemoveList,INVISIBLE)
        ListAdd(RemoveList,SLEEPING)
      end   
      
    elseif status==SHOCKED then
      Set_Result(SHOCKED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, MAGIC_SHELL) then
        ListAdd(RemoveList,MAGIC_SHELL) 
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, STUNNED) then
        ListAdd(RemoveList,SHOCKED) 
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, SHOCKED) or CharacterHasStatus("or",_Character, WET) then
        ListAdd(RemoveList,SHOCKED) 
        Set_Result(STUNNED)
      end
      ListAdd(RemoveList,INVISIBLE)
      ListAdd(RemoveList,SLEEPING)
      
    elseif status==STUNNED then
      Set_Result(STUNNED)
      ListClear_RemoveList()
      ListAdd(RemoveList,SHOCKED)
      ListAdd(RemoveList,PETRIFIED)
      ListAdd(RemoveList,WET) 
      ListAdd(RemoveList,INVISIBLE)
      ListAdd(RemoveList,SLEEPING)
      if CharacterHasStatus("or",_Character, MAGIC_SHELL) then
        ListClear_RemoveList()
        ListAdd(RemoveList,MAGIC_SHELL) 
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, BLESSED) then
        ListClear_RemoveList()
        ListAdd(RemoveList,BLESSED) 
        Set_Result(null)
      end
      
    elseif status==DRUNK then 
      Set_Result(DRUNK)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, CLEAR_MINDED) then
        ListAdd(RemoveList,CLEAR_MINDED)
        Set_Result( null)  
      elseif CharacterHasStatus("or",_Character, DRUNK) then
        ListAdd(RemoveList,DRUNK)
        Set_Result( SLEEPING)    
      end
      
    elseif status==SLOWED then  
      Set_Result(SLOWED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, HASTED) then
        ListAdd(RemoveList,HASTED)
        Set_Result(null)
      end
      
    elseif status==HASTED then  
      Set_Result(HASTED)
      ListClear_RemoveList()
      ListAdd(RemoveList,SLOWED)
      ListAdd(RemoveList,CRIPPLED)

    elseif status==FEAR then  
      Set_Result(FEAR)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
        ListAdd(RemoveList,CLEAR_MINDED)
        ListAdd(RemoveList,ENRAGED)
        Set_Result(null)
      else
        ListAdd(RemoveList,CHARMED)
        ListAdd(RemoveList,TAUNTED)
        ListAdd(RemoveList,SLEEPING)  
        ListAdd(RemoveList,MADNESS) 
      end
      
    elseif status==CHARMED then 
      Set_Result(CHARMED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
        ListAdd(RemoveList,CLEAR_MINDED)
        ListAdd(RemoveList,ENRAGED)   
        Set_Result(null)
      else
        ListAdd(RemoveList,FEAR)
        ListAdd(RemoveList,TAUNTED)
        ListAdd(RemoveList,SLEEPING)
        ListAdd(RemoveList,MADNESS)   
      end
      
    elseif status==TAUNTED then 
      Set_Result(TAUNTED)
      ListClear_RemoveList()
      ListAdd(RemoveList,INVISIBLE)
      if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
        ListAdd(RemoveList,CLEAR_MINDED)
        ListAdd(RemoveList,ENRAGED)   
        Set_Result(null)
      else
        ListAdd(RemoveList,CHARMED)
        ListAdd(RemoveList,FEAR)
        ListAdd(RemoveList,SLEEPING)    
        ListAdd(RemoveList,MADNESS) 
      end
      
    elseif status==SLEEPING then  
      Set_Result(SLEEPING)
      ListClear_RemoveList()
      ListAdd(RemoveList,INVISIBLE)
      if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
        ListAdd(RemoveList,CLEAR_MINDED)
        ListAdd(RemoveList,ENRAGED) 
        Set_Result(null)
      else
        ListAdd(RemoveList,CHARMED)
        ListAdd(RemoveList,TAUNTED)
        ListAdd(RemoveList,FEAR)    
        ListAdd(RemoveList,MADNESS) 
      end
      
    elseif status==MADNESS then 
      Set_Result(MADNESS)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, CLEAR_MINDED) then
        ListAdd(RemoveList,CLEAR_MINDED)
        Set_Result(null)
      end
      
    elseif status==CLEAR_MINDED then  
      Set_Result(CLEAR_MINDED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, POSSESSED) then
        Set_Result(null)
      else
        ListAdd(RemoveList,FEAR)
        ListAdd(RemoveList,CHARMED)
        ListAdd(RemoveList,TAUNTED)
        ListAdd(RemoveList,SLEEPING)
        ListAdd(RemoveList,ENRAGED)
        ListAdd(RemoveList,BLIND)
        ListAdd(RemoveList,DRUNK)
        ListAdd(RemoveList,MADNESS)
      end
      
    elseif status==ENRAGED then 
      Set_Result(ENRAGED)
      ListClear_RemoveList()
      ListAdd(RemoveList,FEAR)
      ListAdd(RemoveList,CHARMED)
      ListAdd(RemoveList,TAUNTED)
      ListAdd(RemoveList,SLEEPING)
      ListAdd(RemoveList,MADNESS) 
      ListAdd(RemoveList,CLEAR_MINDED)
      
    elseif status==RESTED then  
      Set_Result(RESTED)
      ListClear_RemoveList()
      ListAdd(RemoveList,MUTED)
      ListAdd(RemoveList,BLIND)
      ListAdd(RemoveList,CRIPPLED)
      ListAdd(RemoveList,KNOCKED_DOWN)
      ListAdd(RemoveList,BLEEDING)
      ListAdd(RemoveList,PLAGUE)
      ListAdd(RemoveList,INFESTED)  
      
    elseif status==MUTED then 
      Set_Result(MUTED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, RESTED) then
        ListAdd(RemoveList,RESTED)
        Set_Result(null)
      end
      
    elseif status==BLIND then 
      Set_Result(BLIND)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, RESTED) then
        ListAdd(RemoveList,RESTED)
        Set_Result(null)
      end
      
    elseif status==CRIPPLED then  
      Set_Result(CRIPPLED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, RESTED) then
        ListAdd(RemoveList,RESTED)
        Set_Result(null)
      end
      if CharacterHasStatus("or",_Character, HASTED) then
        ListAdd(RemoveList,HASTED)
        Set_Result(null)
      end
      
    elseif status==KNOCKED_DOWN then  
      Set_Result(KNOCKED_DOWN)
      ListClear_RemoveList()
      ListAdd(RemoveList,INVISIBLE)
      ListAdd(RemoveList,SLEEPING)
      if CharacterHasStatus("or",_Character, RESTED) then
        ListAdd(RemoveList,RESTED)
        Set_Result(null)
      end
      
    elseif status==REGENERATION then  
      Set_Result(REGENERATION)
      ListClear_RemoveList()
      ListAdd(RemoveList,ACID)
      ListAdd(RemoveList,POISONED)
      ListAdd(RemoveList,BLEEDING)
      ListAdd(RemoveList,SUFFOCATING)
      ListAdd(RemoveList,BURNING)
      ListAdd(RemoveList,INFESTED)
      
    elseif status==FORTIFIED then 
      Set_Result(FORTIFIED)
      ListClear_RemoveList()
      ListAdd(RemoveList,ACID)
      ListAdd(RemoveList,POISONED)
      ListAdd(RemoveList,BURNING)
      ListAdd(RemoveList,BLEEDING)
      ListAdd(RemoveList,DISEASED)
      ListAdd(RemoveList,INFECTIOUS_DISEASED) 
      ListAdd(RemoveList,DECAYING_TOUCH)  
      
    elseif status==ACID then  
      Set_Result(ACID)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, FORTIFIED) then
        ListAdd(RemoveList,FORTIFIED)
        Set_Result(null)
      end
      
    elseif status==BLEEDING then  
      Set_Result(BLEEDING)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, REGENERATION) then
        ListAdd(RemoveList,REGENERATION)
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, FORTIFIED) then
        ListAdd(RemoveList,FORTIFIED)
        Set_Result(null)
      end

    elseif status==BLESSED then
      Set_Result(BLESSED)
      ListClear_RemoveList()
      ListAdd(RemoveList,DISEASED)
      ListAdd(RemoveList,INFECTIOUS_DISEASED) 
      ListAdd(RemoveList,DECAYING_TOUCH)  
      ListAdd(RemoveList,PETRIFIED) 
      ListAdd(RemoveList,STUNNED) 
      ListAdd(RemoveList,FROZEN)  
      ListAdd(RemoveList,INFESTED)  
      ListAdd(RemoveList,PLAGUE)  
      if CharacterHasStatus("or",_Character, FROZEN) then
        ListAdd(RemoveList,FROZEN)
        Set_Result( CHILLED)
      end   
      if CharacterHasStatus("or",_Character, BURNING) then
        ListAdd(RemoveList,BURNING)
        Set_Result( HOLY_FIRE)
      end   
      if CharacterHasStatus("or",_Character, NECROFIRE) then
        ListAdd(RemoveList,NECROFIRE)
        Set_Result( BURNING)
      end 
      if CharacterHasStatus("or",_Character, CURSED) then
        ListAdd(RemoveList,CURSED)
        Set_Result(null)
      end 
      if CharacterHasStatus("or",_Character, PERMANENTLY_CURSED) then
        Set_Result(null)
      end 
      if CharacterHasStatus("or",_Character, VOIDHOWL) then
        ListAdd(RemoveList,VOIDHOWL)
        Set_Result(null)
      end   
            
    elseif status==MAGIC_SHELL then
      Set_Result(MAGIC_SHELL)
      ListClear_RemoveList()
      ListAdd(RemoveList,FROZEN)  
      ListAdd(RemoveList,STUNNED)   
      ListAdd(RemoveList,PETRIFIED)
      ListAdd(RemoveList,PLAGUE)
      ListAdd(RemoveList,SUFFOCATING)
      ListAdd(RemoveList,POISONED)
      ListAdd(RemoveList,BURNING)
      
    elseif status==CURSED then  
      Set_Result(CURSED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, BLESSED) then
        ListAdd(RemoveList,BLESSED)
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, CHILLED) then
        ListAdd(RemoveList,CHILLED)
        Set_Result( FROZEN)
      end 
      if CharacterHasStatus("or",_Character, BURNING) then
        ListAdd(RemoveList,BURNING)
        Set_Result( NECROFIRE)
      end       
      if CharacterHasStatus("or",_Character, WARM) or CharacterHasStatus("or",_Character, HOLY_FIRE) then
        ListAdd(RemoveList,WARM)
        ListAdd(RemoveList,HOLY_FIRE)
        Set_Result( BURNING)
      end   
      
    elseif status==DISEASED then  
      Set_Result(DISEASED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, FORTIFIED) then
        ListAdd(RemoveList,FORTIFIED)   
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, BLESSED) then
        ListAdd(RemoveList,BLESSED)   
        Set_Result(null)
      end 
      
    elseif status==INFECTIOUS_DISEASED then 
      Set_Result(INFECTIOUS_DISEASED)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, FORTIFIED) then
        ListAdd(RemoveList,FORTIFIED) 
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, BLESSED) then
        ListAdd(RemoveList,BLESSED) 
        Set_Result(null)
      end 
      
    elseif status==DECAYING_TOUCH then  
      Set_Result(DECAYING_TOUCH)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, FORTIFIED) then
        ListAdd(RemoveList,FORTIFIED) 
        Set_Result(null)
      elseif CharacterHasStatus("or",_Character, BLESSED) then
        ListAdd(RemoveList,BLESSED) 
        Set_Result(null)
      end   
      
    elseif status==INVISIBLE then 
      Set_Result(INVISIBLE)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, MARKED) then
        ListAdd(RemoveList,INVISIBLE) 
        Set_Result(null)
      else
        ListAdd(RemoveList,WET)
      end   
      
    elseif status==CHICKEN then
      Set_Result( CHICKEN)
      ListClear_RemoveList()
      ListAdd(RemoveList,WINGS)
      if CharacterHasStatus("or",_Character, CHICKEN) then
        Set_Result(null)
      end   
      
    elseif status==HEALING_ELIXIR then
      Set_Result(HEALING_ELIXIR)
      ListClear_RemoveList()
      ListAdd(RemoveList,WEAK)
      ListAdd(RemoveList,SLOWED)
      ListAdd(RemoveList,DISEASED)
      ListAdd(RemoveList,POISONED)
      ListAdd(RemoveList,BLEEDING)
      ListAdd(RemoveList,CRIPPLED)
      ListAdd(RemoveList,CURSED)
      ListAdd(RemoveList,CHILLED)
      ListAdd(RemoveList,DRUNK)
      ListAdd(RemoveList,BURNING)
      ListAdd(RemoveList,BLEEDING)
      ListAdd(RemoveList,NECROFIRE)
      ListAdd(RemoveList,ACID)
      ListAdd(RemoveList,SUFFOCATING)
      ListAdd(RemoveList,DECAYING_TOUCH)
      ListAdd(RemoveList,INFECTIOUS_DISEASED)
      ListAdd(RemoveList,PLAGUE)
      

    elseif status==CHAIN_HEAL then
      Set_Result(CHAIN_HEAL)
      ListClear_RemoveList()
      ListAdd(RemoveList,INFESTED)
      

    elseif status==CLEANSE_WOUNDS then
      Set_Result(CLEANSE_WOUNDS)
      ListClear_RemoveList()
      ListAdd(RemoveList,INFESTED)
      ListAdd(RemoveList,PLAGUE)
      ListAdd(RemoveList,DISEASED)
      ListAdd(RemoveList,INFECTIOUS_DISEASED)
      

    elseif status==STEAM_LANCE then
      Set_Result(STEAM_LANCE)
      ListClear_RemoveList()
      ListAdd(RemoveList,FROZEN)
      ListAdd(RemoveList,CHILLED)
      ListAdd(RemoveList,DISEASED)
      ListAdd(RemoveList,INFECTIOUS_DISEASED)
      ListAdd(RemoveList,DECAYING_TOUCH)
      ListAdd(RemoveList,PLAGUE)
      ListAdd(RemoveList,INFESTED)  
      if CharacterHasStatus("or",_Character, PLAGUE) then
        ListAdd(RemoveList,PLAGUE)
        Set_Result(null)
      end   


    elseif status==WEB then
      Set_Result(WEB)
      ListClear_RemoveList()
      if CharacterHasStatus("or",_Character, SPIDER_LEGS) and not CharacterHasStatus("andnot",_Character, HASTED) then
        Set_Result(HASTED)   
      elseif CharacterHasStatus("or",_Character, SPIDER_LEGS) then
        Set_Result( null) -- Don't reapply Haste to avoid spam
      elseif CharacterHasStatus("or",_Character, HASTED) and not CharacterHasStatus("andnot",_Character, SPIDER_LEGS) then
        ListAdd(RemoveList,HASTED)
      end   
      

    elseif status==SPIDER_LEGS then
      Set_Result(SPIDER_LEGS)
      ListAdd(RemoveList,WEB)
    
    end
    -- only if different to no charstatus
    if Result~=nil then
      if not(charstatus==NULL and charstatus2==NULL) and (equals(RemoveList,finalresult[status][NULL][NULL].RemoveList) or (finalresult[status][charstatus] and finalresult[status][charstatus][NULL] and equals(RemoveList,finalresult[status][charstatus][NULL].RemoveList))) then
        RemoveList = {}
      elseif not(charstatus==NULL and charstatus2==NULL) and finalresult[status][NULL][NULL].RemoveList and next(RemoveList) then
        local toremove={}
        for i,entry in ipairs(RemoveList) do
          if table_contains_value(finalresult[status][NULL][NULL].RemoveList,entry) then
            table.insert(toremove,entry)
          end
        end
        for _,entry in ipairs(toremove) do
          table_removearrayvalue(RemoveList,entry)
        end
      end 
      if ((charstatus==NULL and charstatus2==NULL) or ((Result~=status and (not finalresult[status][charstatus] or finalresult[status][charstatus][NULL].Result~=Result)) or next(RemoveList))) then
        finalresult[status][charstatus] = finalresult[status][charstatus] or OrderedTable()
        -- finalresult[status][charstatus] = {Result=Result,RemoveList=RemoveList,Checks=Checks}
        -- table.insert(finalresult[status][charstatus],{Result=Result,RemoveList=RemoveList,Checks=Checks,CharacterStatus2=CharacterStatus2})
        finalresult[status][charstatus][charstatus2] = {Result=Result,RemoveList=RemoveList,Checks=Checks}
      end
    else -- status has no extra rules in this script
      dobreak = true
      break
    end
    if not(charstatus==NULL and charstatus2==NULL) and not char2waschecked then
      break -- break the charstatus2 loop
    end
  end
  if dobreak then break end
  end
end
  
  -- TODO:
   -- sicherstellen, dass nur relevante infos drinstehe.
    -- aktuell wird zb. jeder charstatus bei HEALING_ELIXIR aufgelistet und bei jedem passiert dasselbe.
    -- dh es muss erkannt werden, wann etwas immer passiert, unabhängig vom status und wann etwas nur wegen einem status passiert.
    -- und dann eig auch noch eine kombination aus mehreren stati... 
  -- dazu mal mit CharacterStatus==nil durchlaufen lassen
   -- und dann immer das ergebnis mit einem charstatus vergleichen und nur die Unterschiede dazu dann aufnehmen
  -- und die Dinge beim charstatus=nil dann eben als immer gültigen effekt nehmen
  
for _,status in pairs(Stati) do
  StatusAdded(nil,status)
end


for status,v in pairs(finalresult) do
  if not next(v) then
    finalresult[status] = nil
  else
    for charstatus,vv in pairs(v) do
      for charstatus2,vvv in pairs(vv) do
        -- TODO:
        -- wir wollen die einträge aus RemoveList entfernen, die in ALLEN charstatus charstatus2 kombinationen vorkommen.
         -- diese sollen aus allen kombis, außer aus NULL NULL entfernt werden (anstelle des table_removearrayvalue codes oben)
      end
    end
  end
end

-- order by check table to have the same order like the if conditions processed
local ordered_finalresult = OrderedTable()
for status,v in pairs(finalresult) do
  ordered_finalresult[status] = ordered_finalresult[status] or OrderedTable()
  for i,check in ipairs(v.NULL.NULL.Checks) do
    local checkstatus = check.status
    ordered_finalresult[status][checkstatus] = finalresult[status][checkstatus]
  end
end

print(tabletostring(ordered_finalresult))

-- ###### RESULT:

local s = "Status WARM"
printtable = {}
for charstatus,entry1 in pairs(ordered_finalresult["WARM"]) do
  table.insert(printtable,{charstatus=(charstatus=="NULL" and "Normal" or charstatus),Result=entry1.NULL.Result,Remove=table.concat(entry1.NULL.RemoveList)})
end
-- TODO: wenn result in printtable für manche identisch ist, dann zusammenfassen zu einem eintrag

for _,entry in ipairs(printtable) do
  s = s.."\n + "..entry.charstatus.." = "..entry.Result
  if entry.Remove~="" then
    s=s.." - "..entry.Remove
  end
  s = s.."\n-------"
end
print(s)