PROCEDURE CREATE_CORPORATE_SUPPLIER (
    COMPANY_CODE      VARCHAR,
    COMPANY_BRANCH    VARCHAR,
    V_AGENT_NO        NUMBER DEFAULT NULL)
IS
    CURSOR SUPPLIERS
    IS
    SELECT C.V_COMPANY_NAME VENDOR_NAME,
           DECODE (C.V_COMP_STAT, 'A', 'Y', 'N') ENABLED_FLAG,
           'VENDOR' TYPE_OF_SUPPLIER,
           'Immediate' TERMS_NAME,
           'ISF-CORPORATE' PAY_GROUP,
           99 PAY_PRIORITY,
           'UGX' INVOICE_CURRENCY,
           'UGX' PAYMENT_CURRENCY,
           'N' HOLD_FLAG,
           'INVOICE' TERMS_DATE_BASIS,
           'N' INSPEC_REQ_FLAG,
           'N' RCPT_REQUIRED_FLAG,
           'R' MATCH_OPTION,
           'CHECK' PAYM_METHOD_CODE,
           'XUGL' || C.V_COMPANY_CODE || 'C' LEGACY_REF1,
           NULL LEGACY_REF2,
           C.V_LASTUPD_USER LEGACY_REF3,
           TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF4,
           C.V_LASTUPD_USER LEGACY_REF5,
           TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF6,
           NULL LEGACY_REF7,
           'Uganda' LEGACY_REF9,
           '11' LEGACY_REF11,
           SYSDATE LAST_UPDATE_DATE,
           C.V_COMPANY_CODE,
           C.V_COMPANY_BRANCH
    FROM GNMM_COMPANY_MASTER C
    WHERE C.V_COMPANY_CODE = COMPANY_CODE
      AND C.V_COMPANY_BRANCH = COMPANY_BRANCH;

    CURSOR SUPPLIER_SITE (
        V_COMPANYCODE      VARCHAR,
        V_COMPANYBRANCH    VARCHAR)
    IS
    SELECT P.V_POLICY_NO VENDOR_SITE_CODE,
           'N' PURCHASIN_SITE_FLAG,
           'N' RFQ_ONLY_SITE_FLAG,
           'Y' PAY_SITE_FLAG,
           NULL ATTENTION_AR_FLAG,
           NVL (
                   (SELECT G.V_POST_BOX
                    FROM GNDT_COMPANY_ADDRESS G
                    WHERE G.V_COMPANY_CODE = C.V_COMPANY_CODE
                      AND G.V_COMPANY_BRANCH = C.V_COMPANY_BRANCH),
                   'KAMPALA') ADDRESS_LINE1,
           NVL (
                   (SELECT G.V_TOWN
                    FROM GNDT_COMPANY_ADDRESS G
                    WHERE G.V_COMPANY_CODE = C.V_COMPANY_CODE
                      AND G.V_COMPANY_BRANCH = C.V_COMPANY_BRANCH),
                   'KAMPALA') CITY,
           'UGANDA' STATE,
           '+256' ZIP,
           NULL PROVINCE,
           'UG' COUNTRY,
           'INVOICE' TERMS_DATE_BASIS,
           'ISF-CORPORATE' PAY_GRP_LKP_CODE,
           'IMMEDIATE' TERMS_NAME,
           'UGX' INV_CURR_CODE,
           'UGX' PYMT_CURR_CODE,
           'JHL_UG_LIF_OU' OPERATING_UNIT,
           'R' MATCH_OPTION,
           'CHECK' PAYMENT_METHOD_CODE,
           '152037' PREPAYMENT_ACCOUNT_ID,
           '202301' LIABILITY_ACCOUNT,
           'XUGL' || C.V_COMPANY_CODE || 'C' LEGACY_REF1,
           TO_CHAR (C.V_COMPANY_CODE || '-' || C.V_COMPANY_BRANCH) LEGACY_REF2,
           P.V_POLICY_NO LEGACY_REF3,
           P.V_LASTUPD_USER LEGACY_REF4,
           TO_DATE (NVL (D_CREATED_DATE, P.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF5,
           P.V_LASTUPD_USER LEGACY_REF6,
           TO_DATE (NVL (D_CREATED_DATE, P.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF7,
           '210' LEGACY_REF8,
           '11' LEGACY_REF9,
           '11' LEGACY_REF10,
           C.V_COMPANY_CODE,
           C.V_COMPANY_BRANCH
    FROM GNMT_POLICY P,
         GNMM_COMPANY_MASTER C,
         GNMM_POLICY_STATUS_MASTER STATUS,
         GNLU_INSTITUTION_TYPE INS,
         GNLU_PAY_METHOD PM
    WHERE P.V_COMPANY_CODE = C.V_COMPANY_CODE
      AND P.V_COMPANY_BRANCH = C.V_COMPANY_BRANCH
      AND P.V_CNTR_STAT_CODE = STATUS.V_STATUS_CODE
      AND C.V_INST_TYPE = INS.V_INST_TYPE
      AND P.V_PMT_METHOD_CODE = PM.V_PMT_METHOD_CODE
      AND C.V_COMPANY_CODE = V_COMPANYCODE
      AND C.V_COMPANY_BRANCH = V_COMPANYBRANCH
    UNION
    SELECT SUBSTR (TO_CHAR (C.V_COMPANY_CODE || '-' || C.V_COMPANY_BRANCH), 1, 15) VENDOR_SITE_CODE,
           'N' PURCHASIN_SITE_FLAG,
           'N' RFQ_ONLY_SITE_FLAG,
           'Y' PAY_SITE_FLAG,
           NULL ATTENTION_AR_FLAG,
           NVL (
                   (SELECT G.V_POST_BOX
                    FROM GNDT_COMPANY_ADDRESS G
                    WHERE G.V_COMPANY_CODE = AGN.V_COMPANY_CODE
                      AND G.V_COMPANY_BRANCH = AGN.V_COMPANY_BRANCH),
                   'KAMPALA') ADDRESS_LINE1,
           NVL (
                   (SELECT G.V_TOWN
                    FROM GNDT_COMPANY_ADDRESS G
                    WHERE G.V_COMPANY_CODE = AGN.V_COMPANY_CODE
                      AND G.V_COMPANY_BRANCH = AGN.V_COMPANY_BRANCH),
                   'KAMPALA') CITY,
           'UGANDA' STATE,
           '+256' ZIP,
           NULL PROVINCE,
           'UG' COUNTRY,
           'INVOICE' TERMS_DATE_BASIS,
           'ISF-CORPORATE' PAY_GRP_LKP_CODE,
           'IMMEDIATE' TERMS_NAME,
           'UGX' INV_CURR_CODE,
           'UGX' PYMT_CURR_CODE,
           'JHL_UG_LIF_OU' OPERATING_UNIT,
           'R' MATCH_OPTION,
           'CHECK' PAYMENT_METHOD_CODE,
           '152121' PREPAYMENT_ACCOUNT_ID,
           '202351' LIABILITY_ACCOUNT,
           'XUGL' || AGN.V_COMPANY_CODE || 'C' LEGACY_REF1,
           TO_CHAR (TO_CHAR (C.V_COMPANY_CODE || '-' || C.V_COMPANY_BRANCH)) LEGACY_REF2,
           TO_CHAR (NULL) LEGACY_REF3,
           C.V_LASTUPD_USER LEGACY_REF4,
           TO_DATE (NVL (C.V_LASTUPD_INFTIM, C.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF5,
           C.V_LASTUPD_USER LEGACY_REF6,
           TO_DATE (NVL (C.V_LASTUPD_INFTIM, C.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF7,
           '210' LEGACY_REF8,
           '12' LEGACY_REF9,
           '11' LEGACY_REF10,
           AGN.V_COMPANY_CODE,
           AGN.V_COMPANY_BRANCH
    FROM GNMM_COMPANY_MASTER C,
         AMMM_AGENT_MASTER AGN,
         GNLU_INSTITUTION_TYPE INS
    WHERE C.V_COMPANY_CODE = AGN.V_COMPANY_CODE
      AND C.V_COMPANY_BRANCH = AGN.V_COMPANY_BRANCH
      AND C.V_INST_TYPE = INS.V_INST_TYPE
      AND AGN.V_COMPANY_CODE = V_COMPANYCODE
      AND AGN.V_COMPANY_BRANCH = V_COMPANYBRANCH
      AND AGN.N_AGENT_NO = NVL (V_AGENT_NO, AGN.N_AGENT_NO)
    UNION
    SELECT SUBSTR (TO_CHAR (C.V_COMPANY_CODE || '-' || C.V_COMPANY_BRANCH), 1, 15) VENDOR_SITE_CODE,
           'N' PURCHASIN_SITE_FLAG,
           'N' RFQ_ONLY_SITE_FLAG,
           'Y' PAY_SITE_FLAG,
           NULL ATTENTION_AR_FLAG,
           NVL (
                   (SELECT G.V_POST_BOX
                    FROM GNDT_COMPANY_ADDRESS G
                    WHERE G.V_COMPANY_CODE = C.V_COMPANY_CODE
                      AND G.V_COMPANY_BRANCH = C.V_COMPANY_BRANCH),
                   'KAMPALA') ADDRESS_LINE1,
           NVL (
                   (SELECT G.V_TOWN
                    FROM GNDT_COMPANY_ADDRESS G
                    WHERE G.V_COMPANY_CODE = C.V_COMPANY_CODE
                      AND G.V_COMPANY_BRANCH = C.V_COMPANY_BRANCH),
                   'KAMPALA') CITY,
           'UGANDA' STATE,
           '+256' ZIP,
           NULL PROVINCE,
           'UG' COUNTRY,
           'INVOICE' TERMS_DATE_BASIS,
           'ISF-CORPORATE' PAY_GRP_LKP_CODE,
           'IMMEDIATE' TERMS_NAME,
           'UGX' INV_CURR_CODE,
           'UGX' PYMT_CURR_CODE,
           'JHL_UG_LIF_OU' OPERATING_UNIT,
           'R' MATCH_OPTION,
           'CHECK' PAYMENT_METHOD CODE,
           '152037' PREPAYMENT_ACCOUNT_ID,
           '202301' LIABILITY_ACCOUNT,
           'XUGL' || C.V_COMPANY_CODE || 'C' LEGACY_REF1,
           TO_CHAR (C.V_COMPANY_CODE || '-' || C.V_COMPANY_BRANCH) LEGACY_REF2,
           NULL LEGACY_REF3,
           C.V_LASTUPD_USER LEGACY_REF4,
           TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF5,
           C.V_LASTUPD_USER LEGACY_REF6,
           TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM), 'DD-MM-RRRR') LEGACY_REF7,
           '210' LEGACY_REF8,
           '11' LEGACY_REF9,
           '11' LEGACY_REF10,
           C.V_COMPANY_CODE,
           C.V_COMPANY_BRANCH
    FROM GNMM_COMPANY_MASTER C
    WHERE 1 = 1
      AND C.V_COMPANY_CODE = V_COMPANYCODE
      AND C.V_COMPANY_BRANCH = V_COMPANYBRANCH
      AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
          (SELECT AGN.V_COMPANY_CODE, AGN.V_COMPANY_BRANCH
           FROM AMMM_AGENT_MASTER AGN
           WHERE AGN.V_COMPANY_CODE IS NOT NULL)
      AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
          (SELECT P.V_COMPANY_CODE, P.V_COMPANY_BRANCH
           FROM GNMT_POLICY P,
                GNMM_POLICY_STATUS_MASTER STATUS
           WHERE P.V_CNTR_STAT_CODE = STATUS.V_STATUS_CODE
             AND P.V_COMPANY_CODE IS NOT NULL);

    CURSOR SUPPLIER_CONTACT (
        V_COMPANYCODE      VARCHAR,
        V_COMPANYBRANCH    VARCHAR)
    IS
    SELECT DISTINCT
        'JHL_UG_LIF_OU' OPERATING_UNIT,
        C.V_COMPANY_NAME FIRST_NAME,
        '.' LAST_NAME,
        NVL (
                SUBSTR (
                        (SELECT V_CONTACT_NUMBER
                         FROM GNDT_COMPMOBILE_CONTACTS H
                         WHERE H.V_COMPANY_CODE = C.V_COMPANY_CODE
                           AND H.V_COMPANY_BRANCH = C.V_COMPANY_BRANCH
                           AND V_CONTACT_NUMBER NOT LIKE '%@%'
                           AND ROWNUM = 1),
                        1,
                        30),
                '.') PHONE,
        NVL (
                (SELECT V_CONTACT_NUMBER
                 FROM GNDT_COMPMOBILE_CONTACTS H
                 WHERE H.V_COMPANY_CODE = C.V_COMPANY_CODE
                   AND H.V_COMPANY_BRANCH = C.V_COMPANY_BRANCH
                   AND V_CONTACT_NUMBER LIKE '%@%'
                   AND ROWNUM = 1),
                '.') EMAIL_ADDRESS,
        'XUGL' || C.V_COMPANY_CODE || 'C' LEGACY_REF1
    FROM GNMM_COMPANY_MASTER C
    WHERE C.V_COMPANY_CODE = V_COMPANYCODE
      AND C.V_COMPANY_BRANCH = V_COMPANYBRANCH;

    V_SUPPLIER_COUNT        NUMBER := 0;
    V_SUPPLIER_SITE_COUNT   NUMBER := 0;
    V_PIN_COUNT             NUMBER := 0;

    V_CSP_PIN_NO            VARCHAR2 (50);
    V_SITE_COUNT            NUMBER := 0;
    V_CONTACT_COUNT         NUMBER := 0;
BEGIN
    FOR I IN SUPPLIERS
    LOOP
        BEGIN
            SELECT COUNT (*)
            INTO V_SUPPLIER_COUNT
            FROM JHL_OFA_CO_SUPPLIER
            WHERE V_COMPANY_CODE = I.V_COMPANY_CODE
              AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH;
        EXCEPTION
            WHEN OTHERS THEN
                V_SUPPLIER_COUNT := 0;
        END;

        IF V_SUPPLIER_COUNT = 0 THEN
            SELECT NVL (MAX (CSP_PIN_COUNT), 0)
            INTO V_PIN_COUNT
            FROM JHL_OFA_CO_SUPPLIER;

            V_PIN_COUNT := V_PIN_COUNT + 1;

            INSERT INTO JHL_OFA_CO_SUPPLIER (CSP_NO,
                                             V_COMPANY_CODE,
                                             V_COMPANY_BRANCH,
                                             CSP_PIN_NO,
                                             CSP_DATE,
                                             CSP_PIN_COUNT)
            VALUES (JHL_CSP_NO_SEQ.NEXTVAL,
                    I.V_COMPANY_CODE,
                    I.V_COMPANY_BRANCH,
                    'XUGL' || V_PIN_COUNT || 'C',
                    SYSDATE,
                    V_PIN_COUNT);
        END IF;

        BEGIN
            SELECT CSP_PIN_NO
            INTO V_CSP_PIN_NO
            FROM JHL_OFA_CO_SUPPLIER
            WHERE V_COMPANY_CODE = I.V_COMPANY_CODE
              AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_ERROR ('Error Getting Pin number');
        END;

        IF V_CSP_PIN_NO IS NULL THEN
            RAISE_ERROR ('Pin Number is null');
        END IF;

        BEGIN
            SELECT COUNT (*)
            INTO V_PIN_COUNT
            FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
            WHERE PAY_GROUP = 'ISF-CORPORATE'
              AND LEGACY_REF1 = V_CSP_PIN_NO;
        EXCEPTION
            WHEN OTHERS THEN
                V_PIN_COUNT := 0;
        END;

        IF V_PIN_COUNT = 0 THEN
            INSERT INTO XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM (SEQ_ID,
                                                              PROCESS_FLAG,
                                                              VENDOR_NAME,
                                                              ENABLED_FLAG,
                                                              TYPE_OF_SUPPLIER,
                                                              TERMS_NAME,
                                                              PAY_GROUP,
                                                              PAY_PRIORITY,
                                                              INVOICE_CURRENCY,
                                                              PAYMENT_CURRENCY,
                                                              HOLD_FLAG,
                                                              TERMS_DATE_BASIS,
                                                              INSPEC_REQ_FLAG,
                                                              RCPT_REQUIRED_FLAG,
                                                              MATCH_OPTION,
                                                              PAYM_METHOD_CODE,
                                                              LEGACY_REF1,
                                                              LEGACY_REF2,
                                                              LEGACY_REF3,
                                                              LEGACY_REF4,
                                                              LEGACY_REF5,
                                                              LEGACY_REF6,
                                                              LEGACY_REF7,
                                                              LEGACY_REF9,
                                                              LEGACY_REF11,
                                                              LAST_UPDATE_DATE)
            VALUES (XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM,
                    1,
                    I.VENDOR_NAME,
                    I.ENABLED_FLAG,
                    I.TYPE_OF_SUPPLIER,
                    I.TERMS_NAME,
                    I.PAY_GROUP,
                    I.PAY_PRIORITY,
                    I.INVOICE_CURRENCY,
                    I.PAYMENT_CURRENCY,
                    I.HOLD_FLAG,
                    I.TERMS_DATE_BASIS,
                    I.INSPEC_REQ_FLAG,
                    I.RCPT_REQUIRED_FLAG,
                    I.MATCH_OPTION,
                    I.PAYM_METHOD_CODE,
                    V_CSP_PIN_NO,
                    I.LEGACY_REF2,
                    I.LEGACY_REF3,
                    I.LEGACY_REF4,
                    I.LEGACY_REF5,
                    I.LEGACY_REF6,
                    I.LEGACY_REF7,
                    I.LEGACY_REF9,
                    I.LEGACY_REF11,
                    I.LAST_UPDATE_DATE);
        END IF;

        FOR J IN SUPPLIER_SITE (I.V_COMPANY_CODE, I.V_COMPANY_BRANCH)
        LOOP
            BEGIN
                SELECT COUNT (*)
                INTO V_SUPPLIER_SITE_COUNT
                FROM JHL_OFA_CO_SUPPLIER_SITE
                WHERE V_COMPANY_CODE = I.V_COMPANY_CODE
                  AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH
                  AND NVL (V_POLICY_NO, 'XXXXX') = NVL (J.LEGACY_REF3, 'XXXXX');
            EXCEPTION
                WHEN OTHERS THEN
                    V_SUPPLIER_SITE_COUNT := 0;
            END;

            BEGIN
                SELECT COUNT (*)
                INTO V_SITE_COUNT
                FROM APPS.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM
                WHERE LOB_NAME IN ('JHL_UG_LIF_OU')
                  AND PIN_NO = V_CSP_PIN_NO
                  AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE;
            EXCEPTION
                WHEN OTHERS THEN
                    V_SITE_COUNT := 0;
            END;

            IF V_SITE_COUNT = 0 THEN
                BEGIN
                    SELECT COUNT (*)
                    INTO V_SITE_COUNT
                    FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
                    WHERE PAY_GRP_LKP_CODE = 'ISF-CORPORATE'
                      AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE
                      AND LEGACY_REF1 = V_CSP_PIN_NO
                      AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
                EXCEPTION
                    WHEN OTHERS THEN
                        V_SITE_COUNT := 0;
                END;
            END IF;

            IF V_SUPPLIER_SITE_COUNT = 0 THEN
                INSERT INTO JHL_OFA_CO_SUPPLIER_SITE (CSPS_NO,
                                                      V_COMPANY_CODE,
                                                      V_COMPANY_BRANCH,
                                                      V_POLICY_NO,
                                                      CSPS_DATE)
                VALUES (JHL_CSPS_NO_SEQ.NEXTVAL,
                        I.V_COMPANY_CODE,
                        I.V_COMPANY_BRANCH,
                        J.LEGACY_REF3,
                        SYSDATE);
            END IF;

            IF V_SITE_COUNT = 0 THEN
                INSERT INTO XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM (SEQ_ID,
                                                                       PROCESS_FLAG,
                                                                       VENDOR_SITE_CODE,
                                                                       PURCHASIN_SITE_FLAG,
                                                                       RFQ_ONLY_SITE_FLAG,
                                                                       PAY_SITE_FLAG,
                                                                       ADDRESS_LINE1,
                                                                       CITY,
                                                                       STATE,
                                                                       ZIP,
                                                                       COUNTRY,
                                                                       TERMS_DATE_BASIS,
                                                                       PAY_GRP_LKP_CODE,
                                                                       TERMS_NAME,
                                                                       INV_CURR_CODE,
                                                                       PYMT_CURR_CODE,
                                                                       OPERATING_UNIT,
                                                                       MATCH_OPTION,
                                                                       PAYMENT_METHOD_CODE,
                                                                       PREPAYMENT_ACCOUNT,
                                                                       PREPAYMENT_ACCOUNT_ID,
                                                                       LIABILITY_ACCOUNT,
                                                                       LEGACY_REF1,
                                                                       LEGACY_REF2,
                                                                       LEGACY_REF3,
                                                                       LEGACY_REF4,
                                                                       LEGACY_REF5,
                                                                       LEGACY_REF6,
                                                                       LEGACY_REF7,
                                                                       LEGACY_REF8,
                                                                       LEGACY_REF9,
                                                                       LEGACY_REF10)
                VALUES (XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM,
                        1,
                        J.VENDOR_SITE_CODE,
                        J.PURCHASIN_SITE_FLAG,
                        J.RFQ_ONLY_SITE_FLAG,
                        J.PAY_SITE_FLAG,
                        J.ADDRESS_LINE1,
                        J.CITY,
                        J.STATE,
                        J.ZIP,
                        J.COUNTRY,
                        J.TERMS_DATE_BASIS,
                        J.PAY_GRP_LKP_CODE,
                        J.TERMS_NAME,
                        J.INV_CURR_CODE,
                        J.PYMT_CURR_CODE,
                        J.OPERATING_UNIT,
                        J.MATCH_OPTION,
                        J.PAYMENT_METHOD_CODE,
                        J.PREPAYMENT_ACCOUNT,
                        J.PREPAYMENT_ACCOUNT_ID,
                        J.LIABILITY_ACCOUNT,
                        V_CSP_PIN_NO,
                        J.LEGACY_REF2,
                        J.LEGACY_REF3,
                        J.LEGACY_REF4,
                        J.LEGACY_REF5,
                        J.LEGACY_REF6,
                        J.LEGACY_REF7,
                        J.LEGACY_REF8,
                        J.LEGACY_REF9,
                        J.LEGACY_REF10);
            END IF;
        END LOOP;

        FOR K IN SUPPLIER_CONTACT (I.V_COMPANY_CODE, I.V_COMPANY_BRANCH)
        LOOP
            BEGIN
                SELECT COUNT (*)
                INTO V_CONTACT_COUNT
                FROM APPS.XXJIC_AP_SUPPLIER_CONTACT_MAP@JICOFPROD.COM
                WHERE LOB_NAME IN ('JHL_UG_LIF_OU')
                  AND PIN_NO = V_CSP_PIN_NO;
            EXCEPTION
                WHEN OTHERS THEN
                    V_CONTACT_COUNT := 0;
            END;

            IF V_CONTACT_COUNT = 0 THEN
                INSERT INTO XXJICUG_AP_SUPPLIER_CONTACT_STG@JICOFPROD.COM (SEQ_ID,
                                                                          PROCESS_FLAG,
                                                                          OPERATING_UNIT,
                                                                          FIRST_NAME,
                                                                          LAST_NAME,
                                                                          PHONE,
                                                                          EMAIL_ADDRESS,
                                                                          LEGACY_REF1)
                VALUES (XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM,
                        1,
                        K.OPERATING_UNIT,
                        K.FIRST_NAME,
                        K.LAST_NAME,
                        K.PHONE,
                        K.EMAIL_ADDRESS,
                        V_CSP_PIN_NO);
            END IF;
        END LOOP;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_ERROR (SQLERRM);
END CREATE_CORPORATE_SUPPLIER;
