----- check if voucher is ready to flow to OFA-----

SELECT  V_VOU_DESC,V_VOU_NO,D_VOU_DATE
FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR')   BETWEEN TO_DATE('01-JAN-18','DD/MM/RRRR')  AND TO_DATE(sysdate,'DD/MM/RRRR')/*checks date created*/
AND JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED(V_VOU_NO) = 'Y'/*checks if voucher is approved in ISF*/
AND  V_VOU_NO NOT IN (SELECT V_VOU_NO FROM JHL_OFA_PYMT_TRANSACTIONS)/*checks if in ISF staging table*/
AND JHL_GEN_PKG.IS_VOUCHER_CANCELLED(V_VOU_NO) = 'N'/*checks if user cancelled the vocher*/
and V_VOU_NO in ('2023005763');


------staging table for vochers in ISF-----
select *
  FROM JHL_OFA_PYMT_TRANSACTIONS
where V_VOU_NO = '2021011359';  



------ staging table for vochers in OFA (PROCESSED FROM FLAG 1 TO 4)-----
SELECT  * 
  FROM XXJICUG_AP_INVOICES_STG@JICOFPROD.COM 
WHERE OPERATING_UNIT = 'JHL_UG_LIF_OU'
AND VOUCHER_NUM  in ('2021010283');




------VIEW OR BASE TABLES IN OFA------
SELECT  *
FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
WHERE LOB_NAME =  'JHL_UG_LIF_OU'
and PAYMENT_VOUCHER  IN ('2021000941');


select * from JHL_OFA_VOUCHER_ERRORS where V_VOU_NO=2023005720;
edit GNDT_CUSTOMER_IDENTIFICATION where  N_CUST_REF_NO =177038;

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
                 AND  V_VOU_NO=2021000941
                );
                
                
---AP transactions staging table---
select * from  xxjicug_ap_invoices_stg@jicofprod.com  where /*operating_unit = 'JHL_UG_LIF_OU' and process_flag ='3' and*/ voucher_num = '2021010283';

update xxjicug_ap_invoices_stg@jicofprod.com set PROCESS_FLAG=1, ERROR_MESSAGE=null  where operating_unit = 'JHL_UG_LIF_OU' and process_flag ='3' and voucher_num = '2021002028';

edit PSMT_SMS_MASTER where N_SMS_CODE=220;


  select *
  from  APPS.gl_interface@JICOFPROD.COM