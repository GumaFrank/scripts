/* Formatted on 24/12/2019 10:39:07 (QP5 v5.256.13226.35538) */
SELECT B.V_COMPANY_NAME,
       a.V_POLICY_NO,
       E.V_COMPANY_NAME V_AGENT,
       d.V_AGENT_CODE,
       a.d_policy_end_date + 1 RENEWAL_DATE,
       a.V_LASTUPD_USER
  FROM GNMT_POLICY a,
       GNMM_COMPANY_MASTER b,
       AMMT_POL_AG_COMM c,
       AMMM_AGENT_MASTER d,
       GNMM_COMPANY_MASTER e
 --where d_policy_end_date BETWEEN   '31-dec-2012' AND  '31-Jan-2013'
 WHERE     (a.d_policy_end_date + 1) BETWEEN ( :P_FromDate) AND ( :P_ToDate)
       --where (a.d_policy_end_date + 1)  BETWEEN  :P_DATE_FROM AND  :P_DATE_TO
       AND A.V_COMPANY_CODE = B.V_COMPANY_CODE
       AND A.V_COMPANY_BRANCH = B.V_COMPANY_BRANCH
       AND A.V_POLICY_NO = C.V_POLICY_NO
       AND c.V_ROLE_CODE = 'SELLING'
       AND C.N_AGENT_NO = D.N_AGENT_NO
       AND D.V_COMPANY_CODE = E.V_COMPANY_CODE
       AND D.V_COMPANY_BRANCH = E.V_COMPANY_BRANCH