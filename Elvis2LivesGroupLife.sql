
SELECT 
K.D_COMMENCEMENT,
B.V_POLICY_NO,
B.V_NAME,
B.N_SALARY,
B.N_CONTRIBUTION,
B.N_EMPLOYER_CONTRIBUTION,
B.N_IND_SA,
B.N_IND_BASIC_PREM,
B.D_PREM_DUE_DATE,
B.D_NEXT_DUE_DATE,
B.V_CNTR_STAT_CODE,
(SELECT A.V_STATUS_DESC FROM GNMM_POLICY_STATUS_MASTER A WHERE A.V_STATUS_CODE = B.V_CNTR_STAT_CODE) AS STATUS,
B.D_IND_DOB,
B.N_INDSA_REQUEST,
B.N_INDPREM_REQUEST,
B.N_IND_NET_CONTRIBUTION,
B.N_IND_NET_BASIC_PREM,
B.D_CNTR_STAT_DATE,
B.D_CNTR_END_DATE,
B.D_ENTRY_DATE
FROM gnmt_policy_detail B
JOIN gnmt_policy K ON B.v_policy_no = K.v_policy_no
WHERE (B.v_policy_no LIKE 'UG%' OR B.v_policy_no LIKE 'UT%')
AND K.D_COMMENCEMENT BETWEEN '01-JAN-2024' AND '05-AUG-2024'
-- AND B.v_policy_no IN ('UG202000585592', 'UG201700257323')
ORDER BY K.D_COMMENCEMENT desc
