/*
Author Eng Frank Bagambe
Date 12-SEP-2024
Included a new column of Plan name  from gnmm_plan master 
Joined with GNMM_PLAN_MASTER: The script now includes GNMM_PLAN_MASTER (aliased as P) in the 
FROM clause to join the GNMT_POLICY table based on V_PLAN_CODE.
Select V_PLAN_NAME: The column P.V_PLAN_NAME is selected, which brings in the description for each plan code.
Update GROUP BY Clause: The GROUP BY clause includes the new column V_PLAN_NAME to ensure that the query is grouped correctly.

*/

SELECT V_POLICY_NO,
       V_BILL_NO,
       D_BILL_RAISED_DATE,
       D_COMMENCEMENT,
       SUM(N_TRN_AMT) N_TRN_AMT,
       V_REF_NO,
       D_REF_DATE,
       AGENCY_SALES_MANAGER,
       REGIONAL_SALES_MANAGER,
       NATIONAL_SALES_MANAGER,
       D_REF_DATE D_POSTED_DATE,
       V_LOB_DESC AS "Line of Business",
       V_PLAN_CODE,  
       V_PLAN_NAME,  -- New column added to display V_PLAN_NAME
       DECODE(V_PLAN_CODE,  
              'BJIP001-B', 'Investment product',
              'BJIP006', 'Investment product',
              'BJIP007', 'Investment product',
              'BJIP001', 'Investment product',
              'BJIP003', 'Investment product',
              'Traditional product') AS Classification
  FROM (SELECT B.V_POLICY_NO,
               B.V_PLAN_CODE,  
               P.V_PLAN_NAME,  -- Join and select V_PLAN_NAME from GNMM_PLAN_MASTER
               V_POSTED_REF_NO V_BILL_NO,
               TRUNC(D_DUE_DATE) D_BILL_RAISED_DATE,
               TRUNC(D_COMMENCEMENT) D_COMMENCEMENT,
               N_PREM_AMOUNT N_TRN_AMT,
               V_RECEIPT_NO V_REF_NO,
               TRUNC(PREM.D_RECEIPT_DATE) D_REF_DATE,
               (SELECT JHL_UTILS.AGENT_NAME (
                          SUM(DECODE(N_MANAGER_LEVEL, 20, N_MANAGER_NO, 0)))
                          ASM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A')
                  AGENCY_SALES_MANAGER,
               (SELECT JHL_UTILS.AGENT_NAME (
                          SUM(DECODE(N_MANAGER_LEVEL, 15, N_MANAGER_NO, 0)))
                          RSM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A')
                  REGIONAL_SALES_MANAGER,
               (SELECT JHL_UTILS.AGENT_NAME (
                          SUM(DECODE(N_MANAGER_LEVEL, 10, N_MANAGER_NO, 0)))
                          AS NSM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A'
                UNION
                SELECT JHL_UTILS.AGENT_NAME (
                          SUM(DECODE(N_MANAGER_LEVEL, 10, N_MANAGER_NO, 0)))
                          BAM
                  FROM AMMT_AGENT_HIERARCHY K
                 WHERE K.N_AGENT_NO = C.N_AGENT_NO AND V_STATUS = 'A')
                  NATIONAL_SALES_MANAGER,
               (SELECT L.V_LOB_DESC
                  FROM GNMM_PLAN_MASTER P, GNLU_LOB_MASTER L
                 WHERE P.V_PLAN_CODE = B.V_PLAN_CODE
                   AND P.V_PROD_LINE = L.V_LOB_CODE) V_LOB_DESC
          FROM PPMT_PREMIUM_REGISTER PREM, GNMT_POLICY B, AMMT_POL_AG_COMM C, GNMM_PLAN_MASTER P
         WHERE     PREM.V_POLICY_NO = B.V_POLICY_NO
               AND B.V_POLICY_NO = C.V_POLICY_NO
               AND B.V_PLAN_CODE = P.V_PLAN_CODE  -- Join condition to fetch V_PLAN_NAME
               AND V_ROLE_CODE = 'SELLING'
               AND C.V_STATUS = 'A'
               AND V_RECEIPT_NO IS NOT NULL
               AND B.V_POLICY_NO NOT LIKE 'GL%'
               AND TRUNC(PREM.D_RECEIPT_DATE) BETWEEN NVL(
                                                        :P_FM_DT,
                                                        TRUNC(SYSDATE,
                                                               'RRRR'))
                                                   AND NVL(:P_TO_DT,
                                                          TRUNC(SYSDATE)))
GROUP BY V_POLICY_NO,
         V_BILL_NO,
         D_BILL_RAISED_DATE,
         D_COMMENCEMENT,
         V_REF_NO,
         D_REF_DATE,
         AGENCY_SALES_MANAGER,
         REGIONAL_SALES_MANAGER,
         NATIONAL_SALES_MANAGER,
         V_LOB_DESC,
         V_PLAN_CODE,
         V_PLAN_NAME;  -- Added V_PLAN_NAME in the GROUP BY clause
/
