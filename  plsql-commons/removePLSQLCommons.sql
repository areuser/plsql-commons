spool deinstallation.log

drop table plsql_tests;
drop table plsql_logging;
drop sequence s_log_id;
drop sequence s_test_id;

drop package PLSQL_LOG;
drop package PLSQL_PIPE;
drop package PLSQL_TEST;
drop package PLSQL_ERROR;
drop package PLSQL_TYPE;
drop package PLSQL_UTIL;
drop package PLSQL_GEN;
drop package TST_PLSQL_LOG;
drop package TST_PLSQL_ERROR;
drop package TST_PLSQL_UTIL;
drop package PLSQL_MAP;

drop type StringList FORCE;
drop type StringHashMap FORCE;
drop type NumberList FORCE;

drop synonym pLog   ;
drop synonym pTest  ;
drop synonym pPipe  ;
drop synonym pError ;
drop synonym pType  ;
drop synonym pUtil  ;
drop synonym pMap   ;

spool off
exit;