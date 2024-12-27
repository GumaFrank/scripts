CREATE OR REPLACE PACKAGE BODY             JHL_GEN_PKG
AS

    P_POLICY_NO  VARCHAR2(100);
    
   PROCEDURE RAISE_ERROR (V_MSG IN VARCHAR2, V_ERR_NO IN NUMBER := NULL)
   IS
   BEGIN
      IF V_ERR_NO IS NULL
      THEN
         RAISE_APPLICATION_ERROR (
            -20015,
            V_MSG || ' - ' || SUBSTR (SQLERRM (SQLCODE), 10));
      ELSE
         RAISE_APPLICATION_ERROR (
            V_ERR_NO,
            V_MSG || ' - ' || SUBSTR (SQLERRM (SQLCODE), 10));
      END IF;
   END RAISE_ERROR;


   FUNCTION CHECK_SAME_BANK (BRANCH_CODE       VARCHAR,
                             COMPANY_CODE      VARCHAR,
                             COMPANY_BRANCH    VARCHAR)
      RETURN VARCHAR2
   IS
      V_RET_VALUE   VARCHAR2 (1) := 'N';

      V_CO_NAME     VARCHAR2 (500);

      CURSOR BANK_BRANCHES
      IS
         SELECT V_BANK_NAME
           FROM JHL_RCT_BRH_BANKS
          WHERE V_BRANCH_CODE = BRANCH_CODE;
   BEGIN
      ---- get bank name

      BEGIN
         SELECT V_COMPANY_NAME
           INTO V_CO_NAME
           FROM GNMM_COMPANY_MASTER
          WHERE V_COMPANY_CODE = COMPANY_CODE
                AND V_COMPANY_BRANCH = COMPANY_BRANCH;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'N';
      END;



      FOR I IN BANK_BRANCHES
      LOOP
         --                   RAISE_ERROR('v_co_name=='||v_co_name||'V_BANK_NAME=='||i.V_BANK_NAME);

         IF INSTR (V_CO_NAME, I.V_BANK_NAME) > 0
         THEN
            RETURN 'Y';
         END IF;
      END LOOP;


      RETURN V_RET_VALUE;
   END;


   FUNCTION CHECK_VALID_PIN (V_ASSURED_PIN VARCHAR, V_PAYER_PIN VARCHAR)
      RETURN VARCHAR2
   IS
      V_RET_VALUE       VARCHAR2 (1) := 'N';
      V_ASSURED_VALUE   VARCHAR2 (1) := 'N';
      V_PAYER_VALUE     VARCHAR2 (1) := 'N';

      V_CO_NAME         VARCHAR2 (500);
   BEGIN
      IF NVL (LENGTH (V_ASSURED_PIN), 0) <> 11
      THEN
         V_ASSURED_VALUE := 'N';
      ELSE
         IF (LENGTH (
                TRIM (
                   TRANSLATE (
                      TRIM (SUBSTR (V_ASSURED_PIN, 1, 1)),
                      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                      ' ')))
                IS NOT NULL
             OR LENGTH (
                   TRIM (
                      TRANSLATE (
                         TRIM (SUBSTR (V_ASSURED_PIN, 11, 11)),
                         'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                         ' ')))
                   IS NOT NULL)
         THEN
            V_ASSURED_VALUE := 'N';
         ELSE
            V_ASSURED_VALUE := 'Y';
         END IF;
         
          IF   nvl( LENGTH(TRIM(TRANSLATE(V_ASSURED_PIN, ' +-.0123456789',' '))),0) = 2 THEN
              V_ASSURED_VALUE := 'Y';
          ELSE
           V_ASSURED_VALUE := 'N';
         END IF; 
         
      END IF;

      --    RAISE_ERROR('v_assured_pin=='||v_assured_pin||' v_assured_value=='||v_assured_value||'LEN='||NVL(LENGTH(v_assured_pin),0));

      IF NVL (LENGTH (V_PAYER_PIN), 0) <> 11
      THEN
         V_PAYER_VALUE := 'N';
      ELSE
      
         IF (LENGTH (
                TRIM (
                   TRANSLATE (
                      TRIM (SUBSTR (V_PAYER_PIN, 1, 1)),
                      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                      ' ')))
                IS NOT NULL
             OR LENGTH (
                   TRIM (
                      TRANSLATE (
                         TRIM (SUBSTR (V_PAYER_PIN, 11, 11)),
                         'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                         ' ')))
                   IS NOT NULL)
         THEN
            V_PAYER_VALUE := 'N';
         ELSE
            V_PAYER_VALUE := 'Y';
         END IF;
         
         IF   nvl( LENGTH(TRIM(TRANSLATE(V_PAYER_PIN, ' +-.0123456789',' '))),0) = 2 THEN
              V_PAYER_VALUE := 'Y';
          ELSE
           V_PAYER_VALUE := 'N';
         END IF; 
         
      END IF;


      IF (V_PAYER_VALUE = 'N' AND V_ASSURED_VALUE = 'N')
      THEN
         V_RET_VALUE := 'N';
      ELSE
         V_RET_VALUE := 'Y';
      END IF;

      --RAISE_ERROR('v_payer_value=='||v_payer_value||'v_assured_value=='||v_assured_value||'v_ret_value=='||v_ret_value);

      RETURN V_RET_VALUE;
   END;



   PROCEDURE CREATE_USER_LIMIT (V_USER_NAME    VARCHAR2,
                                V_FROM_AMT     NUMBER,
                                V_TO_AMT       NUMBER)
   IS
   BEGIN
      INSERT INTO JHL_USER_LIMITS (USRL_NO,
                                   V_USER_NAME,
                                   USRL_FROM_AMT,
                                   USRL_FROM_TO,
                                   USRL_USR_SIGNATURE,
                                   USRL_DATE,
                                   USRL_BY)
           VALUES (JHL_USRL_NO_SEQ.NEXTVAL,
                   V_USER_NAME,
                   V_FROM_AMT,
                   V_TO_AMT,
                   NULL,
                   SYSDATE,
                   'JHLISFADMIN');
   END;



   FUNCTION GET_POL_SIGN_USER (POLICY_NO VARCHAR)
      RETURN VARCHAR2
   IS
      V_USR_NAME   VARCHAR2 (100);
      V_COUNT      NUMBER := 0;

      CURSOR POL
      IS
         SELECT V_POLICY_NO,
                V_UNDERWRITER,
                N_REQUEST_SA,
                V_LASTUPD_USER,
                N_SUM_COVERED,
                N_CONTRIBUTION
           FROM GNMT_POLICY
          WHERE V_POLICY_NO = POLICY_NO;
   BEGIN
      FOR I IN POL
      LOOP
         BEGIN
            SELECT V_USER_NAME
              INTO V_USR_NAME
              FROM JHL_USER_LIMITS
--             WHERE V_USER_NAME = NVL(JHL_GEN_PKG.GET_POLICY_STATUS_USER(POLICY_NO,'I') ,  NVL (I.V_UNDERWRITER, I.V_LASTUPD_USER))
             WHERE V_USER_NAME = I.V_UNDERWRITER
                   AND I.N_SUM_COVERED BETWEEN USRL_FROM_AMT AND USRL_FROM_TO;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_USR_NAME := NULL;
         END;

         --        RAISE_ERROR('v_usr_name=='||v_usr_name||'N_SUM_COVERED'||I.N_SUM_COVERED||'V_UNDERWRITER=='||NVL(I.V_UNDERWRITER,I.V_LASTUPD_USER) );

         IF V_USR_NAME IS NULL
         THEN
            BEGIN
               SELECT V_USER_NAME
                 INTO V_USR_NAME
                 FROM JHL_USER_LIMITS
                WHERE I.N_SUM_COVERED BETWEEN USRL_FROM_AMT AND USRL_FROM_TO;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT V_USER_NAME
                       INTO V_USR_NAME
                       FROM JHL_USER_LIMITS
                      WHERE USRL_DEFAULT = 'Y';
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        V_USR_NAME := 'KKANANUA';
                  END;
               WHEN OTHERS
               THEN
                  V_USR_NAME := NVL (I.V_UNDERWRITER, I.V_LASTUPD_USER);
            END;
         END IF;
      END LOOP;


      BEGIN
         SELECT COUNT (*)
           INTO V_COUNT
           FROM JHL_USER_LIMITS
          WHERE V_USER_NAME = V_USR_NAME;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_COUNT := 0;
      END;

      IF V_USR_NAME IS NULL OR V_COUNT = 0 OR V_USR_NAME = 'JHLISFADMIN'
      THEN
         BEGIN
            SELECT V_USER_NAME
              INTO V_USR_NAME
              FROM JHL_USER_LIMITS
             WHERE USRL_DEFAULT = 'Y';
         EXCEPTION
            WHEN OTHERS
            THEN
               V_USR_NAME := 'KKANANUA';
         END;
      END IF;


      RETURN V_USR_NAME;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'KKANANUA';
   END;



   FUNCTION GET_VOUCHER_STATUS_USER (VOU_NO VARCHAR, VOU_STATUS VARCHAR)
      RETURN VARCHAR2
   IS
      V_USR_NAME   VARCHAR2 (100);
   BEGIN
      IF VOU_STATUS = 'PREPARE'
      THEN
         BEGIN
            SELECT DISTINCT V_LASTUPD_USER
              INTO V_USR_NAME
              FROM PY_VOUCHER_STATUS_LOG
             WHERE     V_CURRENT_STATUS = 'PY001'
                   AND V_VOU_NO = VOU_NO
                   AND V_PREV_STATUS IS NULL
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_USR_NAME := NULL;
         END;
      ELSIF VOU_STATUS = 'VERIFY'
      THEN
         BEGIN
            SELECT DISTINCT V_LASTUPD_USER
              INTO V_USR_NAME
              FROM PY_VOUCHER_STATUS_LOG
             WHERE     V_CURRENT_STATUS = 'PY002'
                   AND V_VOU_NO = VOU_NO
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_USR_NAME := NULL;
         END;
      ELSIF VOU_STATUS = 'APPROVE'
      THEN
         BEGIN
            SELECT DISTINCT V_LASTUPD_USER
              INTO V_USR_NAME
              FROM PY_VOUCHER_STATUS_LOG
             WHERE     V_CURRENT_STATUS = 'PY004'
                   AND V_VOU_NO = VOU_NO
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_USR_NAME := NULL;
         END;
      END IF;


      RETURN V_USR_NAME;
   END;


   FUNCTION GET_VOUCHER_DATE (VOU_NO VARCHAR, VOU_STATUS VARCHAR)
      RETURN DATE
   IS
      V_DATE   DATE;
   BEGIN
      IF VOU_STATUS = 'PREPARE'
      THEN
         BEGIN
            SELECT TRUNC (MAX(D_LASTUPD_INFTM))
              INTO V_DATE
              FROM PY_VOUCHER_STATUS_LOG
             WHERE     V_CURRENT_STATUS = 'PY001'
                   AND V_VOU_NO = VOU_NO
                   AND V_PREV_STATUS IS NULL;
--                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_DATE := NULL;
         END;
      ELSIF VOU_STATUS = 'VERIFY'
      THEN
         BEGIN
            SELECT TRUNC (MAX(D_LASTUPD_INFTM))
              INTO V_DATE
              FROM PY_VOUCHER_STATUS_LOG
             WHERE     V_CURRENT_STATUS = 'PY002'
                   AND V_VOU_NO = VOU_NO;
--                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_DATE := NULL;
         END;
      ELSIF VOU_STATUS = 'APPROVE'
      THEN
         BEGIN
            SELECT TRUNC (MAX(D_LASTUPD_INFTM))
              INTO V_DATE
              FROM PY_VOUCHER_STATUS_LOG
             WHERE     V_CURRENT_STATUS = 'PY004'
                   AND V_VOU_NO = VOU_NO;
--                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_DATE := NULL;
         END;
      END IF;


      RETURN V_DATE;
   END;


   FUNCTION GET_USER_NAME (USER_NAME VARCHAR)
      RETURN VARCHAR2
   IS
      V_NAME   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT  max(NVL (V_USER_NAME, V_USER_ID))
           INTO V_NAME
           FROM GNMM_BRANCH_SERVER
          WHERE V_USER_ID = USER_NAME ;
--          AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_NAME := USER_NAME;
      END;

      --        RAISE_ERROR('v_name=='||v_name);

--      V_NAME := NVL (V_NAME, USER_NAME);

      RETURN V_NAME;
   END;


   FUNCTION GET_CASH_AMT (V_BRH_CODE     VARCHAR2,
                          V_BIZ_CODE     VARCHAR2,
                          V_DATE_FROM    DATE,
                          V_DATE_TO      DATE)
      RETURN NUMBER
   IS
      V_AMT   NUMBER;
   BEGIN
      SELECT SUM (NVL (N_RECEIPT_AMT, 0))
        INTO V_AMT
        FROM REMT_RECEIPT RCT,
             REMT_RECEIPT_INSTRUMENTS RCT_INS,
             REMM_INSTRUMENT INS
       WHERE     RCT.N_RECEIPT_SESSION = RCT_INS.N_RECEIPT_SESSION
             AND RCT_INS.V_INS_CODE = INS.V_INS_CODE
             AND RCT_INS.V_INS_CODE IN ('CSH')
             AND V_RECEIPT_TABLE = 'DETAIL'
             AND RCT.V_BRANCH_CODE = V_BRH_CODE
             AND DECODE (V_BUSINESS_CODE, 'GRP', 'GRP', 'IND') = V_BIZ_CODE
             AND TO_DATE (D_RECEIPT_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                   V_DATE_FROM,
                                                                   'DD/MM/RRRR')
                                                            AND TO_DATE (
                                                                   V_DATE_TO,
                                                                   'DD/MM/RRRR');


      RETURN NVL (V_AMT, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;


   FUNCTION GET_CHQ_AMT_SM_BNK (V_BRH_CODE     VARCHAR2,
                                V_BIZ_CODE     VARCHAR2,
                                V_DATE_FROM    DATE,
                                V_DATE_TO      DATE)
      RETURN NUMBER
   IS
      V_AMT   NUMBER;
   BEGIN
      SELECT SUM (NVL (N_RECEIPT_AMT, 0))
        INTO V_AMT
        FROM REMT_RECEIPT RCT,
             REMT_RECEIPT_INSTRUMENTS RCT_INS,
             REMM_INSTRUMENT INS
       WHERE     RCT.N_RECEIPT_SESSION = RCT_INS.N_RECEIPT_SESSION
             AND RCT_INS.V_INS_CODE = INS.V_INS_CODE
             AND RCT_INS.V_INS_CODE IN ('CHQ')
             AND V_RECEIPT_TABLE = 'DETAIL'
             AND RCT.V_BRANCH_CODE = V_BRH_CODE
             AND DECODE (V_BUSINESS_CODE, 'GRP', 'GRP', 'IND') = V_BIZ_CODE
             AND TO_DATE (D_RECEIPT_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                   V_DATE_FROM,
                                                                   'DD/MM/RRRR')
                                                            AND TO_DATE (
                                                                   V_DATE_TO,
                                                                   'DD/MM/RRRR')
             AND JHL_GEN_PKG.
                 CHECK_SAME_BANK (V_BRH_CODE,
                                  RCT_INS.V_INS_BANK,
                                  RCT_INS.V_INS_BANK_BRANCH) = 'Y';


      RETURN NVL (V_AMT, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;


   FUNCTION GET_CHQ_AMT_DIF_BNK (V_BRH_CODE     VARCHAR2,
                                 V_BIZ_CODE     VARCHAR2,
                                 V_DATE_FROM    DATE,
                                 V_DATE_TO      DATE)
      RETURN NUMBER
   IS
      V_AMT   NUMBER;
   BEGIN
      SELECT SUM (NVL (N_RECEIPT_AMT, 0))
        INTO V_AMT
        FROM REMT_RECEIPT RCT,
             REMT_RECEIPT_INSTRUMENTS RCT_INS,
             REMM_INSTRUMENT INS
       WHERE     RCT.N_RECEIPT_SESSION = RCT_INS.N_RECEIPT_SESSION
             AND RCT_INS.V_INS_CODE = INS.V_INS_CODE
             AND RCT_INS.V_INS_CODE IN ('CHQ')
             AND V_RECEIPT_TABLE = 'DETAIL'
             AND RCT.V_BRANCH_CODE = V_BRH_CODE
             AND DECODE (V_BUSINESS_CODE, 'GRP', 'GRP', 'IND') = V_BIZ_CODE
             AND TO_DATE (D_RECEIPT_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                   V_DATE_FROM,
                                                                   'DD/MM/RRRR')
                                                            AND TO_DATE (
                                                                   V_DATE_TO,
                                                                   'DD/MM/RRRR')
             AND JHL_GEN_PKG.
                 CHECK_SAME_BANK (V_BRH_CODE,
                                  RCT_INS.V_INS_BANK,
                                  RCT_INS.V_INS_BANK_BRANCH) = 'N';


      RETURN NVL (V_AMT, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;


   FUNCTION GET_CHQ_AMT (V_BRH_CODE     VARCHAR2,
                         V_BIZ_CODE     VARCHAR2,
                         V_DATE_FROM    DATE,
                         V_DATE_TO      DATE)
      RETURN NUMBER
   IS
      V_AMT   NUMBER;
   BEGIN
      SELECT SUM (NVL (N_RECEIPT_AMT, 0))
        INTO V_AMT
        FROM REMT_RECEIPT RCT,
             REMT_RECEIPT_INSTRUMENTS RCT_INS,
             REMM_INSTRUMENT INS
       WHERE     RCT.N_RECEIPT_SESSION = RCT_INS.N_RECEIPT_SESSION
             AND RCT_INS.V_INS_CODE = INS.V_INS_CODE
             AND RCT_INS.V_INS_CODE IN ('CHQ')
             AND V_RECEIPT_TABLE = 'DETAIL'
             AND RCT.V_BRANCH_CODE = V_BRH_CODE
             AND DECODE (V_BUSINESS_CODE, 'GRP', 'GRP', 'IND') = V_BIZ_CODE
             AND TO_DATE (D_RECEIPT_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                   V_DATE_FROM,
                                                                   'DD/MM/RRRR')
                                                            AND TO_DATE (
                                                                   V_DATE_TO,
                                                                   'DD/MM/RRRR');


      RETURN NVL (V_AMT, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;



   FUNCTION GET_RCT_AMT (V_BRH_CODE     VARCHAR2,
                         V_BIZ_CODE     VARCHAR2,
                         V_DATE_FROM    DATE,
                         V_DATE_TO      DATE)
      RETURN NUMBER
   IS
      V_AMT   NUMBER;
   BEGIN
      SELECT SUM (NVL (N_RECEIPT_AMT, 0))
        INTO V_AMT
        FROM REMT_RECEIPT RCT,
             REMT_RECEIPT_INSTRUMENTS RCT_INS,
             REMM_INSTRUMENT INS
       WHERE     RCT.N_RECEIPT_SESSION = RCT_INS.N_RECEIPT_SESSION
             AND RCT_INS.V_INS_CODE = INS.V_INS_CODE
             AND RCT_INS.V_INS_CODE IN ('CHQ', 'CSH')
             AND V_RECEIPT_TABLE = 'DETAIL'
             AND RCT.V_BRANCH_CODE = V_BRH_CODE
             AND DECODE (V_BUSINESS_CODE, 'GRP', 'GRP', 'IND') = V_BIZ_CODE
             AND TO_DATE (D_RECEIPT_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                   V_DATE_FROM,
                                                                   'DD/MM/RRRR')
                                                            AND TO_DATE (
                                                                   V_DATE_TO,
                                                                   'DD/MM/RRRR');


      RETURN NVL (V_AMT, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION IS_VOUCHER_AUTHORIZED (V_VOUCHER_NO VARCHAR2)
      RETURN VARCHAR2
   IS
      V_DESC    VARCHAR2 (500);
      V_COUNT   NUMBER;
   BEGIN
      BEGIN
         SELECT UPPER (V_VOU_DESC)
           INTO V_DESC
           FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
          WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND PV.V_VOU_NO = V_VOUCHER_NO;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_DESC := NULL;
      END;

      IF V_DESC LIKE '%COMMISSION%'
      THEN
         RETURN 'Y';
      ELSE
         BEGIN
            SELECT COUNT (*)
              INTO V_COUNT
              FROM PY_VOUCHER_STATUS_LOG
             WHERE V_CURRENT_STATUS IN ( 'PY004') 
--              V_CURRENT_STATUS IN ( 'PY004','PY009','PY007','PY010','RE002') 
             AND V_VOU_NO = V_VOUCHER_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_COUNT := 0;
         END;

         IF V_COUNT = 0
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END IF;
   END;


   FUNCTION GET_DR_BANK (V_PYM VARCHAR, V_BRH VARCHAR, V_BIZ_CODE VARCHAR)
      RETURN VARCHAR2
   IS
      V_BNK_NAME   VARCHAR2 (500);
   BEGIN
      SELECT V_COMPANY_NAME
        INTO V_BNK_NAME
        FROM GNDT_FINANCE_BRANCH_BANKS BNK_BRH, GNMM_COMPANY_MASTER COMP_BNK
       WHERE     V_BRANCH_CODE = 'HO'
             AND BNK_BRH.V_COMPANY_CODE = 'JICK'
             AND BNK_BRH.V_BANK_CODE = COMP_BNK.V_COMPANY_CODE
             AND BNK_BRH.V_BANK_BRANCH = COMP_BNK.V_COMPANY_BRANCH
             AND BNK_BRH.V_INS_CODE = V_PYM
             AND BNK_BRH.V_COMPANY_BRANCH = V_BRH
             AND DECODE (V_LOB_ACCOUNT,
                         'LOB001', 'IND',
                         'LOB003', 'GRP',
                         'MIS', 'MISC',
                         V_LOB_ACCOUNT) = V_BIZ_CODE
             AND ROWNUM = 1;

      RETURN V_BNK_NAME;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;


   FUNCTION GET_DR_BANK_CODE (V_PYM         VARCHAR,
                              V_BRH         VARCHAR,
                              V_BIZ_CODE    VARCHAR)
      RETURN VARCHAR2
   IS
      V_BNK_NAME   VARCHAR2 (500);
   BEGIN
      SELECT COMP_BNK.V_COMPANY_CODE
        INTO V_BNK_NAME
        FROM GNDT_FINANCE_BRANCH_BANKS BNK_BRH, GNMM_COMPANY_MASTER COMP_BNK
       WHERE     V_BRANCH_CODE = 'HO'
             AND BNK_BRH.V_COMPANY_CODE = 'JICK'
             AND BNK_BRH.V_BANK_CODE = COMP_BNK.V_COMPANY_CODE
             AND BNK_BRH.V_BANK_BRANCH = COMP_BNK.V_COMPANY_BRANCH
             AND BNK_BRH.V_INS_CODE = V_PYM
             AND BNK_BRH.V_COMPANY_BRANCH = V_BRH
             AND DECODE (V_LOB_ACCOUNT,
                         'LOB001', 'IND',
                         'LOB003', 'GRP',
                         'MIS', 'MISC',
                         V_LOB_ACCOUNT) = V_BIZ_CODE
             AND ROWNUM = 1;

      RETURN V_BNK_NAME;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;


   FUNCTION POLICY_AWAITING_PREMIUM (V_POL_NO VARCHAR)
      RETURN VARCHAR2
   IS
      V_RETURN    VARCHAR2 (5);
      V_COUNT     NUMBER;
      V_RCT_AMT   NUMBER := 0;
      V_CONTRIB   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO V_COUNT
           FROM GNMT_POLICY POL
          WHERE POL.V_POLICY_NO = V_POL_NO
                AND POL.V_CNTR_STAT_CODE IN
                       ('NB054',
                        'NB001',
                        'NB058',
                        'NB053',
                        'NB002',
                        'NB104',
                        'NB064');
      EXCEPTION
         WHEN OTHERS
         THEN
            V_COUNT := 0;
      END;

      BEGIN
         SELECT POL.N_CONTRIBUTION
           INTO V_CONTRIB
           FROM GNMT_POLICY POL
          WHERE POL.V_POLICY_NO = V_POL_NO;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_CONTRIB := 0;
      END;


      IF V_COUNT = 0
      THEN
         RETURN 'Y';
      ELSE
         BEGIN
            SELECT SUM (N_RECEIPT_AMT)
              INTO V_RCT_AMT
              FROM REMT_RECEIPT J, GNMT_POLICY POL
             WHERE     J.V_POLICY_NO = POL.V_POLICY_NO
                   AND J.V_RECEIPT_TABLE = 'DETAIL'
                   AND J.V_RECEIPT_STATUS = 'RE001'
                   AND POL.V_CNTR_STAT_CODE IN
                          ('NB054',
                           'NB001',
                           'NB058',
                           'NB053',
                           'NB002',
                           'NB104',
                           'NB064')
                   AND POL.V_POLICY_NO = V_POL_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_RCT_AMT := 0;
         END;

         IF (NVL (V_RCT_AMT, 0) = 0 OR (NVL (V_RCT_AMT, 0) + 50) < V_CONTRIB)
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END IF;
   END;


   FUNCTION GET_RECEIPT_PAYEE (V_RCT_NO VARCHAR)
      RETURN VARCHAR2
   IS
      V_RETURN   VARCHAR2 (300);
   BEGIN
      SELECT DISTINCT NVL (CUST.V_NAME, CO.V_COMPANY_NAME) PAYEE_NAME
        INTO V_RETURN
        FROM REMT_RECEIPT RCT,
             REMT_RECEIPT_INSTRUMENTS RCT_INS,
             GNMT_CUSTOMER_MASTER CUST,
             GNMM_COMPANY_MASTER CO
       WHERE     RCT.N_RECEIPT_SESSION = RCT_INS.N_RECEIPT_SESSION
             AND RCT.N_CUST_REF_NO = CUST.N_CUST_REF_NO(+)
             AND RCT.V_COMPANY_CODE = CO.V_COMPANY_CODE(+)
             AND RCT.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH(+)
             --and V_RECEIPT_NO in ('HQ170000029')
             AND V_RECEIPT_TABLE = 'DETAIL'
             AND ROWNUM = 1
             AND V_RECEIPT_NO = V_RCT_NO;

      RETURN V_RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;



  FUNCTION GET_VOUCHER_POLICY (V_VOUCHER_NO VARCHAR)
      RETURN VARCHAR2
   IS
      V_RETURN   VARCHAR2 (300);

      CURSOR POL
      IS
         SELECT DISTINCT V_POLICY_NO
           FROM (SELECT DISTINCT V_POLICY_NO
                   FROM PYDT_VOUCHER_POLICY_CLIENT
                  WHERE V_VOU_NO = V_VOUCHER_NO
                 UNION ALL
                 SELECT DISTINCT M.V_POLAG_NO
                   FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
                  WHERE     M.N_REF_NO = D.N_REF_NO
                        AND M.V_JOURNAL_STATUS = 'C'
                        AND V_DOCU_TYPE = 'VOUCHER'
                         AND M.V_POLAG_TYPE = 'P'
                        AND V_DOCU_REF_NO = V_VOUCHER_NO);
   BEGIN
      FOR I IN POL
      LOOP
         RETURN I.V_POLICY_NO;
      END LOOP;

      RETURN V_RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   PROCEDURE GET_REVIVAL_PREMIUM
   IS
      --P_POLICY_NO VARCHAR2;

      LN_OUTS_PREM       NUMBER;
      LN_OUTS_PREM_INT   NUMBER;

      REV_OS_DT          DATE;

      LV_LAPS_CHK        VARCHAR2 (2);
      P_BASE_SUB         VARCHAR (1);

      CURSOR POL
      IS
         SELECT DISTINCT A.V_POLICY_NO,
                         V_CNTR_STAT_CODE,
                         D_PREM_DUE_DATE,
                         V_PYMT_FREQ
           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
                AND V_ROLE_CODE = 'SELLING'
                AND C.V_STATUS = 'A'
                AND A.V_POLICY_NO NOT LIKE 'GL%'
                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
                AND C.N_AGENT_NO IN
                       (1218, 28020, 54560, 28779, 40560, 17358, 34620, 22778)
         UNION
         SELECT DISTINCT A.V_POLICY_NO,
                         V_CNTR_STAT_CODE,
                         D_PREM_DUE_DATE,
                         V_PYMT_FREQ
           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
                --And V_Role_Code = 'SELLING'
                AND C.V_STATUS = 'A'
                AND A.V_POLICY_NO NOT LIKE 'GL%'
                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
                AND C.N_AGENT_NO IN (65620, 72770, 22778);
   --SELECT V_POLICY_NO,V_CNTR_STAT_CODE,D_PREM_DUE_DATE,v_pymt_freq
   --FROM GNMT_POLICY
   --WHERE V_CNTR_STAT_CODE IN ( 'NB022','NB025');
   --AND V_POLICY_NO NOT IN (SELECT V_POLICY_NO FROM JHL_REVIVAL_DTLS);
   --AND V_POLICY_NO ='IL201500775641';


   BEGIN
      DELETE FROM JHL_REVIVAL_DTLS;

      FOR I IN POL
      LOOP
         --              RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);
         IF I.V_CNTR_STAT_CODE IN ('NB022', 'NB025')
         THEN
            P_BASE_SUB := 'A';
         ELSIF I.V_CNTR_STAT_CODE = 'NB010'
         THEN
            LV_LAPS_CHK := 'N';
            P_BASE_SUB := 'A';
         END IF;


         REV_OS_DT := I.D_PREM_DUE_DATE;

         WHILE NOT (TRUNC (REV_OS_DT) > TRUNC (SYSDATE))
         LOOP
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                   TO_NUMBER (I.V_PYMT_FREQ));
         END LOOP;

         REV_OS_DT :=
            BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                - (TO_NUMBER (I.V_PYMT_FREQ)));


         IF LV_LAPS_CHK = 'Y'
         THEN
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (I.D_PREM_DUE_DATE),
                                   - (TO_NUMBER (I.V_PYMT_FREQ)));
         END IF;

         BPG_REINSTATE_ENQUIRY.BPC_GET_ENQREVIVAL_PREM (I.V_POLICY_NO,
                                                        1,
                                                        'A',
                                                        TRUNC (REV_OS_DT),
                                                        SYSDATE,
                                                        LN_OUTS_PREM,
                                                        LN_OUTS_PREM_INT,
                                                        'P',
                                                        I.V_CNTR_STAT_CODE,
                                                        'N');

         INSERT INTO JHL_REVIVAL_DTLS (JRD_NO,
                                       V_POLICY_NO,
                                       LN_OUTS_PREM,
                                       LN_OUTS_PREM_INT)
              VALUES (JHL_JRD_NO_SEQ.NEXTVAL,
                      I.V_POLICY_NO,
                      LN_OUTS_PREM,
                      LN_OUTS_PREM_INT);
      --                       RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);


      END LOOP;

      COMMIT;
   END;

   PROCEDURE GET_LOAN_OUTSTANDING
   IS
      V_LOAN_BAL    NUMBER;
      V_LOAN_INT    NUMBER;
      V_POLICY_NO   VARCHAR2 (40);

      CURSOR C1
      IS
         SELECT DISTINCT B.V_POLICY_NO,
                         B.N_LOAN_REF_NO,
                         A.V_CNTR_STAT_CODE,
                         A.V_CNTR_PREM_STAT_CODE
           FROM GNMT_POLICY A, PSMT_LOAN_MASTER B
          WHERE A.V_POLICY_NO = B.V_POLICY_NO AND B.V_LOAN_CLEARED = 'N';
   --           AND B.V_POLICY_NO  = '172373';

   BEGIN
      DELETE FROM JHL_LOAN_OUT_DTLS;

      FOR I IN C1
      LOOP
         BEGIN
            BPG_POLICY_SERVICING.BPC_GET_LOAN_DUE_DETAILS (I.V_POLICY_NO,
                                                           1,
                                                           SYSDATE,
                                                           V_LOAN_BAL,
                                                           V_LOAN_INT);
         EXCEPTION
            WHEN OTHERS
            THEN
               V_LOAN_BAL := NULL;
               V_LOAN_INT := NULL;
         END;

         --    RAISE_APPLICATION_ERROR(-20001,'V_LOAN_BAL=='||V_LOAN_BAL ||'V_LOAN_INT=='||V_LOAN_INT);

         INSERT INTO JHL_LOAN_OUT_DTLS (JRDL_NO,
                                        V_POLICY_NO,
                                        V_LOAN_BAL,
                                        V_LOAN_INT)
              VALUES (JHL_JRDL_NO_SEQ.NEXTVAL,
                      I.V_POLICY_NO,
                      V_LOAN_BAL,
                      V_LOAN_INT);
      END LOOP;


      COMMIT;
   END;

   PROCEDURE GET_APL_OUTSTANDING
   IS
      V_DUE_APL       NUMBER;
      V_DUE_APL_INT   NUMBER;
      V_POLICY_NO     VARCHAR2 (40);

      CURSOR C1
      IS
         SELECT DISTINCT B.V_POLICY_NO,
                         B.N_APL_REF_NO,
                         A.V_CNTR_STAT_CODE,
                         A.V_CNTR_PREM_STAT_CODE
           FROM GNMT_POLICY A, PSMT_POLICY_APL B
          WHERE A.V_POLICY_NO = B.V_POLICY_NO AND B.V_APL_CLEARED = 'N';

   BEGIN
      DELETE FROM JHL_APL_OUT_DTLS;

      FOR I IN C1
      LOOP
         BEGIN
            BPG_POLICY_SERVICING.BPC_GET_APL_DUE_DETAILS (I.V_POLICY_NO,
                                                          1,
                                                          SYSDATE,
                                                          V_DUE_APL,
                                                          V_DUE_APL_INT);
         EXCEPTION
            WHEN OTHERS
            THEN
               V_DUE_APL := NULL;
               V_DUE_APL_INT := NULL;
         END;

         --    RAISE_APPLICATION_ERROR(-20001,'V_LOAN_BAL=='||V_LOAN_BAL ||'V_LOAN_INT=='||V_LOAN_INT);

         INSERT INTO JHL_APL_OUT_DTLS (JRDA_NO,
                                       V_POLICY_NO,
                                       V_DUE_APL,
                                       V_DUE_APL_INT)
              VALUES (JHL_JRDA_NO_SEQ.NEXTVAL,
                      I.V_POLICY_NO,
                      V_DUE_APL,
                      V_DUE_APL_INT);
      END LOOP;


      COMMIT;
   END;
   
   PROCEDURE Bpc_Process_BankIn_Instruments(
                            p_User                 IN  VARCHAR2,
                            p_Program             IN  VARCHAR2,
                            p_Data_Found_Flag    OUT VARCHAR2,
                            p_Instrument_cd     IN  VARCHAR2  default null,
                            P_SESSION_NO IN NUMBER
                            )Is

        CURSOR Cr_BankIn_Ins(t_User VARCHAR2) Is
            SELECT n_inslink_no, n_receipt_session, v_lastupd_user, v_ins_code, n_ins_amount,
                v_bankin_code, v_bankin_branch, n_drawn_zone_no, n_active_ins_amount, v_bank_in_bank_source
                FROM remt_receipt_instruments
                WHERE n_active_ins_amount > 0
                    AND v_lastupd_user = DECODE(t_user,NULL,v_lastupd_user,t_user)
                    AND NVL(v_banked_in_status,'N') = 'N'
                    AND v_instrument_status = bpg_process_receipts.lv_status
                    AND V_ins_code    = NVL(P_INSTRUMENT_CD,V_ins_code)
                    AND N_rECEIPT_SESSION = P_SESSION_NO
                    FOR UPDATE OF v_banked_in_status NOWAIT;

        CURSOR cr_rec( t_receipt_session NUMBER, t_inslink_no NUMBER ) IS
            SELECT v_policy_no, n_seq_no, n_receipt_amt, d_receipt_date
                FROM remt_receipt
                WHERE n_receipt_session = t_receipt_session
                    AND n_inslink_no = t_inslink_no
                    AND v_instrument_status = bpg_process_receipts.lv_status;


        CURSOR cr_rec_err( t_receipt_session NUMBER, t_inslink_no NUMBER ) IS
            SELECT DISTINCT v_receipt_no
                FROM remt_receipt
                WHERE n_receipt_session = t_receipt_session
                    AND n_inslink_no = t_inslink_no
                    AND v_instrument_status = bpg_process_receipts.lv_status;

        CURSOR cr_seq IS
            SELECT seq_bankedin_dets.NEXTVAL n_seq_no
            FROM DUAL;
        lv_comp_branch         gnmt_user.v_branch_code%TYPE;
        lv_lastupd_user        remt_receipt_instruments.v_lastupd_user%TYPE;
        lv_company_name        gnmm_company_master.v_company_name%TYPE;
        lv_company_code        gnmm_company_master.v_company_code%TYPE;
        lv_bankin_code        remt_receipt_instruments.v_bankin_code%TYPE;
        lv_bankin_branch    remt_receipt_instruments.v_bankin_branch%TYPE;
        lv_lob_account        gndt_finance_branch_banks.v_lob_account%TYPE;
        lv_bank_code        gndt_finance_branch_banks.v_bank_code%TYPE;
        lv_bank_branch        gndt_finance_branch_banks.v_bank_branch%TYPE;
        ln_clear_zone_no    gndt_finance_branch_banks.n_clear_zone_no%TYPE;

        lv_fin_branch_code    gndt_finance_branch_users.v_branch_code%TYPE;
        lv_dummy            VARCHAR2(1000);
        ln_count            NUMBER(5);
        ln_dummy_count        NUMBER(5);
        ln_bank_setup_no    NUMBER;
        lv_business_unit    VARCHAR2(1);
        lv_par_non_par        VARCHAR2(1);
        ld_bank_in_date        DATE;
        ln_hold_days        NUMBER;
        lv_plan_code        gnmm_plan_master.v_plan_code%TYPE;
        lv_error_receipt_no VARCHAR2(4000);
        ld_lastupd_date        DATE;
        ln_serial_no        NUMBER;


        ld_sysdate             DATE     := trunc(SYSDATE);
        ld_sysdate_1         DATE     := trunc(SYSDATE)-1;
        ld_sysdate_2         DATE     := trunc(SYSDATE)-2;
        ld_sysdate_3         DATE     := trunc(SYSDATE)-3;
        ld_sysdate_4         DATE     := trunc(SYSDATE)-4;

    BEGIN
        p_data_found_flag := 'N';
        lv_lastupd_user := NVL(p_user, USER);

        IF p_user is Not Null THEN

              FOR i IN (SELECT a.n_receipt_session
                            FROM remt_receipt a
                         WHERE NOT EXISTS (SELECT  n_receipt_session
                                             FROM  remt_receipt
                                            WHERE (v_receipt_table = bpg_process_receipts.Lv_Master OR v_receipt_table = bpg_process_receipts.Lv_Detail)
                                                AND n_receipt_session =a.n_receipt_session)
                          AND a.v_user_code = P_USER
                          AND a.v_receipt_table = bpg_process_receipts.lv_session
                          AND TRUNC(a.d_lastupd_inftim) IN (ld_sysdate,ld_sysdate_1,ld_sysdate_2,ld_sysdate_3,ld_sysdate_4))

                LOOP
                  DELETE FROM remt_receipt_instruments WHERE n_receipt_session = i.n_receipt_session;
                  DELETE FROM remt_receipt WHERE n_receipt_session = i.n_receipt_session;
              END LOOP;

        ELSIF p_user is Null THEN

                   FOR i IN (SELECT n_receipt_session
                            FROM remt_receipt a
                           WHERE  n_receipt_session IN (SELECT n_receipt_session
                                                           FROM remt_receipt
                                                      GROUP BY n_receipt_session
                                                        HAVING count(DISTINCT v_receipt_table)=1)
                             AND v_receipt_table = bpg_process_receipts.lv_session
                             AND TRUNC(a.d_lastupd_inftim) IN (ld_sysdate,ld_sysdate_1,ld_sysdate_2,ld_sysdate_3,ld_sysdate_4))

             LOOP
                  DELETE FROM remt_receipt_instruments WHERE n_receipt_session = i.n_receipt_session;
                  DELETE FROM remt_receipt WHERE n_receipt_session = i.n_receipt_session;
             END LOOP;

        END IF;

        FOR ins IN cr_bankin_ins(p_user)
        LOOP
            lv_bankin_code        := ins.v_bankin_code;
            lv_bankin_branch    := ins.v_bankin_branch;
            p_data_found_flag := 'Y';
            lv_comp_branch := bpg_gen.bfn_get_branch(ins.v_lastupd_user);
            bpg_gen.bpc_get_self_company_name(lv_comp_branch, lv_company_code, lv_company_name);

            lv_fin_branch_code := bpg_process_receipts.bfn_get_finance_branch(
                            p_user_id            => ins.v_lastupd_user,
                            p_finance_process    => 'RE'
                            );

            IF ins.v_ins_code = 'CRADVICE' OR ins.v_bank_in_bank_source = 'R' THEN
                lv_bank_code := lv_bankin_code;
                lv_bank_branch := lv_bankin_branch;
                FOR I IN Cr_Rec( ins.n_receipt_session, ins.n_inslink_no) LOOP

                    lv_plan_code    := NULL;
                    IF I.v_policy_no IS NOT NULL AND bpg_baj_accounting.bfn_is_policy_no_exists(p_policy_no => i.v_policy_no ) = TRUE  THEN
                           bpg_gen.bpc_get_plan_for_the_policy( i.v_policy_no, lv_plan_code );
                        lv_lob_account      := bpg_gen.bfn_get_lob_code_from_policy(i.v_policy_no);
                        lv_business_unit := bpg_baj_accounting.bfn_buz_unit_for_policy(i.v_policy_no);
                        lv_par_non_par     := bpg_policy.bfn_check_par_nonpar( i.v_policy_no, i.n_seq_no, lv_plan_code, lv_plan_code, i.d_receipt_date);
                    ELSE
                        lv_lob_account      := bpg_baj_accounting.bfn_lob_code_for_non_policy;
                        lv_business_unit := bpg_baj_accounting.bfn_buz_unit_for_non_policy;
                        lv_par_non_par     := bpg_baj_accounting.bfn_par_nonpar_for_non_policy;
                    END IF;
                    ld_bank_in_date := TRUNC(NVL(Bpg_Process_Receipts.ld_batch_date,bpg_variable.ld_date));
                    ld_lastupd_date := NVL(Bpg_Process_Receipts.ld_batch_date,bpg_variable.ld_date);
                    FOR seq IN cr_seq
                    LOOP
                        ln_serial_no := seq.n_seq_no;
                    END LOOP;
                    INSERT INTO ppdt_bankedin_dets(n_serial_no, d_deposit_date, v_payment_mode,
                        n_inslink_no, v_paybank_code, v_paybank_branch, n_amount, v_status,
                        n_receipt_session, n_cancelled_amt, v_lob_account, v_lastupd_user,
                        v_lastupd_prog, d_lastupd_inftim, v_business_unit, v_par_non_par,
                        d_bank_in_date, v_bankin_slip_status)
                    VALUES(ln_serial_no, ld_bank_in_date, ins.v_ins_code, ins.n_inslink_no,
                         lv_bank_code, lv_bank_branch, i.n_receipt_amt, bpg_process_receipts.lv_status, ins.n_receipt_session,
                         0, lv_lob_account, lv_lastupd_user, p_program, ld_bank_in_date, lv_business_unit,
                         lv_par_non_par, ld_bank_in_date, bpg_process_receipts.lv_no);

                    UPDATE remt_receipt_instruments
                        SET v_banked_in_status = Bpg_Process_Receipts.lv_yes
                        WHERE n_receipt_session = ins.n_receipt_session
                            AND n_inslink_no = ins.n_inslink_no;
                END LOOP;

                    bpg_process_receipts.bpc_bankin_receipt(
                                            p_receipt_session     => ins.n_receipt_session,
                                            p_inslink_no        => ins.n_inslink_no,
                                            p_giss_code            => lv_bank_code||'-'||lv_bank_branch,
                                            p_user                 => ins.v_lastupd_user,
                                            p_prog                 => p_program,
                                            p_date                 => ld_bank_in_date,
                                            p_business_unit        => lv_business_unit,
                                            p_par_non_par        => lv_par_non_par,
                                            p_lob_accout_code    => lv_lob_account
                                            );


            ELSE
                ln_count := 0;
                bpg_process_receipts.bpc_set_receipt_to_pltable(
                                                        p_receipt_session         => ins.n_receipt_session,
                                                        p_vou_no                  => NULL,
                                                        p_receipt_or_payment     => 'R',
                                                        p_ins_link_no            => ins.n_inslink_no
                                                        );

                ln_count := bpg_process_receipts.ln_pl_tab_rec_count;
                ln_bank_setup_no := bpg_process_receipts.bfn_get_bank_setup_no(
                                                                p_ins_code            => ins.v_ins_code,
                                                                p_company_code        => lv_company_code,
                                                                p_company_branch    => lv_comp_branch,
                                                                p_branch_code        => lv_fin_branch_code,
                                                                p_finance_process    => 'RE',
                                                                p_count                => ln_count
                                                                );


                bpg_process_receipts.bpc_process_bankin_det(
                                            p_lob_account        => lv_lob_account,
                                            p_bank_code            => lv_bank_code,
                                            p_bank_branch        => lv_bank_branch,
                                            p_bank_setup_no        => ln_bank_setup_no,
                                            p_business_unit        => lv_business_unit,
                                            p_par_non_par        => lv_par_non_par
                                            );


                   IF lv_lob_account IS NOT NULL THEN

                       ln_clear_zone_no := bpg_process_receipts.bfn_get_clear_zone_no(p_bank_setup_no => ln_bank_setup_no);
                    ln_hold_days      := bpg_process_receipts.bfn_get_bank_in_hold_days(p_drawn_zone_no => ins.n_drawn_zone_no, p_clear_zone_no => ln_clear_zone_no);

                    ld_bank_in_date := TRUNC(NVL(bpg_process_receipts.ld_batch_date,bpg_variable.ld_date));
                    ld_lastupd_date := NVL(bpg_process_receipts.ld_batch_date,bpg_variable.ld_date);
                    FOR seq IN cr_seq
                    LOOP
                        ln_serial_no := seq.n_seq_no;
                    END LOOP;
                    INSERT INTO ppdt_bankedin_dets(n_serial_no, d_deposit_date, v_payment_mode,
                        n_inslink_no, v_paybank_code, v_paybank_branch, n_amount, v_status,
                        n_receipt_session, n_cancelled_amt, v_lob_account, v_lastupd_user,
                        v_lastupd_prog, d_lastupd_inftim, v_business_unit, v_par_non_par,
                        d_bank_in_date, v_bankin_slip_status, n_hold_days)
                    VALUES(ln_serial_no, ld_bank_in_date, ins.v_ins_code, ins.n_inslink_no,
                         lv_bank_code, lv_bank_branch, ins.n_active_ins_amount, bpg_process_receipts.lv_status, ins.n_receipt_session,
                         0, lv_lob_account, lv_lastupd_user, p_program, ld_bank_in_date, lv_business_unit, lv_par_non_par,
                         ld_bank_in_date, bpg_process_receipts.lv_no, ln_hold_days);

                    UPDATE remt_receipt_instruments
                        SET v_banked_in_status = Bpg_Process_Receipts.lv_yes,
                            v_bankin_code = lv_bank_code,
                            v_bankin_branch = lv_bank_branch
                        WHERE n_receipt_session = ins.n_receipt_session
                            AND n_inslink_no = ins.n_inslink_no;
                    bpg_process_receipts.bpc_bankin_receipt(
                                            p_receipt_session     => ins.n_receipt_session,
                                            p_inslink_no        => ins.n_inslink_no,
                                            p_giss_code            => lv_bank_code||'-'||lv_bank_branch,
                                            p_user                 => ins.v_lastupd_user,
                                            p_prog                 => p_program,
                                            p_date                 => ld_bank_in_date,
                                            p_business_unit        => lv_business_unit,
                                            p_par_non_par        => lv_par_non_par,
                                            p_lob_accout_code    => lv_lob_account
                                            );
                   ELSE
                       IF lv_comp_branch IS NULL THEN
                           Raise_Application_Error(-20178,'Company Branch Does not Exsits for this user : '||ins.v_lastupd_user);
                       ELSIF lv_company_code IS NULL THEN
                           Raise_Application_Error(-20179,'Company Code Does not Exsits for this user : '||ins.v_lastupd_user);
                       ELSIF lv_fin_branch_code IS NULL THEN
                           Raise_Application_Error(-20180,'Finance Branch Does not Exsits for this user : '||ins.v_lastupd_user);
                       ELSE
                           lv_error_receipt_no := NULL;
                           ln_dummy_count := 0;
                        FOR I IN cr_rec_err( ins.n_receipt_session, ins.n_inslink_no) LOOP
                            IF lv_error_receipt_no IS NULL THEN
                                lv_error_receipt_no := i.v_receipt_no;
                            ELSE
                                lv_error_receipt_no := lv_error_receipt_no||', '||i.v_receipt_no;
                            END IF;

                            ln_dummy_count := ln_dummy_count + 1;

                            IF lv_error_receipt_no IS NOT NULL THEN
                            EXIT ;
                            END IF;

                        END LOOP;
                        IF lv_error_receipt_no IS NOT NULL THEN
                            lv_error_receipt_no := ' Receipt No.(s) : '||lv_error_receipt_no;
                        END IF;
                        IF ln_dummy_count <= 1 THEN
                            lv_error_receipt_no := lv_error_receipt_no||chr(13)||'There is no Bank Setup For Ins.Code = "'||ins.v_ins_code||'"';
                            lv_error_receipt_no := lv_error_receipt_no||' Comp. Code = "'||lv_company_code||'" Comp. Branch = "'||lv_comp_branch||'"';
                            lv_error_receipt_no := lv_error_receipt_no||' Finance Branch = "'||lv_fin_branch_code||'"';
                        END IF;
                        IF ln_dummy_count > 0 THEN
                               raise_application_error(-20181,'Lines of Business is Null for this Receipt, Session No : '||ins.n_receipt_session||lv_error_receipt_no);
                           ELSE
                               UPDATE remt_receipt_instruments
                                   SET v_instrument_status = bpg_process_receipts.lv_val_c
                                WHERE n_receipt_session = ins.n_receipt_session
                                AND n_inslink_no = ins.n_inslink_no;
                           END IF;
                       END IF;
                END IF;

            END IF;

        END LOOP;

    END bpc_process_bankin_instruments;
    
    
     PROCEDURE run_banking_process is
     lv_found varchar2(1);
     v_start_date DATE;
     Begin
       v_start_date :=SYSDATE;
     
     delete from exce_handler;
for  x in (select distinct n_Receipt_session  from remt_receipt_instruments where   NVL(v_banked_in_status,'N') = 'N' and  v_instrument_status='A'
  AND n_active_ins_amount>0 )----AND n_Receipt_session=1769379)
LOOP
    bpg_process_receipts.ld_batch_date := trunc(sysdate);
            begin
            bpc_process_bankin_instruments(
                                                p_user                => NULL,
                                                p_program            => 'RE_FRM_08',
                                                p_data_found_flag    => lv_found,
                                                p_Instrument_cd      => null,
                                                P_SESSION_NO       =>X.n_Receipt_session);
        exception
            when others then
                insert into exce_handler values (X.n_Receipt_session);
                null;
            end;
        bpg_process_receipts.ld_batch_date := null;
        commit;
END LOOP;

       INSERT INTO  JHL_OFA_JOBS (OJB_ID, OJB_NAME, OJB_START_DT, OJB_END_DT)
       VALUES(JHL_OJB_ID_SEQ.NEXTVAL,'run_banking_process', v_start_date, SYSDATE);
       
       commit;

End;


FUNCTION get_clm_provision_balance(p_claim_no VARCHAR2,p_sub_claim_no NUMBER, v_serial_no number, v_col_type VARCHAR2)  return number IS
cursor cr_prov_dtl is
select     v_prov_type,v_amount_type,n_amount,
                n_serial_no,d_provision_date ,n_sub_claim_no
from cldt_provision_detail
where v_claim_no=p_claim_no
and n_sub_claim_no=p_sub_claim_no
order by n_serial_no,d_provision_date;

ln_closing_prov number:=0;
v_open_prov number:=0;
v_paid_prov number:=0;
v_adj_prov number:=0;
v_closing_prov number:=0;
BEGIN

        for j in cr_prov_dtl
        loop
            if j.v_prov_type='INT-PROV' then
                v_open_prov:=0;
                v_paid_prov:=0;
                v_adj_prov:=j.n_amount;
                ln_closing_prov:=v_adj_prov;
            elsif j.v_prov_type='DEC-PROV' then
                v_open_prov:=ln_closing_prov;
                v_adj_prov:=j.n_amount;
                v_paid_prov:=0;
                ln_closing_prov:=(v_open_prov-v_adj_prov);

            elsif j.v_prov_type='INC-PROV' then    
                v_open_prov:=ln_closing_prov;
                v_adj_prov:=j.n_amount;
                v_paid_prov:=0;
                ln_closing_prov:=(v_open_prov+v_adj_prov);

            elsif j.v_prov_type='PAID-PROV' then
                v_open_prov:=ln_closing_prov;
                v_adj_prov:=0;
                v_paid_prov:=j.n_amount;
                ln_closing_prov:=(v_open_prov -v_paid_prov);    
        
            end if;
          
                   if  j.n_serial_no =v_serial_no then
                   
                       if v_col_type = 'OPEN' THEN
                        RETURN v_open_prov;
                       ELSIF v_col_type = 'PAID' THEN
                       RETURN v_paid_prov;
                       ELSIF v_col_type = 'ADJUST' THEN
                       RETURN v_adj_prov;
                       ELSIF v_col_type = 'CLOSE' THEN
                       RETURN ln_closing_prov;
                       end if;
                   
                   
                   end if;

    
            
            
        end loop;
        
        return to_number(null);
      
END;


   FUNCTION get_company_name (v_pol_no VARCHAR)
      RETURN VARCHAR2
   IS
      v_co_name   VARCHAR2 (100);
   BEGIN
      BEGIN
      
        SELECT V_COMPANY_NAME
        INTO v_co_name
        FROM GNMT_POLICY POL,GNMM_COMPANY_MASTER CO
        WHERE POL.V_COMPANY_CODE = CO.V_COMPANY_CODE
        AND POL.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH
        AND POL.V_POLICY_NO = v_pol_no;
        
        
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN NULL;
      END;

      RETURN v_co_name;
   END;
     
   
      FUNCTION get_claim_amount (v_pol_no VARCHAR,v_from_dt date, v_to_date date)
      RETURN NUMBER
   IS
      v_clm_amt  number;
   BEGIN
      BEGIN
      
               SELECT  SUM (nvl(CLMT.N_CLAIMANT_AMOUNT,0))
               into v_clm_amt 
       FROM CLMT_CLAIM_MASTER CLM , CLDT_CLAIM_EVENT_POLICY_LINK CLM_LINK,CLDT_CLAIMANT_MASTER CLMT
       WHERE  CLM.V_CLAIM_NO = CLM_LINK.V_CLAIM_NO
       AND CLM.V_CLAIM_NO = CLMT.V_CLAIM_NO
       AND CLM_LINK.V_POLICY_NO = v_pol_no
--      And trunc(CLM.D_Claim_Date) Between '01-JAN-17' And '24-JUL-17'
      AND TRUNC(CLM.D_Claim_Date) BETWEEN TO_DATE(v_from_dt,'DD/MM/RRRR') AND   TO_DATE(v_to_date,'DD/MM/RRRR') ;
      

        
        
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 0;
      END;

      RETURN nvl(v_clm_amt,0);
   END;
     
   
   
         FUNCTION get_policy_requirement (v_pol_no VARCHAR)
      RETURN varchar
   IS
      v_pol_req  VARCHAR2(2000);
   BEGIN
           
         SELECT trim(SUBSTR(V_UW_REASON, (INSTR(V_UW_REASON,' PM') +  INSTR(V_UW_REASON,' AM')+3))) REQ
          INTO v_pol_req
        FROM GNMT_POLICY
        WHERE  V_UW_REASON IS NOT NULL
        AND V_POLICY_NO = v_pol_no;
        
        RETURN v_pol_req;
   
   EXCEPTION
   WHEN OTHERS THEN
   RETURN NULL;
   end;


FUNCTION get_voucher_approval_date (VOU_NO VARCHAR)
      RETURN DATE
   IS
      V_DATE   DATE;
   BEGIN
              SELECT  TRUNC (D_LASTUPD_INFTM)
              INTO V_DATE
              FROM PY_VOUCHER_STATUS_LOG
              WHERE V_CURRENT_STATUS IN ( 'PY004','PY009','PY007','PY010')
              AND V_VOU_NO = VOU_NO;

      RETURN V_DATE;
      
      EXCEPTION
      WHEN OTHERS THEN 
      RETURN NULL;
      
   END;
   
   
   FUNCTION get_customer_identity (v_cus_no NUMBER,v_type VARCHAR)
      RETURN VARCHAR2
   IS
      IDEN_NO   VARCHAR2 (100);
   BEGIN
      
      
          select  MAX(V_IDEN_NO)
          INTO IDEN_NO
          from Gndt_Customer_Identification
          WHERE N_CUST_REF_NO = v_cus_no
          AND V_IDEN_CODE = v_type;

      RETURN IDEN_NO;
   END;
   
   
      FUNCTION get_customer_contact(v_cus_no NUMBER,v_type VARCHAR)
      RETURN VARCHAR2
   IS
      IDEN_NO   VARCHAR2 (100);
   BEGIN
      
      
     IF v_type = 'PHONE' THEN
          select  MAX(V_CONTACT_NUMBER)
          INTO IDEN_NO
          from Gndt_Custmobile_Contacts
          WHERE N_CUST_REF_NO = v_cus_no
           AND V_STATUS = 'A'
          AND V_CONTACT_NUMBER NOT LIKE '%@%';
          
     ELSIF v_type = 'EMAIL' THEN 
           select  MAX(V_CONTACT_NUMBER)
          INTO IDEN_NO
          from Gndt_Custmobile_Contacts
          WHERE N_CUST_REF_NO = v_cus_no
           AND V_STATUS = 'A'
          AND V_CONTACT_NUMBER  LIKE '%@%';
          
       ELSIF v_type = 'PIN' THEN    
            
                    SELECT MAX (V_IDEN_NO)
                    INTO IDEN_NO
                       FROM GNDT_CUSTOMER_IDENTIFICATION
                      WHERE V_IDEN_CODE = 'PIN'
                       AND V_STATUS = 'A'
                            AND V_LASTUPD_INFTIM =
                                   (SELECT MAX (V_LASTUPD_INFTIM)
                                      FROM GNDT_CUSTOMER_IDENTIFICATION
                                     WHERE V_IDEN_CODE = 'PIN'
                                     AND V_STATUS = 'A'
                                           AND N_CUST_REF_NO =v_cus_no)
                            AND N_CUST_REF_NO =v_cus_no;
    
    
     END IF;
        
      

      RETURN IDEN_NO;
   END;
   
   
         FUNCTION get_agent_policy_count(v_agent_no NUMBER)
      RETURN number
   IS
      v_count   number;
   BEGIN
      
      SELECT COUNT(DISTINCT(V_POLICY_NO))
      into v_count
      FROM AMMT_POL_AG_COMM COM
      WHERE    V_ROLE_CODE = 'SELLING'
      AND N_AGENT_NO = v_agent_no
      AND V_POLICY_NO IS NOT NULL;
       
      

      RETURN v_count;
   END;
   
   
   PROCEDURE GET_REVIVAL_OS_PREMIUM(pol_num VARCHAR,  LN_OUTS_PREM OUT NUMBER , LN_OUTS_PREM_INT   OUT NUMBER  )
   IS
      --P_POLICY_NO VARCHAR2;



      REV_OS_DT          DATE;

      LV_LAPS_CHK        VARCHAR2 (2);
      P_BASE_SUB         VARCHAR (1);

      CURSOR POL
      IS
      /*
         SELECT DISTINCT A.V_POLICY_NO,
                         V_CNTR_STAT_CODE,
                         D_PREM_DUE_DATE,
                         V_PYMT_FREQ
           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
                AND V_ROLE_CODE = 'SELLING'
                AND C.V_STATUS = 'A'
                AND A.V_POLICY_NO NOT LIKE 'GL%'
                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
                AND C.N_AGENT_NO IN
                       (1218, 28020, 54560, 28779, 40560, 17358, 34620, 22778)
         UNION
         SELECT DISTINCT A.V_POLICY_NO,
                         V_CNTR_STAT_CODE,
                         D_PREM_DUE_DATE,
                         V_PYMT_FREQ
           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
                --And V_Role_Code = 'SELLING'
                AND C.V_STATUS = 'A'
                AND A.V_POLICY_NO NOT LIKE 'GL%'
                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
                AND C.N_AGENT_NO IN (65620, 72770, 22778);
                */
                
   SELECT V_POLICY_NO,V_CNTR_STAT_CODE,D_PREM_DUE_DATE,v_pymt_freq
   FROM GNMT_POLICY
   WHERE /*V_CNTR_STAT_CODE IN ( 'NB022','NB025')
   AND*/ V_POLICY_NO NOT IN (SELECT V_POLICY_NO FROM JHL_REVIVAL_DTLS)
   AND V_POLICY_NO = pol_num ;


   BEGIN
      DELETE FROM JHL_REVIVAL_DTLS;

      FOR I IN POL
      LOOP
         --              RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);
         IF I.V_CNTR_STAT_CODE IN ('NB022', 'NB025')
         THEN
            P_BASE_SUB := 'A';
         ELSIF I.V_CNTR_STAT_CODE = 'NB010'
         THEN
            LV_LAPS_CHK := 'N';
            P_BASE_SUB := 'A';
         END IF;


         REV_OS_DT := I.D_PREM_DUE_DATE;

         WHILE NOT (TRUNC (REV_OS_DT) > TRUNC (SYSDATE))
         LOOP
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                   TO_NUMBER (I.V_PYMT_FREQ));
         END LOOP;

         REV_OS_DT :=
            BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                - (TO_NUMBER (I.V_PYMT_FREQ)));


         IF LV_LAPS_CHK = 'Y'
         THEN
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (I.D_PREM_DUE_DATE),
                                   - (TO_NUMBER (I.V_PYMT_FREQ)));
         END IF;

         BPG_REINSTATE_ENQUIRY.BPC_GET_ENQREVIVAL_PREM (I.V_POLICY_NO,
                                                        1,
                                                        'A',
                                                        TRUNC (REV_OS_DT),
                                                        SYSDATE,
                                                        LN_OUTS_PREM,
                                                        LN_OUTS_PREM_INT,
                                                        'P',
                                                        I.V_CNTR_STAT_CODE,
                                                        'N');

         INSERT INTO JHL_REVIVAL_DTLS (JRD_NO,
                                       V_POLICY_NO,
                                       LN_OUTS_PREM,
                                       LN_OUTS_PREM_INT)
              VALUES (JHL_JRD_NO_SEQ.NEXTVAL,
                      I.V_POLICY_NO,
                      LN_OUTS_PREM,
                      LN_OUTS_PREM_INT);
      --                       RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);


      END LOOP;

      COMMIT;
   END;




   
  FUNCTION get_policy_channel(v_pol_type VARCHAR , v_pol_no VARCHAR)
      RETURN varchar
   IS
      v_chanel_no   number;
   BEGIN
   
   
          IF v_pol_type   = 'P' THEN
          
          RETURN NULL;
          
          ELSE
   
    begin
            SELECT N_CHANNEL_NO
            INTO v_chanel_no 
            FROM AMMM_AGENT_MASTER 
            WHERE N_AGENT_NO = v_pol_no;
            exception
            when others then
                               
               SELECT N_CHANNEL_NO
               INTO v_chanel_no 
                FROM AMMM_AGENT_MASTER 
                where V_COMPANY_CODE||'-'|| V_COMPANY_BRANCH = v_pol_no;
               
            end;
        END IF;
      

      

      RETURN v_chanel_no;
   END;



