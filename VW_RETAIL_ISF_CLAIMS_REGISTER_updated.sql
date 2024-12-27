/*
updated by Eng Frank Guma B 
Date 02-Jul-2024

SELECT *  FROM VW_RETAIL_ISF_CLAIMS_REGISTER
--APPROVED_BY, APPROVAL_DATE, VERIFY_APPROV_TAT, PROCESS_APPROV_TAT
INVOICE_AMOUNT
SELECT * FROM Xxjic_Ap_Claim_Map@Jicofprod.Com

*/

DROP VIEW VW_RETAIL_ISF_CLAIMS_REGISTER


CREATE OR REPLACE FORCE VIEW VW_RETAIL_ISF_CLAIMS_REGISTER
(
    BENEFICIARY_CODE,
    BENEFICIARY_NAME,
    ADDRESS,
    EFT_CODE,
    BANK_NAME,
    BRANCH_NAME,
    DTB_BRANCH_CODE,
    ACCOUNT_NO,
    CLAIM_AMOUNT,
    PAYMENT_METHOD,
    REMARKS,
    V_VOU_NO,
    VOUCHER_STATUS_CODE,
    VOUCHER_STATUS_DESC,
    PROCESSED_BY,
    PROCESSED_DATE,
    VERIFIED_BY,
    VERIFICATION_DATE,
    PROCESS_VERIFY_TAT,
    APPROVED_BY,
    APPROVAL_DATE,
    VERIFY_APPROV_TAT,
    PROCESS_APPROV_TAT,
    CHEQUE_NO,
    INVOICE_DATE,
    PAYMENT_VOUCHER,
    OFA_UPLOAD_DATE,
    OFA_UPLOA_TAT,
    PAYMENT_STATUS,
    POLICY_OWNER,
    OWNER_GENDER,
    OWNER_NATIONAL_ID,
    OWNER_PIN_NO,
    ASSURED_NAME,
    ASSURED_NAME_GENDER,
    ASSURED_DATE_OF_BIRTH,
    POLICY_BENEFICIARY,
    V_CONTACT_NUMBER,
    EMAIL,
    V_OCCUP_DESC,
    V_POLICY_NO,
    V_PLAN_NAME,
    D_COMMENCEMENT,
    N_TERM,
    D_POLICY_END_DATE,
    V_CURR_STATUS,
    D_PREM_DUE_DATE,
    TOTAL_PREMIUM,
    OUTSTANDING_PREMIUM,
    V_PYMT_DESC,
    V_PMT_METHOD_NAME,
    N_SUM_COVERED,
    EMPLOYER,
    BRANCH,
    LOAN_BAL,
    LOAN_INT,
    APL_BAL,
    APL_INT,
    AGENT,
    UNIT_SALES_MANAGER,
    AGENCY_SALES_MANAGER,
    REGIONAL_SALES_MANAGER,
    NATIONAL_SALES_MANAGER,
    PROCESS_DATE,
    DAY_PROCESSED
)
BEQUEATH DEFINER
AS
    WITH
        Cte_Ofa
        AS
            (SELECT Invoice_Date,
                    Payment_Voucher,
                    Payment_Date,
                    Payment_Status,
                    INVOICE_AMOUNT
               FROM Xxjic_Ap_Claim_Map@Jicofprod.Com
              WHERE     Pay_Group IN
                            ('ISF-CORPORATE',
                             'ISF-INDIVIDUAL-CLAIM',
                             'LIFE-CLAIM')
                    AND Lob_Name = 'JHL_UG_LIF_OU'),
        Cte_Payment
        AS
            (SELECT Eft_Ben_Code
                        Beneficiary_Code,
                    Eft_Ben_Name
                        Beneficiary_Name,
                    Eft_Ben_Address
                        Address,
                    Eft_Code
                        Eft_Code,
                    Eft_Bank_Name
                        Bank_Name,
                    Eft_Branch_Name
                        Branch_Name,
                    Eft_Dtb_Branch_Code
                        Dtb_Branch_Code,
                    '''' || Eft_Client_Acc_No
                        Account_No,
                    Eft_Amount
                        Amount,
                    Eft_Pymt_Method
                        Payment_Method,
                    Eft_Remarks
                        Remarks,
                    --   EFT_VOU_RAISED_BY,
                    --   EFT_VOU_AUTH_BY,
                    C.V_Vou_No,
                    (SELECT Ab.V_Status_Code
                       FROM Pymt_Vou_Master Mst, Gnmm_Policy_Status_Master Ab
                      WHERE     Mst.V_Vou_Status = Ab.V_Status_Code
                            AND C.V_Vou_No = Mst.V_Vou_No)
                        Voucher_Status_code,
                    (SELECT Ab.V_Status_Desc
                       FROM Pymt_Vou_Master Mst, Gnmm_Policy_Status_Master Ab
                      WHERE     Mst.V_Vou_Status = Ab.V_Status_Code
                            AND C.V_Vou_No = Mst.V_Vou_No)
                        Voucher_Status_Desc,
                    Jhl_Gen_Pkg.Get_Voucher_Status_User (C.V_Vou_No,
                                                         'PREPARE')
                        Processed_By,
                    Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'PREPARE')
                        Processed_Date,
                    Jhl_Gen_Pkg.Get_Voucher_Status_User (C.V_Vou_No,
                                                         'VERIFY')
                        Verified_By,
                    Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'VERIFY')
                        Verification_Date,
                    (  Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'VERIFY')
                     - Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'PREPARE'))
                        Process_Verify_Tat,
                    Jhl_Gen_Pkg.Get_Voucher_Status_User (C.V_Vou_No,
                                                         'APPROVE')
                        Approved_By,
                    Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'APPROVE')
                        Approval_Date,
                    (  Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'APPROVE')
                     - Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'VERIFY'))
                        Verify_Approv_Tat,
                    (  Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'APPROVE')
                     - Jhl_Gen_Pkg.Get_Voucher_Date (C.V_Vou_No, 'PREPARE'))
                        Process_Approv_Tat,
                    --JHL_BI_UTILS.get_voucher_payment_date (B.V_vou_no,N_vou_amount,TRUNC (A.EFT_VOU_DATE)) PAYMENT_DATE,
                    (SELECT V_Chq_No
                       FROM Pymt_Vou_Master Mst
                      WHERE C.V_Vou_No = Mst.V_Vou_No)
                        Cheque_No,
                    Policy_Owner,
                    Owner_Gender,
                    Owner_National_Id,
                    Owner_Pin_No,
                    Assured_Name,
                    Assured_Name_Gender,
                    Assured_Date_Of_Birth,
                    Beneficiary_Name
                        Policy_Beneficiary,
                    V_Contact_Number,
                    Email,
                    V_Occup_Desc,
                    B.V_Policy_No,
                    V_Plan_Name,
                    D_Commencement,
                    N_Term,
                    D_Policy_End_Date,
                    V_Curr_Status,
                    D_Prem_Due_Date,
                    Total_Premium,
                    Outstanding_Premium,
                    V_Pymt_Desc,
                    V_Pmt_Method_Name,
                    N_Sum_Covered,
                    Employer,
                    Branch,
                    Loan_Bal,
                    Loan_Int,
                    Apl_Bal,
                    Apl_Int,
                    Agent,
                    Unit_Sales_Manager,
                    Agency_Sales_Manager,
                    Regional_Sales_Manager,
                    National_Sales_Manager,
                    Process_Date
               FROM Jhl_Eft_Pymt_Dtls           A,
                    Client_Details_Api_Report   B,
                    Pydt_Voucher_Policy_Client  C
              --WHERE TRUNC (EFT_PROCESSED_DATE) = TRUNC (SYSDATE)
              WHERE     B.V_Policy_No = A.Eft_Policy_No(+)
                    AND B.V_Policy_No = C.V_Policy_No(+)
                    AND C.V_Vou_No = A.V_Vou_No(+))
    SELECT Beneficiary_Code,
           Beneficiary_Name,
           Address,
           Eft_Code,
           Bank_Name,
           Branch_Name,
           Dtb_Branch_Code,
           Account_No,
           B.INVOICE_AMOUNT   AS Claim_Amount,
           Payment_Method,
           Remarks,
           V_Vou_No,
           Voucher_Status_code,
           Voucher_Status_Desc,
           Processed_By,
           Processed_Date,
           Verified_By,
           Verification_Date,
           Process_Verify_Tat,
           Approved_By,
           Approval_Date,
           Verify_Approv_Tat,
           Process_Approv_Tat,
           Cheque_No,
           Invoice_Date,
           Payment_Voucher,
           Payment_Date                   Ofa_Upload_Date,
           Payment_Date - Invoice_Date    Ofa_Uploa_Tat,
           Payment_Status,
           Policy_Owner,
           Owner_Gender,
           Owner_National_Id,
           Owner_Pin_No,
           Assured_Name,
           Assured_Name_Gender,
           Assured_Date_Of_Birth,
           Policy_Beneficiary,
           V_Contact_Number,
           Email,
           V_Occup_Desc,
           V_Policy_No,
           V_Plan_Name,
           D_Commencement,
           N_Term,
           D_Policy_End_Date,
           V_Curr_Status,
           D_Prem_Due_Date,
           Total_Premium,
           Outstanding_Premium,
           V_Pymt_Desc,
           V_Pmt_Method_Name,
           N_Sum_Covered,
           Employer,
           Branch,
           Loan_Bal,
           Loan_Int,
           Apl_Bal,
           Apl_Int,
           Agent,
           Unit_Sales_Manager,
           Agency_Sales_Manager,
           Regional_Sales_Manager,
           National_Sales_Manager,
           Process_Date,
           CASE
               WHEN TO_CHAR (Processed_Date,
                             'DY',
                             'NLS_DATE_LANGUAGE=ENGLISH') IN
                        ('SAT', 'SUN')
               THEN
                   'WEEKEND'
               ELSE
                   'WEEKDAY'
           END                            AS Day_Processed
      FROM Cte_Payment  A
           LEFT JOIN Cte_Ofa B ON A.V_Vou_No = B.Payment_Voucher
     WHERE A.APPROVED_BY IS NOT NULL
       AND A.APPROVAL_DATE IS NOT NULL
       AND A.VERIFY_APPROV_TAT IS NOT NULL
       AND A.PROCESS_APPROV_TAT IS NOT NULL
