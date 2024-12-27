/* Formatted on 31/01/2019 18:47:00 (QP5 v5.256.13226.35538) */

select count( distinct V_POLICY_NO) from 
(
SELECT A.D_PROPOSAL_DATE,
       A.D_ISSUE,
       a.D_COMMENCEMENT,
       a.V_LASTUPD_USER,
       a.V_POLICY_NO,
       b.V_NAME ASSURED_NAME,
       (SELECT V_CONTACT_NUMBER
          FROM GNDT_CUSTMOBILE_CONTACTS
         WHERE     N_CUST_REF_NO = N_PAYER_REF_NO
               AND V_STATUS = 'A'
               AND ROWNUM = 1)
          V_CONTACT_NUMBER,
       JHL_UTILS.AGENT_NAME (c.N_AGENT_NO) AGENT,
       N_SUM_COVERED,
       b.N_TERM,
       a.V_PYMT_FREQ,
       V_PYMT_DESC,
       a.V_PMT_METHOD_CODE,
       V_PMT_METHOD_NAME,
       a.N_CONTRIBUTION TOTAL_PREMIUM,
       DECODE (a.V_PYMT_FREQ, 0, 1, 12 / a.V_PYMT_FREQ) * a.N_CONTRIBUTION
          TOTAL_ANNUAL_PREM,
       N_IND_BASIC_PREM BASIC_PREMIUM,
       DECODE (a.V_PYMT_FREQ, 0, 1, 12 / a.V_PYMT_FREQ) * b.N_IND_BASIC_PREM
          BASIC_ANNUAL_PREM,
       JHL_UTILS.RIDER_PREMIUM (a.V_POLICY_NO) RIDER_PREMIUM,
       N_PAYER_REF_NO,
       f.V_NAME POLICY_OWNER,
       JHL_UTILS.GET_PREV_STATUS (a.V_POLICY_NO) V_PREV_STATUS,
       a.V_CNTR_STAT_CODE,
       V_STATUS_DESC V_CURR_STATUS,
       a.V_PLAN_CODE,
       V_PLAN_NAME,
       a.D_NEXT_OUT_DATE,
       N_PREM_OS,
       NUM_DUE,
       N_RECEIPT_AMT,
       a.D_DISPATCH_DATE,
       a.D_ACKNOWLEDGE,
       (SELECT DISTINCT BRH.V_BRANCH_NAME
          FROM GNMM_BRANCH_MASTER BRH
         WHERE BRH.V_BRANCH_CODE = A.V_POLICY_BRANCH AND ROWNUM = 1)
          POLICY_BRANCH
  FROM GNMT_POLICY a,
       GNMT_POLICY_DETAIL b,
       AMMT_POL_AG_COMM c,
       GNLU_PAY_METHOD d,
       GNLU_FREQUENCY_MASTER e,
       GNMT_CUSTOMER_MASTER f,
       GNMM_POLICY_STATUS_MASTER g,
       GNMM_PLAN_MASTER h,
       (SELECT x.V_POLICY_NO,
               N_PREM_OS,
               NUM_DUE,
               N_RECEIPT_AMT
          FROM (  SELECT V_POLICY_NO,
                         SUM (N_AMOUNT) N_PREM_OS,
                         SUM (NUM_DUE) NUM_DUE
                    FROM (SELECT V_POLICY_NO,
                                 DECODE (V_STATUS, 'A', N_AMOUNT, 0) N_AMOUNT,
                                 DECODE (V_STATUS, 'A', 1, 0) NUM_DUE
                            FROM PPMT_OUTSTANDING_PREMIUM --WHERE V_POLICY_NO = 'IL201200137132'
                                                         )
                GROUP BY V_POLICY_NO) x,
               (  SELECT V_POLICY_NO, SUM (N_RECEIPT_AMT) N_RECEIPT_AMT
                    FROM REMT_RECEIPT
                   WHERE     V_RECEIPT_TABLE = 'DETAIL'
                         AND V_RECEIPT_STATUS = 'RE001'
                         AND V_RECEIPT_CODE IN ('RCT002', 'RCT003')
                GROUP BY V_POLICY_NO) y
         WHERE x.V_POLICY_NO = y.V_POLICY_NO(+) --AND x.v_policy_no = 'IL201200137132'
                                               ) i
 WHERE     a.V_POLICY_NO = b.V_POLICY_NO
       AND a.V_POLICY_NO = c.V_POLICY_NO
       AND a.V_PMT_METHOD_CODE = d.V_PMT_METHOD_CODE
       AND a.V_PYMT_FREQ = e.V_PYMT_FREQ
       AND V_ROLE_CODE = 'SELLING'
       AND c.V_STATUS = 'A'
       AND a.V_POLICY_NO NOT LIKE 'GL%'
       --AND D_ISSUE BETWEEN '01-JAN-2012' and '5-APR-2012'
       AND a.N_PAYER_REF_NO = f.N_CUST_REF_NO
       AND a.V_CNTR_STAT_CODE = g.V_STATUS_CODE
       AND a.V_PLAN_CODE = h.V_PLAN_CODE
       AND a.V_POLICY_NO = i.V_POLICY_NO
       AND EXTRACT(YEAR FROM a.D_COMMENCEMENT)=2023
       --AND a.v_policy_no = 'IL201200137132'
--       AND TRUNC (NVL (A.D_ISSUE, SYSDATE)) BETWEEN NVL (
--                                                       :P_ISSUE_FM,
--                                                       TRUNC (
--                                                          NVL (A.D_ISSUE,
--                                                               SYSDATE)))
--                                                AND NVL (
--                                                       :P_ISSUE_TO,
--                                                       TRUNC (
--                                                          NVL (A.D_ISSUE,
--                                                               SYSDATE)))
--       AND TRUNC (NVL (A.D_PROPOSAL_DATE, SYSDATE)) BETWEEN NVL (
--                                                               :P_PROPOSAL_FM,
--                                                               TRUNC (
--                                                                  NVL (
--                                                                     A.D_PROPOSAL_DATE,
--                                                                     SYSDATE)))
--                                                        AND NVL (
--                                                               :P_PROPOSAL_TO,
--                                                               TRUNC (
--                                                                  NVL (
--                                                                     A.D_PROPOSAL_DATE,
--                                                                     SYSDATE)))
AND D_ISSUE IS NOT NULL
)