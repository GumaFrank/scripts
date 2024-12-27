WITH DATA AS(
SELECT m.V_POLAG_TYPE,m.d_posted_date,m.v_process_code, m.n_ref_no,m.v_docu_type, m.v_docu_ref_no,m.v_polag_no,d.v_giss_code, d.v_desc,d.v_gl_code,
V_ACCTGRP_CODE,V_PROD_ACCT_CODE,V_CHANNEL_ACCT_CODE,V_LOB_CODE,  V_BRANCH_CODE, M.V_LASTUPD_PROG, v_fund_code,
SUM(DECODE(V_TYPE,'D',N_AMT,-N_AMT))N_AMT, v_source_currency,N_CONVERSION_RATE ,
SUM(DECODE(V_TYPE,'D',N_SOURCE_AMOUNT,-N_SOURCE_AMOUNT))N_SOURCE_AMOUNT, m.v_journal_status ,M.V_LASTUPD_USER ,M.D_DATE
FROM GNMT_GL_MASTER   M, GNDT_GL_DETAILS  D, GNMM_PROCESS_MASTER P
--(select v_vou_no from pymt_vou_master WHERE NVL(V_MERGED_VOUCHER,'N')='N'
--    AND  v_vou_no IN (SELECT V_COLUMN1 FROM AMMT_GLOBAL_TEMP)
--UNION
--select B.v_vou_no from pymt_vou_master A,pymt_vou_master B  WHERE NVL(A.V_MERGED_VOUCHER,'N')='Y'
--AND B.V_MERGED_VOU_NO  =A.V_VOU_NO
--AND A.V_VOU_NO IN (SELECT V_COLUMN1 FROM AMMT_GLOBAL_TEMP)
--) VOU
WHERE M.N_REF_NO = D.N_REF_NO AND M.V_PROCESS_CODE = P.V_PROCESS_ID (+)
and m.v_polag_no='UG201700257323'
group by  m.V_POLAG_TYPE,m.v_polag_no,m.d_posted_date,m.v_process_code,m.n_ref_no,m.v_docu_type, m.v_docu_ref_no,m.v_polag_no,d.v_giss_code,d.v_desc,d.v_gl_code,m.v_journal_status,
V_ACCTGRP_CODE,V_PROD_ACCT_CODE,V_CHANNEL_ACCT_CODE,V_LOB_CODE ,V_BRANCH_CODE,M.V_LASTUPD_PROG ,v_source_currency,v_fund_code  ,M.V_LASTUPD_USER,N_CONVERSION_RATE ,M.D_DATE
order by m.n_ref_no)
SELECT * FROM DATA order by n_ref_no;