
/* Formatted on 23/01/2020 16:43:59 (QP5 v5.256.13226.35538) */
SELECT A.V_Policy_No,
       E.V_Name Policy_Name,
       C.V_Agent_Code,
       D.V_Name Agent_Name,
       N_Contribution,
       D_Prem_Upto Premium_Paid_Upto,
       DECODE (V_Pymt_Freq,
               '01', 'MONTHLY',
               '03', 'QUATERLY',
               '06', 'HALF_YEARLY',
               '12', 'YEARLY',
               'SINGLE_PREMIUM')
          Pay_Mode,
       D_Next_Due_Date,
       D_Prem_Due_Date,
       D_Revive Revival_Date,
       DECODE (V_Revival_Type, 'RV', 'REVIVAL', 'REDATE') Revival_Type
  FROM Psmt_Policy_Revival A,
       Ammt_Pol_Ag_Comm B,
       Ammm_Agent_Master C,
       Gnmt_Customer_Master D,
       Gnmt_Policy_Detail E,
       Psmt_Non_Payment_Termination F
 WHERE     A.V_Policy_No = B.V_Policy_No
       AND B.V_Role_Code = 'SELLING'
       AND B.V_Overriding = 'N'
       AND B.V_Status = 'A'
       AND B.N_Agent_No = C.N_Agent_No
       AND C.N_Cust_Ref_No = D.N_Cust_Ref_No
       AND A.V_Policy_No = E.V_Policy_No
       AND A.V_Policy_No = F.V_Policy_No
       --and a.V_POLICY_NO ='171340'
       AND D_Prem_Upto = (SELECT MAX (D_Prem_Upto)
                            FROM Psmt_Non_Payment_Termination M
                           WHERE M.V_Policy_No = A.V_Policy_No)
       --AND A.D_Revive BETWEEN :Pdate1 AND :Pdate2
       AND TRUNC (A.D_Revive) BETWEEN ( :P_FromDate) AND ( :P_ToDate)
--AND a.D_ISSUE_DATE BETWEEN '01-JAN-2016' AND '20-MAY-2016'