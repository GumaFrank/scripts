-- sending to GL_INTERFACE@JICOFPROD

PROCEDURE SEND_GL_TRANS_TO_OFA
IS
    CURSOR TRANS
    IS
    SELECT OGLI_NO,
           STATUS,
           SET_OF_BOOKS_ID,
           USER_JE_SOURCE_NAME,
           USER_JE_CATEGORY_NAME,
           CURRENCY_CODE,
           ACTUAL_FLAG,
           CASE
               WHEN ROUND (TRUNC (SYSDATE) - TRUNC (D_DATE)) <= 30
                   THEN
                   ACCOUNTING_DATE
               ELSE
                   TO_CHAR (SYSDATE, 'DD-MON-YY')
               END ACCOUNTING_DATE,
           DATE_CREATED,
           CREATED_BY,
           ENTERED_DR,
           ENTERED_CR,
           SEGMENT1,
           SEGMENT2,
           SEGMENT3,
           SEGMENT4,
           SEGMENT5,
           SEGMENT6,
           SEGMENT7,
           SEGMENT8,
           GROUP_ID,
           JOURNAL_DESCRIPTION,
           LINE_DESCRIPTION,
           TO_CHAR (NVL (OGLI_RCT_PAYEE, REFERENCE)) REFERENCE,
           REFERENCE_DATE,
           DECODE (
                   OGLI_RECEIPT_SOURCE,
                   'OFF_REC', NVL (OGLI_RECEIPT_NO, REFERENCE1),
                   DECODE (NVL (OGLI_RECEIPT_NO, 'XX'),
                           'XX', REFERENCE1,
                           REFERENCE1 || '-' || OGLI_RECEIPT_NO))
               REFERENCE1,
           REFERENCE2,
           N_REF_NO,
           V_BRANCH_CODE,
           V_LOB_CODE,
           V_PROCESS_CODE,
           REFERENCE5,
           TO_CHAR (NVL (OGLI_RCT_PAYEE, REFERENCE)) REFERENCE6,
           DECODE (
                   NVL (OGLI_INS_NUMBER, 'XX'),
                   'XX', DECODE (NVL (OGLI_RECEIPT_NO, 'XX'),
                                 'XX', REFERENCE1,
                                 REFERENCE1 || '-' || OGLI_RECEIPT_NO),
                   DECODE (NVL (OGLI_RECEIPT_NO, 'XX'),
                           'XX', REFERENCE1,
                           REFERENCE1 || '-' || OGLI_RECEIPT_NO)
                       || ' - '
                       || OGLI_INS_NUMBER)
               REFERENCE10,
           OGLI_PROCESSED,
           V_DOCU_TYPE,
           OFA_VGL_NO,
           OFA_VGL_CODE,
           OGLI_POSTED,
           D_DATE
    FROM JHL_OFA_GL_INTERFACE
    WHERE 1 = 1
      AND OGLI_PROCESSED = 'Y' 
      AND OGLI_POSTED = 'N'
    UNION ALL
    SELECT OGLI_NO,
           STATUS,
           SET_OF_BOOKS_ID,
           USER_JE_SOURCE_NAME,
           USER_JE_CATEGORY_NAME,
           CURRENCY_CODE,
           ACTUAL_FLAG,
           CASE
               WHEN ROUND (TRUNC (SYSDATE) - TRUNC (D_DATE)) <= 30
                   THEN
                   ACCOUNTING_DATE
               ELSE
                   TO_CHAR (SYSDATE, 'DD-MON-YY')
               END ACCOUNTING_DATE,
           DATE_CREATED,
           CREATED_BY,
           ENTERED_DR,
           ENTERED_CR,
           SEGMENT1,
           SEGMENT2,
           SEGMENT3,
           SEGMENT4,
           SEGMENT5,
           SEGMENT6,
           SEGMENT7,
           SEGMENT8,
           GROUP_ID,
           JOURNAL_DESCRIPTION,
           LINE_DESCRIPTION,
           TO_CHAR (NVL (OGLI_RCT_PAYEE, REFERENCE)) REFERENCE,
           REFERENCE_DATE,
           DECODE (
                   OGLI_RECEIPT_SOURCE,
                   'OFF_REC', NVL (OGLI_RECEIPT_NO, REFERENCE1),
                   DECODE (NVL (OGLI_RECEIPT_NO, 'XX'),
                           'XX', REFERENCE1,
                           REFERENCE1 || '-' || OGLI_RECEIPT_NO))
               REFERENCE1,
           REFERENCE2,
           N_REF_NO,
           V_BRANCH_CODE,
           V_LOB_CODE,
           V_PROCESS_CODE,
           REFERENCE5,
           TO_CHAR (NVL (OGLI_RCT_PAYEE, REFERENCE)) REFERENCE6,
           DECODE (
                   NVL (OGLI_INS_NUMBER, 'XX'),
                   'XX', DECODE (NVL (OGLI_RECEIPT_NO, 'XX'),
                                 'XX', REFERENCE1,
                                 REFERENCE1 || '-' || OGLI_RECEIPT_NO),
                   DECODE (NVL (OGLI_RECEIPT_NO, 'XX'),
                           'XX', REFERENCE1,
                           REFERENCE1 || '-' || OGLI_RECEIPT_NO)
                       || ' - '
                       || OGLI_INS_NUMBER)
               REFERENCE10,
           OGLI_PROCESSED,
           V_DOCU_TYPE,
           OFA_VGL_NO,
           OFA_VGL_CODE,
           OGLI_POSTED,
           D_DATE
    FROM JHL_OFA_GL_INTERFACE
    WHERE 1 = 1
      AND OGLI_PROCESSED = 'Y'
      AND OGLI_POSTED = 'N'
    ORDER BY REFERENCE1;

