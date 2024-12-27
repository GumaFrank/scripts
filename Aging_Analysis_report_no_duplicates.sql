/*
Author Eng Frank B
Date  21-AUG-2024
Description Arresting Dupplicates in Againg analysis Reports 
*/

SELECT 
V_COMPANY_CODE,
V_COMPANY_BRANCH,
V_SCHEME,
V_POLICY_NO,
N_OS_BAL_AMT,
N_OS_BAL_AMT-N_UNALLOCATED as ACTUAL_OUSTANDING,
N_TOT_DR,
N_UNALLOCATED,
DAYS_0_30,
DAYS_31_60,
DAYS_61_90,
DAYS_91_120,
DAYS_121_150,
DAYS_151_180,
DAYS_181_360,
OVER_360_DAYS,
V_BROKER_CODE,
V_BROKER_NAME
FROM
(

WITH Filtered_Policies AS (
    SELECT u.V_COMPANY_CODE,
           u.V_COMPANY_BRANCH,
           REPLACE(w.V_COMPANY_NAME, ',', '') V_SCHEME,
           u.V_POLICY_NO,
           (SELECT NVL(SUM(N_TRN_AMT), 0)
              FROM gndt_bill_trans BT
             WHERE BT.v_policy_no = U.v_policy_no AND BT.V_BILL_BAL_TYPE = 'D') N_OS_BAL_AMT,
           (SELECT SUM(N_TRN_AMT)
              FROM gndt_bill_trans BT
             WHERE BT.v_policy_no = U.v_policy_no
               AND BT.N_BILL_TRN_NO = 1
               AND BT.V_BILL_TYPE = 'DN') N_TOT_DR,
           (SELECT NVL(N_AMOUNT, 0)
              FROM PPMT_OVERSHORT_PAYMENT PT
             WHERE PT.v_policy_no = U.V_POLICY_NO AND ROWNUM = 1) N_UNALLOCATED,
           DAYS_0_30,
           DAYS_31_60,
           DAYS_61_90,
           DAYS_91_120,
           DAYS_121_150,
           DAYS_151_180,
           DAYS_181_360,
           OVER_360_DAYS,
           (SELECT V_AGENT_CODE
              FROM AMMT_POL_AG_COMM p, AMMM_AGENT_MASTER q, GNMM_COMPANY_MASTER r
             WHERE p.N_AGENT_NO = q.N_AGENT_NO
               AND p.V_ROLE_CODE = 'SELLING'
               AND p.V_STATUS = 'A'
               AND q.V_COMPANY_CODE = r.V_COMPANY_CODE
               AND q.V_COMPANY_BRANCH = r.V_COMPANY_BRANCH
               AND V_POLICY_NO = u.V_POLICY_NO) V_BROKER_CODE,
           (SELECT REPLACE(r.V_COMPANY_NAME, ',', '')
              FROM AMMT_POL_AG_COMM p, AMMM_AGENT_MASTER q, GNMM_COMPANY_MASTER r
             WHERE p.N_AGENT_NO = q.N_AGENT_NO
               AND p.V_ROLE_CODE = 'SELLING'
               AND p.V_STATUS = 'A'
               AND q.V_COMPANY_CODE = r.V_COMPANY_CODE
               AND q.V_COMPANY_BRANCH = r.V_COMPANY_BRANCH
               AND V_POLICY_NO = u.V_POLICY_NO) V_BROKER_NAME
      FROM (SELECT V_COMPANY_CODE,
                   V_COMPANY_BRANCH,
                   V_POLICY_NO,
                   SUM(N_TRN_AMT) N_TOT_DR,
                   SUM(N_BILL_BAL_AMT) N_BILL_BAL_AMT,
                   SUM(DAYS_0_30) DAYS_0_30,
                   SUM(DAYS_31_60) DAYS_31_60,
                   SUM(DAYS_61_90) DAYS_61_90,
                   SUM(DAYS_91_120) DAYS_91_120,
                   SUM(DAYS_121_150) DAYS_121_150,
                   SUM(DAYS_151_180) DAYS_151_180,
                   SUM(DAYS_181_360) DAYS_181_360,
                   SUM(OVER_360_DAYS) OVER_360_DAYS
              FROM (SELECT V_COMPANY_CODE,
                           V_COMPANY_BRANCH,
                           V_POLICY_NO,
                           N_TRN_AMT,
                           V_BILL_TYPE,
                           V_BILL_NO,
                           N_BILL_BAL_AMT,
                           DECODE(AGE_SLOT, 30, N_BAL_AMT, 0) DAYS_0_30,
                           DECODE(AGE_SLOT, 60, N_BAL_AMT, 0) DAYS_31_60,
                           DECODE(AGE_SLOT, 90, N_BAL_AMT, 0) DAYS_61_90,
                           DECODE(AGE_SLOT, 120, N_BAL_AMT, 0) DAYS_91_120,
                           DECODE(AGE_SLOT, 150, N_BAL_AMT, 0) DAYS_121_150,
                           DECODE(AGE_SLOT, 180, N_BAL_AMT, 0) DAYS_151_180,
                           DECODE(AGE_SLOT, 360, N_BAL_AMT, 0) DAYS_181_360,
                           DECODE(AGE_SLOT, 361, N_BAL_AMT, 0) OVER_360_DAYS
                      FROM (SELECT V_COMPANY_CODE,
                                   V_COMPANY_BRANCH,
                                   a.V_POLICY_NO,
                                   a.V_BILL_NO,
                                   N_BILL_TRN_NO,
                                   V_BILL_TYPE,
                                   D_TRN_DATE,
                                   DECODE(V_BILL_TYPE, 'DN', N_BILL_BAL_AMT, 'CN', -N_BILL_BAL_AMT) N_BILL_BAL_AMT,
                                   DECODE(V_BILL_TYPE, 'DN', N_TRN_AMT, 'CN', -N_TRN_AMT) N_TRN_AMT,
                                   NVL(N_SETTLED, 0),
                                   DECODE(V_BILL_TYPE,
                                          'DN', (N_TRN_AMT - NVL(N_SETTLED, 0)),
                                          'CN', -(N_TRN_AMT - NVL(N_SETTLED, 0))) N_BAL_AMT,
                                   TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) DAYS,
                                   CASE
                                      WHEN TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) <= 30 THEN 30
                                      WHEN TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) <= 60 THEN 60
                                      WHEN TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) <= 90 THEN 90
                                      WHEN TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) <= 120 THEN 120
                                      WHEN TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) <= 150 THEN 150
                                      WHEN TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) <= 180 THEN 180
                                      WHEN TRUNC(SYSDATE) - TRUNC(D_TRN_DATE) <= 360 THEN 360
                                      ELSE 361
                                   END AGE_SLOT
                              FROM GNDT_BILL_TRANS a,
                                   (SELECT V_POLICY_NO,
                                           V_BILL_NO,
                                           SUM(N_TRN_AMT) N_SETTLED
                                      FROM GNDT_BILL_TRANS
                                     WHERE V_POLICY_NO LIKE 'UG%'
                                       AND N_BILL_TRN_NO > 1
                                       AND NVL(D_TRN_DATE, TRUNC(SYSDATE)) <= NVL(:P_TO_DT, TO_DATE(SYSDATE, 'DD/MM/YYYY'))
                                     GROUP BY V_POLICY_NO, V_BILL_NO) b
                             WHERE a.V_POLICY_NO = b.V_POLICY_NO(+)
                               AND a.V_BILL_NO = b.V_BILL_NO(+)
                               AND a.V_POLICY_NO LIKE 'UG%'
                               AND N_BILL_TRN_NO = 1
                               AND NVL(V_BILL_BAL_TYPE, 'X') != 'R'
                               AND a.V_POLICY_NO IN (SELECT V_POLICY_NO
                                                       FROM GNMT_POLICY
                                                      WHERE V_CNTR_STAT_CODE = 'NB010')
                               AND NVL(D_AGE_START_DATE, TRUNC(SYSDATE)) <= NVL(:P_TO_DT, TO_DATE(SYSDATE, 'DD/MM/YYYY'))))
            GROUP BY V_COMPANY_CODE, V_COMPANY_BRANCH, V_POLICY_NO) u
      JOIN GNMM_COMPANY_MASTER w
        ON u.V_COMPANY_CODE = w.V_COMPANY_CODE
       AND u.V_COMPANY_BRANCH = w.V_COMPANY_BRANCH
      LEFT JOIN (SELECT V_POLICY_NO,
                        SUM(N_RECEIPT_AMT) N_RECEIPT_AMT
                   FROM REMT_RECEIPT
                  WHERE V_RECEIPT_TABLE = 'DETAIL'
                    AND V_RECEIPT_STATUS = 'RE001'
                    AND V_BUSINESS_CODE = 'GRP'
                    AND NVL(D_RECEIPT_DATE, TRUNC(SYSDATE)) <= NVL(:P_TO_DT, TO_DATE(SYSDATE, 'DD/MM/YYYY'))
                  GROUP BY V_POLICY_NO) v
        ON u.V_POLICY_NO = v.V_POLICY_NO
)
SELECT *
  FROM Filtered_Policies
 WHERE V_POLICY_NO IN (
       SELECT V_POLICY_NO
         FROM Filtered_Policies
        GROUP BY V_POLICY_NO
       HAVING COUNT(DISTINCT V_SCHEME) = 1)
       
);
/

--select * from jhl_isf_ofa_acc_map 