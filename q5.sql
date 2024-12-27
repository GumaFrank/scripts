/* 
Author Frank Bagambe
Date 04-Oct-2024
Description 
Query for getting Premium Statement( Input is policy number and Output should have Receipt_No, Receipt_Date, Other_Ref_No, Method, 
Amount, Narration and Status) 


 */
  SELECT a.v_policy_no,
         TO_CHAR (D_OTHER_REF_DATE, 'DD-Mon-YYYY') OTHER_REF_DATE,
         TO_CHAR (D_RECEIPT_DATE, 'DD-Mon-YYYY') RECEIPT_DATE,
         V_OTHER_REF_NO,
         V_RECEIPT_NO,
         DECODE (V_RECEIPT_STATUS, 'RE001', N_RECEIPT_AMT, -1 * N_RECEIPT_AMT)
            N_RECEIPT_AMT,
         DECODE (V_RECEIPT_CODE,
                 'RCT003', 'Proposal Deposit',
                 'RCT002', 'Premium',
                 'RCT004', 'Loan',
                 'Unkown')
            RECEIPT_CODE,
         DECODE (V_RECEIPT_STATUS, 'RE001', 'Processed', 'Cancelled')
            RECEIPT_STATUS
    FROM REMT_RECEIPT a
   WHERE     a.v_policy_no = :POLICY_NUMBER
    --a.v_policy_no = 'UI201900472911'
         AND V_RECEIPT_TABLE = 'DETAIL'
         AND V_RECEIPT_STATUS = 'RE001'
ORDER BY D_RECEIPT_DATE DESC;
/
