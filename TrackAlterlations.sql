/*
Author: Frank B
Date: 11-OCT-2024
Description:  Tracking the Alteration on Policies

*/

SELECT * FROM 
(
  SELECT B.V_Policy_No,
         B.V_Plri_Code,
         DECODE (B.V_Plri_Flag,  'P', 'PLAN',  'R', 'RIDER') Plan_Rider,
         B.V_Alter_Code,
         F.V_Alter_Code_Desc,
         B.V_Old_Value,
         B.V_New_Value,
         B.V_Lastupd_User Lastupdated_By,
         (SELECT Amount
            FROM Jhl_Amounts_V2 H
           WHERE H.V_Policy_No = G.V_Policy_No AND Amt_Type = 'DUE_BONUS_AMT')
            Bonus,
           (NVL (N_Ind_Loading, 0) * 12)
         / DECODE (G.V_Pymt_Freq, '00', 12, TO_NUMBER (G.V_Pymt_Freq))
            Extra_Pa,
           (NVL (N_Ind_Discount, 0) * 12)
         / DECODE (G.V_Pymt_Freq, '00', 12, TO_NUMBER (G.V_Pymt_Freq))
            Discount,
         TRUNC (G.D_Commencement) Commencement_Date,
         MAX (B.D_Lastupd_Inftim) Lastupdated_On
    FROM Psdt_Alteration_History B,
         Psmt_Alteration C,
         Gnmt_Quotation_Detail E,
         Psmm_Alter_Codes F,
         Gnmt_Policy G
   WHERE     B.V_Policy_No = E.V_Policy_No
         AND B.V_Policy_No = G.V_Policy_No
         --   AND G.V_Policy_No(+) = H.V_Policy_No
         AND B.N_Alteration_Seq_No = C.N_Alteration_Seq_No
         AND E.V_Quotation_Id = B.V_Quotation_Id
         AND E.N_Seq_No = B.N_Seq_No
         AND B.V_Alter_Code = F.V_Alter_Code
         AND B.V_Policy_No NOT LIKE 'UG%'
         AND B.V_Old_Value NOT IN ('0', 'FP')
         AND B.V_Alter_Code NOT IN ('AL102',
                                    'AL139',
                                    'AL138',
                                    'AL114',
                                    'AL137',
                                    'AL140',
                                    'AL178',
                                    'AL101',
                                    'AL84',
                                    'AL36',
                                    'AL50',
                                    'AL43',
                                    'AL42',
                                    'AL41',
                                    'AL76',
                                    'AL49',
                                    'AL105',
                                    'AL53',
                                    'AL51',
                                    'AL107',
                                    'AL99',
                                    'AL106',
                                    'AL45',
                                    'AL31',
                                    'AL108',
                                    'AL124',
                                    'AL136',
                                    'AL130',
                                    'AL55',
                                    'AL104',
                                    'AL48')
         -- AND MAX(B.D_LASTUPD_INFTIM) D_LASTUPD_INFTIM
         --         AND G.V_POLICY_NO NOT IN
         --                (SELECT DISTINCT V_POLICY_NO
         --                   FROM GNMT_POLICY
         --                  WHERE TRUNC (D_COMMENCEMENT) BETWEEN :FROM_DATE AND :TO_DATE)
         --AND TRUNC (B.D_Lastupd_Inftim) BETWEEN :From_Date AND :TO_DATE
        
        /* AND TRUNC (B.D_LASTUPD_INFTIM) BETWEEN NVL (
                                                   :P_FM_DT,
                                                   TRUNC (B.D_LASTUPD_INFTIM))
                                            AND NVL (
                                                   :P_TO_DT,
                                                   TRUNC (B.D_LASTUPD_INFTIM))
                                                   */
GROUP BY B.V_Policy_No,
         B.V_Plri_Code,
         G.V_Policy_No,
         B.V_Alter_Code,
         F.V_Alter_Code_Desc,
         B.V_Old_Value,
         B.V_New_Value,
         D_Commencement,
         B.V_Lastupd_User,
         B.V_Plri_Flag,
         G.V_Pymt_Freq,
         N_Ind_Loading,
         N_Ind_Discount
         )
         WHERE V_POLICY_NO IN 
         (
         'UI202401076220',
'UG202401106504',
'UI202401063535',
'UI202401065624',
'UI202300912822')
