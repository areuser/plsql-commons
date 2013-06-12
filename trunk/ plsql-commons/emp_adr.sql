declare
     fileLoc      plsql_type.string := 'CRUD';
     lTemplate    StringList := StringList ();
     lContext     StringList := StringList ();
     lOutput      StringList := StringList ();
     tplName      plsql_type.string := 'emp_adr';
     column_list1 plsql_type.string;
     column_list2 plsql_type.string;
     column_list3 plsql_type.string;
     
     cursor c1 is select 'EMP' table_name, 'EMP' short_name, 'EMP$' dollar_table_name from dual;
     cursor c2 is select column_name, data_type from all_tab_columns where table_name = 'EMP';
begin
     plsql_gen.setLocation(fileLoc);
     lTemplate := plsql_gen.getTemplate (tplName);
     
     for r1 in c1 loop  
        lContext := plsql_gen.addContext (lContext, 'short_name', r1.short_name);  
        lContext := plsql_gen.addContext (lContext, 'table_name', r1.table_name);
        lContext := plsql_gen.addContext (lContext, 'dollar_table_name', r1.dollar_table_name);
     end loop;   

     for r2 in c2 loop   
       column_list1 := column_list1 || plsql_util.printf ('  , {1}
      ', StringList(r2.column_name));
       column_list2 := column_list2 || plsql_util.printf ('  , :old.{1}
      ', StringList(r2.column_name));
     end loop;   
     
     column_list2 := ltrim(column_list2,',');
     
     lContext := plsql_gen.addContext (lContext, 'column_list1', column_list1);  
     lContext := plsql_gen.addContext (lContext, 'column_list2', column_list2);  
     lOutput := plsql_gen.merge (lContext, lTemplate);
     plsql_file.putLines (tplName||'.trg', fileLoc, lOutput, plsql_file.WE8ISO8859P1);     
     lContext := plsql_gen.clearContext (lContext, 'column_list2');
     lContext := plsql_gen.clearContext (lContext);
end;