CREATE OR REPLACE PACKAGE BODY plsql_error
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
   errorMessageList StringList := new StringList();

   MESSAGE_FORMAT plsql_type.string :=  DEFAULT_MESSAGE;
   
   procedure setMessageFormat (input in string) 
   is
   begin
      MESSAGE_FORMAT := input;
   end;
   
   function  getMessageFormat return string
   is
   begin 
      return MESSAGE_FORMAT;
   end;
   
   procedure restoreDefaultMessageFormat
   is
   begin
      MESSAGE_FORMAT := DEFAULT_MESSAGE;
   end;

  function backTrace return string
  is
       bckTrace plsql_type.string default dbms_utility.format_error_backtrace;
  begin
       return bckTrace; 
       --  '"' ||plsql_util.join(plsql_util.replacer(plsql_util.subset(plsql_util.split(replace(backTrace,'"'), chr(10)), 'line [[:digit:]]*$'),  '^ORA.*?\.(.*?)$' ),'"->"')||'"'; -- bckTrace;
  end;
  
  function callStack return string
  is
       stack plsql_type.string default dbms_utility.format_call_stack;
  begin
       return plsql_util.join(plsql_util.replacer(plsql_util.subset(plsql_util.split (stack, chr(10)), 'package body|procedure|function|trigger'),  '.*?[package body|procedure|function|trigger].*?\.(.*?)$' ),'.'); 
  end;

  function errorStack return string
  is
       stack plsql_type.string default dbms_utility.format_error_stack;
  begin
       return plsql_util.join(plsql_util.replacer(plsql_util.subset(plsql_util.split (stack, chr(10)), 'package body|procedure|function|trigger'),  '.*?[package body|procedure|function|trigger].*?\.(.*?)$' ),'.'); 
  end;
  
  function getErrorMessage (errorCode in pls_integer) return string 
  is 
  begin 
       return plsql_map.getString (errorMessageList , errorCode);
  end;
  
  function log (errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false) return string  
  is 
       tmpMessage plsql_type.string := errorMessage;
       message plsql_type.string;
  begin 
    if plsql_util.isBlank ( tmpMessage ) 
    then
        tmpMessage := getErrorMessage (errorCode);
    end if;
    message := plsql_util.printf ( tmpMessage, errorArgs );
     if (withCallStack)
     then
         if plsql_util.isNotBLank (message) 
         then   
             message := plsql_util.printf (MESSAGE_FORMAT, StringList (errorCode,message,callStack,backTrace));
         else 
             message := plsql_util.printf (MESSAGE_FORMAT, StringList (nvl(errorCode,SQLCODE),SQLERRM(SQLCODE),callStack,backTrace));
         end if;
     end if;
     pLog.error(message);
     return message;
  end;

  procedure log (errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false)   
  is 
    message plsql_type.string;
  begin
     message := log (errorCode, errorMessage, errorArgs, withCallStack);
  end; 
  
  procedure throw ( errorMessage in string, errorArgs in StringList default new StringList() )
  is
  begin
       throw ( PLSQLException,  errorMessage, errorArgs);
  end; 

  procedure throw (errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false) 
  is 
       message plsql_type.string;
  begin 
    pTest.assert (plsql_util.contains (errorMessageList, errorCode) , '{1} is an unknown Exception.');
    message := log (errorCode, errorMessage, errorArgs, withCallStack);
    
    if PLSQLException = errorCode then  
          raise_application_error (PLSQLException, message);
    elsif errorCode between -20999 and -20000 then 
          pTest.assert (plsql_util.isNotBlank(plsql_map.getString(errorMessageList, errorCode)), 'User Error Code is defined within the error package');
          raise_application_error (errorCode, nvl(message, plsql_map.getString (errorMessageList, UndeclaredException)));
    elsif plsql_util.isNotBlank(plsql_map.getString (errorMessageList, errorCode)) then 
          -- raise_application_error (PLSQLException, nvl(message, plsql_map.getString (errorMessageList, UndeclaredException))); 
          
