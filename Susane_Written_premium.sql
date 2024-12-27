/* Formatted on 21/10/2020 15:42:34 (QP5 v5.256.13226.35538) */
select * from 
(
SELECT DISTINCT
       V_company_code,
       TRIM (REGEXP_REPLACE (V_company_name, '[^a-zA-Z0-9]', ' '))
          V_company_name,
       REPLACE (
          REPLACE (REPLACE (REPLACE (V_company_name, ','), CHR (10)),
                   CHR (13)),
          '"')
          V_company_name_1,
       A.V_quotation_id,
       V_policy_no,
       D_commencement,
       D_policy_end_date,
       A.N_term,
       V_quot_backup_type,
       N_seq_no,
       REPLACE (
          REPLACE (REPLACE (REPLACE (V_name, ','), CHR (10)), CHR (13)),
          '"')
          V_name,
       N_age_entry,
       D_ind_dob,
       N_ind_sa,
       D_cntr_start_date,
       D_cntr_end_date,
       D_bill_due_date,
       D_bill_raised,
       D_exit,
       A.V_plri_code,
       V_bill_type,
       V_bill_no,
       D_due_end_date,
       DECODE (V_bill_type, 'DN', -N_bill_amt, N_bill_amt) N_bill_amt,
       N_loading_amt,
       N_loading_pct,
       N_original_fcl,
       Restricted_sa,
       N_percent N_comm_pct,
       N_percent / 100 * DECODE (V_bill_type, 'DN', -N_bill_amt, N_bill_amt)
          N_comm_amt
  --N_RI_PREMIUM
  FROM Act_valuation A, Ammm_quot_other_comm_rates B
 WHERE     A.V_quotation_id = B.V_quotation_id(+)
       AND A.V_plri_code = B.V_plri_code(+)
       AND NVL (V_bill_stat, 'X') != 'R'
       --AND V_policy_no = 'UG201700255293'
       --AND TRUNC(D_BILL_RAISED) BETWEEN TO_DATE(?,'DD/MM/YYYY') AND TO_DATE(?,'DD/MM/YYYY')
       -- AND TRUNC (D_bill_raised) BETWEEN '01-jan-2019' AND '31-jan-2019'
       AND (   (D_bill_raised) BETWEEN :P_FM_DT AND :P_TO_DT
            OR ( :P_FM_DT IS NULL AND :P_TO_DT IS NULL))
UNION
SELECT DISTINCT
       V_company_code,
       TRIM (REGEXP_REPLACE (V_company_name, '[^a-zA-Z0-9]', ' '))
          V_company_name,
       REPLACE (
          REPLACE (REPLACE (REPLACE (V_company_name, ','), CHR (10)),
                   CHR (13)),
          '"')
          V_company_name_1,
       A.V_quotation_id,
       V_policy_no,
       D_commencement,
       D_policy_end_date,
       N_rider_term N_term,
       V_quot_backup_type,
       A.N_seq_no,
       REPLACE (
          REPLACE (REPLACE (REPLACE (V_name, ','), CHR (10)), CHR (13)),
          '"')
          V_name,
       A.N_age_entry,
       D_ind_dob,
       N_rider_sa N_ind_sa,
       D_rider_start D_cntr_start_date,
       D_rider_end D_cntr_end_date,
       D_bill_due_date,
       D_bill_raised,
       D_exit,
       C.V_plan_code V_plri_code,
       V_bill_type,
       V_bill_no,
       D_due_end_date,
       0.00 N_bill_amt,
       0.00 N_loading_amt,
       0.00 N_loading_pct,
       C.N_original_fcl,
       N_fcl_amount Restricted_sa,
       0.00 N_comm_pct,
       0.00 N_comm_amt
  --N_RI_PREMIUM
  FROM Act_valuation A, Ammm_quot_other_comm_rates B, Gnmt_quotation_riders C
 WHERE     A.V_quotation_id = B.V_quotation_id(+)
       AND A.V_quotation_id = C.V_quotation_id(+)
       AND A.V_plri_code = B.V_plri_code(+)
       AND A.N_seq_no = C.N_seq_no
       AND NVL (V_bill_stat, 'X') != 'R'
       --AND V_policy_no = 'UG201700255293'
       AND A.V_plri_code IN ('BGTC002', 'BGTM002', 'BGTC001')
       AND (   (D_bill_raised) BETWEEN :P_FM_DT AND :P_TO_DT
            OR ( :P_FM_DT IS NULL AND :P_TO_DT IS NULL))
            
     )
     
     where V_POLICY_NO = 'UG202300901250'
     order by  D_BILL_RAISED desc