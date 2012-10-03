CREATE OR REPLACE PACKAGE plsql_log
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
 * Description : Log Framework, for logging application behavior, a 100% PLSQL Tool:
 *               - Inserting log statements into your code is a low-tech method for debugging it. It may also be the only way because debuggers are not always available or applicable. 
 *               - Logging behavior can be controlled by switching on and off, setting levels, layouts, labels and outputs.
 *               - Out of the box layout can be customized the way you like, printf style.
 *               - The target of the log output can be a DBMS_OUTPUT, table, DBMS_PIPE, HTP.
 *               - The package is being constantly improved thanks to input from users and code contributed by authors in the community. 
 * Since       : 1.0
 *    
 */ 
as 
  
  procedure setDFormat (dFormat IN string);
  function  getDFormat return string;
  function getTimeStamp return string; 
   
  /** 
    * Using this logger hierarchy it is possible to control which log statements are 
    * output. This also helps to reduce the volume of logged output and the cost of logging. 
    */
  LOG_OFF     constant number := 0;
  LOG_ERROR   constant number := 1;
  LOG_WARN    constant number := 2;
  LOG_TEST    constant number := 3;
  LOG_INFO    constant number := 4;
  LOG_DEBUG   constant number := 5;
  
  procedure setLevel (level in number);
  function  getLevel return number;

  /** 
    * Using this logger layout options you can control the markup/format of the logging output.  
    * You can choose between text only, text with timestamp, level and logStack or 
    * be completely free and format the output yourself in a printf style way, making use of the parameters 1=text, 2=timestamp, 3=level and 4=logStack
    * EXAMPLE:  '{3}({2}) => {1}' 
                   or 'TIMESTAMP{2};LEVEL={3};STACK={4};TEXT={1}'    
                   or '<logRecord><text>{1}</text><timestamp>{2}</timestamp><level>{3}</level><logStack>{4}</logStack></logRecord>'  
    */
  FORMAT_CUSTOM    constant plsql_type.string := 'CUSTOM';     -- Yours to define printf style 
  FORMAT_RICH_TEXT constant plsql_type.string := 'RICH_TEXT';  -- Text with timestamp, level, logStack 
  FORMAT_TEXT      constant plsql_type.string := 'TEXT';       -- Only text  
  
  procedure setLayout (layout in string, custom_layout in string default null); 
  function  getLayout return string;
  procedure setFormat (format in string);
  function getFormat return string;
 
  /** 
    * Output target can be where you like , choosing from system, logging table (PLSQL_LOGGING), Oracle Pipe or HTTP. 
    */                                        
  OUTPUT_SYSTEM constant plsql_type.string := 'SYSTEM'; -- DBMS_OUTPUT
  OUTPUT_TABLE    constant plsql_type.string := 'TABLE';    -- INSERT PLSQL_LOGGING
  OUTPUT_PIPE       constant plsql_type.string := 'PIPE';      -- DBMS_PIPE
  OUTPUT_HTTP     constant plsql_type.string := 'HTTP';     -- HTP
  
  procedure setOutput (output in string);
  function  getOutput return string;
  
  /** Optional for most output types but need in output type PIPE as it is set as pipe name. */ 
  procedure setIdentifier (identifier in string);
  function setRandomIdentifier return string;
  function getIdentifier return string;

  /** 
    * You can switch the logger on and off at any time in you sessie. The logger is stateless and therefore you will loss state when switching off.
    * SwitchOn will construct the state in one go as all variables are defaulted, but you can initialise the logger the way you like.    
   */        
  procedure switchOff; 
  
  /** 
    * @param level in number default NULL 
    * @param layout in string default NULL
    * @param output in string default NULL    
    * @pipeName in string default NULL
    */          
  procedure switchOn (level in number default NULL, layout in string default NULL, output in string default NULL, identifier in string default NULL);
 
  /** 
    * All log levels have a methode you can choose to indicate the level of log severity. Text will be the logging text.  
    * @param text in number default NULL 
    * @param args  
   */        
  procedure debug (text in string, args in StringList default new StringList());
  procedure info (text in string, args in StringList default new StringList());
  procedure test (text in string, args  in StringList default new StringList());
  procedure warn (text in string, args  in StringList default new StringList());
  procedure error (text in string, args  in StringList default new StringList());

  /** 
    * A Stack keeps track of the call trace based upon pushed and popped label values during runtime execution . 
   */    
  procedure pushStack (label in string);
  procedure popStack;
  procedure emptyStack;
  function getStack return string;

end plsql_log;
/