FUNCTION get_bill_desc(v_doc_ref_no VARCHAR)
      RETURN varchar
   IS
      v_desc  varchar(200);
   BEGIN
   
               select  max(distinct V_SHORT_NAME)
               into v_desc
            from GNDT_BILL_TRANS a,   LU_CODES c
            where  V_BILL_SOURCE = LU_CODE
            and V_BILL_NO = v_doc_ref_no;

      

      RETURN v_desc;
      
      exception
      when others then
      return null;
   END;


  FUNCTION get_agent_name(v_pol_type VARCHAR , v_pol_no VARCHAR)
      RETURN varchar
   IS
      v_agn_name   VARCHAR2(200);
   BEGIN
   
   
          IF v_pol_type   = 'P' THEN
          
          RETURN NULL;
          
          ELSE
   
--            SELECT V_NAME
--            INTO v_agn_name 
--            FROM AMMM_AGENT_MASTER AGN,GNMT_CUSTOMER_MASTER CU
--            WHERE AGN.N_CUST_REF_NO = CU.N_CUST_REF_NO
--            AND N_AGENT_NO = v_pol_no;
            
            SELECT V_NAME
            INTO v_agn_name 
            FROM 
            
            (
            SELECT V_NAME
            FROM AMMM_AGENT_MASTER AGN,GNMT_CUSTOMER_MASTER CU
            WHERE AGN.N_CUST_REF_NO = CU.N_CUST_REF_NO
            AND N_AGENT_NO = v_pol_no
            UNION ALL
            SELECT V_COMPANY_NAME
            FROM AMMM_AGENT_MASTER AGN,GNMM_COMPANY_MASTER CO
            WHERE AGN.V_COMPANY_CODE = CO.V_COMPANY_CODE
                AND AGN.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH
            AND N_AGENT_NO = v_pol_no
            )
            ;
            
        END IF;
      

      

      RETURN v_agn_name;
   END;



  FUNCTION get_legacy_balance( v_pol_no VARCHAR)
      RETURN number
   IS
      v_bal   number;
   BEGIN
   
   

