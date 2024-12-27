

SELECT 
DISTINCT
    VOUCHERS.V_VOU_NO,
    VOUCHERS.D_VOU_DATE,
    TRANS.V_POLICY_NO,
    TRANS.V_NAME,
    TRANS.V_PLAN_RIDER,
    TRANS.V_STATUS_DESC,
    TRANS.M_PROFIT_STATUS,
    TRANS.V_PLAN_CODE,
    TRANS.V_PLAN_NAME,
    TRANS.N_IND_SA,
    TRANS.N_POLICY_TERM,
    TRANS.N_PREM_PAY_TERM,
    TRANS.ANNUALISED_PREMIUM,
    TRANS.BONUS,
    TRANS.EXTRA_PA,
    TRANS.DISCOUNT,
    TRANS.V_PYMT_DESC,
    TRANS.V_GENDER,
    TRANS.RISK_YEAR,
    TRANS.RISK_MONTH,
    TRANS.D_PREM_DUE_DATE,
    TRANS.D_NEXT_OUT_DATE,
    TRANS.D_POLICY_END_DATE,
    TRANS.DOB1,
    TRANS.DOB2
FROM     
(
    -- TRANS Subquery
    SELECT A.V_POLICY_NO,
           F.V_NAME,
           DECODE (V_PLAN_RIDER, 'R', 'RIDER', 'P', 'PLAN') V_PLAN_RIDER,
           V_STATUS_DESC,
           NVL2 (A.N_PROFIT, 1, 0) M_PROFIT_STATUS,
           A.V_PLAN_CODE,
           V_PLAN_NAME,
           F.N_IND_SA,
           A.N_TERM N_POLICY_TERM,
           A.N_PREM_PAY_TERM,
           (F.N_IND_BASIC_PREM * 12) / DECODE (A.V_PYMT_FREQ, '00', 12, TO_NUMBER (A.V_PYMT_FREQ)) ANNUALISED_PREMIUM,
           AMOUNT BONUS,
           (NVL (N_IND_LOADING, 0) * 12) / DECODE (A.V_PYMT_FREQ, '00', 12, TO_NUMBER (A.V_PYMT_FREQ)) EXTRA_PA,
           (NVL (N_IND_DISCOUNT, 0) * 12) / DECODE (A.V_PYMT_FREQ, '00', 12, TO_NUMBER (A.V_PYMT_FREQ)) DISCOUNT,
           V_PYMT_DESC,
           DECODE (V_SEX, 'M', 'MALE', 'F', 'FEMALE') V_GENDER,
           TO_CHAR (D_COMMENCEMENT, 'YYYY') RISK_YEAR,
           TO_CHAR (D_COMMENCEMENT, 'MM') RISK_MONTH,
           A.D_PREM_DUE_DATE,
           D_NEXT_OUT_DATE,
           D_POLICY_END_DATE,
           (SELECT Q.D_BIRTH_DATE
            FROM GNMT_CUSTOMER_MASTER Q
            WHERE Q.N_CUST_REF_NO = F.N_CUST_REF_NO AND F.N_SEQ_NO = 1) DOB1,
           JHL_UTILS.DOB_TWO (A.V_POLICY_NO) DOB2
    FROM GNMT_POLICY A,
         GNMM_PLAN_MASTER B,
         GNMM_POLICY_STATUS_MASTER C,
         GNLU_FREQUENCY_MASTER D,
         JHL_AMOUNTS_V2 E,
         GNMT_POLICY_DETAIL F
    WHERE A.V_PLAN_CODE = B.V_PLAN_CODE
      AND A.V_CNTR_STAT_CODE = C.V_STATUS_CODE
      AND A.V_PYMT_FREQ = D.V_PYMT_FREQ
      AND V_PROD_LINE IN ('LOB001', 'LOB005')
      AND A.V_POLICY_NO = E.V_POLICY_NO(+)
      AND A.V_POLICY_NO = F.V_POLICY_NO
      AND N_SEQ_NO = 1
      AND E.AMT_TYPE(+) = 'DUE_BONUS_AMT'
      AND A.V_PLAN_CODE NOT LIKE 'FSC%'
      AND V_STATUS_CODE IN ('NB051','NB024','NB105','NB006','NB020')
    UNION
    SELECT A.V_POLICY_NO,
           F.V_NAME,
           DECODE (V_PLAN_RIDER, 'R', 'RIDER', 'P', 'PLAN') V_PLAN_RIDER,
           V_STATUS_DESC,
           NVL2 (A.N_BENEFIT_AMOUNT, 1, 0) M_PROFIT_STATUS,
           A.V_PLAN_CODE,
           V_PLAN_DESC,
           N_RIDER_SA N_SUM_COVERED,
           N_RIDER_TERM N_POLICY_TERM,
           A.N_PREM_PAY_TERM,
           (N_RIDER_PREMIUM * 12) / DECODE (E.V_PYMT_FREQ, '00', 12, TO_NUMBER (E.V_PYMT_FREQ)) ANNUALISED_PREMIUM,
           0 BONUS,
           (NVL (N_RIDER_LOAD_PREM, 0) * 12) / DECODE (E.V_PYMT_FREQ, '00', 12, TO_NUMBER (E.V_PYMT_FREQ)) EXTRA_PA,
           (NVL (N_RIDER_DISCOUNT, 0) * 12) / DECODE (E.V_PYMT_FREQ, '00', 12, TO_NUMBER (E.V_PYMT_FREQ)) DISCOUNT,
           V_PYMT_DESC,
           DECODE (V_SEX, 'M', 'MALE', 'F', 'FEMALE') V_GENDER,
           TO_CHAR (D_RIDER_START, 'YYYY') RISK_YEAR,
           TO_CHAR (D_RIDER_START, 'MM') RISK_MONTH,
           E.D_PREM_DUE_DATE,
           D_NEXT_OUT_DATE,
           D_POLICY_END_DATE,
           (SELECT Q.D_BIRTH_DATE
            FROM GNMT_CUSTOMER_MASTER Q
            WHERE Q.N_CUST_REF_NO = F.N_CUST_REF_NO AND F.N_SEQ_NO = 1) DOB1,
           JHL_UTILS.DOB_TWO (A.V_POLICY_NO) DOB2
    FROM GNMT_POLICY_RIDERS A,
         GNMM_PLAN_MASTER B,
         GNMM_POLICY_STATUS_MASTER C,
         GNMT_POLICY E,
         GNLU_FREQUENCY_MASTER D,
         GNMT_POLICY_DETAIL F
    WHERE A.V_PLAN_CODE = B.V_PLAN_CODE
      AND A.V_RIDER_STAT_CODE = C.V_STATUS_CODE
      AND A.V_POLICY_NO = E.V_POLICY_NO
      AND E.V_PYMT_FREQ = D.V_PYMT_FREQ
      AND V_PROD_LINE IN ('LOB001', 'LOB005')
      AND E.V_POLICY_NO = F.V_POLICY_NO
      AND A.V_POLICY_NO = F.V_POLICY_NO
      AND A.N_SEQ_NO = 1
      AND A.N_SEQ_NO = F.N_SEQ_NO
      AND A.V_PLAN_CODE NOT LIKE 'FSC%'
      AND V_STATUS_CODE IN ('NB051','NB024','NB105','NB006','NB020')
) TRANS
LEFT OUTER JOIN 
(
    -- VOUCHERS Subquery
    SELECT 
           V_vou_source,
           V_process_name,
           V_source_ref_no,
           E.V_policy_no, 
           D_vou_date,
           B.V_vou_no,
           B.V_vou_status,
           V_status_desc,
           B.N_cust_ref_no,
           V_payee_name,
           (SELECT V_contact_number
              FROM Gndt_custmobile_contacts H
             WHERE E.N_cust_ref_no = H.N_cust_ref_no
                   AND V_contact_number NOT LIKE '%@%'
                   AND ROWNUM = 1) AS Contact_no,
           N_vou_amount,
           V_chq_no,
           F.V_lastupd_user,
           NVL (Jhl_gen_pkg.Get_voucher_payment_method (B.V_vou_no), 'CHQ') AS Pay_method,
           Jhl_gen_pkg.Get_voucher_status_user (B.V_vou_no, 'PREPARE') AS Processed_by,
           Jhl_gen_pkg.Get_voucher_status_user (B.V_vou_no, 'VERIFY') AS Verified_by,
           Jhl_gen_pkg.Get_voucher_date (B.V_vou_no, 'VERIFY') AS Verification_date,
           Jhl_gen_pkg.Get_voucher_status_user (B.V_vou_no, 'APPROVE') AS Approved_by,
           Jhl_gen_pkg.Get_voucher_date (B.V_vou_no, 'APPROVE') AS Approval_date,
           (SELECT SUM (N_amount)
              FROM Pydt_vou_details
             WHERE V_payment_type = 'D' AND V_vou_no = B.V_vou_no) AS Gross_amt
    FROM 
           Pymt_voucher_root A,
           Pymt_vou_master B,
           Gnmm_policy_status_master C,
           Gnmm_process_master D,
           Pydt_voucher_policy_client E,  -- Likely correct table for policy number
           Py_voucher_status_log F
    WHERE 
           A.V_main_vou_no = B.V_main_vou_no
           AND V_vou_status = V_status_code
           AND V_vou_source = V_process_id
           AND A.V_main_vou_no = E.V_main_vou_no
           AND V_vou_source NOT IN ('PY001', 'PY014', 'PY009', 'PY010')
           AND B.V_vou_status NOT IN ('PY010', 'PY009')
           AND B.V_vou_no = F.V_vou_no
           AND V_current_status IN ('PY005', 'PY004')
           AND D_vou_date = (
               SELECT MAX(D_vou_date)
               FROM Pymt_voucher_root
               WHERE V_main_vou_no = A.V_main_vou_no
           )
) VOUCHERS ON VOUCHERS.V_POLICY_NO = TRANS.V_POLICY_NO;
/
