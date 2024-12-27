

BEGIN
    TRANSFORM_OFA_RECEIVABLE_TRANS;
END;
/




PROCEDURE TRANSFORM_OFA_RECEIVABLE_TRANS
IS
    CURSOR RCT_SUMMARY
    IS
    SELECT DISTINCT V_DOCU_REF_NO, TO_DATE (D_DATE, 'DD/MM/RRRR') D_DATE
    FROM JHL_OFA_GL_TRANSACTIONS
    WHERE     V_DOCU_TYPE = 'RECEIPT'
      AND OGLT_PROCESSED <> 'Y'
      AND TO_DATE (D_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
            '01-JAN-20',
            'DD/MM/RRRR')
        AND TO_DATE (
                        SYSDATE,
                        'DD/MM/RRRR');

    CURSOR NON_RCT_SUMMARY
    IS
    SELECT DISTINCT
        V_PROCESS_CODE,
        V_LOB_CODE,
        TO_DATE (D_DATE, 'DD/MM/RRRR') D_DATE
    FROM JHL_OFA_GL_TRANSACTIONS
    WHERE     V_DOCU_TYPE <> 'RECEIPT'
      AND OGLT_PROCESSED <> 'Y'
      AND TO_DATE (D_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
            '01-JAN-20',
            'DD/MM/RRRR')
        AND TO_DATE (
                        SYSDATE,
                        'DD/MM/RRRR');

    V_VGL_NO   NUMBER;
BEGIN
    UPDATE JHL_OFA_GL_TRANSACTIONS
    SET V_LOB_CODE =
            DECODE (JHL_GEN_PKG.GET_ENTRY_CHANNEL (N_REF_NO),
                    30, 'LOB003',
                    10, 'LOB001',
                    'LOB001')
    WHERE     OGLT_PROCESSED <> 'Y'
      AND V_LOB_CODE = 'MIS'
      AND V_PROCESS_CODE IN ('AGCOMMPYMT', 'A0001-PROV');

    UPDATE JHL_OFA_GL_TRANSACTIONS
    SET V_LOB_CODE =
            (SELECT DECODE (N_CHANNEL_NO,
                            30, 'LOB003',
                            10, 'LOB001',
                            'LOB001')
             FROM AMMM_AGENT_MASTER
             WHERE N_AGENT_NO = (SELECT N_AGENT_NO
                                 FROM AMDT_AGENT_BENE_POOL_PAYMENT
                                 WHERE N_VOUCHER_NO = V_DOCU_REF_NO))
    WHERE     OGLT_PROCESSED <> 'Y'
      AND V_LOB_CODE = 'MIS'
      AND V_PROCESS_CODE IN ('ACT020');

    UPDATE JHL_OFA_GL_TRANSACTIONS
    SET OFA_ACC_CODE = '201206'
    WHERE     V_LOB_CODE = 'LOB001'
      AND OFA_ACC_CODE = '201209'
      AND OGLT_PROCESSED <> 'Y';

    UPDATE JHL_OFA_GL_TRANSACTIONS
    SET OGTL_DRCR_NARRATION =
            NVL (
                    (SELECT    V_COMPANY_NAME
                                   || '-'
                                   || N_VOUCHER_NO
                                   || '-'
                                   || N_GROSS_AMOUNT
                     FROM AMDT_AGENT_BENEFIT_POOL_DETAIL C,
                          AMDT_AGENT_BENE_POOL_PAYMENT D,
                          AMMM_AGENT_MASTER E,
                          GNMM_COMPANY_MASTER F
                     WHERE     V_TRANS_SOURCE_CODE = 'INCOME_TAX'
                       AND C.N_BENEFIT_POOL_PAY_SEQ =
                           D.N_BENEFIT_POOL_PAY_SEQ
                       AND C.N_AGENT_NO = E.N_AGENT_NO
                       AND E.V_COMPANY_CODE = F.V_COMPANY_CODE
                       AND E.V_COMPANY_BRANCH = F.V_COMPANY_BRANCH
                       AND C.N_REF_NO = JHL_OFA_GL_TRANSACTIONS.N_REF_NO),
                    OGTL_DRCR_NARRATION)
    WHERE     OGLT_PROCESSED <> 'Y'
      AND V_PROCESS_CODE IN ('AGCOMMPYMT', 'A0001-PROV');

    FOR R IN RCT_SUMMARY LOOP
        SELECT JGL_OFA_VGL_NO_SEQ.NEXTVAL INTO V_VGL_NO FROM DUAL;

        NULL;

        UPDATE JHL_OFA_GL_TRANSACTIONS
        SET OGLT_PROCESSED = 'Y',
            OGLT_PROCESSED_DT = SYSDATE,
            OFA_VGL_NO = V_VGL_NO,
            OFA_VGL_CODE =
                'OFA_JV_' || TO_CHAR (R.D_DATE, 'YYYY') || '_' || V_VGL_NO
        WHERE     V_DOCU_REF_NO = R.V_DOCU_REF_NO
          AND TO_DATE (D_DATE, 'DD/MM/RRRR') =
              TO_DATE (R.D_DATE, 'DD/MM/RRRR')
          AND V_DOCU_TYPE = 'RECEIPT'
          AND OGLT_PROCESSED <> 'Y';

    END LOOP;

    FOR C IN NON_RCT_SUMMARY LOOP

        SELECT JGL_OFA_VGL_NO_SEQ.NEXTVAL INTO V_VGL_NO FROM DUAL;

        UPDATE JHL_OFA_GL_TRANSACTIONS
        SET OGLT_PROCESSED = 'Y',
            OGLT_PROCESSED_DT = SYSDATE,
            OFA_VGL_NO = V_VGL_NO,
            OFA_VGL_CODE =
                'OFA_JV_' || TO_CHAR (C.D_DATE, 'YYYY') || '_' || V_VGL_NO
        WHERE     V_PROCESS_CODE = C.V_PROCESS_CODE
          AND V_LOB_CODE = C.V_LOB_CODE
          AND TO_DATE (D_DATE, 'DD/MM/RRRR') =
              TO_DATE (C.D_DATE, 'DD/MM/RRRR')
          AND V_DOCU_TYPE <> 'RECEIPT'
          AND OGLT_PROCESSED <> 'Y';

        UPDATE GNMT_GL_MASTER GL
        SET V_REMARKS =
                'OFA_JV_' || TO_CHAR (C.D_DATE, 'YYYY') || '_' || V_VGL_NO
        WHERE GL.N_REF_NO IN (SELECT DISTINCT TRN.N_REF_NO
                              FROM JHL_OFA_GL_TRANSACTIONS TRN
                              WHERE TRN.OFA_VGL_NO = V_VGL_NO);

    END LOOP;

    COMMIT;
END;


/*

HL_OFA_GL_TRANSACTIONS Table:
The procedure updates this table with the following changes:
V_LOB_CODE Field: Updated based on entry channel or agent information.
OFA_ACC_CODE Field: Updated with the correct account code where applicable.
OGTL_DRCR_NARRATION Field: Updated with a detailed narration based on related records.
OGLT_PROCESSED Field: Set to 'Y' to mark the transaction as processed.
OFA_VGL_NO Field: Assigned a unique voucher number.
OFA_VGL_CODE Field: Updated with a generated code based on the date.
These updates effectively prepare the transactions for further processing, such as posting
 to the General Ledger. The changes made to the JHL_OFA_GL_TRANSACTIONS table by this procedure 
 are critical for ensuring that the financial 
data is correctly processed and ready for the next steps in the transaction flow.
*/