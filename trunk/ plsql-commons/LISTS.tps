create or replace type StringList as table of varchar2(32767)
/
create or replace type StringHashMap as table of StringList
/
create or replace type NumberList as table of number;
/ 