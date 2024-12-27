SELECT JHL_OGLT_NO_SEQ.NEXTVAL,M.N_REF_NO, M.D_DATE, NVL(V_BRANCH_CODE,'HO'), V_LOB_CODE, nvl(V_PROCESS_CODE,'N/A') V_PROCESS_CODE,nvl((SELECT V_PROCESS_NAME
                    FROM GNMM_PROCESS_MASTER
                    WHERE V_PROCESS_ID = V_PROCESS_CODE),nvl(V_PROCESS_CODE,'N/A')) V_PROCESS_NAME,V_DOCU_TYPE,V_DOCU_REF_NO,V_GL_CODE ,V_DESC ,V_TYPE, N_AMT,
                    /* NVL((select  distinct  OFA_ACC_CODE
                                             FROM JHL_OFA_RCT_ACC_MAP ACCS
                                             where ACCS.V_GL_CODE =  D.V_GL_CODE
                                             AND OFA_ACC_CODE IS NOT NULL
                                             and  ACCS.V_DESC = D.V_DESC
                                             ),'NA') OFA_ACC_CODE*/
                                             
                                         NVL( (
                                             SELECT  distinct OFA_ACC_CODE 
                                             FROM JHL_ISF_OFA_ACC_MAP
                                              WHERE TRIM(ISF_GL_CODE) = TRIM(D.V_GL_CODE) 
                                              AND TRIM(ACC_DESC) = TRIM(D.V_DESC)
                                             
                                             ),'N') OFA_ACC_CODE
                                             
                                             ,'UGX',
                                             M.V_POLAG_TYPE,
                                            M.V_POLAG_NO,
                                            M.D_POSTED_DATE,
                                            M.V_REMARKS
   FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
    WHERE M.N_REF_NO = D.N_REF_NO
    AND M.V_JOURNAL_STATUS = 'C'
    AND NVL(M.V_REMARKS,'N') != 'X'
    AND V_DOCU_TYPE !='VOUCHER'
    AND V_PROCESS_CODE NOT IN ('ACT021','RIACT01', 'ACT070','ACT071','PY_APR_RI','PY_VRC_RI')
  AND TO_DATE(M.D_DATE,'DD/MM/RRRR') BETWEEN TO_DATE('01-JAN-20','DD/MM/RRRR')  AND TO_DATE(SYSDATE,'DD/MM/RRRR') 
  AND M.N_REF_NO NOT IN  ( SELECT ORT.N_REF_NO FROM JHL_OFA_GL_TRANSACTIONS ORT WHERE ORT.N_REF_NO =M.N_REF_NO)
  and  V_DESC is null;
  
  
  SELECT *
  FROM JHL_OFA_ISF_MIS_MAP;  