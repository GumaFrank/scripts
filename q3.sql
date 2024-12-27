/*
Author Frank Bagambe
Date 04-OCT-2024
Description 
3.    Query for getting PD Amount ( Input is policy number)

 N_AMOUNT is the PD Amount 


*/

SELECT E.V_Name Assured_Name,
       A.V_Policy_No,
       (SELECT V_Iden_No
          FROM Gndt_Customer_Identification K
         WHERE     V_Iden_Code = 'NIC'
               AND N_Cust_Ref_No = B.N_Payer_Ref_No
               AND ROWNUM = 1)
          National_Id,
       (SELECT V_Iden_No
          FROM Gndt_Customer_Identification
         WHERE     V_Iden_Code = 'PIN'
               AND N_Cust_Ref_No = B.N_Payer_Ref_No
               AND ROWNUM = 1)
          Kra_Pin,
       (SELECT V_Contact_Number
          FROM Gndt_Custmobile_Contacts
         WHERE     N_Cust_Ref_No = B.N_Payer_Ref_No
               AND V_Contact_Number NOT LIKE '%@%'
               AND V_Status = 'A'
               AND ROWNUM = 1)
          V_Contact_Number,
       F.V_Name Policy_Owner,
       V_Type,
       B.N_Contribution,
       N_Amount,
       B.V_Cntr_Stat_Code,
       V_Status_Desc,
       B.V_Lastupd_User,
       B.D_Prem_Due_Date,
       B.D_Next_Out_Date,
       B.D_Commencement,
       B.D_Policy_End_Date,
       Jhl_Utils.Agent_Name (D.N_Agent_No) Agent
  FROM Ppmt_Overshort_Payment A,
       Gnmt_Policy B,
       Gnmm_Policy_Status_Master C,
       Ammt_Pol_Ag_Comm D,
       Gnmt_Policy_Detail E,
       Gnmt_Customer_Master F
 WHERE     A.V_Policy_No = B.V_Policy_No
       AND A.V_Policy_No = E.V_Policy_No
       AND C.V_Status_Code = B.V_Cntr_Stat_Code
       AND B.V_Policy_No = D.V_Policy_No
       AND B.N_Payer_Ref_No = F.N_Cust_Ref_No
       AND V_Role_Code = 'SELLING'
       AND D.V_Status = 'A'
       AND N_Amount > 0
       AND A.V_Policy_No = :policy_number -- Input policy number
       AND A.V_Policy_No NOT LIKE 'GL%'
UNION ALL
  SELECT E.V_Name Assured_Name,
         A.V_Policy_No,
         (SELECT V_Iden_No
            FROM Gndt_Customer_Identification K
           WHERE     V_Iden_Code = 'NIC'
                 AND N_Cust_Ref_No = B.N_Payer_Ref_No
                 AND ROWNUM = 1)
            National_Id,
         (SELECT V_Iden_No
            FROM Gndt_Customer_Identification
           WHERE     V_Iden_Code = 'PIN'
                 AND N_Cust_Ref_No = B.N_Payer_Ref_No
                 AND ROWNUM = 1)
            Kra_Pin,
         (SELECT V_Contact_Number
            FROM Gndt_Custmobile_Contacts
           WHERE     N_Cust_Ref_No = B.N_Payer_Ref_No
                 AND V_Contact_Number NOT LIKE '%@%'
                 AND V_Status = 'A'
                 AND ROWNUM = 1)
            V_Contact_Number,
         F.V_Name Policy_Owner,
         'O' V_Type,
         B.N_Contribution,
         SUM (N_Amount) N_Amount,
         B.V_Cntr_Stat_Code,
         V_Status_Desc,
         B.V_Lastupd_User,
         B.D_Prem_Due_Date,
         B.D_Next_Out_Date,
         B.D_Commencement,
         B.D_Policy_End_Date,
         Jhl_Utils.Agent_Name (D.N_Agent_No) Agent
    FROM Ppdt_Proposal_Deposit A,
         Gnmt_Policy B,
         Gnmm_Policy_Status_Master C,
         Ammt_Pol_Ag_Comm D,
         Gnmt_Policy_Detail E,
         Gnmt_Customer_Master F
   WHERE     A.V_Policy_No = B.V_Policy_No
         AND A.V_Policy_No = E.V_Policy_No
         AND C.V_Status_Code = B.V_Cntr_Stat_Code
         AND B.V_Policy_No = D.V_Policy_No
         AND B.N_Payer_Ref_No = F.N_Cust_Ref_No
         AND V_Role_Code = 'SELLING'
         AND D.V_Status = 'A'
         AND A.V_Policy_No = :policy_number -- Input policy number
         AND A.V_Policy_No NOT LIKE 'GL%'
         AND A.V_Status = 'A'
GROUP BY E.V_Name,
         A.V_Policy_No,
         B.N_Payer_Ref_No,
         F.V_Name,
         B.N_Contribution,
         B.V_Cntr_Stat_Code,
         V_Status_Desc,
         B.V_Lastupd_User,
         B.D_Prem_Due_Date,
         B.D_Next_Out_Date,
         B.D_Commencement,
         B.D_Policy_End_Date,
         Jhl_Utils.Agent_Name (D.N_Agent_No);