--   raise_error('v_pol_no=='||v_pol_no);
   
--   return 999999;

SELECT MONTHS_BETWEEN (trunc (D_DUE_DATE),
                       trunc (D_COMMENCEMENT))
       * MONTHLY_CONTRIBUTION
          LEGACY_AMOUNT
  INTO v_bal
  FROM GNMT_POLICY A,
       (SELECT DECODE (V_PYMT_FREQ, 0, 1, 1 / V_PYMT_FREQ) * N_CONTRIBUTION
                  MONTHLY_CONTRIBUTION,
               V_POLICY_NO
          FROM GNMT_POLICY
         WHERE V_POLICY_NO = v_pol_no) B,
       (SELECT D_DUE_DATE, V_POLICY_NO
          FROM PPMT_OUTSTANDING_PREMIUM
         WHERE N_OUTS_NO =
                  (SELECT MIN (N_OUTS_NO)
                     FROM PPMT_OUTSTANDING_PREMIUM
                    WHERE V_POLICY_NO = v_pol_no AND V_STATUS <> 'R')) C
 WHERE A.V_POLICY_NO = B.V_POLICY_NO AND A.V_POLICY_NO = C.V_POLICY_NO AND A.V_CNTR_STAT_CODE NOT IN ('NB051','NB211')
 UNION  
  SELECT MONTHS_BETWEEN (trunc (D_DUE_DATE),
                         trunc (D_COMMENCEMENT))
         * SUM (MONTHLY_CONTRIBUTION + RIDER_CONTRIBUTION)
            LEGACY_AMOUNT
    --  INTO v_bal
    FROM GNMT_POLICY A,
         (SELECT DECODE (V_PYMT_FREQ, 0, 1, 1 / V_PYMT_FREQ) * N_CONTRIBUTION
                    MONTHLY_CONTRIBUTION,
                 V_POLICY_NO
            FROM GNMT_POLICY A
           WHERE V_POLICY_NO = v_pol_no AND A.V_CNTR_STAT_CODE IN ('NB051','NB211')) B,
         (SELECT D_DUE_DATE, V_POLICY_NO
            FROM PPMT_OUTSTANDING_PREMIUM
           WHERE N_OUTS_NO = (SELECT MIN (N_OUTS_NO)
                                FROM PPMT_OUTSTANDING_PREMIUM
                               WHERE V_POLICY_NO = v_pol_no AND V_STATUS <> 'R')) C,
         (  SELECT DECODE (V_PYMT_FREQ, 0, 1, 1 / V_PYMT_FREQ)
                   * SUM (N_RIDER_PREMIUM)
                      RIDER_CONTRIBUTION,
                   b.V_POLICY_NO
              FROM GNMT_POLICY_RIDERS B, GNMT_POLICY A
             WHERE     B.V_POLICY_NO = A.V_POLICY_NO
                   AND b.V_POLICY_NO = v_pol_no
                   AND B.V_RIDER_STAT_CODE IN ('NB052','NB023')
          GROUP BY b.V_POLICY_NO, V_PYMT_FREQ) D
   WHERE     A.V_POLICY_NO = B.V_POLICY_NO
         AND A.V_POLICY_NO = C.V_POLICY_NO
         AND B.V_POLICY_NO = D.V_POLICY_NO
GROUP BY D_DUE_DATE, D_COMMENCEMENT;

--         RETURN V_BAL;         

           IF V_BAL  <0 THEN
           RETURN 0;
           ELSE
   
         RETURN V_BAL;
         END IF;
         
     EXCEPTION
         WHEN OTHERS THEN
         RETURN 0;
   END;
   
   
   
   FUNCTION get_agent_from( v_pol_no VARCHAR)
      RETURN VARCHAR
   IS
      v_agn_name   VARCHAR(200);
   BEGIN
   
   
        SELECT NVL(CAGN.V_NAME, CO.V_COMPANY_NAME)
        INTO v_agn_name
        FROM AMMT_POLICY_TRANSFER TRANS, AMDT_POLICY_TRANSFER POL_TRANS,AMMM_AGENT_MASTER AGN,
        GNMT_CUSTOMER_MASTER CAGN,GNMM_COMPANY_MASTER CO
        WHERE TRANS.N_POL_TRANSFER_SEQ = POL_TRANS.N_POL_TRANSFER_SEQ
        AND TRANS.N_TO_AGENT_NO = AGN.N_AGENT_NO 
        AND AGN.N_CUST_REF_NO = CAGN.N_CUST_REF_NO(+)
        AND AGN.V_COMPANY_CODE = CO.V_COMPANY_CODE(+)
        AND AGN.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH(+)
        AND  POL_TRANS.N_POL_TRANSFER_SEQ   IN (
               
                                    SELECT MAX(D.N_POL_TRANSFER_SEQ)
                                     FROM AMMT_POLICY_TRANSFER C, AMDT_POLICY_TRANSFER D
                                     WHERE C.N_POL_TRANSFER_SEQ = D.N_POL_TRANSFER_SEQ
                                     and D.V_POLICY_NUMBER  =v_pol_no
                                      );

   
         RETURN v_agn_name;

         
     EXCEPTION
         WHEN OTHERS THEN
         RETURN NULL;
   END;
   
  FUNCTION GET_OUTSTANDING_BALANCE( V_POL_NO VARCHAR)
      RETURN NUMBER
   IS
      V_BAL_2   NUMBER;
      V_BAL_3   NUMBER;
  BEGIN
   
  SELECT 
       NVL (SUM (N_AMT_RECD), 0) C
       
      INTO V_BAL_2
  FROM GNDT_BILL_IND_DETS
 WHERE     V_POLICY_NO = V_POL_NO
       AND N_SEQ_NO = 1
       AND TRUNC (D_PREM_DUE_DATE) <= SYSDATE
       AND V_REC_STATUS <> 'R';
     
  SELECT 
       NVL (SUM (N_AMT_CALLED), 0) A
       
      INTO V_BAL_3
  FROM GNDT_BILL_IND_DETS
 WHERE     V_POLICY_NO = V_POL_NO
       AND N_SEQ_NO = 1
       AND TRUNC (D_PREM_DUE_DATE) > SYSDATE
       AND N_AMT_RECD = 0
       AND V_REC_STATUS <> 'R';
         
           IF V_BAL_2  <= 0 OR V_BAL_3>= V_BAL_2  THEN
           RETURN 0;
           ELSE
   
         RETURN V_BAL_2;
         END IF;
         
     EXCEPTION
         WHEN OTHERS THEN
         RETURN 0;
   END;
   
    FUNCTION IS_VOUCHER_CANCELLED (V_VOUCHER_NO VARCHAR2)
      RETURN VARCHAR2
   IS
      V_DESC    VARCHAR2 (500);
      V_COUNT   NUMBER;
   BEGIN


  
         BEGIN
            SELECT COUNT (*)
              INTO V_COUNT
              FROM PY_VOUCHER_STATUS_LOG
             WHERE V_CURRENT_STATUS IN ( 'PY009','PY007','PY010') AND V_VOU_NO = V_VOUCHER_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_COUNT := 0;
         END;

         IF V_COUNT = 0
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;

   END;
   
   
   procedure bpc_int_acct_doc_trad(p_policy_no varchar2,p_act_process varchar2,p_docu_type varchar2, p_docu_no varchar2,p_deb_code varchar2,p_cr_code varchar2,p_amt number,p_User varchar2,p_prog varchar2,p_date date)  is

ln_int_amnt number;
ln_rem_amnt number;

ln_cnt number := 1;
    A NUMBER;
    ln_accnt_seq number;
    lv_gl_exist boolean := FALSE;
    lv_acct_type varchar2(10);
    lv_acct_code_db varchar2(30);
    lv_acct_code_cr varchar2(30);
    lv_gl_code varchar2(30);
    ln_jrn_no number;
    ln_sub_jrn_no number;
    lv_policy_currency varchar2(30);
    ln_principal number(22,2);
    ln_interest number(22,2);
    lv_gl_master_flag varchar2(1);
    lv_reverse_acct_code varchar2(30);
    lv_mstr_exist varchar2(1) := 'F';
    jour_stat varchar2(10);
    d_amount number(16,2);
    c_amount number(16,2);
    ln_trns_cnt number;
    ln_repay_int number(16,2);
    ln_int_acc   number(16,2);
    LV_PLAN_CODE GNMT_POLICY_DETAIL.V_PLAN_CODE%TYPE;
    ln_policy_year number;
    lv_lob_code varchar2(10);
    lv_par_non_par varchar2(10);
    lv_agent_branch varchar2(50);
    lv_buz_unit   varchar2(50);
    ln_cnt1 number:=0;
    ld_last_date date;
    n_last_int_amt number;
     lv_currency_code varchar2(30);
     lv_currency_desc varchar2(50);

begin



Bpg_Gen.BPC_GET_PLAN_FOR_THE_POLICY(p_policy_no, lv_plan_code);
Bpg_gen.bpc_get_policy_currency (p_policy_no,lv_currency_code,lv_currency_desc);

                        -- Derivation of Line of Business
                            lv_lob_code := bpg_gen.Bfn_Get_LOB_Code_From_Policy(p_policy_no);

                        -- Derivation of Policy Year
                            ln_policy_year := Bpg_Gen.BFN_GET_POLICY_YEAR(p_policy_no,
                                                1,
                                                LV_PLAN_CODE,
                                                'P',
                                                sysdate,
                                                NULL );

                        -- Derivation of Par or non par

                            lv_par_non_par := bpg_policy.bfn_check_par_nonpar (p_policy_no,1, LV_PLAN_CODE, LV_PLAN_CODE);

                        -- Derivation of Agent Branch  added by VASAN.

                            lv_agent_branch:= Bpg_Baj_Accounting.Bfn_Agent_Branch_For_Policy(p_policy_no);

                        -- Derivation of business unit

                            lv_buz_unit  :=Bpg_Baj_Accounting.Bfn_Buz_Unit_For_Policy(p_policy_no);
           dbms_output.put_line('p_deb_code'||p_deb_code);
                      dbms_output.put_line('p_cr_code'||p_cr_code);
bpg_ps_common.bpc_insert_gl(p_policy_no,1,SYSDATE,'Y',p_docu_type,p_docu_no,p_deb_code,'D',p_amt,lv_currency_code,p_act_process,
                                                 ln_jrn_no,ln_sub_jrn_no,p_user,p_prog,SYSDATE,
                                                 lv_plan_code,'M','N',
                                                 ln_policy_year,
                                                 null,
                                                 lv_agent_branch,
                                                 lv_lob_code,
                                                 lv_par_non_par,
                                                 null,
                                                 lv_buz_unit
                                                 );

bpg_ps_common.bpc_insert_gl(p_policy_no,1,SYSDATE,'N',p_docu_type,p_docu_no,p_cr_code,'C',p_amt,lv_currency_code,p_act_process,
                                                 ln_jrn_no,ln_sub_jrn_no,p_user,p_prog,SYSDATE,
                                                 lv_plan_code,'M','N',
                                                 ln_policy_year,
                                                 null,
                                                 lv_agent_branch,
                                                 lv_lob_code,
                                                 lv_par_non_par,
                                                 null,
                                                 lv_buz_unit
                                                 );

                     --   dbms_output.put_line('LV_GL_EXIST'||LV_GL_EXIST);
                            --if first record then insert gl master record and corresponding detail record

                 bpg_baj_accounting.bpc_journal_audit
                 (ln_jrn_no,jour_stat,d_amount,c_amount,
                         p_User,p_prog,sysdate);


end;

   
   
   
PROCEDURE future_prem_utilization_proc  is
   lv_receipt_no   VARCHAR2 (100);     
begin

FOR I IN (SELECT A.N_AMOUNT,B.N_NET_CONTRIBUTION,B.D_PREM_DUE_DATE,b.v_policy_no,b.v_plan_code,b.v_pymt_freq,
   b.d_commencement,Bpg_Policy.bfn_get_policy_anniversary(a.v_policy_no, 1) ,nvl(Bpg_Grplife_Billing.bfn_get_amt_due(b.v_policy_no,1,null,null),0) dueamt,
   b.V_CURRENCY_CODE FROM
      ppmt_overshort_payment a,gnmt_policy b
where trunc(b.d_prem_paying_end_date)> trunc(sysdate) and trunc(b.d_prem_due_date)< Bpg_Policy.bfn_get_policy_anniversary(a.v_policy_no, 1) and A.N_AMOUNT>=B.n_net_contribution and n_amount > 0 and v_type='O'  and a.v_policy_no=b.v_policy_no and
b.v_cntr_stat_code='NB010' and b.v_excess_payment_option ='FP') ---and a.v_policy_no='207339' )
loop
lv_receipt_no :=Bpg_Grplife_Billing.get_wop_receipt_no ;

bpc_int_acct_doc_trad(i.v_policy_no,'ACT001','RECEIPT', i.v_policy_no,'GRA010','GRA018',I.n_amount,USER,USER,SYSDATE);
  Bpg_Grplife_Billing.grp_appropriate_over_short(i.v_policy_no,
            1,
            I.n_amount,
            'S'    ,
            lv_receipt_no,
            'RECEIPT' ,
            sysdate,
            USER,
            'FP_APPROP');
BPG_GRPLIFE_BILLING.INSERT_RECEIPT_HOLDING_ACCOUNT(
                                                                    i.v_policy_no,
                                                                    1,
                                                                    'D' ,
                                                                    lv_receipt_no,
                                                                    1,
                                                                    98,
                                                                    sysdate,
                                                                    NVL(i.n_amount,0),
                                                                    'P',
                                                                    NULL,
                                                                    user,
                                                                    'FP_APPROP',
                                                                    sysdate,
                                                                    i.V_POLICY_NO,
                                                                    i.V_POLICY_NO,
                                                                    nvl(i.V_CURRENCY_CODE,'KES'));

                            BPG_GRPLIFE_BILLING.INSERT_GRPOLICY_RECDETS(
                                                                    P_RECEIPT_DATE     => SYSDATE,
                                                                    P_POLREF_NO        => I.V_POLICY_NO,
                                                                    P_SEQ_NO        => 1,
                                                                    P_FUND_CD        => NULL,
                                                                    P_RECEIPT_CD    => 98,
                                                                    P_AMT_DUE        => NVL(I.dueamt,0),
                                                                    P_AMT_RECVD        => NVL(I.n_amount,0),
                                                                    P_STAT            => NULL,
                                                                    P_USER            => user,
                                                                    P_PROG            => 'FP_APPROP',
                                                                    P_INFTIM        => sysdate,
                                                                    P_RECEIPT_NO    => lv_receipt_no,
                                                                    P_KNOCK_AMT        => NVL(i.n_amount,0),
                                                                    P_COMP_CD        => i.V_POLICY_NO,
                                                                    P_COMP_BRANCH    => i.V_POLICY_NO,
                                                                    P_RECEIPT_CURRENCY         => nvl(i.V_CURRENCY_CODE,'KES'),
                                                                    P_EXCESS_PAYMENT_OPTION =>'FP',
                                                                    P_PRICING_OPTION        => NULL,
                                                                    P_BACK_PRICING_DATE        => NULL,
                                                                    P_AGENT_COMM_GROSS_NET    => 'N'
                                                                    );



                            BPG_PROCESS_RECEIPTS.BPC_PROCESS_EXCESS_PAYMENT(lv_receipt_no,USER,'FP_APPROP',SYSDATE);
                            BPG_GRPLIFE_BILLING.KNOCK_DN_FROM_RECEIPT_HOLDING(user,'FP_APPROP',sysdate,i.v_policy_no );




end loop;
commit;
END;



FUNCTION get_entry_channel(ref_no NUMBER )
      RETURN varchar
   IS
      v_chanel_no   number;
      v_pol_type VARCHAR (10) ;
      v_pol_no VARCHAR(50);
   BEGIN
   
  SELECT V_POLAG_TYPE,V_POLAG_NO
  INTO v_pol_type,v_pol_no
FROM GNMT_GL_MASTER GL
WHERE  GL.N_REF_NO = ref_no;
   
          IF v_pol_type   = 'P' THEN
          
          RETURN NULL;
          
          ELSE
           begin
            SELECT N_CHANNEL_NO
            INTO v_chanel_no 
            FROM AMMM_AGENT_MASTER 
            WHERE N_AGENT_NO = v_pol_no;
            exception
            when others then
                               
               SELECT N_CHANNEL_NO
               INTO v_chanel_no 
                FROM AMMM_AGENT_MASTER 
                where V_COMPANY_CODE||'-'|| V_COMPANY_BRANCH = v_pol_no;
               
            end;
            
            
        END IF;
      

      RETURN v_chanel_no;
      
    exception
    when others then
    RETURN NULL;
    
   END;
  FUNCTION GET_NUM_OS (V_POL_NO VARCHAR)
      RETURN VARCHAR
   IS
      V_NUM_OS   NUMBER;

   BEGIN
      
        SELECT BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE (V_POLICY_NO)
                / (SELECT DECODE (D.V_PYMT_FREQ, 0, 1, 1 / D.V_PYMT_FREQ)
                          * D.N_CONTRIBUTION
                     FROM GNMT_POLICY D
                    WHERE D.V_POLICY_NO = E.V_POLICY_NO
                          AND D.V_POLICY_NO = V_POLICY_NO
                          )
                   OUTS_PREM
           INTO V_NUM_OS
           FROM GNMT_POLICY E 
           WHERE E.V_POLICY_NO =V_POL_NO ;
           
           /* SELECT BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE (E.V_POLICY_NO)
                / (SELECT DECODE (D.V_PYMT_FREQ, 0, 1, 1 / D.V_PYMT_FREQ)
                          * D.N_CONTRIBUTION
                     FROM GNMT_POLICY D
                    WHERE D.V_POLICY_NO  = E.V_POLICY_NO
                          )
                   OUTS_PREM
           INTO V_NUM_OS
           FROM GNMT_POLICY E 
           WHERE E.V_POLICY_NO =V_POL_NO
           AND E.V_POLICY_NO NOT LIKE 'GL%' ;*/

         IF V_NUM_OS >3
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
         
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;
   
     FUNCTION GET_NUM (V_POL_NO VARCHAR)
      RETURN NUMBER
   IS
      V_NUM_OS   NUMBER;

   BEGIN
      
         SELECT BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE (V_POLICY_NO)
                / (SELECT DECODE (D.V_PYMT_FREQ, 0, 1, 1 / D.V_PYMT_FREQ)
                          * D.N_CONTRIBUTION
                     FROM GNMT_POLICY D
                    WHERE D.V_POLICY_NO = E.V_POLICY_NO
                          AND D.V_POLICY_NO = V_POLICY_NO
                          )
                   OUTS_PREM
           INTO V_NUM_OS
           FROM GNMT_POLICY E 
           WHERE E.V_POLICY_NO =V_POL_NO ;

--         IF V_Num_Os >= 3
--         THEN
--            RETURN 'N';
--         ELSE
--            RETURN 'Y';
--         END IF;
RETURN V_NUM_OS;
         
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;
   
  FUNCTION GET_MATURITY_MONTH_BAL (V_POL_NO VARCHAR)
      RETURN VARCHAR
   IS
      V_MON_OS   NUMBER;
 
 BEGIN
 
 SELECT MONTHS_BETWEEN (TO_DATE (C.D_PREM_PAYING_END_DATE, 'dd/mm/rrrr'),
                       TO_DATE (SYSDATE, 'dd/mm/rrrr'))
          MATURITY_MONTHS
  INTO V_MON_OS
  FROM GNMT_POLICY_DETAIL A,
       GNDT_CUSTOMER_ADDRESS B,
       GNMT_POLICY C,
       GNMM_PLAN_MASTER D
 WHERE     A.V_POLICY_NO = C.V_POLICY_NO
       AND C.V_POLICY_NO = V_POL_NO
       AND V_GRP_IND_FLAG = 'I'
       AND A.N_SEQ_NO = 1
       AND C.N_TERM <= 10
       AND A.N_CUST_REF_NO = B.N_CUST_REF_NO
      -- AND B.N_ADD_SEQ_NO = 1
       AND B.N_ADD_SEQ_NO IN (
            SELECT  MAX( B.N_ADD_SEQ_NO)
            FROM GNDT_CUSTOMER_ADDRESS B, GNMT_POLICY D
            WHERE  D.N_PAYER_REF_NO = B.N_CUST_REF_NO
            AND D.V_POLICY_NO  = V_POL_NO
            AND V_CORRES_ADDRESS = 'Y' )
       AND A.V_CNTR_STAT_CODE IN
              ('NB010', 'NB011', 'NB008', 'NB014', 'NB211')
       AND C.V_PLAN_CODE = D.V_PLAN_CODE
       AND C.V_PLAN_CODE IN
              ('BJUB010', 'BFP001', 'BFP002', 'BJUB012', 'BJUB015', 'BJUB018');

            IF V_MON_OS > 2
            THEN
            RETURN 'N';
            ELSE 
            RETURN 'Y';
            END IF;

EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
  
 END;
 
     FUNCTION GET_MATURITY_MONTH_BAL2 (V_POL_NO VARCHAR)
      RETURN VARCHAR
   IS
      V_MON_OS2   NUMBER;
 
 BEGIN
 
 SELECT MONTHS_BETWEEN (TO_DATE (C.D_PREM_PAYING_END_DATE, 'dd/mm/rrrr'),
                       TO_DATE (SYSDATE, 'dd/mm/rrrr'))
          MATURITY_MONTHS
  INTO V_MON_OS2
  FROM GNMT_POLICY_DETAIL A,
       GNDT_CUSTOMER_ADDRESS B,
       GNMT_POLICY C,
       GNMM_PLAN_MASTER D
 WHERE     V_GRP_IND_FLAG = 'I'
       AND A.N_SEQ_NO = 1
       AND A.N_CUST_REF_NO = B.N_CUST_REF_NO
        AND B.N_ADD_SEQ_NO IN (
            SELECT  MAX( B.N_ADD_SEQ_NO)
            FROM GNDT_CUSTOMER_ADDRESS B, GNMT_POLICY D
            WHERE  D.N_PAYER_REF_NO = B.N_CUST_REF_NO
            AND D.V_POLICY_NO  = V_POL_NO
            AND V_CORRES_ADDRESS = 'Y')
       AND A.V_POLICY_NO = C.V_POLICY_NO
       AND C.V_POLICY_NO = V_POL_NO
       AND A.V_CNTR_STAT_CODE IN
              ('NB010', 'NB011', 'NB008', 'NB014', 'NB211')
       AND C.V_PLAN_CODE = D.V_PLAN_CODE
       AND C.V_PLAN_CODE NOT IN
              ('BJUB010',
               'BFP001',
               'BFP002',
               'BJUB012',
               'BJUB015',
               'BJUB018',
               'BMRTA20',
               'BMRTA15',
               'BMRTA10',
               'BMRTA05',
               'BMRSPREM',
               'BTERM01');
       
              IF V_MON_OS2 > 3
            THEN
            RETURN 'N';
            ELSE 
            RETURN 'Y';
            END IF;


EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
  
 END;

 FUNCTION GET_MATURITY_MONTH_BAL3 (V_POL_NO VARCHAR)
      RETURN VARCHAR
   IS
      V_MON_OS3   NUMBER;
 
 BEGIN
 
 SELECT MONTHS_BETWEEN (TO_DATE (C.D_PREM_PAYING_END_DATE, 'dd/mm/rrrr'),
                       TO_DATE (SYSDATE, 'dd/mm/rrrr'))
          MATURITY_MONTHS
  INTO V_MON_OS3
  FROM GNMT_POLICY_DETAIL A,
       GNDT_CUSTOMER_ADDRESS B,
       GNMT_POLICY C,
       GNMM_PLAN_MASTER D
 WHERE     A.V_POLICY_NO = C.V_POLICY_NO
       AND C.V_POLICY_NO = V_POL_NO
       AND V_GRP_IND_FLAG = 'I'
       AND A.N_SEQ_NO = 1
       AND C.N_TERM >= 10
       AND A.N_CUST_REF_NO = B.N_CUST_REF_NO
       --AND B.N_ADD_SEQ_NO = 1
       AND B.N_ADD_SEQ_NO IN (
            SELECT  MAX( B.N_ADD_SEQ_NO)
            FROM GNDT_CUSTOMER_ADDRESS B, GNMT_POLICY D
            WHERE  D.N_PAYER_REF_NO = B.N_CUST_REF_NO
            AND D.V_POLICY_NO  = V_POL_NO
            AND V_CORRES_ADDRESS = 'Y')
       AND A.V_CNTR_STAT_CODE IN
              ('NB010', 'NB011', 'NB008', 'NB014', 'NB211')
       AND C.V_PLAN_CODE = D.V_PLAN_CODE
       AND C.V_PLAN_CODE IN
              ('BJUB010', 'BFP001', 'BFP002', 'BJUB012', 'BJUB015', 'BJUB018');

            IF V_MON_OS3 > 3
            THEN
            RETURN 'N';
            ELSE 
            RETURN 'Y';
            END IF;

EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
  
 END;

   FUNCTION GET_UPR_AMOUNT (
  V_POL_NO VARCHAR,
  V_QUOT_BACKUP_TYPE VARCHAR,
  D_POLICY_END_DATE DATE,
  D_CNTR_START_DATE DATE,
  D_CNTR_END_DATE DATE,
  D_BILL_DUE_DATE DATE,
  D_BILL_RAISED date ,
  N_BILL_AMT NUMBER,
  N_TERM   NUMBER,
  D_COMMENCEMENT date ,
    V_BILL_TYPE VARCHAR )  RETURN NUMBER
    IS
         v_upr_amt   NUMBER;
         v_end_date date;
         v_end_date_term date;


BEGIN
-- RAISE_ERROR('SIGN=='||sign(to_date(D_POLICY_END_DATE,'DD/MM/RRRR')  -  to_date(last_day(D_BILL_RAISED) ,'DD/MM/RRRR')) );

--RAISE_ERROR( 'D_POLICY_END_DATE =='||to_date(D_POLICY_END_DATE,'DD/MM/RRRR') );
--RAISE_ERROR( 'D_BILL_RAISED =='||to_date(last_day(D_BILL_RAISED) ,'DD/MM/RRRR') );

-- if  ( sign(TRUNC(D_POLICY_END_DATE)  -  TRUNC(last_day(D_BILL_RAISED))) = -1) then
-- return 0;
-- end if;

--  if  ( sign(TRUNC(D_CNTR_END_DATE)  -  TRUNC(last_day(D_BILL_RAISED))) = -1) then
-- return 0;
-- end if;

 v_end_date := nvl(D_POLICY_END_DATE , D_CNTR_END_DATE);
 
  if (to_number(TO_CHAR(D_POLICY_END_DATE,'YYYY'))  > to_number(TO_CHAR(SYSDATE,'YYYY')) +1) 
  then
   if V_QUOT_BACKUP_TYPE IN  ('PS','BF') THEN
   v_end_date  := trunc(D_COMMENCEMENT)  + ( N_TERM * 365);
--   RAISE_ERROR('v_end_date=='||v_end_date ||'D_CNTR_START_DATE=='||D_CNTR_START_DATE||'N_TERM=='||N_TERM);
   ELSE
  v_end_date  := trunc(D_BILL_DUE_DATE)  + ( N_TERM * 365);
  END IF;
  end if;

  if  ( sign(TRUNC(v_end_date)  -  TRUNC(last_day(D_BILL_RAISED)))  < 1) then
 return 0;
 end if;



-- if V_BILL_TYPE = 'EX' THEN

--RAISE_ERROR('v_end_date == '||v_end_date);
--RAISE_ERROR('D_BILL_RAISED == '||D_BILL_RAISED);
--RAISE_ERROR('D_BILL_DUE_DATE == '||D_BILL_DUE_DATE);
--RAISE_ERROR('N_BILL_AMT == '||v_end_date);

 if V_QUOT_BACKUP_TYPE IN  ('PS','BF') THEN
 
  SELECT round((TRUNC(v_end_date) - TRUNC(last_day(D_BILL_RAISED) )) /  (TRUNC(v_end_date) - TRUNC(D_COMMENCEMENT )) *  decode(V_BILL_TYPE,'DN',-N_BILL_AMT,N_BILL_AMT) , 2) 
 INTO v_upr_amt
 FROM DUAL;
 
 ELSE
 
 SELECT round((TRUNC(v_end_date) - TRUNC(last_day(D_BILL_RAISED) )) /  (TRUNC(v_end_date) - TRUNC(D_BILL_DUE_DATE )) *  decode(V_BILL_TYPE,'DN',-N_BILL_AMT,N_BILL_AMT) , 2) 
 INTO v_upr_amt
 FROM DUAL;
 END IF;
 
 
-- ELSE
-- 
-- SELECT round((TRUNC(D_CNTR_END_DATE) - TRUNC(last_day(D_BILL_RAISED))) /  (TRUNC(D_CNTR_END_DATE) - TRUNC(D_CNTR_START_DATE )) *  decode(V_BILL_TYPE,'DN',-N_BILL_AMT,N_BILL_AMT) , 2) 
-- INTO v_upr_amt
-- FROM DUAL;
-- 
-- 
-- END IF;


/*UN EARNED PREMIUM RESERVE*/

return v_upr_amt;

END;


FUNCTION get_voucher_payment_method  (V_Voucher_No VARCHAR2)
      RETURN VARCHAR2
   IS
      V_Desc    VARCHAR2 (500);
      V_Count   NUMBER;
        v_pymt   VARCHAR2 (10);
   BEGIN
   
     /* BEGIN
         SELECT UPPER (V_Vou_Desc)
           INTO V_Desc
           FROM Pymt_Voucher_Root Pm, Pymt_Vou_Master Pv
          WHERE Pm.V_Main_Vou_No = Pv.V_Main_Vou_No
                AND Pv.V_Vou_No = V_Voucher_No;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_Desc := NULL;
      END;

      IF V_Desc LIKE '%COMMISSION%'
      THEN
         RETURN 'Y';
      ELSE
         BEGIN
            SELECT COUNT (*)
              INTO V_Count
              FROM Py_Voucher_Status_Log
             WHERE V_Current_Status = 'PY004' AND V_Vou_No = V_Voucher_No;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_Count := 0;
         END;

         IF V_Count = 0
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END IF;*/
      
           begin
            SELECT distinct  VP.V_INST_TYPE 
             into  v_pymt 
            FROM PYDT_VOUCHER_PAYMENTS VP 
             WHERE VP.V_VOU_NO  = V_Voucher_No
             and VP.V_INST_STATUS ='A';
           end;

        return v_pymt;
        
        EXCEPTION
        
        WHEN NO_DATA_FOUND THEN
        
        RETURN NULL;
      
   END;
   
   


  PROCEDURE GET_REVIVAL_PREMIUM(v_pol_no VARCHAR)
   IS
      V_POLICY_NO VARCHAR2 (40);
     LN_OUTS_PREM       NUMBER;
      LN_OUTS_PREM_INT   NUMBER;

      REV_OS_DT          DATE;

      LV_LAPS_CHK        VARCHAR2 (2);
      P_BASE_SUB         VARCHAR (1);

      CURSOR POL
      IS
         SELECT DISTINCT A.V_POLICY_NO,
                         V_CNTR_STAT_CODE,
                         D_PREM_DUE_DATE,
                         V_PYMT_FREQ
           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
                AND V_ROLE_CODE = 'SELLING'
                AND C.V_STATUS = 'A'
                AND A.V_POLICY_NO NOT LIKE 'GL%'
                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
                and A.V_POLICY_NO =v_pol_no;
--                AND C.N_AGENT_NO IN
--                       (1218, 28020, 54560, 28779, 40560, 17358, 34620, 22778)
--         UNION
--         SELECT DISTINCT A.V_POLICY_NO,
--                         V_CNTR_STAT_CODE,
--                         D_PREM_DUE_DATE,
--                         V_PYMT_FREQ
--           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
--          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
--                --And V_Role_Code = 'SELLING'
--                AND C.V_STATUS = 'A'
--                AND A.V_POLICY_NO NOT LIKE 'GL%'
--                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
--                AND C.N_AGENT_NO IN (65620, 72770, 22778);
                
     
   BEGIN
   
--   DELETE FROM JHL_COL_REVIVAL_DTLS;
--
--         INSERT INTO JHL_COL_REVIVAL_DTLS (JRD_NO,
--                                       V_POLICY_NO,
--                                       LN_OUTS_PREM,
--                                       LN_OUTS_PREM_INT)
--              VALUES (JHL_JRD_NO_SEQ.NEXTVAL,
--                      v_pol_no,
--                      -100,
--                      -100);


      DELETE FROM JHL_COL_REVIVAL_DTLS WHERE V_POLICY_NO = v_pol_no;

      FOR I IN POL
      LOOP
         --              RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);
         IF I.V_CNTR_STAT_CODE IN ('NB022', 'NB025')
         THEN
            P_BASE_SUB := 'A';
         ELSIF I.V_CNTR_STAT_CODE = 'NB010'
         THEN
            LV_LAPS_CHK := 'N';
            P_BASE_SUB := 'A';
         END IF;


         REV_OS_DT := I.D_PREM_DUE_DATE;

         WHILE NOT (TRUNC (REV_OS_DT) > TRUNC (SYSDATE))
         LOOP
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                   TO_NUMBER (I.V_PYMT_FREQ));
         END LOOP;

         REV_OS_DT :=
            BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                - (TO_NUMBER (I.V_PYMT_FREQ))+1);


         IF LV_LAPS_CHK = 'Y'
         THEN
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (I.D_PREM_DUE_DATE),
                                   - (TO_NUMBER (I.V_PYMT_FREQ)));
         END IF;

         BPG_REINSTATE_ENQUIRY.BPC_GET_ENQREVIVAL_PREM (I.V_POLICY_NO,
                                                        1,
                                                        'A',
                                                        TRUNC (REV_OS_DT),
                                                        SYSDATE,
                                                        LN_OUTS_PREM,
                                                        LN_OUTS_PREM_INT,
                                                        'P',
                                                        I.V_CNTR_STAT_CODE,
                                                        'N');

         INSERT INTO JHL_COL_REVIVAL_DTLS (JRD_NO,
                                       V_POLICY_NO,
                                       LN_OUTS_PREM,
                                       LN_OUTS_PREM_INT)
              VALUES (JHL_JRD_NO_SEQ.NEXTVAL,
                      I.V_POLICY_NO,
                      LN_OUTS_PREM,
                      LN_OUTS_PREM_INT);
      --                       RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);


      END LOOP;

      COMMIT;
   END;
   
   
   
   
  PROCEDURE GENERATE_POL_BONUS(v_pol_no VARCHAR) IS

CURSOR POLICIES IS 
SELECT *
FROM    GNMT_POLICY
WHERE V_POLICY_NO NOT LIKE 'GL%'
--AND V_CNTR_STAT_CODE = 'NB010'
--and V_POLICY_NO not in (select V_POLICY_NO from JHL_POLICY_AMOUNTS) 
AND V_POLICY_NO  = v_pol_no;

CURSOR    CR_GET_BONUS( v_pol_num VARCHAR)
IS
select N_last_act_bonus,N_RB_ACT_AMT,N_ACTUAL_TOT_AMT
 from  PS_RB_CRB_TEMP 
 where  V_POLICY_NO        = v_pol_no
 and N_policy_year=(select max(N_policy_year)-1 from PS_RB_CRB_TEMP)
 and  V_BONUS_TYPE    = 'ACC-B';

LV_ACTUAL_BONUS        NUMBER(16,2);
LV_INTERIM_BONUS    NUMBER(16,2);

LN_LAST_ACT_BONUS     NUMBER(16,2) :=NULL;
LN_RB_ACT_AMT         NUMBER(16,2) :=NULL;
LN_TOT_BONUS         NUMBER(16,2)  :=NULL;

v_existing_bonus         NUMBER(16,2)  :=NULL;
v_added_bonus         NUMBER(16,2)  :=NULL;


v_count number;

LN_BONUS_RATE         NUMBER(16,2) :=NULL;
LN_D_BONUS_DUE        DATE :=NULL;
N_VALUE_CSV  NUMBER  :=NULL;

 v_pol_loan  NUMBER  := NULL;
 v_pol_loan_int  NUMBER := NULL;
 
      ld_calc_date date;
     lv_policy_status gnmt_policy.v_cntr_stat_code%TYPE;
 
 /*ADDE ON 15JUL2020*/
v_due_apl NUMBER :=  NULL;
v_due_apl_int NUMBER :=NULL;
BEGIN
begin
    JHL_GEN_PKG.GENERATE_POL_AMOUNTS(v_pol_no);
    commit;
  end;

  DELETE FROM JHL_POLICY_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;

FOR I IN POLICIES LOOP

            DELETE FROM JHL_POLICY_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;
            
            DELETE FROM PS_RB_CRB_TEMP_TEST WHERE V_POLICY_NO =  v_pol_no;

 LV_ACTUAL_BONUS := NULL; 
 LV_INTERIM_BONUS := NULL;
 LN_LAST_ACT_BONUS := NULL;
 LN_RB_ACT_AMT := NULL; 
 LN_TOT_BONUS := NULL;
  LN_BONUS_RATE := NULL; 
 LN_D_BONUS_DUE := NULL;
 N_VALUE_CSV := NULL;
 
 v_pol_loan  := NULL;
  v_pol_loan_int  := NULL;
  
 ld_calc_date := TRUNC(sysdate); 
 
 
 IF I.v_cntr_stat_code = 'NB211' THEN
     lv_policy_status := 'CL';
ELSE
     lv_policy_status := NULL;
END IF;



 
    BPG_POLICY_SERVICING_V2.BPC_GET_ACTUAL_INTERIM_BONUS(I.V_POLICY_NO,1,NULL,NULL,'Q',ld_calc_date,lv_policy_status,NULL,NULL,LV_ACTUAL_BONUS ,LV_INTERIM_BONUS ,USER,
                                                            'ABC',SYSDATE,'P');
                                                            

             
    
         insert into PS_RB_CRB_TEMP_TEST (
         V_POLICY_NO, N_SEQ_NO, V_BONUS_TYPE, V_PLAN_CODE, V_PARENT_PLAN_CODE, N_POLICY_YEAR, N_BONUS_RATE, N_UNITS, N_AMOUNT, 
         N_LAST_ACT_BONUS, N_RB_ACT_AMT, N_CR_ACT_AMT, N_LAST_INT_BONUS, N_RB_INT_AMT, N_CR_INT_AMT, N_ACTUAL_TOT_AMT, 
         N_INTERIM_TOT_AMT, D_BONUS_DUE, N_TOT_BONUS, N_SA)
        select  V_POLICY_NO, N_SEQ_NO, V_BONUS_TYPE, V_PLAN_CODE, V_PARENT_PLAN_CODE, N_POLICY_YEAR, N_BONUS_RATE, N_UNITS, N_AMOUNT, 
         N_LAST_ACT_BONUS, N_RB_ACT_AMT, N_CR_ACT_AMT, N_LAST_INT_BONUS, N_RB_INT_AMT, N_CR_INT_AMT, N_ACTUAL_TOT_AMT, 
         N_INTERIM_TOT_AMT, D_BONUS_DUE, N_TOT_BONUS, N_SA
        from PS_RB_CRB_TEMP
         where  V_POLICY_NO        = I.V_POLICY_NO;                                               
                 
                                                            
          select  count(*)
          into v_count
          from PS_RB_CRB_TEMP
           where  V_POLICY_NO        = I.V_POLICY_NO;
           
           
           BEGIN
    select N_last_act_bonus,N_RB_ACT_AMT,N_ACTUAL_TOT_AMT
    INTO    LN_LAST_ACT_BONUS ,LN_RB_ACT_AMT , LN_TOT_BONUS
 from  PS_RB_CRB_TEMP 
 where  V_POLICY_NO        =  I.V_POLICY_NO
 and N_policy_year=(select max(N_policy_year)-1 from PS_RB_CRB_TEMP)
 and  V_BONUS_TYPE    = 'ACC-B';
 EXCEPTION
 WHEN  NO_DATA_FOUND THEN
 LN_LAST_ACT_BONUS := NULL;
 LN_RB_ACT_AMT := NULL; 
 LN_TOT_BONUS := NULL;
 END;
 
 
 BEGIN
 
-- PS_RB_CRB_TEMP_TEST
  select N_BONUS_RATE, D_BONUS_DUE
  INTO LN_BONUS_RATE,LN_D_BONUS_DUE
 from  PS_RB_CRB_TEMP 
 where  V_POLICY_NO        =   I.V_POLICY_NO
 and N_policy_year=(select max(N_policy_year)-1 from PS_RB_CRB_TEMP)
 and  V_BONUS_TYPE    = 'RB';
 
 EXCEPTION
 WHEN  NO_DATA_FOUND THEN
 LN_BONUS_RATE := NULL;
 LN_D_BONUS_DUE := NULL; 
 END;
 
--           commit;
           
           

--           raise_error('v_count=='||v_count);
           
                                                            
   BPG_CSV.BPC_CALC_PAIDUPRT_CSV(I.V_POLICY_NO,1,NULL,NULL,SYSDATE,N_VALUE_CSV);
   
   
      bpg_policy_servicing.bpc_get_loan_due_details (I.V_POLICY_NO,
                                                                                    1,      
                                                                                     TRUNC(SYSDATE),
                                                                                       v_pol_loan,
                                                                                       v_pol_loan_int);
                                                                                       
      /*ADDED 15072020*/                                                                                 
      BPG_POLICY_SERVICING.BPC_GET_APL_DUE_DETAILS (I.V_POLICY_NO, 1,TRUNC(SYSDATE), V_DUE_APL, V_DUE_APL_INT);
                                                                                       
/*
insert into PS_RB_CRB_TEMP_TEST
select *
from PS_RB_CRB_TEMP;*/
--


--    OPEN    CR_GET_BONUS;
--    FETCH    CR_GET_BONUS    INTO    LN_LAST_ACT_BONUS ,LN_RB_ACT_AMT , LN_TOT_BONUS;
--    CLOSE    CR_GET_BONUS;
--
--insert into PS_RB_CRB_TEMP_TEST
--select *
--from PS_RB_CRB_TEMP;

--    
    
 
 
 

--    RAISE_APPLICATION_ERROR(-20001,
--     'v_count =='||v_count||
--                                             'LV_ACTUAL_BONUS=='||LV_ACTUAL_BONUS||
--                                              'LV_INTERIM_BONUS=='||LV_INTERIM_BONUS||
--                                                'LN_LAST_ACT_BONUS=='||LN_LAST_ACT_BONUS||
--                                               'LN_RB_ACT_AMT=='||LN_RB_ACT_AMT||
--                                               'LN_TOT_BONUS=='||LN_TOT_BONUS);
                                               
  DELETE FROM JHL_POLICY_AMOUNTS WHERE V_POLICY_NO =  v_pol_no; 
  INSERT INTO JHL_POLICY_AMOUNTS(V_POLICY_NO, POL_ACTUAL_BONUS_AMT, POL_INTERIM_BONUS_AMT, 
                                                        POL_EXISTING_BONUS, POL_ADDED_BONUS, POL_TOTAL_BONUS,
                                                        POL_BONUS_RATE, POL_BONUS_DUE,POL_BONUS_INFO,POL_CSV_AMOUNT,
                                                        POL_LOAN, POL_LOAN_INT,POL_DUE_APL, POL_DUE_APL_INT)
  VALUES(I.V_POLICY_NO,LV_ACTUAL_BONUS,LV_INTERIM_BONUS,LN_LAST_ACT_BONUS,LN_RB_ACT_AMT, LN_TOT_BONUS,LN_BONUS_RATE/1000*100,
  TO_CHAR(LN_D_BONUS_DUE,'YYYY'),  TO_NUMBER(TO_CHAR(LN_D_BONUS_DUE,'YYYY'))+ 1,N_VALUE_CSV,
  v_pol_loan, v_pol_loan_int,v_due_apl ,v_due_apl_int);
  
  

   
                                              
END LOOP;


    commit; 

--   :CP_TOTAL_BONUS := LN_LAST_ACT_BONUS+ LN_RB_ACT_AMT;
--   :CP_LAST_BONUS :=  LN_LAST_ACT_BONUS;
--   :CP_CURRENT_BONUS := LN_RB_ACT_AMT;

--   RETURN 0;
END;


  PROCEDURE POPULATE_LIFE_CUSTOMERS IS
  
  begin
  
delete from JHL_LIFE_CUSTOMERS;


insert into JHL_LIFE_CUSTOMERS 
(CUST_NAME, PIN, ID_NO, EMAIL, PHONE, D_BIRTH_DATE, N_CUST_REF_NO)

select  V_NAME,(SELECT  max(V_IDEN_NO)
          FROM GNDT_CUSTOMER_IDENTIFICATION
         WHERE    V_IDEN_CODE = 'PIN'
               and  V_LASTUPD_INFTIM = (SELECT  max(V_LASTUPD_INFTIM)
                                                          FROM GNDT_CUSTOMER_IDENTIFICATION 
                                                         WHERE    V_IDEN_CODE = 'PIN'
                                                               and N_CUST_REF_NO = C.N_CUST_REF_NO)
               and N_CUST_REF_NO = C.N_CUST_REF_NO) PIN,
               
               (SELECT  max(V_IDEN_NO)
          FROM GNDT_CUSTOMER_IDENTIFICATION
         WHERE    V_IDEN_CODE = 'NIC'
               and  V_LASTUPD_INFTIM = (SELECT  max(V_LASTUPD_INFTIM)
                                                          FROM GNDT_CUSTOMER_IDENTIFICATION 
                                                         WHERE    V_IDEN_CODE = 'NIC'
                                                               and N_CUST_REF_NO = C.N_CUST_REF_NO)
               and N_CUST_REF_NO = C.N_CUST_REF_NO) ID_NO,
                (SELECT V_CONTACT_NUMBER
             FROM GNDT_CUSTMOBILE_CONTACTS
            WHERE     N_CUST_REF_NO = C.N_CUST_REF_NO--               AND V_STATUS = 'A'
                  AND V_Contact_Number LIKE '%@%'
                  AND ROWNUM = 1)
             EMAIL,
                (SELECT V_CONTACT_NUMBER
             FROM GNDT_CUSTMOBILE_CONTACTS
            WHERE     N_CUST_REF_NO = C.N_CUST_REF_NO --               AND V_STATUS = 'A'
                  AND V_Contact_Number NOT LIKE '%@%'
                  AND ROWNUM = 1)
             PHONE,   TO_DATE (C.D_BIRTH_DATE, 'DD/MM/RRRR') D_BIRTH_DATE,N_CUST_REF_NO
FROM GNMT_CUSTOMER_MASTER  C
WHERE C.N_CUST_REF_NO  in (
                    SELECT POL.N_PAYER_REF_NO 
                    FROM GNMT_POLICY POL
                    )
and N_CUST_REF_NO not in (select N_CUST_REF_NO from JHL_LIFE_CUSTOMERS);
commit;
  end;


PROCEDURE CSV_UPDATE_2 IS
    
    V_TEMP VARCHAR2 (200);  
    N_VALUE_CSV NUMBER;

    
    CURSOR C_POLICIES IS
    SELECT V_POLICY_NO, V_PLAN_CODE, TO_CHAR(D_NEXT_OUT_DATE, 'DD-MON-YYYY') D_NEXT_OUT_DATE, 
    TO_CHAR(D_POLICY_END_DATE, 'DD-MON-YYYY') D_POLICY_END_DATE 
    FROM GNMT_POLICY
    WHERE V_POLICY_NO NOT LIKE 'GL%'
--    AND V_CNTR_STAT_CODE  IN ( 'NB010','NB022')
    AND V_POLICY_NO  NOT IN ( SELECT V_POLICY_NO FROM  Jhl_Amounts_V3)
    AND V_POLICY_NO  NOT IN ( SELECT V_POLICY_NO FROM  Jhl_Amounts_V5)
    and V_PYMT_FREQ <> '00';
    
    v_frm_date DATE;
    
    v_count number :=0;

    BEGIN
    
--    DELETE FROM JHL_AMOUNTS_V5;

        FOR C1_REC IN C_POLICIES
        LOOP

        BEGIN
          v_count :=v_count +1;
          v_frm_date :=SYSDATE;
        --BPG_CSV.BPC_CSV_REQUEST_REFUND(C1_REC.V_POLICY_NO,1,'B', C1_REC.V_PLAN_CODE, C1_REC.V_PLAN_CODE,'P',SYSDATE,'A','P',N_VALUE_CSV);
            BPG_CSV.BPC_CALC_PAIDUPRT_CSV(C1_REC.V_POLICY_NO,1,NULL,NULL,SYSDATE,N_VALUE_CSV);
                
--                IF N_VALUE_CSV != 0 THEN
                    INSERT INTO JHL_AMOUNTS_V5 (JAV3_NO,V_POLICY_NO, AMOUNT, AMT_TYPE, IN_OUT,NARRATION,AS_AT,DT_FROM) 
                    VALUES (JHL_JAV3_NO_SEQ.NEXTVAL,C1_REC.V_POLICY_NO, N_VALUE_CSV, 'VALUE_CSV', 'OUT','CSV',SYSDATE,v_frm_date);
--                END IF;   
                
                IF MOD(v_count,500)   = 0 THEN   
                COMMIT;
                END IF;
            
          
        EXCEPTION
            WHEN ZERO_DIVIDE THEN
                NULL;
        END;


        END LOOP;
        
          COMMIT;
            
    END;    
   

FUNCTION is_voucher_clean  (V_Voucher_No VARCHAR2)
      RETURN VARCHAR2
   IS
v_post_count NUMBER :=0;
v_st_error_count NUMBER :=0;
   BEGIN
   
   v_post_count :=0;
   BEGIN
   
SELECT COUNT(*)
INTO v_post_count
--INTO v_pol_type, v_pol_no
FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
WHERE M.N_REF_NO = D.N_REF_NO
AND M.V_JOURNAL_STATUS = 'C'
--AND NVL(M.V_REMARKS,'N')!='X'
AND V_DOCU_TYPE='VOUCHER'
--AND V_DOCU_REF_NO = '2016084503'
--2017005999
 AND V_DOCU_REF_NO = v_voucher_no;
 EXCEPTION
 WHEN OTHERS THEN
 v_post_count :=0;
 END;
 
 v_st_error_count:=0;
  
 BEGIN
  SELECT COUNT(*)
INTO v_st_error_count
--INTO v_pol_type, v_pol_no
FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
WHERE M.N_REF_NO = D.N_REF_NO
AND M.V_JOURNAL_STATUS <> 'C'
--AND NVL(M.V_REMARKS,'N')!='X'
AND V_DOCU_TYPE='VOUCHER'
--AND V_DOCU_REF_NO = '2016084503'
--2017005999
 AND V_DOCU_REF_NO = v_voucher_no;
 
  EXCEPTION
 WHEN OTHERS THEN
 v_st_error_count :=0;
 END;
 
 
 IF  ( v_post_count <> 0 and v_st_error_count = 0)  THEN
 return 'Y';
 ELSE
 RETURN 'N';
 END IF;
 
 end;
 
 FUNCTION get_loan_amount  (v_pol_no VARCHAR2, v_type VARCHAR2 DEFAULT 'DRAWN' ) RETURN NUMBER  IS

v_amt number :=0;
BEGIN

IF v_type = 'DRAWN' THEN

BEGIN

    SELECT SUM(NVL(N_LOAN_DRAWN,0))
    INTO v_amt
    From Psmt_Loan_Master A, Psdt_Loan_Transaction B
    Where     A.N_Loan_Ref_No = B.N_Loan_Ref_No
    And A.V_Status = 'A'
     and B.V_Status = 'A'
    AND V_POLICY_NO = v_pol_no;
    
 EXCEPTION
 WHEN OTHERS THEN
 v_amt :=0;
