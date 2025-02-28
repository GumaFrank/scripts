INSERT INTO JHLISFUADM.XXJICUG_GL_INTERFACE_STG (
    ogli_no,
    status,
    set_of_books_id,
    ledger_id,
    user_je_source_name,
    user_je_category_name,
    currency_code,
    actual_flag,
    accounting_date,
    date_created,
    created_by,
    entered_dr,
    entered_cr,
    segment1,
    segment2,
    segment3,
    segment4,
    segment5,
    segment6,
    segment7,
    segment8,
    group_id,
    reference5,
    reference10,
    reference6,
    reference_date,
    reference1,
    reference2,
    odi_posted,
    date_staged
)
select i.ogli_no,
       i.status,
       i.set_of_books_id,
       i.set_of_books_id,
       TRIM(i.user_je_source_name),
       TRIM(i.user_je_category_name),
       i.currency_code,
       i.actual_flag,
       i.accounting_date,
       i.date_created,
       i.created_by,
       i.entered_dr,
       i.entered_cr,
       i.segment1,
       i.segment2,
       i.segment3,
       i.segment4,
       i.segment5,
       i.segment6,
       i.segment7,
       i.segment8,
       i.group_id,
       i.reference5,
       i.reference10,
       i.reference6,
       i.reference_date,
       substr(i.reference1, 1, 99),
       i.reference2,
       'N',
       sysdate from (
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
           END
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
  AND OGLI_PROCESSED = 'Y' AND OGLI_POSTED = 'Y' and REFERENCE1 IN ('HQ240028639',
    'HQ240028641',
'HQ240028643'
    )) i;
