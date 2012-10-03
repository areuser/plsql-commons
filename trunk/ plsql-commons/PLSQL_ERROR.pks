CREATE OR REPLACE PACKAGE plsql_error
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
 * Description : Exception Framework, for handling application behavior when things go wrong, a 100% PLSQL Tool:
 *               - You can catch or raise the exceptions during the operation of the application
 * Since       : 1.0
 *    
 */  
as

    procedure throw ( errorMessage in string, errorArgs in StringList default new StringList() );
    procedure throw ( errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false);
    procedure validate (condition boolean, errorMessage string, errorArgs StringList default new StringList()); 
    
    function catch2String (errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false, reThrow in boolean default true) return string;  
    procedure catch (errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false, reThrow in boolean default true); 

    function callStack return string;  
    function backTrace return string;
    
    procedure setMessageFormat (input in string); 
    function  getMessageFormat return string;
    procedure restoreDefaultMessageFormat;
    DEFAULT_MESSAGE  constant plsql_type.string :=  '
ERROR: ORA{1}
MESSAGE: {2}
CALLSTACK: {3}
BACKTRACE: {4}
';
    
    function  getErrorMessage (errorCode in pls_integer) return string;

    AccessIntoNullException           constant pls_integer := -6530 ;
    CaseNotFoundException             constant pls_integer := -6592 ;
    CollectionIsNullException         constant pls_integer := -6531 ;
    CursorAlreadyOpenException        constant pls_integer := -6511 ;
    DupValOnIndexException            constant pls_integer := -1    ;
    InvalidCursorException            constant pls_integer := -1001 ;
    InvalidNumberException            constant pls_integer := -1722 ;
    LoginDeniedException              constant pls_integer := -1017 ;
    NoDataFoundException              constant pls_integer := -1403 ;
    NotLoggedOnException              constant pls_integer := -1012 ;
    ProgramErrorException             constant pls_integer := -6501;
    RowtypeMismatchException          constant pls_integer := -6504 ;
    SelfIsNullException               constant pls_integer := -30625;
    StorageErrorException             constant pls_integer := -6500 ;
    SubscriptBeyondCountException     constant pls_integer := -6533 ;
    SubscriptOutsideLimitException    constant pls_integer := -6532 ;
    SysInvalidRowidException          constant pls_integer := -1410 ;
    TimeoutOnResourceException        constant pls_integer := -51   ;
    TooManyRowsException              constant pls_integer := -1422 ;
    ValueErrorException               constant pls_integer := -6502 ;
    ZeroDivideException               constant pls_integer := -1476 ;    
    UserDefinedException              constant pls_integer := -20000;  
    ArithmeticException               constant pls_integer := -20001;  
    CannotUndoException               constant pls_integer := -20002; 
    ModificationException             constant pls_integer := -20003; 
    EmptyStackException               constant pls_integer := -20004; 
    IllegalAccessException            constant pls_integer := -20005; 
    IllegalArgumentException          constant pls_integer := -20006;  
    IllegalMonitorStateException      constant pls_integer := -20007;  
    IllegalStateException             constant pls_integer := -20008; 
    InterruptedException              constant pls_integer := -20009; 
    IndexOutOfBoundsException         constant pls_integer := -20010; 
    MissingResourceException          constant pls_integer := -20011; 
    NoSuchElementException            constant pls_integer := -20012; 
    NoSuchMethodException             constant pls_integer := -20013; 
    NullPointerException              constant pls_integer := -20014; 
    NumberFormatException             constant pls_integer := -20015; 
    PLSQLException                    constant pls_integer := -20016; 
    PipeException                     constant pls_integer := -20017; 
    SecurityException                 constant pls_integer := -20018; 
    SQLException                      constant pls_integer := -20019; 
    SOAPFaultException                constant pls_integer := -20020; 
    TestException                     constant pls_integer := -20021; 
    SystemException                   constant pls_integer := -20022; 
    UndeclaredException               constant pls_integer := -20023; 
    UnmodifiableSetException          constant pls_integer := -20024; 
    
end plsql_error;
/
