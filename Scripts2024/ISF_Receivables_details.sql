
exec JHL_OFA_UTILS.ofa_gl_trans_proc;


-- Posted reciepts and JV per date in S_DATE
SELECT *
FROM JHL_OFA_GL_TRANSACTIONS
WHERE TRUNC(D_DATE) = TRUNC(SYSDATE-1)  
AND V_DOCU_TYPE = 'RECEIPT'
--AND  V_DOCU_TYPE = 'BILL'
--AND OFA_VGL_CODE = 'OFA_JV_2021_754748';
AND V_DOCU_REF_NO = 'HQ210018434';

-- add a column to document trasanasctions that have that have not posted
SELECT *
FROM JHL_OFA_ISF_MIS_MAP;

-- this is for Reciepts
SELECT *
FROM JHL_OFA_GL_INTERFACE
WHERE  REFERENCE1 = 'HQ220225907';

SELECT *
FROM APPS.gl_interface@JICOFPROD.COM
WHERE REFERENCE1 = 'HQ220225907';

-- this is for JVs
SELECT *
FROM JHL_OFA_NON_RCT_GL_INTER
WHERE REFERENCE1 = 'OFA_JV_2021_754748';

-- this for OFA interface
SELECT *
FROM APPS.gl_interface@JICOFPROD.COM
WHERE REFERENCE1 = 'OFA_JV_2021_754748';

SELECT * FROM APPS.xxjicug_gl_interface_stg7@JICOFPROD.COM;

APPS.XXJIC_ISF_JOURNALS_V@JICOFPROD.COM  -- view

select V_POLICY_NO,D_DISPATCH_DATE,D_ISSUE from gnmt_policy
where   TO_DATE(D_DISPATCH_DATE,'DD/MM/RRRR')   BETWEEN TO_DATE('01-JAN-23','DD/MM/RRRR')  AND TO_DATE('07-JAN-23','DD/MM/RRRR');

desc gnmt_policy;