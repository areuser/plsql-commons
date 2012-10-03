CREATE OR REPLACE PACKAGE BODY ORCA_MT_DATA_OWNER.plsql_gen
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
 *               When using code in generation this the important result is higher quality, standardization and a huge acceleration in development. 
 *               PLSQL_GEN is a simple yet powerful template engine and a 100% pure PL/SQL.
 * Since       : 1.0 
 */ 
as 

  fileLoc type.string := 'TEMPLATE';
  extension type.string := '.tpl';

   function getLocation return string 
   is begin return fileLoc; end; 
   
   procedure setLocation (loc string) 
   is begin fileLoc := loc; end;   

  function getTemplate (fileName in string) return StringList
  is 
  begin
     return plsql_File.getLines (fileName||extension, fileLoc, plsql_File.WE8ISO8859P1); 
  end;    

  /*  Mapping context name with value for the merge process*/
  function addContext (context in StringList, name in string, value in string) return StringList 
  is  
       map StringList:=context;
  begin
       plsql_map.setString (map, name, value);  
       return map;
  end;    
  
  /*  Remove context by name or remove all by no name */
  function clearContext (context in StringList, name in string := null) return StringList 
  is 
       map StringList:=context;
  begin 
       if name is not null then 
           plsql_map.removeMapEntry (map, name);
       else 
          map := new StringList(); 
       end if;
       return map;
  end; 
  
  /* Render the template with the context into a new StringList */
  function  merge (context in StringList, template in StringList) return StringList
  is 
     lOutput  StringList := StringList();
     idx        pls_integer;  
     lTemplateKeys StringList := plsql_map.keySet(context); 
     idxTpl pls_integer;
     delimiter type.string := '%';
     line       type.string; 
  begin 
     idx := template.first;
     while(idx is not null) loop
           line := template(idx);   
           idxTpl := lTemplateKeys.first;
           while(idxTpl is not null)
           loop
                 if plsql_util.isNotBlank (lTemplateKeys (idxTpl)) then   
                     line := replace (line, delimiter||lTemplateKeys (idxTpl)||delimiter, plsql_map.getString(context, lTemplateKeys (idxTpl)));
                 end if; 
                 idxTpl := lTemplateKeys.next(idxTpl);
           end loop; 
           pUtil.extend (lOutput, line); 
           idx := template.next(idx);
     end loop;   
     return lOutput;
  end; 
  
end plsql_gen;
/
