select * from apps.ap_invoices_all@JICOFPROD.COM  where org_id =295 --INVOICE_NUM ---LAST_UPDATE_DATE

select *   FROM JHL_OFA_PYMT_TRANSACTIONS --V_VOU_NO  V_VOU_DATE;

select DISTINCT V_VOU_NO from JHL_OFA_PYMT_TRANSACTIONS where to_char(V_VOU_DATE, 'MON-YYYY') ='SEP-2022'
minus
select DISTINCT invoice_num from apps.ap_invoices_all@JICOFPROD.COM 
where  to_char(INVOICE_DATE, 'MON-YYYY') ='SEP-2022' AND org_id =295

 select DISTINCT V_VOU_NO from JHL_OFA_PYMT_TRANSACTIONS where to_char(V_VOU_DATE, 'MON-YYYY') ='AUG-2022'
 AND  V_VOU_NO NOT IN ( select DISTINCT invoice_num from apps.ap_invoices_all@JICOFPROD.COM 
where  to_char(INVOICE_DATE, 'MON-YYYY') ='AUG-2022' AND org_id =295)


select * from JHL_OFA_GL_TRANSACTIONS where V_DOCU_REF_NO ='HQ220147186';
select * from apps.gl_interface@JICOFPROD.COM  where currency_code = 'UGX' --POLICY_PROP35952
SELECT * FROM apps.gl_je_lines@JICOFPROD.COM  where ledger_id =2088
;
select * from JHL_OFA_GL_TRANSACTIONS;


--payables 

 SELECT DISTINCT REFERENCE1 FROM JHL_OFA_GL_INTERFACE where REFERENCE1 NOT IN (
      SELECT REFERENCE1
    FROM apps.xxjic_gl_interface@jicofprod.com

    )
and
  TO_DATE(ACCOUNTING_DATE,'DD/MM/RRRR')   BETWEEN TO_DATE('01-DEC-22','DD/MM/RRRR')  AND TO_DATE('31-DEC-22','DD/MM/RRRR');


-- INVOICES IN isf AND not in OFA
select DISTINCT V_VOU_NO from JHL_OFA_PYMT_TRANSACTIONS where to_char(V_VOU_DATE, 'MON-YYYY') ='AUG-2022'
MINUS
select DISTINCT invoice_num from apps.ap_invoices_all@JICOFPROD.COM 
where  to_char(INVOICE_DATE, 'MON-YYYY') ='AUG-2022' AND org_id =295;


-- receipts in ISF and Not in OFA
select V_DOCU_REF_NO from  JHL_OFA_GL_TRANSACTIONS  WHERE TO_CHAR(OGLT_DATE, 'MON-YY') ='DEC-22' AND V_DOCU_REF_NO LIKE 'H%'
AND V_DOCU_TYPE ='RECEIPT'
AND V_DOCU_REF_NO NOT IN (
SELECT substr(DESCRIPTION,1,11) FROM  apps.GL_JE_LINES@JICOFPROD.COM 
WHERE PERIOD_NAME = 'DEC-22' AND ledger_id =2088)
;

select * from apps.xxjicug_gl_interface_stg7@JICOFPROD.COM;

select * from  APPS.GL_INTERFACE@JICOFPROD.COM where CURRENCY_CODE='UGX' order by ACCOUNTING_DATE desc;
                 