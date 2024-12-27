/*
Author  Frank Bagambe
Date: 17-JULY-2024
Description:  Gl_Extract_with_Line_of_Business 
included the Line of Business (V_LOB_DESC) from the GNLU_LOB_MASTER table,
joined the GNMT_POLICY table with GNMM_PLAN_MASTER, 
and then joined GNMM_PLAN_MASTER with GNLU_LOB_MASTER in which there was 
line of Business
*/

SELECT 
    V_POLAG_NO, 
    N_NET_CONTRIBUTION, 
    D_COMMENCEMENT, 
    D_POLICY_END_DATE, 
    V_STATUS_DESC, 
    V_GISS_CODE, 
    V_GL_CODE, 
    V_DOCU_TYPE, 
    V_DOCU_REF_NO,
    D_DATE D_POSTED_DATE, 
    V_PROCESS_CODE, 
    V_PROCESS_NAME, 
    V_DESC, 
    AGENCY, 
    SUM(N_AMT) N_AMT, 
    V_REMARKS ORACLE_JV,
    V_LOB_DESC -- Added Line of Business
FROM (
    SELECT
        b.V_POLAG_NO, 
        N_NET_CONTRIBUTION, 
        D_COMMENCEMENT, 
        D_POLICY_END_DATE, 
        V_STATUS_DESC, 
        b.N_REF_NO, 
        V_GISS_CODE, 
        V_GL_CODE, 
        V_DOCU_TYPE, 
        V_DOCU_REF_NO, 
        D_POSTED_DATE, 
        D_DATE, 
        V_TYPE, 
        DECODE(V_TYPE, 'D', N_AMT, -N_AMT) N_AMT, 
        V_PROCESS_CODE, 
        V_PROCESS_NAME, 
        V_DESC, 
        V_ACCOUNT_TYPE, 
        b.V_POLAG_TYPE,
        JHL_UTILS.AGENCY_NAME2(b.V_POLAG_NO) AGENCY,
        b.V_REMARKS,
        l.V_LOB_DESC -- Added Line of Business
    FROM 
        GNDT_GL_DETAILS a
        JOIN GNMT_GL_MASTER b ON a.N_REF_NO = b.N_REF_NO
        LEFT JOIN GNMM_PROCESS_MASTER c ON V_PROCESS_CODE = V_PROCESS_ID
        JOIN GNMT_POLICY d ON b.V_POLAG_NO = d.V_POLICY_NO
        JOIN GNMM_POLICY_STATUS_MASTER e ON V_STATUS_CODE = V_CNTR_STAT_CODE
        JOIN GNMM_PLAN_MASTER p ON d.V_PLAN_CODE = p.V_PLAN_CODE -- Joining GNMT_POLICY with GNMM_PLAN_MASTER
        JOIN GNLU_LOB_MASTER l ON p.V_PROD_LINE = l.V_LOB_CODE -- Joining GNMM_PLAN_MASTER with GNLU_LOB_MASTER
    WHERE 
        V_PROCESS_CODE != 'PR0140'
        AND b.V_JOURNAL_STATUS = 'C'
        AND V_GL_CODE IN (:P_GL_CODE)
        AND TRUNC(b.D_DATE) BETWEEN :P_FM_DT AND :P_TO_DT
)
GROUP BY 
    V_POLAG_NO, 
    N_NET_CONTRIBUTION, 
    D_COMMENCEMENT, 
    D_POLICY_END_DATE, 
    V_STATUS_DESC, 
    V_GISS_CODE, 
    V_GL_CODE, 
    V_DOCU_TYPE, 
    V_DOCU_REF_NO,
    D_DATE, 
    V_PROCESS_CODE, 
    V_PROCESS_NAME, 
    AGENCY, 
    V_DESC, 
    V_REMARKS,
    V_LOB_DESC; -- Include V_LOB_DESC in GROUP BY
