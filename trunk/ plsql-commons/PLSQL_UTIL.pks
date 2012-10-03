CREATE OR REPLACE PACKAGE plsql_util
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
 * Description : PLSQL_UTIL is a package with some reusable functions and procedures.
 *    
 */ 
AS  

  /** This function is ideal for logging boolean values. 
    It exceptes strings of 0, 1, true or false and everything else will return null */
  function toBoolean(value in string) return boolean;
  function toChar(value in boolean) return string;
  function toChar(value in date, format in string := null) return string;
  function toDate(value in string, format in string := null) return date;

  /**
    Joins the elements of the provided array into a single string containing the provided list of elements.
    No delimiter is added before or after the list. Blank strings within the array are represented by empty strings.
    Default delimiter is the space character.
    examples: 1. join(['a','b','c'],',') will resolve into a,b,c
              2. join(['a',' ','c'],',') will resolve into a,,c
              3. join(['a',' ','c']) will resolve into a  c
   */
  function join (args in StringList, sep in string := null, quietCut in boolean default false) return string;   
  /** Split function to return an array from a string. The function performs a textual comparison of the delimiter, and returns all of the substrings 
        split( String => 'a#b#c#,Sep => '#') = [a,b,c] 
        split( String => 'a#b#c#,Sep => '#', preserveAllTokens => true) = [a,b,c,]                   
  */
  function split (value string, sep string, preserveAllTokens boolean default false) return StringList;
  /** Split function to return an array from a string. The function performs a length based cutting, and returns all of the substrings */
  function split (value string, sepSize pls_integer) return StringList;
  /**
      checks if given list contains the given value, nulls are handled like empty strings
      Examples:
       ptest.assert(putil.contains (new StringList('1','2','3'),'2'),'2 moet er in zitten');
       ptest.assert(putil.contains (new StringList('123','2334'),'^2\d{2}4$',true),'met regexp moet je 2__4 kunnen vinden');
      TODO: eval/validate implementeren.
    */
  function contains (checked in StringList, checker in varchar2,regexpUsed in boolean default false,ignoreCase in boolean default false) return boolean;
  
  /**
     Subset/filter return a part of a big array, only the set matched the critaria, criteria are add in regexp or as eval.
     Eval implementation takes each element value and puts it {1}.
     Example:
       putil.join(putil.subset(new StringList('1','2','3','4'), 'mod({1},2)=0'), '|') = '2|4'
    */
  function subset(checked in StringList, checker in string, regExpUsed in boolean default true, ignoreCase in boolean default true) return StringList;
   /**  subset return a part of a big array, only the set between offset number, limit. */
  function subset (args in StringList, offset number, limit number) return StringList;
   /** maximal: return the highest value of a given list, nulls are ignored  */  
  function maximal(args in NumberList) return number;
  function minimal(args in NumberList) return number;
  function replacer (args in StringList, pattern in string, ignoreCase in boolean default true) return StringList;
   /**  
    * Compare of to lists on values will return true or false. 
    * Values must be equal and on the same spot in the array  
   @param  list1 is the first array for type StringList 
   @param  list2 is the seconde array van het type StringList
   @return boolean the answer in true or false
  */
  function equals(list1 StringList, list2 StringList) return boolean;
    
  -- return true when string is whitespace, empty ( '' ) or null
  -- introduced to increase readability of plsql code
  function isBlank(value in string) return boolean;

  /** 
   Introduced to increase readability of plsql code, Blank equals 
   @return true when value is not blank
   */  
  function isNotBlank(value in string) return boolean;
  /** Checks is a char is horizontal tab, new line, vertical tab, new page, carriage return, file separator, group separator, record separator, unit separator or space
      in plsql this translates to chr(9),chr(10),chr(11),chr(12),chr(13),chr(28),chr(29),chr(30),chr(31),chr(32)
      TODO: rewrite using regexp
    */ 
  function isWhiteSpace(value in char) return boolean;
  /** removes horizontal tab, new line, vertical tab, new page, carriage return, file separator, group separator, record separator, unit separator, space, should be replaced by unicode space separator
      in plsql this translates to chr(9),chr(10),chr(11),chr(12),chr(13),chr(28),chr(29),chr(30),chr(31),chr(32)
    */ 
  function deleteWhiteSpace(value in string) return string;
  
  /** if then else */
  function ite (statement boolean, true in string, false in string default null) return string;
  /** if then else */
  function ite (statement boolean, true in number, false in number default to_number(null)) return number;
  /** if then else */
  function ite (statement boolean, true in date, false in date default to_date(null)) return date;  
  
  /** 
    Allows you to define a tokenized string and pass an arbitrary number of arguments to replace the tokens. Each token must be unique, and must increment in the printf {1}, {2}, etc
    @param blankUnMatch boolean to set if you like to blank all unmachted elements, if that's not desired than you can switch off this functionality.  
  */
  function printf (text in string, args in StringList, blankUnMatch in boolean := true ) return string;
  /** Equals printf with StringList only now it only accepts 1 arument, this is created for easy us */ 
  function printf (text in string, args in string, blankUnMatch in boolean := true ) return string;
  /**Internal use only*/
  function printf_ (text in string, args in StringList) return string;
  
  function eval (condition string) return boolean;
    
  function valueOf(data CLOB) return StringList;
  function valueOf(parts StringList) return CLOB;
  
  procedure extend(list in out StringList,value in string);
  procedure extend(list in out StringList,valueList in StringList);
  procedure extend(list in out nocopy NumberList, value number);
  procedure extend(list in out NumberList, valueList in NumberList); 
    
end plsql_util;
/
