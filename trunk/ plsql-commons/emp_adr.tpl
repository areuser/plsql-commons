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
    rLog %short_name%_log_pck.%short_name%_type;
  begin
    rLog.action_type        := 'D';
    rLog.%short_name%_rowid := :old.rowid;
    rLog.%short_name%_id    := :old.%short_name%_id;
    %column_list1% 
    %short_name%_log_pck.store (rLog);
  end;
  
  insert into %dollar_table_name%
  ( %column_list2% 
  )
  values
  ( :old.%short_name%_id
  , %short_name%_log_pck.transaction_id
  , %short_name%_log_pck.transaction_date
  , %short_name%_log_pck.transaction_user
  , %short_name%_log_pck.transaction_action_type
  %column_list3%
  ); 
  end;
END;
/
