/* 
AUTHOR Frank Guma B
DATE 03-SEP-2023
DESC  fETCHING POLICIES AND THE aGENTS AND THE bENEFECIARIES OR Norminees  for Apio

*/
SELECT *
  FROM (SELECT a.V_POLICY_NO,
               V_AGENT_CODE,
               V_AGENT_NAME,
               V_CURRENTLY_REPORTING_CODE,
               V_CURRENTLY_REPORTING_NAME,
               V_LAST_REPORTING_CODE,
               V_LAST_REPORTING_NAME,
               b.V_PYMT_FREQ,
               V_PYMT_DESC,
               N_CONTRIBUTION,
               12 / b.V_PYMT_FREQ * b.N_CONTRIBUTION API,
               D_ISSUE_DATE,
               D_CNTR_START_DATE,
               D_NEXT_DUE_DATE D_NDD,
               D_PREM_DUE_DATE D_PAID_UPTO,
               MONTHS_BETWEEN (D_PREM_DUE_DATE, D_CNTR_START_DATE)
                  MONTHS_PAID,
                 b.N_CONTRIBUTION
               / b.V_PYMT_FREQ
               * MONTHS_BETWEEN (D_PREM_DUE_DATE, D_CNTR_START_DATE)
                  BOOKED_PREM,
               V_CNTR_STAT_CODE,
               V_STATUS_DESC,
               b.V_PMT_METHOD_CODE,
               V_PMT_METHOD_NAME,
               b.V_OCCUP_CODE,
               V_OCCUP_DESC,
               N_IND_SA,
               nom.V_NAME AS NOMINEE_NAME, -- Fetching nominee name from GNMT_CUSTOMER_MASTER
               holder.V_NAME AS POLICY_HOLDER_NAME, -- Fetching policy holder name from GNMT_CUSTOMER_MASTER
               b.V_PLAN_CODE,
               V_PLAN_NAME
          FROM AMMT_POL_AG_COMM a
               JOIN GNMT_POLICY_DETAIL b
                  ON a.V_POLICY_NO = b.V_POLICY_NO
               JOIN GNMM_POLICY_STATUS_MASTER c
                  ON b.V_CNTR_STAT_CODE = c.V_STATUS_CODE
               JOIN GNMM_PLAN_MASTER d
                  ON b.V_PLAN_CODE = d.V_PLAN_CODE
               JOIN GNLU_FREQUENCY_MASTER f
                  ON b.V_PYMT_FREQ = f.V_PYMT_FREQ
               LEFT JOIN GNLU_PAY_METHOD g
                  ON NVL (b.V_PMT_METHOD_CODE, 'X') = g.V_PMT_METHOD_CODE
               LEFT JOIN GNLU_OCCUP_MASTER h
                  ON b.V_OCCUP_CODE = h.V_OCCUP_CODE
               LEFT JOIN V_AGENT_MASTER e
                  ON a.N_AGENT_NO = e.N_AGENT_NO
               LEFT JOIN psmt_nomination_history nom_hist
                  ON b.V_POLICY_NO = nom_hist.V_POLICY_NO
               LEFT JOIN GNMT_CUSTOMER_MASTER nom
                  ON nom_hist.N_CUST_REF_NO = nom.N_CUST_REF_NO
               LEFT JOIN GNMT_CUSTOMER_MASTER holder
                  ON b.N_CUST_REF_NO = holder.N_CUST_REF_NO -- Join to get the policy holder name
         WHERE     V_ROLE_CODE = 'SELLING'
               AND a.V_STATUS = 'A'
               AND a.V_POLICY_NO NOT LIKE 'GL%'
               AND b.N_SEQ_NO = 1--  AND D_ISSUE_DATE >= :START_DATE
                                 -- AND D_ISSUE_DATE <= :END_DATE
       )
 WHERE V_AGENT_CODE = 'A0005524';