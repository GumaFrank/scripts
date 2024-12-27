
/* Formatted on 08/08/2024 09:21:44 (QP5 v5.215.12089.38647) */
  SELECT *
    FROM (  SELECT c.v_agent_code,
                   a.N_AGENT_NO,
                   v_name,
                   a.N_AG_ADVANCE_SEQ_NO,
                   D_ADVANCE_DATE,
                   D_DEDN_START_DATE,
                   D_DEDN_END_DATE,
                   D_NEXT_DED_DATE,
                   N_AMOUNT_PAID,
                   N_BALANCE_AMOUNT,
                   A_INST_AMOUNT,
                   DECODE (a.V_STATUS,
                           'I', 'INACTIVE',
                           'R', 'REJECTED',
                           'A', 'ACTIVE')
                      V_STATUS,
                   a.V_APPROVED_BY,
                   V_AMOUNT,
                   D_TRANS_DATE,
                   V_VOUCHER_NO,
                   D_VOUCHER_DATE
              FROM ammt_ag_advances a,
                   amdt_ag_adv_transactions b,
                   ammm_agent_master c,
                   GNMT_CUSTOMER_MASTER d
             WHERE     V_ADVANCE_CODE = 'ADV'
                   AND a.N_AG_ADVANCE_SEQ_NO = b.N_AG_ADVANCE_SEQ_NO
                   AND a.N_AGENT_NO = c.N_AGENT_NO
                   AND c.N_CUST_REF_NO = d.N_CUST_REF_NO
          ORDER BY a.N_AG_ADVANCE_SEQ_NO, D_TRANS_DATE)
ORDER BY D_TRANS_DATE DESC
