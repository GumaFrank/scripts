
DECLARE

CURSOR VOUCHERS IS 

SELECT  V_VOU_DESC,V_VOU_NO,D_VOU_DATE
FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR')   BETWEEN TO_DATE('01-JAN-22','DD/MM/RRRR')  AND TO_DATE(sysdate,'DD/MM/RRRR')
AND JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED(V_VOU_NO) = 'Y'
AND  V_VOU_NO NOT IN (SELECT V_VOU_NO FROM JHL_OFA_PYMT_TRANSACTIONS)
AND JHL_GEN_PKG.IS_VOUCHER_CANCELLED(V_VOU_NO) = 'N'
and V_VOU_NO in ('2019010013');

BEGIN

     FOR I IN VOUCHERS LOOP
                
                 JHL_OFA_UTILS.JHL_OFA_TRANSFORM_GL_VOU(I.V_VOU_NO);
                 commit;
       END LOOP;

END;
