CREATE OR REPLACE PACKAGE BODY plsql_pipe
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

 
    TIMEOUT     integer := 60;
    DFORMAT    plsql_type.string := 'YYYYMMDD';
    
    procedure setDFormat (dFormat in string) 
    is
    begin
       plsql_pipe.DFORMAT := dFormat;
    end;
    
    function  getDFormat return string
    is
    begin 
       return plsql_pipe.DFORMAT;
    end; 
    
    procedure setTimeOut (timeout in integer) 
    is
    begin
       plsql_pipe.TIMEOUT := timeout;
    end;
    
    function getTimeOut return integer
    is
    begin 
       return plsql_pipe.TIMEOUT;
    end;
    
    procedure send (pipe in string, input in string)
    is
       status  integer;
       message plsql_type.string;
    begin
       if plsql_util.isNotBlank (input) and plsql_util.isNotBlank (pipe)
       then   
           -- implicitly creating a public pipe
           dbms_pipe.pack_message (input);
           status := dbms_pipe.send_message (pipe, getTimeOut );
           if status != 0 
           then 
                message  :=   case status 
                              when 1 then 'PipeException: Timed out. If the pipe was implicitly-created and is empty, then it is removed' 
                              when 2 then 'PipeException: Record in the pipe is too large for the buffer'
                              when 3 then 'PipeException: An interrupt occurred'
                              else  'PipeException: Unclear interruption occurred' end;
                pError.throw (pError.PipeException, message);
           end if;         
       end if;
    end; 
    
    procedure remove (pipe in string)
    is
       status    integer;
    begin
       if plsql_util.isNotBlank ( pipe ) 
       then
           begin  
               status := dbms_pipe.remove_pipe ( pipe );
           exception when others then null;
           end;
       end if;
    end; 
      
    function recieve (pipe in string, timeout integer default null) return string
    is
       status     integer;
       valueOf    integer;
       respValue  plsql_type.string;      
       respNumber number;
       respDate   Date;
    begin
       status := dbms_pipe.receive_message ( pipe, nvl ( timeout, getTimeOut ) ); 
       if status = 0
       then
          valueOf := dbms_pipe.next_item_type;
          if valueOf = 6
          then
             dbms_pipe.unpack_message ( respNumber );
             respValue := to_char( respNumber );
          elsif valueOf = 9
          then
             dbms_pipe.unpack_message ( respValue );
          elsif valueOf = 12
          then
             dbms_pipe.unpack_message ( respNumber );
             respValue := to_char( respNumber , getDFormat );
          else
             -- not implemented , valueOf 
             null; 
          end if;
       else
          -- not implemented , status 
          null; 
       end if;
      return respValue;
    end;  
end plsql_pipe;
/
