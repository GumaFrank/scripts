 
/*RECEIPTS N JVS IN ERROR*/
 SELECT *
   FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
    WHERE M.N_REF_NO = D.N_REF_NO
    AND nvl(M.V_JOURNAL_STATUS,'E') <> 'C'
    AND NVL(M.V_REMARKS,'N') != 'X'
    AND V_DOCU_TYPE !='VOUCHER'
    AND V_PROCESS_CODE NOT IN ('ACT021','RIACT01', 'ACT070','ACT071','PY_APR_RI','PY_VRC_RI')
  AND TO_DATE(M.D_DATE,'DD/MM/RRRR') BETWEEN TO_DATE('01-JAN-21','DD/MM/RRRR')  AND TO_DATE(SYSDATE,'DD/MM/RRRR') 
  AND M.N_REF_NO NOT IN  ( SELECT ORT.N_REF_NO FROM JHL_OFA_GL_TRANSACTIONS ORT WHERE ORT.N_REF_NO =M.N_REF_NO);
  
  /*NOT FLOWN DUE TO MISSING ACCOUNT MAPPING*/
   SELECT *
   FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
    WHERE M.N_REF_NO = D.N_REF_NO
    AND nvl(M.V_JOURNAL_STATUS,'E') <> 'C'
    AND NVL(M.V_REMARKS,'N') != 'X'
    AND V_DOCU_TYPE !='VOUCHER'
    AND V_PROCESS_CODE NOT IN ('ACT021','RIACT01', 'ACT070','ACT071','PY_APR_RI','PY_VRC_RI')
  AND M.N_REF_NO  IN  ( SELECT B.N_REF_NO FROM JHL_OFA_ISF_MIS_MAP B WHERE B.N_REF_NO =M.N_REF_NO);
  
  
  SELECT *
  FROM JHL_OFA_ISF_MIS_MAP;
  
  desc JHL_OFA_ISF_MIS_MAP
  
  -- after fixing the errors
  -- run the procedure
execute  JHL_OFA_UTILS.ofa_gl_trans_proc  ;


-- check  the staging of Oracle
select * from apps.gl_interface@jicofprod.com 


--  mapping table
SELECT * FROM JHL_ISF_OFA_ACC_MAP;