END;

END IF;

RETURN v_amt;

END;

Function Get_Loan_Repaid  (V_Pol_No Varchar2, V_Type Varchar2 Default 'REPAID' ) Return Number  Is

V_Amt_2 Number :=0;

Begin

If V_Type = 'REPAID' Then

Begin

    Select Sum(Nvl(N_Loan_Trans_Repaid,0))
    Into V_Amt_2
    From Psmt_Loan_Master A, Psdt_Loan_Transaction B
    Where     A.N_Loan_Ref_No = B.N_Loan_Ref_No
    And A.V_Status = 'A'
     And B.V_Status = 'A'
    And V_Policy_No = V_Pol_No;
    
 Exception
 When Others Then
 V_Amt_2 :=0;
End;

End If;

Return V_Amt_2;

END;

Function get_intr_Repaid  (V_Pol_No Varchar2, V_Type Varchar2 Default 'INTEREST' ) Return Number  Is

V_Amt_3 Number :=0;

Begin

If V_Type = 'INTEREST' Then

Begin

    Select Sum(Nvl(N_Int_Paid,0))
    Into V_Amt_3
    From Psmt_Loan_Master A, Psdt_Loan_Transaction B
    Where     A.N_Loan_Ref_No = B.N_Loan_Ref_No
    And A.V_Status = 'A'
     And B.V_Status = 'A'
    And V_Policy_No = V_Pol_No;
    
 Exception
 When Others Then
 V_Amt_3 :=0;
End;

End If;

Return V_Amt_3;

END;



 FUNCTION IS_VOUCHER_AUTHORIZED_EFT (V_VOUCHER_NO VARCHAR2)
      RETURN VARCHAR2
   IS
      V_DESC    VARCHAR2 (500);
      V_COUNT   NUMBER;
   BEGIN
      BEGIN
         SELECT UPPER (V_VOU_DESC)
           INTO V_DESC
           FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
          WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND PV.V_VOU_NO = V_VOUCHER_NO;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_DESC := NULL;
      END;

      IF V_DESC LIKE '%COMMISSION%'
      THEN
         RETURN 'Y';
      ELSE
         BEGIN
            SELECT COUNT (*)
              INTO V_COUNT
              FROM PY_VOUCHER_STATUS_LOG
             WHERE V_CURRENT_STATUS IN ( 'PY004') AND V_VOU_NO = V_VOUCHER_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_COUNT := 0;
         END;

         IF V_COUNT = 0
         THEN
            RETURN 'N';
         ELSE
            RETURN 'Y';
         END IF;
      END IF;
   END;
   
   FUNCTION get_policy_agent_name( v_pol_no VARCHAR)
      RETURN varchar
   IS
      v_agn_name   VARCHAR2(300);
   BEGIN
   
   
    SELECT AGN.V_AGENT_CODE || ' : '||  NVL (CAGN.V_NAME, CO.V_COMPANY_NAME)
           INTO v_agn_name 
        FROM AMMT_POL_AG_COMM COM, AMMM_AGENT_MASTER AGN,
        GNMT_CUSTOMER_MASTER CAGN, GNMM_COMPANY_MASTER CO
        WHERE COM.N_AGENT_NO = AGN.N_AGENT_NO
        AND COM.V_ROLE_CODE = 'SELLING'
        AND COM.V_STATUS = 'A'
        AND AGN.N_CUST_REF_NO = CAGN.N_CUST_REF_NO(+)
        AND AGN.V_COMPANY_CODE = CO.V_COMPANY_CODE(+)
        AND AGN.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH(+)
        AND COM.V_POLICY_NO = v_pol_no;
   

      

      

      RETURN v_agn_name;
      
     EXCEPTION
     WHEN OTHERS THEN
     RETURN NULL;
   END;
   
   
      FUNCTION get_discount_premium( v_pol_no VARCHAR)
      RETURN NUMBER
   IS

CURSOR POL IS 

select  A.N_Contribution,  E.V_PYMT_FREQ, E.V_PYMT_DESC,V_PLAN_NAME
from Gnmt_Policy A,Gnlu_Frequency_Master E,Gnmm_Plan_Master H
where  A.V_Pymt_Freq = E.V_Pymt_Freq
  And A.V_Plan_Code = H.V_Plan_Code
  and A.V_POLICY_NO =v_pol_no;


v_premium number;
   BEGIN
   
         FOR I IN POL LOOP
         
           IF  UPPER(I.V_PLAN_NAME) NOT LIKE '%FANAKA%' THEN
           
           RETURN  I.N_Contribution;
           
           ELSE
           

                
                IF I.N_Contribution >=20000 THEN
                
                        IF I.V_PYMT_FREQ = '01' THEN
                        
                                 IF  I.N_Contribution >= 50000 THEN
                                   v_premium :=  I.N_Contribution * (100-5)/100;
                                 ELSE
                                  v_premium :=  I.N_Contribution * (100-2.5)/100;
                                 END IF;
                        
                        ELSIF I.V_PYMT_FREQ = '03'  THEN
                        
                              IF I.N_Contribution >= 143695 THEN
                              v_premium :=  I.N_Contribution * (100-5)/100;
                              ELSIF (I.N_Contribution >=57578 AND I.N_Contribution < 143695 )  THEN
                               v_premium :=  I.N_Contribution * (100-2.5)/100;
                              END IF;
                        
                        
                        ELSIF I.V_PYMT_FREQ = '06'  THEN
                        
                              IF I.N_Contribution >= 283204 THEN
                              v_premium :=  I.N_Contribution * (100-5)/100;
                              ELSIF (I.N_Contribution >=113282 AND I.N_Contribution < 283204 )  THEN
                               v_premium :=  I.N_Contribution * (100-2.5)/100;
                              END IF;
                        
                        
                        
                        ELSIF I.V_PYMT_FREQ = '12'  THEN
                        
                              IF I.N_Contribution >= 558036 THEN
                              v_premium :=  I.N_Contribution * (100-5)/100;
                              ELSIF (I.N_Contribution >=223215 AND I.N_Contribution < 558036 )  THEN
                               v_premium :=  I.N_Contribution * (100-2.5)/100;
                              END IF;
                        
                        
                        ELSE
                        RETURN  I.N_Contribution;
                        END IF;
                        
                ELSE 
                        RETURN  I.N_Contribution; 
               END IF;   

           
           
           END IF;

      RETURN NVL(v_premium,I.N_Contribution);
         END LOOP;
      


      
     EXCEPTION
     WHEN OTHERS THEN
     RETURN NULL;
   END;


   PROCEDURE Mpesa_Alloc_Processing_Prc
   IS
      CURSOR Mps_Rct
      IS
         SELECT *
           FROM Inmt_Jic_Mpesa_Receipts
          WHERE V_Status = 'N'
          and trunc(D_RECEIVED_DATE) >= '25-MAY-18'
          AND V_POLICY_NO NOT LIKE 'GL%'
          and  V_JHL_RECEIPT_NO  not IN (    SELECT V_OTHER_REF_NO
                                                  FROM REMT_RECEIPT
                                                  WHERE V_RECEIPT_TABLE = 'DETAIL'
                                                  and V_OTHER_REF_NO =V_JHL_RECEIPT_NO );

      --    AND V_JHL_RECEIPT_NO = 'LI644KUL0O';
      --   AND V_POLICY_NO = '182447';

      CURSOR Pol_Alloc (
         V_Pol_No VARCHAR)
      IS
      
               SELECT V_Policy_No,
                DECODE ( NVL(JHL_GEN_PKG.policy_was_inforce(V_Policy_No),'XX') , 'NB010', NULL, N_Contribution)
                   Prop_Dep_Amt,
                DECODE (NVL(JHL_GEN_PKG.policy_was_inforce(V_Policy_No),'XX'), 'NB010', N_Contribution, NULL)
                   Prem_Due_Amt,
                TO_NUMBER (
                   REPLACE (
                      SUBSTR (Jhl_Utils.Has_Loan (V_Policy_No), 7, 100),
                      ')'))
                   Loan_Amt
           FROM Gnmt_Policy
          WHERE V_Policy_No = V_Pol_No;
      
--         SELECT V_Policy_No,
--                DECODE (V_Cntr_Prem_Stat_Code, 'NB058', N_Contribution, NULL)
--                   Prop_Dep_Amt,
--                DECODE (V_Cntr_Prem_Stat_Code, 'NB058', NULL, N_Contribution)
--                   Prem_Due_Amt,
--                TO_NUMBER (
--                   REPLACE (
--                      SUBSTR (Jhl_Utils.Has_Loan (V_Policy_No), 7, 100),
--                      ')'))
--                   Loan_Amt,JHL_GEN_PKG.policy_was_inforce(V_Policy_No)
--           FROM Gnmt_Policy
--          WHERE V_Policy_No = V_Pol_No;


      CURSOR Alloc
      IS
         SELECT *
           FROM Inmt_Jic_Mpesa_Rct_Alloc
          WHERE Mpal_Posted = 'N';


      CURSOR Allocated
      IS
         SELECT *
           FROM Inmt_Jic_Mpesa_Receipts
          WHERE Mps_Allocated = 'Y';

      CURSOR Receipts (V_Other_Ref VARCHAR)
      IS
         SELECT DISTINCT V_Receipt_No
           FROM Remt_Receipt
          WHERE V_Other_Ref_No = V_Other_Ref 
          AND V_Receipt_Table = 'DETAIL'
          and trunc(D_RECEIPT_DATE) >= trunc(sysdate);



      V_Pol_Count        NUMBER;
      V_Prop_Alloc_Amt   NUMBER;
      V_Prem_Alloc_Amt   NUMBER;
      V_Loan_Alloc_Amt   NUMBER;
      V_Bal_Amt          NUMBER;

      V_Seq_No           NUMBER;
      V_Error_Msg        VARCHAR2 (2000);
      V_Allocate         VARCHAR2 (1) := 'Y';

      V_Rct_No           VARCHAR2 (100);
      
      v_alloc_count  NUMBER;
   BEGIN
   
   
         
           update  Inmt_Jic_Mpesa_Receipts
           set V_POLICY_NO = UPPER( TRIM(V_POLICY_NO))
          WHERE V_Status = 'N'
          and trunc(D_RECEIVED_DATE) >= '25-MAY-18';
     
      FOR I IN Mps_Rct
      LOOP
         V_Error_Msg := NULL;
         V_Pol_Count := 0;
         V_Allocate := 'Y';


         BEGIN
            SELECT COUNT (*)
              INTO V_Pol_Count
              FROM Gnmt_Policy
             WHERE V_Policy_No = I.V_Policy_No;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_Pol_Count := 0;
         END;

         IF V_Pol_Count = 0
         THEN
            V_Error_Msg := 'UNKOWN POLICY :: ' || I.V_Policy_No;
            V_Allocate := 'N';
         END IF;

         IF V_Pol_Count > 0
         THEN
            FOR J IN Pol_Alloc (I.V_Policy_No)
            LOOP
               IF ( (I.N_Amount
                     - (NVL (J.Prop_Dep_Amt, 0) + NVL (J.Prem_Due_Amt, 0))) >
                      50)
               THEN
                  V_Error_Msg :=
                     'AMOUNT PAID IS MORE THAN PREMIUM EXPECTED :: AMOUNT =='
                     || I.N_Amount
                     || ' PREMIUM =='
                     || (NVL (J.Prop_Dep_Amt, 0) + NVL (J.Prem_Due_Amt, 0));
                  V_Allocate := 'N';
               END IF;
            END LOOP;
         END IF;



         IF V_Allocate <> 'N'
         THEN
            FOR J IN Pol_Alloc (I.V_Policy_No)
            LOOP
               V_Prop_Alloc_Amt := NULL;
               V_Prem_Alloc_Amt := NULL;
               V_Loan_Alloc_Amt := NULL;
               V_Bal_Amt := I.N_Amount;

               /*prem deposit alloc*/

               IF NVL (J.Prop_Dep_Amt, 0) > 0
               THEN
                  V_Prop_Alloc_Amt := J.Prop_Dep_Amt;
--                  V_Prop_Alloc_Amt := I.N_AMOUNT;
               END IF;



               /*premium alloc*/

               IF NVL (J.Prem_Due_Amt, 0) > 0
               THEN
                  V_Prem_Alloc_Amt := J.Prem_Due_Amt;
--                  V_Prem_Alloc_Amt :=  I.N_AMOUNT;
               END IF;



               INSERT INTO Inmt_Jic_Mpesa_Rct_Alloc (Mpal_No,
                                                     V_Policy_No,
                                                     V_Jhl_Receipt_No,
                                                     V_Business_Code,
                                                     Mpal_Amount,
                                                     Mpal_Prop_Dep_Amt,
                                                     Mpal_Prem_Due_Amt,
                                                     Mpal_Loan_Amt,
                                                     Mpal_Prop_Alloc_Amt,
                                                     Mpal_Prem_Alloc_Amt,
                                                     Mpal_Loan_Alloc_Amt,
                                                     Mpal_Date,
                                                     MPAL_RECEIVED_DATE)
                    VALUES (Jhl_Mpal_No_Seq.NEXTVAL,
                            I.V_Policy_No,
                            I.V_Jhl_Receipt_No,
                            I.V_Business_Code,
                            I.N_Amount,
                            J.Prop_Dep_Amt,
                            J.Prem_Due_Amt,
                            J.Loan_Amt,
                            V_Prop_Alloc_Amt,
                            V_Prem_Alloc_Amt,
                            V_Loan_Alloc_Amt,
                            SYSDATE,
                            I.D_RECEIVED_DATE);
            END LOOP;


            UPDATE Inmt_Jic_Mpesa_Receipts
               SET Mps_Allocated = 'Y'
             WHERE V_Jhl_Receipt_No = I.V_Jhl_Receipt_No;
         ELSE
            UPDATE Inmt_Jic_Mpesa_Receipts
               SET Mps_Alloc_Error = V_Error_Msg, Mps_Allocated = 'N'
             WHERE V_Jhl_Receipt_No = I.V_Jhl_Receipt_No;
         END IF;

         UPDATE Inmt_Jic_Mpesa_Receipts
            SET V_Status = 'Y'
          WHERE V_Jhl_Receipt_No = I.V_Jhl_Receipt_No;
      END LOOP;


      FOR L IN Alloc
      LOOP
         V_Seq_No := 1;

         IF NVL (L.Mpal_Prem_Alloc_Amt, 0) > 0
         THEN
            INSERT INTO Inmt_Jic_Receipts (V_Business_Code,
                                           V_Policy_No,
                                           N_Seq_No,
                                           V_Jhl_Receipt_No,
                                           N_Amount,
                                           D_Received_Date,
                                           V_Currency_Code,
                                           V_Collection_Type,
                                           V_Branch_Code,
                                           V_User_Id,
                                           V_Receipt_Type,
                                           V_Status,
                                           V_Ref_Type,
                                           Entry_Date,
                                           V_Inst_No,
                                           V_Inst_Bank,
                                           V_Inst_Branch)
                 VALUES (L.V_Business_Code,
                         L.V_Policy_No,
                         V_Seq_No,
                         L.V_Jhl_Receipt_No,
                       L.MPAL_AMOUNT,   --L.Mpal_Prem_Alloc_Amt,
                         TO_DATE ( NVL(L.MPAL_RECEIVED_DATE,SYSDATE), 'DD/MM/RRRR'),
                         'KES',
                         'MPESA_1',
                         'HQS',
                         'JHLISFADMIN',
                         'RCT002',
                         'N',
                         'POLICY',
                         SYSDATE,
                         L.V_Jhl_Receipt_No,
                         '303008',
                         'HO');

            V_Seq_No := V_Seq_No + 1;
         END IF;


         IF NVL (L.Mpal_Prop_Alloc_Amt, 0) > 0
         THEN
            INSERT INTO Inmt_Jic_Receipts (V_Business_Code,
                                           V_Policy_No,
                                           N_Seq_No,
                                           V_Jhl_Receipt_No,
                                           N_Amount,
                                           D_Received_Date,
                                           V_Currency_Code,
                                           V_Collection_Type,
                                           V_Branch_Code,
                                           V_User_Id,
                                           V_Receipt_Type,
                                           V_Status,
                                           V_Ref_Type,
                                           Entry_Date,
                                           V_Inst_No,
                                           V_Inst_Bank,
                                           V_Inst_Branch)
                 VALUES (L.V_Business_Code,
                         L.V_Policy_No,
                         V_Seq_No,
                         L.V_Jhl_Receipt_No,
                         L.MPAL_AMOUNT,  --L.Mpal_Prop_Alloc_Amt,
                         TO_DATE ( NVL(L.MPAL_RECEIVED_DATE,SYSDATE), 'DD/MM/RRRR'),
                         'KES',
                         'MPESA_1',
                         'HQS',
                         'JHLISFADMIN',
                         'RCT003',
                         'N',
                         'POLICY',
                         SYSDATE,
                         L.V_Jhl_Receipt_No,
                         '303008',
                         'HO');

            V_Seq_No := V_Seq_No + 1;
         END IF;



         UPDATE Inmt_Jic_Mpesa_Rct_Alloc
            SET Mpal_Posted = 'Y', Mpal_Posted_Dt = SYSDATE
          WHERE Mpal_No = L.Mpal_No;

         UPDATE Inmt_Jic_Mpesa_Receipts
            SET Mps_Posted = 'Y', Mps_Posted_Date = SYSDATE
          WHERE V_Jhl_Receipt_No = L.V_Jhl_Receipt_No;
      END LOOP;

               

      /*post to ISF*/
      Bpg_Finance_Batches.Bpc_Generate_Receipt_By_Client (USER, USER, SYSDATE);


      FOR Rec IN Allocated
      LOOP
         V_Rct_No := NULL;
         v_alloc_count :=0;
         FOR Rct IN Receipts (Rec.V_Jhl_Receipt_No)
         LOOP
         
            V_Rct_No := Rct.V_Receipt_No;
            v_alloc_count :=  v_alloc_count +1;
            if v_alloc_count > 1 then
            rollback;
            raise_error('Multiple Allocation detected' || Rec.V_Jhl_Receipt_No );
            end if;
         END LOOP;

         UPDATE Inmt_Jic_Mpesa_Receipts
            SET Mps_Isf_Receipt_No = V_Rct_No
          WHERE V_Jhl_Receipt_No = Rec.V_Jhl_Receipt_No;
      END LOOP;

      COMMIT;
   END;



   PROCEDURE Mpesa_Alloc_Processing_Prc_Bk
   IS
      CURSOR Mps_Rct
      IS
         SELECT *
           FROM Inmt_Jic_Mpesa_Receipts
          WHERE V_Status = 'N' AND V_Jhl_Receipt_No = 'LI644KUL0O';

      --   AND V_POLICY_NO = '182447';

      CURSOR Pol_Alloc (
         V_Pol_No VARCHAR)
      IS
         SELECT V_Policy_No,
                DECODE (V_Cntr_Prem_Stat_Code, 'NB058', N_Contribution, NULL)
                   Prop_Dep_Amt,
                DECODE (V_Cntr_Prem_Stat_Code, 'NB058', NULL, N_Contribution)
                   Prem_Due_Amt,
                TO_NUMBER (
                   REPLACE (
                      SUBSTR (Jhl_Utils.Has_Loan (V_Policy_No), 7, 100),
                      ')'))
                   Loan_Amt
           FROM Gnmt_Policy
          WHERE V_Policy_No = V_Pol_No;


      CURSOR Alloc
      IS
         SELECT *
           FROM Inmt_Jic_Mpesa_Rct_Alloc
          WHERE Mpal_Posted = 'N';



      V_Pol_Count        NUMBER;
      V_Prop_Alloc_Amt   NUMBER;
      V_Prem_Alloc_Amt   NUMBER;
      V_Loan_Alloc_Amt   NUMBER;
      V_Bal_Amt          NUMBER;

      V_Seq_No           NUMBER;
   BEGIN
      FOR I IN Mps_Rct
      LOOP
         V_Pol_Count := 0;

         BEGIN
            SELECT COUNT (*)
              INTO V_Pol_Count
              FROM Gnmt_Policy
             WHERE V_Policy_No = I.V_Policy_No;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_Pol_Count := 0;
         END;

         IF V_Pol_Count > 0
         THEN
            FOR J IN Pol_Alloc (I.V_Policy_No)
            LOOP
               V_Prop_Alloc_Amt := NULL;
               V_Prem_Alloc_Amt := NULL;
               V_Loan_Alloc_Amt := NULL;
               V_Bal_Amt := I.N_Amount;

               /*prem deposit alloc*/

               IF NVL (J.Prop_Dep_Amt, 0) > 0
               THEN
                  IF V_Bal_Amt > 0
                  THEN
                     IF V_Bal_Amt <= NVL (J.Prop_Dep_Amt, 0)
                     THEN
                        V_Prop_Alloc_Amt := V_Bal_Amt;
                     ELSE
                        V_Prop_Alloc_Amt := J.Prop_Dep_Amt;
                     END IF;


                     V_Bal_Amt := V_Bal_Amt - NVL (J.Prop_Dep_Amt, 0);
                  END IF;
               END IF;



               /*premium alloc*/

               IF NVL (J.Prem_Due_Amt, 0) > 0
               THEN
                  IF V_Bal_Amt > 0
                  THEN
                     IF V_Bal_Amt <= NVL (J.Prem_Due_Amt, 0)
                     THEN
                        V_Prem_Alloc_Amt := V_Bal_Amt;
                     ELSE
                        V_Prem_Alloc_Amt := J.Prem_Due_Amt;
                     END IF;


                     V_Bal_Amt := V_Bal_Amt - NVL (J.Prem_Due_Amt, 0);
                  END IF;
               END IF;



               /*loan alloc*/

               IF NVL (J.Loan_Amt, 0) > 0
               THEN
                  IF V_Bal_Amt > 0
                  THEN
                     IF V_Bal_Amt <= NVL (J.Loan_Amt, 0)
                     THEN
                        V_Loan_Alloc_Amt := V_Bal_Amt;
                     ELSE
                        V_Loan_Alloc_Amt := J.Loan_Amt;
                     END IF;


                     V_Bal_Amt := V_Bal_Amt - NVL (J.Loan_Amt, 0);
                  END IF;
               END IF;

               IF V_Bal_Amt > 0
               THEN
                  V_Prem_Alloc_Amt := NVL (V_Prem_Alloc_Amt, 0) + V_Bal_Amt;
               --                                       v_bal_amt:=0;
               END IF;

               --                                       raise_error('v_bal_amt=='||v_bal_amt);


               INSERT INTO Inmt_Jic_Mpesa_Rct_Alloc (Mpal_No,
                                                     V_Policy_No,
                                                     V_Jhl_Receipt_No,
                                                     V_Business_Code,
                                                     Mpal_Amount,
                                                     Mpal_Prop_Dep_Amt,
                                                     Mpal_Prem_Due_Amt,
                                                     Mpal_Loan_Amt,
                                                     Mpal_Prop_Alloc_Amt,
                                                     Mpal_Prem_Alloc_Amt,
                                                     Mpal_Loan_Alloc_Amt,
                                                     Mpal_Date)
                    VALUES (Jhl_Mpal_No_Seq.NEXTVAL,
                            I.V_Policy_No,
                            I.V_Jhl_Receipt_No,
                            I.V_Business_Code,
                            I.N_Amount,
                            J.Prop_Dep_Amt,
                            J.Prem_Due_Amt,
                            J.Loan_Amt,
                            V_Prop_Alloc_Amt,
                            V_Prem_Alloc_Amt,
                            V_Loan_Alloc_Amt,
                            SYSDATE);
            END LOOP;
         ELSE
            UPDATE Inmt_Jic_Mpesa_Receipts
               SET Mps_Alloc_Error = 'UNKOWN POLICY :: ' || I.V_Policy_No
             WHERE V_Jhl_Receipt_No = I.V_Jhl_Receipt_No;
         END IF;

         UPDATE Inmt_Jic_Mpesa_Receipts
            SET V_Status = 'Y'
          WHERE V_Jhl_Receipt_No = I.V_Jhl_Receipt_No;
      END LOOP;


      FOR L IN Alloc
      LOOP
         V_Seq_No := 1;

         IF NVL (L.Mpal_Prem_Alloc_Amt, 0) > 0
         THEN
            INSERT INTO Inmt_Jic_Receipts (V_Business_Code,
                                           V_Policy_No,
                                           N_Seq_No,
                                           V_Jhl_Receipt_No,
                                           N_Amount,
                                           D_Received_Date,
                                           V_Currency_Code,
                                           V_Collection_Type,
                                           V_Branch_Code,
                                           V_User_Id,
                                           V_Receipt_Type,
                                           V_Status,
                                           V_Ref_Type,
                                           Entry_Date)
                 VALUES (L.V_Business_Code,
                         L.V_Policy_No,
                         V_Seq_No,
                         L.V_Jhl_Receipt_No,
                         L.Mpal_Prem_Alloc_Amt,
                         TO_DATE (SYSDATE, 'DD/MM/RRRR'),
                         'KES',
                         'MPESA',
                         'HO',
                         'JHLISFADMIN',
                         'RCT002',
                         'N',
                         'POLICY',
                         SYSDATE);

            V_Seq_No := V_Seq_No + 1;
         END IF;


         IF NVL (L.Mpal_Prop_Alloc_Amt, 0) > 0
         THEN
            INSERT INTO Inmt_Jic_Receipts (V_Business_Code,
                                           V_Policy_No,
                                           N_Seq_No,
                                           V_Jhl_Receipt_No,
                                           N_Amount,
                                           D_Received_Date,
                                           V_Currency_Code,
                                           V_Collection_Type,
                                           V_Branch_Code,
                                           V_User_Id,
                                           V_Receipt_Type,
                                           V_Status,
                                           V_Ref_Type,
                                           Entry_Date)
                 VALUES (L.V_Business_Code,
                         L.V_Policy_No,
                         V_Seq_No,
                         L.V_Jhl_Receipt_No,
                         L.Mpal_Prop_Alloc_Amt,
                         TO_DATE (SYSDATE, 'DD/MM/RRRR'),
                         'KES',
                         'MPESA',
                         'HO',
                         'JHLISFADMIN',
                         'RCT003',
                         'N',
                         'POLICY',
                         SYSDATE);

            V_Seq_No := V_Seq_No + 1;
         END IF;


         IF NVL (L.Mpal_Loan_Alloc_Amt, 0) > 0
         THEN
            INSERT INTO Inmt_Jic_Receipts (V_Business_Code,
                                           V_Policy_No,
                                           N_Seq_No,
                                           V_Jhl_Receipt_No,
                                           N_Amount,
                                           D_Received_Date,
                                           V_Currency_Code,
                                           V_Collection_Type,
                                           V_Branch_Code,
                                           V_User_Id,
                                           V_Receipt_Type,
                                           V_Status,
                                           V_Ref_Type,
                                           Entry_Date)
                 VALUES (L.V_Business_Code,
                         L.V_Policy_No,
                         V_Seq_No,
                         L.V_Jhl_Receipt_No,
                         L.Mpal_Loan_Alloc_Amt,
                         TO_DATE (SYSDATE, 'DD/MM/RRRR'),
                         'KES',
                         'MPESA',
                         'HO',
                         'JHLISFADMIN',
                         'RCT004',
                         'N',
                         'POLICY',
                         SYSDATE);

            V_Seq_No := V_Seq_No + 1;
         END IF;

         UPDATE Inmt_Jic_Mpesa_Rct_Alloc
            SET Mpal_Posted = 'Y', Mpal_Posted_Dt = SYSDATE
          WHERE Mpal_No = L.Mpal_No;

         UPDATE Inmt_Jic_Mpesa_Receipts
            SET Mps_Posted = 'Y', Mps_Posted_Date = SYSDATE
          WHERE V_Jhl_Receipt_No = L.V_Jhl_Receipt_No;
      END LOOP;
   /*post to ISF*/
   --           BPG_FINANCE_BATCHES.Bpc_Generate_Receipt_by_client(user,USER,SYSdate);

   -- commit;
   END;



   FUNCTION CHECK_IDENTIFICATION_VALIDITY (v_ident_val VARCHAR, v_type VARCHAR)
      RETURN VARCHAR2
   IS
      V_RET_VALUE       VARCHAR2 (1);
  b_isvalid   BOOLEAN;

   BEGIN
   
   V_RET_VALUE :=NULL;
   
           IF v_type = 'ID' THEN
                   IF( (NVL (LENGTH (v_ident_val), 0) BETWEEN 6 AND 9)  )THEN
                   
                    if (nvl( LENGTH(TRIM(TRANSLATE(v_ident_val, ' +-.0123456789',' '))),0)  = 0 ) then
                   
                        V_RET_VALUE := 'Y';
                    end if;
                   
                   END IF;
           
           END IF;
           
             IF v_type = 'PP' THEN
                   IF (NVL (LENGTH (v_ident_val), 0) =  8) THEN
                   
                   if (nvl( LENGTH(TRIM(TRANSLATE(v_ident_val, ' +-.0123456789',' '))),0)  = 0 ) then
                       V_RET_VALUE := 'Y';
                   end if;
                   END IF;
           
           END IF;
           
           
           IF v_type = 'PHONE' THEN
                   IF (NVL (LENGTH (v_ident_val), 0)  BETWEEN 10 AND 13 ) THEN
                   
                    V_RET_VALUE := 'Y';
                    
                   END IF;
           
           END IF;
   
   
         IF v_type = 'EMAIL' THEN
         
         
                b_isvalid :=
      REGEXP_LIKE (v_ident_val,
                   '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$');
                   IF b_isvalid THEN
                   
                    V_RET_VALUE := 'Y';
                    
                   END IF;
           
           END IF;
     
      --RAISE_ERROR('v_payer_value=='||v_payer_value||'v_assured_value=='||v_assured_value||'v_ret_value=='||v_ret_value);

      RETURN V_RET_VALUE;
   END;

 

 FUNCTION get_claim_payment_date (v_claim_no VARCHAR,v_amt NUMBER,v_date date,v_date_type VARCHAR default 'PAID'  )
      RETURN date
   IS
      v_pymt_date  DATE;
      v_count number := 0;
   BEGIN
      BEGIN
             begin
                   Select  count(*)
                   into v_count
                    From Pymt_Voucher_Root A, Pymt_Vou_Master B,JHL_OFA_CHQ_DETAILS c
                   Where A.V_Main_Vou_No = B.V_Main_Vou_No 
                   and V_Vou_No = PAYMENT_VOUCHER
    --               and c.LOB_NAME = 'JHL_KE_LIF_OU'
        --           And V_Vou_Source = 'CLAIMS'
                   and V_Source_Ref_No = v_claim_no;
               exception
               when others then
               v_count := 0;
               
              end;
               
          
            if  (v_count > 1) then
            
                   Select  MAX(PAYMENT_DATE)
                   into v_pymt_date
                    From Pymt_Voucher_Root A, Pymt_Vou_Master B,JHL_OFA_CHQ_DETAILS c
                   Where A.V_Main_Vou_No = B.V_Main_Vou_No 
                   and V_Vou_No = PAYMENT_VOUCHER
    --               and c.LOB_NAME = 'JHL_KE_LIF_OU'
        --           And V_Vou_Source = 'CLAIMS'
                   and V_Source_Ref_No = v_claim_no
                   and trunc(A.D_VOU_DATE) = trunc(v_date);
