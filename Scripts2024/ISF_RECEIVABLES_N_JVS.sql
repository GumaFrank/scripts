select * from apps.gl_interface@JICOFPROD.COM where reference1 like '%HQ200014010%'

select * from APPS.XXJIC_ISF_JOURNALS_V@JICOFPROD.COM  where reference1 like '%HQ20007%'

select * from apps.xxjic_isf_journals_v@jicofprod.com where reference1 like '%HQ20007%';



-- checking receipts in the OFA
select  *
FROM APPS.XXJIC_ISF_JOURNALS_V@JICOFPROD.COM
WHERE 1=1
and ( BATCH_NAME LIKE  '%HQ200014010%' )
and CURRENCY_CODE = 'UGX';


JHL_OFA_UTILS.ofa_gl_trans_proc ; -- pushing receipts and JVS (recievables) to OF

--CHECK FINAL TABLE BEFORE PUSHING TO OFA   
 SELECT * FROM JHL_OFA_GL_INTERFACE
          WHERE 1 = 1 
                AND OGLI_PROCESSED = 'Y' AND OGLI_POSTED = 'N';
                
              
          --LAST PROCEDUERE THAT PUSHES RECIEPTS TO OFA
          
          EXEC JHL_OFA_UTILS.SEND_GL_TRANS_TO_OFA;
            
 --last ISF staging table before pushing to ffa
  update  JHL_OFA_GL_INTERFACE  set OGLI_PROCESSED = 'Y', OGLI_POSTED = 'N' WHERE REFERENCE1 in ('HQ210159158',
'HQ210159159',
'HQ210159080',
'HQ210151486',
'HQ210185658',
'HQ210185659',
'HQ210185657',
'HQ210159081',
'HQ210192807',
'HQ210185660',
'HQ210169650');
  
  --last isf staging for JVs
  select * from JHL_OFA_NON_RCT_GL_INTER where  REFERENCE1 in ('HQ210159158');


JHL_OFA_GL_TRANSACTIONS;


 
-- Checking the Receipts and JV that qualify to flow to OFA 

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
                    AND V_PROCESS_CODE NOT IN ('ACT021','RIACT01')
                    --and m.V_REMARKS = 'SUN_JV_0000058485'
                    AND V_DOCU_REF_NO = 'HQ200149164'               
                 --   AND TO_DATE(M.D_DATE,'DD/MM/RRRR') BETWEEN '01-NOV-16' AND '01-NOV-16' 
--                     AND  M.N_REF_NO = 84567979
--                      AND M.N_REF_NO = I.N_REF_NO;
;



---account mapping in ISF interface---

SELECT * FROM JHL_ISF_OFA_ACC_MAP where ISF_GL_CODE='114601';

--- store all the accounts that are not mapped for JVs and receipts---
select *
from JHL_OFA_ISF_MIS_MAP;


--staging table for JVs and receipts in ISF---
select *
from JHL_OFA_GL_TRANSACTIONS 
where V_DOCU_REF_NO = 'HQ200149164';

-- this is for Reciepts
SELECT *
FROM JHL_OFA_GL_INTERFACE
WHERE  REFERENCE1 = 'HQ200149164' 
order by OGLI_NO asc;

SELECT *
FROM APPS.gl_interface@JICOFPROD.COM
WHERE REFERENCE1 = 'HQ200149164';


select  *
FROM APPS.XXJIC_ISF_JOURNALS_V@JICOFPROD.COM
WHERE 1=1
and ( BATCH_NAME LIKE  '%HQ210169650%'  )
and CURRENCY_CODE = 'UGX';