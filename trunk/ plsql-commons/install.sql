set define off;
spool installation.log
@@plsql.tab
@@PLSQL_LOG.pks;
@@PLSQL_LOG.pkb;
@@PLSQL_PIPE.pks;
@@PLSQL_PIPE.pkb;
@@PLSQL_TEST.pks;
@@PLSQL_TEST.pkb;
@@PLSQL_ERROR.pks;
@@PLSQL_ERROR.pkb;
@@PLSQL_TYPE.pks;
@@PLSQL_UTIL.pks;
@@PLSQL_UTIL.pkb;
@@TST_PLSQL_LOG.pks;
@@TST_PLSQL_LOG.pkb;
@@TST_PLSQL_ERROR.pks;
@@TST_PLSQL_ERROR.pkb;
@@TST_PLSQL_UTIL.pks;
@@TST_PLSQL_UTIL.pkb;
@@PLSQL_MAP.pks;
@@PLSQL_MAP.pkb;
@@LISTS.tps; 
set define on;
@@syn.sql;

alter package PLSQL_LOG compile;
alter package PLSQL_LOG compile body;
alter package PLSQL_PIPE compile;
alter package PLSQL_PIPE compile body;
alter package PLSQL_TEST compile;
alter package PLSQL_TEST compile body;
alter package PLSQL_ERROR compile;
alter package PLSQL_ERROR compile body;
alter package PLSQL_UTIL compile;
alter package PLSQL_UTIL compile body;
alter package PLSQL_TYPE compile;
alter package PLSQL_MAP compile;
alter package PLSQL_MAP compile body;
alter package PLSQL_TYPE compile;

alter package TST_PLSQL_LOG compile;
alter package TST_PLSQL_LOG compile body;
alter package TST_PLSQL_ERROR compile;
alter package TST_PLSQL_ERROR compile body;
alter package TST_PLSQL_UTIL compile;
alter package TST_PLSQL_UTIL compile body;

begin pTest.runTestSuite ( 'TST_PLSQL_ERROR'); end;
begin pTest.runTestSuite ( 'TST_PLSQL_UTIL' ); end;
begin pTest.runTestSuite ( 'TST_PLSQL_LOG' ); end; 

spool off
exit;