--                   and N_VOU_AMOUNT =v_amt ;
               else
               
                    Select  PAYMENT_DATE
                   into v_pymt_date
                    From Pymt_Voucher_Root A, Pymt_Vou_Master B,JHL_OFA_CHQ_DETAILS c
                   Where A.V_Main_Vou_No = B.V_Main_Vou_No 
                   and V_Vou_No = PAYMENT_VOUCHER
    --               and c.LOB_NAME = 'JHL_KE_LIF_OU'
        --           And V_Vou_Source = 'CLAIMS'
                   and V_Source_Ref_No = v_claim_no;
               
               end if;
          

        
        
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN NULL;
      END;

      RETURN v_pymt_date;
   END;
   
   
   
   
 


FUNCTION get_mps_receipt_no (v_mps_code       VARCHAR)
      RETURN VARCHAR2
   IS
      V_Ret_Value   VARCHAR2 (500) ;

      CURSOR receipts
      IS
         SELECT  V_RECEIPT_NO                                        
        FROM REMT_RECEIPT
        WHERE V_RECEIPT_TABLE = 'DETAIL'
        and V_OTHER_REF_NO =v_mps_code;
        
        v_count number :=0;
   BEGIN

     
--        begin
--        SELECT  count(distinct V_RECEIPT_NO)    
--        into v_count                               
--        FROM REMT_RECEIPT
--        WHERE V_RECEIPT_TABLE = 'DETAIL'
--        and V_OTHER_REF_NO =v_mps_code;
--        end;
--  

     
--           if v_count > 1 then 
           
              v_count :=0;
              FOR I IN receipts
              LOOP
               v_count := v_count+1;
               
                if v_count = 1 then
               
              V_Ret_Value := I.V_RECEIPT_NO;
                end if;
                
                 if v_count >1 then
                  V_Ret_Value := V_Ret_Value || ' '||I.V_RECEIPT_NO;
                 end if;
                
                

              END LOOP;
              
--           end if;


      RETURN V_Ret_Value;
   END;
   
   FUNCTION GET_AGENCY_HIERARCHY (V_AGENT_NO  number, v_level VARCHAR,d_type  VARCHAR  DEFAULT 'C')
      RETURN VARCHAR2 IS
      v_manager VARCHAR2(200);
      BEGIN
                SELECT  DECODE(d_type, 'C',J.V_AGENT_CODE ,V_NAME)
               INTO v_manager
                FROM AMMT_AGENT_HIERARCHY H,AMMM_AGENT_MASTER J, GNMT_CUSTOMER_MASTER K
                WHERE   H.N_MANAGER_NO =J.N_AGENT_NO
                AND J.N_CUST_REF_NO = K.N_CUST_REF_NO
                AND N_MANAGER_LEVEL = v_level
                AND  H.N_AGENT_NO = V_AGENT_NO
                 AND H.V_STATUS = 'A'
                  AND J.V_STATUS = 'A';
          
          RETURN v_manager;
          
       EXCEPTION
       WHEN OTHERS  THEN
       RETURN NULL;
      END;
      
      
   FUNCTION policy_was_inforce
    (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE)
  RETURN VARCHAR2 IS

    CURSOR C1 IS
    select V_CURR_STAT_CODE from GN_CONTRACT_STATUS_LOG
    WHERE V_POLICY_NO = P_POLICY_NO
    AND V_CURR_STAT_CODE = 'NB010'
    AND ROWNUM=1;  
  
    V_TEMP VARCHAR2 (200);

    BEGIN


        IF C1%ISOPEN THEN CLOSE C1; END IF;
        OPEN C1;
        FETCH C1 INTO V_TEMP;
           
        RETURN V_TEMP;

    END;    
    
    
FUNCTION get_agn_persistancy(v_date date, v_m_start number, v_m_end number, v_agn_no number) RETURN number IS

    v_per number;

    BEGIN

SELECT
        ROUND(SUM(PERS_STATUS_6M)/COUNT(PERS_STATUS_6M)*100,0) PERS
        into v_per
        FROM
        (
        SELECT N_AGENT_NO, V_POLICY_NO, 
        DECODE(JHL_SALESFORCE_UTILS.WOP_STATUS(V_POLICY_NO), 'YES', 1, DECODE(V_CNTR_STAT_DESC, 'IN-FORCE',1,0)) PERS_STATUS_6M
        FROM JHL_SALESFORCE_DIGITAL_DATA
        WHERE V_CNTR_STAT_DESC IN ('IN-FORCE','LAPSE','APL LAPSE','SURRENDERED')
        AND N_AGENT_LEVEL=40
        AND MONTHS_BETWEEN(TO_DATE(v_date, 'dd-MM-RRRR'), D_COMMENCEMENT) >= v_m_start --6 OR 12
        AND MONTHS_BETWEEN(TO_DATE(v_date, 'dd-MM-RRRR'), D_COMMENCEMENT) < v_m_end     --12 OR 24
        ) Z
       -- WHERE N_AGENT_NO IN ($agent->n_agent_no)
       WHERE N_AGENT_NO = v_agn_no
        GROUP BY N_AGENT_NO;
        
        return v_per  ;
        
--        exception
--        when others then
--        return 0;

    END;   


FUNCTION get_pol_stamp_duty(v_pol_no VARCHAR ) RETURN number IS

    v_duty number;

    BEGIN


           Select SUM(AMOUNT) AMOUNT
           into v_duty
                       FROM (
                           select  ( sum(N_SUM_COVERED/10000)*7.5)AMOUNT
                           from gnmt_policy a
                           where a.v_policy_no = v_pol_no
                        Union
                           select  NVL(COUNT(b.V_PLAN_CODE)*40, 0)AMOUNT
                           from gnmt_policy_riders b 
                           where b.v_policy_no = v_pol_no
                           and b.N_RIDER_PREMIUM <>0
                           group by  b.V_POLICY_NO
                           );
        
        return v_duty  ;
        
        exception
        when others then
        return 0;

    END;   
     FUNCTION AGENT_NAME8
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2 IS

    CURSOR C1 IS
    SELECT V_AGENT_CODE||'-'||TRIM(V_COMPANY_NAME)||' ('||TRIM(V_ADD_THREE)||')'
    FROM AMMM_AGENT_MASTER a, GNMM_COMPANY_MASTER b, GNDT_COMPANY_ADDRESS c
    WHERE A.V_COMPANY_CODE = b.V_COMPANY_CODE
    AND A.V_COMPANY_BRANCH = B.V_COMPANY_BRANCH
    AND b.V_COMPANY_CODE = c.V_COMPANY_CODE
    AND B.V_COMPANY_BRANCH =C.V_COMPANY_BRANCH
    AND a.N_AGENT_NO = P_AGENT_NO
  AND ROWNUM =1      
    UNION
    SELECT V_AGENT_CODE||'-'||TRIM(V_NAME)||' ('||TRIM(c.V_ADD_THREE)||')' AGENCY 
    FROM AMMM_AGENT_MASTER a, GNMT_CUSTOMER_MASTER b, GNDT_CUSTOMER_ADDRESS c
    WHERE a.N_CUST_REF_NO = b.N_CUST_REF_NO
    AND b.N_CUST_REF_NO = c.N_CUST_REF_NO
    AND N_AGENT_NO=P_AGENT_NO
 AND ROWNUM =1;

    V_TEMP VARCHAR2 (200);

    BEGIN


        IF C1%ISOPEN THEN CLOSE C1; END IF;
        OPEN C1;
        FETCH C1 INTO V_TEMP;
           
        RETURN V_TEMP;

    END;
    
      FUNCTION AGENT_NAME
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2 IS
    V_TEMP VARCHAR2 (200);

    BEGIN
            
--            SELECT V_AGENT_CODE||'-'||TRIM(V_NAME)||' ('||TRIM(V_ADD_THREE)||')' INTO V_TEMP
--            FROM AMMM_AGENT_MASTER a, GNMT_CUSTOMER_MASTER b, GNDT_CUSTOMER_ADDRESS c
--            WHERE a.N_CUST_REF_NO = b.N_CUST_REF_NO
--            AND b.N_CUST_REF_NO = c.N_CUST_REF_NO
--            AND a.N_AGENT_NO = P_AGENT_NO
--            AND ROWNUM =1;
--    EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--            V_TEMP := 'X';

            SELECT AGENCY INTO V_TEMP
            FROM
            (
            SELECT V_AGENT_CODE||'-'||TRIM(V_NAME)||' ('||TRIM(c.V_ADD_THREE)||')' AGENCY, c.N_ADD_SEQ_NO--INTO V_TEMP
            FROM AMMM_AGENT_MASTER a, GNMT_CUSTOMER_MASTER b, GNDT_CUSTOMER_ADDRESS c
            WHERE a.N_CUST_REF_NO = b.N_CUST_REF_NO
            AND b.N_CUST_REF_NO = c.N_CUST_REF_NO
            AND N_AGENT_NO=P_AGENT_NO
            ORDER BY N_ADD_SEQ_NO DESC
            )
            WHERE ROWNUM=1;
           
            RETURN V_TEMP;

    END;
    
    
  FUNCTION get_contributions (v_pol_no varchar, v_date date)  RETURN number IS
--    V_TEMP VARCHAR2 (200);
v_contrib_count number;

    BEGIN
            
               /* select  COUNT(  sum(BIL.N_TRN_AMT) )
                into v_contrib_count
                from GNDT_BILL_TRANS BIL
                where v_policy_no = v_pol_no
                AND NVL (BIL.V_Cancel_Status, 'N') = 'N'
                AND BIL.N_Trn_Amt != 0
                AND BIL.N_Bill_Trn_No > 1
                and trunc(d_ref_date) <= trunc(v_date)
                group by d_ref_date;*/
                
                
                select   COUNT(  sum(PREM.N_PREM_AMOUNT) )  
                into v_contrib_count
                from PPMT_PREMIUM_REGISTER PREM
                WHERE PREM.V_POLICY_NO NOT LIKE 'GL%'
                AND V_RECEIPT_NO IS NOT NULL 
                and V_POLICY_NO = v_pol_no
                And TRUNC (PREM.D_RECEIPT_DATE)  <= trunc(v_date)
                  group by D_RECEIPT_DATE;
                
                return v_contrib_count;

    END;
    
    
      FUNCTION get_contributions_bk (v_pol_no varchar, v_date date)  RETURN number IS
--    V_TEMP VARCHAR2 (200);
v_contrib_count number;

    BEGIN
            
                select  COUNT(  sum(BIL.N_TRN_AMT) )
                into v_contrib_count
                from GNDT_BILL_TRANS BIL
                where v_policy_no = v_pol_no
                AND NVL (BIL.V_Cancel_Status, 'N') = 'N'
                AND BIL.N_Trn_Amt != 0
                AND BIL.N_Bill_Trn_No > 1
                and trunc(d_ref_date) <= trunc(v_date)
                group by d_ref_date;
                
                return v_contrib_count;

    END;
    
    
 FUNCTION is_new_prem (v_pol_no varchar, v_date date)  RETURN varchar IS
--    V_TEMP VARCHAR2 (200);
v_contrib_count number;
v_return varchar2(1) := 'Y';

    BEGIN
            
--                select  COUNT(  sum(BIL.N_TRN_AMT) )
--                into v_contrib_count
--                from GNDT_BILL_TRANS BIL
--                where v_policy_no = v_pol_no
--                AND NVL (BIL.V_Cancel_Status, 'N') = 'N'
--                AND BIL.N_Trn_Amt != 0
--                AND BIL.N_Bill_Trn_No > 1
--                and trunc(d_ref_date) <= trunc(v_date)
--                group by d_ref_date;
--                
                
                     select   COUNT(  sum(PREM.N_PREM_AMOUNT) )  
                into v_contrib_count
                from PPMT_PREMIUM_REGISTER PREM
                WHERE PREM.V_POLICY_NO NOT LIKE 'GL%'
                AND V_RECEIPT_NO IS NOT NULL 
                and V_POLICY_NO = v_pol_no
                And TRUNC (PREM.D_RECEIPT_DATE)  <= trunc(v_date)
                  group by D_RECEIPT_DATE;
                
               
                
                if v_contrib_count > 12 then
                v_return :='N';
                END IF;
                 return v_return;

    END;
    
    
     FUNCTION is_new_prem_bk (v_pol_no varchar, v_date date)  RETURN varchar IS
--    V_TEMP VARCHAR2 (200);
v_contrib_count number;
v_return varchar2(1) := 'Y';

    BEGIN
            
                select  COUNT(  sum(BIL.N_TRN_AMT) )
                into v_contrib_count
                from GNDT_BILL_TRANS BIL
                where v_policy_no = v_pol_no
                AND NVL (BIL.V_Cancel_Status, 'N') = 'N'
                AND BIL.N_Trn_Amt != 0
                AND BIL.N_Bill_Trn_No > 1
                and trunc(d_ref_date) <= trunc(v_date)
                group by d_ref_date;
                
               
                
                if v_contrib_count > 12 then
                v_return :='N';
                END IF;
                 return v_return;

    END;
    
    
    PROCEDURE bpc_commission_clawback(      p_policy_no VARCHAR2,
                                      p_comm_gen_from DATE,
                                      p_comm_gen_to DATE,
                                      p_plan_code VARCHAR2 DEFAULT NULL,
                                      p_user VARCHAR2,
                                      p_prog VARCHAR2,
                                      p_date DATE DEFAULT SYSDATE,
                                      p_intimation_seq NUMBER DEFAULT NULL,
                                      p_reason VARCHAR2 DEFAULT NULL)IS

CURSOR cr_policy IS
SELECT *FROM gnmt_policy WHERE v_policy_no = p_policy_no;

CURSOR cr_intimation IS
SELECT *FROM ammt_commission_intimation
WHERE n_comm_intimation_seq = p_intimation_seq
--WHERE v_policy_no = p_policy_no
--AND v_comm_process_code IN ('G','C')
--AND n_comm_intimation_seq = NVL(p_intimation_seq,n_comm_intimation_seq)
--AND trunc(d_comm_gen) BETWEEN trunc(p_comm_gen_from) AND trunc(p_comm_gen_to)
--AND v_plan_code = NVL(p_plan_code,v_plan_code)
--AND v_record_status = 'P'
ORDER BY 1;

CURSOR cr_comm_details(p_policy_no VARCHAR2,
                       p_due_date DATE,
                       p_inti_seq NUMBER,
                       p_plan_code VARCHAR2)IS
SELECT *FROM ammt_pol_comm_detail
--WHERE v_policy_no = p_policy_no
--AND trunc(d_premium_due) = trunc(p_due_date)
--AND v_plan_code =  p_plan_code
--AND n_comm_intimation_seq = p_inti_seq
WHERE n_comm_intimation_seq = p_inti_seq
AND v_policy_no = p_policy_no
ORDER BY n_level;

CURSOR cr_prod_details(p_policy_no VARCHAR2,
                       p_due_date DATE,
                       p_intimation_seq NUMBER,
                       p_plan_code VARCHAR2)IS
SELECT *FROM amdt_agent_production_history
--WHERE v_policy_no = p_policy_no
--AND trunc(d_due_date) = trunc(p_due_date)
--AND v_plan_code =  p_plan_code
--AND v_source_ref_no = TO_CHAR(p_intimation_seq)
WHERE v_source_ref_no = TO_CHAR(p_intimation_seq)
AND v_policy_no = p_policy_no
ORDER BY v_source_ref_no,v_prod_level;


CURSOR Cr_Comm_Seq IS SELECT seq_comm_prem_reg.NEXTVAL FROM Dual;

CURSOR Cr_fetch_lob(lv_plri_code VARCHAR2) IS SELECT v_prod_line
FROM gnmm_plan_master
WHERE v_plan_code = lv_plri_code;

CURSOR cr_sharing_percent(p_policy_no VARCHAR2)IS
SELECT n_percent FROM ammt_pol_ag_comm
WHERE v_policy_no = p_policy_no
AND v_status = 'A';

ln_comm_seq NUMBER;
lv_lob VARCHAR2(100);
lv_process_code VARCHAR2(10);
ln_prem_amt NUMBER;
ln_comm_amt NUMBER;
ln_percent NUMBER;
BEGIN
FOR i IN cr_policy LOOP
    FOR j IN cr_intimation LOOP
            OPEN  Cr_Comm_Seq;
            FETCH Cr_Comm_Seq INTO ln_comm_seq;
            CLOSE Cr_Comm_Seq;
        FOR k IN cr_comm_details(j.v_policy_no,j.d_due_date,j.n_comm_intimation_seq,j.v_plan_code) LOOP
            IF NVL(k.n_comm_amt,0) <> 0 AND NVL(k.n_prem_amt,0) <> 0 THEN

               lv_process_code := NULL;
               IF k.n_prem_amt < 0 THEN
                  lv_process_code := 'G';
                  ln_prem_amt := -k.n_prem_amt;
                  ln_comm_amt := -k.n_comm_amt;
               ELSIF k.n_prem_amt > 0 THEN
                  lv_process_code := 'C';
                  ln_prem_amt := k.n_prem_amt;
                  ln_comm_amt := k.n_comm_amt;
               END IF;

               bpg_agency.insert_comm_details(  p_policy_no             => k.v_policy_no,
                                                p_seq_no                 => k.n_seq_no,
                                                p_agent_code             => k.n_agent_no,
                                                p_due_date                 => k.d_premium_due,
                                                p_prem_amt                 => ln_prem_amt,--k.n_prem_amt,
                                                p_comm_paid_date        => NULL,
                                                p_receipt_date             => k.d_receipt,
                                                p_receipt_no             => NVL(k.v_receipt_no,j.v_posted_ref_no),
                                                p_adjusted_from         => k.v_adjusted_from,
                                                p_comm_amt                 => ln_comm_amt,--k.n_comm_amt,
                                                p_oc_flag                 => k.v_oc_flag,
                                                p_sub_agent             => k.n_sub_agent_no,
                                                p_comm_status             => 'UP',
                                                p_status                 => 'A',
                                                p_lastuser                 => p_user,
                                                p_lastprog                 => p_prog,
                                                p_date                     => NVL(p_date,SYSDATE),
                                                p_level                   => k.n_level,
                                                p_earned_rank             => k.v_earned_rank,
                                                p_comm_seq                 => ln_comm_seq,
                                                p_process                 => lv_process_code,
                                                p_plan_code             => k.v_plan_code,
                                                p_comm_year             => k.n_comm_year,
                                                p_posted_from             => j.v_posted_from,
                                                p_posted_ref_no         => j.v_posted_ref_no,
                                                p_prem_type             => NVL(k.v_prem_type,'R'),
                                                p_sharing_percentage     => k.n_sharing_percentage,
                                                p_freq                     => j.v_pymt_freq,
                                                p_porc                  => k.v_porc_comm,
                                                p_source_ref_no         => k.v_source_ref_no,
                                                p_source_desc             => k.v_source_desc,
                                                p_pol_currency             => Bpg_Currency.get_policy_currency(k.v_policy_no),
                                                p_comm_currency         => Bpg_Currency.get_base_currency,
                                                p_exchange_rate         => NULL,
                                                p_comm_rate             => NVL(k.n_comm_rate,0),
                                                p_remarks                 => p_reason,
                                                p_comm_transferred         => NULL ,
                                                p_comm_trans_to         => NULL,
                                                p_comm_trans_fr         => NULL,
                                                p_comm_seq_trans_from     => NULL,
                                                p_vat_applicable         => NULL,
                                                p_vat_amount             => NULL,
                                                p_vat_percentage         => NULL,
                                                p_par_nonpar               => j.v_par_non_par,
                                                p_rop_seq                  => k.n_rop_seq,
                                                p_rop_sub_seq              => k.n_rop_sub_seq,
                                                p_comm_intimation_seq      => k.n_comm_intimation_seq);
           END IF;
        END LOOP;

         FOR l IN cr_prod_details(j.v_policy_no,j.d_due_date,j.n_comm_intimation_seq,j.v_plan_code) LOOP

            OPEN Cr_fetch_lob(l.v_plan_code);
            FETCH Cr_fetch_lob INTO lv_lob;
            CLOSE Cr_fetch_lob;

            OPEN cr_sharing_percent(l.v_policy_no);
            FETCH cr_sharing_percent INTO ln_percent;
            CLOSE cr_sharing_percent;

            IF l.n_first_yr_prem <> 0 THEN
               ln_prem_amt := -l.n_first_yr_prem;
               ln_comm_amt := -l.n_first_yr_comm;
            ELSIF l.n_renewal_prem <> 0 THEN
               ln_prem_amt := -l.n_renewal_prem;
               ln_comm_amt := -l.n_renewal_comm;
            ELSIF l.n_excess_prem <> 0 THEN
               ln_prem_amt := -l.n_excess_prem;
               ln_comm_amt := -l.n_excess_prem_comm;
            END IF;

            IF ln_prem_amt <> 0 THEN
                bpg_agency.bpc_update_agent_production( p_agent_no          => l.n_agent_no,
                                                        p_plan_code            => l.v_plan_code,
                                                        p_comm_level           => l.v_prod_level,
                                                        p_policy_no            => l.v_policy_no,
                                                        p_seq_no            => l.n_seq_no,
                                                        p_due_date             => l.d_due_date,
                                                        p_receipt_no           => l.v_receipt_no,
                                                        p_receipt_date         => l.d_receipt_date,
                                                        p_policy_year        => l.n_prem_year,
                                                        p_premium_amount       => ln_prem_amt,
                                                        p_commission_amount => ln_comm_amt,
                                                        p_lastupd_prog      => p_prog,
                                                         p_lastupd_user      => p_user,
                                                         p_invest_prem_type    => NVL(j.v_premium_type,'R'),
                                                         p_percent              => ln_percent,
                                                        p_trans_date         => NVL(p_date,trunc(SYSDATE)),
                                                        p_lob                 => lv_lob,
                                                        p_selling_agent_no     => l.n_selling_agent_no,
                                                        p_actual_pol_seq    => j.n_actual_seq_no ,
                                                        p_bill_ref_no       => j.v_posted_ref_no,
                                                        p_intimation_seq    => j.n_comm_intimation_seq,
                                                        p_pymt_freq            => j.v_pymt_freq);
           END IF;
        END LOOP;
    END LOOP;
END LOOP;
END bpc_commission_clawback;

 PROCEDURE process_commission_clawback_bk IS
Ln_cnt number :=1;
BEGIN
--FOR i IN (select a.* from ammt_commission_intimation a
--                    where exists (select 1 from ammt_pol_comm_detail b
--                                        where b.v_policy_no = a.v_policy_no
--                                        and b.n_comm_intimation_seq = a.n_comm_intimation_seq)
--                    and a.v_comm_process_Code in ('G','C')
--                    and trunc(a.d_comm_gen) between to_date('01/09/2018','dd/mm/yyyy') and to_date('30/09/2018','dd/mm/yyyy')
--                    and a.v_record_status = 'P'
--                    and a.v_line_of_business <> 'LOB003'
--                    order by 1) LOOP

FOR i in (SELECT * FROM data_05102018_pol_1) LOOP
dbms_application_info.set_action(action_name => 'Data Correction = ' || Ln_cnt );
bpc_commission_clawback(p_policy_no => i.v_policy_no,
                        p_comm_gen_from => NULL,
                        p_comm_gen_to => NULL,
                        p_plan_code => NULL,
                        p_user => 'RFA_REVERSE',
                        p_prog  => 'RFA_REVERSE',
                        p_date => SYSDATE,
                        p_intimation_seq => i.n_comm_intimation_seq,
                        p_reason => 'Comission Repost for on 05/10/2018');
Ln_cnt := Ln_cnt + 1;
END LOOP;
END;
  

PROCEDURE process_commission_clawback IS
Ln_cnt number := 1;
cursor cr_pol is
select distinct v_policy_no from data_05102018_pol_1;
begin
for i in cr_pol loop
dbms_application_info.set_action(action_name => 'Data Correction = ' || Ln_cnt );
delete from gndt_gl_details where n_ref_no in (Select n_ref_no from gnmt_gl_master where v_polag_no = i.v_policy_no and v_process_code like '%AG%'
                                                        and v_lastupd_user in ('RFA_REPOST','RFA_REVERSE'));
delete from gnmt_gl_master where v_polag_no = i.v_policy_no and v_process_code like '%AG%' and v_lastupd_user in ('RFA_REPOST','RFA_REVERSE');
delete from amdt_agent_production_history where v_policy_no = i.v_policy_no and v_lastupd_user in ('RFA_REPOST','RFA_REVERSE');
delete from ammt_pol_comm_detail where v_policy_no = i.v_policy_no and v_lastupd_user in ('RFA_REPOST','RFA_REVERSE');
Ln_cnt := Ln_cnt +1;
end loop;
commit;
end;


PROCEDURE process_bulk_emails_reports(  P_FROM_DATE Date,
                             P_TO_DATE    Date,
                             P_pmt_method_code Varchar2,
                             p_cntr_stat_code Varchar2,
                             p_report_name  varchar2,
                             P_USER      VARCHAR2 DEFAULT USER ,
                             P_PROG      VARCHAR2 DEFAULT 'PS_LTR_A05',
                             P_DATE      DATE default SYSDATE) IS
                             
        CURSOR CR_PROCESS_REPORT IS
              SELECT N_REPORT_NO FROM GNMM_REPORT_MASTER
              WHERE v_report_name=p_report_name;

        CURSOR CR_GET_PARAM(P_REPORT_NO NUMBER)  IS
              SELECT * FROM GNMT_REPORT_PARAM
                WHERE N_REPORT_NO=P_REPORT_NO;

        CURSOR CR_BRANCH IS
              SELECT V_BRANCH_CODE FROM GNMT_USER
               WHERE V_USER_ID=P_USER;

     LN_SEQ_NO NUMBER(16,2);
    LV_BRANCH VARCHAR2(50);
    LN_CNT NUMBER:=0; 
    ln_report_no number;
    
  cursor cr_policies is 
  
  select V_POLICY_NO,v_cntr_stat_code,v_pmt_method_code 
  from gnmt_policy 
  where TO_NUMBER(TO_CHAR(TO_DATE(D_COMMENCEMENT,'DD/MM/RRRR'),'MMDD')) BETWEEN TO_NUMBER(TO_CHAR(TO_DATE(P_FROM_DATE,'DD/MM/RRRR'),'MMDD')) AND TO_NUMBER(TO_CHAR(TO_DATE(P_TO_DATE,'DD/MM/RRRR'),'MMDD'))
        and v_pmt_method_code = nvl(P_pmt_method_code,v_pmt_method_code)
        and v_cntr_stat_code = nvl(p_cntr_stat_code,v_cntr_stat_code)
        and v_grp_ind_flag='I'
        and p_report_name = 'PS_LTR_A05'
        and  V_PLAN_CODE not in ( SELECT V_PLAN_CODE
                                                FROM GNMM_PLAN_MASTER
                                                WHERE  ((UPPER(V_PLAN_DESC) LIKE '%GOLD%') OR(UPPER(V_PLAN_DESC) LIKE '%UNIF%')) )
                                                
union all
  
  select V_POLICY_NO,v_cntr_stat_code,v_pmt_method_code 
  from gnmt_policy 
  where TO_NUMBER(TO_CHAR(TO_DATE(D_COMMENCEMENT,'DD/MM/RRRR'),'MMDD')) BETWEEN TO_NUMBER(TO_CHAR(TO_DATE(P_FROM_DATE,'DD/MM/RRRR'),'MMDD')) AND TO_NUMBER(TO_CHAR(TO_DATE(P_TO_DATE,'DD/MM/RRRR'),'MMDD'))
        and v_pmt_method_code = nvl(P_pmt_method_code,v_pmt_method_code)
        and v_cntr_stat_code = nvl(p_cntr_stat_code,v_cntr_stat_code)
        and v_grp_ind_flag='I'
        and p_report_name = 'PS_LTR_A08'
        and  V_PLAN_CODE not in ( SELECT V_PLAN_CODE
                                                FROM GNMM_PLAN_MASTER
                                                WHERE  ((UPPER(V_PLAN_DESC) LIKE '%GOLD%') OR(UPPER(V_PLAN_DESC) LIKE '%UNIF%')) );

