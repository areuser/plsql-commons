CREATE OR REPLACE TRIGGER %short_name%_adr AFTER DELETE ON %table_name% FOR EACH ROW
DECLARE
/*****************************************************************************
   NAME: %short_name%_adr
   PURPOSE:

   ADR trigger is generated.
   Modifications of the code will be lost

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0                    Dimitri Lambrou  Initial
******************************************************************************/
BEGIN
  
  declare
    rLog transaction_log.store_type;
  begin
    rLog.action_type := 'D';
    rLog.rowid       := :old.rowid;
    rLog.id          := :old.%short_name%_id; 
    rLog.entity_type := '%short_name%';
    transaction_log.store (rLog);
  end;
  
  insert into %dollar_table_name%
  ( %column_list1% 
  )
  values
  ( %column_list2%
  );
  end;
END;
/