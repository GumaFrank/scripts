/*
Author: Eng Frank Bagambe Guma
Date 12-sep-2024
Descrtiption
Actuarial Evaluation Report 
the Modifications in the Report 
the Update in the report
By joining GNMM_PLAN_MASTER on the shared column V_PLAN_CODE, the V_PLAN_NAME 
column is included in
 both parts of the UNION query to provide the description for each plan code. 
This modification allows you to display the V_PLAN_NAME directly in your query results

*/

SELECT A.V_POLICY_NO,
       LOB.V_LOB_DESC AS "Line of Business",
       F.V_NAME,
       DECODE (V_PLAN_RIDER, 'R', 'RIDER', 'P', 'PLAN') V_PLAN_RIDER,
       V_STATUS_DESC,
       NVL2 (A.N_PROFIT, 1, 0) M_PROFIT_STATUS,
       A.V_PLAN_CODE,
       B.V_PLAN_NAME,  -- Fetch V_PLAN_NAME from GNMM_PLAN_MASTER
       DECODE(A.V_PLAN_CODE, 'BJIP001-B', 'Investment product',
                                 'BJIP006', 'Investment product',
                                 'BJIP007', 'Investment product',
                                 'BJIP001', 'Investment product',
                                 'BJIP003', 'Investment product',
                                 'Traditional product') AS Classification,
       F.N_IND_SA,
       A.N_TERM N_POLICY_TERM,
       A.N_PREM_PAY_TERM,
       (F.N_IND_BASIC_PREM * 12) / DECODE (A.V_PYMT_FREQ, '00', 12, TO_NUMBER (A.V_PYMT_FREQ)) ANNUALISED_PREMIUM,
       AMOUNT BONUS,
       (NVL (N_IND_LOADING, 0) * 12) / DECODE (A.V_PYMT_FREQ, '00', 12, TO_NUMBER (A.V_PYMT_FREQ)) EXTRA_PA,
       (NVL (N_IND_DISCOUNT, 0) * 12) / DECODE (A.V_PYMT_FREQ, '00', 12, TO_NUMBER (A.V_PYMT_FREQ)) DISCOUNT,
       V_PYMT_DESC,
       DECODE (V_SEX, 'M', 'MALE', 'F', 'FEMALE') V_GENDER,
       TO_CHAR (D_COMMENCEMENT, 'YYYY') RISK_YEAR,
       TO_CHAR (D_COMMENCEMENT, 'MM') RISK_MONTH,
       A.D_PREM_DUE_DATE,
       D_NEXT_OUT_DATE,
       D_POLICY_END_DATE,
       (SELECT Q.D_BIRTH_DATE FROM GNMT_CUSTOMER_MASTER Q WHERE Q.N_CUST_REF_NO = F.N_CUST_REF_NO AND F.N_SEQ_NO = 1) DOB1,
       JHL_UTILS.DOB_TWO (A.V_POLICY_NO) DOB2
  FROM GNMT_POLICY A
       JOIN GNMM_PLAN_MASTER B ON A.V_PLAN_CODE = B.V_PLAN_CODE
       JOIN GNLU_LOB_MASTER LOB ON B.V_PROD_LINE = LOB.V_LOB_CODE
       JOIN GNMM_POLICY_STATUS_MASTER C ON A.V_CNTR_STAT_CODE = C.V_STATUS_CODE
       JOIN GNLU_FREQUENCY_MASTER D ON A.V_PYMT_FREQ = D.V_PYMT_FREQ
       LEFT JOIN JHL_AMOUNTS_V2 E ON A.V_POLICY_NO = E.V_POLICY_NO AND E.AMT_TYPE = 'DUE_BONUS_AMT'
       JOIN GNMT_POLICY_DETAIL F ON A.V_POLICY_NO = F.V_POLICY_NO AND F.N_SEQ_NO = 1
 WHERE LOB.V_LOB_CODE IN ('LOB001', 'LOB005')
   AND A.V_PLAN_CODE NOT LIKE 'FSC%'
UNION
SELECT A.V_POLICY_NO,
       LOB.V_LOB_DESC AS "Line of Business",
       F.V_NAME,
       DECODE (V_PLAN_RIDER, 'R', 'RIDER', 'P', 'PLAN') V_PLAN_RIDER,
       V_STATUS_DESC,
       NVL2 (A.N_BENEFIT_AMOUNT, 1, 0) M_PROFIT_STATUS,
       A.V_PLAN_CODE,
       B.V_PLAN_NAME,  -- Fetch V_PLAN_NAME from GNMM_PLAN_MASTER
       DECODE(A.V_PLAN_CODE, 'BJIP001-B', 'Investment product',
                                 'BJIP006', 'Investment product',
                                 'BJIP007', 'Investment product',
                                 'BJIP001', 'Investment product',
                                 'BJIP003', 'Investment product',
                                 'Traditional product') AS Classification,
       N_RIDER_SA N_SUM_COVERED,
       N_RIDER_TERM N_POLICY_TERM,
       A.N_PREM_PAY_TERM,
       (N_RIDER_PREMIUM * 12) / DECODE (E.V_PYMT_FREQ, '00', 12, TO_NUMBER (E.V_PYMT_FREQ)) ANNUALISED_PREMIUM,
       0 BONUS,
       (NVL (N_RIDER_LOAD_PREM, 0) * 12) / DECODE (E.V_PYMT_FREQ, '00', 12, TO_NUMBER (E.V_PYMT_FREQ)) EXTRA_PA,
       (NVL (N_RIDER_DISCOUNT, 0) * 12) / DECODE (E.V_PYMT_FREQ, '00', 12, TO_NUMBER (E.V_PYMT_FREQ)) DISCOUNT,
       V_PYMT_DESC,
       DECODE (V_SEX, 'M', 'MALE', 'F', 'FEMALE') V_GENDER,
       TO_CHAR (D_RIDER_START, 'YYYY') RISK_YEAR,
       TO_CHAR (D_RIDER_START, 'MM') RISK_MONTH,
       E.D_PREM_DUE_DATE,
       D_NEXT_OUT_DATE,
       D_POLICY_END_DATE,
       (SELECT Q.D_BIRTH_DATE FROM GNMT_CUSTOMER_MASTER Q WHERE Q.N_CUST_REF_NO = F.N_CUST_REF_NO AND F.N_SEQ_NO = 1) DOB1,
       JHL_UTILS.DOB_TWO (A.V_POLICY_NO) DOB2
  FROM GNMT_POLICY_RIDERS A
       JOIN GNMM_PLAN_MASTER B ON A.V_PLAN_CODE = B.V_PLAN_CODE
       JOIN GNLU_LOB_MASTER LOB ON B.V_PROD_LINE = LOB.V_LOB_CODE
       JOIN GNMM_POLICY_STATUS_MASTER C ON A.V_RIDER_STAT_CODE = C.V_STATUS_CODE
       JOIN GNMT_POLICY E ON A.V_POLICY_NO = E.V_POLICY_NO
       JOIN GNLU_FREQUENCY_MASTER D ON E.V_PYMT_FREQ = D.V_PYMT_FREQ
       JOIN GNMT_POLICY_DETAIL F ON E.V_POLICY_NO = F.V_POLICY_NO AND A.V_POLICY_NO = F.V_POLICY_NO AND A.N_SEQ_NO = F.N_SEQ_NO
 WHERE LOB.V_LOB_CODE IN ('LOB001', 'LOB005')
   AND A.V_PLAN_CODE NOT LIKE 'FSC%'
