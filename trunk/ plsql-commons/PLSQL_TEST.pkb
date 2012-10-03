CREATE OR REPLACE PACKAGE BODY plsql_test 
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

   exceptionList StringHashMap := StringHashMap();
   
   type testRecDefault is record  
   (procPrefix plsql_type.string := 'T\_'
   ,setUp      plsql_type.string := 'SETUP'
   ,tearDown   plsql_type.string := 'TEARDOWN' 
   );
   
   testDefaults testRecDefault;
   
   function toString(tstResult TestResult) return string                                                                                  
   is                                                                                                                                        
   begin                                                                                                                                     
       if ( tstResult .isSucceeded )                                                                                                             
       then                                                                                                                                    
          return plsql_util.printf('unit {1}.{2} succeeded',StringList(tstResult .suite,tstResult.unit));                                         
       else                                                                                                                                    
         return plsql_util.printf('unit {1}.{2} failed, cause {3}',StringList(tstResult .suite,tstResult .unit,tstResult .exceptionMessage));                 
       end if;                                                                                                                                 
   end;                                                                                                                                      

   function getTestUnits (suite in string) return StringList
   is
      cursor curTear (tearType in string) 
      is select distinct object_name unit, object_id
           from all_arguments
         where package_name = suite
             and object_name = tearType
             and object_name in (testDefaults.setUp,testDefaults.tearDown)
           order by object_id;                                                                   

      cursor curUnit 
      is select distinct object_name unit, object_id                                                                                        
         from   all_arguments
         where  package_name = suite
         and    object_name like testDefaults.procPrefix||'%' escape '\'
         and    object_name not in (testDefaults.setUp,testDefaults.tearDown)
         order by object_id;

      suiteList StringList := new StringList();
   begin

      for setup in curTear (testDefaults.setUp) loop
         plsql_util.extend(suiteList, testDefaults.setUp);
      end loop;

      for unitTest in curUnit loop
         plsql_util.extend (suiteList, unitTest.unit);
      end loop;

      for teardown in curTear (testDefaults.tearDown) loop
         plsql_util.extend(suiteList, testDefaults.tearDown);
      end loop;

      return suiteList;
   end;                                                                                                                                      
   
   function  runTestUnit  (suite in string, unit in string) return TestResult
   is                                                                                                                                        
       unitResult TestResult;
       exceptionCodeList StringList := plsql_map.keySet ( exceptionList );
       
   begin                     
       unitResult.suite := suite;
       unitResult.unit  := unit;
       declare                                                                                                                               
           execString plsql_type.string;                                                                                                           
       begin 
           execString := plsql_util.printf ('begin {1}.{2}; end;',StringList(suite,unit));        
           execute immediate execString;                                                                                                         
           unitResult.isSucceeded := true;                                                                                                         
           unitResult.exceptionMessage := null;                                                                                                              
       exception                                                                                                                             
       when others then                                                                                                                      
           unitResult.isSucceeded  := false;
           unitResult.exceptionMessage := sqlerrm;
       end;                                                                                                                                  
       return unitResult;                                                                                                                        
   end;                                                                                                                                      
                                                                                                      
   function  runTestSuite (suite in string) return TestResultList
   is
      unitResult    TestResult;
      tstResultList TestResultList;
      tstSuite       StringList := new StringList();
      unit             plsql_type.string;
      idx              number;
   begin                                                                                                                                                                                                                                                   
      tstSuite := getTestUnits (suite);
      idx := tstSuite.first;
      while( idx is not null ) loop
         unit := tstSuite (idx);
         unitResult := plsql_test.runTestUnit (suite, unit);
         tstResultList(tstResultList.count) := unitResult;
         idx := tstSuite.next(idx);
      end loop;
      return tstResultList;
   end;
                                                                                                                                             
    procedure runTestSuite (suite in string)
   is                                                                                                                                        
      tstResultList TestResultList;                                                                                    
      sResultList   TestResultList;                                                                                       
      fResultList   TestResultList;                                                                                       
      tstResult     TestResult;                                                                                            
      idx            number;                                                                                                                           
   begin                                                                                                                                     
       plsql_log.test ('===== Run Test Suite "{1}" ==== ', StringList(suite));
       tstResultList  := plsql_test.runTestSuite(suite);
       if tstResultList (tstResultList .first).unit = testDefaults.setUp then                                                                                                                                  
          tstResultList .delete (tstResultList .first);
       end if;                                                                                                                               
       if tstResultList (tstResultList .last).unit = testDefaults.tearDown then                                                                                                                                  
          tstResultList .delete (tstResultList .last);
       end if;                                                                                                                               
                                                                                                                                            
       idx := tstResultList .first;                                                                                                          
       while(idx is not null)                                                                                                                
       loop                                                                                                                                  
           tstResult := tstResultList (idx);                                                                                                
           plsql_log.test(toString(tstResult));                                                                                                  
           if ( tstResult.isSucceeded )                                                                                                       
           then                                                                                                                              
              sResultList(sResultList.count) := tstResult;                                                                                   
           else                                                                                                                              
              fResultList(fResultList.count) := tstResult;                                                                                   
           end if;                                                                                                                           
           idx := tstResultList.next(idx);                                                                                                  
       end loop;                                                                                                                             
                                                                                                                                            
       plsql_log.test('');                                                                                                                        
       plsql_log.test('===== Test Report  ===== ');                                                                                               
       plsql_log.test('Run {1} tests of which {2} succeeded and {3} failed', StringList(tstResultList .count, sResultList.count, fResultList.count));
       if ( fResultList.count > 0 )                                                                                                          
       then                                                                                                                                  
           plsql_log.test('Failures are caused by : ');                                                                                           
           idx := fResultList.first;                                                                                                         
           while(idx is not null)                                                                                                            
           loop                                                                                                                              
               tstResult := fResultList(idx);                                                                                               
               plsql_log.test(toString(tstResult));                                                                                              
               idx := fResultList.next(idx);                                                                                                 
           end loop;                                                                                                                         
       end if;                                                                                                                                     
    end;                                                                                                                                      
                                                                                                                                             
    procedure assert (condition in boolean, remark in string default NULL, args in StringList default new StringList())
    is                                                                                                                                        
    begin                                                                                                                                     
       if condition
       then                                                                                                                                   
          null;                                                                                                                                
       else                                                                                                                                   
          raise_application_error (pError.TestException, plsql_util.printf (remark, args));
       end if;                                                                                                                                
    end;

    procedure persist (tstResultList TestResultList, identifier string default SYS_GUID)
    is 
       pragma autonomous_transaction;
       tstResult TestResult;
       idx pls_integer;
       type tabTest is table of plsql_tests%rowtype index by binary_integer;
       tstResultTab tabTest;
    begin 
 
           idx := tstResultList .first;                                                                                                         
           while(idx is not null)                                                                                                            
           loop                                                                                                                              
               tstResult  := tstResultList (idx);
               select s_test_id.nextval into tstResultTab(idx).test_id from dual;
               tstResultTab(idx).test_time := systimestamp;
               tstResultTab(idx).test_identifier := identifier;
               tstResultTab(idx).test_suite := tstResult.suite;
               tstResultTab(idx).test_unit := tstResult.unit;
               tstResultTab(idx).test_succeeded := plsql_util.toChar(tstResult .isSucceeded);
               tstResultTab(idx).test_error := tstResult.exceptionCode;
               tstResultTab(idx).test_message := tstResult.exceptionMessage;
               idx := tstResultList.next(idx);
           end loop; 
           forall i in tstResultTab.first..tstResultTab.last
               insert into plsql_tests values tstResultTab(i);    
           commit;                                                                                              
    end;  
    
end plsql_test;
/
