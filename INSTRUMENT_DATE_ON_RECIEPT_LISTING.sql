/*
AUTHOR: Frank Bagambe
Date: 28-OCT-2024
Description:   it was a projection requirement from Joyce Nalusiba to added
an Instrument Date to the report 

*/

  SELECT Rct.V_Branch_Code,
         Ins.V_Ins_Code,
         Rct.V_Branch_Code Branch,
         Rct.V_Currency_Code,
         V_Currency_Desc Currency_Desc,
         Ins.V_Ins_Code Payment_Code,
         Ins.V_Desc Payment_Method,
         TO_DATE (D_Receipt_Date, 'DD/MM/RRRR') Receipt_Date,
         V_Receipt_No Receipt_No,
         Rct_Ins.D_INS_DATE INSTRUMENT_DATE,
         NVL (
            Cust.V_Name,
            (SELECT V_Company_Name
               FROM Gnmm_Company_Master C
              WHERE     C.V_Company_Code = Rct.V_Company_Code
                    AND C.V_Company_Branch = Rct.V_Company_Branch))
            Description,
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
            Receipt_Type,
         DECODE (Rct.V_Business_Code,
                 'IND', 'Individual Life',
                 'GRP', 'Group Life',
                 'MISC', 'Miscellaneous',
                 Rct.V_Business_Code)
            Business_Code,
         NVL (V_Ins_Number, ' - ') Cheque_No,
         Banks.V_Company_Name || ' - ' || Banks.V_Company_Branch Client_Bank,
         N_Receipt_Amt Receipt_Amount,
         V_Ins_Bank,
         V_Ins_Bank_Branch,
         Rct.V_User_Code,
         Rct.V_Policy_No,
         Jhl_Gen_Pkg.Get_Dr_Bank (Ins.V_Ins_Code,
                                  Rct.V_Branch_Code,
                                  Rct.V_Business_Code)
            Dr_Bank,
         Jhl_Gen_Pkg.Get_Dr_Bank_Code (Ins.V_Ins_Code,
                                       Rct.V_Branch_Code,
                                       Rct.V_Business_Code)
            Dr_Bank_Code,
            DECODE (RCT.V_RECEIPT_STATUS,
                 'RE001', 'Processed',
                 'RE002', 'Cancelled')
            V_RECEIPT_STATUS,
            RCT.V_INSTRUMENT_STATUS
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
         --AND Rct.V_Instrument_Status = 'A' /*Requested by Mary in order to include Transferred receipts */      
         AND TRUNC (D_Receipt_Date) BETWEEN ( :P_FromDate) AND ( :P_ToDate)
         AND UPPER (NVL (Rct.V_Receipt_Remarks, 'XXXXX')) NOT LIKE '%OFFLINE%'
ORDER BY 1,
         2,
         4,
         11