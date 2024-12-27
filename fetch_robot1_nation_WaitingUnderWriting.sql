/*
Author: Updated by Eng Frank Bagambe Guma
Date: 07-OCT-2024

Description: 
in the where Clause, ADD_MONTHS(SYSDATE, -1) was added
ADD_MONTHS(SYSDATE, -1): This gets the date that is one month prior to the current date (SYSDATE).

and B.D_COMMENCEMENT <= SYSDATE

B.D_COMMENCEMENT <= SYSDATE: Ensures the risk date (D_COMMENCEMENT) is not in the future.

and it Fetchecthes only ROBOT1 transactions 
*/

SELECT DISTINCT A.V_POLICY_NO,
                B.V_PLAN_CODE,
                (SELECT K.V_PLAN_NAME
                   FROM GNMM_PLAN_MASTER K
                  WHERE K.V_PLAN_CODE = B.V_PLAN_CODE)
                   PLAN_CODE,
                B.D_COMMENCEMENT AS RISK_DATE,
                B.V_PROPOSER_NAME,
                B.V_PAYER_NAME,
                A.N_RECEIPT_AMT,
                B.V_CNTR_STAT_CODE,
                (SELECT k.V_STATUS_DESC
                   FROM GNMM_POLICY_STATUS_MASTER k
                  WHERE k.V_STATUS_CODE = B.V_CNTR_STAT_CODE)
                   POLICY_STATUS,
                A.V_USER_CODE,
                B.V_UNDERWRITER
  FROM REMT_RECEIPT A, gnmt_policy B
WHERE A.V_POLICY_NO = B.V_POLICY_NO
  AND A.V_REF_TYPE = 'POLICY'
  AND A.V_REF_CODE IS NOT NULL
  AND B.V_CNTR_STAT_CODE = 'NB054'
  AND B.D_COMMENCEMENT >= ADD_MONTHS(SYSDATE, -1)
  AND B.D_COMMENCEMENT <= SYSDATE
  AND  lower(B.V_UNDERWRITER) LIKE 'robo%';
  /
  
  --select * from gnmt_policy  where V_UNDERWRITER like '%ROBOT1%'

--SELECT * FROM GNMM_POLICY_STATUS_MASTER


--SELECT * FROM GNMT_POLICY_DETAIL WHERE V_POLICY_NO = 'UG201800361022'
--
--LIKE 'UG%' OR  V_POLICY_NO LIKE 'UT%'
--
--SELECT * FROM GNMT_POLICY WHERE V_POLICY_NO = 'UG201800361022'

--SELECT * FROM GNMM_COMPANY_MASTER  WHERE V_COMPANY_CODE = 'HFBNSSF2018'  --  V_COMPANY_NAME



 SELECT count(distinct(v_policy_no)) AS num_policies, pm.v_plan_desc,
  to_char(D_COMMENCEMENT, 'Month') AS MONTH, to_char(D_COMMENCEMENT, 'YYYY') AS Year, p.V_UNDERWRITER 
FROM gnmt_policy p JOIN gnmm_plan_master pm ON p.v_plan_code = pm.v_plan_code
WHERE lower(p.V_UNDERWRITER) LIKE 'robo%' AND to_char(D_COMMENCEMENT, 'YYYY') = 2024
GROUP BY pm.v_plan_desc, to_char(D_COMMENCEMENT, 'Month'),
 to_char(D_COMMENCEMENT, 'YYYY'), p.V_UNDERWRITER ORDER BY MONTH;