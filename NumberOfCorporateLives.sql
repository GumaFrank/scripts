
/* 
AUTHOR: Eng Frank Bagambe
Date: 04-sep-2024
Description: Corporate Number of Lives 
Requested by Actuarial
Should be refreshed 1st of every month  
 */
  SELECT B.V_POLICY_NO,
         B.V_NAME,
         B.N_SALARY,
         B.N_CONTRIBUTION,
         B.N_EMPLOYER_CONTRIBUTION,
         B.N_IND_SA,
         B.N_IND_BASIC_PREM,
         B.D_PREM_DUE_DATE,
         B.D_NEXT_DUE_DATE,
         B.V_CNTR_STAT_CODE,
         (SELECT A.V_STATUS_DESC
            FROM GNMM_POLICY_STATUS_MASTER A
           WHERE A.V_STATUS_CODE = B.V_CNTR_STAT_CODE)
            STATUS,
         B.D_CNTR_START_DATE,
         B.D_CNTR_END_DATE,
         B.D_ENTRY_DATE
    FROM GNMT_POLICY_DETAIL B
   WHERE (B.V_POLICY_NO LIKE 'UG%' OR B.V_POLICY_NO LIKE 'UT%')
   --and B.V_CNTR_STAT_CODE = 'NB010'
ORDER BY D_CNTR_START_DATE DESC;
/

