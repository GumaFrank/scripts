SELECT * FROM GNMT_CUSTOMER_MASTER;

SELECT GNMT_CUSTOMER_MASTER.V_NAME , GNMT_CUSTOMER_MASTER.N_CUST_REF_NOFROM GNMT_CUSTOMER_MASTER from ;

SELECT * FROM GNMT_POLICY where D_ISSUE is not null and D_DISPATCH_DATE is null order by V_POLICY_NO desc;


SELECT  GNMT_POLICY.V_POLICY_NO, GNMT_POLICY.N_PROPOSER_REF_NO GNMT_POLICY;

SELECT * FROM GNDT_CUSTMOBILE_CONTACTS;


SELECT GNDT_CUSTMOBILE_CONTACTS.V_CONTACT_NUMBER, GNDT_CUSTMOBILE_CONTACTS.N_CUST_REF_NO, GNMT_POLICY.V_POLICY_NO

FROM GNDT_CUSTMOBILE_CONTACTS, GNMT_POLICY

WHERE V_CONTACT_CODE IN ('CONT003', 'CONT010')




















































AND 
GNDT_CUSTMOBILE_CONTACTS.N_CUST_REF_NO=GNMT_POLICY.N_PROPOSER_REF_NO;