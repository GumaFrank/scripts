
SELECT POLICY.N_PROPOSER_REF_NO, POLICY.V_POLICY_NO, GNMT_CUSTOMER_MASTER.V_NAME AS CUSTOMER, PLAN.V_PLAN_NAME AS PRODUCT,GNDT_CUSTMOBILE_CONTACTS.V_CONTACT_NUMBER  FROM GNMT_POLICY POLICY  
LEFT JOIN GNMM_PLAN_MASTER PLAN ON POLICY.V_PLAN_CODE = PLAN.V_PLAN_CODE  LEFT JOIN
GNMT_CUSTOMER_MASTER ON GNMT_CUSTOMER_MASTER.N_CUST_REF_NO = POLICY.N_PROPOSER_REF_NO LEFT JOIN
GNDT_CUSTMOBILE_CONTACTS ON  GNMT_CUSTOMER_MASTER.N_CUST_REF_NO = GNDT_CUSTMOBILE_CONTACTS.N_CUST_REF_NO
WHERE POLICY.V_AGENT_CODE in ('BAM_O-A0003494\BAA_O-A0003494')
ORDER BY POLICY.N_PROPOSER_REF_NO