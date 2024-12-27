CREATE OR REPLACE PACKAGE             JHL_GEN_PKG AS 
P_POLICY_NO  VARCHAR2(100);
FUNCTION check_same_bank (branch_code  VARCHAR,company_code VARCHAR, company_branch VARCHAR)    RETURN VARCHAR2;
FUNCTION check_valid_pin (v_assured_pin  VARCHAR,v_payer_pin VARCHAR)    RETURN VARCHAR2;

PROCEDURE create_user_limit (V_USER_NAME  VARCHAR2, v_from_amt  NUMBER ,v_to_amt  NUMBER );
FUNCTION get_pol_sign_user (policy_no  VARCHAR)    RETURN VARCHAR2;
FUNCTION get_voucher_status_user (vou_no  VARCHAR, vou_status VARCHAR)    RETURN VARCHAR2;
FUNCTION get_voucher_date (vou_no  VARCHAR, vou_status VARCHAR)    RETURN date;
FUNCTION get_user_name (user_name  VARCHAR)    RETURN VARCHAR2;
FUNCTION get_cash_amt (v_brh_code VARCHAR2, v_biz_code VARCHAR2,v_date_from  DATE, v_date_to DATE)    RETURN NUMBER;
FUNCTION get_chq_amt_sm_bnk (v_brh_code VARCHAR2, v_biz_code VARCHAR2,v_date_from  DATE, v_date_to DATE)    RETURN NUMBER;
FUNCTION get_chq_amt_dif_bnk (v_brh_code VARCHAR2, v_biz_code VARCHAR2,v_date_from  DATE, v_date_to DATE)    RETURN NUMBER;
FUNCTION get_chq_amt (v_brh_code VARCHAR2, v_biz_code VARCHAR2,v_date_from  DATE, v_date_to DATE)    RETURN NUMBER;
FUNCTION get_rct_amt (v_brh_code VARCHAR2, v_biz_code VARCHAR2,v_date_from  DATE, v_date_to DATE)    RETURN NUMBER;
FUNCTION is_voucher_authorized (v_voucher_no  VARCHAR2)    RETURN VARCHAR2;
FUNCTION get_dr_bank (v_pym  VARCHAR, v_brh VARCHAR, v_biz_code VARCHAR)    RETURN VARCHAR2;
FUNCTION get_dr_bank_code (v_pym  VARCHAR, v_brh VARCHAR, v_biz_code VARCHAR)    RETURN VARCHAR2;
FUNCTION policy_awaiting_premium (v_pol_no  VARCHAR)    RETURN VARCHAR2;
FUNCTION get_receipt_payee (v_rct_no  VARCHAR)    RETURN VARCHAR2;
FUNCTION get_voucher_policy (v_voucher_no  VARCHAR)    RETURN VARCHAR2;
PROCEDURE GET_REVIVAL_PREMIUM;
PROCEDURE GET_LOAN_OUTSTANDING;
PROCEDURE GET_APL_OUTSTANDING;
PROCEDURE Bpc_Process_BankIn_Instruments(
                        p_User                 IN  VARCHAR2,
                        p_Program             IN  VARCHAR2,
                        p_Data_Found_Flag    OUT VARCHAR2,
                        p_Instrument_cd     IN  VARCHAR2  default null,
                        P_SESSION_NO IN NUMBER
                        );
                            
