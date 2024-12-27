SELECT 
DISTINCT
    gp.V_POLICY_NO,
    gp.D_DISPATCH_DATE,
    gp.N_CONTRIBUTION,
    gp.D_ISSUE,
    gp.D_ACKNOWLEDGE,
    gp.N_PAYER_REF_NO,
    cm_assured.V_NAME AS ASSURED_NAME,
    cm_agent.V_NAME AS AGENT_NAME
FROM 
    GNMT_POLICY gp
JOIN 
    GNMT_CUSTOMER_MASTER cm_assured 
    ON gp.N_PAYER_REF_NO = cm_assured.N_CUST_REF_NO
LEFT JOIN 
    AMMT_POL_AG_COMM pac 
    ON gp.V_POLICY_NO = pac.V_POLICY_NO
LEFT JOIN 
    AMMM_AGENT_MASTER am 
    ON pac.N_AGENT_NO = am.N_AGENT_NO
LEFT JOIN 
    GNMT_CUSTOMER_MASTER cm_agent 
    ON am.N_CUST_REF_NO = cm_agent.N_CUST_REF_NO
WHERE 
    gp.D_ISSUE >= TO_DATE('2024-01-01', 'YYYY-MM-DD')
    order by 4 desc ;
    /