BEGIN


     OPEN CR_BRANCH;
     FETCH CR_BRANCH INTO LV_BRANCH;
     CLOSE CR_BRANCH;
     
     open CR_PROCESS_REPORT;
     fetch CR_PROCESS_REPORT into ln_report_no;
     close CR_PROCESS_REPORT;
     

    FOR I IN cr_policies LOOP 
    
    SELECT SEQ_CORRES.NEXTVAL INTO LN_SEQ_NO FROM DUAL;
    
                INSERT INTO GNMT_CORRES_DESPATCH(N_CORRES_CODE ,
                                                 V_PROCESS_ID,
                                                 N_REPORT_NO,
                                                 V_POLICY_NO,
                                                  N_SEQ_NO ,
                                                  V_REMINDER_FLAG,
                                                 V_MODULE,
                                                 D_PRINT,
                                                 V_REPRINT,
                                                 V_STATUS,
                                                 V_LASTUPD_USER,
                                                 V_LASTUPD_PROG,
                                                 V_LASTUPD_INFTIM,
                                                 V_BRANCH_CODE,
                                                 V_REF_TYPE,
                                                 V_REF_NO ,
                                                 N_CORRES_TRANS,
                                                 N_SET_NO ,
                                                 N_COPIES)
                                            VALUES
                                                 (LN_SEQ_NO,
                                                    p_report_name,
                                                  ln_report_no,
                                                  I.V_POLICY_NO,
                                                  1,
                                                  null,
                                                  'PS',
                                                  TRUNC(SYSDATE),
                                                  'N',
                                                  'PR',
                                                   P_USER,
                                                    P_PROG,
                                                    TRUNC(SYSDATE),
                                                    LV_BRANCH,
                                                    p_report_name,
                                                    I.V_POLICY_NO,
                                                    1,
                                                    null,
                                                    1);

      FOR K IN CR_GET_PARAM(ln_report_no) LOOP
               IF K.V_PARAM_NAME='P_POLICY_NO' THEN
                   INSERT INTO GNDT_CORRES_PARAMETER ( N_CORRES_CODE,
                                                         V_PARAM,
                                                      V_PARAM_TYPE,
                                                      V_PARAM_CHAR_VAL,
                                                      V_PARAM_NUM_VAL,
                                                      V_PARAM_DATE_VAL,
                                                      V_LASTUPD_USER,
                                                      V_LASTUPD_PROG,
                                                      V_LASTUPD_INFTIM,
                                                      N_CORRES_TRANS)
                                                   VALUES(  LN_SEQ_NO,
                                                         K.V_PARAM_NAME,
                                                         K.V_PARAM_DATA_TYPE,
                                                         I.V_POLICY_NO,
                                                         NULL,
                                                         NULL,
                                                         P_USER,
                                                         P_PROG,
                                                         TRUNC(SYSDATE),
                                                         1);
          ELSIF K.V_PARAM_NAME='P_PAY_METHOD' THEN
                   INSERT INTO GNDT_CORRES_PARAMETER ( N_CORRES_CODE,
                                                         V_PARAM,
                                                      V_PARAM_TYPE,
                                                      V_PARAM_CHAR_VAL,
                                                      V_PARAM_NUM_VAL,
                                                      V_PARAM_DATE_VAL,
                                                      V_LASTUPD_USER,
                                                      V_LASTUPD_PROG,
                                                      V_LASTUPD_INFTIM,
                                                      N_CORRES_TRANS)
                                                   VALUES(  LN_SEQ_NO,
                                                         K.V_PARAM_NAME,
                                                         K.V_PARAM_DATA_TYPE,
                                                         I.V_PMT_METHOD_CODE,
                                                         NULL,
                                                         NULL,
                                                         P_USER,
                                                         P_PROG,
                                                         TRUNC(SYSDATE),
                                                         1);
      ELSIF K.V_PARAM_NAME='P_STATUS_DESC' THEN
                   INSERT INTO GNDT_CORRES_PARAMETER ( N_CORRES_CODE,
                                                         V_PARAM,
                                                      V_PARAM_TYPE,
                                                      V_PARAM_CHAR_VAL,
                                                      V_PARAM_NUM_VAL,
                                                      V_PARAM_DATE_VAL,
                                                      V_LASTUPD_USER,
                                                      V_LASTUPD_PROG,
                                                      V_LASTUPD_INFTIM,
                                                      N_CORRES_TRANS)
                                                   VALUES(  LN_SEQ_NO,
                                                         K.V_PARAM_NAME,
                                                         K.V_PARAM_DATA_TYPE,
                                                         I.v_cntr_stat_code,
                                                         NULL,
                                                         NULL,
                                                         P_USER,
                                                         P_PROG,
                                                         TRUNC(SYSDATE),
                                                         1);
          END IF;
    END LOOP;
END LOOP;

END;                     

FUNCTION Get_Alteration_Text (P_policy_no       VARCHAR,
                                 P_alter_code      VARCHAR,
                                 P_quotation_id    VARCHAR)
      RETURN VARCHAR
   IS
      b_text       VARCHAR (1000);
      v_alt_date   DATE;
      v_old_val    VARCHAR (1000);
      v_new_val    VARCHAR (1000);
   BEGIN
      --    raise_error (
      --    'P_policy_no=='||P_policy_no||
      --    'P_alter_code=='||P_alter_code||
      --     'P_quotation_id=='||P_quotation_id||
      --    'v_new_val=='||v_new_val||
      --    'v_old_val=='||v_old_val);
      IF P_alter_code IN ('AL123', 'AL22', 'AL45')
      THEN
         SELECT REPLACE (
                   REPLACE (
                      REPLACE (
                         V_boiler_text,
                         'V_OLD_VALUE',
                         Jhl_utils.Old_new_val (A.V_alter_code, V_old_value)),
                      'V_NEW_VALUE',
                      Jhl_utils.Old_new_val (A.V_alter_code, V_new_value)),
                   'D_ALTERATION',
                   TO_CHAR (D_alteration, 'DD-MM-YYYY'))
           INTO b_text
           FROM Psdt_alteration_history A,
                Jhl_endt_boiler_text E,
                Psmt_alteration C
          WHERE     A.V_alter_code = E.V_alter_code
                AND A.N_alteration_seq_no = C.N_alteration_seq_no
                AND A.V_policy_no = P_policy_no
                AND A.V_alter_code = P_alter_code
                AND A.V_quotation_id = P_quotation_id;
      END IF;

      IF P_alter_code IN ('AL27', 'AL26')
      THEN
         SELECT DISTINCT D_alteration
           INTO v_alt_date
           FROM Psdt_alteration_history A,
                Jhl_endt_boiler_text E,
                Psmt_alteration C
          WHERE     A.V_alter_code = E.V_alter_code
                AND A.N_alteration_seq_no = C.N_alteration_seq_no
                AND A.V_policy_no = P_policy_no
                AND A.V_alter_code = P_alter_code
                AND A.V_quotation_id = P_quotation_id;


         BEGIN
              SELECT                                           -- v_policy_no,
                    RTRIM (
                        XMLAGG (XMLELEMENT (E, V_PLAN_DESC || ',')).EXTRACT (
                           '//text()'),
                        ',')
                        Riders
                INTO v_old_val
                FROM Psdt_alteration_history Y, GNMM_PLAN_MASTER PL
               WHERE     Y.V_old_value = PL.V_PLAN_CODE
                     AND Y.V_policy_no = P_policy_no
                     AND Y.V_alter_code = P_alter_code
                     AND V_policy_no = P_policy_no
            GROUP BY V_policy_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_old_val := NULL;
         END;



         BEGIN
              SELECT                                           -- v_policy_no,
                    RTRIM (
                        XMLAGG (XMLELEMENT (E, V_PLAN_DESC || ',')).EXTRACT (
                           '//text()'),
                        ',')
                        Riders
                INTO v_new_val
                FROM Psdt_alteration_history Y, GNMM_PLAN_MASTER PL
               WHERE     Y.V_NEW_value = PL.V_PLAN_CODE
                     AND Y.V_policy_no = P_policy_no
                     AND Y.V_alter_code = P_alter_code
                     AND V_policy_no = P_policy_no
            GROUP BY V_policy_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_new_val := NULL;
         END;



         SELECT REPLACE (
                   REPLACE (
                      REPLACE (V_boiler_text, 'V_OLD_VALUE', v_old_val),
                      'V_NEW_VALUE',
                      v_new_val),
                   'D_ALTERATION',
                   TO_CHAR (v_alt_date, 'DD-MM-YYYY'))
           INTO b_text
           FROM Jhl_endt_boiler_text E
          WHERE E.V_alter_code = P_alter_code;
      --                                                                                                             raise_error (
      --    'P_policy_no=='||P_policy_no||
      --    'P_alter_code=='||P_alter_code||
      --     'P_quotation_id=='||P_quotation_id||
      --     'v_alt_date=='||v_alt_date||
      --    'v_new_val=='||v_new_val||
      --    'v_old_val=='||v_old_val||
      --    'b_text=='||b_text

      --    );

      END IF;



      RETURN b_text;
   --     exception
   --     when others then
   --     raise_error('Error on alteration text');
   END;
   

FUNCTION Get_Policy_Nominees (P_policy_no  VARCHAR, V_TYPE VARCHAR DEFAULT 'N')
      RETURN VARCHAR IS
      
      V_TEMP VARCHAR2 (2000);
      V_NOM_RELATION VARCHAR2 (2000);
      
      v_count NUMBER;
      
      CURSOR C1 IS
SELECT
a.N_CUST_REF_NO, V_NAME, V_REL_DESC
FROM PSMT_NOMINATION_HISTORY a, GNMT_CUSTOMER_MASTER b, GNLU_RELATION_MASTER c
WHERE a.N_CUST_REF_NO = b.N_CUST_REF_NO
and a.V_REL_CODE = c.V_REL_CODE
AND A.V_STATUS = 'A'
AND V_POLICY_NO = P_policy_no;

begin
    V_TEMP := '';
    V_NOM_RELATION := '';
    FOR i IN C1 LOOP
        V_TEMP := V_TEMP||','||i.V_NAME;
        V_NOM_RELATION := V_NOM_RELATION||','||i.V_REL_DESC;
    END LOOP;
    

    IF V_TYPE =  'N' THEN
    RETURN SUBSTR(V_TEMP,2) ;
    ELSE
    RETURN SUBSTR(V_NOM_RELATION,2);
    END IF;
    
    END ;


function Get_Policy_Plan_Discount ( P_policy_no  VARCHAR, Plan_Code VARCHAR) return Number is
    cursor cr_DiscAmt is
        SELECT
            SUM(A.N_LOAD_DIS_PREM)
        FROM GNDT_CHARGE_QUOT_LOAD_DIS_DETS A,
             GNMT_QUOTATION B
        WHERE     A.V_QUOTATION_ID        =        B.V_QUOTATION_ID
        AND        A.V_LOAD_DISCOUNT            =        'D'
        AND        B.V_POLICY_NO                    =        P_policy_no
        AND        B.V_PLAN_CODE                 =        Plan_Code
        AND        B.V_QUOT_BACKUP_TYPE     IS    NULL;
    
    lv_DiscAmt Number;
begin

    Open cr_DiscAmt;
        Fetch cr_DiscAmt into lv_DiscAmt;
    Close cr_DiscAmt; 
    
  Return nvl(lv_DiscAmt,0);
end;


function  Modal_Prem_Formula (P_Policy_No  VARCHAR, p_poltype VARCHAR DEFAULT 'N') return Number is
   cursor cr_modal_prem is select n_contribution
                           from gnmt_quotation
                           where v_policy_no = P_Policy_No
                           and V_CNTR_STAT_CODE = 'NB010';
                           
   cursor cr_ser_tax is select N_SERVICE_TAX tax
                        from gnmt_quotation
                        where v_policy_no = P_Policy_No; 
                        
   cursor cr_tmodal_prem is select n_net_contribution
                           from gnmt_quotation
                           where v_policy_no = P_Policy_No
                           and V_CNTR_STAT_CODE = 'NB010'; 
                           
   cursor cr_prem_paid is select sum(n_amount) premamt
                          from ppdt_proposal_deposit
                          where v_policy_no = P_Policy_No
                          and v_status ='A'; 
                          
   cursor cr_pay_mode is select initcap( b.v_pymt_desc) paymode 
                         from gnmt_quotation a,
                              gnlu_frequency_master b
                         where a.v_pymt_freq = b.v_pymt_freq
                         and     a.v_policy_no = P_Policy_No; 
                         
   cursor cr_pay_method is select initcap( b.V_PMT_METHOD_NAME) paymode 
                         from gnmt_quotation a,
                              GNLU_PAY_METHOD b
                         where a.V_PMT_METHOD_CODE = b.V_PMT_METHOD_CODE
                         and     a.v_policy_no = P_Policy_No;                         
                         
   ln_prem_paid number := 0;
   ln_mod_prem number := 0;
   ln_ser_tax number := 0;
   ln_tmod_prem number := 0;
   ln_topup_amt number := 0;
   cp_mod_prem number := 0;
    cp_topup_amt number := 0;
    cp_ser_tax number := 0;
    cp_tmod_prem number := 0;
    cp_prem_paid number := 0;
                                                                                                                                

begin
   open cr_modal_prem;
   fetch cr_modal_prem into ln_mod_prem;
   close cr_modal_prem;
   ln_topup_amt := bpg_nb_traditional_life.bfn_get_topup_amount(P_Policy_No,'P');
   If p_poltype = 'Y' Then
       cp_mod_prem := ln_mod_prem - nvl(ln_topup_amt,0);
   Else
       cp_mod_prem := ln_mod_prem;
   End If;
   cp_topup_amt := ln_topup_amt;
   
   
   open cr_ser_tax;
   fetch cr_ser_tax into ln_ser_tax;
   close cr_ser_tax;
    cp_ser_tax := ln_ser_tax;
   
   open cr_tmodal_prem;
   fetch cr_tmodal_prem into ln_tmod_prem;
   close cr_tmodal_prem;
   cp_tmod_prem := ln_tmod_prem;
   
   open cr_prem_paid;
   fetch cr_prem_paid into ln_prem_paid;
   close cr_prem_paid;
   
   cp_prem_paid := nvl(ln_prem_paid,0);
   
   /*open cr_pay_mode;
   fetch cr_pay_mode into :cp_pay_mode;
   close cr_pay_mode;

   open cr_pay_method;
   fetch cr_pay_method into :cp_pay_method;
   close cr_pay_method;*/
  
IF p_poltype = 'N' THEN
   return cp_mod_prem;
ELSE
return cp_tmod_prem;
END IF;
   
   
end;


function  get_lapse_inforce_period (P_Policy_No  VARCHAR ) return Number is

v_lapse_date DATE;
v_inforce_dt DATE;
begin

BEGIN
    SELECT  max(V_LASTUPD_INFTIM)
    INTO v_lapse_date
    FROM PSMT_NON_PAYMENT_TERMINATION
    WHERE V_POLICY_NO = P_Policy_No;
    EXCEPTION
    WHEN OTHERS THEN
    return 0;
    END;
    
    if v_lapse_date is null then
    
    return 0;
    
    end if;
    
    BEGIN
    /*SELECT  max(D_FROM)
    INTO v_inforce_dt
    FROM GN_CONTRACT_STATUS_LOG LG,GNMT_POLICY POL
    WHERE LG.V_POLICY_NO=POL.V_POLICY_NO
    and LG.V_PLRI_CODE = POL.V_PLAN_CODE
    AND  LG.V_POLICY_NO =P_Policy_No
    AND LG.V_CURR_STAT_CODE = 'NB010';*/
    
        SELECT max(D_REVIVE) 
            INTO v_inforce_dt
        FROM  PSMT_POLICY_REVIVAL
        WHERE V_POLICY_NO = P_Policy_No;
    
    EXCEPTION
    WHEN OTHERS THEN
     raise_error('Error getting');
    END;
    
--    raise_error('v_inforce_dt:==' ||v_inforce_dt|| 
--             'v_lapse_date:==' ||v_lapse_date );
    
    return   round(months_between(v_inforce_dt ,v_lapse_date),2);

end;


PROCEDURE populate_banca_yearly_com  is

CURSOR POLICIES IS 
/*SELECT V_POLICY_NO, D_COMMENCEMENT, D_POLICY_END_DATE,   POL.N_CONTRIBUTION PREMIUM ,
POL.N_CONTRIBUTION  * 12/TO_NUMBER(POL.V_PYMT_FREQ) ANNUAL_PREM , POL.V_PYMT_FREQ,
V_PYMT_DESC
 
FROM GNMT_POLICY POL,GNLU_FREQUENCY_MASTER FREQ
WHERE  POL.V_PYMT_FREQ = FREQ.V_PYMT_FREQ
--and V_POLICY_NO  IN ( 'IL201801399940','IL201701150545')
and V_POLICY_NO  IN (
                        SELECT POLICY_NO
                        FROM JHL_POLICY) ;*/
                        
    SELECT POL.V_POLICY_NO, D_COMMENCEMENT, D_POLICY_END_DATE,   POL.N_CONTRIBUTION PREMIUM ,
POL.N_CONTRIBUTION  * 12/TO_NUMBER(POL.V_PYMT_FREQ) ANNUAL_PREM , POL.V_PYMT_FREQ
FROM GNMT_POLICY POL, AMMT_POL_AG_COMM C
WHERE  POL.V_POLICY_NO = C.V_POLICY_NO
 AND POL.V_POLICY_NO NOT LIKE 'GL%'
AND C.V_STATUS = 'A'
AND  C.N_AGENT_NO IN  (1218, 28020, 54560, 28779, 40560, 17358, 34620, 22778,65620, 72770,22778,74753,80214,82494)
AND V_CNTR_STAT_CODE IN ('NB022')
AND POL.D_COMMENCEMENT >= '01-JAN-14';
--and POL.V_POLICY_NO  IN ( 'IL201801412842')
-- AND POL.V_POLICY_NO  IN (
--                        SELECT POLICY_NO
--                        FROM JHL_POLICY) ;
                        
v_end_date DATE;
v_issued_date DATE;
v_start_date DATE;
v_from_date DATE;
v_to_date DATE;
v_ann_date DATE;
v_beg_date DATE;
v_count NUMBER; 
v_comm_amt NUMBER; 
v_comm_rt NUMBER; 
v_comm_used_rt NUMBER;
v_n_prem_amt  NUMBER;

BEGIN

DELETE FROM JHL_ANNUAL_POL_COM; 

    FOR I IN POLICIES LOOP
    
    
    
          v_start_date  := I.D_COMMENCEMENT;
          v_end_date  := I.D_COMMENCEMENT;
          v_ann_date   :=  add_months(I.D_COMMENCEMENT,12);
          v_count :=1;
          
       WHILE( TRUNC(v_end_date) <= TRUNC(I.D_POLICY_END_DATE) ) LOOP
      
       v_comm_used_rt :=null;
       
                SELECT  TRUNC(v_end_date)
                              INTO  v_from_date
                               from dual;
                               
                  select  ADD_MONTHS(v_end_date,12)
                  INTO  v_to_date
                   from dual;
                   
                   
                   /*SELECT 
                 
                NVL( SUM(N_COMM_AMT),0)
                 INTO v_comm_amt
            FROM Ammt_Pol_Comm_Detail A,
                 Gnmt_Policy_Detail B,
                 Ammm_Agent_Master C,
                 Gnmt_Customer_Master D,
                 --GNDT_CUSTOMER_ADDRESS e,
                 Ammm_Rank_Master F,
                 Amdt_Agent_Benefit_Pool_Detail G,
                 Amdt_Agent_Bene_Pool_Payment H,
                 Gnmm_Plan_Master J
           WHERE     V_Comm_Status IN ('P')
                 AND A.V_Policy_No = B.V_Policy_No
                 AND A.N_Seq_No = B.N_Seq_No
                 AND A.N_Agent_No = C.N_Agent_No
                 AND C.N_Cust_Ref_No = D.N_Cust_Ref_No
                 AND C.V_Rank_Code = F.V_Rank_Code
                 AND C.N_Channel_No = F.N_Channel_No
                 AND G.V_Trans_Source_Code IN ('COMMISSION',
                                               'COMMISSION REVERSAL')
                 AND V_Accounted = 'Y'
                 AND A.V_Plan_Code = J.V_Plan_Code
                 AND A.N_Comm_Benefit_Pool_Seq_No = G.N_Benefit_Pool_Seq_No
                 AND G.N_Benefit_Pool_Pay_Seq(+) = H.N_Benefit_Pool_Pay_Seq
                 AND  A.V_POLICY_NO   = I.V_POLICY_NO
                 AND TRUNC(G.D_Trans_Date) BETWEEN  v_from_date AND v_to_date -1
                 AND V_Oc_Flag ='N';*/
                 
                 
                SELECT 
                NVL( SUM(N_COMM_AMT),0)
                 INTO v_comm_amt
                FROM AMMT_POL_COMM_DETAIL A 
                WHERE  A.V_POLICY_NO = I.V_POLICY_NO
                 AND A.V_Oc_Flag ='N'
                AND TRUNC(A.D_COMM_PAID) BETWEEN  v_from_date AND v_to_date -1;
                
                
                
                     SELECT 
                NVL( SUM(N_PREM_AMT),0)
                 INTO v_n_prem_amt
                FROM AMMT_POL_COMM_DETAIL A 
                WHERE  A.V_POLICY_NO = I.V_POLICY_NO
                 AND A.V_Oc_Flag ='N'
                AND TRUNC(A.D_COMM_PAID) BETWEEN  v_from_date AND v_to_date -1;
                
                
                 begin
                 SELECT  round( avg(N_COMM_RATE),2)
                 INTO v_comm_used_rt
                FROM AMMT_POL_COMM_DETAIL A 
                WHERE  A.V_POLICY_NO = I.V_POLICY_NO
                 AND A.V_Oc_Flag ='N'
                AND TRUNC(A.D_COMM_PAID) BETWEEN  v_from_date AND v_to_date -1;
                exception
                when no_data_found then
                v_comm_used_rt :=null;
                
                end;
                
                
                 
                 
                 IF  v_count = 1 THEN
                 v_comm_rt := 40;
                 END IF;
                 
                    IF  v_count = 2 THEN
                 v_comm_rt := 20;
                 END IF;
                 
                         IF  v_count > 2 THEN
                 v_comm_rt := 5;
                 END IF;
                   
                   INSERT INTO JHL_ANNUAL_POL_COM(
                   POL_NO, POL_YEAR, POL_YEAR_START, POL_YEAR_END, 
                   POL_COM_RATE, POL_ANNUAL_PREM, POL_EXPECTED_COM, 
                   POL_PAID_COM, POL_UNPAID_COM,N_PREM_AMT
                   )
                   
                   VALUES(I.V_POLICY_NO,v_count ,v_from_date,v_to_date -1,
                  nvl( v_comm_used_rt,v_comm_rt) ,
                   I.ANNUAL_PREM, 
                    I.ANNUAL_PREM * v_comm_rt/100  ,
                    NVL(v_comm_amt,0), 
                   I.ANNUAL_PREM * v_comm_rt/100 - NVL(v_comm_amt,0),v_n_prem_amt );
                   
                   
       
         v_end_date := ADD_MONTHS(v_end_date,12);
       
       
            
       v_count := v_count+1;
       
       END LOOP;

    END LOOP;
COMMIT;
END;
     

FUNCTION test_trigger RETURN BOOLEAN is
 
 v_val BOOLEAN;
 BEGIN
--  populate_banca_yearly_com;
 v_val :=true;

 RETURN  v_val;
 
 END;


PROCEDURE profiler_control(
   start_stop IN VARCHAR2,
   run_comm IN VARCHAR2,
   ret OUT BOOLEAN) AS ret_code INTEGER;
BEGIN
 ret_code:=dbms_profiler.internal_version_check;
  IF ret_code !=0 THEN
   ret:=FALSE;
  ELSIF start_stop NOT IN ('START','STOP') THEN
   ret:=FALSE;
  ELSIF start_stop = 'START' THEN
   ret_code:=DBMS_PROFILER.START_PROFILER(run_comment1=>run_comm);
   IF ret_code=0 THEN
    ret:=TRUE;
   ELSE
    ret:=FALSE;
   END IF;
  ELSIF start_stop = 'STOP' THEN
   ret_code:=DBMS_PROFILER.FLUSH_DATA;
   ret_code:=DBMS_PROFILER.STOP_PROFILER;
   IF ret_code=0 THEN
    ret:=TRUE;
   ELSE
    ret:=FALSE;
   END IF;
  END IF;
END profiler_control;



function  get_policy_voucher_amount (P_Policy_No  VARCHAR, v_approved  VARCHAR ) return Number is

v_amt number;



BEGIN

    
SELECT SUM(NVL(N_VOU_AMOUNT,0))
 into v_amt
FROM PYMT_VOUCHER_ROOT A,PYMT_VOU_MASTER B
WHERE   A.V_MAIN_VOU_NO = B.V_MAIN_VOU_NO  
AND  JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED(B.V_vou_no) = v_approved
and  JHL_GEN_PKG.IS_VOUCHER_CANCELLED(B.V_vou_no)  = 'N'
AND B.V_VOU_NO IN                 ( SELECT   E.V_VOU_NO
                                                FROM PYDT_VOUCHER_POLICY_CLIENT E
                                                WHERE  E.V_POLICY_NO = P_Policy_No
                                                );
    
--    raise_error('v_inforce_dt:==' ||v_inforce_dt|| 
--             'v_lapse_date:==' ||v_lapse_date );
    
    return  v_amt;

end;


function  get_policy_status_user (P_Policy_No  VARCHAR, v_st  VARCHAR ) return VARCHAR is

v_user VARCHAR2(200);


CURSOR POL IS 
  SELECT V_LASTUPD_USER,V_UNDERWRITER
  FROM GNMT_POLICY POL
  WHERE  POL.V_POLICY_NO =  P_Policy_No;

BEGIN

for i in POL loop

        if  v_st = 'I' THEN
        
        BEGIN
        
        SELECT  V_LASTUPD_USER
         INTO v_user
        FROM GN_CONTRACT_STATUS_LOG
        WHERE V_POLICY_NO = P_Policy_No
        AND V_PREV_STAT_CODE LIKE 'NB099%' 
        AND V_CURR_STAT_CODE = 'NB010'
        and V_PLRI_FLAG = 'P' ;
        
        EXCEPTION
        
        WHEN OTHERS  THEN
         RETURN NVL(I.V_UNDERWRITER,I.V_LASTUPD_USER);
        END;
        
        RETURN NVL(v_user,I.V_UNDERWRITER);

ELSE
        RETURN NVL(I.V_UNDERWRITER,I.V_LASTUPD_USER);
        end if ;
       

end loop;



EXCEPTION 
WHEN OTHERS THEN 
RETURN NULL;
end;



function  get_policy_voucher_case (p_policy_No  VARCHAR, p_vou  VARCHAR ) return NUMBER is

v_user VARCHAR2(200);


CURSOR POL IS 
SELECT *
FROM JHL_CRM_CASES  C
WHERE UPPER(C.POLICY_NUMBER_C)  =p_policy_No
--AND  DECODE(UPPER(C.ASSIGNED),'PETER.WAKORI','PWAKORI' ,UPPER(C.ASSIGNED) )   =  UPPER(JHL_GEN_PKG.GET_VOUCHER_STATUS_USER (B.V_VOU_NO, 'PREPARE') )
order by DATE_ENTERED desc;

BEGIN

for i in POL loop

     return i.CASE_NUMBER;
       

end loop;

return null;


