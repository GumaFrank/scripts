/*
Author Frank Bagambe
Date 17-JULY-2024
Description.. Debit Knocked Report with Line of Business 

*/

SELECT A.V_POLICY_NO,
       A.V_PLAN_CODE,
       PM.V_PLAN_NAME AS "Product",
       CASE 
           WHEN PM.V_PROD_LINE = 'LOB004' THEN 'Credit Life'
           WHEN PM.V_PROD_LINE = 'LOB003' THEN 'Group Life'
           WHEN PM.V_PROD_LINE = 'LOB001' THEN 'Traditional Life'
           WHEN PM.V_PROD_LINE = 'LOB005' THEN 'Unit-linked'
           WHEN PM.V_PROD_LINE = 'LOB002' THEN 'Annuity'
           WHEN PM.V_PROD_LINE = 'MIS' THEN 'MISCELLANEOUS'
           ELSE 'UNKNOWN'
       END AS "Product Line",
       A.V_BILL_NO,
       A.D_BILL_RAISED_DATE,
       A.D_COMMENCEMENT,
       SUM(A.N_TRN_AMT) N_TRN_AMT,
       A.V_REF_NO,
       A.D_REF_DATE,
       A.AGENCY_SALES_MANAGER,
       A.REGIONAL_SALES_MANAGER,
       A.NATIONAL_SALES_MANAGER,
       A.D_REF_DATE D_POSTED_DATE
  FROM (SELECT B.V_POLICY_NO,
               B.V_PLAN_CODE,
               V_POSTED_REF_NO V_BILL_NO,
               TRUNC(D_DUE_DATE) D_BILL_RAISED_DATE,
               TRUNC(D_COMMENCEMENT) D_COMMENCEMENT,
               N_PREM_AMOUNT N_TRN_AMT,
               V_RECEIPT_NO V_REF_NO,
               TRUNC(PREM.D_RECEIPT_DATE) D_REF_DATE,
               (SELECT JHL_UTILS.AGENT_NAME(
                          SUM(DECODE(N_MANAGER_LEVEL, 20, N_MANAGER_NO, 0)))
                          ASM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A')
                  AGENCY_SALES_MANAGER,
               (SELECT JHL_UTILS.AGENT_NAME(
                          SUM(DECODE(N_MANAGER_LEVEL, 15, N_MANAGER_NO, 0)))
                          RSM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A')
                  REGIONAL_SALES_MANAGER,
               (SELECT JHL_UTILS.AGENT_NAME(
                          SUM(DECODE(N_MANAGER_LEVEL, 10, N_MANAGER_NO, 0)))
                          AS NSM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A'
                UNION
                SELECT JHL_UTILS.AGENT_NAME(
                          SUM(DECODE(N_MANAGER_LEVEL, 10, N_MANAGER_NO, 0)))
                          BAM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A')
                  NATIONAL_SALES_MANAGER
          FROM PPMT_PREMIUM_REGISTER PREM
          JOIN GNMT_POLICY B ON PREM.V_POLICY_NO = B.V_POLICY_NO
          JOIN AMMT_POL_AG_COMM C ON B.V_POLICY_NO = C.V_POLICY_NO
         WHERE V_ROLE_CODE = 'SELLING'
           AND C.V_STATUS = 'A'
           AND V_RECEIPT_NO IS NOT NULL
           AND B.V_POLICY_NO NOT LIKE 'GL%'
           AND TRUNC(PREM.D_RECEIPT_DATE) BETWEEN NVL(:P_FM_DT, TRUNC(SYSDATE, 'RRRR'))
                                             AND NVL(:P_TO_DT, TRUNC(SYSDATE))) A
  JOIN GNMM_PLAN_MASTER PM ON A.V_PLAN_CODE = PM.V_PLAN_CODE
GROUP BY A.V_POLICY_NO,
         A.V_PLAN_CODE,
         PM.V_PLAN_NAME,
         PM.V_PROD_LINE,
         A.V_BILL_NO,
         A.D_BILL_RAISED_DATE,
         A.D_COMMENCEMENT,
         A.V_REF_NO,
         A.D_REF_DATE,
         A.AGENCY_SALES_MANAGER,
         A.REGIONAL_SALES_MANAGER,
         A.NATIONAL_SALES_MANAGER
