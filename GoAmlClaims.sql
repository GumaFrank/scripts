
/*
Author: Frank Bagambe
Date: 10-OCT-2024

Description
GoAML for claims 
*/
SELECT DISTINCT
       CLMS.V_CLAIM_NO,
       CLMS.CLAIM_TYPE,
       CLMS.D_CLAIM_DATE,
       CLMS.TRANSMODE_CODE,
       CLMS.N_VOU_AMOUNT,
       CLMS.FROM_FUNDS_CODE,
       --CLMS.V_CLIENT_NAME,
       --CLMS.V_POLICY_NO,
       --POL.V_POLICY_NO AS CUSTOMER_POLICY,
       --CUST.V_NAME
       NVL (CUST.V_Name,
            (SELECT V_Company_Name
               FROM Gnmm_Company_Master C
              WHERE POL.V_Company_Code = C.V_Company_Code))
          FIRST_NAME,
       NVL (CUST.V_Name,
            (SELECT V_Company_Name
               FROM Gnmm_Company_Master C
              WHERE POL.V_Company_Code = C.V_Company_Code))
          Last_NAME,
       NVL (CUST.D_BIRTH_DATE,
            (SELECT D_BIRTH_DATE
               FROM Gnmm_Company_Master C
              WHERE POL.V_Company_Code = C.V_Company_Code))
          DATE_OF_BIRTH,
       NVL (
          CUST.V_NATION_CODE,
          (SELECT CompAddr.V_STATE_CODE
             FROM GNDT_COMPANY_ADDRESS CompAddr
            WHERE POL.V_Company_Code = CompAddr.V_Company_Code AND ROWNUM = 1))
          AS Nationality,
       'MOB' AS tph_communication_type,
       NULL AS tph_communication_type2,
       NVL (
          (SELECT CM.V_CONTACT_NUMBER
             FROM GNDT_CUSTMOBILE_CONTACTS CM
            WHERE     CM.N_CUST_REF_NO = POL.N_PAYER_REF_NO
                  AND CM.V_CONTACT_CODE = 'CONT010'
                  AND ROWNUM = 1),
          (SELECT MAX (V_Contact_Number)
             FROM Gndt_Compmobile_Contacts H
            WHERE     H.V_Company_Code = POL.V_Company_Code
                  AND ROWNUM = 1
                  AND V_Contact_Number NOT LIKE '%@%'))
          AS Mobile_Number,
       'PER' AS address_type,
       NVL (
          (SELECT Addr.V_ADD_ONE
             FROM GNDT_CUSTOMER_ADDRESS Addr
            WHERE Addr.N_CUST_REF_NO = POL.N_PAYER_REF_NO AND ROWNUM = 1),
          (SELECT CompAddr.V_ADD_ONE
             FROM GNDT_COMPANY_ADDRESS CompAddr
            WHERE CompAddr.V_COMPANY_CODE = POL.V_Company_Code AND ROWNUM = 1))
          AS Address,
       NVL (
          (SELECT Addr.V_ADD_ONE
             FROM GNDT_CUSTOMER_ADDRESS Addr
            WHERE Addr.N_CUST_REF_NO = POL.N_PAYER_REF_NO AND ROWNUM = 1),
          (SELECT CompAddr.V_ADD_ONE
             FROM GNDT_COMPANY_ADDRESS CompAddr
            WHERE CompAddr.V_COMPANY_CODE = POL.V_Company_Code AND ROWNUM = 1))
          AS Address_2,
       NVL (
          (SELECT Addr.V_STATE_CODE
             FROM GNDT_CUSTOMER_ADDRESS Addr
            WHERE Addr.N_CUST_REF_NO = POL.N_PAYER_REF_NO AND ROWNUM = 1),
          (SELECT CompAddr.V_STATE_CODE
             FROM GNDT_COMPANY_ADDRESS CompAddr
            WHERE CompAddr.V_COMPANY_CODE = POL.V_Company_Code AND ROWNUM = 1))
          AS country_code,
       NVL (
          (SELECT CM.V_CONTACT_NUMBER
             FROM GNDT_CUSTMOBILE_CONTACTS CM
            WHERE     CM.N_CUST_REF_NO = POL.N_PAYER_REF_NO
                  AND CM.V_CONTACT_CODE = 'CONT003'
                  AND ROWNUM = 1),
          (SELECT LOWER (MAX (V_Contact_Number))
             FROM Gndt_Compmobile_Contacts H
            WHERE     H.V_Company_Code = POL.V_Company_Code
                  AND ROWNUM = 1
                  AND V_Contact_Number LIKE '%@%'))
          AS Email_Address,
       NVL (Cust.V_EMPLOYER_NAME, 'SELF') EMPLOYER_NAME,
       NULL AS employer_address_type,
       NULL AS address,
       NULL AS employer_city,
       'UG' AS EMPLOYER_country_code,
       NULL AS employer_phone_iD,
       NULL AS tph_communication_type,
       NULL AS tph_number,
       (SELECT ID.V_IDEN_CODE
          FROM GNDT_CUSTOMER_IDENTIFICATION ID
         WHERE     ID.N_CUST_REF_NO = POL.N_PAYER_REF_NO
               AND ID.V_IDEN_CODE = 'NIC'
               AND ROWNUM = 1)
          AS Identification_type,
       (SELECT ID.V_IDEN_NO
          FROM GNDT_CUSTOMER_IDENTIFICATION ID
         WHERE     ID.N_CUST_REF_NO = POL.N_PAYER_REF_NO
               AND ID.V_IDEN_CODE = 'NIC'
               AND ROWNUM = 1)
          AS IDENTIFICATION_NUMBER,
       'UG' AS issue_country,
       'UG' AS from_country,
       'EFT' AS to_funds_code,
       'Jubilee Life Insurance' AS to_entity,
       'PVT' AS incorporation_legal_form,
       '187577' AS incorporation_number,
       'INSURANCE' AS business,
       'WORK' AS ph_contact_type,
       NULL AS tph_communication_type,
       '256414336770' AS tph_number,
       'WORK' AS address_type,
       'Kampala' AS director_city,
       '7122' AS address,
       'Kampala' AS city,
       'UG' AS country_code,
       'UG' AS incorporation_country_code,
       'Kumar' AS director_id_first_name,
       'Sumit Guarav' AS director_id_first_name,
       '10-FEB-1976' AS director_id_birthdate,
       'INDIA' AS director_id_nationality1,
       'WORK' AS address_type,
       '7122' AS address,
       'UG' AS country_code,
       'CEO' AS occupation,
       'EMPLOYMENT' AS source_of_wealth,
       'CEO' AS DIRECTOR_ROLE,
       '13-AUG-2014' AS incorporation_date,
       'UG' AS to_country
  FROM GNMT_POLICY POL,
       Gnmt_Customer_Master CUST,
       -- Gnmm_Company_Master Banks,
       (SELECT DISTINCT
               A.V_CLAIM_NO,
               V_DESCRIPTION CLAIM_TYPE,
               A.D_CLAIM_DATE,
               'EFT' AS transmode_code,
               NVL (GROSS_PAID, 0) GROSS_PAID,
               'EFT' AS from_funds_code,
               A.V_CLIENT_NAME,
               --V_NAME as First_name,
               --V_NAME as Last_name,
               -- add  DATE_OF_BIRTH
               --Add mobile number

               D.V_POLICY_NO,
               D_CNTR_START_DATE,
               D_PREM_PAYING_END_DATE,
               N_CONTRIBUTION,
               N_TERM,
               M.V_PLAN_DESC,
               N_IND_SA,
               V_STATUS_DESC CLAIM_STATUS,
               NVL (N_AMOUNT_PAYABLE, 0) CLAIM_PROV,
               NVL (N_PROV_AMOUNT, 0) BONUS_PROV,
                 NVL (N_AMOUNT_PAYABLE, 0)
               + NVL (N_PROV_AMOUNT, 0)
               - NVL (GROSS_PAID, 0)
                  CLAIM_OS,
               D_EVENT_DATE,
               A.V_LASTUPD_USER,
               V_PAYEE_NAME,
               V_VOU_NO,
               D_VOU_DATE,
               N_VOU_AMOUNT,
               V_CHQ_NO,
               V_CONTACT_NUMBER
          FROM CLMT_CLAIM_MASTER A,
               CLLU_TYPE_MASTER B,
               CLMM_STATUS_MASTER C,
               CLDT_CLAIM_EVENT_POLICY_LINK D,
               CLDT_PROVISION_MASTER E,
               CLDT_BONUS_PROVISION F,
               GNMT_POLICY_DETAIL G,
               GNMM_PLAN_MASTER M,
               GNDT_CUSTMOBILE_CONTACTS N,
               (SELECT DISTINCT V_CLAIM_NO, D_EVENT_DATE
                  FROM CLDT_CLAIM_EVENT_LINK) H,
               (SELECT V_SOURCE_REF_NO,
                       V_VOU_NO,
                       NULL V_MAIN_VOU_NO,
                       V_VOU_SOURCE,
                       D_VOU_DATE,
                       N_VOU_AMOUNT,
                       V_CHQ_NO,
                       V_PAYEE_NAME
                  FROM PYMT_VOUCHER_ROOT A, PYMT_VOU_MASTER B
                 WHERE     A.V_MAIN_VOU_NO = B.V_MAIN_VOU_NO
                       AND V_VOU_SOURCE = 'CLAIMS') I,
               (  SELECT V_CLAIM_NO, SUM (N_CLAIMANT_AMOUNT) GROSS_PAID
                    FROM CLDT_CLAIMANT_MASTER
                GROUP BY V_CLAIM_NO) J
         WHERE     D.V_CLAIM_TYPE = B.V_CLAIM_TYPE(+)
               AND A.V_CLAIM_STATUS = C.V_STATUS_CODE
               AND A.V_CLAIM_NO = D.V_CLAIM_NO
               AND D.V_CLAIM_NO = E.V_CLAIM_NO(+)
               AND D.N_SUB_CLAIM_NO = E.N_SUB_CLAIM_NO(+)
               AND D.V_CLAIM_NO = F.V_CLAIM_NO(+)
               AND D.N_SUB_CLAIM_NO = F.N_SUB_CLAIM_NO(+)
               AND D.V_POLICY_NO = G.V_POLICY_NO
               AND D.N_SEQ_NO = G.N_SEQ_NO
               AND A.V_CLAIM_NO = H.V_CLAIM_NO
               AND A.V_CLAIM_NO = I.V_SOURCE_REF_NO(+)
               AND A.V_CLAIM_NO = J.V_CLAIM_NO(+)
               AND G.V_PLAN_CODE = M.V_PLAN_CODE
               AND G.V_PLAN_CODE = D.V_PLRI_CODE
               AND G.N_CUST_REF_NO = N.N_CUST_REF_NO(+)
               AND N.V_CONTACT_NUMBER(+) LIKE '0%'
               AND TRUNC (D_CLAIM_DATE) BETWEEN NVL (:P_FM_DT,
                                                     TRUNC (D_CLAIM_DATE))
                                            AND NVL (:P_TO_DT,
                                                     TRUNC (D_CLAIM_DATE))
               AND V_VOU_NO IS NOT NULL
               AND N_VOU_AMOUNT >= 20000000--AND D.V_POLICY_NO NOT LIKE 'GL%'
       ) CLMS
 WHERE     CLMS.V_POLICY_NO = POL.V_POLICY_NO
       AND POL.N_PAYER_REF_NO = CUST.N_CUST_REF_NO