EXCEPTION 
WHEN OTHERS THEN 
RETURN NULL;
end;


 FUNCTION GET_PREV_STATUS
    (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE)
  RETURN VARCHAR2 IS
    V_TEMP VARCHAR2 (200);
    V_MULTI VARCHAR2 (2);
    V_USER VARCHAR2 (200);
    

    BEGIN
            
        SELECT PREV_STATUS INTO V_TEMP
        FROM
        (
        SELECT V_POLICY_NO, V_PREV_STAT_CODE, y.V_STATUS_DESC PREV_STATUS, V_CURR_STAT_CODE, z.V_STATUS_DESC CURR_STATUS, N_SEQ
        FROM GN_CONTRACT_STATUS_LOG x, GNMM_POLICY_STATUS_MASTER y, GNMM_POLICY_STATUS_MASTER z
        WHERE V_PLRI_FLAG='P'
        AND v_policy_no like P_POLICY_NO
        AND V_PREV_STAT_CODE = y.V_STATUS_CODE
        AND V_CURR_STAT_CODE = z.V_STATUS_CODE
        ORDER BY N_SEQ DESC
        )
        WHERE ROWNUM=1;

        RETURN V_TEMP;


    END;  
    
    
    FUNCTION RIDER_PREMIUM
    (P_POLICY_NO IN VARCHAR2)
  RETURN NUMBER IS
    V_TEMP NUMBER;

    BEGIN
            
            SELECT SUM(N_RIDER_PREMIUM) INTO V_TEMP
            FROM GNMT_POLICY_RIDERS
            WHERE V_POLICY_NO = P_POLICY_NO;
           
            RETURN V_TEMP;


    END;
    
    
    FUNCTION DOB_TWO
    (P_POLICY_NO IN VARCHAR2)
  RETURN DATE IS
    V_TEMP DATE;

    BEGIN
            
        SELECT TRUNC(D_IND_DOB) INTO V_TEMP FROM GNMT_POLICY_DETAIL
        WHERE V_POLICY_NO = P_POLICY_NO
        AND N_SEQ_NO = 2;
           
        RETURN V_TEMP;


    END;
    
    
    FUNCTION AGENT_PROD_FIRST_YEAR
    (P_AGENT_NO IN NUMBER, P_TYPE IN VARCHAR2)
  RETURN NUMBER IS
    V_COUNT NUMBER;
    V_PREMIUM NUMBER;
    V_FM_DT VARCHAR2(20);

    BEGIN


        SELECT COUNT(a.V_POLICY_NO) POLICY_COUNT, SUM(12/b.V_PYMT_FREQ*N_CONTRIBUTION) API INTO V_COUNT, V_PREMIUM
        FROM AMMT_POL_AG_COMM a, GNMT_POLICY b
        WHERE V_ROLE_CODE = 'SELLING'
        AND a.V_POLICY_NO = b.V_POLICY_NO
        AND N_SELL_AGENT_LINK = P_AGENT_NO
        AND a.V_POLICY_NO NOT LIKE 'GL%'
        AND b.V_PYMT_FREQ<>'00'
        AND b.V_CNTR_STAT_CODE NOT IN ('NB053','NB054','NB058','NB099','NB001')
        AND a.V_STATUS = 'A'
        AND D_COMMENCEMENT BETWEEN ADD_MONTHS(TRUNC(SYSDATE),-12) AND TRUNC(SYSDATE)-1;

        IF P_TYPE = 'COUNT' THEN   
            RETURN V_COUNT;
        ELSE
            RETURN V_PREMIUM;
        END IF;


    END;  

  FUNCTION AGENT_PROD
    (P_AGENT_NO IN NUMBER, P_FM_DT IN DATE, P_TO_DT IN DATE, P_PERIOD IN VARCHAR2, P_TYPE IN VARCHAR2)
  RETURN NUMBER IS
    V_COUNT NUMBER;
    V_PREMIUM NUMBER;
    V_FM_DT DATE;

    BEGIN
        V_FM_DT := P_FM_DT;
        IF P_PERIOD = 'YTD' THEN
            V_FM_DT := TRUNC(P_FM_DT,'YY');
            
            
        END IF;

        SELECT COUNT(a.V_POLICY_NO) POLICY_COUNT, SUM(DECODE(b.V_PYMT_FREQ,0,1,12/b.V_PYMT_FREQ)*N_CONTRIBUTION) API INTO V_COUNT, V_PREMIUM
        FROM AMMT_POL_AG_COMM a, GNMT_POLICY b
        WHERE V_ROLE_CODE = 'SELLING'
        AND a.V_POLICY_NO = b.V_POLICY_NO
        AND N_SELL_AGENT_LINK = P_AGENT_NO
        AND a.V_POLICY_NO NOT LIKE 'GL%'
        AND b.V_PYMT_FREQ<>'00'
        AND b.V_CNTR_STAT_CODE NOT IN ('NB053','NB054','NB058','NB099','NB001')
        AND a.V_STATUS = 'A'
--        AND D_ISSUE BETWEEN TO_DATE(V_FM_DT,'DD/MM/YYYY') AND TO_DATE(P_TO_DT,'DD/MM/YYYY');
        AND trunc(D_ISSUE) BETWEEN trunc(V_FM_DT) AND trunc(P_TO_DT);

        IF P_TYPE = 'COUNT' THEN   
            RETURN V_COUNT;
        ELSE
            RETURN V_PREMIUM;
        END IF;


    END;  
    
    
    
    FUNCTION AGENCY_NAME2
    (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
  RETURN VARCHAR2 IS

    CURSOR C1 IS
    SELECT TRIM(V_ADD_THREE) AGENCY
    FROM AMMT_POL_AG_COMM a, AMMM_AGENT_MASTER b, GNDT_CUSTOMER_ADDRESS c
    WHERE a.N_AGENT_NO = b.N_AGENT_NO
    AND b.N_CUST_REF_NO = c.N_CUST_REF_NO
    AND V_POLICY_NO=P_POLICY_NO --'IL201200031675'
    AND V_ROLE_CODE= 'SELLING'
    AND a.V_STATUS = 'A'
    AND ROWNUM =1;
  
    V_TEMP VARCHAR2 (200);

    BEGIN


        IF C1%ISOPEN THEN CLOSE C1; END IF;
        OPEN C1;
        FETCH C1 INTO V_TEMP;
           
        RETURN V_TEMP;

    END; 
    
    
    FUNCTION AGENT_NAME3
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2 IS

    CURSOR C1 IS
    SELECT V_AGENT_CODE||'-'||TRIM(V_COMPANY_NAME)||' ('||TRIM(V_ADD_THREE)||')'
    FROM AMMM_AGENT_MASTER a, GNMM_COMPANY_MASTER b, GNDT_COMPANY_ADDRESS c
    WHERE A.V_COMPANY_CODE = b.V_COMPANY_CODE
    AND A.V_COMPANY_BRANCH = B.V_COMPANY_BRANCH
    AND b.V_COMPANY_CODE = c.V_COMPANY_CODE
    AND B.V_COMPANY_BRANCH =C.V_COMPANY_BRANCH
    AND a.N_AGENT_NO = P_AGENT_NO
    AND ROWNUM =1;  
  
    V_TEMP VARCHAR2 (200);

    BEGIN


        IF C1%ISOPEN THEN CLOSE C1; END IF;
        OPEN C1;
        FETCH C1 INTO V_TEMP;
           
        RETURN V_TEMP;

    END;   
    
 FUNCTION AGENT_NAME5 (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
 RETURN VARCHAR2
IS
   V_TEMP   VARCHAR2 (200);
    BEGIN
       SELECT CONTACT_NUMBER
         INTO V_TEMP
         FROM (  SELECT V_AGENT_CODE || '-' || TRIM (V_NAME) AGENT_NAME,
                        C.V_CONTACT_NUMBER CONTACT_NUMBER,
                        A.N_CUST_REF_NO                              
                   FROM AMMM_AGENT_MASTER A,
                        GNMT_CUSTOMER_MASTER B,
                        GNDT_CUSTMOBILE_CONTACTS C,
                        AMMT_POL_AG_COMM D
                  WHERE     A.N_CUST_REF_NO = B.N_CUST_REF_NO
                        AND B.N_CUST_REF_NO = C.N_CUST_REF_NO
                        --AND V_AGENT_CODE=P_AGENT_NO
                        AND A.N_AGENT_NO = D.N_AGENT_NO
                        AND D.V_STATUS = 'A'
                        AND D.V_ROLE_CODE = 'SELLING'
                        AND V_POLICY_NO = P_POLICY_NO
                        AND C.V_CONTACT_NUMBER NOT LIKE ('%@%')
                        AND C.V_CONTACT_NUMBER NOT LIKE ('%A%')
               ORDER BY N_ADD_SEQ_NO DESC)
        
        WHERE ROWNUM = 1;

       RETURN V_TEMP;
       
       END; 
       
FUNCTION AGENT_NAME6 (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
 RETURN VARCHAR2
IS
   V_TEMP   VARCHAR2 (200);
    BEGIN
       SELECT AGENT_NAME
         INTO V_TEMP
         FROM (  SELECT V_AGENT_CODE || '-' || TRIM (V_NAME) AGENT_NAME,
                        C.V_CONTACT_NUMBER CONTACT_NUMBER,
                        A.N_CUST_REF_NO                              
                   FROM AMMM_AGENT_MASTER A,
                        GNMT_CUSTOMER_MASTER B,
                        GNDT_CUSTMOBILE_CONTACTS C,
                        AMMT_POL_AG_COMM D
                  WHERE     A.N_CUST_REF_NO = B.N_CUST_REF_NO
                        AND B.N_CUST_REF_NO = C.N_CUST_REF_NO
                        --AND V_AGENT_CODE=P_AGENT_NO
                        AND A.N_AGENT_NO = D.N_AGENT_NO
                        AND D.V_STATUS = 'A'
                        AND D.V_ROLE_CODE = 'SELLING'
                        AND V_POLICY_NO = P_POLICY_NO
                        AND C.V_CONTACT_NUMBER NOT LIKE ('%@%')
                        AND C.V_CONTACT_NUMBER NOT LIKE ('%A%')
               ORDER BY N_ADD_SEQ_NO DESC)
        WHERE ROWNUM = 1;

       RETURN V_TEMP;

    END; 
    
FUNCTION AGENT_NAME7 (P_POLICY_NO IN AMMT_POL_AG_COMM.V_POLICY_NO%TYPE)
RETURN VARCHAR2
IS
   V_TEMP   VARCHAR2 (200);
    BEGIN
       SELECT EMAIL_ADDRESS
         INTO V_TEMP
         FROM (  SELECT V_AGENT_CODE || '-' || TRIM (V_NAME) AGENT_NAME,
                        C.V_CONTACT_NUMBER EMAIL_ADDRESS,
                        A.N_CUST_REF_NO                              
                   FROM AMMM_AGENT_MASTER A,
                        GNMT_CUSTOMER_MASTER B,
                        GNDT_CUSTMOBILE_CONTACTS C,
                        AMMT_POL_AG_COMM D
                  WHERE     A.N_CUST_REF_NO = B.N_CUST_REF_NO
                        AND B.N_CUST_REF_NO = C.N_CUST_REF_NO
                        --AND V_AGENT_CODE=P_AGENT_NO
                        AND A.N_AGENT_NO = D.N_AGENT_NO
                        AND D.V_STATUS = 'A'
                        AND D.V_ROLE_CODE = 'SELLING'
                        AND V_POLICY_NO = P_POLICY_NO
                        AND C.V_CONTACT_NUMBER LIKE ('%@%')
                        ORDER BY N_ADD_SEQ_NO DESC)
        WHERE ROWNUM = 1;

       RETURN V_TEMP;

    END; 



 FUNCTION POLICY_APPROVAL_ANALYSIS(P_POLICY_NO VARCHAR) RETURN BOOLEAN is
 
 v_val BOOLEAN;
 BEGIN
--  populate_banca_yearly_com;

--raise_error('test');

DBMS_APPLICATION_INFO.SET_ACTION ('Started Loaded into Oracle file ==: '||P_POLICY_NO); 

  JHL_GEN_PKG.GENERATE_POL_BONUS( P_POLICY_NO);
  
    DBMS_OUTPUT.PUT_LINE ('v_pol_no == :'||P_POLICY_NO); 
 DBMS_APPLICATION_INFO.SET_CLIENT_INFO('Successfully executed '||P_POLICY_NO);
  
 v_val :=true;

 RETURN  v_val;
 
 END;
 
 
  FUNCTION FIRST_DAY_OF_YEAR(v_date DATE) RETURN DATE IS
  
  BEGIN
    RETURN TRUNC( v_date,'YYYY');
  END; 
  
  
  function  get_ri_amount ( p_amt_type VARCHAR , p_ri_policy_no VARCHAR, p_ri_quotation_id VARCHAR , p_reinsurer_code VARCHAR,   p_date  date ) return Number  is
v_ri_amount  NUMBER ;
begin


            IF P_AMT_TYPE ='SA' THEN

                    SELECT  SUM(N_SA_CHANGE)
                    INTO  v_ri_amount
                    FROM RIDT_TREATY_LISTING RI_LST
                    WHERE RI_LST.V_RI_POLICY_NO=P_RI_POLICY_NO
                    AND RI_LST.V_RI_QUOTATION_ID =P_RI_QUOTATION_ID
                    AND RI_LST.V_REINSURER_CODE = P_REINSURER_CODE
                     AND nvl(RI_LST.V_LIST_TYPE,'xyasyd') <> 'F' 
                    AND TRUNC(D_POSTED)=  TRUNC(P_DATE);
            
            END IF; 
            
            
                IF P_AMT_TYPE ='PREM' THEN

                    SELECT  SUM(N_PREM_CHANGE)
                    INTO  v_ri_amount
                    FROM RIDT_TREATY_LISTING RI_LST
                    WHERE RI_LST.V_RI_POLICY_NO=P_RI_POLICY_NO
                    AND RI_LST.V_RI_QUOTATION_ID =P_RI_QUOTATION_ID
                    AND RI_LST.V_REINSURER_CODE = P_REINSURER_CODE
                     AND nvl(RI_LST.V_LIST_TYPE,'xyasyd') <> 'F' 
                    AND TRUNC(D_POSTED)=  TRUNC(P_DATE);
            
            END IF; 
            
            
                        
                IF P_AMT_TYPE ='EM-PREM' THEN

                        SELECT   SUM(N_LOAD_DIS_PREM)   
                         INTO  v_ri_amount
                        FROM RIDT_POLICY_LOAD_DISC_DETAIL LD
                        WHERE LD.V_RI_POLICY_NO =P_RI_POLICY_NO
                         AND LD.V_RI_QUOTATION_ID = P_RI_QUOTATION_ID;
            
            END IF; 
            
            
            
            
             IF P_AMT_TYPE ='F-SA' THEN

                    SELECT  SUM(N_SA_CHANGE)
                    INTO  v_ri_amount
                    FROM RIDT_TREATY_LISTING RI_LST
                    WHERE RI_LST.V_RI_POLICY_NO=P_RI_POLICY_NO
                    AND RI_LST.V_RI_QUOTATION_ID =P_RI_QUOTATION_ID
                    AND RI_LST.V_REINSURER_CODE = P_REINSURER_CODE
                     AND nvl(RI_LST.V_LIST_TYPE,'xyasyd') = 'F' 
                    AND TRUNC(D_POSTED)=  TRUNC(P_DATE);
            
            END IF; 
            
            
                IF P_AMT_TYPE ='F-PREM' THEN

                    SELECT  SUM(N_PREM_CHANGE)
                    INTO  v_ri_amount
                    FROM RIDT_TREATY_LISTING RI_LST
                    WHERE RI_LST.V_RI_POLICY_NO=P_RI_POLICY_NO
                    AND RI_LST.V_RI_QUOTATION_ID =P_RI_QUOTATION_ID
                    AND RI_LST.V_REINSURER_CODE = P_REINSURER_CODE
                     AND nvl(RI_LST.V_LIST_TYPE,'xyasyd') = 'F' 
                    AND TRUNC(D_POSTED)=  TRUNC(P_DATE);
            
            END IF; 
            
            
                        
                IF P_AMT_TYPE ='F-EM-PREM' THEN

                        SELECT   SUM(N_LOAD_DIS_PREM)   
                         INTO  v_ri_amount
                        FROM RIDT_POLICY_LOAD_DISC_DETAIL LD
                        WHERE LD.V_RI_POLICY_NO =P_RI_POLICY_NO
                         AND LD.V_RI_QUOTATION_ID = P_RI_QUOTATION_ID;
            
            END IF; 
            
            
            
            
            

      RETURN NVL(v_ri_amount,0);
end;



function  get_ri_load_pct (p_ri_policy_no VARCHAR, p_ri_quotation_id VARCHAR ) return Number  is
v_ri_pct  NUMBER ;
begin

                        SELECT  distinct N_LOAD_DISCOUNT_VALUE
                         INTO  v_ri_pct
                        FROM RIDT_POLICY_LOAD_DISC_DETAIL LD
                        WHERE LD.V_RI_POLICY_NO =P_RI_POLICY_NO
                         AND LD.V_RI_QUOTATION_ID = P_RI_QUOTATION_ID;

                         RETURN v_ri_pct;
end;


 PROCEDURE GENERATE_POL_AMOUNTS(v_pol_no VARCHAR) IS


CURSOR C1 IS 
SELECT SUM(N_RATE) RATE,V_PLRI_CODE 
FROM PSDT_PLAN_SURVIVAL_BREAKUP 
WHERE V_POLICY_NO =v_pol_no
AND V_PLRI_CODE NOT IN ('BJUB010',
                                   'BFP001',
                                   'BFP002',
                                   'BJUB012',
                                   'BJUB015',
                                   'BJUB018',
                                   'BMRTA20',
                                   'BMRTA15',
                                   'BMRTA10',
                                   'BMRTA05',
                                   'BMRSPREM',
                                   'BTERM01')
GROUP BY V_PLRI_CODE

UNION

SELECT N_AMT_PAYABLE *100 RATE  ,B.V_PLAN_CODE
FROM GNMM_PLAN_EVENT_LINK A, GNMT_POLICY B 
WHERE A.V_PLAN_CODE= B.V_PLAN_CODE
AND A.V_PLAN_CODE IN ('BJUB010','BFP001','BFP002','BJUB012','BJUB015','BJUB018')
AND A.V_EVENT_CODE = 'GMAT'
AND B.V_POLICY_NO =v_pol_no; 

CURSOR POLICIES IS 
SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
AND Jhl_gen_pkg.Get_maturity_month_bal2 (A.V_policy_no) = 'Y'
   AND V_grp_ind_flag = 'I'
     AND A.N_seq_no = 1
    AND C.V_plan_code NOT IN ('BJUB010',
                                   'BFP001',
                                   'BFP002',
                                   'BJUB012',
                                   'BJUB015',
                                   'BJUB018',
                                   'BMRTA20',
                                   'BMRTA15',
                                   'BMRTA10',
                                   'BMRTA05',
                                   'BMRSPREM',
                                   'BTERM01')
AND C.V_POLICY_NO  = v_pol_no

union 

SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
AND Jhl_Gen_Pkg.Get_Maturity_Month_Bal (A.v_policy_no) = 'Y'
AND Jhl_Gen_Pkg.Get_Num_Os (A.v_policy_no) = 'Y'
AND V_grp_ind_flag = 'I'
AND A.N_seq_no = 1
AND C.N_Term <= 5
AND C.V_Plan_Code IN ( 'BFP001', 'BFP002')
AND C.V_POLICY_NO  = v_pol_no


union 

SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
  AND Jhl_Gen_Pkg.Get_Maturity_Month_Bal (A.v_policy_no) = 'Y'
AND V_grp_ind_flag = 'I'
AND A.N_seq_no = 1
AND C.N_Term >5
AND C.N_Term <=10
AND C.V_Plan_Code IN ( 'BFP001', 'BFP002')
AND C.V_POLICY_NO  = v_pol_no

union 

SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
 AND Jhl_Gen_Pkg.Get_Maturity_Month_Bal3 (A.v_policy_no) = 'Y'
AND V_grp_ind_flag = 'I'
AND A.N_seq_no = 1
AND C.N_Term >5
 AND C.N_Term > 10
AND C.V_Plan_Code IN ( 'BFP001', 'BFP002')
AND C.V_POLICY_NO  = v_pol_no;


 V_RATE NUMBER := 0;
 V_PLAN VARCHAR2 (50);
 V_COMPUTED_SA  NUMBER := 0;
 V_LOAN_BAL NUMBER;
 V_LOAN_INT NUMBER;
 LN_ACTUAL_BONUS NUMBER;
 LN_INTERIM_BONUS NUMBER;
 V_DUE_APL NUMBER;
 V_DUE_APL_INT NUMBER;
 V_GROSS_CLAIMS NUMBER;
 V_CP_CALC_SA NUMBER;
 V_CP_TOTAL_BONUS  NUMBER;
  V_CP_INTERIM  NUMBER;
  V_CP_NFP_BAL NUMBER;
  V_CP_PREM_DUE  NUMBER;
  V_CP_TOTAL_DEDUCT NUMBER;
  V_CP_GROSS_CLAIM NUMBER;
  V_CP_LOAN_BAL NUMBER;
  V_CP_NET_CLAIM  NUMBER;
  N_VALUE_CSV  NUMBER  :=NULL;


  BEGIN
  
    DELETE FROM JHL_POL_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;
   
--    commit;
    OPEN C1;
    V_RATE := 0;
        FETCH C1 INTO V_RATE,V_PLAN ;
    CLOSE C1;
  
  FOR I IN POLICIES LOOP
  
          DELETE FROM JHL_POL_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;
            DELETE FROM PS_RB_CRB_TEMP_TEST WHERE V_POLICY_NO =  v_pol_no;
    V_COMPUTED_SA := I.N_IND_SA - (V_RATE/100* I.N_IND_SA);
    
    IF I.V_cntr_stat_code = 'NB014' THEN
         V_CP_CALC_SA := I.N_IND_SA     ;
    ELSE 
         V_CP_CALC_SA := NVL(V_COMPUTED_SA,I.N_IND_SA)     ;
    END IF;    
    
--  DELETE FROM PS_RB_CRB_TEMP;
  -- DELETE FROM PS_PLAN_BONUS_YEAR_TEMP;                                                                             

 BPG_POLICY_SERVICING_V2.BPC_GET_ACTUAL_INTERIM_BONUS(v_pol_no,1,NULL,NULL,'Q',TRUNC(SYSDATE)+1,'CL',NULL,1,LN_ACTUAL_BONUS,LN_INTERIM_BONUS,USER,USER,SYSDATE);
 IF V_PLAN IN ('RJSMAXE01','RJSMAXE02','RSMAXE01','RSMAXE02')THEN
  V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS/2;
  V_CP_INTERIM := LN_INTERIM_BONUS/2; 
 ELSIF
  V_PLAN IN ('RWLF001','RWLF002','RJMAXE01','RJMAXE02') THEN
  V_CP_TOTAL_BONUS := 0;
  V_CP_INTERIM := 0; 
 ELSE
     V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS;
  V_CP_INTERIM := LN_INTERIM_BONUS;
     
 END IF;  
    
 BPG_POLICY_SERVICING.BPC_GET_LOAN_DUE_DETAILS(V_POL_NO,1,SYSDATE,V_LOAN_BAL,V_LOAN_INT);
     V_CP_LOAN_BAL := V_LOAN_BAL+V_LOAN_INT;
 
 BPG_POLICY_SERVICING.BPC_GET_APL_DUE_DETAILS (V_POL_NO, 1,TRUNC(SYSDATE), V_DUE_APL, V_DUE_APL_INT);
  V_CP_NFP_BAL := V_DUE_APL+V_DUE_APL_INT;
  V_CP_PREM_DUE := BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE(V_POL_NO); 
  V_CP_TOTAL_DEDUCT :=    V_CP_LOAN_BAL + V_CP_NFP_BAL + V_CP_PREM_DUE + 2.50;
   
  V_CP_GROSS_CLAIM := (V_CP_TOTAL_BONUS + V_CP_INTERIM + V_CP_CALC_SA );
  V_CP_NET_CLAIM := V_CP_GROSS_CLAIM - V_CP_TOTAL_DEDUCT;
  BPG_CSV.BPC_CALC_PAIDUPRT_CSV(V_POL_NO,1,NULL,NULL,SYSDATE,N_VALUE_CSV);
  
  DELETE FROM JHL_POL_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;
   INSERT INTO JHL_POL_AMOUNTS(V_POLICY_NO, POL_ACTUAL_BONUS_AMT, 
   POL_INTERIM_BONUS_AMT, POL_CSV_AMOUNT, POL_LOAN_BAL, POL_LOAN_INT, 
   POL_DUE_APL_AMT, POL_DUE_APL_INT, POL_PREM_DUE, 
   POL_TOTAL_DEDUCT, POL_GROSS_CLAIM, POL_NET_CLAIM,POL_NFP_BAL,POL_TOTAL_BONUS,
   POL_DV_TYPE, POL_DATE,POL_SURR_VALUE)
   VALUES( V_POL_NO,V_CP_TOTAL_BONUS, V_CP_INTERIM, nvl(N_VALUE_CSV,0),
   V_LOAN_BAL, V_LOAN_INT,V_DUE_APL,V_DUE_APL_INT,V_CP_PREM_DUE,
   V_CP_TOTAL_DEDUCT,V_CP_GROSS_CLAIM,V_CP_NET_CLAIM,V_CP_NFP_BAL,V_CP_TOTAL_BONUS,
   'M', SYSDATE,nvl(N_VALUE_CSV,0)
   );

--       commit; 
     
END LOOP;
--raise_error('hihhihihihi');
    commit; 

END;
   
 
 function get_amt_to_words(v_amt number)
  return Char is
V_AMT_TO_WD  VARCHAR2(4000) := NULL;
begin
    V_AMT_TO_WD   := NULL;
  SELECT DECODE( ((v_amt-TRUNC(v_amt))*100),0,SPELL_NUMBER(TRUNC(v_amt)),SPELL_NUMBER(TRUNC(v_amt))||' Shillings '||SPELL_NUMBER((v_amt-TRUNC(v_amt))*100 )||' Cents ') 
  INTO V_AMT_TO_WD 
   from dual;
   
  RETURN(V_AMT_TO_WD);
  
  EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
  
end;  


 PROCEDURE GENERATE_POL_AMOUNTS_SUR(v_pol_no VARCHAR) IS

CURSOR POLICIES IS 
SELECT  *
FROM    GNMT_POLICY C
WHERE  C.V_POLICY_NO  = v_pol_no ; 




 V_RATE NUMBER := 0;
 V_PLAN VARCHAR2 (50);
 V_COMPUTED_SA  NUMBER := 0;
 V_LOAN_BAL NUMBER;
 V_LOAN_INT NUMBER;
 LN_ACTUAL_BONUS NUMBER;
 LN_INTERIM_BONUS NUMBER;
 V_DUE_APL NUMBER;
 V_DUE_APL_INT NUMBER;
 V_GROSS_CLAIMS NUMBER;
 V_CP_CALC_SA NUMBER;
 V_CP_TOTAL_BONUS  NUMBER;
  V_CP_INTERIM  NUMBER;
  V_CP_NFP_BAL NUMBER;
  V_CP_PREM_DUE  NUMBER;
  V_CP_TOTAL_DEDUCT NUMBER;
  V_CP_GROSS_CLAIM NUMBER;
  V_CP_LOAN_BAL NUMBER;
  V_CP_NET_CLAIM  NUMBER;
  N_VALUE_CSV  NUMBER  :=NULL;


  BEGIN
  
    DELETE FROM JHL_POL_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;

  
  FOR I IN POLICIES LOOP

 BPG_POLICY_SERVICING.BPC_GET_LOAN_DUE_DETAILS(V_POL_NO,1,SYSDATE,V_LOAN_BAL,V_LOAN_INT);
     V_CP_LOAN_BAL := V_LOAN_BAL+V_LOAN_INT;

-- BPG_POLICY_SERVICING_V2.BPC_GET_ACTUAL_INTERIM_BONUS(v_pol_no,1,NULL,NULL,'Q',TRUNC(SYSDATE)+1,'CL',NULL,1,LN_ACTUAL_BONUS,LN_INTERIM_BONUS,USER,USER,SYSDATE);
  Bpg_policy_servicing_v2.Bpc_Get_Actual_Interim_Bonus(v_pol_no,NULL,null,null,'P',sysdate,'NB010', null, null,LN_ACTUAL_BONUS, LN_INTERIM_BONUS, user, user, sysdate);
  V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS +LN_INTERIM_BONUS;
  V_CP_INTERIM := LN_INTERIM_BONUS;
 
    

 
 BPG_POLICY_SERVICING.BPC_GET_APL_DUE_DETAILS (V_POL_NO, 1,TRUNC(SYSDATE), V_DUE_APL, V_DUE_APL_INT);
  V_CP_NFP_BAL := V_DUE_APL+V_DUE_APL_INT;
  V_CP_PREM_DUE := BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE(V_POL_NO); 
  V_CP_TOTAL_DEDUCT :=    V_CP_LOAN_BAL + V_CP_NFP_BAL + V_CP_PREM_DUE + 2.50;
   
  V_CP_GROSS_CLAIM := (V_CP_TOTAL_BONUS + V_CP_INTERIM + V_CP_CALC_SA );
  V_CP_NET_CLAIM := V_CP_GROSS_CLAIM - V_CP_TOTAL_DEDUCT;
  BPG_CSV.BPC_CALC_PAIDUPRT_CSV(V_POL_NO,1,NULL,NULL,SYSDATE,N_VALUE_CSV);
  
   INSERT INTO JHL_POL_AMOUNTS(V_POLICY_NO, POL_ACTUAL_BONUS_AMT, 
   POL_INTERIM_BONUS_AMT, POL_CSV_AMOUNT, POL_LOAN_BAL, POL_LOAN_INT, 
   POL_DUE_APL_AMT, POL_DUE_APL_INT, POL_PREM_DUE, 
   POL_TOTAL_DEDUCT, POL_GROSS_CLAIM, POL_NET_CLAIM,POL_NFP_BAL,POL_TOTAL_BONUS,
   POL_DV_TYPE, POL_DATE,POL_SURR_VALUE)
   VALUES( V_POL_NO,V_CP_TOTAL_BONUS, V_CP_INTERIM, N_VALUE_CSV,
   V_LOAN_BAL, V_LOAN_INT,V_DUE_APL,V_DUE_APL_INT,V_CP_PREM_DUE,
   V_CP_TOTAL_DEDUCT,V_CP_GROSS_CLAIM,V_CP_NET_CLAIM,V_CP_NFP_BAL,V_CP_TOTAL_BONUS,
   'T', SYSDATE,NVL(N_VALUE_CSV,0)
   );

--       commit; 
     
END LOOP;
--raise_error('hihhihihihi');
    commit; 

END;




      



    
END JHL_GEN_PKG;

/