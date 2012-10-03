CREATE OR REPLACE PACKAGE BODY plsql_util
/**
 * Copyright (c) 2008-2011, The PLSQL Commons team ( http://code.google.com/p/plsql-commons/)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Authors     : arnold@reuser.info and dimtri.lambrou@gmail.com
 *    
 */   
AS 

  function toBoolean(value in string) return boolean
  is
  begin
    if lower(value) in ('true','false','1','0') 
    then 
      return lower(value) in ('true' ,'1');
    else 
      return null;
    end if;
  end;
  
  function toChar(value in boolean) return string
  is
  begin
    return ite (value,'true','false');
  end;
  
  function toChar(value in date, format in string := null) return string
  is
  begin
    return to_char (value,nvl(format,plsql_type.DFORMAT));
  end;
  
  function toDate(value in string, format in string := null) return date
  is
  begin
    return to_date(value,nvl(format,plsql_type.DFORMAT));
  end;

  function eval (condition string) return boolean
  is
    bReturn plsql_type.string;
  begin
    execute immediate
        printf_ ('BEGIN
                    :1 := plsql_util.toChar(({1}));
                  END;', StringList (condition))
            using out bReturn;
    return toBoolean(bReturn);
  end eval;
      
  -- joins the elements of the provided array into a single string containing the provided list of elements.
  -- No delimiter is added before or after the list. Blank strings within the array are represented by empty strings.
  -- examples : 1. join(['a','b','c'],',') will resolve into a,b,c
  --            2. join(['a',' ','c'],',') will resolve into a,,c
  function join (args in StringList,sep in string := null,quietCut in boolean default false) return string
  is
     vTmpText   plsql_type.string := '';
     v_tmp_args   StringList := args;
     v_tmp_sep    plsql_type.string := sep;
     idx   pls_integer;
     first  boolean := true;
     maxSize constant pls_integer := 32000;
     function parts2string(parts StringList,quietCut boolean default false) return string
     is
          idx pls_integer := 1;
          val plsql_type.string;
          part plsql_type.string;
     begin
          if ( parts is not null ) 
          then                 
              idx := parts.first;
              while ( idx is not null ) 
              loop
                  part := parts(idx);
                  if ( quietCut and ( length(val) + length(part) > maxSize) )  
                  then 
                      exit;                        
                  else 
                      val := val || part;
                  end if;
                  idx := parts.next(idx);
              end loop;
          end if;     
          return val;       
     end;       
  begin
     if ( args is null )
     then
       v_tmp_args := new StringList();
     end if;
     if ( sep is null )
     then
       v_tmp_sep := ' ';
     end if;
    idx := v_tmp_args.first;
    while(idx is not null)
    loop
      --
      if ( isBlank(v_tmp_args(idx)) )
      then
         if( first )
         then
             vTmpText := parts2string(new StringList(vTmpText,''),quietCut);
         else
             vTmpText :=parts2string(new StringList(vTmpText,v_tmp_sep,''),quietCut);    
         end if;
      else
         if( first )
         then
           vTmpText :=parts2string(new StringList(vTmpText,v_tmp_args(idx)),quietCut);
         else
            vTmpText :=parts2string(new StringList(vTmpText,v_tmp_sep,v_tmp_args(idx)),quietCut);
         end if;
      end if;
      --
      idx := v_tmp_args.next(idx);
      first := false;
    end loop;
    return vTmpText;
  end;

  function split (value string, Sep string, preserveAllTokens boolean default false) return StringList
  is
      /**
          split( String => 'a#b#c#,Sep => '#') = [a,b,c] 
          split( String => 'a#b#c#,Sep => '#',PreserveAllTokens => true) = [a,b,c,]                   
      */
      words  StringList := new StringList();
      idx    pls_integer;
      list   plsql_type.string := value;
      val    plsql_type.string;
  begin
      loop
          idx := instr(list,Sep);
          if idx > 0 then
              words.extend;
              words(words.last) := substr(list,1,idx-1);
              list := substr(list,idx+length(Sep));
          else
              if ( length(list) > 0 or preserveAllTokens )
              then
                  words.extend;
                  words(words.last) := list;
                  exit;
              end if;
              exit;
          end if;
      end loop;
      return words;
  end split;    
   
  function split (value string, sepSize pls_integer) return StringList
  is
    vString       plsql_type.string := value;
    vTokens     StringList;
  begin
    vTokens := new StringList();
    while(length(vString) > 0 )
    loop
        vTokens.extend;
        vTokens(vTokens.last):= substr(vString,1,sepSize);
        vstring := substr(vString,sepSize+1);
    end loop;
    return vTokens;
  end;

  function minimal(args in NumberList) return number
  is
    v_min number;
    idx   pls_integer;
    vArgs NumberList;
  begin
     vArgs := nvl(args, new NumberList());
     idx := vArgs.first;
     while(idx is not null)
     loop
       if( vArgs(idx) is not null )
       then
           --
           -- set initial value
           if ( v_min is null )
           then
               v_min := vArgs(idx);
           end if;
           --
           -- find minimum
           if( v_min > vArgs(idx) )
           then
               v_min := vArgs(idx);
           end if;
       end if;
       --
       idx := vArgs.next(idx);
     end loop;
     return v_min;
  end;
  
  function maximal(args in NumberList)
  return number
  is
    vMax number;
    idx   pls_integer;
    vArgs  NumberList;
  begin
     vArgs := nvl(args,new NumberList());
     idx := vArgs.first;
     while(idx is not null)
     loop
       if( vArgs(idx) is not null )
       then
           --
           -- set initial value
           if ( vMax is null )
           then
               vMax := vArgs(idx);
           end if;
           --
           -- find minimum
           if( vMax < vArgs(idx) )
           then
               vMax := vArgs(idx);
           end if;
       end if;
       --
       idx := vArgs.next(idx);
     end loop;
     return vMax;
  end;

   -- checking if a search string in part of one of the list strings
   function contains (checked in StringList, checker in varchar2,regexpUsed in boolean default false,ignoreCase in boolean default false) return boolean
   is
     v_contains boolean := false;
     idx        pls_integer;
     args       StringList;
     val        plsql_type.string;
   begin
      --
      args := nvl(checked,new StringList());
      idx := args.first;
      while(idx is not null)
      loop
        --
        val := args(idx);
        if ( putil.isBlank(checker) and putil.isBlank(val) )
        then
            --
            -- determine equality of empty string
            v_contains := true;
            exit;
        elsif ( putil.isNotBlank(checker) )
        then
            --
            -- determine equality of non empty strings
            if ( regexpUsed and regexp_instr(val, checker, 1,1,0,'mn'||ite(ignoreCase,'i','c')) != 0 )
            then
                v_contains := true;
                exit;
            elsif (ignoreCase and lower(val) = lower(checker) )
            then
                v_contains := true;
                exit;
            elsif ( val = checker )
            then
                v_contains := true;
                exit;
            end if;
        end if;
        --
        idx := args.next(idx);
      end loop;
      return v_contains;
  end;
 
  function subset (args in StringList, offset number, limit number) return StringList  
  is
     idx  pls_integer;
     vArgs StringList := StringList();
  begin
     idx := args.first;
     while(idx is not null)
     loop
       --
       if ( idx between offset and limit )
       then 
         vArgs .extend;
         vArgs (vArgs.last) := args(idx);
       end if; 
       --
       idx := args.next(idx);
     end loop;
     return vArgs ;
  end;
   
  function subset (checked in StringList, checker in string, regexpUsed in boolean default true,ignoreCase in boolean default true) return StringList
  is
     idx        pls_integer;
     args       StringList;
     subSetArgs StringList := new StringList();
     val        plsql_type.string;
   begin
      --
      args := nvl (checked, new StringList());
      idx := args.first;
      if ( isBlank(checker) or idx is null )
      then
        return new StringList();
      end if;
      while (idx is not null)
      loop
        --
        val := args(idx);
        if isBlank(val)
        then
            --
            -- determine equality of empty string
            null;
        elsif ( isNotBlank(checker) )
        then
            --
            -- determine equality of non empty strings
            if ( regexpUsed and regexp_instr(val, checker, 1,1,0,'mn'||ite(ignoreCase,'i','c')) != 0 )
            then
                subSetArgs.extend;
                subSetArgs(subSetArgs.last) := val;
            elsif (instr (checker, '{1}') > 0
              and eval(printf_(checker,StringList(val))) )
            then
                subSetArgs.extend;
                subSetArgs(subSetArgs.last) := val;
            elsif (ignoreCase
              and instr (checker, '{1}') > 0
              and eval(printf_(lower(checker),StringList(lower(val)))) )
            then
                subSetArgs.extend;
                subSetArgs(subSetArgs.last) := val;
            elsif (ignoreCase and lower(val) = lower(checker) )
            then
                subSetArgs.extend;
                subSetArgs(subSetArgs.last) := val;
            elsif ( val = checker )
            then
                subSetArgs.extend;
                subSetArgs(subSetArgs.last) := val;
            end if;
        end if;
        --
        idx := args.next(idx);
      end loop;
      return subsetargs;
  end;

  function replacer (args in StringList, pattern in string, ignoreCase in boolean default true) return StringList
  is 
     vArgs StringList := args;
     idx integer;
    
  begin 
      idx := vArgs.first;
       while(idx is not null)
       loop
          vArgs(idx) := regexp_replace (vArgs(idx), pattern , '\1'); -- 1,1,0,'mn'||ite(ignoreCase,'i','c')                         
          idx := vArgs.next(idx);
       end loop;
      return vArgs;
  end;

  function equals(list1 StringList, list2 StringList) return boolean
  is
      idx  number;
      function lEquals (obj1 in string,obj2 in string) return boolean
      is
        v_return boolean := true;
      begin
        if ( obj1 is null and obj2 is null )
        then
           v_return := true;
        else
           v_return := nvl(( obj1 = obj2 ),false);
        end if;
        return v_return;
      end lEquals;
  begin
      if ( list1.count != list2.count )
      then
       return false;
      end if;
      idx := list1.first;
      while(idx is not null)
      loop
          if ( not lEquals(list1(idx),list2(idx) ) )
          then
              return false;
          end if;
          idx := list1.next(idx);
      end loop;
      return true;
  end;
      
  function isWhiteSpace(value in char)
  return boolean
  is
  begin
    --  TODO : still missing as whitespace characters
    --    unicode space separator
    --    unicode line separator
    --    unicode paragraph separator
    case value
        when chr(9)  then return true; -- horizontal tab
        when chr(10) then return true; -- new line
        when chr(11) then return true; -- vertical tab
        when chr(12) then return true; -- new page
        when chr(13) then return true; -- carriage return
        when chr(28) then return true; -- file separator
        when chr(29) then return true; -- group separator
        when chr(30) then return true; -- record separator
        when chr(31) then return true; -- unit separator
        when chr(32) then return true; -- space, should be replaced by unicode space separator
        else return false;
   end case;
  end;
  
  function deleteWhiteSpace(value in string)
  return string
  is
      v_clean plsql_type.string := '';
      idx pls_integer;
  begin
      if ( length(value) >= 1 )
      then
          for i in 1..length(value)
          loop
              if (not isWhiteSpace(substr(value,i,1)))
              then
                  v_clean := v_clean || substr(value,i,1);
              end if;
          end loop;
          return v_clean;
      else
          return value;
      end if;
  end;
      
  function isBlank(value in string) return boolean
  is
  begin
      return deleteWhiteSpace (value) is null;
  end;
    
  -- return true when value is not blank
  -- introduced to increase readability of plsql code
  function isNotBlank(value in string)
    return boolean
    is
  begin
     return not isBlank(value); 
  end;
  
  function ite (statement boolean, true in string, false in string default null)
    return string
  is
   v_return string(2000);
  begin
    if (statement)
    then
      v_return := true;
    else
      v_return := false;
    end if;
    return v_return;
  end;
  
  function ite (statement boolean, true in number, false in number default to_number(null))
    return number
  is
   v_return number;
  begin
    if (statement)
    then
      v_return := true;
    else
      v_return := false;
    end if;
    return v_return;
  end;
  
  function ite (statement boolean, true in date, false in date default to_date(null))
    return date
  is
   v_return date;
  begin
    if (statement)
    then
      v_return := true;
    else
      v_return := false;
    end if;
    return v_return;
  end;
 
 
  function printf (text in string, args in StringList, blankUnMatch in boolean := true )  
  return string
  is
    v_start_sep  char (1)        := '{';
    v_end_sep    char (1)        := '}';
    v_sep        plsql_type.string;
    v_output     plsql_type.string;
    idx             pls_integer;
    v_args       StringList;
    -- blanking of missing elements. 
    function extend(text in string, args in StringList := new StringList(),start_sep in char) return StringList
    is
        vTmpText   plsql_type.string := text;
        v_tmp_args   StringList := args;
        v_tmp_count  StringList ;
        v_tmp_nr     NumberList := new NumberList ();
        max_target   pls_integer;
    begin
      if ( args is null )
      then
       v_tmp_args := new StringList();
      end if;
      v_tmp_count := subset(split(regexp_replace (vTmpText, '{([[:digit:]])}','###\1###'),'###'),'^[[:digit:]]$');
      idx := v_tmp_count.first;
      while(idx is not null)
      loop
        v_tmp_nr.extend(); 
        v_tmp_nr(v_tmp_nr.count) := v_tmp_count(idx);
        idx := v_tmp_count.next(idx);
      end loop;
      max_target := maximal(v_tmp_nr);
      -- plsql_test.assert(max_target is null or max_target < 255, 'Too many elements in printf, max of 255 exceeded');
      while ( v_tmp_args.count < max_target )
      loop
        v_tmp_args.extend();
        v_tmp_args(v_tmp_args.last) := '';
      end loop;
      -- plsql_log.debug ('v_tmp_args.count='||v_tmp_args.count);
      return v_tmp_args;
    end;
   begin
        if blankUnMatch  
        then 
          v_args := extend(text,args,v_start_sep);
        else
          v_args := args; 
        end if;   
        v_output   := text;
        if ( v_args is not null and v_args.count > 0 )
        then
            idx := v_args.first;
            while(idx is not null)
            loop
                v_sep      := v_start_sep || idx || v_end_sep;
                v_output   := replace (v_output, v_sep, v_args (idx));
                idx := v_args.next(idx);
            end loop;
        end if;
      return nvl(v_output,''); 
   end printf;  

   function printf (text in string, args in string, blankUnMatch in boolean := true )
   return string
   is
   begin
     return printf (text,StringList(args), blankUnMatch);
   end;
      
   -- internal only, within plsql_pcks 
   function printf_ (text in string, args in StringList) return string
   is
     v_start_sep  char (1)        := '{';
     v_end_sep    char (1)        := '}';
     v_sep        varchar (10);
     v_output     string(32767);
     idx          pls_integer;
     v_args       StringList;
   begin
        v_args   := args; 
        v_output := text;
        if ( v_args is not null and v_args.count > 0 )
        then
            idx := v_args.first;
            while(idx is not null)
            loop
                v_sep      := v_start_sep || idx || v_end_sep;
                v_output   := replace (v_output, v_sep, v_args (idx));
                idx := v_args.next(idx);
            end loop;
        end if;
     return nvl(v_output,'');
  end;   

  function valueOf(data CLOB) return StringList
  is
    parts  StringList := new StringList();
    idx    pls_integer;
    len    pls_integer;
    pos    pls_integer := 1;
    amount binary_integer := 32767;
    buff   string(32767);
  begin
    len := dbms_lob.getlength(data);
    while pos < len
    loop
        dbms_lob.read(data, amount, pos, buff);
        if buff is not null then
            parts.extend;
            parts(parts.last):= buff;
        end if;
        pos := pos + amount;
    end loop;
    return parts;
  end;
  
  function valueOf(parts StringList) return CLOB
  is
    data   CLOB := EMPTY_CLOB;
    buff   string(32767);
    idx    pls_integer;
  begin
    dbms_lob.createTemporary(data,true);
    idx := parts.first;
    while(idx is not null)
    loop
        buff := parts(idx);
        dbms_lob.writeappend(data,length(buff), buff);
        idx := parts.next(idx);
    end loop;
    return data;
  end; 

  procedure extend (list in out nocopy NumberList, value number)
  is
  begin
        if ( list is not null )
        then
            list.extend;
            list(list.last):= value;
        end if;
  end;
 
  procedure extend (list in out NumberList, valueList in NumberList)
  is
  begin  
     list := list multiset union all valueList; 
  end;
      
  procedure extend (list in out StringList, value in string)
  is
  begin
    if ( list is not null )
    then  
        list.extend; 
        list(list.last):= value;
    end if; 
  end;  
   
  procedure extend(list in out StringList, valueList in StringList)
  is
  begin  
     list := list multiset union all valueList; 
  end;

  function sort(strings StringList) return StringList
  is
      type tmpTable_t is table of pls_integer index by plsql_type.string;
      tmpTable tmpTable_t;
      tmpTableIdx plsql_type.string;
      stringEl plsql_type.string;
      stringElIdx number;
      result StringList;
  begin
      result := new StringList();
      if ( strings is null ) then return result; end if;
      --
      stringElIdx := strings.first;
      while ( stringElIdx is not null ) 
      loop 
          stringEl := strings(stringElIdx);
          tmpTable(stringEl) := 0;
          stringElIdx := strings.next(stringElIdx);
      end loop;
      --
      tmpTableIdx :=  tmpTable.first;
      while ( tmpTableIdx is not null ) 
      loop
          extend(result,tmpTableIdx);
          tmpTableIdx :=  tmpTable.next(tmpTableIdx);
      end loop;
      return result;
  end;
  
end plsql_util;
/
