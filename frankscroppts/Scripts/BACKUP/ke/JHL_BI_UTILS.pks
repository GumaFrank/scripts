CREATE OR REPLACE PACKAGE             JHL_BI_UTILS AS 
 PROCEDURE POPULATE_GL_TRANS;
  PROCEDURE GET_REVIVAL_PREMIUM_TEST;
  PROCEDURE POPULATE_IL_TRANS;
  PROCEDURE POPULATE_IL_UW;  
  FUNCTION get_all_agn_persistancy(v_date date, v_m_start number, v_m_end number) RETURN number;
  FUNCTION GET_AGENT_NAME
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2;
   FUNCTION AGENT_NAME
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2;
     FUNCTION RIDER_PREMIUM
    (P_POLICY_NO IN VARCHAR2)
  RETURN NUMBER;
  
       FUNCTION GET_PREV_STATUS
    (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE)
  RETURN VARCHAR2;
  FUNCTION Get_Claim_Adjusted_Amt (p_claim_no IN CLDT_PROVISION_DETAIL.V_CLAIM_NO%TYPE) RETURN NUMBER;
  FUNCTION Get_Date_Diff (v_from_dt DATE , v_to_dt DATE ) RETURN NUMBER;
    FUNCTION GET_CUR_POL_STATUS (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE) RETURN VARCHAR2;
    
    FUNCTION get_cleared_pol_apl (p_policy_no   IN GNMT_POLICY.V_POLICY_NO%TYPE,
                              v_type           VARCHAR,
                              v_end_date       DATE)
   RETURN NUMBER;
   
   FUNCTION get_claim_type(claim_no   VARCHAR, v_vou_desc VARCHAR)
   RETURN VARCHAR;
   FUNCTION get_prev_rct_dt(pol_no VARCHAR, v_cur_date DATE)
   RETURN DATE;
   FUNCTION get_prev_rct_amt(pol_no VARCHAR, v_date DATE)
   RETURN NUMBER;
    FUNCTION get_wk_start_end(v_wk_no NUMBER, v_type VARCHAR)
   RETURN DATE;
    FUNCTION get_wk_start_end_desc(v_wk_no NUMBER) RETURN VARCHAR;
    FUNCTION get_policy_scheme(v_pol_no  VARCHAR) RETURN VARCHAR;
    function  get_policy_status_user (P_Policy_No  VARCHAR, v_st  VARCHAR ) return VARCHAR;
      FUNCTION GET_POL_STATUS
    (P_STATUS_CODE IN GNMM_POLICY_STATUS_MASTER.V_STATUS_CODE%TYPE)
  RETURN VARCHAR2;
  FUNCTION is_policy_annuity (P_Policy_No VARCHAR)
   RETURN VARCHAR;
     FUNCTION duplicate_pin_count (v_pin_no  VARCHAR)
   RETURN NUMBER;
     FUNCTION get_bill_time (p_bill_no  VARCHAR,p_code VARCHAR )
   RETURN NUMBER;
   
     FUNCTION get_voucher_status(p_vou_no VARCHAR)
   RETURN VARCHAR;
   FUNCTION Get_Productivity_Avg(P_USERNAME VARCHAR2, P_TRANS_TYPE VARCHAR2, P_GROUPING VARCHAR2)  RETURN OBJ_JHL_GL_PROD_AVG;
    FUNCTION get_other_pol_count (v_cust_code  number, v_pol VARCHAR,  v_arrears  VARCHAR Default 'N') RETURN NUMBER; 
    
FUNCTION get_voucher_payment_date (v_vou_no VARCHAR,v_amt NUMBER,v_date date  )
      RETURN date;
       PROCEDURE GENERATE_POL_AMOUNTS(v_pol_no VARCHAR);
        function get_amt_to_words(v_amt number)return Char;
        PROCEDURE GENERATE_POL_AMOUNTS_SUR(v_pol_no VARCHAR);
         function get_bfn_count (P_policy_no varchar2, p_survival_date date)  return number;
          function get_emp_id (P_policy_no varchar2, v_cust_ref_no varchar2, v_type varchar2 )  return varchar2;
          FUNCTION get_policy_amounts (v_pol_no VARCHAR,   v_amt_type VARCHAR)
      RETURN NUMBER;
      function  get_ri_arrangement_amt ( p_amt_type VARCHAR , p_ri_policy_no VARCHAR, 
                                                  p_treaty_code VARCHAR , p_reinsurer_code VARCHAR   ) return Number;
       FUNCTION is_voucher_annuity (p_vou_no VARCHAR)
   RETURN VARCHAR;
    FUNCTION get_ind_customer_pin (v_cust_ref_no  number) RETURN VARCHAR;
    FUNCTION get_co_customer_pin (v_companycode  VARCHAR, v_companybranch VARCHAR) RETURN VARCHAR;
     FUNCTION CHECK_VALID_PIN (V_PIN_NO VARCHAR) RETURN VARCHAR2;
     FUNCTION get_identifier_count (v_cust_ref_no  number,v_code VARCHAR2) RETURN NUMBER;
END JHL_BI_UTILS;

/