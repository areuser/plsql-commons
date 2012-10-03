CREATE OR REPLACE PACKAGE plsql_test 
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
 * Description : PLSQL_TEST is a Unit Testing Framework for writing and performing automatized unit tests for applications 
 *               written in PLSQL. It follows the tradition of the "xUnit" framework that is available for almost all 
 *               programming languages. Automatized tests are one of the cornerstones of a methodology called extreme programming, 
 *               which tries to solve many of the traditional problems with software development. 
 *               You can read more about it at http://www.xprogramming.org or http://www.extremeprogramming.org/. 
 *               
 *               Writing the tests before you write the stored procedure makes you think carefully about its interface, and 
 *               may improve the design. Each unit test can be seen as a design element specifying classes, methods, and observable behaviour. Automatic tests will give you the courage to refactoring your code without being afraid 
 *               of breaking anything. The tests also serve the purpose of documentation. They explain in detail what is expected 
 *               to happen in the stored procedures you write. 
 
 *               
 *  How to?   : Your test suite is a package, which can contain a setup procedure so you can first prepare the world' to make an isolated environment for testingx
 *                   In the end, whether succeed or fail we should clean up our 'world' to not disturb other tests or code
 *               
 * Checks the contract for implementing the UnitTest Interface, SetUp, TearDown, t_
 *  TestFixture, Test, ExpectedException(pError.ArithmeticException), SetUp,TearDown
 *               
 * Since       : 1.0
 *    
 * Example     : begin
 *                  pLog.switchOn; 
 *                  pTest.testSuite( 'TST_PLSQL_LOG' ); 
 *               end; 
 *    
 */ 
AS  
    type TestResult is record 
    ( suite pType.string 
    , unit pType.string 
    , isSucceeded  boolean 
    , exceptionCode pType.string
    , exceptionMessage pType.string        
    ); 
    
    type TestResultList is table of TestResult index by pls_integer;
    
    function runTestUnit (suite in string, unit in string) return TestResult;
    function runTestSuite (suite in string) return TestResultList;
    procedure runTestSuite (suite in string);
    procedure assert (condition in boolean, remark in string default NULL, args in StringList default new StringList());
    procedure persist (tstResultList TestResultList, identifier string default SYS_GUID);
    
end plsql_test;
/
