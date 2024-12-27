
SELECT V_AGENT_CODE,

         A.V_ADVANCE_CODE,

         V_ADVANCE_DESC,

         A.N_AG_ADVANCE_SEQ_NO,

         A.V_STATUS,

         N_AMOUNT_PAID  APPROVED_AMOUNT,

         V_AMOUNT DEDUCTED_AMOUNT,

         N_BALANCE_AMOUNT,

         V_POLICY_NO,

         V_PYMT_FREQ,

         D_NEXT_DED_DATE,

         V_VOUCHER_NO,

         D_VOUCHER_DATE,

         D_TRANS_DATE,

         A.V_APPROVED_BY

    FROM AMMT_AG_ADVANCES A,

         AMDT_AG_ADV_TRANSACTIONS B,

         AMMM_AGENT_MASTER C,

         AMMM_ADVANCE_MASTER D

   WHERE   A.V_ADVANCE_CODE NOT IN ('A0001') 

         AND A.N_AGENT_NO = C.N_AGENT_NO

         AND A.V_ADVANCE_CODE = D.V_ADVANCE_CODE

         AND A.N_AG_ADVANCE_SEQ_NO = B.N_AG_ADVANCE_SEQ_NO(+)

         AND V_TRANS_TYPE = 'RPMT'

        --- AND A.V_ADVANCE_CODE = 'PREMDET'

         --and   a.N_AG_ADVANCE_SEQ_NO=47

        -- AND D_trans_date BETWEEN :from_date AND :to_date

--         And Trunc (D_trans_date) Between To_Date(?,'DD/MM/YYYY') AND To_Date(?,'DD/MM/YYYY')

--           AND TRUNC (D_TRANS_DATE) BETWEEN :P_FM_DT  AND :P_TO_DT

--and a.N_AGENT_NO =6565

        AND EXTRACT(YEAR FROM D_trans_date)>= 2023

ORDER BY A.N_AGENT_NO,

         V_ADVANCE_CODE,

         D_TRANS_DATE,

         A.N_AG_ADVANCE_SEQ_NO