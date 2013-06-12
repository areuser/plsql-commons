CREATE OR REPLACE PACKAGE plsql_gen
/**
 * Copyright 2008 the original author or authors.
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
 * Description : Template Engine are designed for separation of business logic from the presentation of data.
 *               When using code in generation this the important result is higher quality, standardization and a huge excelarion in development.
 *               PLSQL_GEN is a simple yet powerful template engine and a 100% pure PL/SQL.
 * Since       : 1.0
 *    
 */
as  

   function getLocation return string;
   
   procedure setLocation (loc string);

  /* read template from file */
  function getTemplate (fileName in string) return StringList;

  /* Maintain the mapping, mapping is always given back */
  function addContext (context in StringList, name in string, value in string) return StringList;
  function clearContext (context in StringList, name in string := null) return StringList;
  
  /* Render the template with the context into a new StringList */
  function  merge (context in StringList, template in StringList) return StringList;
  
  /* Render template on multiple levels generating output based on a query */
  function SqlTemplate (
    sqlStatement in string,
    columnTempl  in string := null,
    recordTempl  in string := '<ROW>{1}</ROW>',
    rootTempl    in string := '<ROOT>{1}</ROOT>'
  ) return string;
  
end;
/