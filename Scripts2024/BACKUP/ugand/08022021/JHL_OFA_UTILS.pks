CREATE OR REPLACE PACKAGE            JHL_OFA_UTILS AS 
PROCEDURE JHL_OFA_GL_VOUCHERS_NEW(v_voucher_no  VARCHAR2  );
PROCEDURE CREATE_INDIVIDUAL_SUPPLIER(v_cust_ref_no NUMBER, v_agent_no NUMBER DEFAULT NULL) ;
PROCEDURE CREATE_CORPORATE_SUPPLIER(company_code VARCHAR,company_branch VARCHAR, v_agent_no NUMBER DEFAULT NULL);
PROCEDURE JHL_OFA_PAYABLES_PROC;
PROCEDURE JHL_OFA_TRANSFORM_GL_VOU_PROC (v_voucher_no  VARCHAR2 );

FUNCTION BFN_GET_PAYEE_NAME(P_VOUCHER_NO VARCHAR2)
  RETURN VARCHAR2;
  PROCEDURE delete_supplier_master;
  PROCEDURE ofa_gl_trans_proc;
      PROCEDURE create_ofa_receivable_trans;
    PROCEDURE transform_ofa_receivable_trans;
   PROCEDURE transform_ofa_gl_trans;
    PROCEDURE SEND_GL_TRANS_TO_OFA;
     PROCEDURE log_voucher_error(vou_no varchar,v_error_msg varchar);
     PROCEDURE CREATE_INDIVIDUAL_SUPPLIER_NEW(v_cust_ref_no NUMBER, v_agent_no NUMBER DEFAULT NULL);
     PROCEDURE CREATE_CORPORATE_SUPPLIER_NEW(company_code VARCHAR,company_branch VARCHAR, v_agent_no NUMBER DEFAULT NULL);
     PROCEDURE JHL_OFA_TRANSFORM_GL_VOU (v_voucher_no  VARCHAR2 );
          PROCEDURE create_ofa_cancelled_pymt_gl ( voucher_no number default null);
       PROCEDURE transform_ofa_cancel_py_trans;
       PROCEDURE transform_ofa_py_gl_trans;
         PROCEDURE SEND_PYMT_GL_TRANS_TO_OFA;
         PROCEDURE UPDT_CHQ;
END JHL_OFA_UTILS;

/