BEGIN
    FOR I IN TRANS LOOP
        INSERT INTO APPS.GL_INTERFACE@JICOFPROD.COM
            (STATUS,
             SET_OF_BOOKS_ID,
             LEDGER_ID,
             USER_JE_SOURCE_NAME,
             USER_JE_CATEGORY_NAME,
             CURRENCY_CODE,
             ACTUAL_FLAG,
             ACCOUNTING_DATE,
             DATE_CREATED,
             CREATED_BY,
             ENTERED_DR,
             ENTERED_CR,
             SEGMENT1,
             SEGMENT2,
             SEGMENT3,
             SEGMENT4,
             SEGMENT5,
             SEGMENT6,
             SEGMENT7,
             SEGMENT8,
             GROUP_ID,
             REFERENCE5,
             REFERENCE10,
             REFERENCE6,
             REFERENCE_DATE,
             REFERENCE1,
             REFERENCE2)
        VALUES
            (I.STATUS,
             I.SET_OF_BOOKS_ID,
             I.SET_OF_BOOKS_ID,
             TRIM (I.USER_JE_SOURCE_NAME),
             TRIM (I.USER_JE_CATEGORY_NAME),
             I.CURRENCY_CODE,
             I.ACTUAL_FLAG,
             I.ACCOUNTING_DATE,
             I.DATE_CREATED,
             I.CREATED_BY,
             I.ENTERED_DR,
             I.ENTERED_CR,
             I.SEGMENT1,
             I.SEGMENT2,
             I.SEGMENT3,
             I.SEGMENT4,
             I.SEGMENT5,
             I.SEGMENT6,
             I.SEGMENT7,
             I.SEGMENT8,
             I.GROUP_ID,
             I.REFERENCE5,
             I.REFERENCE10,
             I.REFERENCE6,
             I.REFERENCE_DATE,
             I.REFERENCE1,
             I.REFERENCE2);

        UPDATE JHL_OFA_GL_INTERFACE
        SET OGLI_POSTED = 'Y', OGLI_POSTED_DATE = SYSDATE
        WHERE OGLI_NO = I.OGLI_NO;

    END LOOP;

    COMMIT;
END;
/

/*

Key Points:
Processing: The procedure retrieves records from JHL_OFA_GL_INTERFACE where the records have been processed (OGLI_PROCESSED = 'Y') but not yet posted (OGLI_POSTED = 'N').
Posting: It then posts these records to the GL_INTERFACE table in the Oracle General Ledger.
Status Update: After posting, it updates the OGLI_POSTED status in the JHL_OFA_GL_INTERFACE table to mark the records as posted.
This procedure is critical for moving the finalized data from the staging area (JHL_OFA_GL_INTERFACE) into the official ledger interface table (GL_INTERFACE).

*/