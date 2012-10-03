CREATE OR REPLACE PACKAGE tst_plsql_util 
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
 * Description : The test cases for plsql_util
 *               begin pTest.runTestSuite ( 'TST_PLSQL_UTIL' ); end;
 * Since       : 1.0
 *    
 */  
AS 
  -- Test the tester! 
  procedure t_assert;
  
  -- Test the StringList, to show the behavoir of the StringList. 
  procedure t_StringLists;
    
  -- Test contract of :
  procedure t_join;
  procedure t_isBlank;
  --  function defaultIfBlank(pp_value in string,pp_default in string) return string;  
  --  function isNotBlank(pp_value in string) return boolean;
  procedure t_isWhiteSpace;   
  procedure t_split;    
  procedure t_ite;    
  procedure t_printf;     
  procedure t_maximal; 
  procedure t_extend;
  procedure t_toDate;
  procedure t_toChar;
  procedure t_toBoolean;
  procedure t_subset;
  procedure t_eval;
  
END tst_plsql_util;
/
