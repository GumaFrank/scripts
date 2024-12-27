/* 
Author Frank Bagambe
Date 08-OCT-2024
Description
The Receivable for  go AML (Rquested by Immaculate 

 */
  SELECT V_Receipt_No transactionnumber,
         DECODE (Rct.V_Receipt_Code,
                 'RCT002', 'Policy Premium',
                 'RCT003', 'Proposal Deposit',
                 'RCT004', 'Loan Repayment',
                 'RCT100', 'Policy Premium',
                 'RCT001', 'Policy Premium',
                 'RCT012', 'Scheme Premium',
                 (SELECT Rc.V_Receipt_Desc
                    FROM Remm_Receipt_Code Rc
                   WHERE Rc.V_Receipt_Code = Rct.V_Receipt_Code))
            transaction_description,
         TO_DATE (D_Receipt_Date, 'DD/MM/RRRR') date_transaction,
         'EFT' AS transmode_code,
         N_Receipt_Amt Receipt_Amount,
         'EFT' AS from_funds_code,
         NVL (
            Cust.V_Name,
            (SELECT V_Company_Name
               FROM Gnmm_Company_Master C
              WHERE     C.V_Company_Code = Rct.V_Company_Code
                    AND C.V_Company_Branch = Rct.V_Company_Branch))
            fIRST_NAME,
         NVL (
            Cust.V_Name,
            (SELECT V_Company_Name
               FROM Gnmm_Company_Master C
              WHERE     C.V_Company_Code = Rct.V_Company_Code
                    AND C.V_Company_Branch = Rct.V_Company_Branch))
            LAST_NAME,
         NVL (
            Cust.D_BIRTH_DATE,
            (SELECT D_BIRTH_DATE
               FROM Gnmm_Company_Master C
              WHERE     C.V_Company_Code = Rct.V_Company_Code
                    AND C.V_Company_Branch = Rct.V_Company_Branch))
            DATE_OF_BIRTH,
         NVL (
            Cust.V_NATION_CODE,
            (SELECT CompAddr.V_STATE_CODE
               FROM GNDT_COMPANY_ADDRESS CompAddr
              WHERE CompAddr.V_COMPANY_CODE = Rct.V_Company_Code AND ROWNUM = 1))
            AS Nationality,
         'MOB' AS tph_communication_type,
         NULL AS tph_communication_type2,
         -- Add mobile number
         NVL (
            (SELECT CM.V_CONTACT_NUMBER
               FROM GNDT_CUSTMOBILE_CONTACTS CM
              WHERE     CM.N_CUST_REF_NO = Cust.N_CUST_REF_NO
                    AND CM.V_CONTACT_CODE = 'CONT010'
                    AND ROWNUM = 1),
            (SELECT MAX (V_Contact_Number)
               FROM Gndt_Compmobile_Contacts H
              WHERE H.V_Company_Code = Rct.V_Company_Code AND ROWNUM = 1 --AND H.V_Company_Branch = CO.V_Company_Branch
                    AND V_Contact_Number NOT LIKE '%@%'))
            AS Mobile_Number,
         'PER' AS address_type,
         NVL (
            (SELECT Addr.V_ADD_ONE
               FROM GNDT_CUSTOMER_ADDRESS Addr
              WHERE Addr.N_CUST_REF_NO = Cust.N_CUST_REF_NO AND ROWNUM = 1),
            (SELECT CompAddr.V_ADD_ONE
               FROM GNDT_COMPANY_ADDRESS CompAddr
              WHERE CompAddr.V_COMPANY_CODE = Rct.V_Company_Code AND ROWNUM = 1))
            AS Address,
         NVL (
            (SELECT Addr.V_ADD_ONE
               FROM GNDT_CUSTOMER_ADDRESS Addr
              WHERE Addr.N_CUST_REF_NO = Cust.N_CUST_REF_NO AND ROWNUM = 1),
            (SELECT CompAddr.V_ADD_ONE
               FROM GNDT_COMPANY_ADDRESS CompAddr
              WHERE CompAddr.V_COMPANY_CODE = Rct.V_Company_Code AND ROWNUM = 1))
            AS Address_2,
         NVL (
            (SELECT Addr.V_STATE_CODE
               FROM GNDT_CUSTOMER_ADDRESS Addr
              WHERE Addr.N_CUST_REF_NO = Cust.N_CUST_REF_NO AND ROWNUM = 1),
            (SELECT CompAddr.V_STATE_CODE
               FROM GNDT_COMPANY_ADDRESS CompAddr
              WHERE CompAddr.V_COMPANY_CODE = Rct.V_Company_Code AND ROWNUM = 1))
            AS country_code,
         -- Add email address
         NVL (
            (SELECT CM.V_CONTACT_NUMBER
               FROM GNDT_CUSTMOBILE_CONTACTS CM
              WHERE     CM.N_CUST_REF_NO = Cust.N_CUST_REF_NO
                    AND CM.V_CONTACT_CODE = 'CONT003'
                    AND ROWNUM = 1),
            (SELECT LOWER (MAX (V_Contact_Number))
               FROM Gndt_Compmobile_Contacts H
              WHERE     H.V_Company_Code = Rct.V_Company_Code
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
           WHERE     ID.N_CUST_REF_NO = Cust.N_CUST_REF_NO
                 AND ID.V_IDEN_CODE = 'NIC'
                 AND ROWNUM = 1)
            AS Identification_type,
         -- Add Identification Number
         (SELECT ID.V_IDEN_NO
            FROM GNDT_CUSTOMER_IDENTIFICATION ID
           WHERE     ID.N_CUST_REF_NO = Cust.N_CUST_REF_NO
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
    FROM Remt_Receipt Rct,
         Remt_Receipt_Instruments Rct_Ins,
         Unmm_Currency_Master Cur,
         Remm_Instrument Ins,
         Gnmt_Customer_Master Cust,
         Gnmm_Company_Master Banks
   WHERE     Rct.N_Receipt_Session = Rct_Ins.N_Receipt_Session
         AND Rct.V_Currency_Code = Cur.V_Currency_Code
         AND Rct_Ins.V_Ins_Code = Ins.V_Ins_Code
         AND Rct.N_Cust_Ref_No = Cust.N_Cust_Ref_No(+)
         AND Rct_Ins.V_Ins_Bank = Banks.V_Company_Code(+)
         AND Rct_Ins.V_Ins_Bank_Branch = Banks.V_Company_Branch(+)
         AND V_Receipt_Table = 'DETAIL'
         AND N_Receipt_Amt >= 20000000
         AND TRUNC (D_Receipt_Date) BETWEEN (:P_FromDate) AND (:P_ToDate)
         AND UPPER (NVL (Rct.V_Receipt_Remarks, 'XXXXX')) NOT LIKE '%OFFLINE%'
ORDER BY 3 DESC;