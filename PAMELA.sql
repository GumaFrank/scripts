/* Formatted on 20/02/2020 18:11:53 (QP5 v5.256.13226.35538) */

SELECT * FROM
(
  SELECT V_Agent_Code,
         Agent_Name,
         Designation,
         Agency,
         Trans_Date,
         Trans_Date2,
         V_Policy_No,
         N_Seq_No,
         V_Plan_Desc,
         Policy_Owner,
         Policy_Year,
         D_Premium_Due,
         V_Override,
         Sub_Agent_Code,
         SUM (Premium_Amt) Premium_Amt,
         SUM (N_Comm_Amt) N_Comm_Amt,
         SUM (N_Wht) N_Wht,
         SUM (N_Net_Comm) N_Net_Comm,
         N_VOUCHER_NO
    FROM (SELECT A.N_Agent_No,
                 V_Agent_Code,
                 D.V_Name Agent_Name,
                 V_Description Designation,
                 NULL Agency,
                 A.V_Plan_Code,
                 J.V_Plan_Desc,
                 D_Comm_Gen Trans_Date,
                 G.D_Trans_Date Trans_Date2,
                 A.V_Policy_No,
                 A.N_Seq_No,
                 B.V_Name Assured_Name,
                 (SELECT V_Name
                    FROM Gnmt_Customer_Master X, Gnmt_Policy Y
                   WHERE     X.N_Cust_Ref_No = Y.N_Payer_Ref_No
                         AND Y.V_Policy_No = A.V_Policy_No)
                    Policy_Owner,
                 N_Comm_Year Policy_Year,
                 D_Premium_Due,
                 N_Prem_Amt Premium_Amt,
                 V_Receipt_No,
                 N_Comm_Amt,
                 N_Comm_Rate,
                 NVL (V_Income_Tax_Rule_Ref, 0) / 100 * N_Comm_Amt N_Wht,
                 N_Comm_Amt - NVL (V_Income_Tax_Rule_Ref, 0) / 100 * N_Comm_Amt
                    N_Net_Comm,
                 V_Oc_Flag V_Override,
                 Bpg_Agency.Bfn_Get_Agent_Code (N_Sub_Agent_No) Sub_Agent_Code,
                 H.N_VOUCHER_NO
            FROM Ammt_Pol_Comm_Detail A,
                 Gnmt_Policy_Detail B,
                 Ammm_Agent_Master C,
                 Gnmt_Customer_Master D,
                 Ammm_Rank_Master F,
                 Amdt_Agent_Benefit_Pool_Detail G,
                 Amdt_Agent_Bene_Pool_Payment H,
                 Gnmm_Plan_Master J
           WHERE     V_Comm_Status IN ('P')
                 AND A.V_Policy_No = B.V_Policy_No
                 AND A.N_Seq_No = B.N_Seq_No
                 AND A.N_Agent_No = C.N_Agent_No
                 AND C.N_Cust_Ref_No = D.N_Cust_Ref_No
                 AND C.V_Rank_Code = F.V_Rank_Code
                 AND C.N_Channel_No = F.N_Channel_No
                 --AND  H.D_Trans_Date Between :From_Date And :To_Date
                 --AND TRUNC(H.D_Trans_Date) BETWEEN TO_DATE(?,'DD/MM/YYYY') AND TO_DATE(?,'DD/MM/YYYY')
                 --AND TRUNC (NVL (H.D_TRANS_DATE, SYSDATE)) BETWEEN NVL (:P_FM_DT, TRUNC (NVL (H.D_TRANS_DATE, SYSDATE))) AND NVL (:P_TO_DT, TRUNC (NVL (H.D_TRANS_DATE, SYSDATE)))
                 AND G.V_Trans_Source_Code IN ('COMMISSION', 'COMMISSION REVERSAL')
                 AND V_Accounted = 'Y'
                 AND A.V_Plan_Code = J.V_Plan_Code
                 AND A.N_Comm_Benefit_Pool_Seq_No = G.N_Benefit_Pool_Seq_No
                 AND G.N_Benefit_Pool_Pay_Seq(+) = H.N_Benefit_Pool_Pay_Seq)
GROUP BY V_Agent_Code,
         Agent_Name,
         Designation,
         Agency,
         Trans_Date,
         Trans_Date2,
         V_Policy_No,
         N_Seq_No,
         V_Plan_Desc,
         Assured_Name,
         Policy_Owner,
         Policy_Year,
         D_Premium_Due,
         V_Override,
         Sub_Agent_Code,N_VOUCHER_NO
UNION
  SELECT V_Agent_Code,
         Agent_Name,
         Designation,
         Agency,
         Trans_Date,
         Trans_Date2,
         V_Policy_No,
         N_Seq_No,
         V_Plan_Desc,
         Policy_Owner,
         Policy_Year,
         D_Premium_Due,
         V_Override,
         Sub_Agent_Code,
         SUM (Premium_Amt) Premium_Amt,
         SUM (N_Comm_Amt) N_Comm_Amt,
         SUM (N_Wht) N_Wht,
         SUM (N_Net_Comm) N_Net_Comm,
         N_VOUCHER_NO
    FROM (SELECT A.N_Agent_No,
                 V_Agent_Code,
                 D.V_company_name Agent_Name,
                 V_Description Designation,
                 NULL Agency,
                 A.V_Plan_Code,
                 J.V_Plan_Desc,
                 D_Comm_Gen Trans_Date,
                 G.D_Trans_Date Trans_Date2,
                 A.V_Policy_No,
                 A.N_Seq_No,
                 B.V_Name Assured_Name,
                 (SELECT V_Name
                    FROM Gnmt_Customer_Master X, Gnmt_Policy Y
                   WHERE     X.N_Cust_Ref_No = Y.N_Payer_Ref_No
                         AND Y.V_Policy_No = A.V_Policy_No)
                    Policy_Owner,
                 N_Comm_Year Policy_Year,
                 D_Premium_Due,
                 N_Prem_Amt Premium_Amt,
                 V_Receipt_No,
                 N_Comm_Amt,
                 N_Comm_Rate,
                 NVL (V_Income_Tax_Rule_Ref, 0) / 100 * N_Comm_Amt N_Wht,
                 N_Comm_Amt - NVL (V_Income_Tax_Rule_Ref, 0) / 100 * N_Comm_Amt
                    N_Net_Comm,
                 V_Oc_Flag V_Override,
                 Bpg_Agency.Bfn_Get_Agent_Code (N_Sub_Agent_No) Sub_Agent_Code,
                 H.N_VOUCHER_NO
            FROM Ammt_Pol_Comm_Detail A,
                 Gnmt_Policy_Detail B,
                 Ammm_Agent_Master C,
                 Gnmm_company_master D,
                 Ammm_Rank_Master F,
                 Amdt_Agent_Benefit_Pool_Detail G,
                 Amdt_Agent_Bene_Pool_Payment H,
                 Gnmm_Plan_Master J
           WHERE     V_Comm_Status IN ('P')
                 AND A.V_Policy_No = B.V_Policy_No
                 AND A.N_Seq_No = B.N_Seq_No
                 AND A.N_Agent_No = C.N_Agent_No
                 AND C.V_company_code = D.V_company_code
                 AND C.V_company_branch = D.V_company_branch
                 AND C.V_Rank_Code = F.V_Rank_Code
                 AND C.N_Channel_No = F.N_Channel_No
                 --AND  TRUNC(H.D_Trans_Date) Between :From_Date And :To_Date
                 --AND TRUNC(H.D_Trans_Date) BETWEEN TO_DATE(?,'DD/MM/YYYY') AND TO_DATE(?,'DD/MM/YYYY')
                 --AND TRUNC (NVL (H.D_TRANS_DATE, SYSDATE)) BETWEEN NVL (:P_FM_DT, TRUNC (NVL (H.D_TRANS_DATE, SYSDATE))) AND NVL (:P_TO_DT, TRUNC (NVL (H.D_TRANS_DATE, SYSDATE)))
                 AND G.V_Trans_Source_Code IN ('COMMISSION', 'COMMISSION REVERSAL')
                 AND V_Accounted = 'Y'
                 AND A.V_Plan_Code = J.V_Plan_Code
                 AND A.N_Comm_Benefit_Pool_Seq_No = G.N_Benefit_Pool_Seq_No
                 AND G.N_Benefit_Pool_Pay_Seq(+) = H.N_Benefit_Pool_Pay_Seq
                 AND G.V_lob_code IN ('LOB001', 'LOB005'))
GROUP BY V_Agent_Code,
         Agent_Name,
         Designation,
         Agency,
         Trans_Date,
         Trans_Date2,
         V_Policy_No,
         N_Seq_No,
         V_Plan_Desc,
         Assured_Name,
         Policy_Owner,
         Policy_Year,
         D_Premium_Due,
         V_Override,
         Sub_Agent_Code,N_VOUCHER_NO
ORDER BY V_Policy_No

) WHERE --V_AGENT_CODE ='A0003496' AND
/*v_policy_no IN
('UI201900427702',
'UI201900507406',
'UI202300912575')
                 */
N_VOUCHER_NO IN
('2024005521',
'2024005731',
'2024005737',
'2024005736',
'2024005728',
'2024005729',
'2024005730',
'2024005738',
'2024005732',
'2024005733',
'2024005734',
'2024005735',
'2024004797',
'2024004796',
'2024004795')
AND TO_CHAR(TRANS_DATE2,'MON-YY') ='APR-24'