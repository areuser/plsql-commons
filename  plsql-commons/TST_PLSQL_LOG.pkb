CREATE OR REPLACE PACKAGE BODY tst_plsql_log 
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


  procedure t_Pipe 
  is 
     pipeResult pType.string;
  begin
      pPipe.send ('TEST','Send2Pipe 1');
      pPipe.setTimeOut (1);
      pTest.assert ( pPipe.recieve ('TEST') = 'Send2Pipe 1', 'Data should be recieved');
      pTest.assert ( pPipe.recieve ('TEST') is null, 'Pipe should be empty');
      pPipe.remove ('TEST');
      pTest.assert ( pPipe.recieve ('TEST') is null, 'Pipe is not closed');
      pPipe.send ('TEST','Send2Pipe 2');
      pTest.assert ( pPipe.recieve ('TEST') = 'Send2Pipe 2', 'Data should be recieved');
      pPipe.remove ('TEST');
      pPipe.remove ('TEST');
  end; 

  procedure t_DFormat
  is     
    tmpTimeStamp pType.string;
  begin
    pLog.switchOn;
    pLog.setDFormat ( pLog.getDFormat ); 
    pTest.assert ( pLog.getDFormat = 'YYYYMMDD-HH24:MI:SS.FF2' , 'Date Format is not set correctly'); 
    tmpTimeStamp := to_char ( systimestamp , pLog.getDFormat );
  end; 
  
  procedure t_Layout
  is     
    str pType.string := 'Why log in any format at all, okay "{1}"';
  begin
    pLog.switchOn;
    pTest.assert ( pLog.getLayout = pLog.FORMAT_RICH_TEXT, 'Default layout should be FORMAT_RICH_TEXT');
    pTest.assert ( pLog.getFormat = '{2} {3} {4}   {1}', 'And the format should be like {2} {3} {4}   {1}');
    pLog.setFormat ( str );
    pTest.assert ( pLog.getLayout = pLog.FORMAT_CUSTOM, 'The layout type will be implicitly set to LAYOUT_CUSTOM');
    pTest.assert ( pLog.getFormat = str, 'The supplied CustomLayout should be stored unchanged');
  end; 
  
  procedure t_Level 
  is     
  begin
    pLog.switchOn;
    pTest.assert ( pLog.getLevel = pLog.LOG_DEBUG , 'Default logging level should be DEBUG');
    pLog.setLevel ( pLog.LOG_INFO );
    pTest.assert ( pLog.getLevel = pLog.LOG_INFO, 'Setting and getting of the log LEVEL should be straight forward');
  end; 

  procedure t_Stack
  is 
  begin 
    pLog.switchOn;
    pLog.pushStack ('first');
    pLog.pushStack ('second');
    pLog.pushStack ('thirth');
    pTest.assert ( pLog.getStack = 'first.second.thirth', pUtil.printf('Log stack is not correct, "{1}"', StringList(pLog.getStack)));
    pLog.popStack;
    pTest.assert ( pLog.getStack = 'first.second', pUtil.printf('Log stack is not correct, "{1}"', StringList(pLog.getStack)));
    pLog.emptyStack;
    pTest.assert ( pLog.getStack is null, pUtil.printf('Log stack is not correct, "{1}"', StringList(pLog.getStack)));
  end; 
  
  procedure t_Debug
  is 
     identifier pType.string;
  begin 
    pLog.switchOn;
    pLog.setOutput ( pLog.OUTPUT_PIPE );
    identifier := pLog.setRandomIdentifier;
    pPipe.setTimeOut (1);
    pLog.setLayout ( pLog.FORMAT_TEXT );
    pLog.debug ('teststring');
    pTest.assert (trim(pPipe.recieve (identifier)) = 'teststring', 'Debug data should be recieved');
 end; 

  procedure t_Switch 
  is
    logMessage pType.string;
  begin 
    pLog.switchOn;
    pTest.assert (pLog.getLevel = pLog.LOG_DEBUG,pUtil.printf ('Default log level should be 5=DEBUG, but the level is {1}', StringList(pLog.getLevel)));
    pLog.setLevel (pLog.LOG_WARN);
    pTest.assert (pLog.getLevel = pLog.LOG_WARN, pUtil.printf ('Default log level should be 2=LOG_WARN, but the level is {1}', StringList(pLog.getLevel)));
    pLog.setLevel (pLog.LOG_DEBUG);
    pTest.assert (pLog.getLayout = pLog.FORMAT_RICH_TEXT, 'Default log layout should be RICH_TEXT');
    pTest.assert (pLog.getOutput = pLog.OUTPUT_SYSTEM, 'Default log should should be SYSTEM');
    pLog.setOutput (pLog.OUTPUT_PIPE);
    pTest.assert (pLog.getOutput = pLog.OUTPUT_PIPE, 'Output type should have been set to PIPE instead of '||pLog.getOutput);
    pTest.assert (pLog.getIdentifier is null, 'Log stack is not correct');
    pPipe.setTimeout(1);
    begin 
        pLog.debug ('identifier should be set');
        pTest.assert (false, 'PipeException not thrown');
        exception when others then null;
    end;
    pLog.setIdentifier('TST_PLSQL_LOG');
    pTest.assert (pLog.getIdentifier = 'TST_PLSQL_LOG', 'Indentifier is not correct');
    pLog.debug ('test string 1');
    logMessage := pPipe.recieve (pLog.getIdentifier);
    pTest.assert (pPipe.recieve (pLog.getIdentifier) is null, 'Pipe should be empty');
    pLog.setLayout (pLog.FORMAT_TEXT);
    pLog.debug ('test string 2');
    pTest.assert (pPipe.recieve (pLog.getIdentifier) = 'test string 2', 'Debug data should be recieved');
    pLog.switchOff;
    pTest.assert (pPipe.recieve ('TST_PLSQL_LOG') is null, 'Pipe should be closed');
    pLog.switchOn (pLog.LOG_INFO, pLog.FORMAT_TEXT, pLog.OUTPUT_PIPE, 'TST_PLSQL_LOG' );
    pTest.assert (pLog.getLevel = pLog.LOG_INFO 
                        and pLog.getLayout = pLog.FORMAT_TEXT 
                        and pLog.getFormat = '{1}' 
                        and pLog.getOutput = pLog.OUTPUT_PIPE
                        and pLog.getIdentifier = 'TST_PLSQL_LOG' ,'Log construction didn''t initialized the logger as aspected');                        
    pTest.assert (pPipe.recieve (pLog.getIdentifier) is null, 'Pipe should be empty');
    pPipe.send (pLog.getIdentifier, 'test string 3');
    pTest.assert (pPipe.recieve (pLog.getIdentifier) = 'test string 3', 'Pipe should not be empty');
    pLog.info ('test string 4');
    pTest.assert (pPipe.recieve (pLog.getIdentifier) = 'test string 4', 'debug data should be recieved');
    pLog.switchOff;
    pLog.switchOn;
  end;
  
end tst_plsql_log;
/