EXECUTE IMMEDIATE  plsql_util.printf ('declare  
   DynamicException exception; 
   pragma exception_init (DynamicException, {1});
begin 
   raise DynamicException;
end;',errorCode);

    else
          raise_application_error (PLSQLException, plsql_util.printf (MESSAGE_FORMAT, StringList (sqlcode,SQLERRM(SQLCODE))));
    end if;
  end;
   
  procedure validate (condition boolean, errorMessage string, errorArgs StringList default new StringList())
  is  
  begin 
       if ( condition )
       then 
         null; 
       else  
            throw (IllegalArgumentException, errorMessage, errorArgs, true); 
       end if;
  end;
      
  function catch2String (errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false, reThrow in boolean default true)  return string
  is
       message      plsql_type.string;
  begin     
     message := log (errorCode, errorMessage, errorArgs, withCallStack);
     if reThrow then
        throw (errorCode, message); 
--        if errorCode between -29999 and -20000 then 
--             pTest.assert (plsql_util.isNotBlank(plsql_map.getString(errorMessageList, errorCode)), 'User Error Code is defined within the error package');
--             throw (errorCode, nvl(message, plsql_map.getString (errorMessageList, UndeclaredException)));
--        elsif plsql_util.isNotBlank(plsql_map.getString (errorMessageList, errorCode)) then 
--             throw (nvl(message, plsql_map.getString (errorMessageList, UndeclaredException)));
--        else
--            if not withCallStack then log (errorCode, errorMessage, errorArgs, true); end if;
--            throw (sqlerrm(sqlcode));
--        end if;
     end if;   
     return message;              
  end;
   
  procedure catch (errorCode in pls_integer, errorMessage in string default NULL, errorArgs in StringList default new StringList(), withCallStack in boolean default false, reThrow in boolean default true)
  is  
      message plsql_type.string;
  begin
      message := catch2String (errorCode, errorMessage, errorArgs, withCallStack, reThrow);
  end;  
  
begin 
   -- 
   plsql_map.setString (errorMessageList, UserDefinedException        , 'Generic user defined exception: "{1}"');
   plsql_map.setString (errorMessageList, TestException                 , 'Exception thrown by the UnitTest application: "{1}"');
   plsql_map.setString (errorMessageList, PLSQLException                , 'Errors arise within PL/SQL program, contact the application manager to solve this issue.');
   
   plsql_map.setString (errorMessageList, ArithmeticException           , 'Thrown when an exceptional arithmetic condition has occurred. For example, an integer is "divide by zero" thrown');
   plsql_map.setString (errorMessageList, CannotUndoException           , 'Thrown when an UndoableEdit is told to undo() and can''t.');
   plsql_map.setString (errorMessageList, ModificationException         , 'This exception may be thrown by methods that have detected concurrent modification of an object when such modification is not permissible');
   plsql_map.setString (errorMessageList, EmptyStackException           , 'Thrown by methods in the Stack class to indicate that the stack is empty. '); 
   plsql_map.setString (errorMessageList, IllegalAccessException        , 'An IllegalAccessException is thrown when an application tries to invoke a method, but the currently executing method does not have access');
   plsql_map.setString (errorMessageList, IllegalArgumentException      , 'Unchecked exception thrown when a format string contains an illegal syntax or a format specifier that is incompatible with the given arguments. Only explicit subtypes of this exception which correspond to specific errors should be instantiated.');
   plsql_map.setString (errorMessageList, IllegalMonitorStateException  , 'IllegalMonitorStateException');
   plsql_map.setString (errorMessageList, IllegalStateException         , 'Signals that a method has been invoked at an illegal or inappropriate time. In other words, the PLSQL environment or PLSQL application is not in an appropriate state for the requested operation. ');
   plsql_map.setString (errorMessageList, InterruptedException          , 'Thrown when a thread is waiting, sleeping, or otherwise paused for a long time and another job interrupts it using the interrupt method in job.' );
   plsql_map.setString (errorMessageList, IndexOutOfBoundsException     , 'Thrown to indicate that an index of some sort (such as to an array, to a string, or to a vector) is out of range. ');
   plsql_map.setString (errorMessageList, MissingResourceException      , 'Signals that a resource is missing. ');
   plsql_map.setString (errorMessageList, NoSuchElementException        , 'Thrown by the nextElement method of an Enumeration to indicate that there are no more elements in the enumeration. ');
   plsql_map.setString (errorMessageList, NoSuchMethodException         , 'Thrown when a particular method cannot be found. ');
   plsql_map.setString (errorMessageList, NullPointerException          , 'Thrown when an application attempts to use null in a case where an object is required. ');
   plsql_map.setString (errorMessageList, NumberFormatException         , 'Thrown to indicate that the application has attempted to convert a string to one of the numeric types, but that the string does not have the appropriate format. ');
   plsql_map.setString (errorMessageList, PipeException                 , 'Thrown when an error occurs within a named pipe.');
   plsql_map.setString (errorMessageList, SecurityException             , 'Thrown by the security manager to indicate a security violation. ');
   plsql_map.setString (errorMessageList, SQLException                  , 'An exception that provides information on a database access error or other errors. ');
   plsql_map.setString (errorMessageList, SOAPFaultException            , 'The SOAPFaultException exception represents a SOAP fault. ');
   plsql_map.setString (errorMessageList, SystemException               , 'Thrown to indicate that a requested system action can''t be performed.');
   plsql_map.setString (errorMessageList, UndeclaredException           , 'Thrown to indicate that a requested operation can''t be performed but the why is undeclared. ');
   plsql_map.setString (errorMessageList, UnmodifiableSetException      , 'Thrown to indicate that the requested operation cannot be performed because the set is unmodifiable. ');
   
   plsql_map.setString (errorMessageList, AccessIntoNullException       , 'Your program attempts to assign values to the attributes of an uninitialized (atomically null) object.');
   plsql_map.setString (errorMessageList, CaseNotFoundException         , 'None of the choices in the WHEN clauses of a CASE statement is selected, and there is no ELSE clause.');
   plsql_map.setString (errorMessageList, CollectionIsNullException     , 'Your program attempts to apply collection methods other than EXISTS to an uninitialized (atomically null) nested table or varray, or the program attempts to assign values to the elements of an uninitialized nested table or varray.');
   plsql_map.setString (errorMessageList, CursorAlreadyOpenException    , 'Your program attempts to open an already open cursor. A cursor must be closed before it can be reopened. A cursor FOR loop automatically opens the cursor to which it refers. So, your program cannot open that cursor inside the loop.');
   plsql_map.setString (errorMessageList, DupValOnIndexException        , 'Your program attempts to store duplicate values in a database column that is constrained by a unique index.');
   plsql_map.setString (errorMessageList, InvalidCursorException        , 'Your program attempts an illegal cursor operation such as closing an unopened cursor.');
   plsql_map.setString (errorMessageList, InvalidNumberException        , 'In a SQL statement, the conversion of a character string into a number fails because the string does not represent a valid number. (In procedural statements, VALUE_ERROR is raised.) This exception is also raised when the LIMIT-clause expression in a bulk FETCH statement does not evaluate to a positive number.');
   plsql_map.setString (errorMessageList, LoginDeniedException          , 'Your program attempts to log on to Oracle with an invalid username and/or password.');
   plsql_map.setString (errorMessageList, NoDataFoundException          , 'A SELECT INTO statement returns no rows, or your program references a deleted element in a nested table or an uninitialized element in an index-by table. SQL aggregate functions such as AVG and SUM always return a value or a null. So, a SELECT INTO statement that calls an aggregate function never raises NO_DATA_FOUND. The FETCH statement is expected to return no rows eventually, so when that happens, no exception is raised.');
   plsql_map.setString (errorMessageList, NotLoggedOnException          , 'Your program issues a database call without being connected to Oracle.');
   plsql_map.setString (errorMessageList, ProgramErrorException         , 'PL/SQL has an internal problem.');
   plsql_map.setString (errorMessageList, RowtypeMismatchException      , 'The host cursor variable and PL/SQL cursor variable involved in an assignment have incompatible return types. For example, when an open host cursor variable is passed to a stored subprogram, the return types of the actual and formal parameters must be compatible.');
   plsql_map.setString (errorMessageList, SelfIsNullException           , 'Your program attempts to call a MEMBER method on a null instance. That is, the built-in parameter SELF (which is always the first parameter passed to a MEMBER method) is null.');
   plsql_map.setString (errorMessageList, StorageErrorException         , 'PL/SQL runs out of memory or memory has been corrupted.');
   plsql_map.setString (errorMessageList, SubscriptBeyondCountException , 'Your program references a nested table or varray element using an index number larger than the number of elements in the collection.');
   plsql_map.setString (errorMessageList, SubscriptOutsideLimitException, 'Your program references a nested table or varray element using an index number (-1 for example) that is outside the legal range.');
   plsql_map.setString (errorMessageList, SysInvalidRowidException      , 'The conversion of a character string into a universal rowid fails because the character string does not represent a valid rowid.');
   plsql_map.setString (errorMessageList, TimeoutOnResourceException    , 'A time-out occurs while Oracle is waiting for a resource.');
   plsql_map.setString (errorMessageList, TooManyRowsException          , 'A SELECT INTO statement returns more than one row.');
   plsql_map.setString (errorMessageList, ValueErrorException           , 'An arithmetic, conversion, truncation, or size-constraint error occurs. For example, when your program selects a column value into a character variable, if the value is longer than the declared length of the variable, PL/SQL aborts the assignment and raises VALUE_ERROR. In procedural statements, VALUE_ERROR is raised if the conversion of a character string into a number fails. (In SQL statements, INVALID_NUMBER is raised.)');
   plsql_map.setString (errorMessageList, ZeroDivideException           , 'Your program attempts to divide a number by zero.');
            
end plsql_error;
/
