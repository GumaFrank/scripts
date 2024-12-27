/*
Author: Frank Bgambe
Date: 11-OCT-2024
Description
Procedure to allow receivable Reconciliation

*/

-- check if the table exist
select * from   xxjicug_isf_journals_v;
/
-- else create the table
create table xxjicug_isf_journals_v 
as select * from APPS.XXJICUG_ISF_JOURNALS_V@JICOFPROD.COM where rownum <1

/
-- and the Column to tell when did the procedure run
ALTER TABLE xxjicug_isf_journals_v
ADD date_proc_run DATE;
/

-- Create the procedure to post data from OFA, APPS.XXJICUG_ISF_JOURNALS_V@JICOFPROD.COM to ISF xxjicug_isf_journals_v

create or replace PROCEDURE LOAD_XXJICUG_ISF_JOURNALS_V AS
BEGIN
Execute Immediate 'Truncate  table XXJICUG_ISF_JOURNALS_V'; --This table needs to be created in ISF
commit;
    INSERT INTO xxjicug_isf_journals_v (
        ledger_id,
        batch_id,
        group_id,
        batch_name,
        creation_date,
        journal_name,
        journal_source,
        journal_gategory,
        b_description,
        header_ref,
        line,
        account_combination,
        segment1,
        segment5,
        period,
        period_name,
        transaction_date,
        currency_code,
        entered_dr,
        entered_cr,
        description,
        accounted_dr,
        accounted_cr,
        post_status,
        date_proc_run
    )
        SELECT /*+ driving_site (n) */
    ledger_id,
    batch_id,
    group_id,
    batch_name,
    creation_date,
    journal_name,
    journal_source,
    journal_gategory,
    b_description,
    header_ref,
    line,
    account_combination,
    segment1,
    segment5,
    period,
    period_name,
    transaction_date,
    currency_code,
    entered_dr,
    entered_cr,
    description,
    accounted_dr,
    accounted_cr,
    post_status,
            sysdate
        FROM
            APPS.XXJICUG_ISF_JOURNALS_V@JICOFPROD.COM n
  WHERE transaction_date between '01-JAN-2022' and SYSDATE -1 ;
  commit;
  END;
  /
  -- ad hoc Excecution of the Procedure
  BEGIN
  LOAD_XXJICUG_ISF_JOURNALS_V;
END;
/

-- create and schedule the job

BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'ofa_jvs_to_isf',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN LOAD_XXJICUG_ISF_JOURNALS_V; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=0; BYMINUTE=0; BYSECOND=0',  -- Runs daily at midnight
    enabled         => TRUE,
    comments        => 'Job to run LOAD_XXJICUG_ISF_JOURNALS_V procedure daily at midnight'
  );
END;
/

SELECT job_name, enabled, repeat_interval, next_run_date
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'ofa_jvs_to_isf';

/

--- updating the job in case you want to change something in the scehedule
BEGIN
  DBMS_SCHEDULER.set_attribute (
    name           => 'ofa_jvs_to_isf',
    attribute      => 'repeat_interval',
    value          => 'FREQ=DAILY; BYHOUR=1; BYMINUTE=0; BYSECOND=0'  --  change the time
  );
END;
/

-- disabling the Job

BEGIN
  DBMS_SCHEDULER.disable ('ofa_jvs_to_isf');
END;
/

-- if you want to drop the Job

BEGIN
  DBMS_SCHEDULER.drop_job ('ofa_jvs_to_isf');
END;
/
