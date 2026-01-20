local function tabletostring(b)if type(b)~="table"then error("tableToString expects a table")end;local c={}local function d(e)local f=0;local g=0;for h in pairs(e)do if type(h)~="number"or h<=0 or h%1~=0 then return false end;if h>f then f=h end;g=g+1 end;return f==g,f end;local function i(j,k)local e=type(j)local l=string.rep("    ",k)local m=string.rep("    ",k+1)if e=="number"or e=="boolean"then return tostring(j)elseif e=="string"then return string.format("%q",j)elseif e=="nil"then return"nil"elseif e=="table"then if c[j]then error("Cannot serialize table with cyclic reference")end;c[j]=true;local n,o=d(j)local p="{\n"if n then for q=1,o do p=p..m..i(j[q],k+1)..",\n"end else for h,r in pairs(j)do local s;if type(h)=="string"and h:match("^[_%a][_%w]*$")then s=h else s="["..i(h,k+1).."]"end;p=p..m..s.." = "..i(r,k+1)..",\n"end end;p=p..l.."}"c[j]=nil;return p else error("Unsupported type: "..e)end end;return i(b,0)end


local Stati={WARM="WARM",WET="WET",BURNING="BURNING",NECROFIRE="NECROFIRE",HOLY_FIRE="HOLY_FIRE",CHILLED="CHILLED",FROZEN="FROZEN",PETRIFIED="PETRIFIED",QUEST_OVERGROWN="QUEST_OVERGROWN",WEB="WEB",INVISIBLE="INVISIBLE",SLEEPING="SLEEPING",MAGIC_SHELL="MAGIC_SHELL",SHOCKED="SHOCKED",STUNNED="STUNNED",DRUNK="DRUNK",CLEAR_MINDED="CLEAR_MINDED",SLOWED="SLOWED",HASTED="HASTED",FEAR="FEAR",CHARMED="CHARMED",TAUNTED="TAUNTED",MADNESS="MADNESS",ENRAGED="ENRAGED",RESTED="RESTED",MUTED="MUTED",BLIND="BLIND",CRIPPLED="CRIPPLED",KNOCKED_DOWN="KNOCKED_DOWN",BLEEDING="BLEEDING",POISONED="POISONED",ACID="ACID",SUFFOCATING="SUFFOCATING",REGENERATION="REGENERATION",FORTIFIED="FORTIFIED",DISEASED="DISEASED",INFECTIOUS_DISEASED="INFECTIOUS_DISEASED",DECAYING_TOUCH="DECAYING_TOUCH",INFESTED="INFESTED",PLAGUE="PLAGUE",BLESSED="BLESSED",CURSED="CURSED",PERMANENTLY_CURSED="PERMANENTLY_CURSED",VOIDHOWL="VOIDHOWL",DEATH_FOG="DEATH_FOG",CHICKEN="CHICKEN",WINGS="WINGS",HEALING_ELIXIR="HEALING_ELIXIR",WEAK="WEAK",CHAIN_HEAL="CHAIN_HEAL",CLEANSE_WOUNDS="CLEANSE_WOUNDS",STEAM_LANCE="STEAM_LANCE",SPIDER_LEGS="SPIDER_LEGS",MARKED="MARKED",POSSESSED="POSSESSED",VOIDWOKEN="VOIDWOKEN",}
local WARM="WARM";local WET="WET";local BURNING="BURNING";local NECROFIRE="NECROFIRE";local HOLY_FIRE="HOLY_FIRE";local CHILLED="CHILLED";local FROZEN="FROZEN";local PETRIFIED="PETRIFIED";local QUEST_OVERGROWN="QUEST_OVERGROWN";local WEB="WEB";local INVISIBLE="INVISIBLE";local SLEEPING="SLEEPING";local MAGIC_SHELL="MAGIC_SHELL";local SHOCKED="SHOCKED";local STUNNED="STUNNED";local DRUNK="DRUNK";local CLEAR_MINDED="CLEAR_MINDED";local SLOWED="SLOWED";local HASTED="HASTED";local FEAR="FEAR";local CHARMED="CHARMED";local TAUNTED="TAUNTED";local MADNESS="MADNESS";local ENRAGED="ENRAGED";local RESTED="RESTED";local MUTED="MUTED";local BLIND="BLIND";local CRIPPLED="CRIPPLED";local KNOCKED_DOWN="KNOCKED_DOWN";local BLEEDING="BLEEDING";local POISONED="POISONED";local ACID="ACID";local SUFFOCATING="SUFFOCATING";local REGENERATION="REGENERATION";local FORTIFIED="FORTIFIED";local DISEASED="DISEASED";local INFECTIOUS_DISEASED="INFECTIOUS_DISEASED";local DECAYING_TOUCH="DECAYING_TOUCH";local INFESTED="INFESTED";local PLAGUE="PLAGUE";local BLESSED="BLESSED";local CURSED="CURSED";local PERMANENTLY_CURSED="PERMANENTLY_CURSED";local VOIDHOWL="VOIDHOWL";local DEATH_FOG="DEATH_FOG";local CHICKEN="CHICKEN";local WINGS="WINGS";local HEALING_ELIXIR="HEALING_ELIXIR";local WEAK="WEAK";local CHAIN_HEAL="CHAIN_HEAL";local CLEANSE_WOUNDS="CLEANSE_WOUNDS";local STEAM_LANCE="STEAM_LANCE";local SPIDER_LEGS="SPIDER_LEGS";local MARKED="MARKED";local POSSESSED="POSSESSED";local VOIDWOKEN="VOIDWOKEN";

