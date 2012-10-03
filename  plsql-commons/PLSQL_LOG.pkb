CREATE OR REPLACE PACKAGE BODY plsql_log
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
  /** Constants */
  LOG_RICH_TEXT constant plsql_type.string := '{2} {3} {4}   {1}'; -- timeStamp, level, logStack text 
  LOG_TEXT      constant plsql_type.string := '{1}'; 
  
  /** Settings */
  IS_ACTIVE           boolean := false;
  DFORMAT            plsql_type.string := 'YYYYMMDD-HH24:MI:SS.FF2';
  LEVEL                  number := LOG_DEBUG;
  LOG_FORMAT       plsql_type.string  := LOG_RICH_TEXT;
  LOG_OUTPUT       plsql_type.string  := OUTPUT_SYSTEM;
  LAYOUT               plsql_type.string  := FORMAT_RICH_TEXT;  -- User defined layout
  IDENTIFIER          plsql_type.string;
  STACK                 StringList := new StringList();
 
  procedure initialize 
  is 
  begin
          LEVEL                   := LOG_DEBUG;
          LOG_FORMAT       := LOG_RICH_TEXT;
          LOG_OUTPUT       := OUTPUT_SYSTEM;
          LAYOUT               := FORMAT_RICH_TEXT;
          setIdentifier(null);
          emptyStack;
  end;
  
  function getStack return string
  is 
  begin
     return nvl ( plsql_util.join ( STACK , '.' ) , '' );
  end;
 
  procedure pushStack (label in string)
  is 
  begin
    if ( IS_ACTIVE )
    then 
        STACK.extend;
        STACK ( STACK.count ) := label;
    end if;
  end;
  
  procedure popStack
  is 
  begin
    if ( IS_ACTIVE )
    then
        if ( STACK.count > 0 )
        then
            STACK.delete ( STACK.count );
        end if; 
    end if;
  end; 
    
  procedure emptyStack
  IS 
  begin
    if ( IS_ACTIVE )
    then 
        if ( STACK.count > 0 )
        then
            STACK.delete;
        end if; 
    end if;
  end; 
   
  function getTimeStamp return string
  is
  begin
        return to_char ( systimestamp , DFORMAT );
  end; 
  
  procedure setDFormat (dFormat in string) 
  is
  begin
     plsql_log.DFORMAT := dFormat;
  end;
  
  function  getDFormat return string
  is
  begin 
    return plsql_log.DFORMAT;
  end; 
  
  function level2String (level in number)  return string 
  is 
  begin 
     return case level 
              when 0 then 'LOG_OFF'
              when 1 then 'LOG_ERROR'
              when 2 then 'LOG_WARN'
              when 3 then 'LOG_TEST' 
              when 4 then 'LOG_INFO'
              when 5 then 'LOG_DEBUG'
              else  'UNKNOWN' end; 
  end;
  
  procedure setLevel (level in number) 
  is
  begin
     -- IllegalArgumentException 
      pTest.assert ( level between 0 and 5,  plsql_util.printf_ ('LEVEL type {1}, is not supported',  StringList (level2String(level))));
      plsql_log.LEVEL := level;
  end;
 
  function getLevel return number 
  is
  begin
    return plsql_log.LEVEL;
  end; 

  procedure setLayout (layout in string, custom_layout in string default null)
  is
  begin  
     -- IllegalArgumentException 
     pTest.assert ( layout in (FORMAT_TEXT, FORMAT_RICH_TEXT, FORMAT_CUSTOM),  plsql_util.printf_ ('LAYOUT type {1}, is not supported', StringList (layout)));
     plsql_log.LAYOUT := layout; 
     if plsql_log.LAYOUT = FORMAT_TEXT
     then 
         plsql_log.LOG_FORMAT := LOG_TEXT;
     elsif plsql_log.LAYOUT = FORMAT_RICH_TEXT 
     then 
         plsql_log.LOG_FORMAT := LOG_RICH_TEXT;
     elsif plsql_log.LAYOUT = FORMAT_CUSTOM
     then
        plsql_log.LOG_FORMAT := plsql_util.ite ( plsql_util.isNotBlank ( custom_layout ), custom_layout , LOG_TEXT ); 
     end if;       
  end;
  
  function getLayout return string 
  is
  begin
    return plsql_log.LAYOUT;
  end; 
  
  procedure setFormat (format in string )
  is
  begin
       plsql_log.LAYOUT := FORMAT_CUSTOM; 
       plsql_log.LOG_FORMAT := plsql_util.ite ( plsql_util.isNotBlank ( format ), format , LOG_TEXT );
  end; 
     
  function getFormat return string 
  is
  begin
      return LOG_FORMAT;
  end; 
  
  procedure setOutput (output in string)
  is
  begin
     -- IllegalArgumentException 
     pTest.assert ( output in ( OUTPUT_SYSTEM, OUTPUT_TABLE, OUTPUT_PIPE, OUTPUT_HTTP),  plsql_util.printf ('OUTPUT type {1}, is not supported', StringList (output)));
     LOG_OUTPUT := output;
     if LOG_OUTPUT = OUTPUT_SYSTEM
     then
        -- Set buffer_size to NULL for unlimited size, in 10gR2 (10.2) and above
        if  dbms_db_version.version > 10 or ( dbms_db_version.version  = 10  and dbms_db_version.release  >= 2 )
        then  
           dbms_output.enable (buffer_size => null);
        else  
           dbms_output.enable (buffer_size => 1000000);  
        end if; 
     end if;
  end; 
  
  function getOutput return string 
  is
  begin
     return LOG_OUTPUT;
  end;
  
  function getIdentifier return string 
  is
  begin
    return plsql_log.IDENTIFIER;
  end; 
 
  procedure setIdentifier (identifier in string)
  is
      status integer;  
  begin  
      pPipe.remove (getIdentifier);
     plsql_log.IDENTIFIER := identifier; 
  end;
  
 function setRandomIdentifier return string  
 is  
 begin
     setIdentifier(DBMS_PIPE.UNIQUE_SESSION_NAME);
     return getIdentifier;
 end;
 
  procedure log2Pipe (input in string)
  is
  begin
     pTest.assert ( plsql_util.isNotBlank ( getIdentifier ), 'Log identifier must be set when logging in PIPE mode');
     if plsql_util.isnotBlank (input) 
     then   
         -- implicitly creating a public pipe
         pPipe.send(getIdentifier, input); 
     end if;
  end; 

  procedure log2Table (logtext in string)
  is
     pragma autonomous_transaction;
     strLevel plsql_type.string:= level2String (getLevel); 
  begin  
     insert into plsql_logging (log_id, log_idenfier, log_level, log_stack , log_time, log_text) 
     values (s_log_id.nextval, getIdentifier, strLevel, getStack, systimestamp, logtext);
     commit;
  end;
 
  procedure printLog (input in string)
  is 
    logText plsql_type.string;
    offSet   number  := 0;
  begin
    if LOG_OUTPUT = OUTPUT_PIPE
    then
      log2Pipe (input);
    elsif LOG_OUTPUT  = OUTPUT_SYSTEM
    then
      if input is not null
      then
        dbms_output.put_line (input);
      end if;
    elsif LOG_OUTPUT = OUTPUT_TABLE
    then 
      logText := substr ( input , 4000 );
      while(logText is not null)
      loop
         log2Table ( logText );
         offSet   := offSet + 4000;
         logText := substr (input, offSet, 4000);
      end loop; 
    elsif LOG_OUTPUT = OUTPUT_HTTP
    then
      htp.print (input||'<br>');
    else
      null;
    end if;
  end;

  procedure log (type in string, text in string, args in StringList default new StringList ())
  is  
  begin
    if ( IS_ACTIVE )
    then
        printLog (plsql_util.printf (getFormat,StringList(plsql_util.printf (text,args), getTimeStamp, type, getStack)));
    end if;
  end;

  procedure debug (text in string, args in StringList default new StringList())
  is
  begin
    if getLevel >= LOG_DEBUG
    then
      log (LOG_DEBUG, text, args);
    end if; 
  end; 
  
  procedure info (text in string, args in StringList default new StringList())
  is
  begin
    if getLevel >= LOG_INFO 
    then 
      log (LOG_INFO, text, args);
    end if;
  end;

  procedure test (text in string, args in StringList default new StringList())
  is
  begin
    if getLevel  >= LOG_TEST
    then 
      log (LOG_TEST, text, args);
    end if;
  end;

  procedure warn (text in string, args in StringList default new StringList())
  is
  begin
    if getLevel >= LOG_WARN
    then 
      log (LOG_WARN, text, args);
    end if;
  end; 
  
  procedure error (text in string, args in StringList default new StringList())
  is
  begin
    if getLevel >= LOG_ERROR
    then 
      log (LOG_ERROR, text, args);
    end if;
  end; 

  procedure switchOn (level in number default NULL, layout in string default NULL, output in string default NULL, identifier in string default NULL) 
  IS
  begin
    IS_ACTIVE := true;
    initialize;
    if plsql_util.isNotBlank ( level ) 
    then 
       setLevel ( level );
    end if;
    if plsql_util.isNotBlank ( layout ) 
    then 
       setLayout ( layout );
    end if;
    if plsql_util.isNotBlank ( output ) 
    then 
       setOutput ( output );
    else 
       setOutput ( getOutput ); 
    end if;
    if plsql_util.isNotBlank ( identifier ) 
    then 
       setIdentifier ( identifier );
    end if;
  end;
 
  procedure switchOff
  is
  begin
     IS_ACTIVE := false;
     initialize;
  end; 
  
 end plsql_log;
/
