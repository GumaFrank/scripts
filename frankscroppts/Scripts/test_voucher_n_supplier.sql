select *
 FROM JHL_OFA_PYMT_TRANSACTIONS
where trunc(OPT_DATE) = trunc(SYSDATE);
 V_VOU_NO = '2021000232';   


DELETE FROM JHL_OFA_PYMT_TRANSACTIONS
where V_VOU_NO  IN (
SELECT  DISTINCT VOUCHER_NUM
  FROM XXJICug_AP_INVOICES_STG@JICOFPROD.COM 
WHERE OPERATING_UNIT = 'JHL_UG_LIF_OU'
AND PROCESS_FLAG  in ( '1')
);   

SELECT  * --DISTINCT VOUCHER_NUM
  FROM XXJICug_AP_INVOICES_STG@JICOFPROD.COM 
WHERE OPERATING_UNIT = 'JHL_UG_LIF_OU'
AND PROCESS_FLAG  in ( '1')
AND VOUCHER_NUM  in ('2021000239');



 DELETE  FROM XXJICug_AP_INVOICES_STG@JICOFPROD.COM 
WHERE OPERATING_UNIT = 'JHL_UG_LIF_OU'
AND PROCESS_FLAG  in ( '1');
AND VOUCHER_NUM  in ('2021000239');

COMMIT;


SELECT  *
FROM JHL_OFA_VOUCHER_ERRORS
WHERE V_VOU_NO   IN ('2021000239');

SELECT JHL_BI_UTILS.CHECK_VALID_PIN('CM9206810186DH')
FROM  DUAL;


 SELECT *
 FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
WHERE PAY_GROUP LIKE '%LIFE%'
AND LEGACY_REF1 ='CM9206810186DH';

SELECT *
FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
WHERE PAY_GRP_LKP_CODE  LIKE '%LIFE%'
AND LEGACY_REF1 ='CM9206810186DH';

 SELECT *
FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM B
WHERE  B.LEGACY_REF1 ='CM9206810186DH';



EXEC JHL_OFA_UTILS_UPDATED.JHL_OFA_PAYABLES_PROC;
 commit;

DECLARE

CURSOR VOUCHERS IS 

SELECT  V_VOU_DESC,V_VOU_NO,D_VOU_DATE
FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR')   BETWEEN TO_DATE('01-JAN-21','DD/MM/RRRR')  AND TO_DATE(sysdate,'DD/MM/RRRR')
AND JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED(V_VOU_NO) = 'Y'
AND  V_VOU_NO NOT IN (SELECT V_VOU_NO FROM JHL_OFA_PYMT_TRANSACTIONS)
ORDER BY D_VOU_DATE DESC;
--and V_VOU_NO IN ('2021000239');


BEGIN

     FOR I IN VOUCHERS LOOP
                
                 JHL_OFA_UTILS_UPDATED.JHL_OFA_TRANSFORM_GL_VOU(I.V_VOU_NO);
                 commit;
       END LOOP;

END;





DELETE 
FROM JHL_OFA_PYMT_TRANSACTIONS
WHERE /*V_VOU_NO= '2018089524'
AND*/ V_VOU_NO NOT IN 
(
SELECT PAYMENT_VOUCHER
FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
WHERE/* PAYMENT_VOUCHER like  '%2018079222%' 
and  */LOB_NAME =  'JHL_UG_LIF_OU'
AND PAYMENT_VOUCHER  = V_VOU_NO

UNION ALL

SELECT  VOUCHER_NUM
FROM XXJICug_AP_INVOICES_STG@JICOFPROD.COM 
WHERE OPERATING_UNIT = 'JHL_UG_LIF_OU'
AND VOUCHER_NUM = V_VOU_NO
)
AND INVOICE_AMOUNT <> 0; 


begin

DELETE 
FROM JHL_OFA_PYMT_VOUCHER_DTLS
WHERE /*V_VOU_NO= '2018079222'
AND */V_VOU_NO NOT IN 
(
SELECT PAYMENT_VOUCHER
FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
WHERE/* PAYMENT_VOUCHER like  '%2018079222%' 
and  */LOB_NAME =  'JHL_UG_LIF_OU'
AND PAYMENT_VOUCHER  = V_VOU_NO

UNION ALL

SELECT  VOUCHER_NUM
FROM XXJICug_AP_INVOICES_STG@JICOFPROD.COM 
WHERE OPERATING_UNIT = 'JHL_UG_LIF_OU'
AND VOUCHER_NUM = V_VOU_NO
);
commit;
end;


commit;

-- ---vochers that have not flown with error----
SELECT DISTINCT  V_VOU_NO, OVE_DESC, V_GL_CODE, V_ACC_DESC, V_SUP_CODE
FROM JHL_OFA_VOUCHER_ERRORS
WHERE  V_VOU_NO  IN (

                SELECT  V_VOU_NO
                FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
                WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR')   BETWEEN TO_DATE('01-JAN-20','DD/MM/RRRR')  AND TO_DATE(sysdate,'DD/MM/RRRR')
                AND JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED(V_VOU_NO) = 'Y'
                AND JHL_GEN_PKG.IS_VOUCHER_CANCELLED(V_VOU_NO) = 'N'
                AND  V_VOU_NO NOT IN (SELECT V_VOU_NO FROM JHL_OFA_PYMT_TRANSACTIONS)
                
                );
--WHERE 
