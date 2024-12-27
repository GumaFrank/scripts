BEGIN
    TRANSFORM_OFA_GL_TRANS;
END;



PROCEDURE TRANSFORM_OFA_GL_TRANS
IS
    CURSOR RCT_TRANS
    IS
    SELECT 'NEW' STATUS,
           '2088' SET_OF_BOOKS_ID,
           'ISF LIFE' USER_JE_SOURCE_NAME,
           DECODE (V_DOCU_TYPE, 'RECEIPT', 'ISF Receipts', 'ISF Others')
               USER_JE_CATEGORY_NAME,
           V_SOURCE_CURRENCY CURRENCY_CODE,
           'A' ACTUAL_FLAG,
           TO_CHAR (D_DATE, 'DD-MON-YY') ACCOUNTING_DATE,
           TO_CHAR (D_DATE, 'DD-MON-YY') DATE_CREATED,
           0 CREATED_BY,
           DECODE (V_TYPE, 'D', N_AMT, NULL) ENTERED_DR,
           DECODE (V_TYPE, 'C', N_AMT, NULL) ENTERED_CR,
           '221' SEGMENT1,
           DECODE (V_BRANCH_CODE, 'HO', '210', '000') SEGMENT2,
           '00' SEGMENT3,
           DECODE (V_LOB_CODE,  'LOB001', '12',  'LOB003', '11','LOB004', '13','LOB005', '14','LOB002', '63',  '00')
               SEGMENT4,
           OFA_ACC_CODE SEGMENT5,
           '00' SEGMENT6,
           '000' SEGMENT7,
           '000' SEGMENT8,
           OFA_VGL_NO GROUP_ID,
           V_DOCU_TYPE || '-' || V_PROCESS_CODE || '-' || V_PROCESS_NAME
               JOURNAL_DESCRIPTION,
           V_DESC LINE_DESCRIPTION,
           OFA_VGL_NO REFERENCE,
           TO_CHAR (D_DATE, 'DD-MON-YY') REFERENCE_DATE,
           V_DOCU_REF_NO REFERENCE1,
           V_DOCU_TYPE REFERENCE2,
           NULL N_REF_NO,
           V_BRANCH_CODE,
           V_LOB_CODE,
           V_PROCESS_CODE,
           V_DOCU_TYPE,
           D_DATE,
           OFA_VGL_NO,
           OFA_VGL_CODE
    FROM (  SELECT TO_DATE (D_DATE, 'DD/MM/RRRR') D_DATE,
                   V_BRANCH_CODE,
                   V_LOB_CODE,
                   V_PROCESS_CODE,
                   V_PROCESS_NAME,
                   V_DOCU_TYPE,
                   V_DOCU_REF_NO,
                   V_GL_CODE,
                   V_DESC,
                   V_TYPE,
                   SUM (N_AMT) N_AMT,
                   OFA_ACC_CODE,
                   V_SOURCE_CURRENCY,
                   OFA_VGL_NO,
                   OFA_VGL_CODE
            FROM JHL_OFA_GL_TRANSACTIONS TRANS
            WHERE     1 = 1
              AND OGLT_PROCESSED = 'Y'
              AND OGLT_POSTED = 'N'
              AND V_DOCU_TYPE = 'RECEIPT'
              AND TRANS.OFA_VGL_NO NOT IN
                  (SELECT OFA_VGL_NO
                   FROM JHL_OFA_GL_INTERFACE INTER
                   WHERE INTER.OFA_VGL_NO = TRANS.OFA_VGL_NO)
            GROUP BY TO_DATE (D_DATE, 'DD/MM/RRRR'),
                     V_BRANCH_CODE,
                     V_LOB_CODE,
                     V_PROCESS_CODE,
                     V_PROCESS_NAME,
                     V_DOCU_TYPE,
                     V_DOCU_REF_NO,
                     V_GL_CODE,
                     V_DESC,
                     V_TYPE,
                     OFA_ACC_CODE,
                     V_SOURCE_CURRENCY,
                     OFA_VGL_NO,
                     OFA_VGL_CODE);
BEGIN
    FOR REC IN RCT_TRANS LOOP
        -- Transformation logic to prepare the transactions for GL_INTERFACE
        NULL; -- Placeholder for actual processing logic
    END LOOP;

    COMMIT;
END;
