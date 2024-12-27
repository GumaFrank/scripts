



PROCEDURE OFA_GL_TRANS_PROC
IS
    V_START_DATE   DATE;
BEGIN
    V_START_DATE := SYSDATE;

    CREATE_OFA_RECEIVABLE_TRANS;
    TRANSFORM_OFA_RECEIVABLE_TRANS;
    TRANSFORM_OFA_GL_TRANS;
    SEND_GL_TRANS_TO_OFA;

    INSERT INTO JHL_OFA_JOBS (OJB_ID,
                              OJB_NAME,
                              OJB_START_DT,
                              OJB_END_DT)
    VALUES (JHL_OJB_ID_SEQ.NEXTVAL,
            'ofa_gl_trans_proc',
            V_START_DATE,
            SYSDATE);

    COMMIT;
END;


/*
Explanation:
CREATE_OFA_RECEIVABLE_TRANS: This procedure creates receivable transactions.
TRANSFORM_OFA_RECEIVABLE_TRANS: It transforms and updates these transactions.
TRANSFORM_OFA_GL_TRANS: Further processes the transactions for posting.
SEND_GL_TRANS_TO_OFA: Posts the transactions to the GL_INTERFACE table.
Finally, the procedure logs the job execution in the JHL_OFA_JOBS table and commits all changes



*/