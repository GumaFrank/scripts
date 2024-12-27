PROCEDURE CREATE_OFA_RECEIVABLE_TRANS
IS
CURSOR REFS
    IS
    SELECT DISTINCT M.N_REF_NO N_REF_NO
    FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
    WHERE     M.N_REF_NO = D.N_REF_NO
      AND M.V_JOURNAL_STATUS = 'C'
      AND NVL (M.V_REMARKS, 'N') != 'X'
      AND V_DOCU_TYPE != 'VOUCHER'
      AND V_PROCESS_CODE NOT IN
          ('ACT021',
           'RIACT01',
           'ACT070',
           'ACT071',
           'PY_APR_RI',
           'PY_VRC_RI')
      AND TO_DATE (M.D_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
            '01-JAN-20',
            'DD/MM/RRRR')
        AND TO_DATE (
                        SYSDATE,
                        'DD/MM/RRRR')
      AND M.N_REF_NO NOT IN (SELECT ORT.N_REF_NO
                             FROM JHL_OFA_GL_TRANSACTIONS ORT
                             WHERE ORT.N_REF_NO = M.N_REF_NO);
BEGIN
    FOR I IN REFS
    LOOP
        INSERT INTO JHL_OFA_GL_TRANSACTIONS (OGLT_NO,
                                             N_REF_NO,
                                             D_DATE,
                                             V_BRANCH_CODE,
                                             V_LOB_CODE,
                                             V_PROCESS_CODE,
                                             V_PROCESS_NAME,
                                             V_DOCU_TYPE,
                                             V_DOCU_REF_NO,
                                             V_GL_CODE,
                                             V_DESC,
                                             V_TYPE,
                                             N_AMT,
                                             OFA_ACC_CODE,
                                             V_SOURCE_CURRENCY,
                                             V_POLAG_TYPE,
                                             V_POLAG_NO,
                                             D_POSTED_DATE,
                                             V_SUN_JV,
                                             OGLT_PROCESSED,
                                             OGLT_POSTED,
                                             OGLT_DATE,
                                             OGTL_DRCR_NARRATION)
        SELECT JHL_OGLT_NO_SEQ.NEXTVAL,
               M.N_REF_NO,
               M.D_DATE,
               NVL (V_BRANCH_CODE, 'HO'),
               V_LOB_CODE,
               NVL (V_PROCESS_CODE, 'N/A') V_PROCESS_CODE,
               NVL ( (SELECT V_PROCESS_NAME
                      FROM GNMM_PROCESS_MASTER
                      WHERE V_PROCESS_ID = V_PROCESS_CODE),
                     NVL (V_PROCESS_CODE, 'N/A'))
                       V_PROCESS_NAME,
               V_DOCU_TYPE,
               V_DOCU_REF_NO,
               V_GL_CODE,
               NVL (V_DESC, 'N/A'),
               V_TYPE,
               N_AMT,
               NVL ( (SELECT OFA_ACC_CODE
                      FROM JHL_ISF_OFA_ACC_MAP
                      WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                        AND TRIM (ACC_DESC) = TRIM (D.V_DESC)),
                     'N'),
               'UGX',
               M.V_POLAG_TYPE,
               M.V_POLAG_NO,
               M.D_POSTED_DATE,
               M.V_REMARKS,
               'N',
               'N',
               SYSDATE,
               'X'
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
        WHERE     M.N_REF_NO = D.N_REF_NO
          AND M.V_JOURNAL_STATUS = 'C'
          AND NVL (M.V_REMARKS, 'N') != 'X'
          AND V_DOCU_TYPE != 'VOUCHER'
          AND V_PROCESS_CODE NOT IN ('ACT021', 'RIACT01');
        COMMIT;
    END LOOP;
END;



























PROCEDURE CREATE_OFA_RECEIVABLE_TRANS
IS
CURSOR REFS
    IS
    SELECT DISTINCT M.N_REF_NO N_REF_NO
    FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
    WHERE     M.N_REF_NO = D.N_REF_NO
      AND M.V_JOURNAL_STATUS = 'C'
      AND NVL (M.V_REMARKS, 'N') != 'X'
      AND V_DOCU_TYPE != 'VOUCHER'
      AND V_PROCESS_CODE NOT IN
          ('ACT021',
           'RIACT01',
           'ACT070',
           'ACT071',
           'PY_APR_RI',
           'PY_VRC_RI')
      AND TO_DATE (M.D_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
            '01-MAY-2024',
            'DD/MM/RRRR')
        AND TO_DATE (
            '31-MAY-2024',
            'DD/MM/RRRR')
      AND M.N_REF_NO NOT IN (SELECT ORT.N_REF_NO
                             FROM JHL_OFA_GL_TRANSACTIONS ORT
                             WHERE ORT.N_REF_NO = M.N_REF_NO);
BEGIN
    FOR I IN REFS
    LOOP
        INSERT INTO JHL_OFA_GL_TRANSACTIONS (OGLT_NO,
                                             N_REF_NO,
                                             D_DATE,
                                             V_BRANCH_CODE,
                                             V_LOB_CODE,
                                             V_PROCESS_CODE,
                                             V_PROCESS_NAME,
                                             V_DOCU_TYPE,
                                             V_DOCU_REF_NO,
                                             V_GL_CODE,
                                             V_DESC,
                                             V_TYPE,
                                             N_AMT,
                                             OFA_ACC_CODE,
                                             V_SOURCE_CURRENCY,
                                             V_POLAG_TYPE,
                                             V_POLAG_NO,
                                             D_POSTED_DATE,
                                             V_SUN_JV,
                                             OGLT_PROCESSED,
                                             OGLT_POSTED,
                                             OGLT_DATE,
                                             OGTL_DRCR_NARRATION)
        SELECT JHL_OGLT_NO_SEQ.NEXTVAL,
               M.N_REF_NO,
               M.D_DATE,
               NVL (V_BRANCH_CODE, 'HO'),
               V_LOB_CODE,
               NVL (V_PROCESS_CODE, 'N/A') V_PROCESS_CODE,
               NVL ( (SELECT V_PROCESS_NAME
                      FROM GNMM_PROCESS_MASTER
                      WHERE V_PROCESS_ID = V_PROCESS_CODE),
                     NVL (V_PROCESS_CODE, 'N/A'))
                       V_PROCESS_NAME,
               V_DOCU_TYPE,
               V_DOCU_REF_NO,
               V_GL_CODE,
               NVL (V_DESC, 'N/A'),
               V_TYPE,
               N_AMT,
               NVL ( (SELECT OFA_ACC_CODE
                      FROM JHL_ISF_OFA_ACC_MAP
                      WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                        AND TRIM (ACC_DESC) = TRIM (D.V_DESC)),
                     'N'),
               'UGX',
               M.V_POLAG_TYPE,
               M.V_POLAG_NO,
               M.D_POSTED_DATE,
               M.V_REMARKS,
               'N',
               'N',
               SYSDATE,
               'X'
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
        WHERE     M.N_REF_NO = D.N_REF_NO
          AND M.V_JOURNAL_STATUS = 'C'
          AND NVL (M.V_REMARKS, 'N') != 'X'
          AND V_DOCU_TYPE != 'VOUCHER'
          AND V_PROCESS_CODE NOT IN ('ACT021', 'RIACT01');
        COMMIT;
    END LOOP;
END;

--executing for now

BEGIN
    CREATE_OFA_RECEIVABLE_TRANS;
END;
/
