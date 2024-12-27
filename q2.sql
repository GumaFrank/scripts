/*
Author Frank Bagambe
Date : 04-OCT-2024
Description: 
Query for getting Latest Voucher Date( Input is policy number)

*/

SELECT 
       V_vou_source,
       V_process_name,
       V_source_ref_no,
       E.V_policy_no,  -- Replace with the actual policy number column
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
       AND E.V_policy_no = :policy_number  -- Correct column for policy number
       AND V_vou_source NOT IN ('PY001', 'PY014', 'PY009', 'PY010')
       AND B.V_vou_status NOT IN ('PY010', 'PY009')
       AND B.V_vou_no = F.V_vou_no
       AND V_current_status IN ('PY005', 'PY004')
       AND D_vou_date = (
           SELECT MAX(D_vou_date)
           FROM Pymt_voucher_root
           WHERE V_main_vou_no = A.V_main_vou_no
       );
