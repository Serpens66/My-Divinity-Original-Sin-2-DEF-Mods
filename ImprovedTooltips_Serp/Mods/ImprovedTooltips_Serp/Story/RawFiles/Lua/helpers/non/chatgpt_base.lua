-- (the result was ok, but for the more advanced conditions it was wrong and required multiple forward questions and manual adjustments to get the final result)


Analyse the following lua code. Especially check the function "On_New_Status" and check its result for all possible outcomes of the unknown function "CharacterHasStatus". 
Then create me a table in lua, that shows all possible outcomes if the new status "WARM" is applied. This lua table should be computer readable.

local Stati={"POSSESSED","HASTED","STUNNED","STEAM_LANCE","FEAR","SUFFOCATING","POISONED","HEALING_ELIXIR","RESTED","NECROFIRE","MAGIC_SHELL","INVISIBLE","BLIND","VOIDWOKEN","MARKED","CHAIN_HEAL","SPIDER_LEGS","PERMANENTLY_CURSED","CHARMED","CURSED","BLESSED","WET","PETRIFIED","SHOCKED","WEAK","CHILLED","CHICKEN","DISEASED","INFECTIOUS_DISEASED","KNOCKED_DOWN","DEATH_FOG","FORTIFIED","BURNING","CLEAR_MINDED","WINGS","MUTED","REGENERATION","CLEANSE_WOUNDS","CRIPPLED","PLAGUE","WEB","DECAYING_TOUCH","ACID","DRUNK","BLEEDING","FROZEN","ENRAGED","TAUNTED","MADNESS","SLOWED","HOLY_FIRE","VOIDHOWL","INFESTED","WARM","SLEEPING",}
local NULL="NULL";local WARM="WARM";local WET="WET";local BURNING="BURNING";local NECROFIRE="NECROFIRE";local HOLY_FIRE="HOLY_FIRE";local CHILLED="CHILLED";local FROZEN="FROZEN";local PETRIFIED="PETRIFIED";local WEB="WEB";local INVISIBLE="INVISIBLE";local SLEEPING="SLEEPING";local MAGIC_SHELL="MAGIC_SHELL";local SHOCKED="SHOCKED";local STUNNED="STUNNED";local DRUNK="DRUNK";local CLEAR_MINDED="CLEAR_MINDED";local SLOWED="SLOWED";local HASTED="HASTED";local FEAR="FEAR";local CHARMED="CHARMED";local TAUNTED="TAUNTED";local MADNESS="MADNESS";local ENRAGED="ENRAGED";local RESTED="RESTED";local MUTED="MUTED";local BLIND="BLIND";local CRIPPLED="CRIPPLED";local KNOCKED_DOWN="KNOCKED_DOWN";local BLEEDING="BLEEDING";local POISONED="POISONED";local ACID="ACID";local SUFFOCATING="SUFFOCATING";local REGENERATION="REGENERATION";local FORTIFIED="FORTIFIED";local DISEASED="DISEASED";local INFECTIOUS_DISEASED="INFECTIOUS_DISEASED";local DECAYING_TOUCH="DECAYING_TOUCH";local INFESTED="INFESTED";local PLAGUE="PLAGUE";local BLESSED="BLESSED";local CURSED="CURSED";local PERMANENTLY_CURSED="PERMANENTLY_CURSED";local VOIDHOWL="VOIDHOWL";local DEATH_FOG="DEATH_FOG";local CHICKEN="CHICKEN";local WINGS="WINGS";local HEALING_ELIXIR="HEALING_ELIXIR";local WEAK="WEAK";local CHAIN_HEAL="CHAIN_HEAL";local CLEANSE_WOUNDS="CLEANSE_WOUNDS";local STEAM_LANCE="STEAM_LANCE";local SPIDER_LEGS="SPIDER_LEGS";local MARKED="MARKED";local POSSESSED="POSSESSED";local VOIDWOKEN="VOIDWOKEN";

local Result = nil
local RemoveList = {}

local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k
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

