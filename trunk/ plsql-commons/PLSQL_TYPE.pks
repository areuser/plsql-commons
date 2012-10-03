CREATE OR REPLACE PACKAGE plsql_type 
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
 * Description : PLSQL_TYPE is a package to have generic convesion and global constants
 *    
 */ 
AS
 -- common type for varchar2 variables
  subtype string   is varchar2(32767);
  DFORMAT CONSTANT    varchar2(20)  := 'YYYYMMDD';
   
end plsql_type;
/