PROCEDURE run_banking_process;
FUNCTION get_clm_provision_balance(p_claim_no VARCHAR2,p_sub_claim_no NUMBER, v_serial_no number, v_col_type VARCHAR2)  return number;

 FUNCTION get_company_name (v_pol_no VARCHAR)RETURN VARCHAR2;
       FUNCTION get_claim_amount (v_pol_no VARCHAR,v_from_dt date, v_to_date date)
      RETURN NUMBER;
             FUNCTION get_policy_requirement (v_pol_no VARCHAR)
      RETURN varchar;
      FUNCTION get_voucher_approval_date (VOU_NO VARCHAR)
      RETURN DATE;
         FUNCTION get_customer_identity (v_cus_no NUMBER,v_type VARCHAR)
      RETURN VARCHAR2;
        FUNCTION get_customer_contact(v_cus_no NUMBER,v_type VARCHAR)
      RETURN VARCHAR2;
               FUNCTION get_agent_policy_count(v_agent_no NUMBER)
      RETURN number;
         PROCEDURE GET_REVIVAL_OS_PREMIUM(pol_num VARCHAR,  LN_OUTS_PREM OUT NUMBER , LN_OUTS_PREM_INT   OUT NUMBER  );
      FUNCTION get_policy_channel(v_pol_type VARCHAR , v_pol_no VARCHAR) RETURN VARCHAR;
      FUNCTION get_bill_desc(v_doc_ref_no VARCHAR)
      RETURN varchar;
        FUNCTION get_agent_name(v_pol_type VARCHAR , v_pol_no VARCHAR)
      RETURN varchar;
        FUNCTION get_legacy_balance( v_pol_no VARCHAR)
      RETURN number;
         FUNCTION get_agent_from( v_pol_no VARCHAR)
      RETURN VARCHAR;
        FUNCTION Get_Outstanding_Balance( V_POL_NO VARCHAR)
      RETURN number;
    FUNCTION IS_VOUCHER_CANCELLED (V_VOUCHER_NO VARCHAR2)
      RETURN VARCHAR2;
      PROCEDURE future_prem_utilization_proc;
      FUNCTION get_entry_channel(ref_no NUMBER )
      RETURN varchar;
      FUNCTION GET_NUM_OS (V_POL_NO VARCHAR) RETURN VARCHAR  ;
      FUNCTION GET_NUM (V_POL_NO VARCHAR) RETURN NUMBER  ;
      FUNCTION GET_MATURITY_MONTH_BAL (V_POL_NO VARCHAR) RETURN VARCHAR;
      FUNCTION GET_MATURITY_MONTH_BAL2 (V_POL_NO VARCHAR) RETURN VARCHAR;
      FUNCTION GET_MATURITY_MONTH_BAL3 (V_POL_NO VARCHAR) RETURN VARCHAR;
   FUNCTION GET_UPR_AMOUNT (
  V_POL_NO VARCHAR,
  V_QUOT_BACKUP_TYPE VARCHAR,
  D_POLICY_END_DATE DATE,
  D_CNTR_START_DATE DATE,
  D_CNTR_END_DATE DATE,
  D_BILL_DUE_DATE DATE,
  D_BILL_RAISED date ,
  N_BILL_AMT NUMBER,
  N_TERM   NUMBER,
  D_COMMENCEMENT date ,
    V_BILL_TYPE VARCHAR )  RETURN NUMBER;
    
    FUNCTION get_voucher_payment_method  (V_Voucher_No VARCHAR2)
      RETURN VARCHAR2;
        PROCEDURE GET_REVIVAL_PREMIUM(v_pol_no VARCHAR);
         PROCEDURE GENERATE_POL_BONUS(v_pol_no VARCHAR);
           PROCEDURE POPULATE_LIFE_CUSTOMERS;
            PROCEDURE CSV_UPDATE_2 ;
            FUNCTION is_voucher_clean  (V_Voucher_No VARCHAR2)
      RETURN VARCHAR2;
       FUNCTION get_loan_amount  (v_pol_no VARCHAR2, v_type VARCHAR2 DEFAULT 'DRAWN' ) RETURN NUMBER;
       FUNCTION get_loan_Repaid  (v_pol_no VARCHAR2, v_type VARCHAR2 DEFAULT 'REPAID' ) RETURN NUMBER;
       FUNCTION get_intr_Repaid  (v_pol_no VARCHAR2, v_type VARCHAR2 DEFAULT 'INTEREST' ) RETURN NUMBER;
        FUNCTION IS_VOUCHER_AUTHORIZED_EFT (V_VOUCHER_NO VARCHAR2)
      RETURN VARCHAR2;
        FUNCTION get_policy_agent_name( v_pol_no VARCHAR)
      RETURN varchar;
      
            FUNCTION get_discount_premium( v_pol_no VARCHAR)
      RETURN NUMBER;
       
      PROCEDURE Mpesa_Alloc_Processing_Prc;
      
      
FUNCTION CHECK_IDENTIFICATION_VALIDITY (v_ident_val VARCHAR, v_type VARCHAR)
      RETURN VARCHAR2;
      
 FUNCTION get_claim_payment_date (v_claim_no VARCHAR,v_amt NUMBER,v_date date,v_date_type VARCHAR default 'PAID'  )
      RETURN date;
      
