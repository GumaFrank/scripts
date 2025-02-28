/*

Author Eng Frank Guma B
Date 16-JUL-2024
Description:  Aya Report with added Fields


*/


Select 
y.V_LASTUPD_USER,
y.V_QUALITY_CHECK_USER, -- ISSUED
y.D_QUALITY_CHECK_DATE, 
y.D_PROPOSAL_SUBMIT,
k.V_POLICY_NO,
k.V_AGENT_CODE,
k.V_AGENT_NAME,
k.V_CURRENTLY_REPORTING_CODE,
k.V_CURRENTLY_REPORTING_NAME,
k.V_LAST_REPORTING_CODE,
k.V_LAST_REPORTING_NAME,
k.V_PYMT_FREQ,
k.V_PYMT_DESC,
k.N_CONTRIBUTION,
k.API,    
k.D_ISSUE_DATE,
k.D_CNTR_START_DATE,
k.D_NDD,
k.D_PAID_UPTO,
k.MONTHS_PAID,
k.BOOKED_PREM,
k.V_CNTR_STAT_CODE,
k.V_STATUS_DESC,
k.V_PMT_METHOD_CODE,
k.V_PMT_METHOD_NAME,
k.V_OCCUP_CODE,
k.V_OCCUP_DESC,
k.N_IND_SA,
k.V_NAME,
k.V_PLAN_CODE,
k.V_PLAN_NAME
from
(
SELECT a.V_POLICY_NO,
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
       MONTHS_BETWEEN (D_PREM_DUE_DATE, D_CNTR_START_DATE) MONTHS_PAID,
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
       V_NAME,
       b.V_PLAN_CODE,
       V_PLAN_NAME
  FROM AMMT_POL_AG_COMM a,
       GNMT_POLICY_DETAIL b,
       GNMM_POLICY_STATUS_MASTER c,
       GNMM_PLAN_MASTER d,
       GNLU_FREQUENCY_MASTER f,
       GNLU_PAY_METHOD g,
       GNLU_OCCUP_MASTER h,
       V_AGENT_MASTER e
 WHERE     V_ROLE_CODE = 'SELLING'
       AND a.V_POLICY_NO = b.V_POLICY_NO
       AND a.V_STATUS = 'A'
       AND b.V_CNTR_STAT_CODE = c.V_STATUS_CODE
       AND b.V_PLAN_CODE = d.V_PLAN_CODE
       --AND b.V_CNTR_STAT_CODE NOT IN ('NB053','NB054','NB058','NB099')
       AND a.N_AGENT_NO = e.N_AGENT_NO(+)
       --AND b.V_PMT_METHOD_CODE = c.V_PMT_METHOD_CODE(+)
       --AND N_SELL_AGENT_LINK = :P_AGENT_NO
       AND a.V_POLICY_NO NOT LIKE 'GL%'
       AND b.N_SEQ_NO = 1
       AND D_ISSUE_DATE >= :START_DATE AND D_ISSUE_DATE <=   :END_DATE
       AND b.V_PYMT_FREQ = f.V_PYMT_FREQ
       AND NVL (b.V_PMT_METHOD_CODE, 'X') = g.V_PMT_METHOD_CODE(+)
       AND b.V_OCCUP_CODE = h.V_OCCUP_CODE(+)
       )  k , gnmt_policy y
       
       where
       k.v_policy_no=y.v_policy_no
        --and rownum <=10
        
        order by  4 desc