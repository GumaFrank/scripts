
/*
Author: Frank Bagambe
DATE: 28-OCT-2024
DESC:RECEIPT LISTING FOR AUDIT
*/

SELECT
    B.D_FROM_DATE,
    B.D_TO_DATE,
    B.V_LASTUPD_USER,
    DECODE (B.V_PREV_STATUS,
     'RE001', 'Processed',
                      'RE002', 'Cancelled') AS Previous_status,
   -- B.V_CURRENT_STATUS,
    A.V_BRANCH_CODE,
    A.V_INS_CODE,
    A.BRANCH,
    A.V_CURRENCY_CODE,
    A.CURRENCY_DESC,
    A.PAYMENT_CODE,
    A.PAYMENT_METHOD,
    A.RECEIPT_DATE,
    A.RECEIPT_NO,
    A.INSTRUMENT_DATE,
    A.DESCRIPTION,
    A.RECEIPT_TYPE,
    A.BUSINESS_CODE,
    A.CHEQUE_NO,
    A.CLIENT_BANK,
    A.RECEIPT_AMOUNT,
    A.V_INS_BANK,
    A.V_INS_BANK_BRANCH,
    A.V_USER_CODE,
    A.V_POLICY_NO,
    A.DR_BANK,    
    A.DR_BANK_CODE,
    A.V_RECEIPT_STATUS,
    A.V_INSTRUMENT_STATUS
FROM 
    (
        SELECT Rct.V_Branch_Code,
               Ins.V_Ins_Code,
               Rct.V_Branch_Code AS Branch,
               Rct.V_Currency_Code,
               Cur.V_Currency_Desc AS Currency_Desc,
               Ins.V_Ins_Code AS Payment_Code,
               Ins.V_Desc AS Payment_Method,
               TO_DATE(Rct.D_Receipt_Date, 'DD/MM/RRRR') AS Receipt_Date,
               Rct.V_Receipt_No AS Receipt_No,
               Rct_Ins.D_INS_DATE AS INSTRUMENT_DATE,
               NVL(Cust.V_Name, 
                   (SELECT V_Company_Name
                      FROM Gnmm_Company_Master C
                     WHERE C.V_Company_Code = Rct.V_Company_Code
                       AND C.V_Company_Branch = Rct.V_Company_Branch)
               ) AS Description,
               DECODE(Rct.V_Receipt_Code,
                      'RCT002', 'Policy Premium',
                      'RCT003', 'Proposal Deposit',
                      'RCT004', 'Loan Repayment',
                      'RCT100', 'Policy Premium',
                      'RCT001', 'Policy Premium',
                      'RCT012', 'Scheme Premium',
                      (SELECT Rc.V_Receipt_Desc
                         FROM Remm_Receipt_Code Rc
                        WHERE Rc.V_Receipt_Code = Rct.V_Receipt_Code)
               ) AS Receipt_Type,
               DECODE(Rct.V_Business_Code,
                      'IND', 'Individual Life',
                      'GRP', 'Group Life',
                      'MISC', 'Miscellaneous',
                      Rct.V_Business_Code
               ) AS Business_Code,
               NVL(Rct_Ins.V_Ins_Number, ' - ') AS Cheque_No,
               Banks.V_Company_Name || ' - ' || Banks.V_Company_Branch AS Client_Bank,
               Rct.N_Receipt_Amt AS Receipt_Amount,
               Rct_Ins.V_Ins_Bank,
               Rct_Ins.V_Ins_Bank_Branch,
               Rct.V_User_Code,
               Rct.V_Policy_No,
               Jhl_Gen_Pkg.Get_Dr_Bank(Ins.V_Ins_Code, Rct.V_Branch_Code, Rct.V_Business_Code) AS Dr_Bank,
               Jhl_Gen_Pkg.Get_Dr_Bank_Code(Ins.V_Ins_Code, Rct.V_Branch_Code, Rct.V_Business_Code) AS Dr_Bank_Code,
               DECODE(Rct.V_Receipt_Status,
                      'RE001', 'Processed',
                      'RE002', 'Cancelled'
               ) AS V_RECEIPT_STATUS,
               Rct.V_Instrument_Status AS V_INSTRUMENT_STATUS
        FROM Remt_Receipt Rct
        JOIN Remt_Receipt_Instruments Rct_Ins ON Rct.N_Receipt_Session = Rct_Ins.N_Receipt_Session
        JOIN Unmm_Currency_Master Cur ON Rct.V_Currency_Code = Cur.V_Currency_Code
        JOIN Remm_Instrument Ins ON Rct_Ins.V_Ins_Code = Ins.V_Ins_Code
        LEFT JOIN Gnmt_Customer_Master Cust ON Rct.N_Cust_Ref_No = Cust.N_Cust_Ref_No
        LEFT JOIN Gnmm_Company_Master Banks ON Rct_Ins.V_Ins_Bank = Banks.V_Company_Code
                                            AND Rct_Ins.V_Ins_Bank_Branch = Banks.V_Company_Branch
        WHERE V_Receipt_Table = 'DETAIL'
          AND TRUNC(Rct.D_Receipt_Date) BETWEEN :P_FromDate AND :P_ToDate
          AND UPPER(NVL(Rct.V_Receipt_Remarks, 'XXXXX')) NOT LIKE '%OFFLINE%'
        ORDER BY Rct.V_Branch_Code, Rct.V_Receipt_No
    ) A
LEFT OUTER JOIN RE_RECEIPT_STATUS_log B ON A.RECEIPT_NO = B.V_RECEIPT_NO
--WHERE B.V_RECEIPT_NO = 'HO240001617';
/