--       FUNCTION get_voucher_payment_date (v_vou_no VARCHAR,v_date_type VARCHAR default 'PAID'  )
--      RETURN date;
--      
      FUNCTION get_mps_receipt_no (v_mps_code       VARCHAR)
      RETURN VARCHAR2;
      
      FUNCTION GET_AGENCY_HIERARCHY (V_AGENT_NO  number, v_level VARCHAR,d_type  VARCHAR  DEFAULT 'C' )
      RETURN VARCHAR2;
      
        FUNCTION policy_was_inforce
    (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE)
  RETURN VARCHAR2;
  FUNCTION get_agn_persistancy(v_date date, v_m_start number, v_m_end number, v_agn_no number) RETURN number;
  FUNCTION get_pol_stamp_duty(v_pol_no VARCHAR ) RETURN number;
  FUNCTION AGENT_NAME8 (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE) RETURN VARCHAR2;
  FUNCTION AGENT_NAME  (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE) RETURN VARCHAR2;
    FUNCTION get_contributions (v_pol_no varchar, v_date date)  RETURN number;
     FUNCTION is_new_prem (v_pol_no varchar, v_date date)  RETURN varchar;
      PROCEDURE process_commission_clawback;
       FUNCTION Get_Alteration_Text  (P_policy_no VARCHAR,P_alter_code  VARCHAR, P_quotation_id VARCHAR)
      RETURN VARCHAR;
      PROCEDURE process_bulk_emails_reports(  P_FROM_DATE Date,
                             P_TO_DATE    Date,
                             P_pmt_method_code Varchar2,
                             p_cntr_stat_code Varchar2,
                             p_report_name  varchar2,
                             P_USER      VARCHAR2 DEFAULT USER ,
                             P_PROG      VARCHAR2 DEFAULT 'PS_LTR_A05',
                             P_DATE      DATE default SYSDATE);
  FUNCTION Get_Policy_Nominees(P_policy_no  VARCHAR, V_TYPE VARCHAR DEFAULT 'N') RETURN VARCHAR;
  function Get_Policy_Plan_Discount ( P_policy_no  VARCHAR, Plan_Code VARCHAR) return Number;
  function  Modal_Prem_Formula (P_Policy_No  VARCHAR, p_poltype VARCHAR DEFAULT 'N') return Number;
  function  get_lapse_inforce_period (P_Policy_No  VARCHAR ) return Number;
  PROCEDURE populate_banca_yearly_com;
  
   FUNCTION test_trigger RETURN BOOLEAN;
 
 PROCEDURE profiler_control(
   start_stop IN VARCHAR2,
   run_comm IN VARCHAR2,
   ret OUT BOOLEAN) ;
function  get_policy_voucher_amount (P_Policy_No  VARCHAR, v_approved  VARCHAR ) return Number;
function  get_policy_status_user (P_Policy_No  VARCHAR, v_st  VARCHAR ) return VARCHAR;
function  get_policy_voucher_case (p_policy_No  VARCHAR, p_vou  VARCHAR ) return NUMBER;
FUNCTION GET_PREV_STATUS
    (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE)
  RETURN VARCHAR2;
      FUNCTION RIDER_PREMIUM
    (P_POLICY_NO IN VARCHAR2)
  RETURN NUMBER;
  
      FUNCTION DOB_TWO
    (P_POLICY_NO IN VARCHAR2)
  RETURN DATE;
  
     FUNCTION AGENT_PROD_FIRST_YEAR
    (P_AGENT_NO IN NUMBER, P_TYPE IN VARCHAR2)
  RETURN NUMBER;

  
    FUNCTION AGENT_PROD
    (P_AGENT_NO IN NUMBER, P_FM_DT IN DATE, P_TO_DT IN DATE, P_PERIOD IN VARCHAR2, P_TYPE IN VARCHAR2)
  RETURN NUMBER;
  
  FUNCTION AGENCY_NAME2
    (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
  RETURN VARCHAR2;
  
    FUNCTION AGENT_NAME3
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2;
   FUNCTION AGENT_NAME5
 (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
  RETURN VARCHAR2;
    FUNCTION AGENT_NAME6
 (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
  RETURN VARCHAR2;
      FUNCTION AGENT_NAME7
 (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
  RETURN VARCHAR2;
--  P_POLICY_NO  VARCHAR2 :=null;
   FUNCTION POLICY_APPROVAL_ANALYSIS(P_POLICY_NO VARCHAR) RETURN BOOLEAN;
   FUNCTION FIRST_DAY_OF_YEAR(v_date DATE) RETURN DATE;
     function  get_ri_amount ( p_amt_type VARCHAR , p_ri_policy_no VARCHAR, p_ri_quotation_id VARCHAR , p_reinsurer_code VARCHAR,   p_date  date ) return Number;
 function  get_ri_load_pct (p_ri_policy_no VARCHAR, p_ri_quotation_id VARCHAR ) return Number;
   PROCEDURE GENERATE_POL_AMOUNTS(v_pol_no VARCHAR);
        function get_amt_to_words(v_amt number)return Char;
        PROCEDURE GENERATE_POL_AMOUNTS_SUR(v_pol_no VARCHAR);
      END JHL_GEN_PKG;

/