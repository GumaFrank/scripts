select * from  gnmt_policy where v_policy_no ='UG202300991826'
 --commit
select a.d_quotation_date, a.*  from gnmt_policy_detail a where a.v_policy_no ='UG202300991826'

select * from   jhl_ofa_voucher_errors order by 2  --where OVE_DESC like '%PIN%'

SELECT * FROM GNMT_POLICY_DETAIL WHERE V_POLICY_NO = 'UG201700255293'
SELECT * FROM GNMT_CUSTOMER_MASTER WHERE UPPER(V_NAME)  LIKE UPPER ('%TWISHIME%') 79250 78942
SELECT * FROM GNDT_CUSTOMER_IDENTIFICATION WHERE N_CUST_REF_NO =320024
 
 SELECT * FROM CLDT_CLAIM_EVENT_POLICY_LINK WHERE V_CLAIM_NO='CL20222116'; --UI202100668350
 /
  SELECT * FROM CLDT_CLAIM_EVENT_STATUS_LINK WHERE V_CLAIM_NO='CL20222116';
  /
    SELECT * FROM CLDT_CLAIM_DECISION_HISTORY WHERE V_CLAIM_NO='CL20222116';
  /
  SELECT * FROM GNMT_GL_MASTER WHERE N_REf_NO IN ('27483838','27711564');
  /
  SELECT * FROM GNDT_GL_DETAILS WHERE N_REf_NO IN 
  (SELECT N_REF_NO FROM GNMT_GL_MASTER WHERE V_DOCU_REF_NO='CL20222116') ORDER BY 1,2;
  /
  UPDATE GNDT_GL_DETAILS SET V_LOB_CODE='LOB005' WHERE N_REF_NO='27711564' AND V_LOB_CODE='LOB001';
  
  2023000166
  /
  SELECT * FROM PYDT_VOUCHER_POLICY_CLIENT WHERE V_POLICY_NO='UI202100668350';
  /
  SELECT * FROM GNMT_GL_MASTER WHERE V_DOCU_REF_NO ='2023008379'
  SELECT * FROM PYMT_VOU_MASTER WHERE V_VOU_NO='2023014063' 
    SELECT * FROM PYDT_VOU_DETAILS WHERE V_VOU_NO='2023008380'
    
        SELECT * FROM PYDT_VOUCHER_POLICY_CLIENT WHERE V_VOU_NO='2023000166'
        SELECT * FROM GNDT_GL_DETAILS
        
/


SELECT * FROM  
EDIT GNMT_GL_MASTER WHERE  V_DOCU_REF_NO = '202301200'

2023008379
2023008380
2023009419
2023011250
2023011408
2023012454
2023013742
202301200




   SELECT * FROM  GNDT_GL_DETAILS WHERE N_REF_NO =29813152
2023008134
2023008379
2023008380
2023009419
2023011250
2023011406
2023011407
2023011408
2023012454
2023013742
2023011406
2023011407
202301200

SELECT * FROM GNMT_GL_MASTER WHERE  V_DOCU_REF_NO IN ('2023008134','2024001604')

2024001604


SELECT 
    distinct JOB_NAME,
    --JOB_CLASS,
    --ENABLED,
    --LAST_START_DATE,
    --LAST_RUN_DURATION,
    STATUS,
    RUN_DURATION,
    LOG_DATE
FROM 
    DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE 
    LOG_DATE >= TRUNC(SYSDATE) - 1 -- Filter for jobs that ran yesterday
    and JOB_NAME LIKE '%OFA%'
ORDER BY 
    LOG_DATE DESC;
/

select * from  DBA_SCHEDULER_JOB_RUN_DETAILS

/
SELECT 
    JOB_NAME,
    STATUS,
    TO_CHAR(ACTUAL_START_DATE, 'YYYY-MM-DD HH24:MI:SS') AS START_TIME,
    TO_CHAR(END_DATE, 'YYYY-MM-DD HH24:MI:SS') AS END_TIME,
    ROUND((END_DATE - START_DATE) * 24 * 60, 2) AS RUN_TIME_IN_MINUTES
FROM 
    DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE 
    JOB_NAME like  '%OFA%'
    AND START_DATE >= TRUNC(SYSDATE) - 1
    AND START_DATE < TRUNC(SYSDATE)
ORDER BY 
    START_DATE DESC;
/



-- gl missing 
2023011406, 
2023011407