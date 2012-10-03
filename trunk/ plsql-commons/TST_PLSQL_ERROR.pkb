CREATE OR REPLACE PACKAGE BODY TST_PLSQL_ERROR 
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

  procedure t_Catch
  is 
  begin
    -- 
    begin
          -- plog.switchOn; 
          begin
                 raise Dup_Val_On_Index;
          exception 
          when others then 
                pError.setMessageFormat  ( '<ERROR>{1}</ERROR><MESSAGE>{2}</MESSAGE><STACK>{3}</STACK>' ); 
                pError.catch (sqlcode,pError.getErrorMessage (pError.UserDefinedException), StringList (sqlerrm), true, false);
          end; 
         raise Dup_Val_On_Index;
    exception 
    when others then 
         pError.setMessageFormat  ( pError.DEFAULT_MESSAGE); 
         pError.catch (errorCode => sqlcode, errorMessage => sqlerrm, withCallStack => true, reThrow => false);
    end;  

    -- 
    begin
       pError.throw (pError.RowtypeMismatchException );
    exception 
    when others then 
       if sqlcode = pError.RowtypeMismatchException then null; else pTest.assert (false,'sqlcode <> pError.RowtypeMismatchException'); end if;    
    end; 

    -- 
    begin
       pError.throw (pError.ProgramErrorException, '{1} says this is killing the {2} project, this error should be ignored', StringList ('Arnold','PLSQL Commons'));
    exception
    when others then 
       if sqlcode = pError.ProgramErrorException 
       then pTest.assert (pError.getErrorMessage(pError.ProgramErrorException)<>sqlerrm, 'sqlerrm message equals Error.ProgramErrorException');
       else pTest.assert (false,'sqlcode not equals pError.ProgramErrorException'); end if;    
    end; 
      
    -- 
    begin 
       pError.throw ('{1} says this is killing the {2} project, this error should be ignored', StringList ('Arnold','PLSQL Commons'));
    exception 
    when others then 
        -- plog.switchOn; 
        plog.error  (pError.catch2String (errorCode => sqlcode, errorMessage => sqlerrm, withCallStack => true , reThrow => false ) );
    end; 
    
  end; 
  
  procedure t_Throw
  is 
  begin
    null; 
  end; 
  
  procedure t_MessageFormat
  is 
  begin
    null; 
  end; 
  
end tst_plsql_error;
/
