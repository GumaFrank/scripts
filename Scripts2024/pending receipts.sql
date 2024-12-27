-- Checking the Receipts and JV that qualify to flow to OFA 

 SELECT JHL_OGLT_NO_SEQ.NEXTVAL,M.N_REF_NO, M.D_DATE, NVL(V_BRANCH_CODE,'HO'), V_LOB_CODE, nvl(V_PROCESS_CODE,'N/A') V_PROCESS_CODE,nvl((SELECT V_PROCESS_NAME
                    FROM GNMM_PROCESS_MASTER
                    WHERE V_PROCESS_ID = V_PROCESS_CODE),nvl(V_PROCESS_CODE,'N/A')) V_PROCESS_NAME,V_DOCU_TYPE,V_DOCU_REF_NO,V_GL_CODE ,V_DESC ,V_TYPE, N_AMT,
                                                             
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
                    AND V_PROCESS_CODE NOT IN ('ACT021','RIACT01')
                    AND V_DOCU_REF_NO in ('HQ220186597','HQ220186612','HQ220186576','HQ220186488','HQ220186490');   



--staging table for JVs and receipts in ISF---
select *
from JHL_OFA_GL_TRANSACTIONS 
where V_DOCU_REF_NO in  ('HQ220186597','HQ220186612','HQ220186576','HQ220186488','HQ220186490');

-- this is final staging table before pushing to ofa staging -------
SELECT *
FROM JHL_OFA_GL_INTERFACE
WHERE  REFERENCE1 in  ('HQ220186597','HQ220186612','HQ220186576','HQ220186488','HQ220186490');

 


----- OFA staging table for receipts -----
SELECT *
FROM APPS.gl_interface@JICOFPROD.COM
WHERE REFERENCE1 in  ('HQ220186597','HQ220186612','HQ220186576','HQ220186488','HQ220186490');

------ofa view for recepits and JV to confirm hat has flon successfully----

select  *
FROM APPS.XXJIC_ISF_JOURNALS_V@JICOFPROD.COM
WHERE 1=1
and ( BATCH_NAME LIKE  '%HQ220186490%'  )
and CURRENCY_CODE = 'UGX';

 SELECT * FROM apps.xxjic_gl_interface@jicofprod.com WHERE REFERENCE1 in ('HQ220186597','HQ220186612','HQ220186576','HQ220186488','HQ220186490');
 
 
