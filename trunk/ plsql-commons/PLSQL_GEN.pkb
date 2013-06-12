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
     lOutput    StringList := StringList();
     idx        pls_integer;  
     lTemplateKeys StringList := plsql_map.keySet(context);
     idxTpl pls_integer;
     delimiter  type.string := '%';
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

  /* Render template on multiple levels generating output based on a query */
  function SqlTemplate (
    sqlStatement in string,
    columnTempl  in string := null,
    recordTempl  in string := '<ROW>{1}</ROW>',  -- 
    rootTempl    in string := '<ROOT>{1}</ROOT>' -- 
  ) 
     return string  
  is
    type rDynInfo is record (
      cur      integer           default dbms_sql.open_cursor,
      colcnt   number,
      desctbl  dbms_sql.desc_tab
    );
    vDynInfo   rDynInfo;
    vOutput    type.string;
    vStatus    integer;
    vData      StringList := StringList(); 
    
    function format (input in string)
      return string
    is
    begin
      return replace (input, '"', '''');
    end;
    
    function prepStatement (input in string)
      return rDynInfo
    as
      lDynInfo     rDynInfo;
      lColumnValue type.string;
    begin
      dbms_sql.parse (lDynInfo.cur, format (input), dbms_sql.native);
      dbms_sql.describe_columns (lDynInfo.cur,
                                 lDynInfo.colcnt,
                                 lDynInfo.desctbl
                                );
      for i in 1 .. lDynInfo.colcnt
      loop
        dbms_sql.define_column (lDynInfo.cur, i, lColumnValue, 4000);
      end loop;
      return lDynInfo;
    end;
    
    function fetchRow (dynInfo in rDynInfo, template in string)
      return StringList
    is
      lReturn  StringList := new StringList();
      vReturn  type.string;
    begin
      for i in 1 .. dynInfo.colcnt
      loop
        dbms_sql.column_value (dynInfo.cur, i, vReturn);
        if template is null
        then
          vReturn := plsql_util.printf ('<{1}>{2}</{1}>', new StringList (dynInfo.desctbl(i).col_name, vReturn));
        end if; 
        plsql_util.extend (lReturn, vReturn);
      end loop;
      return lReturn;
    end;
    
  begin
    vDynInfo := prepStatement (sqlStatement);
    vStatus  := dbms_sql.execute (vDynInfo.cur);
    while (dbms_sql.fetch_rows (vDynInfo.cur) > 0)
    loop
      vData := fetchRow (vDynInfo, columnTempl);
      if columnTempl is not null
      then
        vOutput := vOutput||plsql_util.printf(recordTempl, new StringList (plsql_util.printf (columnTempl,vData)));
      else
        vOutput := vOutput||plsql_util.printf(recordTempl, new StringList (plsql_util.join(vData)));
      end if;
    end loop;
    --
    vOutput := plsql_util.printf(rootTempl, new StringList (vOutput));
    return vOutput;
  end;
    
end plsql_gen;
/
 