local tags = {"VEGETAL","UNDEAD","UNDEAD_BEAST","DEATHFOG_IMMUNE","DRAGON","VOIDWOKEN","DEMON","CONSTRUCT"}

local null = nil
local _Result = "_Result"
local Result = nil
local _RemoveList = "_Result"
local RemoveList = {}
local CharacterStatus = nil

local function IsTagged(char,Tag)
  return false
end
local function CharacterHasTalent(char,tal)
  return false
end
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end
local function Set(result,status)
  if result==_Result then
    Result = status
  end
end
local function ListClear(list)
  if list==_RemoveList then
    RemoveList = {}
  end
end
local function ListAdd(list,add)
  if list==_RemoveList then
    if not table_contains_value(RemoveList,add) then
      table.insert(RemoveList,add)
    end
  end
end
local function CharacterHasStatus(char,status)
  return CharacterStatus==status
end

local finalresult = {}
local function StatusAdded(char,status)
  finalresult[status] = {}
  for _,charstatus in pairs(Stati) do
    CharacterStatus = charstatus
    if status==WARM then
      Set(_Result,WARM)
      ListClear(_RemoveList)
      ListAdd(_RemoveList,WET)
      if CharacterHasStatus(_Character, WARM) then
        ListAdd(_RemoveList,WARM)
        Set(_Result,BURNING)    
      elseif CharacterHasStatus(_Character, BURNING) or
        CharacterHasStatus(_Character, NECROFIRE) or
        CharacterHasStatus(_Character, HOLY_FIRE) then
        Set(_Result,null) 
      elseif CharacterHasStatus(_Character, CHILLED) then
        ListAdd(_RemoveList,CHILLED)
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, FROZEN) then
        ListAdd(_RemoveList,FROZEN)   
        Set(_Result,CHILLED)    
      end
  

      Set(_Result,BURNING)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, WARM) and not CharacterHasStatus(_Character, WET) then
        ListAdd(_RemoveList, WARM)
      elseif CharacterHasStatus(_Character, WET) and not CharacterHasStatus(_Character, WARM) then
        ListAdd(_RemoveList, WET)
        Set(_Result, WARM)
      elseif CharacterHasStatus(_Character, WET) and CharacterHasStatus(_Character, WARM) then
        ListAdd(_RemoveList, WET)
      elseif CharacterHasStatus(_Character, CHILLED) then
        ListAdd(_RemoveList, CHILLED)
        Set(_Result, WARM)
      elseif CharacterHasStatus(_Character, FROZEN) then
        ListAdd(_RemoveList, FROZEN)
        Set(_Result, WET)
      elseif CharacterHasStatus(_Character, NECROFIRE) or CharacterHasStatus(_Character, HOLY_FIRE) then
        Set(_Result,null)
      end
      ListAdd(_RemoveList, WEB)
      

    elseif status==NECROFIRE then
      Set(_Result,NECROFIRE)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, PETRIFIED) then
        Set(_Result,null)
      else
        ListAdd(_RemoveList, WARM)
        ListAdd(_RemoveList, BURNING)
        ListAdd(_RemoveList, CHILLED)
        ListAdd(_RemoveList, WET)
        ListAdd(_RemoveList, FROZEN)
        if  CharacterHasStatus(_Character, HOLY_FIRE) then
          ListAdd(_RemoveList, HOLY_FIRE)   
          Set(_Result, BURNING)
        elseif  CharacterHasStatus(_Character, BLESSED) then
          ListAdd(_RemoveList, BLESSED)   
          Set(_Result, BURNING)   
        end
      end
      if CharacterHasStatus(_Character,QUEST_OVERGROWN) then
        ListAdd(_RemoveList, QUEST_OVERGROWN)
        Set(_Result,null) 
      end
      ListAdd(_RemoveList, WEB)
      

    elseif status==HOLY_FIRE then
      Set(_Result,HOLY_FIRE)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, PETRIFIED) then
        Set(_Result,null)
      else
        ListAdd(_RemoveList, WARM)
        ListAdd(_RemoveList, BURNING)
        ListAdd(_RemoveList, CHILLED)
        ListAdd(_RemoveList, WET)
        ListAdd(_RemoveList, FROZEN)
        if  CharacterHasStatus(_Character, NECROFIRE) then
          ListAdd(_RemoveList, NECROFIRE) 
          Set(_Result, BURNING)
        end
      end
      ListAdd(_RemoveList, WEB)
      

    elseif status==WET then
      Set(_Result,WET)
      Set(_Turns,null)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, WARM)
      ListAdd(_RemoveList, INVISIBLE)
      if IsTagged(_Character, "VEGETAL") and CharacterHasStatus(_Character, QUEST_SUNSHINE) then
        Set(_Result,QUEST_OVERGROWN)
        ListAdd(_RemoveList, QUEST_SUNSHINE)
      elseif CharacterHasStatus(_Character, BURNING) then
        ListAdd(_RemoveList, BURNING)
        Set(_Result, WARM)
      elseif CharacterHasStatus(_Character, HOLY_FIRE) then
        ListAdd(_RemoveList, HOLY_FIRE)
        Set(_Result, WARM)
      elseif CharacterHasStatus(_Character, CHILLED) then
        ListAdd(_RemoveList, CHILLED)
        Set(_Result,FROZEN)
        Set(_Turns,1)
      elseif CharacterHasStatus(_Character, FROZEN) or CharacterHasStatus(_Character, NECROFIRE) or CharacterHasStatus(_Character, HOLY_FIRE) then
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, SHOCKED) then
        ListAdd(_RemoveList, SHOCKED)
        Set(_Result,STUNNED)
        Set(_Turns,1)
      end
      

    elseif status==CHILLED then
      Set(_Result,CHILLED)
      Set(_Turns,null)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, BURNING) then
        ListAdd(_RemoveList, BURNING)
        Set(_Result, WARM)
      elseif CharacterHasStatus(_Character, HOLY_FIRE) then
        ListAdd(_RemoveList, HOLY_FIRE)
        Set(_Result, WARM)
      elseif CharacterHasStatus(_Character, WARM) then
        ListAdd(_RemoveList, WARM)    
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, CHILLED) or CharacterHasStatus(_Character, WET) then
        ListAdd(_RemoveList, CHILLED)
        ListAdd(_RemoveList, WET)
        Set(_Result, FROZEN)
        Set(_Turns,1)
      elseif CharacterHasStatus(_Character, FROZEN) or CharacterHasStatus(_Character, NECROFIRE) or CharacterHasStatus(_Character, HOLY_FIRE) then    
        Set(_Result,null)
      end
      

    elseif status==FROZEN then
      Set(_Result,FROZEN)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, CHILLED)
      ListAdd(_RemoveList, WET)
      ListAdd(_RemoveList, INVISIBLE)
      ListAdd(_RemoveList, SLEEPING)
      if CharacterHasStatus(_Character, MAGIC_SHELL) then
        ListClear(_RemoveList)
        ListAdd(_RemoveList, MAGIC_SHELL) 
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, BURNING) then
        ListAdd(_RemoveList, BURNING)
        Set(_Result, WET)
      elseif CharacterHasStatus(_Character, HOLY_FIRE) then
        ListAdd(_RemoveList, HOLY_FIRE)
        Set(_Result, WET)
      elseif CharacterHasStatus(_Character, NECROFIRE) or CharacterHasStatus(_Character, HOLY_FIRE) then
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, WARM) then
        ListAdd(_RemoveList, WARM)
        Set(_Result, CHILLED)
      end
      

    elseif status==PETRIFIED then
      Set(_Result,PETRIFIED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, MAGIC_SHELL) then
        ListClear(_RemoveList)
        ListAdd(_RemoveList, MAGIC_SHELL) 
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, BLESSED) then
        ListClear(_RemoveList)
        ListAdd(_RemoveList, BLESSED)   
        Set(_Result,null)
      end
      if Result==PETRIFIED then
        ListAdd(_RemoveList, STUNNED) 
        ListAdd(_RemoveList, SHOCKED)
        ListAdd(_RemoveList, BLEEDING)
        ListAdd(_RemoveList, CRIPPLED)
        ListAdd(_RemoveList, BURNING)
        ListAdd(_RemoveList, POISONED)
        ListAdd(_RemoveList, INVISIBLE)
        ListAdd(_RemoveList, SLEEPING)
      end   
      

    elseif status==SHOCKED then
      Set(_Result,SHOCKED)
      Set(_Turns,null)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, MAGIC_SHELL) then
        ListAdd(_RemoveList, MAGIC_SHELL) 
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, STUNNED) then
        ListAdd(_RemoveList, SHOCKED) 
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, SHOCKED) or CharacterHasStatus(_Character, WET) then
        ListAdd(_RemoveList, SHOCKED) 
        Set(_Result,STUNNED)
        Set(_Turns,1)
      end
      ListAdd(_RemoveList, INVISIBLE)
      ListAdd(_RemoveList, SLEEPING)
      

    elseif status==STUNNED then
      Set(_Result,STUNNED)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, SHOCKED)
      ListAdd(_RemoveList, PETRIFIED)
      ListAdd(_RemoveList, WET) 
      ListAdd(_RemoveList, INVISIBLE)
      ListAdd(_RemoveList, SLEEPING)
      if CharacterHasStatus(_Character, MAGIC_SHELL) then
        ListClear(_RemoveList)
        ListAdd(_RemoveList, MAGIC_SHELL) 
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, BLESSED) then
        ListClear(_RemoveList)
        ListAdd(_RemoveList, BLESSED) 
        Set(_Result,null)
      end
      

    elseif status==DRUNK then 
      Set(_Result,DRUNK)
      Set(_Turns,null)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, CLEAR_MINDED) then
        ListAdd(_RemoveList, CLEAR_MINDED)
        Set(_Result, null)  
      elseif CharacterHasStatus(_Character, DRUNK) then
        ListAdd(_RemoveList, DRUNK)
        Set(_Result, SLEEPING)    
        Set(_Turns,2)
      end
      

    elseif status==SLOWED then  
      Set(_Result,SLOWED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, HASTED) then
        ListAdd(_RemoveList, HASTED)
        Set(_Result,null)
      end
      

    elseif status==HASTED then  
      Set(_Result,HASTED)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, SLOWED)
      ListAdd(_RemoveList, CRIPPLED)
      

    elseif status==FEAR then  
      Set(_Result,FEAR)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, CLEAR_MINDED) or CharacterHasStatus(_Character, ENRAGED) then
        ListAdd(_RemoveList, CLEAR_MINDED)
        ListAdd(_RemoveList, ENRAGED)
        Set(_Result,null)
      else
        ListAdd(_RemoveList, CHARMED)
        ListAdd(_RemoveList, TAUNTED)
        ListAdd(_RemoveList, SLEEPING)  
        ListAdd(_RemoveList, MADNESS) 
      end
      

    elseif status==CHARMED then 
      Set(_Result,CHARMED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, CLEAR_MINDED) or CharacterHasStatus(_Character, ENRAGED) then
        ListAdd(_RemoveList, CLEAR_MINDED)
        ListAdd(_RemoveList, ENRAGED)   
        Set(_Result,null)
      else
        ListAdd(_RemoveList, FEAR)
        ListAdd(_RemoveList, TAUNTED)
        ListAdd(_RemoveList, SLEEPING)
        ListAdd(_RemoveList, MADNESS)   
      end
      

    elseif status==TAUNTED then 
      Set(_Result,TAUNTED)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, INVISIBLE)
      if CharacterHasStatus(_Character, CLEAR_MINDED) or CharacterHasStatus(_Character, ENRAGED) then
        ListAdd(_RemoveList, CLEAR_MINDED)
        ListAdd(_RemoveList, ENRAGED)   
        Set(_Result,null)
      else
        ListAdd(_RemoveList, CHARMED)
        ListAdd(_RemoveList, FEAR)
        ListAdd(_RemoveList, SLEEPING)    
        ListAdd(_RemoveList, MADNESS) 
      end
      

    elseif status==SLEEPING then  
      Set(_Result,SLEEPING)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, INVISIBLE)
      if CharacterHasStatus(_Character, CLEAR_MINDED) or CharacterHasStatus(_Character, ENRAGED) then
        ListAdd(_RemoveList, CLEAR_MINDED)
        ListAdd(_RemoveList, ENRAGED) 
        Set(_Result,null)
      else
        ListAdd(_RemoveList, CHARMED)
        ListAdd(_RemoveList, TAUNTED)
        ListAdd(_RemoveList, FEAR)    
        ListAdd(_RemoveList, MADNESS) 
      end
      

    elseif status==MADNESS then 
      Set(_Result,MADNESS)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, CLEAR_MINDED) then
        ListAdd(_RemoveList, CLEAR_MINDED)
        Set(_Result,null)
      end
      

    elseif status==CLEAR_MINDED then  
      Set(_Result,CLEAR_MINDED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, POSSESSED) then
        Set(_Result,null)
      else
        ListAdd(_RemoveList, FEAR)
        ListAdd(_RemoveList, CHARMED)
        ListAdd(_RemoveList, TAUNTED)
        ListAdd(_RemoveList, SLEEPING)
        ListAdd(_RemoveList, ENRAGED)
        ListAdd(_RemoveList, BLIND)
        ListAdd(_RemoveList, DRUNK)
        ListAdd(_RemoveList, MADNESS)
      end
      

    elseif status==ENRAGED then 
      Set(_Result,ENRAGED)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, FEAR)
      ListAdd(_RemoveList, CHARMED)
      ListAdd(_RemoveList, TAUNTED)
      ListAdd(_RemoveList, SLEEPING)
      ListAdd(_RemoveList, MADNESS) 
      ListAdd(_RemoveList, CLEAR_MINDED)
      

    elseif status==RESTED then  
      Set(_Result,RESTED)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, MUTED)
      ListAdd(_RemoveList, BLIND)
      ListAdd(_RemoveList, CRIPPLED)
      ListAdd(_RemoveList, KNOCKED_DOWN)
      ListAdd(_RemoveList, BLEEDING)
      ListAdd(_RemoveList, PLAGUE)
      ListAdd(_RemoveList, INFESTED)  
      

    elseif status==MUTED then 
      Set(_Result,MUTED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, RESTED) then
        ListAdd(_RemoveList, RESTED)
        Set(_Result,null)
      end
      

    elseif status==BLIND then 
      Set(_Result,BLIND)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, RESTED) then
        ListAdd(_RemoveList, RESTED)
        Set(_Result,null)
      end
      

    elseif status==CRIPPLED then  
      Set(_Result,CRIPPLED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, RESTED) then
        ListAdd(_RemoveList, RESTED)
        Set(_Result,null)
      end
      if CharacterHasStatus(_Character, HASTED) then
        ListAdd(_RemoveList, HASTED)
        Set(_Result,null)
      end
      

    elseif status==KNOCKED_DOWN then  
      Set(_Result,KNOCKED_DOWN)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, INVISIBLE)
      ListAdd(_RemoveList, SLEEPING)
      if CharacterHasStatus(_Character, RESTED) then
        ListAdd(_RemoveList, RESTED)
        Set(_Result,null)
      end
      

    elseif status==REGENERATION then  
      Set(_Result,REGENERATION)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, ACID)
      ListAdd(_RemoveList, POISONED)
      ListAdd(_RemoveList, BLEEDING)
      ListAdd(_RemoveList, SUFFOCATING)
      ListAdd(_RemoveList, BURNING)
      ListAdd(_RemoveList, INFESTED)
      

    elseif status==FORTIFIED then 
      Set(_Result,FORTIFIED)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, ACID)
      ListAdd(_RemoveList, POISONED)
      ListAdd(_RemoveList, BURNING)
      ListAdd(_RemoveList, BLEEDING)
      ListAdd(_RemoveList, DISEASED)
      ListAdd(_RemoveList, INFECTIOUS_DISEASED) 
      ListAdd(_RemoveList, DECAYING_TOUCH)  
      

    elseif status==ACID then  
      Set(_Result,ACID)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, FORTIFIED) then
        ListAdd(_RemoveList, FORTIFIED)
        Set(_Result,null)
      end
      

    elseif status==POISONED then  
      Set(_Result,POISONED)
      ListClear(_RemoveList)
      
    elseif status==BLEEDING then  
      Set(_Result,BLEEDING)
      ListClear(_RemoveList)
      if IsTagged(_Character, "UNDEAD") and CharacterIsPlayer(_Character) then
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, REGENERATION) then
        ListAdd(_RemoveList, REGENERATION)
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, FORTIFIED) then
        ListAdd(_RemoveList, FORTIFIED)
        Set(_Result,null)
      end

    elseif status==BLESSED then
      Set(_Result,BLESSED)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, DISEASED)
      ListAdd(_RemoveList, INFECTIOUS_DISEASED) 
      ListAdd(_RemoveList, DECAYING_TOUCH)  
      ListAdd(_RemoveList, PETRIFIED) 
      ListAdd(_RemoveList, STUNNED) 
      ListAdd(_RemoveList, FROZEN)  
      ListAdd(_RemoveList, INFESTED)  
      ListAdd(_RemoveList, PLAGUE)  
      if CharacterHasStatus(_Character, FROZEN) then
        ListAdd(_RemoveList, FROZEN)
        Set(_Result, CHILLED)
      end   
      if CharacterHasStatus(_Character, BURNING) then
        ListAdd(_RemoveList, BURNING)
        Set(_Result, HOLY_FIRE)
      end   
      if CharacterHasStatus(_Character, NECROFIRE) then
        ListAdd(_RemoveList, NECROFIRE)
        Set(_Result, BURNING)
      end 
      if CharacterHasStatus(_Character, CURSED) then
        ListAdd(_RemoveList, CURSED)
        Set(_Result,null)
      end 
      if CharacterHasStatus(_Character, PERMANENTLY_CURSED) then
        Set(_Result,null)
      end 
      if CharacterHasStatus(_Character, VOIDHOWL) then
        ListAdd(_RemoveList, VOIDHOWL)
        Set(_Result,null)
      end   
      

    elseif status==VOIDHOWL then
      Set(_Result,VOIDHOWL)
      

    elseif status==WARM then
      Set(_Result,MAGIC_SHELL)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, FROZEN)  
      ListAdd(_RemoveList, STUNNED)   
      ListAdd(_RemoveList, PETRIFIED)
      ListAdd(_RemoveList, PLAGUE)
      ListAdd(_RemoveList, SUFFOCATING)
      ListAdd(_RemoveList, POISONED)
      ListAdd(_RemoveList, BURNING)
      

    elseif status==CURSED then  
      Set(_Result,CURSED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, BLESSED) then
        ListAdd(_RemoveList, BLESSED)
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, CHILLED) then
        ListAdd(_RemoveList, CHILLED)
        Set(_Result, FROZEN)
      elseif CharacterHasStatus(_Character, QUEST_OVERGROWN) then
        ListAdd(_RemoveList, QUEST_OVERGROWN)
        Set(_Result,null) 
      end 
      if CharacterHasStatus(_Character, BURNING) then
        ListAdd(_RemoveList, BURNING)
        Set(_Result, NECROFIRE)
      end       
      if CharacterHasStatus(_Character, WARM) or CharacterHasStatus(_Character, HOLY_FIRE) then
        ListAdd(_RemoveList, WARM)
        ListAdd(_RemoveList, HOLY_FIRE)
        Set(_Result, BURNING)
      end   
      

    elseif status==DISEASED then  
      Set(_Result,DISEASED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, FORTIFIED) then
        ListAdd(_RemoveList, FORTIFIED)   
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, BLESSED) then
        ListAdd(_RemoveList, BLESSED)   
        Set(_Result,null)
      end 
      

    elseif status==INFECTIOUS_DISEASED then 
      Set(_Result,INFECTIOUS_DISEASED)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, FORTIFIED) then
        ListAdd(_RemoveList, FORTIFIED) 
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, BLESSED) then
        ListAdd(_RemoveList, BLESSED) 
        Set(_Result,null)
      end 
      

    elseif status==DECAYING_TOUCH then  
      Set(_Result,DECAYING_TOUCH)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, FORTIFIED) then
        ListAdd(_RemoveList, FORTIFIED) 
        Set(_Result,null)
      elseif CharacterHasStatus(_Character, BLESSED) then
        ListAdd(_RemoveList, BLESSED) 
        Set(_Result,null)
      end   
      

    elseif status==INVISIBLE then 
      Set(_Result,INVISIBLE)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, MARKED) then
        ListAdd(_RemoveList, INVISIBLE) 
        Set(_Result,null)
      else
        ListAdd(_RemoveList, WET)
      end   
      

    elseif status==DEATH_FOG then 
      Set(_Result,DEATH_FOG)
      ListClear(_RemoveList)
      if CharacterHasTalent(_Character, Zombie)   or
        IsTagged(_Character, "UNDEAD")            or
        IsTagged(_Character, "UNDEAD_BEAST")      or
        IsTagged(_Character, "DEATHFOG_IMMUNE")   or
        IsTagged(_Character, "DRAGON")            or
        IsTagged(_Character, "VOIDWOKEN")         or
        IsTagged(_Character, "DEMON")             or
        IsTagged(_Character, "CONSTRUCT") then
        Set(_Result,null)
      end   
      

    elseif status==CHICKEN then
      Set(_Result, CHICKEN)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, WINGS)
      if CharacterHasStatus(_Character, CHICKEN) then
        Set(_Result,null)
      end   
      

    elseif status==HEALING_ELIXIR then
      Set(_Result,HEALING_ELIXIR)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, WEAK)
      ListAdd(_RemoveList, SLOWED)
      ListAdd(_RemoveList, DISEASED)
      ListAdd(_RemoveList, POISONED)
      ListAdd(_RemoveList, BLEEDING)
      ListAdd(_RemoveList, CRIPPLED)
      ListAdd(_RemoveList, CURSED)
      ListAdd(_RemoveList, CHILLED)
      ListAdd(_RemoveList, DRUNK)
      ListAdd(_RemoveList, BURNING)
      ListAdd(_RemoveList, BLEEDING)
      ListAdd(_RemoveList, NECROFIRE)
      ListAdd(_RemoveList, ACID)
      ListAdd(_RemoveList, SUFFOCATING)
      ListAdd(_RemoveList, DECAYING_TOUCH)
      ListAdd(_RemoveList, INFECTIOUS_DISEASED)
      ListAdd(_RemoveList, PLAGUE)
      

    elseif status==CHAIN_HEAL then
      Set(_Result,CHAIN_HEAL)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, INFESTED)
      

    elseif status==CLEANSE_WOUNDS then
      Set(_Result,CLEANSE_WOUNDS)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, INFESTED)
      ListAdd(_RemoveList, PLAGUE)
      ListAdd(_RemoveList, DISEASED)
      ListAdd(_RemoveList, INFECTIOUS_DISEASED)
      

    elseif status==STEAM_LANCE then
      Set(_Result,STEAM_LANCE)
      ListClear(_RemoveList)
      ListAdd(_RemoveList, FROZEN)
      ListAdd(_RemoveList, CHILLED)
      ListAdd(_RemoveList, DISEASED)
      ListAdd(_RemoveList, INFECTIOUS_DISEASED)
      ListAdd(_RemoveList, DECAYING_TOUCH)
      ListAdd(_RemoveList, PLAGUE)
      ListAdd(_RemoveList, INFESTED)  
      if CharacterHasStatus(_Character, PLAGUE) then
        ListAdd(_RemoveList, PLAGUE)
        Set(_Result,null)
      end   


    elseif status==WEB then
      Set(_Result,WEB)
      ListClear(_RemoveList)
      if CharacterHasStatus(_Character, SPIDER_LEGS) and not CharacterHasStatus(_Character, HASTED) then
        Set(_Result,HASTED)   
      elseif CharacterHasStatus(_Character, SPIDER_LEGS) then
        Set(_Result, null) -- Don't reapply Haste to avoid spam
      elseif CharacterHasStatus(_Character, HASTED) and not CharacterHasStatus(_Character, SPIDER_LEGS) then
        ListAdd(_RemoveList, HASTED)
      end   
      

    elseif status==SPIDER_LEGS then
      Set(_Result,SPIDER_LEGS)
      ListAdd(_RemoveList, WEB)
    
    end
    
    if Result~=status or next(RemoveList) then
      finalresult[status][charstatus] = {Result=Result,RemoveList=RemoveList}
    end
    
  end
end
  
  -- TODO:
   -- sicherstellen, dass nur relevante infos drinstehe.
    -- aktuell wird zb. jeder charstatus bei HEALING_ELIXIR aufgelistet und bei jedem passiert dasselbe.
    -- dh es muss erkannt werden, wann etwas immer passiert, unabhängig vom status und wann etwas nur wegen einem status passiert.
    -- und dann eig auch noch eine kombination aus mehreren stati... 
  
  
for _,status in pairs(Stati) do
  StatusAdded(nil,status)
end
print(tabletostring(finalresult))

-- ###### RESULT:

