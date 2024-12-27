/*
Author Eng Frank Bagambe Guma
Date 18-AUG-2024
Desc
Checking the ISF to OFA scheduled jobs if they ran succesfuly as scheduled
*/

--SET SERVEROUTPUT ON;

DECLARE
    v_ofa_gl_trans_proc_running  VARCHAR2(3);
    v_isf_payables_to_ofa_running VARCHAR2(3);
BEGIN
    -- Check if OFA_GL_TRANS_PROC job is running
    SELECT CASE
               WHEN COUNT(*) > 0 THEN 'YES'
               ELSE 'NO'
           END INTO v_ofa_gl_trans_proc_running
    FROM DBA_SCHEDULER_RUNNING_JOBS
    WHERE JOB_NAME = 'OFA_GL_TRANS_PROC';

    -- Check if ISF_PAYABLES_TO_OFA job is running
    SELECT CASE
               WHEN COUNT(*) > 0 THEN 'YES'
               ELSE 'NO'
           END INTO v_isf_payables_to_ofa_running
    FROM DBA_SCHEDULER_RUNNING_JOBS
    WHERE JOB_NAME = 'ISF_PAYABLES_TO_OFA';

    -- Output the results
    DBMS_OUTPUT.PUT_LINE('OFA_GL_TRANS_PROC running: ' || v_ofa_gl_trans_proc_running);
    DBMS_OUTPUT.PUT_LINE('ISF_PAYABLES_TO_OFA running: ' || v_isf_payables_to_ofa_running);
END;
/




DECLARE
    v_ofa_gl_trans_proc_last_run  DATE;
    v_isf_payables_to_ofa_last_run DATE;
BEGIN
    -- Get the last run time for OFA_GL_TRANS_PROC job
    SELECT MAX(ACTUAL_START_DATE)
    INTO v_ofa_gl_trans_proc_last_run
    FROM DBA_SCHEDULER_JOB_RUN_DETAILS
    WHERE JOB_NAME = 'OFA_GL_TRANS_PROC';

    -- Get the last run time for ISF_PAYABLES_TO_OFA job
    SELECT MAX(ACTUAL_START_DATE)
    INTO v_isf_payables_to_ofa_last_run
    FROM DBA_SCHEDULER_JOB_RUN_DETAILS
    WHERE JOB_NAME = 'ISF_PAYABLES_TO_OFA';

    -- Output the results
    DBMS_OUTPUT.PUT_LINE('Last run time for OFA_GL_TRANS_PROC: ' || v_ofa_gl_trans_proc_last_run);
    DBMS_OUTPUT.PUT_LINE('Last run time for ISF_PAYABLES_TO_OFA: ' || v_isf_payables_to_ofa_last_run);
END;
/

select * from  DBA_SCHEDULER_JOB_RUN_DETAILS;
/

SELECT 
    JOB_NAME, 
    MAX(ACTUAL_START_DATE) AS LAST_RUN_TIME
FROM 
    DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE 
    JOB_NAME IN ('OFA_GL_TRANS_PROC', 'ISF_PAYABLES_TO_OFA')
GROUP BY 
    JOB_NAME;
/

SELECT 
     STATUS,
    JOB_NAME,
    ACTUAL_START_DATE,
    LAG(ACTUAL_START_DATE) OVER (ORDER BY ACTUAL_START_DATE) AS PREVIOUS_START_DATE,
    (ACTUAL_START_DATE - LAG(ACTUAL_START_DATE) OVER (ORDER BY ACTUAL_START_DATE)) * 24 * 60 AS MINUTES_BETWEEN_RUNS
FROM 
    DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE 
    JOB_NAME = 'ISF_PAYABLES_TO_OFA'
ORDER BY 
   ACTUAL_START_DATE DESC;
/

select * from DBA_SCHEDULER_JOB_RUN_DETAILS;
/

SELECT 
    STATUS,
    JOB_NAME,
    ACTUAL_START_DATE,
    LAG(ACTUAL_START_DATE) OVER (ORDER BY ACTUAL_START_DATE) AS PREVIOUS_START_DATE,
    (ACTUAL_START_DATE - LAG(ACTUAL_START_DATE) OVER (ORDER BY ACTUAL_START_DATE)) * 24 * 60 AS MINUTES_BETWEEN_RUNS
FROM 
    DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE 
    JOB_NAME = 'OFA_GL_TRANS_PROC'
ORDER BY 
   ACTUAL_START_DATE DESC;
/


select * from xxjicug_ap_invoices_stg@JICOFPROD.COM where OPERATING_UNIT LIKE '%LIF%';
/
SELECT * FROM apps.GL_INTERFACE@JICOFPROD.COM where STATUS = 'NEW' AND  CURRENCY_CODE = 'UGX' 
ORDER BY DATE_CREATED DESC;
/


--DATE_CREATED  ASC
/

SELECT * FROM apps.GL_INTERFACE@JICOFPROD.COM  WHERE CURRENCY_CODE = 'UGX' 
and STATUS ='NEW' /*and USER_JE_CATEGORY_NAME = 'ISF Receipts' */
 AND USER_JE_SOURCE_NAME ='ISF LIFE'
ORDER BY ACCOUNTING_DATE  DESC;
/

select * from gl_interface where user_je_category_name ='ISF Others'
andSELECT * FROM apps.GL_INTERFACE@JICOFPROD.COM  WHERE CURRENCY_CODE = 'UGX' 
and STATUS ='NEW' and USER_JE_CATEGORY_NAME = 'ISF Receipts' 
ORDER BY ACCOUNTING_DATE  DESC; accounting_date ='31-JUL-2024'
 order by DATE_CREATED desc;
 /
 
 
 select * from  JHL_OFA_GL_TRANSACTIONS
select * from  JHL_OFA_GL_INTERFACE
/

--SELECT * FROM JHL_OFA_JOBS
--select OJB_NAME, OJB_START_DT - OJB_END_DT from JHL_OFA_JOBS
select OJB_START_DT, OJB_NAME, OJB_END_DT -OJB_START_DT  from JHL_OFA_JOBS ORDER BY OJB_START_DT DESC;
/



select * from JHL_OFA_GL_TRANSACTIONS order by D_DATE DESC

TRANSFORM_OFA_GL_TRANS
/

begin
    JHL_OFA_UTILS_1.OFA_GL_TRANS_PROC();
end;
/



SELECT 
    OJB_NAME, 
    (OJB_END_DT - OJB_START_DT) * 24 AS DURATION_IN_HOURS
FROM 
    JHL_OFA_JOBS
ORDER BY 
    OJB_START_DT DESC;
/

SELECT 
    OJB_NAME, 
    (OJB_END_DT - OJB_START_DT) * 24 * 60 AS DURATION_IN_MINUTES
FROM 
    JHL_OFA_JOBS
ORDER BY 
    OJB_START_DT DESC;
/

OFA_GL_TRANS_PROC
ISF_PAYABLES_TO_OFA


select  jhl_bi_utils.get_ind_customer_pin('5233') from dual;
 
select jhl_bi_utils.check_valid_pin('SID05226') from dual;


 JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED ('2023011408');