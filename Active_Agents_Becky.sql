/* 
Author Eng Frank Bagambe Frank
Date:  08-SEP-2024
Description:  Extracting all Active Agents (Individual Active Agents )
Requestor: Becky Muwanga
 */
 
SELECT A.V_AGENT_CODE,
A.D_APPOINTMENT,
       B.V_NAME,
       A.V_RANK_CODE,
       A.V_STATUS,
       (SELECT V_AGENT_STATUS_DESC
          FROM Ammm_agent_status
         WHERE V_AGENT_STATUS_CODE = A.V_STATUS)
          Agent_status_descrption,
       -- Retrieve the SID identification number
       (SELECT V_IDEN_NO
          FROM Gndt_customer_identification CI_SID
         WHERE     CI_SID.N_CUST_REF_NO = A.N_CUST_REF_NO
               AND CI_SID.V_IDEN_CODE = 'SID'
               AND ROWNUM = 1)
          AS SID_ID,
       -- Retrieve the NIC identification number
       (SELECT V_IDEN_NO
          FROM Gndt_customer_identification CI_NIC
         WHERE     CI_NIC.N_CUST_REF_NO = A.N_CUST_REF_NO
               AND CI_NIC.V_IDEN_CODE = 'NIC'
               AND ROWNUM = 1)
          AS NIC_ID,
       -- Retrieve the PIN identification number
       (SELECT V_IDEN_NO
          FROM Gndt_customer_identification CI_PIN
         WHERE     CI_PIN.N_CUST_REF_NO = A.N_CUST_REF_NO
               AND CI_PIN.V_IDEN_CODE = 'PIN'
               AND ROWNUM = 1)
          AS PIN_ID,
       -- Retrieve the Email
       (SELECT Q.V_CONTACT_NUMBER
          FROM Gndt_custmobile_contacts Q
         WHERE     Q.N_CUST_REF_NO = A.N_CUST_REF_NO
               AND Q.V_CONTACT_NUMBER LIKE '%@%'
               AND ROWNUM = 1)
          AS EMAIL,
       -- Retrieve the Contact Number
       (SELECT Q.V_CONTACT_NUMBER
          FROM Gndt_custmobile_contacts Q
         WHERE     Q.N_CUST_REF_NO = A.N_CUST_REF_NO
               AND Q.V_CONTACT_NUMBER NOT LIKE '%@%'
               AND ROWNUM = 1)
          AS CONTACT_NUMBER
  FROM    Ammm_agent_master A
       JOIN
          Gnmt_customer_master B
       ON A.N_CUST_REF_NO = B.N_CUST_REF_NO
 WHERE A.V_AGENT_TYPE = 'I' AND A.V_STATUS = 'A'
 ORDER BY 2 DESC;
/