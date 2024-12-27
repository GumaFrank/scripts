SELECT * FROM APPS.HZ_PARTIES@JICOFPROD.COM WHERE ATTRIBUTE1='CF85031102P95K';
SELECT * FROM apps.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM where PIN_NO ='1000027793';
SELECT * FROM apps.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM where VENDOR_NAME = 'NDAGIRE PROSSY';

update XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM set OPERATING_UNIT='JHL_UG_LIF_OU' where VENDOR_NAME = 'OKELLO BERNARD WEREH';
update   XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM  set PROCESS_FLAG=1,ERROR_MESSAGE=NULL  where VENDOR_SITE_CODE IN ('UI202100654755');
 
SELECT * FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM  where VENDOR_NAME = 'OKELLO BERNARD WEREH';
SELECT * FROM   XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM   where VENDOR_SITE_CODE IN ('UI202100654755');
2023001094

SELECT * FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM WHERE LEGACY_REF1 ='CM81042100VFCK';


exec JHL_OFA_UTILS.CREATE_INDIVIDUAL_SUPPLIER_NEW(251363);
 

 
 select * from  Gnmm_Company_Master;
 
 select * from  xxjicug_ap_invoices_stg@jicofprod.com  where operating_unit = 'JHL_UG_LIF_OU'  and voucher_num = '2021000957'; --and process_flag ='3'

---AP transactions staging table---
select * from  xxjicug_ap_invoices_stg@jicofprod.com  where operating_unit = 'JHL_UG_LIF_OU' and process_flag ='3' --and voucher_num = '2021000957';
 
 select * from apps.hz_parties@jicofprod.com where attribute1='CF85031102P95K';
 
  select * from  XXJICug_AP_SUPPLIER_SITE_STG@jicofprod.com   where legacy_ref1 ='CM81042100VFCK'  ;
  
   SELECT * FROM  XXJICUG_AP_SUPPLIER_CONCT_STG@jicofprod.com where legacy_ref1 ='CM81042100VFCK'
  
 select * from   XXJICUG_AP_SUPPLIER_STG@jicofprod.com  where legacy_ref1 ='CM81042100VFCK';
 
 
 DESC apps.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM ;
SELECT * FROM  apps.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM  WHERE VENDOR_SITE_CODE = 'UI202100654755';

select * from apps.ap_invoices_all@jicofprod.com where INVOICE_NUM ='2021000941'

select * from PPMT_OUTSTANDING_PREMIUM order;



 