CREATE OR REPLACE PACKAGE BODY tst_plsql_util
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

    procedure t_assert
    is        
        cause plsql_type.string := 'incorrect implementation of contract {1}';
    begin
       pTest.assert(true, pUtil.printf(cause, 1));
       pTest.assert(not false, pUtil.printf(cause, 2));
       pTest.assert(null is null,pUtil.printf(cause, 3));
       pTest.assert('' is null,pUtil.printf(cause, 4));
       pTest.assert(1  = '1', pUtil.printf(cause,5));
       pTest.assert('1' <> '2', pUtil.printf(cause,6));
    end;
    
    procedure t_StringLists
    is 
      vt1 StringList:= new StringList('A','B');
      vt2 StringList:= new StringList('A','B','');
      vt3 StringList:= new StringList('A','B','',null);
    begin
      pTest.assert(vt1.count = 2,'dat is niet genoeg');
      pTest.assert(vt2.count = 3,'dat is niet genoeg');
      pTest.assert(vt3.count = 4,'dat is niet genoeg');
    end;  

    procedure t_join
    is
        cause plsql_type.string := 'incorrect implementation of contract';
    begin    
        pTest.assert(pUtil.join(new StringList()) is null,cause);
        pTest.assert(pUtil.join(new StringList('a', 'b', 'c')) = 'a b c',cause);
        pTest.assert(pUtil.join(new StringList(null, '', 'a')) = '  a',cause); 
        pTest.assert(pUtil.join(new StringList('a', 'b', 'c'),'#') = 'a#b#c',cause);
        pTest.assert(pUtil.join(new StringList(null, '', 'a'),'#') = '##a',cause);
        pTest.assert(pUtil.join(new StringList('Hello'),',')                                   = 'Hello'                  ,'pUtil.join 1' );
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common'))                                = 'Hello PLSQL Common'             ,'pUtil.join 2' );
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common','Team'))                         = 'Hello PLSQL Common Team'        ,'pUtil.join 3' );
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common','Team'),',')                     = 'Hello,PLSQL Common,Team'        ,'pUtil.join 4' );
        pTest.assert(pUtil.join(new StringList('','PLSQL Common','Team'),',')                          = ',PLSQL Common,Team'             ,'pUtil.join 5' );
        pTest.assert(pUtil.join(new StringList('','','Team'),',')                              = ',,Team'                 ,'pUtil.join 6' );
        pTest.assert(pUtil.join(new StringList(to_char(null),'PLSQL Common','Team'),',')               = ',PLSQL Common,Team'             ,'pUtil.join 7' );
        pTest.assert(pUtil.join(new StringList(to_char(null),to_char(null),'Team'),',')        = ',,Team'                 ,'pUtil.join 8' );
        pTest.assert(pUtil.join(new StringList(to_char(null)),',')                               is null                  ,'pUtil.join 9' );
        pTest.assert(pUtil.join(new StringList(to_char(null),to_char(null)),',')               = ','                      ,'pUtil.join 10');
        pTest.assert(pUtil.join(new StringList(to_char(null),to_char(null),to_char(null)),',') = ',,'                     ,'pUtil.join 11');
        pTest.assert(pUtil.join(new StringList(to_char(null),to_char(null),to_char(null)))     = '  '                     ,'pUtil.join 12');
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common','Team'),'?')                     = 'Hello?PLSQL Common?Team'        ,'pUtil.join 13');
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common','Team'),'?')                     = 'Hello?PLSQL Common?Team'        ,'pUtil.join 14');
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common','Team'),'?')                     = 'Hello?PLSQL Common?Team'        ,'pUtil.join 15');
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common','Team'),'|')                     = 'Hello|PLSQL Common|Team'        ,'pUtil.join 16');
        pTest.assert(pUtil.join(new StringList('Hello','PLSQL Common','Team'),'||')                    = 'Hello||PLSQL Common||Team'      ,'pUtil.join 17');
        pTest.assert(pUtil.join(new StringList('Hello||','PLSQL Common||','Team||'),'')                = 'Hello|| PLSQL Common|| Team||'  ,'pUtil.join 18');
        pTest.assert(pUtil.join(new StringList('Hello||','PLSQL Common||','Team||'),'||')              = 'Hello||||PLSQL Common||||Team||','pUtil.join 19');
    end;
    
    procedure t_isBlank
    is
        cause plsql_type.string := 'incorrect implementation of contract';    
    begin
        pTest.assert(pUtil.isBlank(null),cause); 
        pTest.assert(pUtil.isBlank(''),cause);
        pTest.assert(not pUtil.isBlank('#'),cause);        
        pTest.assert(not pUtil.isNotBlank(null),cause); 
        pTest.assert(not pUtil.isNotBlank(''),cause);
    end;
    
    procedure t_isWhiteSpace
    is
        cause plsql_type.string := 'incorrect implementation of contract';    
    begin
        -- Determines if the specified character is white space
        -- A character is considered to be a Java whitespace character if and only if it satisfies one of the following criteria:
        --    * It is a Unicode space separator (category "Zs"), but is not a no-break space (\u00A0 or \uFEFF).
        --    * It is a Unicode line separator (category "Zl").
        --    * It is a Unicode paragraph separator (category "Zp").
        --    * It is \u0009, HORIZONTAL TABULATION.
        --    * It is \u000A, LINE FEED.
        --    * It is \u000B, VERTICAL TABULATION.
        --    * It is \u000C, FORM FEED.
        --    * It is \u000D, CARRIAGE RETURN.
        --    * It is \u001C, FILE SEPARATOR.
        --    * It is \u001D, GROUP SEPARATOR.
        --    * It is \u001E, RECORD SEPARATOR.
        --    * It is \u001F, UNIT SEPARATOR.     
        --
        -- Testcases will test contract :
        -- 
        --  function isWhiteSpace(char in char) return boolean;
        --  function deleteWhiteSpace(value in string) return string;        
        --          
        pTest.assert(pUtil.isWhiteSpace(' '),cause); -- a space is whitespace 
        pTest.assert(not pUtil.isWhiteSpace(null),cause); -- null is not whitespace 
        pTest.assert(not pUtil.isWhiteSpace(''),cause); -- empty string is not whitespace
        pTest.assert(pUtil.deleteWhiteSpace(null) is null ,cause); 
        pTest.assert(pUtil.deleteWhiteSpace('') is null,cause);
        pTest.assert(pUtil.deleteWhiteSpace(' ') is null,cause);
        pTest.assert(pUtil.deleteWhiteSpace('  # 
                                               # ') = '##',cause);                                                        

    end;
    
    procedure t_split
    is
        cause plsql_type.string := 'incorrect implementation of contract';    
        
    begin
        pTest.assert(pUtil.equals(pUtil.split(null,'#'),new StringList()),cause); -- null return empty list
        pTest.assert(pUtil.equals(pUtil.split(null,42),new StringList()),cause); -- null return empty list        
        pTest.assert(pUtil.equals(pUtil.split('','#'),new StringList()),cause); -- empty string return empty list
        pTest.assert(pUtil.equals(pUtil.split('',42),new StringList()),cause); -- empty string return empty list
        pTest.assert(pUtil.equals(pUtil.split('abc',2),new StringList('ab','c')),cause);
        pTest.assert(pUtil.equals(pUtil.split('a#b#c','#'),new StringList('a','b','c')),cause);
        pTest.assert(pUtil.equals(pUtil.split('#a#b#c','#'),new StringList('','a','b','c')),cause);
        pTest.assert(pUtil.equals(pUtil.split('a#b#c#','#'),new StringList('a','b','c')),cause);                                                       
    end;

   procedure t_ite
   is
        cause plsql_type.string := 'incorrect implementation of contract';  
        v_tst_ls  date; 
        v_tst_ls2 date; 
   begin
        -- If Then Else = ite, provided a easy way to implement if then else in 1 line.                  
        --  nulls are handled without exceptions, input value nulls is false.  
        pTest.assert(pUtil.ite(false,'then','else') = 'else',cause); 
        pTest.assert(pUtil.ite(true,'then','else') = 'then',cause); 
        pTest.assert(pUtil.ite(null,'then','else') = 'else',cause);
        pTest.assert(pUtil.ite(null != null,'waar','niet waar') = 'niet waar','dit mag echt niet waar zijn');
        pTest.assert(pUtil.ite(null > null,'waar','niet waar' ) = 'niet waar','dit mag echt niet waar zijn');
        pTest.assert(pUtil.ite('' is null,'waar','niet waar' )  = 'waar','dit mag echt niet onwaar zijn');
        pTest.assert(pUtil.ite('B' > 'A' ,'waar','niet waar' )  = 'waar','dit mag echt niet onwaar zijn');
        pTest.assert(pUtil.ite(pUtil.toDate('01011010','DDMMYYYY')= pUtil.toDate('01011010','DDMMYYYY'),pUtil.toDate('01011010','DDMMYYYY'),null) = pUtil.toDate('01011010','DDMMYYYY'),'pUtil.ite 1');
        pTest.assert(pUtil.ite(pUtil.toDate('01011010','DDMMYYYY')= pUtil.toDate('02011010','DDMMYYYY'),pUtil.toDate('01011010','DDMMYYYY'),null) is null ,'pUtil.ite 2');
        pTest.assert(pUtil.ite(pUtil.toDate('01011010','DDMMYYYY')= pUtil.toDate('02011010','DDMMYYYY'),pUtil.toDate('01011010','DDMMYYYY'),to_date(''))is null ,'pUtil.ite 2b');
        pTest.assert(pUtil.ite(pUtil.toDate(NULL)                 = null,null,0)                                = 0,'pUtil.ite 3');
        pTest.assert(pUtil.ite(pUtil.toDate(NULL)                 = to_date(null),null,0)                       = 0 ,'pUtil.ite 4');
        pTest.assert(pUtil.ite(pUtil.toDate(NULL)                 = to_date(null,'YYYYMMDD'),null,0)            = 0 ,'pUtil.ite 5');
        pTest.assert(pUtil.ite(pUtil.toDate(NULL)                 = pUtil.toDate(null,'YYYYMMDD'),null,0)       = 0     ,'pUtil.ite 5b');
        pTest.assert(pUtil.ite(pUtil.toDate(NULL)                 = pUtil.toDate(null),null,0)                  = 0     ,'pUtil.ite 5c');
        pTest.assert(pUtil.ite(pUtil.toDate('01011010')           < to_date('02011010','YYYYMMDD'),pUtil.toDate('02011010','YYYYMMDD'),pUtil.toDate('01011010'))          =   to_date('02011010','YYYYMMDD')    ,'pUtil.ite 6');
        pTest.assert(pUtil.ite(pUtil.toDate('01011010')           > to_date('02011010','YYYYMMDD'),pUtil.toDate('01011010','YYYYMMDD'),pUtil.toDate('02011010'))          =   to_date('02011010','YYYYMMDD')    ,'pUtil.ite 7');
        pTest.assert(pUtil.ite(pUtil.toDate('01011010')           > to_date('02011010','YYYYMMDD'),pUtil.toDate('01011010','YYYYMMDD'))                                   is null  ,'pUtil.ite 8');
        pTest.assert (pUtil.ite('b'='a', 12, 0)  = 0 ,'a:'||cause);
        pTest.assert (pUtil.ite('a'='a', 12, 0)  = 12,'b:'||cause);
        pTest.assert (pUtil.ite('a'=null, 12, 1.3) = 1.3,'c:'||cause);
        pTest.assert (pUtil.ite(null=null, 8, 0) = 0 ,'d:'||cause);
        pTest.assert (pUtil.ite(null='z', 8, 0)  = 0 ,'e:'||cause);
        pTest.assert (pUtil.ite('a'='A', 5, 0)   = 0 ,'f:'||cause);
        pTest.assert (pUtil.ite('ab'='ab', 5, 0) = 5 ,'g:'||cause);
        pTest.assert (pUtil.ite('ab'='ac', 5, 7) = 7 ,'h:'||cause);
        pTest.assert (pUtil.ite('ab'='a', 5, 0)  = 0 ,'i:'||cause);
   end;

   procedure t_printf
   is
     nr pls_integer:=0;
     
        function cause return string  
        is
          str plsql_type.string:= 'incorrect implementation of contract';
        begin
          nr:=nr+1;
          return str||' '||nr; 
        end;  
        
   begin
   
        -- printf: gives the possibility to build a string from parts, keeping the main definition string the same. 
        --   nulls are handled like empty strings. 
        pTest.assert(pUtil.printf ('Ik heb {1} appels en {2} eieren dan heb ik {1}+{2}={3} dingen',new StringList('2','4','6')) = 'Ik heb 2 appels en 4 eieren dan heb ik 2+4=6 dingen',cause);
        pTest.assert(pUtil.printf ('{1}{2}{1}',new StringList('1','2'))='121',cause); 
        pTest.assert(pUtil.printf ('{1}{2}{1}',new StringList(null,'2'))='2',cause);
        pTest.assert(pUtil.printf ('{2}',new StringList('1','2'))='2',cause);
        pTest.assert(pUtil.printf ('{2}', '1', false) = '{2}',cause);
        pTest.assert(pUtil.printf ('{2}','1', true) is null,cause);
        pTest.assert(pUtil.printf ('{2}','1') is null,cause);
        pTest.assert(pUtil.printf ('{1}','1') = '1',cause);
        pTest.assert((pUtil.printf ('{2}','1', false) is not null),cause);
        pTest.assert((pUtil.printf ('{1}',to_char(null)) is null),cause);
        pTest.assert(pUtil.printf ('{1}','1')           = '1'     ,'Printf 1');
        pTest.assert(pUtil.printf ('{1}',' ')           = ' '     ,'Printf 3');
        pTest.assert(pUtil.printf ('{1}','')            is null      ,'Printf 4');
        pTest.assert(pUtil.printf ('{1}','')            is null   ,'Printf 5');
        pTest.assert(pUtil.printf ('{1}',to_char(null)) is null   ,'Printf 6');
        pTest.assert(pUtil.printf ('{A}','1')           = '{A}'   ,'Printf 8');                                                       
        pTest.assert(pUtil.printf ('{2}{3}'            ,new StringList('1','2'), false)       = '2{3}','Printf 9');
        pTest.assert(pUtil.printf ('{2}{2}{3}{3}{4}{4}',new StringList('A','B'))       = 'BB'  ,'Printf 9b' );
        pTest.assert(pUtil.printf ('{2}{3}{4}'         ,new StringList('A','B'), false)       = 'B{3}{4}','Printf 9c'); 
        pTest.assert(pUtil.printf ('{2}{2}{3}{4}'      ,new StringList('A','B'))       = 'BB'  ,'Printf 9d');
        pTest.assert(pUtil.printf ('{2}{3}'            ,new StringList('1','2','3'))   = '23'   ,'Printf 10');
        pTest.assert(pUtil.printf ('{2}{3}'            ,new StringList('1','',''))     is null  ,'Printf 11');
   end;

   procedure t_contains
   is
        cause plsql_type.string := 'incorrect implementation of contract';
   begin
        -- contains: checks if given list contains the given value, nulls are handled like empty strings   
        pTest.assert(pUtil.contains (new StringList('1','2','3'),'2'),cause);
        pTest.assert(not pUtil.contains (new StringList('1','2'),'3'),cause);
        pTest.assert(not pUtil.contains (new StringList('123'),'3'),cause);
        pTest.assert(not pUtil.contains (new StringList('123'),to_char(null)),cause);  
        pTest.assert(pUtil.contains (new StringList(to_char(null),'2','3'),to_char(null)),cause);
        pTest.assert(pUtil.contains (new StringList('123','2334'),'^2\d{2}4$',true),cause);
        pTest.assert(pUtil.contains (new StringList('123','2334'),'^2[[:digit:]]{2}4$',true),cause);
        pTest.assert(pUtil.contains (new StringList('abc','aBCd'),'^[ |a]\w{2}[d|e]$',true),cause);
        pTest.assert(pUtil.contains (new StringList('abc','aBCd'),'^[ |a][[:alpha:]]{2}[d|e]$',true),cause);
        pTest.assert(pUtil.contains (new StringList('abc','Abcd'),'^a\w{2}D$',true,true),cause);
        pTest.assert(pUtil.contains (new StringList('abc','Abcbc
                                                          
                                                          bcD'),'^A.*?D$',true,false),cause);
        pTest.assert(pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'zafira ', false, false), cause||': 1'); 
        pTest.assert(not pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'zafira', false, false), cause||': 2'); 
        pTest.assert(not pUtil.contains (new StringList('corsa', 'astra', 'zafira', 'omega'),'zaFira', false, false), cause||': 3'); 
        pTest.assert(pUtil.contains (new StringList('corsa', 'astra', 'zafira', 'omega'),'zaFira', false, true), cause||': 4'); 
        pTest.assert(pUtil.contains (new StringList('corsa', 'astra', 'zaFiRa', 'omega'),'zafira', false, true), cause||': 5'); 
        pTest.assert(not pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'cors', false, false), cause||': 6'); 
        pTest.assert(not pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'', false, false), cause||': 7'); 
        pTest.assert(not pUtil.contains (new StringList('', 'astra', 'zafira ', 'omega'),'bla', false, false), cause||': 8'); 
        pTest.assert(pUtil.contains (new StringList('', 'astra', 'zafira ', 'omega'),'', false, false), cause||': 9'); 
        pTest.assert(pUtil.contains (new StringList(''),'', false, false), cause||': 10'); 
        pTest.assert(not pUtil.contains (new StringList(''),'ab', false, false), cause||': 11'); 
        pTest.assert(not pUtil.contains (new StringList(),'', false, false), cause||': 12'); 
        pTest.assert(not pUtil.contains (new StringList(),'ab', false, false), cause||': 13'); 
        pTest.assert(pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'^.*$', true, false), cause||': 1'); 
        pTest.assert(pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'^astra$', true, false), cause||': 1'); 
        pTest.assert(pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'[[:alpha:]]', true, false), cause||': 1'); 
        pTest.assert(not pUtil.contains (new StringList('corsa', 'astra', 'zafira ', 'omega'),'[[:digit:]]', true, false), cause||': 1'); 
   end;

   procedure t_minimal
   is
        cause plsql_type.string := 'incorrect implementation of contract';
   begin
        -- minimal: return the lowest value of a given list, nulls are ignored  
        pTest.assert(pUtil.minimal (new NumberList(1,2,0,0,null,3)) = 0, cause);
   end;
 
   procedure t_maximal
   is
        cause plsql_type.string := 'incorrect implementation of contract';
   begin
        -- maximal: return the highest value of a given list, nulls are ignored 
        pTest.assert(pUtil.maximal (new NumberList(1,2,0,0,null,3,2)) = 3, cause);
   end;
   
   procedure t_extend
   is
    cause plsql_type.string := 'incorrect implementation of contract';   
    list StringList;
   begin
   		-- procedure extend(value in out StringList,value in string)
   		list := new StringList('a','b');
   		pUtil.extend(list, 'c');
   		pTest.assert(pUtil.equals(list,new StringList('a','b','c')),cause);
   		list := new StringList('a','b',null);
   		pUtil.extend(list, 'c');
   		pTest.assert(pUtil.equals(list,new StringList('a','b',null,'c')),cause);    
   end;
   
   procedure t_toDate
   is 
    cause plsql_type.string := 'incorrect implementation of contract';    
   begin
     pTest.assert(pUtil.toDate(to_char(sysdate,'YYYYMMDD'),'YYYYMMDD')    = to_date(to_char(sysdate,'YYYYMMDD'),'YYYYMMDD')   , 'toDate 1' );  
     pTest.assert(pUtil.toDate(to_char(sysdate,'DDMMYYYY'),'DDMMYYYY')    = to_date(to_char(sysdate,'DDMMYYYY'),'DDMMYYYY')   , 'toDate 2' );  
     pTest.assert(to_char(pUtil.toDate('19000101','YYYYMMDD'),'YYYYMMDD') = '19000101'                    , 'toDate 3' );                                                                                                                                              
     pTest.assert(to_char(pUtil.toDate('01011900','DDMMYYYY'),'YYYYMMDD') = '19000101'                    , 'toDate 4' );                                                                                
     pTest.assert(to_char(pUtil.toDate('190001','YYYYMM'),'YYYYMM')       = '190001'                      , 'toDate 5' );                                      
     pTest.assert(pUtil.toDate(null,'YYYYMMDD')                           is null                         , 'toDate 6' );                                                                                                                                                                          
     pTest.assert(pUtil.toDate(null)                                      is null                         , 'toDate 7' );                                                                          
     pTest.assert(pUtil.toDate('','YYYYMMDD')                             is null                         , 'toDate 8' );                                                                                                                                   
     pTest.assert(pUtil.toDate('')                                        is null                         , 'toDate 9' );
     pTest.assert(pUtil.toDate('10000101','YYYYMMDD')                     = to_date('10000101','YYYYMMDD'), 'toDate 10');
     pTest.assert(pUtil.toDate('00010101','YYYYMMDD')                     = to_date('00010101','YYYYMMDD'), 'toDate 11');
     pTest.assert(to_char(pUtil.toDate(to_char(sysdate,'YYYYMMDD')),'YYYYMMDD') = to_CHAR(sysdate,'YYYYMMDD'),'toDate 12');
     pTest.assert(to_char(pUtil.toDate('19000101'),'YYYYMMDD') = '19000101','toDate 13');
     pTest.assert(to_char(pUtil.toDate('01011900','DDMMYYYY'),'YYYYMMDD') = '19000101','toDate 14');
     pTest.assert(to_char(pUtil.toDate('190001','YYYYMM'),'YYYYMM') = '190001','toDate 15');
   end;
  
 procedure t_toChar
  as
  begin  
    pTest.assert (pUtil.tochar(null is null) = 'true','dit moet waar zijn');
    pTest.assert (pUtil.tochar('B' = 'A')    = 'false','dit is nooit true');
  end;
  
 procedure t_toBoolean
 is
 begin
    pTest.assert (pUtil.toboolean('true'),'To boolean test 4');
    pTest.assert (pUtil.toboolean('TRUE'),'To boolean test 1');
    pTest.assert (pUtil.toboolean('trUe'),'To boolean test 1');
    pTest.assert (pUtil.toboolean('FALSE')=false,'To boolean test 3');
    pTest.assert (pUtil.toboolean('false')=false,'To boolean test 6');
    pTest.assert (pUtil.toboolean('fAlse')=false,'To boolean test 7');
    pTest.assert (pUtil.toboolean('') is null,'To boolean test 2a');
    pTest.assert (pUtil.toboolean('WAAR') is null,'To boolean test 8');
    pTest.assert (pUtil.toboolean('waar') is null,'To boolean test 9');
    pTest.assert (pUtil.toboolean('misschien') is null,'To boolean test 10');
    pTest.assert (pUtil.toboolean('a') is null,'To boolean test 11');
    pTest.assert (pUtil.toboolean(',') is null,'To boolean test 12');
    pTest.assert (pUtil.toboolean('true ') is null,'To boolean test 13');
    pTest.assert (pUtil.toboolean(' true') is null,'To boolean test 14');
    pTest.assert (pUtil.toboolean('true#') is null,'To boolean test 15');
    pTest.assert (pUtil.toboolean('true,') is null,'To boolean test 16');
    pTest.assert (pUtil.toboolean(1),'To boolean test 17');
    pTest.assert (pUtil.toboolean('1'),'To boolean test 18');
    pTest.assert (pUtil.toboolean(3-2),'To boolean test 19');    
    pTest.assert (pUtil.toboolean(0)=false,'To boolean test 20');
    pTest.assert (pUtil.toboolean('0')=false,'To boolean test 21');
    pTest.assert (pUtil.toboolean(3-3)=false,'To boolean test 22');
    pTest.assert (pUtil.toboolean(6) is null,'To boolean test 23');
    pTest.assert (pUtil.toboolean('6') is null,'To boolean test 24');
    pTest.assert (pUtil.toboolean(4+2) is null,'To boolean test 25');
 end;
  
 procedure t_subset is
   v_set  StringList := new StringList('A','1','B','2','C','3','D','4'); 
   v_set2 StringList := new StringList('abc', '123', 'def', '456'); 
   v_set3 StringList := new StringList('corsa', 'zafira', 'astra', 'omega'); 
 begin
   pTest.assert (pUtil.join(pUtil.subset(v_set, 3, 6), '|') = 'B|2|C|3', 'Subset test 1');
   pTest.assert (pUtil.join(pUtil.subset(v_set, 1, 1), '|') = 'A'      , 'Subset test 2');
   pTest.assert (pUtil.join(pUtil.subset(v_set, 1, 100), '|') = 'A|1|B|2|C|3|D|4', 'Subset test 3');
   pTest.assert (pUtil.join(pUtil.subset(v_set, 8, 1), '|') is null      , 'Subset test 4');
   pTest.assert (pUtil.join(pUtil.subset(v_set, 3, 2), '|') is null      , 'Subset test 5');
   pTest.assert (pUtil.join(pUtil.subset(v_set, 8, 8), '|') = '4'      , 'Subset test 6');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 3, 6), '|') = 'def|456', 'Subset test 7');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 1, 1), '|') = 'abc'      , 'Subset test 8');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 1, 100), '|') = 'abc|123|def|456', 'Subset test 9');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 8, 1), '|') is null      , 'Subset test 10');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 3, 2), '|') is null      , 'Subset test 11');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 4, 4), '|') = '456'      , 'Subset test 12');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 'a'), '|') = 'abc', 'Subset test 13');
   pTest.assert (pUtil.join(pUtil.subset(v_set2, 'a', false), '|') is null, 'Subset test 13');
   pTest.assert (pUtil.join(pUtil.subset(v_set3, 'o'), '|') = 'corsa|omega', 'Subset test 14');
   pTest.assert (pUtil.join(pUtil.subset(v_set3, 'O'), '|') = 'corsa|omega', 'Subset test 15');
   pTest.assert (pUtil.join(pUtil.subset(v_set3, 'O', true, false), '|') is null, 'Subset test 16');
 end;
 
 procedure t_eval is
 begin
   pTest.assert (pUtil.eval('1=1'), 'Eval test 1');
   pTest.assert (not pUtil.eval('1>1'), 'Eval test 2');
   pTest.assert (pUtil.eval('1>0'), 'Eval test 3');
   pTest.assert (pUtil.eval('''a''=''a'''), 'Eval test 4');
   pTest.assert (pUtil.eval('''a''<>''b'''), 'Eval test 5');
   pTest.assert (pUtil.eval('mod(12,2)=0'), 'Eval test 6');
   pTest.assert (pUtil.eval('mod(13,3)=1'), 'Eval test 7');
   pTest.assert (not pUtil.eval('mod(13,3)=0'), 'Eval test 8');
   pTest.assert (not pUtil.eval(' ''A'' in (''B'', ''C'') '), 'Eval test 11');
   pTest.assert (pUtil.eval(' ''A'' in (''B'', ''C'', ''A'') '), 'Eval test 12');
   pTest.assert (pUtil.eval(' '''' is null '), 'Eval test 13');
   pTest.assert (pUtil.eval(' '''''''' is not null '), 'Eval test 13a');
   pTest.assert (pUtil.eval(' null is null '), 'Eval test 13b');
   pTest.assert (pUtil.eval(' ''3'' is not null'), 'Eval test 14');
   pTest.assert (not pUtil.eval(' '''' is not null '), 'Eval test 15');
   pTest.assert (pUtil.eval('3/2=1.5'), 'Eval test 16');
   pTest.assert (pUtil.eval('5*4=20'), 'Eval test 17');
   pTest.assert (pUtil.eval('lpad(''12'', 4, ''0'') = ''0012'''), 'Eval test 19');
   pTest.assert (pUtil.eval('lpad(''12'', 4, 0) = ''0012'''), 'Eval test 20');
 end; 
 
end tst_plsql_util;
/
