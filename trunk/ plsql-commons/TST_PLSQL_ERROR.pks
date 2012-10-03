CREATE OR REPLACE PACKAGE tst_plsql_error
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
 * Description : The test cases for plsql_error
 *               begin pTest.runTestSuite ( 'TST_PLSQL_ERROR'); end; 
 * Since       : 1.0
 *    
 */  
AS 
  procedure t_Catch; 
  procedure t_Throw;
  procedure t_MessageFormat;
end tst_plsql_error;
/
