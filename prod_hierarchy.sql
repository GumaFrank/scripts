SELECT A.D_Proposal_Date,
       A.D_Issue,
       A.D_Commencement,
       A.V_Lastupd_User,
       A.V_Policy_No,
       B.V_Name Assured_Name,
       W.V_Iden_No,
       W.V_Name Beneficiary_Name,
       (SELECT V_Iden_No
          FROM Gndt_Customer_Identification
         WHERE     V_Iden_Code = 'PIN'
               AND N_Cust_Ref_No = A.N_Payer_Ref_No
               AND ROWNUM = 1)
          Kra_Pin,
       (SELECT V_Contact_Number
          FROM Gndt_Custmobile_Contacts
         WHERE     N_Cust_Ref_No = N_Payer_Ref_No
               AND V_Status = 'A'
               AND V_Contact_Number NOT LIKE '%@%'
               AND ROWNUM = 1)
          V_Contact_Number,
       Jhl_Utils.Agent_Name (C.N_Agent_No) Agent,
       (SELECT Jhl_Utils.Agent_Name (
                  SUM (DECODE (N_Manager_Level, 30, N_Manager_No, 0)))
                  Usm
          FROM Ammt_Agent_Hierarchy K
         WHERE K.N_Agent_No = C.N_Agent_No AND V_Status = 'A')
          Unit_Sales_Manager,
       (SELECT Jhl_Utils.Agent_Name (
                  SUM (DECODE (N_Manager_Level, 20, N_Manager_No, 0)))
                  Asm
          FROM Ammt_Agent_Hierarchy K
         WHERE K.N_Agent_No = C.N_Agent_No AND V_Status = 'A')
          Agency_Sales_Manager,
       (SELECT Jhl_Utils.Agent_Name (
                  SUM (DECODE (N_Manager_Level, 15, N_Manager_No, 0)))
                  Rsm
          FROM Ammt_Agent_Hierarchy K
         WHERE K.N_Agent_No = C.N_Agent_No AND V_Status = 'A')
          Regional_Sales_Manager,
       (SELECT Jhl_Utils.Agent_Name (
                  SUM (DECODE (N_Manager_Level, 10, N_Manager_No, 0)))
                  AS Nsm
          FROM Ammt_Agent_Hierarchy K
         WHERE K.N_Agent_No = C.N_Agent_No AND V_Status = 'A')
          National_Sales_Manager,
       N_Sum_Covered,
       B.N_Term,
       A.V_Pymt_Freq,
       V_Pymt_Desc,
       A.V_Pmt_Method_Code,
       V_Pmt_Method_Name,
       N_Original_Fcl,
       A.N_Contribution Total_Premium,
       DECODE (A.V_Pymt_Freq, 0, 1, 12 / A.V_Pymt_Freq) * A.N_Contribution
          Total_Annual_Prem,
       N_Ind_Basic_Prem Basic_Premium,
       DECODE (A.V_Pymt_Freq, 0, 1, 12 / A.V_Pymt_Freq) * B.N_Ind_Basic_Prem
          Basic_Annual_Prem,
       Jhl_Utils.Rider_Premium (A.V_Policy_No) Rider_Premium,
       N_Payer_Ref_No,
       F.V_Name Policy_Owner,
       Jhl_Utils.Get_Prev_Status (A.V_Policy_No) V_Prev_Status,
       A.V_Cntr_Stat_Code,
       V_Status_Desc V_Curr_Status,
       A.V_Plan_Code,
       V_Plan_Name,
       A.D_Next_Out_Date,
       N_Prem_Os,
       Num_Due,
       N_Receipt_Amt,
       A.D_Dispatch_Date,
       A.D_Acknowledge
  FROM Gnmt_Policy A,
       Gnmt_Policy_Detail B,
       Ammt_Pol_Ag_Comm C,
       Gnlu_Pay_Method D,
       Gnlu_Frequency_Master E,
       Gnmt_Customer_Master F,
       Gnmm_Policy_Status_Master G,
       Gnmm_Plan_Master H,
       Psmt_Policy_Beneficiary W,
       (SELECT X.V_Policy_No,
               N_Prem_Os,
               Num_Due,
               N_Receipt_Amt
          FROM (  SELECT V_Policy_No,
                         SUM (N_Amount) N_Prem_Os,
                         SUM (Num_Due) Num_Due
                    FROM (SELECT V_Policy_No,
                                 DECODE (V_Status, 'A', N_Amount, 0) N_Amount,
                                 DECODE (V_Status, 'A', 1, 0) Num_Due
                            FROM Ppmt_Outstanding_Premium --WHERE V_POLICY_NO = 'IL201200137132'
                                                         )
                GROUP BY V_Policy_No) X,
               (  SELECT V_Policy_No, SUM (N_Receipt_Amt) N_Receipt_Amt
                    FROM Remt_Receipt
                   WHERE     V_Receipt_Table = 'DETAIL'
                         AND V_Receipt_Status = 'RE001'
                         AND V_Receipt_Code IN ('RCT002', 'RCT003')
                GROUP BY V_Policy_No) Y
         WHERE X.V_Policy_No = Y.V_Policy_No(+) --AND x.v_policy_no = 'IL201200137132'
                                               ) I
 WHERE     A.V_Policy_No = B.V_Policy_No
       AND A.V_Policy_No = C.V_Policy_No
       AND A.V_Policy_No = W.V_Policy_No
       AND A.V_Pmt_Method_Code = D.V_Pmt_Method_Code
       AND A.V_Pymt_Freq = E.V_Pymt_Freq
       AND V_Role_Code = 'SELLING'
       AND C.V_Status = 'A'
       AND A.V_Policy_No NOT LIKE 'UG%'
       --AND D_ISSUE BETWEEN '01-JAN-2012' and '5-APR-2012'
       AND A.N_Payer_Ref_No = F.N_Cust_Ref_No
       AND A.V_Cntr_Stat_Code = G.V_Status_Code
       AND A.V_Plan_Code = H.V_Plan_Code
       AND A.V_Policy_No = I.V_Policy_No
       --AND a.v_policy_no = 'IL201200137132'
       AND (TRUNC (A.D_ISSUE)) BETWEEN ( :P_FM_DT) AND ( :P_TO_DT)