local function On_New_Status(_Character,new_status)
  Result = nil
  RemoveList = {}
  if new_status==WARM then
    Set_Result(WARM)
    ListClear_RemoveList()
    ListAdd(RemoveList,WET)
    if CharacterHasStatus("or",_Character, WARM) then
      ListAdd(RemoveList,WARM)
      Set_Result(BURNING)    
    elseif CharacterHasStatus("or",_Character, BURNING) or CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then
      Set_Result(NULL) 
    elseif CharacterHasStatus("or",_Character, CHILLED) then
      ListAdd(RemoveList,CHILLED)
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, FROZEN) then
      ListAdd(RemoveList,FROZEN)   
      Set_Result(CHILLED)    
    end

  elseif new_status==BURNING then
    Set_Result(BURNING)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, WARM) and not CharacterHasStatus("and not",_Character, WET) then
      ListAdd(RemoveList,WARM)
    elseif CharacterHasStatus("or",_Character, WET) and not CharacterHasStatus("and not",_Character, WARM) then
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
      Set_Result(NULL)
    end
    ListAdd(RemoveList,WEB)
    
  elseif new_status==NECROFIRE then
    Set_Result(NECROFIRE)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, PETRIFIED) then
      Set_Result(NULL)
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
    
  elseif new_status==HOLY_FIRE then
    Set_Result(HOLY_FIRE)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, PETRIFIED) then
      Set_Result(NULL)
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
    
  elseif new_status==WET then
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
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, SHOCKED) then
      ListAdd(RemoveList,SHOCKED)
      Set_Result(STUNNED)
    end
    
  elseif new_status==CHILLED then
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
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, CHILLED) or CharacterHasStatus("or",_Character, WET) then
      ListAdd(RemoveList,CHILLED)
      ListAdd(RemoveList,WET)
      Set_Result( FROZEN)
    elseif CharacterHasStatus("or",_Character, FROZEN) or CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then    
      Set_Result(NULL)
    end
    
  elseif new_status==FROZEN then
    Set_Result(FROZEN)
    ListClear_RemoveList()
    ListAdd(RemoveList,CHILLED)
    ListAdd(RemoveList,WET)
    ListAdd(RemoveList,INVISIBLE)
    ListAdd(RemoveList,SLEEPING)
    if CharacterHasStatus("or",_Character, MAGIC_SHELL) then
      ListClear_RemoveList()
      ListAdd(RemoveList,MAGIC_SHELL) 
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, BURNING) then
      ListAdd(RemoveList,BURNING)
      Set_Result( WET)
    elseif CharacterHasStatus("or",_Character, HOLY_FIRE) then
      ListAdd(RemoveList,HOLY_FIRE)
      Set_Result( WET)
    elseif CharacterHasStatus("or",_Character, NECROFIRE) or CharacterHasStatus("or",_Character, HOLY_FIRE) then
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, WARM) then
      ListAdd(RemoveList,WARM)
      Set_Result( CHILLED)
    end
    
  elseif new_status==PETRIFIED then
    Set_Result(PETRIFIED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, MAGIC_SHELL) then
      ListClear_RemoveList()
      ListAdd(RemoveList,MAGIC_SHELL) 
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, BLESSED) then
      ListClear_RemoveList()
      ListAdd(RemoveList,BLESSED)   
      Set_Result(NULL)
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
    
  elseif new_status==SHOCKED then
    Set_Result(SHOCKED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, MAGIC_SHELL) then
      ListAdd(RemoveList,MAGIC_SHELL) 
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, STUNNED) then
      ListAdd(RemoveList,SHOCKED) 
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, SHOCKED) or CharacterHasStatus("or",_Character, WET) then
      ListAdd(RemoveList,SHOCKED) 
      Set_Result(STUNNED)
    end
    ListAdd(RemoveList,INVISIBLE)
    ListAdd(RemoveList,SLEEPING)
    
  elseif new_status==STUNNED then
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
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, BLESSED) then
      ListClear_RemoveList()
      ListAdd(RemoveList,BLESSED) 
      Set_Result(NULL)
    end
    
  elseif new_status==DRUNK then 
    Set_Result(DRUNK)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, CLEAR_MINDED) then
      ListAdd(RemoveList,CLEAR_MINDED)
      Set_Result( NULL)  
    elseif CharacterHasStatus("or",_Character, DRUNK) then
      ListAdd(RemoveList,DRUNK)
      Set_Result( SLEEPING)    
    end
    
  elseif new_status==SLOWED then  
    Set_Result(SLOWED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, HASTED) then
      ListAdd(RemoveList,HASTED)
      Set_Result(NULL)
    end
    
  elseif new_status==HASTED then  
    Set_Result(HASTED)
    ListClear_RemoveList()
    ListAdd(RemoveList,SLOWED)
    ListAdd(RemoveList,CRIPPLED)

  elseif new_status==FEAR then  
    Set_Result(FEAR)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
      ListAdd(RemoveList,CLEAR_MINDED)
      ListAdd(RemoveList,ENRAGED)
      Set_Result(NULL)
    else
      ListAdd(RemoveList,CHARMED)
      ListAdd(RemoveList,TAUNTED)
      ListAdd(RemoveList,SLEEPING)  
      ListAdd(RemoveList,MADNESS) 
    end
    
  elseif new_status==CHARMED then 
    Set_Result(CHARMED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
      ListAdd(RemoveList,CLEAR_MINDED)
      ListAdd(RemoveList,ENRAGED)   
      Set_Result(NULL)
    else
      ListAdd(RemoveList,FEAR)
      ListAdd(RemoveList,TAUNTED)
      ListAdd(RemoveList,SLEEPING)
      ListAdd(RemoveList,MADNESS)   
    end
    
  elseif new_status==TAUNTED then 
    Set_Result(TAUNTED)
    ListClear_RemoveList()
    ListAdd(RemoveList,INVISIBLE)
    if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
      ListAdd(RemoveList,CLEAR_MINDED)
      ListAdd(RemoveList,ENRAGED)   
      Set_Result(NULL)
    else
      ListAdd(RemoveList,CHARMED)
      ListAdd(RemoveList,FEAR)
      ListAdd(RemoveList,SLEEPING)    
      ListAdd(RemoveList,MADNESS) 
    end
    
  elseif new_status==SLEEPING then  
    Set_Result(SLEEPING)
    ListClear_RemoveList()
    ListAdd(RemoveList,INVISIBLE)
    if CharacterHasStatus("or",_Character, CLEAR_MINDED) or CharacterHasStatus("or",_Character, ENRAGED) then
      ListAdd(RemoveList,CLEAR_MINDED)
      ListAdd(RemoveList,ENRAGED) 
      Set_Result(NULL)
    else
      ListAdd(RemoveList,CHARMED)
      ListAdd(RemoveList,TAUNTED)
      ListAdd(RemoveList,FEAR)    
      ListAdd(RemoveList,MADNESS) 
    end
    
  elseif new_status==MADNESS then 
    Set_Result(MADNESS)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, CLEAR_MINDED) then
      ListAdd(RemoveList,CLEAR_MINDED)
      Set_Result(NULL)
    end
    
  elseif new_status==CLEAR_MINDED then  
    Set_Result(CLEAR_MINDED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, POSSESSED) then
      Set_Result(NULL)
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
    
  elseif new_status==ENRAGED then 
    Set_Result(ENRAGED)
    ListClear_RemoveList()
    ListAdd(RemoveList,FEAR)
    ListAdd(RemoveList,CHARMED)
    ListAdd(RemoveList,TAUNTED)
    ListAdd(RemoveList,SLEEPING)
    ListAdd(RemoveList,MADNESS) 
    ListAdd(RemoveList,CLEAR_MINDED)
    
  elseif new_status==RESTED then  
    Set_Result(RESTED)
    ListClear_RemoveList()
    ListAdd(RemoveList,MUTED)
    ListAdd(RemoveList,BLIND)
    ListAdd(RemoveList,CRIPPLED)
    ListAdd(RemoveList,KNOCKED_DOWN)
    ListAdd(RemoveList,BLEEDING)
    ListAdd(RemoveList,PLAGUE)
    ListAdd(RemoveList,INFESTED)  
    
  elseif new_status==MUTED then 
    Set_Result(MUTED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, RESTED) then
      ListAdd(RemoveList,RESTED)
      Set_Result(NULL)
    end
    
  elseif new_status==BLIND then 
    Set_Result(BLIND)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, RESTED) then
      ListAdd(RemoveList,RESTED)
      Set_Result(NULL)
    end
    
  elseif new_status==CRIPPLED then  
    Set_Result(CRIPPLED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, RESTED) then
      ListAdd(RemoveList,RESTED)
      Set_Result(NULL)
    end
    if CharacterHasStatus("or",_Character, HASTED) then
      ListAdd(RemoveList,HASTED)
      Set_Result(NULL)
    end
    
  elseif new_status==KNOCKED_DOWN then  
    Set_Result(KNOCKED_DOWN)
    ListClear_RemoveList()
    ListAdd(RemoveList,INVISIBLE)
    ListAdd(RemoveList,SLEEPING)
    if CharacterHasStatus("or",_Character, RESTED) then
      ListAdd(RemoveList,RESTED)
      Set_Result(NULL)
    end
    
  elseif new_status==REGENERATION then  
    Set_Result(REGENERATION)
    ListClear_RemoveList()
    ListAdd(RemoveList,ACID)
    ListAdd(RemoveList,POISONED)
    ListAdd(RemoveList,BLEEDING)
    ListAdd(RemoveList,SUFFOCATING)
    ListAdd(RemoveList,BURNING)
    ListAdd(RemoveList,INFESTED)
    
  elseif new_status==FORTIFIED then 
    Set_Result(FORTIFIED)
    ListClear_RemoveList()
    ListAdd(RemoveList,ACID)
    ListAdd(RemoveList,POISONED)
    ListAdd(RemoveList,BURNING)
    ListAdd(RemoveList,BLEEDING)
    ListAdd(RemoveList,DISEASED)
    ListAdd(RemoveList,INFECTIOUS_DISEASED) 
    ListAdd(RemoveList,DECAYING_TOUCH)  
    
  elseif new_status==ACID then  
    Set_Result(ACID)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, FORTIFIED) then
      ListAdd(RemoveList,FORTIFIED)
      Set_Result(NULL)
    end
    
  elseif new_status==BLEEDING then  
    Set_Result(BLEEDING)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, REGENERATION) then
      ListAdd(RemoveList,REGENERATION)
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, FORTIFIED) then
      ListAdd(RemoveList,FORTIFIED)
      Set_Result(NULL)
    end

  elseif new_status==BLESSED then
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
      Set_Result(NULL)
    end 
    if CharacterHasStatus("or",_Character, PERMANENTLY_CURSED) then
      Set_Result(NULL)
    end 
    if CharacterHasStatus("or",_Character, VOIDHOWL) then
      ListAdd(RemoveList,VOIDHOWL)
      Set_Result(NULL)
    end   
          
  elseif new_status==MAGIC_SHELL then
    Set_Result(MAGIC_SHELL)
    ListClear_RemoveList()
    ListAdd(RemoveList,FROZEN)  
    ListAdd(RemoveList,STUNNED)   
    ListAdd(RemoveList,PETRIFIED)
    ListAdd(RemoveList,PLAGUE)
    ListAdd(RemoveList,SUFFOCATING)
    ListAdd(RemoveList,POISONED)
    ListAdd(RemoveList,BURNING)
    
  elseif new_status==CURSED then  
    Set_Result(CURSED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, BLESSED) then
      ListAdd(RemoveList,BLESSED)
      Set_Result(NULL)
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
    
  elseif new_status==DISEASED then  
    Set_Result(DISEASED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, FORTIFIED) then
      ListAdd(RemoveList,FORTIFIED)   
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, BLESSED) then
      ListAdd(RemoveList,BLESSED)   
      Set_Result(NULL)
    end 
    
  elseif new_status==INFECTIOUS_DISEASED then 
    Set_Result(INFECTIOUS_DISEASED)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, FORTIFIED) then
      ListAdd(RemoveList,FORTIFIED) 
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, BLESSED) then
      ListAdd(RemoveList,BLESSED) 
      Set_Result(NULL)
    end 
    
  elseif new_status==DECAYING_TOUCH then  
    Set_Result(DECAYING_TOUCH)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, FORTIFIED) then
      ListAdd(RemoveList,FORTIFIED) 
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, BLESSED) then
      ListAdd(RemoveList,BLESSED) 
      Set_Result(NULL)
    end   
    
  elseif new_status==INVISIBLE then 
    Set_Result(INVISIBLE)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, MARKED) then
      ListAdd(RemoveList,INVISIBLE) 
      Set_Result(NULL)
    else
      ListAdd(RemoveList,WET)
    end   
    
  elseif new_status==CHICKEN then
    Set_Result( CHICKEN)
    ListClear_RemoveList()
    ListAdd(RemoveList,WINGS)
    if CharacterHasStatus("or",_Character, CHICKEN) then
      Set_Result(NULL)
    end   
    
  elseif new_status==HEALING_ELIXIR then
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
    

  elseif new_status==CHAIN_HEAL then
    Set_Result(CHAIN_HEAL)
    ListClear_RemoveList()
    ListAdd(RemoveList,INFESTED)
    

  elseif new_status==CLEANSE_WOUNDS then
    Set_Result(CLEANSE_WOUNDS)
    ListClear_RemoveList()
    ListAdd(RemoveList,INFESTED)
    ListAdd(RemoveList,PLAGUE)
    ListAdd(RemoveList,DISEASED)
    ListAdd(RemoveList,INFECTIOUS_DISEASED)
    

  elseif new_status==STEAM_LANCE then
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
      Set_Result(NULL)
    end   


  elseif new_status==WEB then
    Set_Result(WEB)
    ListClear_RemoveList()
    if CharacterHasStatus("or",_Character, SPIDER_LEGS) and not CharacterHasStatus("and not",_Character, HASTED) then
      Set_Result(HASTED)   
    elseif CharacterHasStatus("or",_Character, SPIDER_LEGS) then
      Set_Result(NULL)
    elseif CharacterHasStatus("or",_Character, HASTED) and not CharacterHasStatus("and not",_Character, SPIDER_LEGS) then
      ListAdd(RemoveList,HASTED)
    end   
    

  elseif new_status==SPIDER_LEGS then
    Set_Result(SPIDER_LEGS)
    ListAdd(RemoveList,WEB)
  
  end

end



