CREATE OR REPLACE PACKAGE BODY JHLISFUADM.JHL_OFA_UTILS
AS
   PROCEDURE raise_error (v_msg IN VARCHAR2, v_err_no IN NUMBER := NULL)
   IS
   BEGIN
      IF v_err_no IS NULL
      THEN
         raise_application_error (
            -20015,
            v_msg || ' - ' || SUBSTR (SQLERRM (SQLCODE), 10));
      ELSE
         raise_application_error (
            v_err_no,
            v_msg || ' - ' || SUBSTR (SQLERRM (SQLCODE), 10));
      END IF;
   END raise_error;



   PROCEDURE JHL_OFA_GL_VOUCHERS_NEW (v_voucher_no VARCHAR2)
   IS
      CURSOR VOUCHERS
      IS
           SELECT 'Isf-Life' SOURCE_SYSTEM,
                  LEGACY_SUPPLIER_CODE,
                  'JHL_UG_LIF_OU' OPERATING_UNIT,
                  'JHL_UG_LIF_LE' LEGAL_ENTITY_NAME,
                  V_VOU_NO VOUCHER_NUM,
                  V_VOU_NO INVOICE_NUM,
                  'STANDARD' INVOICE_TYPE,
                  TO_DATE (V_VOU_DATE, 'DD-MM-RRRR') INVOICE_DATE,
                  VENDOR_NAME,
                  VENDOR_SITE_CODE,
                  INVOICE_AMOUNT,
                  INVOICE_CURRENCY_CODE INVOICE_CURRENCY,
                  'USER' EXCHANGE_RATE_TYPE,
                  TO_DATE (V_VOU_DATE, 'DD-MM-RRRR') EXCHANGE_DATE,
                  'IMMEDIATE' TERMS_NAME,
                  TO_DATE (V_VOU_DATE, 'DD-MM-RRRR') TERMS_DATE,
                  DESCRIPTION,
                  'CHECK' PAYMENT_METHOD_CODE,
                  PAY_GROUP_LOOKUP_CODE,
                  'ISF' SOURCE,
                  --TO_DATE(V_VOU_DATE ,'DD-MM-RRRR') GL_DATE,

                  CASE
                     WHEN ROUND (TRUNC (SYSDATE) - TRUNC (V_VOU_DATE)) <= 30
                     THEN
                        V_VOU_DATE
                     ELSE
                        TO_DATE (SYSDATE, 'DD-MM-RRRR')
                  END
                     GL_DATE,
                  LIABILITY_ACCOUNT,
                  LINE_NUMBER,
                  'Item' LINETYPE,
                  LINE_AMOUNT,
                  LEGACY_REF1,
                  N_CUST_REF_NO LEGACY_REF2,
                  LEGACY_REF3,
                  'JHLUPROD' LEGACY_REF4,
                  TO_DATE (V_VOU_DATE, 'DD-MM-RRRR') LEGACY_REF5,
                  'JHLUPROD' LEGACY_REF6,
                  TO_DATE (V_VOU_DATE, 'DD-MM-RRRR') LEGACY_REF7,
                  '210' LEGACY_REF8,
                  NVL (OPT_CHANNEL_CODE, '11') LEGACY_REF9,
                  NVL (OPT_PRODUCT_CODE, '12') LEGACY_REF10,
                  10 || V_VOU_NO SEQ_ID,
                  1 PROCESS_FLAG,
                  11 CREATED_BY,
                  V_VOU_DATE CREATION_DATE,
                  V_VOU_DATE LAST_UPDATE_DATE,
                  V_MAIN_VOU_NO,
                  V_VOU_NO,
                  TO_CHAR (N_CUST_REF_NO) VENDOR_NUM,
                  EXCHANGE_RATE,
                  LEGACY_REF11,
                  VERIFIED_BY LEGACY_REF12,
                  VERIFIED_DT LEGACY_REF13,
                  APPROVED_BY LEGACY_REF14,
                  APPROVED_DT LEGACY_REF15
             FROM JHL_OFA_PYMT_TRANSACTIONS
            WHERE OPT_PROCESSED = 'N' AND V_VOU_NO = v_voucher_no
         ORDER BY LINE_NUMBER;
   BEGIN
      INSERT INTO JHL_OFA_PYMT_VOUCHER_DTLS (OPV_NO,
                                             V_VOU_NO,
                                             OPV_DATE,
                                             OPV_USER)
           VALUES (OPV_NO_SEQ.NEXTVAL,
                   v_voucher_no,
                   SYSDATE,
                   'JHLISFUADM');

      FOR I IN VOUCHERS
      LOOP
         --            -- insert into a temp table to show its processed.
         --            INSERT INTO JHL_OFA_PYMT_VOUCHER_DTLS
         --                   (OPV_NO, V_MAIN_VOU_NO, V_VOU_NO, OPV_DATE, OPV_USER)
         --            VALUES(OPV_NO_SEQ.NEXTVAL,I.V_MAIN_VOU_NO,I.V_VOU_NO,SYSDATE,'DMWIRIGI');

         ---INSERT INTO ORACLE STAGING TABLE
         --            XXJICUG_AP_INVOICES_STG
         INSERT
           INTO XXJICUG_AP_INVOICES_STG@JICOFPROD.COM (SEQ_ID,
                                                       PROCESS_FLAG,
                                                       SOURCE_SYSTEM,
                                                       LEGACY_SUPPLIER_CODE,
                                                       OPERATING_UNIT,
                                                       LEGAL_ENTITY_NAME,
                                                       VOUCHER_NUM,
                                                       INVOICE_NUM,
                                                       INVOICE_TYPE,
                                                       INVOICE_DATE,
                                                       VENDOR_NUM,
                                                       VENDOR_NAME,
                                                       VENDOR_SITE_CODE,
                                                       INVOICE_AMOUNT,
                                                       INVOICE_CURRENCY,
                                                       EXCHANGE_RATE_TYPE,
                                                       EXCHANGE_DATE,
                                                       TERMS_NAME,
                                                       TERMS_DATE,
                                                       DESCRIPTION,
                                                       PAYMENT_METHOD_CODE,
                                                       PAY_GROUP_LOOKUP_CODE,
                                                       SOURCE,
                                                       GL_DATE,
                                                       LIABILITY_ACCOUNT,
                                                       LINE_NUMBER,
                                                       LINETYPE,
                                                       LINE_AMOUNT,
                                                       LEGACY_REF1,
                                                       LEGACY_REF2,
                                                       LEGACY_REF3,
                                                       LEGACY_REF4,
                                                       LEGACY_REF5,
                                                       LEGACY_REF6,
                                                       LEGACY_REF7,
                                                       LEGACY_REF8,
                                                       LEGACY_REF9,
                                                       LEGACY_REF10,
                                                       CREATED_BY,
                                                       CREATION_DATE,
                                                       LAST_UPDATE_DATE,
                                                       EXCHANGE_RATE,
                                                       LEGACY_REF11,
                                                       LEGACY_REF12,
                                                       LEGACY_REF13,
                                                       LEGACY_REF14,
                                                       LEGACY_REF15)
         VALUES (XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM,
                 1,
                 I.SOURCE_SYSTEM,
                 I.LEGACY_SUPPLIER_CODE,
                 I.OPERATING_UNIT,
                 I.LEGAL_ENTITY_NAME,
                 I.VOUCHER_NUM,
                 I.INVOICE_NUM,
                 I.INVOICE_TYPE,
                 I.INVOICE_DATE,
                 I.VENDOR_NUM,
                 I.VENDOR_NAME,
                 I.VENDOR_SITE_CODE,
                 I.INVOICE_AMOUNT,
                 I.INVOICE_CURRENCY,
                 I.EXCHANGE_RATE_TYPE,
                 I.EXCHANGE_DATE,
                 I.TERMS_NAME,
                 I.TERMS_DATE,
                 I.DESCRIPTION,
                 I.PAYMENT_METHOD_CODE,
                 I.PAY_GROUP_LOOKUP_CODE,
                 I.SOURCE,
                 I.GL_DATE,
                 I.LIABILITY_ACCOUNT,
                 I.LINE_NUMBER,
                 I.LINETYPE,
                 I.LINE_AMOUNT,
                 I.LEGACY_REF1,
                 I.LEGACY_REF2,
                 I.LEGACY_REF3,
                 I.LEGACY_REF4,
                 I.LEGACY_REF5,
                 I.LEGACY_REF6,
                 I.LEGACY_REF7,
                 I.LEGACY_REF8,
                 I.LEGACY_REF9,
                 I.LEGACY_REF10,
                 I.CREATED_BY,
                 I.CREATION_DATE,
                 I.LAST_UPDATE_DATE,
                 I.EXCHANGE_RATE,
                 I.LEGACY_REF11,
                 I.LEGACY_REF12,
                 I.LEGACY_REF13,
                 I.LEGACY_REF14,
                 I.LEGACY_REF15);
      END LOOP;

      UPDATE JHL_OFA_PYMT_TRANSACTIONS
         SET OPT_PROCESSED = 'Y'
       WHERE V_VOU_NO = v_voucher_no;

      COMMIT;
   END;



   PROCEDURE CREATE_INDIVIDUAL_SUPPLIER (
      v_cust_ref_no    NUMBER,
      v_agent_no       NUMBER DEFAULT NULL)
   IS
      CURSOR SUPPLIERS
      IS
         SELECT C.V_NAME VENDOR_NAME,
                DECODE (C.V_STATUS, 'A', 'Y', 'N') ENABLED_FLAG,
                'VENDOR' TYPE_OF_SUPPLIER,
                'Immediate' TERMS_NAME,
                'ISF-INDIVIDUAL-CLAIM' PAY_GROUP,
                99 PAY_PRIORITY,
                'UGX' INVOICE_CURRENCY,
                'UGX' PAYMENT_CURRENCY,
                'N' HOLD_FLAG,
                'INVOICE' TERMS_DATE_BASIS,
                'N' INSPEC_REQ_FLAG,
                'N' RCPT_REQUIRED_FLAG,
                'R' MATCH_OPTION,
                'CHECK' PAYM_METHOD_CODE,
                DECODE (
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'),
                   '.', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   '-', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'))
                   LEGACY_REF1,
                REPLACE (
                   TRIM (
                      (SELECT V_IDEN_NO
                         FROM GNDT_CUSTOMER_IDENTIFICATION
                        WHERE     V_IDEN_CODE = 'NIC'
                              AND N_CUST_REF_NO = C.N_CUST_REF_NO
                              AND ROWNUM = 1)),
                   ' ',
                   '')
                   LEGACY_REF2,
                C.V_LASTUPD_USER LEGACY_REF3,
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF4,
                C.V_LASTUPD_USER LEGACY_REF5,
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF6,
                TO_DATE (D_BIRTH_DATE, 'DD-MM-RRRR') LEGACY_REF7,
                'Uganda' LEGACY_REF9,
                '11' LEGACY_REF11,
                SYSDATE LAST_UPDATE_DATE,
                N_CUST_REF_NO
           FROM GNMT_CUSTOMER_MASTER C
          --WHERE C.N_CUST_REF_NO IN (SELECT N_PAYER_REF_NO FROM GNMT_POLICY WHERE V_CNTR_STAT_CODE = 'NB010')
          WHERE N_CUST_REF_NO = v_cust_ref_no;


      CURSOR SUPPLIERS_SITE (
         v_cust_ref_no NUMBER)
      IS
         SELECT P.V_POLICY_NO VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = P.N_PAYER_REF_NO AND ROWNUM = 1),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = P.N_PAYER_REF_NO AND ROWNUM = 1),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'ISF-INDIVIDUAL-CLAIM' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152037' PREPAYMENT_ACCOUNT_ID,
                '202301' LIABILITY_ACCOUNT,
                DECODE (
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'),
                   '.', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   '-', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'))
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2,
                P.V_POLICY_NO LEGACY_REF3,
                p.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                p.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '11' LEGACY_REF9,
                '12' LEGACY_REF10
           FROM GNMT_POLICY P, GNMT_CUSTOMER_MASTER C, GNLU_PAY_METHOD PM
          WHERE     P.N_PAYER_REF_NO = C.N_CUST_REF_NO
                AND P.V_PMT_METHOD_CODE = PM.V_PMT_METHOD_CODE
                --AND V_CNTR_STAT_CODE = 'NB010'
                AND C.N_CUST_REF_NO = v_cust_ref_no
         UNION
         SELECT TO_CHAR ('PYR-' || C.N_CUST_REF_NO) VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'ISF-INDIVIDUAL-CLAIM' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152121' PREPAYMENT_ACCOUNT_ID,
                '202351' LIABILITY_ACCOUNT,
                DECODE (
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'),
                   '.', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   '-', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'))
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2,
                TO_CHAR (NULL) LEGACY_REF3,
                c.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                c.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '13' LEGACY_REF9,
                '12' LEGACY_REF10
           FROM Ammm_Agent_Master AGN, Gnmt_Customer_Master C
          WHERE     AGN.N_Cust_Ref_No = C.N_Cust_Ref_No
                --AND AGN.V_STATUS  'A'
                AND AGN.N_AGENT_NO = NVL (v_agent_no, AGN.N_AGENT_NO)
                AND C.N_CUST_REF_NO = v_cust_ref_no
         UNION
         SELECT TO_CHAR ('PYR-' || C.N_CUST_REF_NO) VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'ISF-INDIVIDUAL-CLAIM' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152121' PREPAYMENT_ACCOUNT_ID,
                '202351' LIABILITY_ACCOUNT,
                DECODE (
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'),
                   '.', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   '-', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'))
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2,
                TO_CHAR (NULL) LEGACY_REF3,
                c.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                c.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '13' LEGACY_REF9,
                '12' LEGACY_REF10
           FROM Gnmt_Customer_Master C
          WHERE     TO_CHAR (C.N_CUST_REF_NO) NOT IN
                       (SELECT AGN.N_CUST_REF_NO
                          FROM AMMM_AGENT_MASTER AGN
                         WHERE AGN.N_CUST_REF_NO IS NOT NULL
                        UNION ALL
                        SELECT POL.N_PAYER_REF_NO
                          FROM GNMT_POLICY POL
                         WHERE POL.N_PAYER_REF_NO IS NOT NULL)
                AND C.N_CUST_REF_NO = v_cust_ref_no;


      CURSOR SUPPLIER_CONTACT (
         v_cust_ref_no NUMBER)
      IS
         SELECT 'JHL_UG_LIF_OU' OPERATING_UNIT,
                NVL (
                   TRIM (
                      SUBSTR (TRIM (NVL (V_FIRST_NAME, C.V_NAME)),
                              1,
                              INSTR (NVL (V_FIRST_NAME, C.V_NAME), ' ') - 1)),
                   C.V_NAME)
                   FIRST_NAME,
                --NVL(V_FIRST_NAME, C.V_NAME)  FIRST_NAME,

                NVL (
                   TRIM (SUBSTR (TRIM (NVL (V_FIRST_NAME, C.V_NAME)),
                                 INSTR (TRIM (NVL (V_FIRST_NAME, C.V_NAME)),
                                        ' ',
                                        -1,
                                        1))),
                   '.')
                   LAST_NAME,
                --   NVL(V_LAST_NAME,'.')  LAST_NAME,
                NVL (
                   (SELECT V_CONTACT_NUMBER
                      FROM GNDT_CUSTMOBILE_CONTACTS
                     WHERE     N_CUST_REF_NO = C.N_CUST_REF_NO
                           AND V_STATUS = 'A'
                           AND V_Contact_Number NOT LIKE '%@%'
                           AND ROWNUM = 1),
                   '.')
                   PHONE,
                NVL (
                   (SELECT V_CONTACT_NUMBER
                      FROM GNDT_CUSTMOBILE_CONTACTS
                     WHERE     N_CUST_REF_NO = C.N_CUST_REF_NO
                           AND V_STATUS = 'A'
                           AND V_Contact_Number LIKE '%@%'
                           AND ROWNUM = 1),
                   '.')
                   EMAIL_ADDRESS,
                DECODE (
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'),
                   '.', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   '-', 'XUGL' || C.N_CUST_REF_NO || 'I',
                   NVL (
                      REPLACE (
                         TRIM (
                            (SELECT MAX (V_IDEN_NO)
                               FROM GNDT_CUSTOMER_IDENTIFICATION
                              WHERE     V_IDEN_CODE = 'PIN'
                                    AND V_LASTUPD_INFTIM =
                                           (SELECT MAX (V_LASTUPD_INFTIM)
                                              FROM GNDT_CUSTOMER_IDENTIFICATION
                                             WHERE     V_IDEN_CODE = 'PIN'
                                                   AND N_CUST_REF_NO =
                                                          C.N_CUST_REF_NO)
                                    AND N_CUST_REF_NO = C.N_CUST_REF_NO)),
                         ' ',
                         ''),
                      'XUGL' || C.N_CUST_REF_NO || 'I'))
                   LEGACY_REF1
           FROM GNMT_CUSTOMER_MASTER C
          WHERE C.N_CUST_REF_NO = v_cust_ref_no;

      v_supplier_count        NUMBER := 0;
      v_supplier_site_count   NUMBER := 0;
      v_pin_count             NUMBER := 0;
      v_site_count            NUMBER := 0;
      v_contact_count         NUMBER := 0;
   BEGIN
      FOR I IN SUPPLIERS
      LOOP
         BEGIN
            SELECT COUNT (*)
              INTO v_supplier_count
              FROM JHL_OFA_SUPPLIER
             WHERE N_CUST_REF_NO = I.N_CUST_REF_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_supplier_count := 0;
         END;


         IF v_supplier_count = 0
         THEN
            INSERT INTO JHL_OFA_SUPPLIER (OSP_NO,
                                          N_CUST_REF_NO,
                                          OSP_PIN_NO,
                                          OSP_DATE,
                                          OSP_ID_NO)
                 VALUES (JHL_OSP_NO_SEQ.NEXTVAL,
                         I.N_CUST_REF_NO,
                         I.LEGACY_REF1,
                         SYSDATE,
                         I.LEGACY_REF2);
         END IF;

         --                    BEGIN
         --                          SELECT COUNT(*)
         --                           INTO v_pin_view_count
         --                         FROM  APPS.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM
         --                         WHERE LOB_NAME  IN ('JHL_UG_LIF_OU')
         --                         and PIN_NO = I.LEGACY_REF1
         --                         and v_pin_view_count ;
         --
         --                       EXCEPTION
         --                        WHEN OTHERS THEN
         --                        v_pin_view_count:=0;
         --                        END;


         BEGIN
            SELECT COUNT (*)
              INTO v_pin_count
              FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
             WHERE     PAY_GROUP = 'ISF-INDIVIDUAL-CLAIM'
                   AND LEGACY_REF1 = I.LEGACY_REF1;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_pin_count := 0;
         END;


         --                          raise_error('v_pin_count=='||v_pin_count||'LEGACY_REF1=='||I.LEGACY_REF1);

         IF v_pin_count = 0
         THEN
            INSERT
              INTO XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM (SEQ_ID,
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
                    I.LEGACY_REF1,
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

         FOR J IN SUPPLIERS_SITE (I.N_CUST_REF_NO)
         LOOP
            BEGIN
               SELECT COUNT (*)
                 INTO v_supplier_site_count
                 FROM JHL_OFA_SUPPLIER_SITE
                WHERE     N_CUST_REF_NO = I.N_CUST_REF_NO
                      AND NVL (V_POLICY_NO, 'XXXXX') =
                             NVL (J.LEGACY_REF3, 'XXXXX');
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_supplier_site_count := 0;
            END;



            BEGIN
               SELECT COUNT (*)
                 INTO v_site_count
                 FROM APPS.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM
                WHERE     LOB_NAME IN ('JHL_UG_LIF_OU')
                      AND PIN_NO = I.LEGACY_REF1
                      AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_site_count := 0;
            END;

            IF v_site_count = 0
            THEN
               BEGIN
                  SELECT COUNT (*)
                    INTO v_site_count
                    FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
                   WHERE     PAY_GRP_LKP_CODE = 'ISF-INDIVIDUAL-CLAIM'
                         AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE
                         AND LEGACY_REF1 = J.LEGACY_REF1
                         AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_site_count := 0;
               END;
            END IF;


            IF v_supplier_site_count = 0
            THEN
               INSERT INTO JHL_OFA_SUPPLIER_SITE (OSPC_NO,
                                                  N_CUST_REF_NO,
                                                  V_POLICY_NO,
                                                  OSPC_DATE)
                    VALUES (JHL_OSPC_NO_SEQ.NEXTVAL,
                            I.N_CUST_REF_NO,
                            J.LEGACY_REF3,
                            SYSDATE);
            END IF;



            IF v_site_count = 0
            THEN
               INSERT
                 INTO XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM (
                         SEQ_ID,
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
                         PREPAYMENT_ACCOUNT_ID,
                         PREPAYMENT_ACCOUNT,
                         LIABILITY_ACCOUNT,
                         LIABILITY_ACCOUNT_ID,
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
                       J.PREPAYMENT_ACCOUNT_ID,
                       J.PREPAYMENT_ACCOUNT_ID,
                       J.LIABILITY_ACCOUNT,
                       J.LIABILITY_ACCOUNT,
                       J.LEGACY_REF1,
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



         FOR C IN SUPPLIER_CONTACT (I.N_CUST_REF_NO)
         LOOP
            BEGIN
               SELECT COUNT (*)
                 INTO v_contact_count
                 FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                WHERE     LEGACY_REF1 = C.LEGACY_REF1
                      AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_contact_count := 0;
            END;

            IF v_contact_count = 0
            THEN
               INSERT
                 INTO XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM (
                         SEQ_ID,
                         PROCESS_FLAG,
                         OPERATING_UNIT,
                         FIRST_NAME,
                         LAST_NAME,
                         PHONE,
                         EMAIL_ADDRESS,
                         LEGACY_REF1)
               VALUES (XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM,
                       1,
                       C.OPERATING_UNIT,
                       C.FIRST_NAME,
                       C.LAST_NAME,
                       C.PHONE,
                       C.EMAIL_ADDRESS,
                       C.LEGACY_REF1);
            END IF;
         END LOOP;



         BEGIN
            SELECT COUNT (*)
              INTO v_site_count
              FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
             WHERE     PAY_GRP_LKP_CODE = 'ISF-INDIVIDUAL-CLAIM'
                   AND LEGACY_REF1 = I.LEGACY_REF1
                   AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
         EXCEPTION
            WHEN OTHERS
            THEN
               v_site_count := 0;
         END;

         --                                              raise_error('v_site_count=='||v_site_count);
         IF v_site_count = 0
         THEN
            DELETE FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
                  WHERE     PAY_GROUP = 'ISF-INDIVIDUAL-CLAIM'
                        AND LEGACY_REF1 = I.LEGACY_REF1
                        AND LEGACY_REF9 = 'Uganda';

            DELETE FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                  WHERE     LEGACY_REF1 = I.LEGACY_REF1
                        AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
         END IF;
      END LOOP;



      COMMIT;
   END;

   PROCEDURE CREATE_CORPORATE_SUPPLIER (
      company_code      VARCHAR,
      company_branch    VARCHAR,
      v_agent_no        NUMBER DEFAULT NULL)
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
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF4,
                C.V_LASTUPD_USER LEGACY_REF5,
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF6,
                NULL LEGACY_REF7,
                'Uganda' LEGACY_REF9,
                '11' LEGACY_REF11,
                SYSDATE LAST_UPDATE_DATE,
                C.V_COMPANY_CODE,
                C.V_COMPANY_BRANCH
           FROM Gnmm_Company_Master C
          WHERE     c.V_COMPANY_CODE = company_code
                AND c.V_COMPANY_BRANCH = company_branch;



      CURSOR SUPPLIER_SITE (
         v_companycode      VARCHAR,
         v_companybranch    VARCHAR)
      IS
         SELECT P.V_POLICY_NO VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NULL ATTENTION_AR_FLAG,
                NVL (
                   (SELECT G.V_POST_BOX
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT G.V_Town
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   CITY,
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
                TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH)
                   LEGACY_REF2,
                P.V_POLICY_NO LEGACY_REF3,
                p.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                p.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '11' LEGACY_REF9,
                '11' LEGACY_REF10,
                C.V_COMPANY_CODE,
                C.V_COMPANY_BRANCH
           FROM Gnmt_Policy P,
                Gnmm_Company_Master C,
                GNMM_POLICY_STATUS_MASTER STATUS,
                GNLU_INSTITUTION_TYPE INS,
                GNLU_PAY_METHOD PM
          WHERE     P.V_Company_Code = C.V_Company_Code
                AND P.V_Company_Branch = C.V_Company_Branch
                AND P.V_CNTR_STAT_CODE = STATUS.V_STATUS_CODE
                AND C.V_INST_TYPE = INS.V_INST_TYPE
                AND P.V_PMT_METHOD_CODE = PM.V_PMT_METHOD_CODE
                --AND  V_STATUS_DESC IN ('IN-FORCE')

                AND C.V_COMPANY_CODE = v_companycode
                AND C.V_COMPANY_BRANCH = v_companybranch
         UNION
         SELECT SUBSTR (
                   TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH),
                   1,
                   15)
                   VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NULL ATTENTION_AR_FLAG,
                NVL (
                   (SELECT G.V_POST_BOX
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = AGN.V_Company_Code
                           AND G.V_Company_Branch = AGN.V_Company_Branch),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT G.V_Town
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = AGN.V_Company_Code
                           AND G.V_Company_Branch = AGN.V_Company_Branch),
                   'KAMPALA')
                   CITY,
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
                TO_CHAR (
                   TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH))
                   LEGACY_REF2,
                TO_CHAR (NULL) LEGACY_REF3,
                C.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (C.V_LASTUPD_INFTIM, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                C.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (C.V_LASTUPD_INFTIM, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '12' LEGACY_REF9,
                '11' LEGACY_REF10,
                AGN.V_COMPANY_CODE,
                AGN.V_COMPANY_BRANCH
           FROM GNMM_COMPANY_MASTER C,
                AMMM_AGENT_MASTER AGN,
                GNLU_INSTITUTION_TYPE INS
          WHERE     C.V_Company_Code = AGN.V_Company_Code
                AND C.V_Company_Branch = AGN.V_Company_Branch
                AND C.V_INST_TYPE = INS.V_INST_TYPE
                --AND AGN.V_STATUS = 'A'
                AND AGN.V_COMPANY_CODE = v_companycode
                AND AGN.V_COMPANY_BRANCH = v_companybranch
                AND AGN.N_AGENT_NO = NVL (v_agent_no, AGN.N_AGENT_NO)
         UNION
         SELECT SUBSTR (
                   TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH),
                   1,
                   15)
                   VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NULL ATTENTION_AR_FLAG,
                NVL (
                   (SELECT G.V_POST_BOX
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT G.V_Town
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   CITY,
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
                TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH)
                   LEGACY_REF2,
                NULL LEGACY_REF3,
                c.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                c.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '11' LEGACY_REF9,
                '11' LEGACY_REF10,
                C.V_COMPANY_CODE,
                C.V_COMPANY_BRANCH
           FROM Gnmm_Company_Master C
          WHERE     1 = 1
                AND C.V_COMPANY_CODE = v_companycode
                AND C.V_COMPANY_BRANCH = v_companybranch
                AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
                       (SELECT AGN.V_COMPANY_CODE, AGN.V_COMPANY_BRANCH
                          FROM AMMM_AGENT_MASTER AGN
                         WHERE AGN.V_COMPANY_CODE IS NOT NULL)
                AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
                       (SELECT P.V_COMPANY_CODE, P.V_COMPANY_BRANCH
                          FROM Gnmt_Policy P,
                               GNMM_POLICY_STATUS_MASTER STATUS
                         WHERE     P.V_CNTR_STAT_CODE = STATUS.V_STATUS_CODE
                               AND P.V_COMPANY_CODE IS NOT NULL-- AND  V_STATUS_DESC IN ('IN-FORCE')

                       );


      CURSOR SUPPLIER_CONTACT (
         v_companycode      VARCHAR,
         v_companybranch    VARCHAR)
      IS
         SELECT DISTINCT
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                C.V_COMPANY_NAME FIRST_NAME,
                '.' LAST_NAME,
                NVL (
                   SUBSTR (
                      (SELECT V_Contact_Number
                         FROM Gndt_Compmobile_Contacts H
                        WHERE     H.V_Company_Code = C.V_Company_Code
                              AND H.V_Company_Branch = C.V_Company_Branch
                              AND V_Contact_Number NOT LIKE '%@%'
                              AND ROWNUM = 1),
                      1,
                      30),
                   '.')
                   PHONE,
                NVL (
                   (SELECT V_Contact_Number
                      FROM Gndt_Compmobile_Contacts H
                     WHERE     H.V_Company_Code = C.V_Company_Code
                           AND H.V_Company_Branch = C.V_Company_Branch
                           AND V_Contact_Number LIKE '%@%'
                           AND ROWNUM = 1),
                   '.')
                   EMAIL_ADDRESS,
                'XUGL' || C.V_COMPANY_CODE || 'C' LEGACY_REF1
           FROM Gnmm_Company_Master C
          WHERE     C.V_COMPANY_CODE = v_companycode
                AND C.V_COMPANY_BRANCH = v_companybranch;



      v_supplier_count        NUMBER := 0;
      v_supplier_site_count   NUMBER := 0;
      v_pin_count             NUMBER := 0;

      v_csp_pin_no            VARCHAR2 (50);
      v_site_count            NUMBER := 0;
      v_contact_count         NUMBER := 0;
   BEGIN
      FOR I IN SUPPLIERS
      LOOP
         BEGIN
            SELECT COUNT (*)
              INTO v_supplier_count
              FROM JHL_OFA_CO_SUPPLIER
             WHERE     V_COMPANY_CODE = I.V_COMPANY_CODe
                   AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_supplier_count := 0;
         END;

         IF v_supplier_count = 0
         THEN
            SELECT NVL (MAX (CSP_PIN_COUNT), 0)
              INTO v_pin_count
              FROM JHL_OFA_CO_SUPPLIER;

            v_pin_count := v_pin_count + 1;

            INSERT INTO JHL_OFA_CO_SUPPLIER (CSP_NO,
                                             V_COMPANY_CODE,
                                             V_COMPANY_BRANCH,
                                             CSP_PIN_NO,
                                             CSP_DATE,
                                             CSP_PIN_COUNT)
                 VALUES (JHL_CSP_NO_SEQ.NEXTVAL,
                         I.V_COMPANY_CODE,
                         I.V_COMPANY_BRANCH,
                         'XUGL' || v_pin_count || 'C',
                         SYSDATE,
                         v_pin_count);
         END IF;

         --get PIN NUMBER
         BEGIN
            SELECT CSP_PIN_NO
              INTO v_csp_pin_no
              FROM JHL_OFA_CO_SUPPLIER
             WHERE     V_COMPANY_CODE = I.V_COMPANY_CODe
                   AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_error ('Error Getting Pin number');
         END;

         --                              Raise_error('Pin Number is null=='||v_csp_pin_no);

         IF v_csp_pin_no IS NULL
         THEN
            Raise_error ('Pin Number is null');
         END IF;

         BEGIN
            SELECT COUNT (*)
              INTO v_pin_count
              FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
             WHERE PAY_GROUP = 'ISF-CORPORATE' AND LEGACY_REF1 = v_csp_pin_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_pin_count := 0;
         END;


         --                                  BEGIN
         --                          SELECT COUNT(*)
         --                           INTO v_pin_count
         --                         FROM  APPS.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM
         --                         WHERE LOB_NAME  IN ('JHL_UG_LIF_OU')
         --                         and PIN_NO = v_csp_pin_no;
         --
         --                       EXCEPTION
         --                        WHEN OTHERS THEN
         --                        v_pin_count:=0;
         --                        END;
         --

         IF v_pin_count = 0
         THEN
            INSERT
              INTO XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM (SEQ_ID,
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
                    v_csp_pin_no,
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
                 INTO v_supplier_site_count
                 FROM JHL_OFA_CO_SUPPLIER_SITE
                WHERE     V_COMPANY_CODE = I.V_COMPANY_CODE
                      AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH
                      AND NVL (V_POLICY_NO, 'XXXXX') =
                             NVL (J.LEGACY_REF3, 'XXXXX');
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_supplier_site_count := 0;
            END;



            BEGIN
               SELECT COUNT (*)
                 INTO v_site_count
                 FROM APPS.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM
                WHERE     LOB_NAME IN ('JHL_UG_LIF_OU')
                      AND PIN_NO = v_csp_pin_no
                      AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_site_count := 0;
            END;



            IF v_site_count = 0
            THEN
               BEGIN
                  SELECT COUNT (*)
                    INTO v_site_count
                    FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
                   WHERE     PAY_GRP_LKP_CODE = 'ISF-CORPORATE'
                         AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE
                         AND LEGACY_REF1 = v_csp_pin_no
                         AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_site_count := 0;
               END;
            END IF;


            IF v_supplier_site_count = 0
            THEN
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


            IF v_site_count = 0
            THEN
               INSERT
                 INTO XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM (
                         SEQ_ID,
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
                         LIABILITY_ACCOUNT_ID,
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
                       J.PREPAYMENT_ACCOUNT_ID,
                       J.PREPAYMENT_ACCOUNT_ID,
                       J.LIABILITY_ACCOUNT,
                       J.LIABILITY_ACCOUNT,
                       v_csp_pin_no,
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


         FOR C IN SUPPLIER_CONTACT (I.V_COMPANY_CODE, I.V_COMPANY_BRANCH)
         LOOP
            BEGIN
               SELECT COUNT (*)
                 INTO v_contact_count
                 FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                WHERE     LEGACY_REF1 = v_csp_pin_no
                      AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_contact_count := 0;
            END;


            IF v_contact_count = 0
            THEN
               INSERT
                 INTO XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM (
                         PROCESS_FLAG,
                         OPERATING_UNIT,
                         FIRST_NAME,
                         LAST_NAME,
                         PHONE,
                         EMAIL_ADDRESS,
                         LEGACY_REF1,
                         SEQ_ID)
               VALUES (1,
                       C.OPERATING_UNIT,
                       SUBSTR (C.FIRST_NAME, 1, 50),
                       C.LAST_NAME,
                       C.PHONE,
                       C.EMAIL_ADDRESS,
                       v_csp_pin_no,
                       XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM);
            END IF;
         END LOOP;



         BEGIN
            SELECT COUNT (*)
              INTO v_site_count
              FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
             WHERE     PAY_GRP_LKP_CODE = 'ISF-CORPORATE'
                   AND LEGACY_REF1 = v_csp_pin_no
                   AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
         EXCEPTION
            WHEN OTHERS
            THEN
               v_site_count := 0;
         END;

         --                                        raise_error('v_site_count=='||v_site_count);

         IF v_site_count = 0
         THEN
            DELETE FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
                  WHERE     PAY_GROUP = 'ISF-CORPORATE'
                        AND LEGACY_REF1 = v_csp_pin_no
                        AND LEGACY_REF9 = 'Uganda';

            DELETE FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                  WHERE     LEGACY_REF1 = v_csp_pin_no
                        AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
         END IF;
      END LOOP;
   END;



   PROCEDURE JHL_OFA_PAYABLES_PROC
   IS
      CURSOR VOUCHERS
      IS
         SELECT V_VOU_DESC, V_VOU_NO, D_VOU_DATE
           FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
          WHERE     PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND TO_DATE (D_VOU_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                  '01-JAN-20',
                                                                  'DD/MM/RRRR')
                                                           AND TO_DATE (
                                                                  SYSDATE,
                                                                  'DD/MM/RRRR')
                AND JHL_GEN_PKG.IS_VOUCHER_CANCELLED (V_VOU_NO) = 'N'
                AND JHL_GEN_PKG.is_voucher_authorized (V_VOU_NO) = 'Y';

      --    and rownum <=2500;
      -- and V_VOU_NO in ('2018001617');
      --AND  V_VOU_NO NOT IN (SELECT V_VOU_NO FROM JHL_OFA_PYMT_TRANSACTIONS);
      --AND V_VOU_DESC IN  ('CASH PAYMENT','TOTAL SURRENDER - LIFE','Claims Payment','LOAN')
      --AND N_CUST_REF_NO IS NOT  NULL;
      --and  upper(V_VOU_DESC) =  'MEDICAL FEES PAYMENT'
      --and V_VOU_NO NOT   IN ('2017027168','2017023582','2017023583');

      v_start_date   DATE;
   BEGIN
      --DELETE FROM JHL_OFA_PYMT_TRANSACTIONS;
      --DELETE FROM JHL_OFA_PYMT_VOUCHER_DTLS;
      --DELETE XXJICUG_AP_INVOICES_STG@JICOFPROD.COM
      --where OPERATING_UNIT = 'JHL_UG_LIF_OU';

      --delete from XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
      --where PAY_GROUP in ('ISF-INDIVIDUAL-CLAIM','ISF-CORPORATE');
      --
      --delete from XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
      --where PAY_GRP_LKP_CODE in ('ISF-INDIVIDUAL-CLAIM','ISF-CORPORATE');
      --
      -- delete from  XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
      -- where OPERATING_UNIT = 'JHL_UG_LIF_OU';

      v_start_date := SYSDATE;

      FOR I IN VOUCHERS
      LOOP
         BEGIN
            --                raise_error('hereree==');


            --             INSERT INTO JHL_OFA_GL_PAYMENTS_DETAILS(OPMT_NO, N_REF_NO, D_DATE, V_BRANCH_CODE, V_LOB_CODE,
            --                      V_PROCESS_CODE, V_PROCESS_NAME, V_DOCU_TYPE, V_DOCU_REF_NO, V_GL_CODE, V_DESC, V_TYPE, N_AMT,OFA_ACC_CODE,V_SOURCE_CURRENCY,OPMT_DATE,OPMT_USER)
            --
            --     SELECT JHL_OPMT_NO_SEQ.NEXTVAL,M.N_REF_NO, M.D_DATE, V_BRANCH_CODE, V_LOB_CODE, nvl(V_PROCESS_CODE,'N/A') V_PROCESS_CODE,nvl((SELECT V_PROCESS_NAME
            --                    FROM GNMM_PROCESS_MASTER
            --                    WHERE V_PROCESS_ID = V_PROCESS_CODE),nvl(V_PROCESS_CODE,'N/A')) V_PROCESS_NAME,V_DOCU_TYPE,V_DOCU_REF_NO,V_GL_CODE ,V_DESC ,V_TYPE, N_AMT,
            --                    /* NVL((select  distinct  OFA_ACC_CODE
            --                                             FROM JHL_OFA_ACC_MAP ACCS
            --                                             where  ACCS.V_GL_CODE =  D.V_GL_CODE
            --                                             AND OFA_ACC_CODE IS NOT NULL
            --                                             and  ACCS.V_DESC = D.V_DESC
            --                                             ),'N/A') */
            --                                                    (SELECT  distinct OFA_ACC_CODE
            --                                             FROM JHL_ISF_OFA_ACC_MAP
            --                                             WHERE ISF_GL_CODE = D.V_GL_CODE
            --                                             and ACC_DESC =D.V_DESC )   OFA_ACC_CODE,'UGX',SYSDATE,'DMWIRIGI'
            --                          FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
            --                          WHERE M.N_REF_NO = D.N_REF_NO
            --                          AND M.V_JOURNAL_STATUS = 'C'
            --                          AND V_DOCU_TYPE='VOUCHER'
            --                          AND V_DOCU_REF_NO = I.V_VOU_NO
            ----                      JHL_OFA_TRANSFORM_GL_VOU     AND to_date(M.D_POSTED_DATE,'DD/MM/RRRR') BETWEEN to_date('01-JAN-17','DD/MM/RRRR')  AND to_date('31-JAN-17','DD/MM/RRRR')
            --                           AND M.N_REF_NO NOT IN  ( SELECT ORT.N_REF_NO FROM JHL_OFA_GL_PAYMENTS_DETAILS ORT WHERE ORT.N_REF_NO =M.N_REF_NO );


            --                 IF I.V_VOU_NO IN ('2016163174','2016163135','2016163075','2016163210') THEN
            --                 RAISE_ERROR('  -- ');
            --                 END IF;

            --raise_error('V_VOU_NO=='||I.V_VOU_NO);

            --JHL_OFA_TRANSFORM_GL_VOU_PROC(I.V_VOU_NO);

            JHL_OFA_TRANSFORM_GL_VOU (I.V_VOU_NO);
         --
         --                exception
         --                when others then
         --                log_voucher_error(I.V_VOU_NO,'Error creating voucher number');
         --                ROLLBACK;
         END;

         COMMIT;
      END LOOP;

      INSERT INTO JHL_OFA_JOBS (OJB_ID,
                                OJB_NAME,
                                OJB_START_DT,
                                OJB_END_DT)
           VALUES (JHL_OJB_ID_SEQ.NEXTVAL,
                   'JHL_OFA_PAYABLES_PROC',
                   v_start_date,
                   SYSDATE);

      COMMIT;
   END;

   PROCEDURE JHL_OFA_TRANSFORM_GL_VOU_PROC (v_voucher_no VARCHAR2)
   IS
      CURSOR VOUCHERS
      IS
           SELECT V_GL_CODE ACCT_CODE,
                  V_PROCESS_CODE,
                  SUM (DECODE (V_TYPE, 'D', -N_AMT, N_AMT)) AMOUNT,
                  DECODE (V_DESC, 'INCOME_TAX', 'WHT TAX', V_DESC) V_DESC,
                  (SELECT DISTINCT OFA_ACC_CODE
                     FROM JHL_ISF_OFA_ACC_MAP ACCS
                    WHERE     ACCS.ISF_GL_CODE = D.V_GL_CODE
                          AND OFA_ACC_CODE IS NOT NULL
                          AND ACCS.ACC_DESC = D.V_DESC)
                     OFA_ACC_CODE,
                  DECODE (SIGN (SUM (DECODE (V_TYPE, 'D', -N_AMT, N_AMT))),
                          -1, 1,
                          2)
                     ORD,
                  V_DOCU_REF_NO V_VOU_NO,
                  BPG_FINANCE_BATCHES.BFN_GET_PAYEE_NAME (V_DOCU_REF_NO)
                     VENDOR_NAME,
                  ABS (SUM (DECODE (V_TYPE, 'D', -N_AMT, N_AMT))) AMT
             FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
            WHERE     M.N_REF_NO = D.N_REF_NO
                  AND M.V_JOURNAL_STATUS = 'C'
                  --AND NVL(M.V_REMARKS,'N')!='X'
                  AND V_DOCU_TYPE = 'VOUCHER'
                  AND TO_DATE (M.D_POSTED_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                         '01-JAN-17',
                                                                         'DD/MM/RRRR')
                                                                  AND TO_DATE (
                                                                         '31-JAN-17',
                                                                         'DD/MM/RRRR')
                  --AND V_DOCU_REF_NO = '2016084503'
                  AND V_DOCU_REF_NO = v_voucher_no
         GROUP BY V_GL_CODE,
                  V_PROCESS_CODE,
                  V_DESC,
                  V_DOCU_REF_NO
         ORDER BY ORD, AMT DESC;


      CURSOR voucher
      IS
         SELECT V_VOU_DESC,
                V_PAYEE_NAME,
                N_CUST_REF_NO,
                V_COMPANY_CODE,
                V_COMPANY_BRANCH,
                V_IND_COMPANY,
                PM.V_MAIN_VOU_NO V_MAIN_VOU_NO,
                N_VOU_AMOUNT,
                D_VOU_DATE,
                'UGX' V_CURRENCY_CODE
           FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
          WHERE     PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND PV.V_VOU_NO = v_voucher_no;



      payee_name        VARCHAR (400);
      v_n_cust_ref_no   NUMBER (25);
      company_code      VARCHAR2 (20);
      company_branch    VARCHAR2 (50);
      ind_company       VARCHAR2 (2);


      v_pay_amount      NUMBER;
      v_sign            NUMBER;
      v_gross_amt       NUMBER;
      v_account         VARCHAR2 (50);
      v_desc            VARCHAR2 (200);
      v_acct_code       VARCHAR2 (50);
      v_count           NUMBER;
      policy_no         VARCHAR2 (30);
      v_pin_no          VARCHAR2 (30);

      v_amount          NUMBER;
      MAIN_VOU_NO       VARCHAR2 (50);
      vou_count         NUMBER;
      v_site_code       VARCHAR2 (50);

      v_total_amount    NUMBER;

      v_error_message   VARCHAR2 (1000);
      v_exist_count     NUMBER := 0;
      v_vou_date        DATE;

      v_agent_no        NUMBER;
      currency_code     VARCHAR2 (100);

      v_policy_count    NUMBER;
   BEGIN
      vou_count := 0;

      SELECT COUNT (*)
        INTO vou_count
        FROM JHL_OFA_PYMT_TRANSACTIONS
       WHERE V_VOU_NO = v_voucher_no;

      v_agent_no := NULL;

      IF vou_count = 0
      THEN
         v_count := 0;

         FOR I IN VOUCHERS
         LOOP
            IF i.ACCT_CODE <> '115092'
            THEN
               v_count := v_count + 1;

               FOR v IN voucher
               LOOP
                  v_desc := v.V_VOU_DESC;
                  payee_name := v.V_PAYEE_NAME;
                  v_n_cust_ref_no := v.N_CUST_REF_NO;
                  company_code := v.V_COMPANY_CODE;
                  company_branch := V.V_COMPANY_BRANCH;
                  ind_company := v.V_IND_COMPANY;
                  MAIN_VOU_NO := v.V_MAIN_VOU_NO;
                  v_pay_amount := v.N_VOU_AMOUNT;
                  v_sign := SIGN (v.N_VOU_AMOUNT);
                  v_vou_date := v.D_VOU_DATE;
                  currency_code := V.V_currency_code;
               END LOOP;

               /*CHECK WHETHER PAYER HAS POLICY NUMBER*/

               IF ind_company = 'I'
               THEN
                  BEGIN
                     SELECT COUNT (*)
                       INTO v_policy_count
                       FROM Gnmt_Policy P
                      WHERE     P.N_PAYER_REF_NO = v_n_cust_ref_no
                            AND P.N_PAYER_REF_NO IS NOT NULL;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_policy_count := 0;
                  END;
               ELSE
                  BEGIN
                     SELECT COUNT (*)
                       INTO v_policy_count
                       FROM Gnmt_Policy P
                      WHERE     P.V_Company_Code = company_code
                            AND P.V_Company_Branch = company_branch
                            AND P.V_Company_Code IS NOT NULL;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_policy_count := 0;
                  END;
               END IF;



               --                               IF upper(v_desc) not in ('REFUND COMPANY OVERSHOT','MEDICAL FEES PAYMENT', 'COMMISSION') THEN

               policy_no := NULL;

               IF     v_policy_count > 0
                  AND UPPER (v_desc) NOT IN
                         ('REFUND COMPANY OVERSHOT',
                          'MEDICAL FEES PAYMENT',
                          'COMMISSION')
               THEN
                  IF ind_company = 'I'
                  THEN
                     BEGIN
                        SELECT V_POLICY_NO
                          INTO policy_no
                          FROM PYDT_VOUCHER_POLICY_CLIENT
                         WHERE     V_VOU_NO = v_voucher_no
                               AND V_POLICY_NO IN
                                      (SELECT V_POLICY_NO
                                         FROM Gnmt_Policy P
                                        WHERE     P.N_PAYER_REF_NO =
                                                     v_n_cust_ref_no
                                              AND P.N_PAYER_REF_NO
                                                     IS NOT NULL);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           policy_no := NULL;
                     END;
                  ELSE
                     BEGIN
                        SELECT V_POLICY_NO
                          INTO policy_no
                          FROM PYDT_VOUCHER_POLICY_CLIENT
                         WHERE     V_VOU_NO = v_voucher_no
                               AND V_POLICY_NO IN
                                      (SELECT V_POLICY_NO
                                         FROM Gnmt_Policy P
                                        WHERE     P.V_Company_Code =
                                                     company_code
                                              AND P.V_Company_Branch =
                                                     company_branch
                                              AND P.V_Company_Code
                                                     IS NOT NULL);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           policy_no := NULL;
                     END;
                  END IF;
               END IF;

               --                               RAISE_ERROR('v_policy_count=='||v_policy_count||'policy_no=='||policy_no);



               IF ind_company = 'I'
               THEN
                  v_site_code := NVL (policy_no, 'PYR-' || v_n_cust_ref_no);



                  CREATE_INDIVIDUAL_SUPPLIER (v_n_cust_ref_no);

                  BEGIN
                     SELECT OSP_PIN_NO
                       INTO v_pin_no
                       FROM JHL_OFA_SUPPLIER
                      WHERE N_CUST_REF_NO = v_n_cust_ref_no;
                  EXCEPTION
                     --                                            when no_data_found then
                     --                                            v_pin_no  := null;
                     WHEN OTHERS
                     THEN
                        RAISE_ERROR (
                              'ERROR GETTING pIN NUMBER  CO CODE=='
                           || v_n_cust_ref_no
                           || ' NAME ='
                           || payee_name);
                  --                                    v_error_message := 'ERROR GETTING pIN NUMBER  CO CODE=='||company_code|| ' BRN ='||company_branch;
                  END;



                  IF v_site_code IS NULL
                  THEN
                     raise_error (
                           ' Site Code missing '
                        || v_n_cust_ref_no
                        || ' ;;;;'
                        || v_desc
                        || ' ;;;;'
                        || policy_no);
                  END IF;
               ELSE
                  v_site_code :=
                     NVL (
                        policy_no,
                        SUBSTR (
                           TO_CHAR (company_code || '-' || company_branch),
                           1,
                           15));

                  --                                                   raise_error('company_code=='||company_code||'company_branch=='||company_branch||'v_agent_no=='||v_agent_no);
                  CREATE_CORPORATE_SUPPLIER (company_code, company_branch);

                  --                                                                              raise_error('company_code=='||company_code||'company_branch=='||company_branch||'v_agent_no=='||v_agent_no);

                  BEGIN
                     SELECT CSP_PIN_NO
                       INTO v_pin_no
                       FROM JHL_OFA_CO_SUPPLIER
                      WHERE     V_COMPANY_CODE = company_code
                            AND V_COMPANY_BRANCH = company_branch;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        RAISE_ERROR (
                              'ERROR GETTING pIN NUMBER  CO CODE=='
                           || company_code
                           || ' BRN ='
                           || company_branch);
                  END;
               END IF;


               v_amount := I.AMOUNT * v_sign * -1;

               --    RAISE_ERROR('v_n_cust_ref_no=='||v_n_cust_ref_no||'v_policy_count=='||v_policy_count||
               --                          'policy_no=='||policy_no||'v_site_code=='||v_site_code||'v_pin_no=='||v_pin_no);


               INSERT INTO JHL_OFA_PYMT_TRANSACTIONS (OPT_NO,
                                                      V_VOU_NO,
                                                      LEGACY_SUPPLIER_CODE,
                                                      VENDOR_NAME,
                                                      VENDOR_SITE_CODE,
                                                      INVOICE_AMOUNT,
                                                      INVOICE_CURRENCY_CODE,
                                                      EXCHANGE_RATE,
                                                      DESCRIPTION,
                                                      LIABILITY_ACCOUNT,
                                                      LINE_NUMBER,
                                                      LEGACY_REF1,
                                                      LINE_AMOUNT,
                                                      N_CUST_REF_NO,
                                                      V_COMPANY_CODE,
                                                      V_COMPANY_BRANCH,
                                                      V_MAIN_VOU_NO,
                                                      LEGACY_REF3,
                                                      V_VOU_DATE)
                    VALUES (
                              OFA_OPT_NO_SEQ.NEXTVAL,
                              i.V_VOU_NO,
                              NVL (
                                 TO_CHAR (v_n_cust_ref_no),
                                 TO_CHAR (
                                    company_code || '-' || company_branch)),
                              i.VENDOR_NAME,
                              v_site_code,
                              v_pay_amount,
                              currency_code,
                              1,
                              I.V_DESC,
                              I.OFA_ACC_CODE,
                              v_count,
                              v_pin_no,
                              v_amount,
                              v_n_cust_ref_no,
                              company_code,
                              company_branch,
                              main_vou_no,
                              policy_no,
                              v_vou_date);
            END IF;
         END LOOP;

         SELECT SUM (LINE_AMOUNT)
           INTO v_total_amount
           FROM JHL_OFA_PYMT_TRANSACTIONS
          WHERE V_VOU_NO = v_voucher_no;

         UPDATE JHL_OFA_PYMT_TRANSACTIONS
            SET INVOICE_AMOUNT = v_total_amount
          WHERE V_VOU_NO = v_voucher_no;

         BEGIN
            SELECT COUNT (*)
              INTO v_exist_count
              FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
             WHERE     LOB_NAME = 'JHL_UG_LIF_OU'
                   AND PAYMENT_VOUCHER = v_voucher_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_exist_count := 0;
         END;

         IF v_exist_count = 0
         THEN
            BEGIN
               SELECT COUNT (*)
                 INTO v_exist_count
                 FROM XXJICUG_AP_INVOICES_STG@JICOFPROD.COM
                WHERE     OPERATING_UNIT = 'JHL_UG_LIF_OU'
                      AND VOUCHER_NUM = v_voucher_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_exist_count := 0;
            END;
         END IF;


         IF v_exist_count = 0 AND v_total_amount <> 0
         THEN
            JHL_OFA_GL_VOUCHERS_NEW (v_voucher_no);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_error ('v_voucher_no==' || v_voucher_no);
   END;



   PROCEDURE JHL_OFA_TRANSFORM_GL_VOU_BK (v_voucher_no VARCHAR2)
   IS
      CURSOR VOUCHERS
      IS
           SELECT V_GL_CODE ACCT_CODE,
                  V_PROCESS_CODE,
                  SUM (DECODE (V_TYPE, 'D', -N_AMT, N_AMT)) AMOUNT,
                  DECODE (V_DESC, 'INCOME_TAX', 'WHT TAX', V_DESC) V_DESC,
                  (SELECT DISTINCT OFA_ACC_CODE
                     FROM JHL_ISF_OFA_ACC_MAP
                    WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                          AND TRIM (ACC_DESC) = TRIM (d.V_DESC))
                     OFA_ACC_CODE,
                  DECODE (SIGN (SUM (DECODE (V_TYPE, 'D', -N_AMT, N_AMT))),
                          -1, 1,
                          2)
                     ORD,
                  V_DOCU_REF_NO V_VOU_NO,
                  BPG_FINANCE_BATCHES.BFN_GET_PAYEE_NAME (V_DOCU_REF_NO)
                     VENDOR_NAME,
                  ABS (SUM (DECODE (V_TYPE, 'D', -N_AMT, N_AMT))) AMT
             FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
            WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
                  AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                  AND V_DOCU_REF_NO = v_voucher_no
         GROUP BY V_GL_CODE,
                  V_PROCESS_CODE,
                  V_DESC,
                  V_DOCU_REF_NO
         ORDER BY ORD, AMT DESC;


      CURSOR voucher
      IS
         SELECT V_VOU_DESC,
                V_PAYEE_NAME,
                N_CUST_REF_NO,
                V_COMPANY_CODE,
                V_COMPANY_BRANCH,
                V_IND_COMPANY,
                PM.V_MAIN_VOU_NO V_MAIN_VOU_NO,
                N_VOU_AMOUNT,
                D_VOU_DATE,
                DECODE (V_CURRENCY_CODE, 'UGS', 'UGX', V_CURRENCY_CODE)
                   V_CURRENCY_CODE
           FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
          WHERE     PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND PV.V_VOU_NO = v_voucher_no;



      payee_name        VARCHAR (400);
      v_n_cust_ref_no   NUMBER (25);
      company_code      VARCHAR2 (20);
      company_branch    VARCHAR2 (50);
      ind_company       VARCHAR2 (2);


      v_pay_amount      NUMBER;
      v_sign            NUMBER;
      v_gross_amt       NUMBER;
      v_account         VARCHAR2 (50);
      v_desc            VARCHAR2 (200);
      v_acct_code       VARCHAR2 (50);
      v_count           NUMBER;
      policy_no         VARCHAR2 (30);
      v_pin_no          VARCHAR2 (30);

      v_amount          NUMBER;
      MAIN_VOU_NO       VARCHAR2 (50);
      vou_count         NUMBER;
      v_site_code       VARCHAR2 (50);

      v_total_amount    NUMBER;

      v_error_message   VARCHAR2 (1000);
      v_exist_count     NUMBER := 0;
      v_vou_date        DATE;
      currency_code     VARCHAR2 (100);

      v_agent_no        NUMBER;
   BEGIN
      vou_count := 0;

      SELECT COUNT (*)
        INTO vou_count
        FROM JHL_OFA_PYMT_TRANSACTIONS
       WHERE V_VOU_NO = v_voucher_no;

      v_agent_no := NULL;

      IF vou_count = 0
      THEN
         v_count := 0;

         FOR I IN VOUCHERS
         LOOP
            IF i.ACCT_CODE <> '115092'
            THEN
               v_count := v_count + 1;



               FOR v IN voucher
               LOOP
                  v_desc := v.V_VOU_DESC;
                  payee_name := v.V_PAYEE_NAME;
                  v_n_cust_ref_no := v.N_CUST_REF_NO;
                  company_code := v.V_COMPANY_CODE;
                  company_branch := V.V_COMPANY_BRANCH;
                  ind_company := v.V_IND_COMPANY;
                  MAIN_VOU_NO := v.V_MAIN_VOU_NO;
                  v_pay_amount := v.N_VOU_AMOUNT;
                  v_sign := SIGN (v.N_VOU_AMOUNT);
                  v_vou_date := v.D_VOU_DATE;
                  currency_code := V.V_currency_code;
               END LOOP;

               BEGIN
                  SELECT DISTINCT V_POLICY_NO
                    INTO policy_no
                    FROM PYDT_VOUCHER_POLICY_CLIENT
                   WHERE V_VOU_NO = v_voucher_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     policy_no := NULL;
               END;



               --                         RAISE_ERROR('v_n_cust_ref_no=='||v_n_cust_ref_no||'policy_no=='||policy_no);

               IF ind_company = 'I'
               THEN
                  IF v_desc = 'COMMISSION'
                  THEN
                     v_agent_no := NULL;

                     --                                            v_site_code := v_n_cust_ref_no;
                     BEGIN
                        SELECT TO_CHAR (
                                  TRIM (N_AGENT_NO || ' - ' || V_AGENT_CODE))
                          INTO v_site_code
                          FROM Ammm_Agent_Master AGN
                         WHERE     AGN.N_Cust_Ref_No = v_n_cust_ref_no
                               AND V_STATUS = 'A';
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           SELECT MAX (
                                     TO_CHAR (
                                        TRIM (
                                              N_AGENT_NO
                                           || ' - '
                                           || V_AGENT_CODE)))
                             INTO v_site_code
                             FROM Ammm_Agent_Master AGN
                            WHERE AGN.N_Cust_Ref_No = v_n_cust_ref_no;
                        WHEN OTHERS
                        THEN
                           --                                                        v_site_code := null;

                           --                                                        v_error_message := 'Error getting agent No';
                           raise_error (
                              'Error getting agent No ' || v_n_cust_ref_no);
                     END;

                     SELECT N_AGENT_NO
                       INTO v_agent_no
                       FROM Ammm_Agent_Master AGN
                      WHERE     AGN.N_Cust_Ref_No = v_n_cust_ref_no
                            AND TO_CHAR (
                                   TRIM (N_AGENT_NO || ' - ' || V_AGENT_CODE)) =
                                   v_site_code;
                  ELSE
                     v_site_code := policy_no;
                  END IF;



                  CREATE_INDIVIDUAL_SUPPLIER (v_n_cust_ref_no, v_agent_no);

                  BEGIN
                     SELECT OSP_PIN_NO
                       INTO v_pin_no
                       FROM JHL_OFA_SUPPLIER
                      WHERE N_CUST_REF_NO = v_n_cust_ref_no;
                  EXCEPTION
                     --                                            when no_data_found then
                     --                                            v_pin_no  := null;
                     WHEN OTHERS
                     THEN
                        RAISE_ERROR (
                              'ERROR GETTING pIN NUMBER  CO CODE=='
                           || v_n_cust_ref_no
                           || ' NAME ='
                           || payee_name);
                  --                                    v_error_message := 'ERROR GETTING pIN NUMBER  CO CODE=='||company_code|| ' BRN ='||company_branch;
                  END;



                  IF v_site_code IS NULL
                  THEN
                     raise_error (
                           ' Site Code missing '
                        || v_n_cust_ref_no
                        || ' ;;;;'
                        || v_desc
                        || ' ;;;;'
                        || policy_no);
                  END IF;
               ELSE
                  IF v_desc = 'COMMISSION'
                  THEN
                     v_agent_no := NULL;

                     --v_site_code := company_code;

                     BEGIN
                        SELECT TO_CHAR (
                                  TRIM (N_AGENT_NO || ' - ' || V_AGENT_CODE))
                          INTO v_site_code
                          FROM AMMM_AGENT_MASTER AGN
                         WHERE     AGN.V_Company_Code = company_code
                               AND AGN.V_Company_Branch = company_branch
                               AND V_STATUS = 'A';
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           SELECT MAX (
                                     TO_CHAR (
                                        TRIM (
                                              N_AGENT_NO
                                           || ' - '
                                           || V_AGENT_CODE)))
                             INTO v_site_code
                             FROM AMMM_AGENT_MASTER AGN
                            WHERE     AGN.V_Company_Code = company_code
                                  AND AGN.V_Company_Branch = company_branch;
                        WHEN OTHERS
                        THEN
                           raise_error (
                                 'Error getting agent No '
                              || company_code
                              || ' '
                              || company_branch);
                     END;

                     --                                                    raise_error('v_site_code=='||v_site_code||'v_n_cust_ref_no=='||v_n_cust_ref_no);
                     SELECT N_AGENT_NO
                       INTO v_agent_no
                       FROM Ammm_Agent_Master AGN
                      WHERE     AGN.V_Company_Code = company_code
                            AND AGN.V_Company_Branch = company_branch
                            AND TO_CHAR (
                                   TRIM (N_AGENT_NO || ' - ' || V_AGENT_CODE)) =
                                   v_site_code;
                  ELSE
                     v_site_code := policy_no;
                  END IF;

                  --                                                   raise_error('v_agent_no=='||v_agent_no);
                  CREATE_CORPORATE_SUPPLIER (company_code,
                                             company_branch,
                                             v_agent_no);

                  BEGIN
                     SELECT CSP_PIN_NO
                       INTO v_pin_no
                       FROM JHL_OFA_CO_SUPPLIER
                      WHERE     V_COMPANY_CODE = company_code
                            AND V_COMPANY_BRANCH = company_branch;
                  EXCEPTION
                     --                                            when no_data_found then
                     --                                            v_pin_no  := null;
                     WHEN OTHERS
                     THEN
                        RAISE_ERROR (
                              'ERROR GETTING pIN NUMBER  CO CODE=='
                           || company_code
                           || ' BRN ='
                           || company_branch);
                  --                                    v_error_message := 'ERROR GETTING pIN NUMBER  CO CODE=='||company_code|| ' BRN ='||company_branch;
                  END;
               --                                    if v_site_code is null then
               --                                   raise_error(' Site Code missing ' ||company_code||' ;;;;'||company_branch||' ;;;;'||v_desc);
               --                                   end if;

               END IF;

               v_amount := I.AMOUNT * v_sign * -1;

               --                     raise_error('ref=='||nvl( to_char(v_n_cust_ref_no) ,  to_char(company_code||'-'||company_branch)));

               --                    if v_error_message is null then


               IF v_desc LIKE '%OVERSHOT%'
               THEN
                  policy_no := NULL;
                  v_site_code :=
                     SUBSTR (TO_CHAR (company_code || '-' || company_branch),
                             1,
                             15);
               END IF;


               --                      if v_pin_no is not null then
               INSERT INTO JHL_OFA_PYMT_TRANSACTIONS (OPT_NO,
                                                      V_VOU_NO,
                                                      LEGACY_SUPPLIER_CODE,
                                                      VENDOR_NAME,
                                                      VENDOR_SITE_CODE,
                                                      INVOICE_AMOUNT,
                                                      INVOICE_CURRENCY_CODE,
                                                      EXCHANGE_RATE,
                                                      DESCRIPTION,
                                                      LIABILITY_ACCOUNT,
                                                      LINE_NUMBER,
                                                      LEGACY_REF1,
                                                      LINE_AMOUNT,
                                                      N_CUST_REF_NO,
                                                      V_COMPANY_CODE,
                                                      V_COMPANY_BRANCH,
                                                      V_MAIN_VOU_NO,
                                                      LEGACY_REF3,
                                                      V_VOU_DATE)
                    VALUES (
                              OFA_OPT_NO_SEQ.NEXTVAL,
                              i.V_VOU_NO,
                              NVL (
                                 TO_CHAR (v_n_cust_ref_no),
                                 TO_CHAR (
                                    company_code || '-' || company_branch)),
                              i.VENDOR_NAME,
                              v_site_code,
                              v_pay_amount,
                              currency_code,
                              1,
                              I.V_DESC,
                              I.OFA_ACC_CODE,
                              v_count,
                              v_pin_no,
                              v_amount,
                              v_n_cust_ref_no,
                              company_code,
                              company_branch,
                              main_vou_no,
                              policy_no,
                              v_vou_date);
            --                        end if;
            --                     end if;



            END IF;
         END LOOP;

         SELECT SUM (LINE_AMOUNT)
           INTO v_total_amount
           FROM JHL_OFA_PYMT_TRANSACTIONS
          WHERE V_VOU_NO = v_voucher_no;

         UPDATE JHL_OFA_PYMT_TRANSACTIONS
            SET INVOICE_AMOUNT = v_total_amount
          WHERE V_VOU_NO = v_voucher_no;

         BEGIN
            SELECT COUNT (*)
              INTO v_exist_count
              FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
             WHERE     LOB_NAME = 'JHL_UG_LIF_OU'
                   AND PAYMENT_VOUCHER = v_voucher_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_exist_count := 0;
         END;


         ----
         ----        IF v_total_amount <> 0 and v_error_message is null THEN

         --if v_pin_no is not null and vou_count = 0  then
         --        end if;

         --and v_total_amount <> 0

         IF v_exist_count = 0
         THEN
            JHL_OFA_GL_VOUCHERS_NEW (v_voucher_no);
         END IF;
      ----        END IF;


      END IF;
   --exception
   --when others then
   --raise_error('v_voucher_no=='||v_voucher_no);
   END;


   PROCEDURE JHL_OFA_TRANSFORM_GL_VOU (v_voucher_no VARCHAR2)
   IS
      CURSOR VOUCHERS
      IS
           SELECT V_GL_CODE ACCT_CODE,
                  V_PROCESS_CODE,
                  SUM (DECODE (V_TYPE, 'D', -N_SOURCE_AMOUNT, N_SOURCE_AMOUNT))
                     AMOUNT,
                  DECODE (V_DESC, 'INCOME_TAX', 'WHT TAX', V_DESC) V_DESC,
                  (SELECT DISTINCT OFA_ACC_CODE
                     FROM JHL_ISF_OFA_ACC_MAP
                    WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                          AND TRIM (ACC_DESC) = TRIM (d.V_DESC))
                     OFA_ACC_CODE,
                  DECODE (
                     SIGN (
                        SUM (
                           DECODE (V_TYPE,
                                   'D', -N_SOURCE_AMOUNT,
                                   N_SOURCE_AMOUNT))),
                     -1, 1,
                     2)
                     ORD,
                  V_DOCU_REF_NO V_VOU_NO,
                  BPG_FINANCE_BATCHES.BFN_GET_PAYEE_NAME (V_DOCU_REF_NO)
                     VENDOR_NAME,
                  ABS (
                     SUM (
                        DECODE (V_TYPE, 'D', -N_SOURCE_AMOUNT, N_SOURCE_AMOUNT)))
                     AMT,
                  N_CONVERSION_RATE
             FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
            WHERE     M.N_REF_NO = D.N_REF_NO
                  AND M.V_JOURNAL_STATUS = 'C'
                  AND V_DOCU_TYPE = 'VOUCHER'
                  AND V_DOCU_REF_NO = v_voucher_no
         GROUP BY V_GL_CODE,
                  V_PROCESS_CODE,
                  V_DESC,
                  V_DOCU_REF_NO,
                  N_CONVERSION_RATE
         ORDER BY ORD, AMT DESC;


      CURSOR voucher
      IS
         SELECT V_VOU_DESC,
                V_PAYEE_NAME,
                N_CUST_REF_NO,
                V_COMPANY_CODE,
                V_COMPANY_BRANCH,
                V_IND_COMPANY,
                PM.V_MAIN_VOU_NO V_MAIN_VOU_NO,
                N_VOU_AMOUNT,
                D_VOU_DATE,
                DECODE (V_currency_code, 'UGS', 'UGX', V_currency_code)
                   V_currency_code
           FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
          WHERE     PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND PV.V_VOU_NO = v_voucher_no;



      payee_name            VARCHAR (400);
      v_n_cust_ref_no       NUMBER (25);
      company_code          VARCHAR2 (20);
      company_branch        VARCHAR2 (50);
      ind_company           VARCHAR2 (2);


      v_pay_amount          NUMBER;
      v_sign                NUMBER;
      v_gross_amt           NUMBER;
      v_account             VARCHAR2 (50);
      v_desc                VARCHAR2 (200);
      v_acct_code           VARCHAR2 (50);
      v_count               NUMBER;
      policy_no             VARCHAR2 (30);
      v_pin_no              VARCHAR2 (30);

      v_amount              NUMBER;
      MAIN_VOU_NO           VARCHAR2 (50);
      vou_count             NUMBER;
      v_site_code           VARCHAR2 (50);

      v_total_amount        NUMBER;

      v_error_message       VARCHAR2 (1000);
      v_exist_count         NUMBER := 0;
      v_vou_date            DATE;

      v_agent_no            NUMBER;
      currency_code         VARCHAR2 (100);

      v_policy_count        NUMBER;

      v_pol_type            VARCHAR2 (2);
      v_pol_no              VARCHAR2 (250);

      v_pol_payer           NUMBER (25);
      v_co_code             VARCHAR2 (20);
      v_co_brh              VARCHAR2 (50);
      v_diff_payee_name     VARCHAR (400);
      v_vendor_name         VARCHAR (400);
      v_pay_group           VARCHAR2 (50);

      v_post_count          NUMBER := 0;
      v_st_error_count      NUMBER := 0;
      v_leg_sup_code        VARCHAR2 (150);

      v_vou_auth_date       DATE;

      v_vou_approved        VARCHAR2 (5) := 'N';

      v_channel             VARCHAR2 (30);
      v_product             VARCHAR2 (30);
      v_acc_count           NUMBER := 0;

      /*12-feb-2020*/
      v_email_no            VARCHAR2 (150);
      v_phone_no            VARCHAR2 (150);

      v_control_acc_count   NUMBER := 0;
   BEGIN
      v_post_count := 0;

      SELECT COUNT (*)
        INTO v_post_count
        --INTO v_pol_type, v_pol_no
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
       WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
             AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                                         --2017005999
             AND V_DOCU_REF_NO = v_voucher_no;

      vou_count := 0;

      SELECT COUNT (*)
        INTO vou_count
        FROM JHL_OFA_PYMT_TRANSACTIONS
       WHERE V_VOU_NO = v_voucher_no;


      v_st_error_count := 0;

      SELECT COUNT (*)
        INTO v_st_error_count
        --INTO v_pol_type, v_pol_no
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
       WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS <> 'C' --AND NVL(M.V_REMARKS,'N')!='X'
             AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                                         --2017005999
             AND V_DOCU_REF_NO = v_voucher_no;


      v_vou_approved := 'N';
      v_vou_approved := JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED (v_voucher_no);

      v_acc_count := 0;

      SELECT COUNT (*)
        INTO v_acc_count
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
       WHERE     M.N_REF_NO = D.N_REF_NO
             AND M.V_JOURNAL_STATUS = 'C'
             --AND NVL(M.V_REMARKS,'N')!='X'
             AND V_DOCU_TYPE = 'VOUCHER'
             --AND V_DOCU_REF_NO = '2016084503'
             AND V_DOCU_REF_NO = v_voucher_no
             AND (SELECT DISTINCT OFA_ACC_CODE
                    FROM JHL_ISF_OFA_ACC_MAP
                   WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                         AND TRIM (ACC_DESC) = TRIM (d.V_DESC))
                    IS NULL;


      SELECT COUNT (*)
        INTO v_control_acc_count
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
       WHERE     M.N_REF_NO = D.N_REF_NO
             AND M.V_JOURNAL_STATUS = 'C'
             AND V_DOCU_TYPE = 'VOUCHER'
             AND V_DESC LIKE '%PAYMENT CONTROL%'
             AND V_DOCU_REF_NO = v_voucher_no;



      DELETE FROM JHL_OFA_VOUCHER_ERRORS
            WHERE V_VOU_NO = v_voucher_no;



      -- raise_error('v_acc_count=='||v_acc_count);

      IF v_acc_count <> 0
      THEN
         INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO,
                                             V_VOU_NO,
                                             OVE_DESC,
                                             V_GL_CODE,
                                             V_ACC_DESC)
            SELECT JHL_OVE_NO_SEQ.NEXTVAL,
                   v_voucher_no,
                   'MISSING ACCOUNT MAPPING',
                   V_GL_CODE,
                   V_DESC
              FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
             WHERE     M.N_REF_NO = D.N_REF_NO
                   AND M.V_JOURNAL_STATUS = 'C'
                   --AND NVL(M.V_REMARKS,'N')!='X'
                   AND V_DOCU_TYPE = 'VOUCHER'
                   --AND V_DOCU_REF_NO = '2016084503'
                   AND V_DOCU_REF_NO = v_voucher_no
                   AND (SELECT DISTINCT OFA_ACC_CODE
                          FROM JHL_ISF_OFA_ACC_MAP
                         WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                               AND TRIM (ACC_DESC) = TRIM (d.V_DESC))
                          IS NULL;
      --      VALUES(JHL_OVE_NO_SEQ.NEXTVAL, v_voucher_no, 'MISSING ACCOUNT MAPPING');

      END IF;


      IF v_st_error_count <> 0
      THEN
         INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO, V_VOU_NO, OVE_DESC)
              VALUES (
                        JHL_OVE_NO_SEQ.NEXTVAL,
                        v_voucher_no,
                        'ISF ACCOUNTING ENTRIES ERROR');
      END IF;

      IF v_vou_approved <> 'Y'
      THEN
         INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO, V_VOU_NO, OVE_DESC)
              VALUES (
                        JHL_OVE_NO_SEQ.NEXTVAL,
                        v_voucher_no,
                        'VOUCHER IS NOT APPROVED IN ISF ');
      END IF;

      IF v_control_acc_count = 0
      THEN
         INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO, V_VOU_NO, OVE_DESC)
              VALUES (
                        JHL_OVE_NO_SEQ.NEXTVAL,
                        v_voucher_no,
                        'ISF CONTROL ACCOUNT MISSING');
      END IF;



      IF (    vou_count = 0
          AND v_post_count <> 0
          AND v_st_error_count = 0
          AND v_vou_approved = 'Y'
          AND v_acc_count = 0)
      THEN
         --RAISE_ERROR('vou_count=='||vou_count);



         ---get voucher type wheter policy or not
         BEGIN
            SELECT DISTINCT M.V_POLAG_TYPE, M.V_POLAG_NO
              INTO v_pol_type, v_pol_no
              FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
             WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
                   AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                                               --2017005999
                   AND V_DOCU_REF_NO = v_voucher_no;
         EXCEPTION
            WHEN TOO_MANY_ROWS
            THEN
               BEGIN
                  SELECT DISTINCT M.V_POLAG_TYPE, M.V_POLAG_NO
                    INTO v_pol_type, v_pol_no
                    FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
                   WHERE     M.N_REF_NO = D.N_REF_NO
                         AND M.V_JOURNAL_STATUS = 'C'
                         --AND NVL(M.V_REMARKS,'N')!='X'
                         AND V_DOCU_TYPE = 'VOUCHER'
                         --AND V_DOCU_REF_NO = '2016084503'
                         --2017005999
                         AND V_DOCU_REF_NO = v_voucher_no
                         AND M.V_POLAG_NO IN (SELECT V_POLICY_NO
                                                FROM PYDT_VOUCHER_POLICY_CLIENT
                                               WHERE V_VOU_NO = v_voucher_no);
               EXCEPTION
                  WHEN TOO_MANY_ROWS
                  THEN
                     v_pol_type := 'M';
                     v_pol_no := 'N';
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR ('many rows==' || v_voucher_no);
               END;
            WHEN OTHERS
            THEN
               RAISE_ERROR ('Error getting voucher type ==' || v_voucher_no);
         END;

         IF v_pol_type IS NULL OR v_pol_no IS NULL
         THEN
            raise_error ('policy type is null ==' || v_voucher_no);
         END IF;


         FOR v IN voucher
         LOOP
            v_desc := v.V_VOU_DESC;
            payee_name := v.V_PAYEE_NAME;
            v_n_cust_ref_no := v.N_CUST_REF_NO;
            company_code := v.V_COMPANY_CODE;
            company_branch := V.V_COMPANY_BRANCH;
            ind_company := v.V_IND_COMPANY;
            MAIN_VOU_NO := v.V_MAIN_VOU_NO;
            v_pay_amount := v.N_VOU_AMOUNT;
            v_sign := SIGN (v.N_VOU_AMOUNT);
            v_vou_date := v.D_VOU_DATE;
            currency_code := V.V_currency_code;
         END LOOP;

         v_vou_auth_date :=
            JHL_GEN_PKG.get_voucher_approval_date (v_voucher_no);


         SELECT DISTINCT
                DECODE ( (JHL_GEN_PKG.get_entry_channel (M.N_REF_NO)),
                        '10', '11',
                        '30', '12',
                        '11')
                   CHANNEL,
                DECODE (V_LOB_CODE,  'LOB001', '12',  'LOB003', '11',  '12')
                   PRODUCT
           INTO v_channel, v_product
           FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
          WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
                AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                AND V_DOCU_REF_NO = v_voucher_no AND ROWNUM = 1;



         --                   v_pol_no := NULL;
         --                   policy_no := NULL;
         v_vendor_name := payee_name;
         v_pol_payer := v_n_cust_ref_no;
         v_co_code := company_code;
         v_co_brh := company_branch;
         v_site_code := NULL;
         v_pin_no := NULL;
         v_diff_payee_name := NULL;
         v_pay_group := NULL;

         IF v_pol_payer IS NOT NULL
         THEN
            SELECT MAX (VENDOR_SITE_CODE)
              INTO v_site_code
              FROM (SELECT P.V_POLICY_NO VENDOR_SITE_CODE
                      FROM GNMT_POLICY P,
                           GNMT_CUSTOMER_MASTER C,
                           GNLU_PAY_METHOD PM
                     WHERE     P.N_PAYER_REF_NO = C.N_CUST_REF_NO
                           AND P.V_PMT_METHOD_CODE = PM.V_PMT_METHOD_CODE(+)
                           --AND V_CNTR_STAT_CODE = 'NB010'
                           AND C.N_CUST_REF_NO = v_pol_payer
                    UNION
                    SELECT TO_CHAR ('PYR-' || C.N_CUST_REF_NO)
                              VENDOR_SITE_CODE
                      FROM Ammm_Agent_Master AGN, Gnmt_Customer_Master C
                     WHERE AGN.N_Cust_Ref_No = C.N_Cust_Ref_No --AND AGN.V_STATUS  'A'
                           AND C.N_CUST_REF_NO = v_pol_payer
                    UNION
                    SELECT TO_CHAR ('PYR-' || C.N_CUST_REF_NO)
                              VENDOR_SITE_CODE
                      FROM Gnmt_Customer_Master C
                     WHERE     TO_CHAR (C.N_CUST_REF_NO) NOT IN
                                  (SELECT AGN.N_CUST_REF_NO
                                     FROM AMMM_AGENT_MASTER AGN
                                    WHERE AGN.N_CUST_REF_NO IS NOT NULL
                                   UNION ALL
                                   SELECT POL.N_PAYER_REF_NO
                                     FROM GNMT_POLICY POL
                                    WHERE POL.N_PAYER_REF_NO IS NOT NULL)
                           AND C.N_CUST_REF_NO = v_pol_payer);
         ELSE
            SELECT MAX (VENDOR_SITE_CODE)
              INTO v_site_code
              FROM (SELECT P.V_POLICY_NO VENDOR_SITE_CODE
                      FROM Gnmt_Policy P,
                           GNMM_COMPANY_MASTER C,
                           GNMM_POLICY_STATUS_MASTER STATUS,
                           GNLU_INSTITUTION_TYPE INS,
                           GNLU_PAY_METHOD PM
                     WHERE     P.V_Company_Code = C.V_Company_Code
                           AND P.V_Company_Branch = C.V_Company_Branch
                           AND P.V_CNTR_STAT_CODE = STATUS.V_STATUS_CODE
                           AND C.V_INST_TYPE = INS.V_INST_TYPE
                           AND P.V_PMT_METHOD_CODE = PM.V_PMT_METHOD_CODE
                           --AND  V_STATUS_DESC IN ('IN-FORCE')

                           AND C.V_COMPANY_CODE = v_co_code
                           AND C.V_COMPANY_BRANCH = v_co_brh
                    UNION
                    SELECT SUBSTR (
                              TO_CHAR (
                                    C.V_Company_Code
                                 || '-'
                                 || c.V_COMPANY_BRANCH),
                              1,
                              15)
                              VENDOR_SITE_CODE
                      FROM GNMM_COMPANY_MASTER C,
                           AMMM_AGENT_MASTER AGN,
                           GNLU_INSTITUTION_TYPE INS
                     WHERE     C.V_Company_Code = AGN.V_Company_Code
                           AND C.V_Company_Branch = AGN.V_Company_Branch
                           AND C.V_INST_TYPE = INS.V_INST_TYPE
                           --AND AGN.V_STATUS = 'A'
                           AND AGN.V_COMPANY_CODE = v_co_code
                           AND AGN.V_COMPANY_BRANCH = v_co_brh
                           AND AGN.N_AGENT_NO =
                                  NVL (v_agent_no, AGN.N_AGENT_NO)
                    UNION
                    SELECT SUBSTR (
                              TO_CHAR (
                                    C.V_Company_Code
                                 || '-'
                                 || c.V_COMPANY_BRANCH),
                              1,
                              15)
                              VENDOR_SITE_CODE
                      FROM Gnmm_Company_Master C
                     WHERE     1 = 1
                           AND C.V_COMPANY_CODE = v_co_code
                           AND C.V_COMPANY_BRANCH = v_co_brh
                           AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
                                  (SELECT AGN.V_COMPANY_CODE,
                                          AGN.V_COMPANY_BRANCH
                                     FROM AMMM_AGENT_MASTER AGN
                                    WHERE AGN.V_COMPANY_CODE IS NOT NULL)
                           AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
                                  (SELECT P.V_COMPANY_CODE,
                                          P.V_COMPANY_BRANCH
                                     FROM Gnmt_Policy P,
                                          GNMM_POLICY_STATUS_MASTER STATUS
                                    WHERE     P.V_CNTR_STAT_CODE =
                                                 STATUS.V_STATUS_CODE
                                          AND P.V_COMPANY_CODE IS NOT NULL-- AND  V_STATUS_DESC IN ('IN-FORCE')

                                  ));
         END IF;



         IF v_pol_type = 'P'
         THEN
            policy_no := v_pol_no;
            --                        v_site_code :=v_pol_no;
            v_pay_group := 'LIFE-CLAIM';


            IF v_pol_payer IS NOT NULL
            THEN
               CREATE_INDIVIDUAL_SUPPLIER_NEW (v_pol_payer);


               BEGIN
                  v_pin_no := JHL_BI_UTILS.get_ind_customer_pin (v_pol_payer);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || v_pol_payer
                        || ' NAME ='
                        || v_vendor_name);
               END;

               /*getting Phone   12-02-2020*/

               BEGIN
                  SELECT V_CONTACT_NUMBER
                    INTO v_email_no
                    FROM GNDT_CUSTMOBILE_CONTACTS
                   WHERE     1 = 1
                         AND V_CONTACT_CODE = 'CONT003'
                         AND N_CUST_REF_NO = v_pol_payer
                         AND V_Contact_Number LIKE '%@%';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_email_no := NULL;
               END;

               BEGIN
                  SELECT V_CONTACT_NUMBER
                    INTO v_phone_no
                    FROM GNDT_CUSTMOBILE_CONTACTS
                   WHERE     1 = 1
                         AND V_CONTACT_CODE = 'CONT010'
                         AND N_CUST_REF_NO = v_pol_payer
                         AND V_Contact_Number NOT LIKE '%@%';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_phone_no := NULL;
               END;
            ELSE
               CREATE_CORPORATE_SUPPLIER_NEW (v_co_code, v_co_brh);

               BEGIN
                  v_pin_no :=
                     JHL_BI_UTILS.get_co_customer_pin (v_co_code, v_co_brh);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || v_co_code
                        || ' BRN ='
                        || v_co_brh);
               END;


               /*get corporate email n phone 12-feb-2020*/

               BEGIN
                  SELECT V_Contact_Number
                    INTO v_email_no
                    FROM Gndt_Compmobile_Contacts H
                   WHERE     H.V_Company_Code = v_co_code
                         AND H.V_Company_Branch = v_co_brh
                         AND V_CONTACT_CODE = 'CONT003'
                         AND V_Contact_Number LIKE '%@%';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_email_no := NULL;
               END;

               BEGIN
                  SELECT V_Contact_Number
                    INTO v_phone_no
                    FROM Gndt_Compmobile_Contacts H
                   WHERE     H.V_Company_Code = v_co_code
                         AND H.V_Company_Branch = v_co_brh
                         AND V_CONTACT_CODE IN ('CONT009', 'CONT010')
                         AND V_Contact_Number LIKE '%@%';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_phone_no := NULL;
               END;
            END IF;
         ELSE
            IF v_pol_type = 'M' AND v_desc = 'Medical Fees Payment'
            THEN
               v_pay_group := 'LIFE-CLAIM';
            ELSIF v_pol_type = 'M' AND v_desc <> 'Medical Fees Payment'
            THEN
               RAISE_ERROR (
                  'v_pol_type==' || v_pol_type || 'v_desc==' || v_desc);
            ELSE
               v_pay_group := 'LIFE-COMMISSION';
            END IF;

            IF ind_company = 'I'
            THEN
               --                                                 v_site_code := NVL(policy_no, 'PYR-'||v_n_cust_ref_no);


               CREATE_INDIVIDUAL_SUPPLIER_NEW (v_n_cust_ref_no);

               BEGIN
                  v_pin_no :=
                     JHL_BI_UTILS.get_ind_customer_pin (v_n_cust_ref_no);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || v_n_cust_ref_no
                        || ' NAME ='
                        || payee_name);
               END;

               IF v_site_code IS NULL
               THEN
                  raise_error (
                        ' Site Code missing '
                     || v_n_cust_ref_no
                     || ' ;;;;'
                     || v_desc
                     || ' ;;;;'
                     || policy_no);
               END IF;
            ELSE
               --                                        v_site_code :=  NVL(policy_no,SUBSTR( to_char(company_code ||'-'||company_branch),1,15) );

               CREATE_CORPORATE_SUPPLIER_NEW (company_code, company_branch);


               BEGIN
                  v_pin_no :=
                     JHL_BI_UTILS.get_co_customer_pin (company_code,
                                                       company_branch);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || company_code
                        || ' BRN ='
                        || company_branch);
               END;
            END IF;
         END IF;



         v_count := 0;

         FOR I IN VOUCHERS
         LOOP
            --                 if i.ACCT_CODE <> '310001' then
            IF ( i.V_DESC NOT LIKE ('%PAYMENT CONTROL%') and nvl(v_pay_amount,0) >0)
            THEN
               v_count := v_count + 1;

               v_amount := I.AMOUNT * v_sign * -1;

               v_leg_sup_code := NULL;



               IF v_pol_type = 'P'
               THEN
                  v_leg_sup_code :=
                     NVL (TO_CHAR (v_pol_payer),
                          TO_CHAR (v_co_code || '-' || v_co_brh));
               ELSE
                  v_leg_sup_code :=
                     NVL (TO_CHAR (v_n_cust_ref_no),
                          TO_CHAR (company_code || '-' || company_branch));
               END IF;

               --
               IF (TO_DATE (v_vou_date, 'DD/MM/RRRR') < '31-JUL-17')
               THEN
                  v_vou_date := SYSDATE;
                  RAISE_ERROR (
                        'v_vou =='
                     || i.V_VOU_NO
                     || 'v_vou_date=='
                     || v_vou_date
                     || 'v_vou_auth_date=='
                     || v_vou_auth_date);
               END IF;

               IF (TO_DATE (v_vou_auth_date, 'DD/MM/RRRR') < '31-JUL-17')
               THEN
                  v_vou_auth_date := SYSDATE;
                  RAISE_ERROR (
                        'v_vou =='
                     || i.V_VOU_NO
                     || 'v_vou_date=='
                     || v_vou_date
                     || 'v_vou_auth_date=='
                     || v_vou_auth_date);
               END IF;


               IF (JHL_BI_UTILS.is_voucher_annuity (i.V_VOU_NO) = 'Y')
               THEN
                  v_pay_group := 'LIFE-ANNUITY';
               END IF;

               IF (JHL_BI_UTILS.CHECK_VALID_PIN (v_pin_no) <> 'Y')
               THEN
                  IF v_pin_no IS NULL
                  THEN
                     INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO,
                                                         V_VOU_NO,
                                                         OVE_DESC,
                                                         V_SUP_CODE)
                          VALUES (
                                    JHL_OVE_NO_SEQ.NEXTVAL,
                                    v_voucher_no,
                                       'MISSING CLIENT PIN  ::'
                                    || v_pin_no
                                    || ' Client Code:: '
                                    || v_leg_sup_code
                                    || ' Name :: '
                                    || NVL (v_vendor_name, i.VENDOR_NAME),
                                    v_leg_sup_code);
                  ELSE
                     INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO,
                                                         V_VOU_NO,
                                                         OVE_DESC,
                                                         V_SUP_CODE)
                          VALUES (
                                    JHL_OVE_NO_SEQ.NEXTVAL,
                                    v_voucher_no,
                                       'INVALID CLIENT PIN  ::>'
                                    || v_pin_no
                                    || '< Client Code:: '
                                    || v_leg_sup_code
                                    || ' Name :: '
                                    || NVL (v_vendor_name, i.VENDOR_NAME),
                                    v_leg_sup_code);
                  END IF;
               END IF;



               IF (    v_amount <> 0
                   AND JHL_BI_UTILS.CHECK_VALID_PIN (v_pin_no) = 'Y')
               THEN
                  INSERT
                    INTO JHL_OFA_PYMT_TRANSACTIONS (OPT_NO,
                                                    V_VOU_NO,
                                                    LEGACY_SUPPLIER_CODE,
                                                    VENDOR_NAME,
                                                    VENDOR_SITE_CODE,
                                                    INVOICE_AMOUNT,
                                                    INVOICE_CURRENCY_CODE,
                                                    EXCHANGE_RATE,
                                                    DESCRIPTION,
                                                    LIABILITY_ACCOUNT,
                                                    LINE_NUMBER,
                                                    LEGACY_REF1,
                                                    LINE_AMOUNT,
                                                    N_CUST_REF_NO,
                                                    V_COMPANY_CODE,
                                                    V_COMPANY_BRANCH,
                                                    V_MAIN_VOU_NO,
                                                    LEGACY_REF3,
                                                    V_VOU_DATE,
                                                    LEGACY_REF11,
                                                    V_VOU_DESC,
                                                    PAY_GROUP_LOOKUP_CODE,
                                                    OPT_DATE,
                                                    POL_TYPE,
                                                    POL_NO,
                                                    DIF_N_CUST_REF_NO,
                                                    DIF_V_COMPANY_CODE,
                                                    DIF_V_COMPANY_BRANCH,
                                                    OPT_VOU_APPROVAL_DT,
                                                    PAYMENT_METHOD_CODE,
                                                    CAPTURED_BY,
                                                    VERIFIED_BY,
                                                    APPROVED_BY,
                                                    CAPTURED_DT,
                                                    VERIFIED_DT,
                                                    APPROVED_DT,
                                                    OPT_BRANCH_CODE,
                                                    OPT_CHANNEL_CODE,
                                                    OPT_PRODUCT_CODE,
                                                    VENDOR_EMAIL_ADDRESS,
                                                    VENDOR_PHONE,
                                                    CREATED_AT)
                  VALUES (
                            OFA_OPT_NO_SEQ.NEXTVAL,
                            i.V_VOU_NO,
                            v_leg_sup_code,
                            NVL (v_vendor_name, i.VENDOR_NAME),
                            v_site_code,
                            v_pay_amount,
                            currency_code,
                            I.N_CONVERSION_RATE,
                            I.V_DESC,
                            I.OFA_ACC_CODE,
                            v_count,
                            v_pin_no,
                            v_amount,
                            v_pol_payer,
                            v_co_code,
                            v_co_brh,
                            main_vou_no,
                            policy_no,
                            v_vou_date,
                            v_diff_payee_name,
                            v_desc,
                            v_pay_group,
                            SYSDATE,
                            v_pol_type,
                            v_pol_no,
                            v_n_cust_ref_no,
                            company_code,
                            company_branch,
                            v_vou_auth_date,
                            DECODE (
                               jhl_gen_pkg.get_voucher_payment_method (
                                  i.V_VOU_NO),
                               'EFT', 'EFT',
                               'CHECK'),
                            JHL_GEN_PKG.GET_VOUCHER_STATUS_USER (i.V_VOU_NO,
                                                                 'PREPARE'),
                            JHL_GEN_PKG.GET_VOUCHER_STATUS_USER (i.V_VOU_NO,
                                                                 'VERIFY'),
                            JHL_GEN_PKG.GET_VOUCHER_STATUS_USER (i.V_VOU_NO,
                                                                 'APPROVE'),
                            JHL_GEN_PKG.GET_VOUCHER_DATE (i.V_VOU_NO,
                                                          'PREPARE'),
                            JHL_GEN_PKG.GET_VOUCHER_DATE (i.V_VOU_NO,
                                                          'VERIFY'),
                            JHL_GEN_PKG.GET_VOUCHER_DATE (i.V_VOU_NO,
                                                          'APPROVE'),
                            '210',
                            v_channel,
                            v_product,
                            v_email_no,
                            v_phone_no,
                            SYSDATE);
               END IF;
            END IF;
         END LOOP;

         SELECT SUM (LINE_AMOUNT)
           INTO v_total_amount
           FROM JHL_OFA_PYMT_TRANSACTIONS
          WHERE V_VOU_NO = v_voucher_no;

         UPDATE JHL_OFA_PYMT_TRANSACTIONS
            SET INVOICE_AMOUNT = v_total_amount
          WHERE V_VOU_NO = v_voucher_no;

         --          raise_error('v_total_amount=='||v_total_amount);

         BEGIN
            SELECT COUNT (*)
              INTO v_exist_count
              FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
             WHERE     LOB_NAME = 'JHL_UG_LIF_OU'
                   AND PAYMENT_VOUCHER = v_voucher_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_exist_count := 0;
         END;

         /* 12-FEB-2020 EFT COMMENT ON 04-FEB-21*/
         /* IF (jhl_gen_pkg.get_voucher_payment_method(v_voucher_no) = 'EFT' ) THEN

            JHL_OFA_UTILS.create_voucher_bank_details(v_voucher_no);
            END IF;*/


         /*
    IF v_exist_count = 0 and v_total_amount <> 0 THEN

            JHL_OFA_GL_VOUCHERS_NEW(v_voucher_no);

    END IF;


    */

         IF v_exist_count = 0
         THEN
            BEGIN
               SELECT COUNT (*)
                 INTO v_exist_count
                 FROM XXJICUG_AP_INVOICES_STG@JICOFPROD.COM
                WHERE     OPERATING_UNIT = 'JHL_UG_LIF_OU'
                      AND VOUCHER_NUM = v_voucher_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_exist_count := 0;
            END;
         END IF;


         --IF (jhl_gen_pkg.get_voucher_payment_method(v_voucher_no) = 'EFT')
         --THEN
         --JHL_OFA_UTILS.create_voucher_bank_details(v_voucher_no);
         --END IF;



         IF (v_exist_count = 0 AND v_total_amount <> 0)
         THEN
            JHL_OFA_GL_VOUCHERS_NEW (v_voucher_no);
         END IF;


         IF ( (v_exist_count = 0 AND v_total_amount = 0) or (v_pay_amount = 0))
         THEN
----             raise_error('v_pay_amount1=='||v_pay_amount);
            create_ofa_cancelled_pymt_gl (v_voucher_no);
         END IF;
--         raise_error('v_pay_amount2=='||v_pay_amount);
      END IF;
   --exception
   --when others then
   --dbms_output.put_line('Backtrace => '||dbms_utility.format_error_backtrace);
   --raise_error('v_voucher_no=='||v_voucher_no);

   END;



   PROCEDURE JHL_OFA_TRANSFORM_GL_VOU_040221 (v_voucher_no VARCHAR2)
   IS
      CURSOR VOUCHERS
      IS
           /*SELECT V_GL_CODE ACCT_CODE,V_PROCESS_CODE, sum(decode(V_TYPE,'D',-N_AMT,N_AMT)) AMOUNT, decode(V_DESC,'INCOME_TAX','WHT TAX',V_DESC)  V_DESC,

                                    (SELECT  distinct OFA_ACC_CODE
                                                        FROM JHL_ISF_OFA_ACC_MAP
                                                          WHERE TRIM(ISF_GL_CODE) = TRIM(D.V_GL_CODE)
                                                        and TRIM(ACC_DESC) = TRIM(d.V_DESC))  OFA_ACC_CODE,   decode( sign(sum(decode(V_TYPE,'D',-N_AMT,N_AMT))),-1,1,2) ORD,
                                    V_DOCU_REF_NO V_VOU_NO,BPG_FINANCE_BATCHES.BFN_GET_PAYEE_NAME(V_DOCU_REF_NO) VENDOR_NAME,
                                   ABS( sum(decode(V_TYPE,'D',-N_AMT,N_AMT)) ) AMT

           FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
           WHERE M.N_REF_NO = D.N_REF_NO
           AND M.V_JOURNAL_STATUS = 'C'
           --AND NVL(M.V_REMARKS,'N')!='X'
           AND V_DOCU_TYPE='VOUCHER'
           --AND V_DOCU_REF_NO = '2016084503'
            AND V_DOCU_REF_NO = v_voucher_no
           -- AND to_date(M.D_POSTED_DATE,'DD/MM/RRRR') BETWEEN to_date('01-JAN-18','DD/MM/RRRR')  AND to_date('23-JUL-17','DD/MM/RRRR')
           group by  V_GL_CODE,V_PROCESS_CODE,V_DESC,V_DOCU_REF_NO
           ORDER BY ORD,AMT DESC;*/


           SELECT V_GL_CODE ACCT_CODE,
                  V_PROCESS_CODE,
                  SUM (DECODE (V_TYPE, 'D', -N_SOURCE_AMOUNT, N_SOURCE_AMOUNT))
                     AMOUNT,
                  DECODE (V_DESC, 'INCOME_TAX', 'WHT TAX', V_DESC) V_DESC,
                  /*(select  distinct  OFA_ACC_CODE
                                           from JHL_OFA_ACC_MAP ACCS
                                           where  --ACCS.V_GL_CODE =  D.V_GL_CODE
                                            OFA_ACC_CODE IS NOT NULL
                                           AND ACCS.V_DESC = D.V_DESC) */
                  (SELECT DISTINCT OFA_ACC_CODE
                     FROM JHL_ISF_OFA_ACC_MAP
                    WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                          AND TRIM (ACC_DESC) = TRIM (d.V_DESC))
                     OFA_ACC_CODE,
                  DECODE (
                     SIGN (
                        SUM (
                           DECODE (V_TYPE,
                                   'D', -N_SOURCE_AMOUNT,
                                   N_SOURCE_AMOUNT))),
                     -1, 1,
                     2)
                     ORD,
                  V_DOCU_REF_NO V_VOU_NO,
                  BPG_FINANCE_BATCHES.BFN_GET_PAYEE_NAME (V_DOCU_REF_NO)
                     VENDOR_NAME,
                  ABS (
                     SUM (
                        DECODE (V_TYPE, 'D', -N_SOURCE_AMOUNT, N_SOURCE_AMOUNT)))
                     AMT,
                  N_CONVERSION_RATE
             FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
            WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
                  AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                  AND V_DOCU_REF_NO = v_voucher_no
         -- AND to_date(M.D_POSTED_DATE,'DD/MM/RRRR') BETWEEN to_date('01-JUL-17','DD/MM/RRRR')  AND to_date('23-JUL-17','DD/MM/RRRR')
         GROUP BY V_GL_CODE,
                  V_PROCESS_CODE,
                  V_DESC,
                  V_DOCU_REF_NO,
                  N_CONVERSION_RATE
         ORDER BY ORD, AMT DESC;


      CURSOR voucher
      IS
         SELECT V_VOU_DESC,
                V_PAYEE_NAME,
                N_CUST_REF_NO,
                V_COMPANY_CODE,
                V_COMPANY_BRANCH,
                V_IND_COMPANY,
                PM.V_MAIN_VOU_NO V_MAIN_VOU_NO,
                N_VOU_AMOUNT,
                D_VOU_DATE,
                DECODE (V_currency_code, 'UGS', 'UGX', V_currency_code)
                   V_currency_code
           FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
          WHERE     PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND PV.V_VOU_NO = v_voucher_no;



      payee_name          VARCHAR (400);
      v_n_cust_ref_no     NUMBER (25);
      company_code        VARCHAR2 (20);
      company_branch      VARCHAR2 (50);
      ind_company         VARCHAR2 (2);


      v_pay_amount        NUMBER;
      v_sign              NUMBER;
      v_gross_amt         NUMBER;
      v_account           VARCHAR2 (50);
      v_desc              VARCHAR2 (200);
      v_acct_code         VARCHAR2 (50);
      v_count             NUMBER;
      policy_no           VARCHAR2 (30);
      v_pin_no            VARCHAR2 (30);

      v_amount            NUMBER;
      MAIN_VOU_NO         VARCHAR2 (50);
      vou_count           NUMBER;
      v_site_code         VARCHAR2 (50);

      v_total_amount      NUMBER;

      v_error_message     VARCHAR2 (1000);
      v_exist_count       NUMBER := 0;
      v_vou_date          DATE;

      v_agent_no          NUMBER;
      currency_code       VARCHAR2 (100);

      v_policy_count      NUMBER;

      v_pol_type          VARCHAR2 (2);
      v_pol_no            VARCHAR2 (250);

      v_pol_payer         NUMBER (25);
      v_co_code           VARCHAR2 (20);
      v_co_brh            VARCHAR2 (50);
      v_diff_payee_name   VARCHAR (400);
      v_vendor_name       VARCHAR (400);
      v_pay_group         VARCHAR2 (50);

      v_post_count        NUMBER := 0;
      v_leg_sup_code      VARCHAR2 (150);

      v_vou_auth_date     DATE;

      v_st_error_count    NUMBER := 0;
      v_vou_approved      VARCHAR2 (5) := 'N';

      v_channel           VARCHAR2 (30);
      v_product           VARCHAR2 (30);
      v_acc_count         NUMBER := 0;
   BEGIN
      v_post_count := 0;


      SELECT COUNT (*)
        INTO v_post_count
        --INTO v_pol_type, v_pol_no
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
       WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
             AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                                         --2017005999
             AND V_DOCU_REF_NO = v_voucher_no;

      vou_count := 0;

      SELECT COUNT (*)
        INTO vou_count
        FROM JHL_OFA_PYMT_TRANSACTIONS
       WHERE V_VOU_NO = v_voucher_no;


      v_st_error_count := 0;

      SELECT COUNT (*)
        INTO v_st_error_count
        --INTO v_pol_type, v_pol_no
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
       WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS <> 'C' --AND NVL(M.V_REMARKS,'N')!='X'
             AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                                         --2017005999
             AND V_DOCU_REF_NO = v_voucher_no;

      v_vou_approved := 'N';

      v_vou_approved := JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED (v_voucher_no);

      v_acc_count := 0;

      SELECT COUNT (*)
        INTO v_acc_count
        FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
       WHERE     M.N_REF_NO = D.N_REF_NO
             AND M.V_JOURNAL_STATUS = 'C'
             --AND NVL(M.V_REMARKS,'N')!='X'
             AND V_DOCU_TYPE = 'VOUCHER'
             --AND V_DOCU_REF_NO = '2016084503'
             AND V_DOCU_REF_NO = v_voucher_no
             AND (SELECT DISTINCT OFA_ACC_CODE
                    FROM JHL_ISF_OFA_ACC_MAP
                   WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                         AND TRIM (ACC_DESC) = TRIM (d.V_DESC))
                    IS NULL;

      DELETE FROM JHL_OFA_VOUCHER_ERRORS
            WHERE V_VOU_NO = v_voucher_no;

      IF v_acc_count <> 0
      THEN
         INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO,
                                             V_VOU_NO,
                                             OVE_DESC,
                                             V_GL_CODE,
                                             V_ACC_DESC)
            SELECT JHL_OVE_NO_SEQ.NEXTVAL,
                   v_voucher_no,
                   'MISSING ACCOUNT MAPPING',
                   V_GL_CODE,
                   V_DESC
              FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
             WHERE     M.N_REF_NO = D.N_REF_NO
                   AND M.V_JOURNAL_STATUS = 'C'
                   --AND NVL(M.V_REMARKS,'N')!='X'
                   AND V_DOCU_TYPE = 'VOUCHER'
                   --AND V_DOCU_REF_NO = '2016084503'
                   AND V_DOCU_REF_NO = v_voucher_no
                   AND (SELECT DISTINCT OFA_ACC_CODE
                          FROM JHL_ISF_OFA_ACC_MAP
                         WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                               AND TRIM (ACC_DESC) = TRIM (d.V_DESC))
                          IS NULL;
      END IF;


      IF v_st_error_count <> 0
      THEN
         INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO, V_VOU_NO, OVE_DESC)
              VALUES (
                        JHL_OVE_NO_SEQ.NEXTVAL,
                        v_voucher_no,
                        'ISF ACCOUNTING ENTRIES ERROR');
      END IF;

      IF v_vou_approved <> 'Y'
      THEN
         INSERT INTO JHL_OFA_VOUCHER_ERRORS (OVE_NO, V_VOU_NO, OVE_DESC)
              VALUES (
                        JHL_OVE_NO_SEQ.NEXTVAL,
                        v_voucher_no,
                        'VOUCHER IS NOT APPROVED IN ISF ');
      END IF;



      IF (    vou_count = 0
          AND v_post_count <> 0
          AND v_st_error_count = 0
          AND v_vou_approved = 'Y'
          AND v_acc_count = 0)
      THEN
         --RAISE_ERROR('vou_count=='||vou_count);



         ---get voucher type wheter policy or not
         BEGIN
            SELECT DISTINCT M.V_POLAG_TYPE, M.V_POLAG_NO
              INTO v_pol_type, v_pol_no
              FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
             WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
                   AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                                               --2017005999
                   AND V_DOCU_REF_NO = v_voucher_no;
         EXCEPTION
            WHEN TOO_MANY_ROWS
            THEN
               BEGIN
                  SELECT DISTINCT M.V_POLAG_TYPE, M.V_POLAG_NO
                    INTO v_pol_type, v_pol_no
                    FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
                   WHERE     M.N_REF_NO = D.N_REF_NO
                         AND M.V_JOURNAL_STATUS = 'C'
                         --AND NVL(M.V_REMARKS,'N')!='X'
                         AND V_DOCU_TYPE = 'VOUCHER'
                         --AND V_DOCU_REF_NO = '2016084503'
                         --2017005999
                         AND V_DOCU_REF_NO = v_voucher_no
                         AND M.V_POLAG_NO IN (SELECT V_POLICY_NO
                                                FROM PYDT_VOUCHER_POLICY_CLIENT
                                               WHERE V_VOU_NO = v_voucher_no);
               EXCEPTION
                  WHEN TOO_MANY_ROWS
                  THEN
                     v_pol_type := 'M';
                     v_pol_no := 'N';
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR ('many rows==' || v_voucher_no);
               END;
            WHEN OTHERS
            THEN
               RAISE_ERROR ('Error getting voucher type ==' || v_voucher_no);
         END;

         IF v_pol_type IS NULL OR v_pol_no IS NULL
         THEN
            raise_error ('policy type is null ==' || v_voucher_no);
         END IF;


         FOR v IN voucher
         LOOP
            v_desc := v.V_VOU_DESC;
            payee_name := v.V_PAYEE_NAME;
            v_n_cust_ref_no := v.N_CUST_REF_NO;
            company_code := v.V_COMPANY_CODE;
            company_branch := V.V_COMPANY_BRANCH;
            ind_company := v.V_IND_COMPANY;
            MAIN_VOU_NO := v.V_MAIN_VOU_NO;
            v_pay_amount := v.N_VOU_AMOUNT;
            v_sign := SIGN (v.N_VOU_AMOUNT);
            v_vou_date := v.D_VOU_DATE;
            currency_code := V.V_currency_code;
         END LOOP;

         v_vou_auth_date :=
            JHL_GEN_PKG.get_voucher_approval_date (v_voucher_no);

         SELECT DISTINCT
                DECODE ( (JHL_GEN_PKG.get_entry_channel (M.N_REF_NO)),
                        '10', '11',
                        '30', '12',
                        '11')
                   CHANNEL,
                DECODE (V_LOB_CODE,  'LOB001', '12',  'LOB003', '11',  '12')
                   PRODUCT
           INTO v_channel, v_product
           FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
          WHERE M.N_REF_NO = D.N_REF_NO AND M.V_JOURNAL_STATUS = 'C' --AND NVL(M.V_REMARKS,'N')!='X'
                AND V_DOCU_TYPE = 'VOUCHER' --AND V_DOCU_REF_NO = '2016084503'
                AND V_DOCU_REF_NO = v_voucher_no AND ROWNUM = 1;

         --  raise_error('v_vou_auth_date=='||v_vou_auth_date);

         policy_no := NULL;
         v_vendor_name := NULL;
         v_pol_payer := NULL;
         v_co_code := NULL;
         v_co_brh := NULL;
         v_site_code := NULL;
         v_pin_no := NULL;
         v_diff_payee_name := NULL;
         v_pay_group := NULL;

         IF v_pol_type = 'P'
         THEN
            policy_no := v_pol_no;
            v_site_code := v_pol_no;
            v_pay_group := 'LIFE-CLAIM';


            SELECT N_PAYER_REF_NO, P.V_COMPANY_CODE, P.V_COMPANY_BRANCH
              INTO v_pol_payer, v_co_code, v_co_brh
              FROM GNMT_POLICY P
             WHERE P.V_POLICY_NO = v_pol_no;

            IF v_pol_payer IS NOT NULL
            THEN
               SELECT N_PAYER_REF_NO, V_NAME
                 INTO v_pol_payer, v_vendor_name
                 FROM GNMT_POLICY P, GNMT_CUSTOMER_MASTER C
                WHERE     P.N_PAYER_REF_NO = C.N_CUST_REF_NO
                      AND P.V_POLICY_NO = v_pol_no;

               IF NVL (v_pol_payer, -2000) <> NVL (v_n_cust_ref_no, -2001)
               THEN
                  v_diff_payee_name := payee_name;
               ELSE
                  v_diff_payee_name := NULL;
               END IF;


               CREATE_INDIVIDUAL_SUPPLIER_NEW (v_pol_payer);

               BEGIN
                  SELECT OSP_PIN_NO
                    INTO v_pin_no
                    FROM JHL_OFA_SUPPLIER
                   WHERE N_CUST_REF_NO = v_pol_payer;
               EXCEPTION
                  --                                            when no_data_found then
                  --                                            v_pin_no  := null;
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || v_pol_payer
                        || ' NAME ='
                        || v_vendor_name);
               --                                    v_error_message := 'ERROR GETTING pIN NUMBER  CO CODE=='||company_code|| ' BRN ='||company_branch;
               END;
            ELSE
               SELECT P.V_COMPANY_CODE, P.V_COMPANY_BRANCH, V_COMPANY_NAME
                 INTO v_co_code, v_co_brh, v_vendor_name
                 FROM Gnmt_Policy P, GNMM_COMPANY_MASTER C
                WHERE     P.V_Company_Code = C.V_Company_Code
                      AND P.V_Company_Branch = C.V_Company_Branch
                      AND P.V_POLICY_NO = v_pol_no;


               IF (    NVL (company_code, 'EIRUWIW') =
                          NVL (v_co_code, 'KSDFYUEY')
                   AND NVL (company_branch, 'KSDFYUEY') =
                          NVL (v_co_brh, 'EIRUWIW'))
               THEN
                  v_diff_payee_name := NULL;
               ELSE
                  v_diff_payee_name := payee_name;
               END IF;



               CREATE_CORPORATE_SUPPLIER_NEW (v_co_code, v_co_brh);

               --                                                                              raise_error('company_code=='||company_code||'company_branch=='||company_branch||'v_agent_no=='||v_agent_no);

               BEGIN
                  SELECT CSP_PIN_NO
                    INTO v_pin_no
                    FROM JHL_OFA_CO_SUPPLIER
                   WHERE     V_COMPANY_CODE = v_co_code
                         AND V_COMPANY_BRANCH = v_co_brh;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || v_co_code
                        || ' BRN ='
                        || v_co_brh);
               END;
            END IF;
         ELSE
            IF v_pol_type = 'M' AND v_desc = 'Medical Fees Payment'
            THEN
               v_pay_group := 'LIFE-CLAIM';
            ELSIF v_pol_type = 'M' AND v_desc <> 'Medical Fees Payment'
            THEN
               /* 25th January 2021
                RAISE_ERROR('v_pol_type=='||v_pol_type||'v_desc=='||v_desc);*/
               v_pay_group := 'LIFE-CLAIM';
            ELSE
               v_pay_group := 'LIFE-CLAIM';
            END IF;

            IF ind_company = 'I'
            THEN
               v_site_code := NVL (policy_no, 'PYR-' || v_n_cust_ref_no);


               CREATE_INDIVIDUAL_SUPPLIER_NEW (v_n_cust_ref_no);

               BEGIN
                  SELECT OSP_PIN_NO
                    INTO v_pin_no
                    FROM JHL_OFA_SUPPLIER
                   WHERE N_CUST_REF_NO = v_n_cust_ref_no;
               EXCEPTION
                  --                                            when no_data_found then
                  --                                            v_pin_no  := null;
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || v_n_cust_ref_no
                        || ' NAME ='
                        || payee_name);
               --                                    v_error_message := 'ERROR GETTING pIN NUMBER  CO CODE=='||company_code|| ' BRN ='||company_branch;
               END;



               IF v_site_code IS NULL
               THEN
                  raise_error (
                        ' Site Code missing '
                     || v_n_cust_ref_no
                     || ' ;;;;'
                     || v_desc
                     || ' ;;;;'
                     || policy_no);
               END IF;
            ELSE
               v_site_code :=
                  NVL (
                     policy_no,
                     SUBSTR (TO_CHAR (company_code || '-' || company_branch),
                             1,
                             15));

               --                                                   raise_error('company_code=='||company_code||'company_branch=='||company_branch||'v_agent_no=='||v_agent_no);
               CREATE_CORPORATE_SUPPLIER_NEW (company_code, company_branch);

               --                                                                              raise_error('company_code=='||company_code||'company_branch=='||company_branch||'v_agent_no=='||v_agent_no);

               BEGIN
                  SELECT CSP_PIN_NO
                    INTO v_pin_no
                    FROM JHL_OFA_CO_SUPPLIER
                   WHERE     V_COMPANY_CODE = company_code
                         AND V_COMPANY_BRANCH = company_branch;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE_ERROR (
                           'ERROR GETTING pIN NUMBER  CO CODE=='
                        || company_code
                        || ' BRN ='
                        || company_branch);
               END;
            END IF;
         END IF;



         v_count := 0;

         FOR I IN VOUCHERS
         LOOP
            IF i.ACCT_CODE <> '115092'
            THEN
               v_count := v_count + 1;



               v_amount := I.AMOUNT * v_sign * -1;



               v_leg_sup_code := NULL;

               IF v_pol_type = 'P'
               THEN
                  v_leg_sup_code :=
                     NVL (TO_CHAR (v_pol_payer),
                          TO_CHAR (v_co_code || '-' || v_co_brh));
               ELSE
                  v_leg_sup_code :=
                     NVL (TO_CHAR (v_n_cust_ref_no),
                          TO_CHAR (company_code || '-' || company_branch));
               END IF;


               IF (I.OFA_ACC_CODE IS NULL)
               THEN
                  raise_error (
                     'ofa account is null V_VOU_NO== ' || i.V_VOU_NO);
               END IF;


               IF v_amount <> 0
               THEN
                  INSERT
                    INTO JHL_OFA_PYMT_TRANSACTIONS (OPT_NO,
                                                    V_VOU_NO,
                                                    LEGACY_SUPPLIER_CODE,
                                                    VENDOR_NAME,
                                                    VENDOR_SITE_CODE,
                                                    INVOICE_AMOUNT,
                                                    INVOICE_CURRENCY_CODE,
                                                    EXCHANGE_RATE,
                                                    DESCRIPTION,
                                                    LIABILITY_ACCOUNT,
                                                    LINE_NUMBER,
                                                    LEGACY_REF1,
                                                    LINE_AMOUNT,
                                                    N_CUST_REF_NO,
                                                    V_COMPANY_CODE,
                                                    V_COMPANY_BRANCH,
                                                    V_MAIN_VOU_NO,
                                                    LEGACY_REF3,
                                                    V_VOU_DATE,
                                                    LEGACY_REF11,
                                                    V_VOU_DESC,
                                                    PAY_GROUP_LOOKUP_CODE,
                                                    OPT_DATE,
                                                    POL_TYPE,
                                                    POL_NO,
                                                    DIF_N_CUST_REF_NO,
                                                    DIF_V_COMPANY_CODE,
                                                    DIF_V_COMPANY_BRANCH,
                                                    OPT_VOU_APPROVAL_DT,
                                                    PAYMENT_METHOD_CODE,
                                                    CAPTURED_BY,
                                                    VERIFIED_BY,
                                                    APPROVED_BY,
                                                    CAPTURED_DT,
                                                    VERIFIED_DT,
                                                    APPROVED_DT,
                                                    OPT_BRANCH_CODE,
                                                    OPT_CHANNEL_CODE,
                                                    OPT_PRODUCT_CODE)
                  VALUES (
                            OFA_OPT_NO_SEQ.NEXTVAL,
                            i.V_VOU_NO,
                            v_leg_sup_code,
                            NVL (v_vendor_name, i.VENDOR_NAME),
                            v_site_code,
                            v_pay_amount,
                            currency_code,
                            I.N_CONVERSION_RATE,
                            I.V_DESC,
                            I.OFA_ACC_CODE,
                            v_count,
                            v_pin_no,
                            v_amount,
                            v_pol_payer,
                            v_co_code,
                            v_co_brh,
                            main_vou_no,
                            policy_no,
                            v_vou_date,
                            v_diff_payee_name,
                            v_desc,
                            v_pay_group,
                            SYSDATE,
                            v_pol_type,
                            v_pol_no,
                            v_n_cust_ref_no,
                            company_code,
                            company_branch,
                            v_vou_auth_date,
                            'CHECK', --decode(jhl_gen_pkg.get_voucher_payment_method(i.V_VOU_NO),'EFT','EFT','CHECK' ),
                            JHL_GEN_PKG.GET_VOUCHER_STATUS_USER (i.V_VOU_NO,
                                                                 'PREPARE'),
                            JHL_GEN_PKG.GET_VOUCHER_STATUS_USER (i.V_VOU_NO,
                                                                 'VERIFY'),
                            JHL_GEN_PKG.GET_VOUCHER_STATUS_USER (i.V_VOU_NO,
                                                                 'APPROVE'),
                            JHL_GEN_PKG.GET_VOUCHER_DATE (i.V_VOU_NO,
                                                          'PREPARE'),
                            JHL_GEN_PKG.GET_VOUCHER_DATE (i.V_VOU_NO,
                                                          'VERIFY'),
                            JHL_GEN_PKG.GET_VOUCHER_DATE (i.V_VOU_NO,
                                                          'APPROVE'),
                            '210',
                            v_channel,
                            v_product);
               END IF;
            END IF;
         END LOOP;

         SELECT SUM (LINE_AMOUNT)
           INTO v_total_amount
           FROM JHL_OFA_PYMT_TRANSACTIONS
          WHERE V_VOU_NO = v_voucher_no;

         UPDATE JHL_OFA_PYMT_TRANSACTIONS
            SET INVOICE_AMOUNT = v_total_amount
          WHERE V_VOU_NO = v_voucher_no;

         BEGIN
            SELECT COUNT (*)
              INTO v_exist_count
              FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
             WHERE     LOB_NAME = 'JHL_UG_LIF_OU'
                   AND PAYMENT_VOUCHER = v_voucher_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_exist_count := 0;
         END;


         /*
    IF v_exist_count = 0 and v_total_amount <> 0 THEN

            JHL_OFA_GL_VOUCHERS_NEW(v_voucher_no);

    END IF;


    */

         IF v_exist_count = 0
         THEN
            BEGIN
               SELECT COUNT (*)
                 INTO v_exist_count
                 FROM XXJICUG_AP_INVOICES_STG@JICOFPROD.COM
                WHERE     OPERATING_UNIT = 'JHL_UG_LIF_OU'
                      AND VOUCHER_NUM = v_voucher_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_exist_count := 0;
            END;
         END IF;


         IF (v_exist_count = 0 AND v_total_amount <> 0)
         THEN
            JHL_OFA_GL_VOUCHERS_NEW (v_voucher_no);
         END IF;


         IF (v_exist_count = 0 AND v_total_amount = 0)
         THEN
            create_ofa_cancelled_pymt_gl (v_voucher_no);
         END IF;
      END IF;
   --exception
   --when others then
   --raise_error('v_voucher_no=='||v_voucher_no);
   END;

   FUNCTION BFN_GET_PAYEE_NAME (P_VOUCHER_NO VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR CR_PAYEE_NAME
      IS
         SELECT V_PAYEE_NAME,
                V_COMPANY_CODE,
                V_COMPANY_BRANCH,
                V_IND_COMPANY
           FROM PYMT_VOU_MASTER
          WHERE V_VOU_NO = P_VOUCHER_NO;

      CURSOR CR_COMP_NAME (
         P_COMP_CODE     IN VARCHAR2,
         P_COMP_BRANCH   IN VARCHAR2)
      IS
         SELECT V_COMPANY_NAME
           FROM GNMM_COMPANY_MASTER
          WHERE     V_COMPANY_CODE = P_COMP_CODE
                AND V_COMPANY_BRANCH = P_COMP_BRANCH;


      LV_IND_COMP       VARCHAR2 (2000);
      LV_COMP_CODE      VARCHAR2 (2000);
      LV_COMP_BRANCH    VARCHAR2 (2000);
      LV_PAYEE_NAME     VARCHAR2 (2000);
      LV_COMPANY_NAME   VARCHAR2 (2000);
      LV_PAYEE          VARCHAR2 (2000);
   BEGIN
      OPEN CR_PAYEE_NAME;

      FETCH CR_PAYEE_NAME
      INTO LV_PAYEE_NAME, LV_IND_COMP, LV_COMP_CODE, LV_COMP_BRANCH;

      CLOSE CR_PAYEE_NAME;

      OPEN CR_COMP_NAME (LV_COMP_CODE, LV_COMP_BRANCH);

      FETCH CR_COMP_NAME INTO LV_COMPANY_NAME;

      CLOSE CR_COMP_NAME;

      IF LV_IND_COMP = 'I'
      THEN
         LV_PAYEE := LV_PAYEE_NAME;
      ELSIF LV_IND_COMP = 'C'
      THEN
         LV_PAYEE := LV_COMPANY_NAME;
      ELSE
         LV_PAYEE := NULL;
      END IF;

      RETURN NVL (LV_PAYEE_NAME, '');
   END;


   PROCEDURE delete_supplier_master
   IS
   BEGIN
      DELETE FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
            WHERE PAY_GROUP IN ('ISF-INDIVIDUAL-CLAIM', 'ISF-CORPORATE');

      DELETE FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
            WHERE PAY_GRP_LKP_CODE IN
                     ('ISF-INDIVIDUAL-CLAIM', 'ISF-CORPORATE');

      DELETE FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
            WHERE OPERATING_UNIT = 'JHL_UG_LIF_OU';
   END;

   --    PROCEDURE delete_customer_master IS
   --  begin
   --
   --  delete from  XXJIC_AR_CUSTOMERS_STG@JICOFPROD.COM
   --where ORGANIZATION_NAME = 'JHL_UG_LIF_OU' ;
   --
   --delete from XXJIC_AR_CUSTOMERS_CONTACT_STG@JICOFPROD.COM
   --where ORGANIZATION_NAME = 'JHL_UG_LIF_OU' ;
   --
   --  end;


   PROCEDURE ofa_gl_trans_proc
   IS
      v_start_date   DATE;
   BEGIN
      v_start_date := SYSDATE;

      create_ofa_receivable_trans;
      transform_ofa_receivable_trans;
      transform_ofa_gl_trans;
      SEND_GL_TRANS_TO_OFA;


      INSERT INTO JHL_OFA_JOBS (OJB_ID,
                                OJB_NAME,
                                OJB_START_DT,
                                OJB_END_DT)
           VALUES (JHL_OJB_ID_SEQ.NEXTVAL,
                   'ofa_gl_trans_proc',
                   v_start_date,
                   SYSDATE);

      COMMIT;
   END;



   PROCEDURE create_ofa_receivable_trans
   IS
      CURSOR refs
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
   -- AND V_DOCU_TYPE = 'RECEIPT' ;
   --AND V_DOCU_REF_NO = 'DN2994474'   ;

   BEGIN
      --DELETE FROM JHL_OFA_GL_TRANSACTIONS;

      --  select  count(*)
      --from JHL_OFA_GL_TRANSACTIONS

      FOR I IN refs
      LOOP
         BEGIN
            /*
                    INSERT INTO JHL_OFA_GL_TRANSACTIONS(OGLT_NO, N_REF_NO, D_DATE, V_BRANCH_CODE, V_LOB_CODE,
                    V_PROCESS_CODE, V_PROCESS_NAME, V_DOCU_TYPE, V_DOCU_REF_NO, V_GL_CODE, V_DESC, V_TYPE, N_AMT,OFA_ACC_CODE,V_SOURCE_CURRENCY)

                     SELECT JHL_OGLT_NO_SEQ.NEXTVAL,M.N_REF_NO, M.D_DATE, V_BRANCH_CODE, V_LOB_CODE, nvl(V_PROCESS_CODE,'N/A') V_PROCESS_CODE,nvl((SELECT V_PROCESS_NAME
                  FROM GNMM_PROCESS_MASTER
                  WHERE V_PROCESS_ID = V_PROCESS_CODE),nvl(V_PROCESS_CODE,'N/A')) V_PROCESS_NAME,V_DOCU_TYPE,V_DOCU_REF_NO,V_GL_CODE ,V_DESC ,V_TYPE, N_AMT,
                   (select  distinct  OFA_ACC_CODE
                                           FROM JHL_OFA_RCT_ACC_MAP ACCS
                                           where OFA_ACC_CODE IS NOT NULL
                                           and  ACCS.V_DESC = D.V_DESC
                                           ) OFA_ACC_CODE,'UGX'
                  FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
                  WHERE M.N_REF_NO = D.N_REF_NO
                  AND M.V_JOURNAL_STATUS = 'C'
                  AND NVL(M.V_REMARKS,'N') != 'X'
                  AND V_DOCU_TYPE !='VOUCHER'
                  AND V_PROCESS_CODE NOT IN ('ACT021','RIACT01')
                    AND M.N_REF_NO = I.N_REF_NO;*/



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
                                                 V_SUN_JV)
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
                      NVL (V_DESC, 'XX'),
                      V_TYPE,
                      N_AMT,
                      /* NVL((select  distinct  OFA_ACC_CODE
                                               FROM JHL_OFA_RCT_ACC_MAP ACCS
                                               where ACCS.V_GL_CODE =  D.V_GL_CODE
                                               AND OFA_ACC_CODE IS NOT NULL
                                               and  ACCS.V_DESC = D.V_DESC
                                               ),'NA') OFA_ACC_CODE*/

                      NVL (
                         (SELECT DISTINCT OFA_ACC_CODE
                            FROM JHL_ISF_OFA_ACC_MAP
                           WHERE     TRIM (ISF_GL_CODE) = TRIM (D.V_GL_CODE)
                                 AND TRIM (ACC_DESC) = TRIM (D.V_DESC)),
                         'N')
                         OFA_ACC_CODE,
                      'UGX',
                      M.V_POLAG_TYPE,
                      M.V_POLAG_NO,
                      M.D_POSTED_DATE,
                      M.V_REMARKS
                 FROM GNMT_GL_MASTER M, GNDT_GL_DETAILS D
                WHERE     M.N_REF_NO = D.N_REF_NO
                      AND M.V_JOURNAL_STATUS = 'C'
                      AND NVL (M.V_REMARKS, 'N') != 'X'
                      AND V_DOCU_TYPE != 'VOUCHER'
                      AND V_PROCESS_CODE NOT IN ('ACT021', 'RIACT01')
                      --and m.V_REMARKS = 'SUN_JV_0000058485'
                      --AND V_DOCU_REF_NO = 'DN2994474'
                      --   AND TO_DATE(M.D_DATE,'DD/MM/RRRR') BETWEEN '01-NOV-16' AND '01-NOV-16'
                      --                     AND  M.N_REF_NO = 84567979
                      AND M.N_REF_NO = I.N_REF_NO;
         --                    AND M.N_REF_NO NOT IN  ( SELECT ORT.N_REF_NO FROM JHL_OFA_GL_TRANSACTIONS ORT WHERE ORT.N_REF_NO =M.N_REF_NO ) ;



         EXCEPTION
            WHEN OTHERS
            THEN
               --                    NULL;

               RAISE_ERROR ('Error on ref == ' || I.N_REF_NO);
         END;

         --   transform_ofa_gl_trans(I.N_REF_NO);
         COMMIT;
      END LOOP;


      DELETE FROM JHL_OFA_ISF_MIS_MAP;

      INSERT INTO JHL_OFA_ISF_MIS_MAP (V_GL_CODE, V_DESC, N_REF_NO)
         SELECT DISTINCT V_GL_CODE, NVL (V_DESC, 'XX'), N_REF_NO
           FROM JHL_OFA_GL_TRANSACTIONS
          WHERE OFA_ACC_CODE = 'N';


      DELETE FROM JHL_OFA_GL_TRANSACTIONS
            WHERE N_REF_NO IN (SELECT DISTINCT N_REF_NO
                                 FROM JHL_OFA_GL_TRANSACTIONS
                                WHERE OFA_ACC_CODE = 'N');



      COMMIT;
   --  transform_ofa_receivable_trans;
   END;



   PROCEDURE transform_ofa_receivable_trans
   IS
      /*
      CURSOR RCT_BANK IS
      SELECT  N_REF_NO,V_DOCU_REF_NO,TO_DATE(D_DATE,'DD/MM/RRRR') D_DATE
     FROM  JHL_OFA_GL_TRANSACTIONS
     WHERE V_DOCU_TYPE = 'RECEIPT'
     AND OGLT_PROCESSED <> 'Y'
     AND V_PROCESS_CODE  IN ('ACT036')
     --AND 1=2
     --AND TO_DATE(D_DATE,'DD/MM/RRRR')  BETWEEN TO_DATE('01-MAR-17','DD/MM/RRRR') AND TO_DATE('31-MAR-17','DD/MM/RRRR')
     and V_DOCU_REF_NO in (   SELECT  V_RECEIPT_NO
                                             FROM REMT_RECEIPT RCT
                                             WHERE V_RECEIPT_TABLE = 'DETAIL'
     --                                         AND V_BUSINESS_CODE <>  'MISC'
                                             AND TRUNC(D_RECEIPT_DATE) BETWEEN TO_DATE ('01-DEC-17','DD/MM/RRRR')  AND TO_DATE(SYSDATE,'DD/MM/RRRR')
     --                                         AND V_CURRENCY_CODE = 'KES'
                                              );*/



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

      --SELECT DISTINCT  N_REF_NO
      --FROM JHL_OFA_GL_INTERFACE;


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



      v_vgl_no   NUMBER;
   BEGIN
      UPDATE JHL_OFA_GL_TRANSACTIONS
         SET V_LOB_CODE =
                DECODE (JHL_GEN_PKG.get_entry_channel (N_REF_NO),
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


      --UPDATE GL TAX LINE WITH BROKER DETAILS(OB003)
      UPDATE JHL_OFA_GL_TRANSACTIONS
         SET OGTL_DRCR_NARRATION =
                NVL (
                   (SELECT    V_COMPANY_NAME
                           || '-'
                           || N_VOUCHER_NO
                           || '-'
                           || N_GROSS_AMOUNT
                      FROM AMDT_AGENT_BENEFIT_POOL_DETAIL c,
                           AMDT_AGENT_BENE_POOL_PAYMENT d,
                           AMMM_AGENT_MASTER e,
                           GNMM_COMPANY_MASTER f
                     WHERE     V_TRANS_SOURCE_CODE = 'INCOME_TAX'
                           AND c.N_BENEFIT_POOL_PAY_SEQ =
                                  d.N_BENEFIT_POOL_PAY_SEQ
                           AND c.N_AGENT_NO = e.N_AGENT_NO
                           AND NVL (e.V_COMPANY_CODE, 'X') =
                                  NVL (f.V_COMPANY_CODE, 'X')
                           AND NVL (e.V_COMPANY_BRANCH, 'X') =
                                  NVL (f.V_COMPANY_BRANCH, 'X')
                           AND TO_CHAR (c.N_BENEFIT_POOL_SEQ_NO) =
                                  V_DOCU_REF_NO),
                   'X')
       WHERE     OFA_ACC_CODE = '201209'
             AND NVL (TRIM (OGTL_DRCR_NARRATION), 'X') = 'X'
             AND OGLT_PROCESSED <> 'Y';


      --UPDATE IL TAX LINE WITH NAME OF AGENT
      UPDATE JHL_OFA_GL_TRANSACTIONS
         SET OGTL_DRCR_NARRATION =
                NVL (
                   (SELECT    V_NAME
                           || '-'
                           || N_VOUCHER_NO
                           || '-'
                           || N_GROSS_AMOUNT
                      FROM AMDT_AGENT_BENEFIT_POOL_DETAIL c,
                           AMDT_AGENT_BENE_POOL_PAYMENT d,
                           AMMM_AGENT_MASTER e,
                           GNMT_CUSTOMER_MASTER f
                     WHERE     V_TRANS_SOURCE_CODE = 'INCOME_TAX'
                           AND c.N_BENEFIT_POOL_PAY_SEQ =
                                  d.N_BENEFIT_POOL_PAY_SEQ
                           AND c.N_AGENT_NO = e.N_AGENT_NO
                           AND e.N_CUST_REF_NO = f.N_CUST_REF_NO
                           AND TO_CHAR (c.N_BENEFIT_POOL_SEQ_NO) =
                                  V_DOCU_REF_NO),
                   'X')
       WHERE     OFA_ACC_CODE = '201206'
             AND NVL (TRIM (OGTL_DRCR_NARRATION), 'X') = 'X'
             AND OGLT_PROCESSED <> 'Y';


      /*
      FOR I IN RCT_BANK LOOP

      UPDATE JHL_OFA_GL_TRANSACTIONS
      SET D_DATE =  (SELECT  DISTINCT D_RECEIPT_DATE
                                            FROM REMT_RECEIPT RCT
                                            WHERE V_RECEIPT_TABLE = 'DETAIL'
                                            AND  V_RECEIPT_NO = I.V_DOCU_REF_NO
                                            AND ROWNUM =1),
               OGLT_D_DATE = I.D_DATE
      WHERE N_REF_NO  = I.N_REF_NO
      AND V_DOCU_REF_NO = I.V_DOCU_REF_NO;


      END LOOP;*/



      --  select *
      --from JHL_OFA_GL_INTERFACE;
      --
      --delete from JHL_OFA_GL_INTERFACE;



      FOR R IN RCT_SUMMARY
      LOOP
         SELECT JGL_OFA_VGL_NO_SEQ.NEXTVAL INTO v_vgl_no FROM DUAL;


         NULL;



         UPDATE JHL_OFA_GL_TRANSACTIONS
            SET OGLT_PROCESSED = 'Y',
                OGLT_PROCESSED_DT = SYSDATE,
                OFA_VGL_NO = v_vgl_no,
                OFA_VGL_CODE =
                   'OFA_JV_' || TO_CHAR (R.D_DATE, 'YYYY') || '_' || v_vgl_no
          WHERE     V_DOCU_REF_NO = R.V_DOCU_REF_NO
                AND TO_DATE (D_DATE, 'DD/MM/RRRR') =
                       TO_DATE (R.D_DATE, 'DD/MM/RRRR')
                AND V_DOCU_TYPE = 'RECEIPT'
                AND OGLT_PROCESSED <> 'Y';
      --        RAISE_APPLICATION_ERROR(-20001,'v_vgl_no=='||v_vgl_no||'N_REF_NO=='||R.N_REF_NO );

      --          DBMS_OUTPUT.PUT_LINE('v_vgl_no:' || v_vgl_no || ' vgl_code:' || 'OFA_JV_'||to_char(R.D_DATE,'YYYY')||'_'||v_vgl_no);

      END LOOP;

      --      RAISE_ERROR('HERE==');

      FOR C IN NON_RCT_SUMMARY
      LOOP
         --           RAISE_ERROR('BEFORE LOOP==');
         SELECT JGL_OFA_VGL_NO_SEQ.NEXTVAL INTO v_vgl_no FROM DUAL;

         UPDATE JHL_OFA_GL_TRANSACTIONS
            SET OGLT_PROCESSED = 'Y',
                OGLT_PROCESSED_DT = SYSDATE,
                OFA_VGL_NO = v_vgl_no,
                OFA_VGL_CODE =
                   'OFA_JV_' || TO_CHAR (C.D_DATE, 'YYYY') || '_' || v_vgl_no
          WHERE     V_PROCESS_CODE = C.V_PROCESS_CODE
                AND V_LOB_CODE = C.V_LOB_CODE
                AND TO_DATE (D_DATE, 'DD/MM/RRRR') =
                       TO_DATE (C.D_DATE, 'DD/MM/RRRR')
                AND V_DOCU_TYPE <> 'RECEIPT'
                AND OGLT_PROCESSED <> 'Y';


         UPDATE GNMT_GL_MASTER GL
            SET V_REMARKS =
                   'OFA_JV_' || TO_CHAR (C.D_DATE, 'YYYY') || '_' || v_vgl_no
          WHERE GL.N_REF_NO IN (SELECT DISTINCT TRN.N_REF_NO
                                  FROM JHL_OFA_GL_TRANSACTIONS TRN
                                 WHERE TRN.OFA_VGL_NO = v_vgl_no);
      --                     RAISE_ERROR('AFTER LOOP==');

      -- RAISE_APPLICATION_ERROR(-20001,'v_vgl_no=='||v_vgl_no||'V_LOB_CODE=='||C.V_LOB_CODE||'D_DATE =='||C.D_DATE );
      --          DBMS_OUTPUT.PUT_LINE('v_vgl_no:' || v_vgl_no || ' vgl_code:' || 'OFA_JV_'||to_char(C.D_DATE,'YYYY')||'_'||v_vgl_no);
      --            COMMIT;

      END LOOP;

      COMMIT;
   --  transform_ofa_gl_trans;
   END;



   PROCEDURE transform_ofa_gl_trans
   IS
      CURSOR RCT_TRANS
      IS
         SELECT 'NEW' STATUS,
                '2024' SET_OF_BOOKS_ID,
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
                DECODE (V_LOB_CODE,  'LOB001', '12',  'LOB003', '11',  '00')
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
                          --    and V_DOCU_REF_NO = 'DN2994474'
                          -- and N_REF_NO = v_n_ref_no
                          AND OGLT_PROCESSED = 'Y'
                          AND OGLT_POSTED = 'N'
                          AND V_DOCU_TYPE = 'RECEIPT'
                          AND TRANS.OFA_VGL_NO NOT IN
                                 (SELECT OFA_VGL_NO
                                    FROM JHL_OFA_GL_INTERFACE INTER
                                   WHERE INTER.OFA_VGL_NO = TRANS.OFA_VGL_NO)
                          AND TO_DATE (D_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                        '01-JAN-20',
                                                                        'DD/MM/RRRR')
                                                                 AND TO_DATE (
                                                                        SYSDATE,
                                                                        'DD/MM/RRRR')
                 --    AND TO_DATE(D_DATE,'DD/MM/RRRR') BETWEEN '28-DEC-16' AND  '30-DEC-16'
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
                          V_DOCU_TYPE,
                          OFA_VGL_NO,
                          OFA_VGL_CODE);

      CURSOR NON_RCT_TRANS
      IS
         SELECT 'NEW' STATUS,
                '2024' SET_OF_BOOKS_ID,
                'ISF LIFE' USER_JE_SOURCE_NAME,
                'ISF Others' USER_JE_CATEGORY_NAME,
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
                DECODE (V_LOB_CODE,  'LOB001', '12',  'LOB003', '11',  '00')
                   SEGMENT4,
                OFA_ACC_CODE SEGMENT5,
                '00' SEGMENT6,
                '000' SEGMENT7,
                '000' SEGMENT8,
                OFA_VGL_NO GROUP_ID,
                V_PROCESS_CODE || '-' || V_PROCESS_NAME JOURNAL_DESCRIPTION,
                V_DESC LINE_DESCRIPTION,
                OFA_VGL_NO REFERENCE,
                TO_CHAR (D_DATE, 'DD-MON-YY') REFERENCE_DATE,
                OFA_VGL_CODE REFERENCE1,
                'ISF Others' REFERENCE2,
                NULL N_REF_NO,
                V_BRANCH_CODE,
                V_LOB_CODE,
                V_PROCESS_CODE,
                D_DATE,
                OFA_VGL_NO,
                OFA_VGL_CODE,
                OGTL_DRCR_NARRATION
           FROM (  SELECT TO_DATE (D_DATE, 'DD/MM/RRRR') D_DATE,
                          V_BRANCH_CODE,
                          V_LOB_CODE,
                          V_PROCESS_CODE,
                          V_PROCESS_NAME,
                          V_GL_CODE,
                          V_DESC,
                          V_TYPE,
                          SUM (N_AMT) N_AMT,
                          V_SOURCE_CURRENCY,
                          OFA_ACC_CODE,
                          OFA_VGL_NO,
                          OFA_VGL_CODE,
                          OGTL_DRCR_NARRATION
                     FROM JHL_OFA_GL_TRANSACTIONS TRANS
                    WHERE     1 = 1
                          AND OGLT_PROCESSED = 'Y'
                          AND OGLT_POSTED = 'N'
                          AND V_DOCU_TYPE <> 'RECEIPT'
                          AND TRANS.OFA_VGL_NO NOT IN
                                 (SELECT OFA_VGL_NO
                                    FROM JHL_OFA_NON_RCT_GL_INTER INTER
                                   WHERE INTER.OFA_VGL_NO = TRANS.OFA_VGL_NO)
                          AND TO_DATE (D_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                                        '01-JAN-20',
                                                                        'DD/MM/RRRR')
                                                                 AND TO_DATE (
                                                                        SYSDATE,
                                                                        'DD/MM/RRRR')
                 GROUP BY TO_DATE (D_DATE, 'DD/MM/RRRR'),
                          V_BRANCH_CODE,
                          V_LOB_CODE,
                          V_PROCESS_CODE,
                          V_PROCESS_NAME,
                          V_GL_CODE,
                          V_DESC,
                          V_TYPE,
                          V_SOURCE_CURRENCY,
                          OFA_ACC_CODE,
                          OFA_VGL_NO,
                          OFA_VGL_CODE,
                          OGTL_DRCR_NARRATION);


      --CURSOR  RCT_SUMMARY IS
      --SELECT  N_REF_NO,SUM(NVL(ENTERED_DR,0)) DR, SUM(NVL(ENTERED_CR,0)) CR,
      --SUM(NVL(ENTERED_DR,0)) - SUM(NVL(ENTERED_CR,0))  DIF,REFERENCE1,D_DATE
      --FROM JHL_OFA_GL_INTERFACE
      --GROUP BY N_REF_NO,REFERENCE1,D_DATE;
      --
      --CURSOR  NON_RCT_SUMMARY IS
      --SELECT  V_PROCESS_CODE,V_LOB_CODE,D_DATE,SUM(NVL(ENTERED_DR,0)) DR, SUM(NVL(ENTERED_CR,0)) CR,
      --SUM(NVL(ENTERED_DR,0)) - SUM(NVL(ENTERED_CR,0))  DIF
      --FROM JHL_OFA_NON_RCT_GL_INTER
      --GROUP BY V_PROCESS_CODE,V_LOB_CODE,D_DATE;



      v_vgl_no   NUMBER;
   BEGIN
      --  select *
      --from JHL_OFA_GL_INTERFACE;
      --
      --delete from JHL_OFA_GL_INTERFACE;

      --UPDATE JHL_OFA_GL_TRANSACTIONS
      --SET OGLT_POSTED = 'N';

      --DELETE JHL_OFA_GL_INTERFACE;
      --DELETE JHL_OFA_NON_RCT_GL_INTER;



      FOR I IN RCT_TRANS
      LOOP
         INSERT INTO JHL_OFA_GL_INTERFACE (OGLI_NO,
                                           STATUS,
                                           SET_OF_BOOKS_ID,
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
                                           JOURNAL_DESCRIPTION,
                                           LINE_DESCRIPTION,
                                           REFERENCE,
                                           REFERENCE_DATE,
                                           REFERENCE1,
                                           REFERENCE2,
                                           N_REF_NO,
                                           V_BRANCH_CODE,
                                           V_LOB_CODE,
                                           V_PROCESS_CODE,
                                           REFERENCE5,
                                           REFERENCE6,
                                           REFERENCE10,
                                           OGLI_PROCESSED,
                                           V_DOCU_TYPE,
                                           OGLI_POSTED,
                                           D_DATE,
                                           OFA_VGL_NO,
                                           OFA_VGL_CODE,
                                           OGLI_PROCESSED_DT)
              VALUES (JHL_OGLI_NO_SEQ.NEXTVAL,
                      I.STATUS,
                      I.SET_OF_BOOKS_ID,
                      I.USER_JE_SOURCE_NAME,
                      I.USER_JE_CATEGORY_NAME,
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
                      I.JOURNAL_DESCRIPTION,
                      I.LINE_DESCRIPTION,
                      I.REFERENCE,
                      I.REFERENCE_DATE,
                      I.REFERENCE1,
                      I.REFERENCE2,
                      I.N_REF_NO,
                      I.V_BRANCH_CODE,
                      I.V_LOB_CODE,
                      I.V_PROCESS_CODE,
                      I.JOURNAL_DESCRIPTION,
                      I.N_REF_NO,
                      I.LINE_DESCRIPTION,
                      'Y',
                      I.V_DOCU_TYPE,
                      'N',
                      I.D_DATE,
                      I.OFA_VGL_NO,
                      I.OFA_VGL_CODE,
                      SYSDATE);
      --      commit;

      END LOOP;



      FOR J IN NON_RCT_TRANS
      LOOP
         INSERT INTO JHL_OFA_NON_RCT_GL_INTER (OGLI_NO,
                                               STATUS,
                                               SET_OF_BOOKS_ID,
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
                                               JOURNAL_DESCRIPTION,
                                               LINE_DESCRIPTION,
                                               REFERENCE,
                                               REFERENCE_DATE,
                                               REFERENCE1,
                                               REFERENCE2,
                                               N_REF_NO,
                                               V_BRANCH_CODE,
                                               V_LOB_CODE,
                                               V_PROCESS_CODE,
                                               REFERENCE5,
                                               REFERENCE6,
                                               REFERENCE10,
                                               OGLI_PROCESSED,
                                               D_DATE,
                                               V_DOCU_TYPE,
                                               OGLI_POSTED,
                                               OFA_VGL_NO,
                                               OFA_VGL_CODE,
                                               OGLI_PROCESSED_DT,
                                               OGLI_DRCR_NARRATION)
              VALUES (JHL_OGLI_NO_SEQ.NEXTVAL,
                      J.STATUS,
                      J.SET_OF_BOOKS_ID,
                      J.USER_JE_SOURCE_NAME,
                      J.USER_JE_CATEGORY_NAME,
                      J.CURRENCY_CODE,
                      J.ACTUAL_FLAG,
                      J.ACCOUNTING_DATE,
                      J.DATE_CREATED,
                      J.CREATED_BY,
                      J.ENTERED_DR,
                      J.ENTERED_CR,
                      J.SEGMENT1,
                      J.SEGMENT2,
                      J.SEGMENT3,
                      J.SEGMENT4,
                      J.SEGMENT5,
                      J.SEGMENT6,
                      J.SEGMENT7,
                      J.SEGMENT8,
                      J.GROUP_ID,
                      J.JOURNAL_DESCRIPTION,
                      J.LINE_DESCRIPTION,
                      J.REFERENCE,
                      J.REFERENCE_DATE,
                      J.REFERENCE1,
                      J.REFERENCE2,
                      J.N_REF_NO,
                      J.V_BRANCH_CODE,
                      J.V_LOB_CODE,
                      J.V_PROCESS_CODE,
                      J.JOURNAL_DESCRIPTION,
                      J.N_REF_NO,
                      J.LINE_DESCRIPTION,
                      'Y',
                      J.D_DATE,
                      j.USER_JE_CATEGORY_NAME,
                      'N',
                      J.OFA_VGL_NO,
                      J.OFA_VGL_CODE,
                      SYSDATE,
                      J.OGTL_DRCR_NARRATION);
      --      commit;
      END LOOP;


      UPDATE JHL_OFA_GL_INTERFACE
         SET OGLI_RECEIPT_NO =
                (SELECT DISTINCT V_OTHER_REF_NO
                   FROM REMT_RECEIPT b
                  WHERE     V_RECEIPT_TABLE = 'DETAIL'
                        AND b.V_RECEIPT_NO = REFERENCE1
                        AND ROWNUM = 1),
             OGLI_RECEIPT_SOURCE =
                (SELECT DISTINCT V_SOURCE
                   FROM REMT_RECEIPT b
                  WHERE     V_RECEIPT_TABLE = 'DETAIL'
                        AND b.V_RECEIPT_NO = REFERENCE1
                        AND ROWNUM = 1),
             OGLI_OTHER_REF_DATE =
                (SELECT DISTINCT D_OTHER_REF_DATE
                   FROM REMT_RECEIPT b
                  WHERE     V_RECEIPT_TABLE = 'DETAIL'
                        AND b.V_RECEIPT_NO = REFERENCE1
                        AND ROWNUM = 1),
             OGLI_RCT_PAYEE =
                TRIM (JHL_GEN_PKG.get_receipt_payee (REFERENCE1)),
             OGLI_INS_NUMBER =
                (SELECT DISTINCT V_INS_NUMBER
                   FROM REMT_RECEIPT RCT, REMT_RECEIPT_INSTRUMENTS RCT_INS
                  WHERE     RCT.N_RECEIPT_SESSION = RCT_INS.N_RECEIPT_SESSION
                        AND RCT.V_RECEIPT_TABLE = 'DETAIL'
                        AND RCT.V_RECEIPT_NO = REFERENCE1
                        AND ROWNUM = 1)
       WHERE OGLI_PROCESSED = 'Y' AND NVL (OGLI_POSTED, 'Y') <> 'Y';

      /* update pension receipts*/

      UPDATE JHL_OFA_GL_INTERFACE
         SET SEGMENT1 = '222',
             SEGMENT4 = '00',
             USER_JE_CATEGORY_NAME = 'DA-Receipts',
             USER_JE_SOURCE_NAME = 'DA-PENSION'
       WHERE     jhl_gen_pkg.is_pension_receipt (REFERENCE1) = 'Y'
             AND OGLI_PROCESSED = 'Y'
             AND NVL (OGLI_POSTED, 'Y') <> 'Y';



      UPDATE JHL_OFA_GL_TRANSACTIONS
         SET OGLT_POSTED = 'Y', OGLT_POSTED_DATE = SYSDATE
       WHERE     OGLT_PROCESSED = 'Y'
             AND TO_DATE (D_DATE, 'DD/MM/RRRR') BETWEEN TO_DATE (
                                                           '01-DEC-21',
                                                           'DD/MM/RRRR')
                                                    AND TO_DATE (
                                                           SYSDATE,
                                                           'DD/MM/RRRR')
             AND OGLT_POSTED <> 'Y'
             AND OFA_VGL_NO IN
                    (SELECT OFA_VGL_NO
                       FROM JHL_OFA_NON_RCT_GL_INTER
                      WHERE OGLI_PROCESSED = 'Y' AND OGLI_POSTED = 'N'
                     UNION ALL
                     SELECT OFA_VGL_NO
                       FROM JHL_OFA_GL_INTERFACE
                      WHERE OGLI_PROCESSED = 'Y' AND OGLI_POSTED = 'N');



      COMMIT;
   --      FOR R IN RCT_SUMMARY LOOP
   --
   --        SELECT JGL_OFA_VGL_NO_SEQ.NEXTVAL
   --                  INTO v_vgl_no
   --                  FROM DUAL;
   --
   --
   --             UPDATE  JHL_OFA_GL_INTERFACE
   --             SET OFA_VGL_NO = v_vgl_no,
   --                   OFA_VGL_CODE = 'OFA_JV_'||to_char(R.D_DATE,'YYYY')||'_'||v_vgl_no,
   --                   OGLI_PROCESSED = 'Y',
   --                   GROUP_ID = v_vgl_no,
   --                REFERENCE = v_vgl_no,
   --                REFERENCE1 = R.REFERENCE1
   --              WHERE N_REF_NO = R.N_REF_NO;
   --
   --              UPDATE JHL_OFA_GL_TRANSACTIONS
   --              SET  OGLT_PROCESSED = 'Y',
   --               OGLT_PROCESSED_DT = SYSDATE,
   --               OFA_VGL_NO =v_vgl_no ,
   --               OFA_VGL_CODE =  'OFA_JV_'||to_char(R.D_DATE,'YYYY')||'_'||v_vgl_no
   --              WHERE N_REF_NO = R.N_REF_NO ;
   --
   --
   --          DBMS_OUTPUT.PUT_LINE('v_vgl_no:' || v_vgl_no || ' vgl_code:' || 'OFA_JV_'||to_char(R.D_DATE,'YYYY')||'_'||v_vgl_no);
   --       commit;
   --
   --      END LOOP;
   --
   --
   --          FOR C IN NON_RCT_SUMMARY LOOP
   --
   --                  SELECT JGL_OFA_VGL_NO_SEQ.NEXTVAL
   --                  INTO v_vgl_no
   --                  FROM DUAL;
   --
   --
   --             UPDATE  JHL_OFA_NON_RCT_GL_INTER
   --             SET OFA_VGL_NO = v_vgl_no,
   --                   OFA_VGL_CODE = 'OFA_JV_'||to_char(C.D_DATE,'YYYY')||'_'||v_vgl_no,
   --                   OGLI_PROCESSED = 'Y',
   --                   GROUP_ID = v_vgl_no,
   --                REFERENCE = v_vgl_no,
   --                REFERENCE1 = 'OFA_JV_'||to_char(C.D_DATE,'YYYY')||'_'||v_vgl_no
   --              WHERE V_PROCESS_CODE = C.V_PROCESS_CODE
   --              AND V_LOB_CODE =C.V_LOB_CODE
   --              AND TO_DATE(D_DATE,'DD/MM/RRRR') = TO_DATE(C.D_DATE,'DD/MM/RRRR');
   --
   --               UPDATE JHL_OFA_GL_TRANSACTIONS
   --              SET  OGLT_PROCESSED = 'Y',
   --               OGLT_PROCESSED_DT = SYSDATE,
   --               OFA_VGL_NO =v_vgl_no ,
   --               OFA_VGL_CODE =  'OFA_JV_'||to_char(C.D_DATE,'YYYY')||'_'||v_vgl_no
   --              WHERE V_PROCESS_CODE = C.V_PROCESS_CODE
   --              AND V_LOB_CODE =C.V_LOB_CODE
   --              AND TO_DATE(D_DATE,'DD/MM/RRRR') = TO_DATE(C.D_DATE,'DD/MM/RRRR');
   --
   --
   --          DBMS_OUTPUT.PUT_LINE('v_vgl_no:' || v_vgl_no || ' vgl_code:' || 'OFA_JV_'||to_char(C.D_DATE,'YYYY')||'_'||v_vgl_no);
   --           commit;
   --          END LOOP;


   --        send to ofa
   --      SEND_GL_TRANS_TO_OFA(v_n_ref_no);


   --      UPDATE JHL_OFA_GL_TRANSACTIONS
   --      SET  OGLT_PROCESSED = 'Y'
   --      WHERE N_REF_NO = v_n_ref_no;



   END;



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
          WHERE 1 = 1 --    AND N_REF_NO = v_n_ref_no
                AND OGLI_PROCESSED = 'Y' AND OGLI_POSTED = 'N'
         --      AND TO_DATE(D_DATE,'DD/MM/RRRR')  BETWEEN TO_DATE('01-OCT-17','DD/MM/RRRR') AND TO_DATE(SYSDATE,'DD/MM/RRRR')
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
                TO_CHAR (REFERENCE) REFERENCE,
                REFERENCE_DATE,
                REFERENCE1,
                REFERENCE2,
                N_REF_NO,
                V_BRANCH_CODE,
                V_LOB_CODE,
                V_PROCESS_CODE,
                REFERENCE5,
                DECODE (OGLI_DRCR_NARRATION, 'X', NULL, OGLI_DRCR_NARRATION)
                   REFERENCE6,
                DECODE (
                   NVL (OGLI_SUN_JV, 'XX'),
                   'XX', REFERENCE10 || '-' || REFERENCE1,
                   REFERENCE10 || '-' || REFERENCE1 || '-' || OGLI_SUN_JV)
                   REFERENCE10,
                OGLI_PROCESSED,
                V_DOCU_TYPE,
                OFA_VGL_NO,
                OFA_VGL_CODE,
                OGLI_POSTED,
                D_DATE
           FROM JHL_OFA_NON_RCT_GL_INTER
          WHERE 1 = 1 --    AND N_REF_NO = v_n_ref_no
                AND OGLI_PROCESSED = 'Y' AND OGLI_POSTED = 'N';
   BEGIN
      --     select *
      -- from APPS.gl_interface@JICOFPROD.COM
      -- where SET_OF_BOOKS_ID ='2021';
      --
      --  delete from  APPS.gl_interface@JICOFPROD.COM where SET_OF_BOOKS_ID ='2021';

      --          UPDATE JHL_OFA_GL_INTERFACE
      --              SET OGLI_POSTED = 'N';
      --
      --              UPDATE JHL_OFA_NON_RCT_GL_INTER
      --              SET OGLI_POSTED = 'N';
      --
      --        select JHL_OFA_GL_INTERFACE.*,     (SELECT DISTINCT  V_OTHER_REF_NO
      --                 FROM REMT_RECEIPT b
      --                 WHERE V_RECEIPT_TABLE='DETAIL'
      --                 AND b.V_RECEIPT_NO=REFERENCE1) RECEIPT_NO
      --             from JHL_OFA_GL_INTERFACE;
      ----             where OFA_VGL_CODE = 'OFA_JV_2017_1191311';

      FOR I IN TRANS
      LOOP
         INSERT INTO APPS.gl_interface@JICOFPROD.COM (STATUS,
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
              VALUES (i.STATUS,
                      i.SET_OF_BOOKS_ID,
                      i.SET_OF_BOOKS_ID,
                      TRIM (i.USER_JE_SOURCE_NAME),
                      TRIM (i.USER_JE_CATEGORY_NAME),
                      i.CURRENCY_CODE,
                      i.ACTUAL_FLAG,
                      i.ACCOUNTING_DATE,
                      i.DATE_CREATED,
                      i.CREATED_BY,
                      i.ENTERED_DR,
                      i.ENTERED_CR,
                      i.SEGMENT1,
                      i.SEGMENT2,
                      i.SEGMENT3,
                      i.SEGMENT4,
                      i.SEGMENT5,
                      i.SEGMENT6,
                      i.SEGMENT7,
                      i.SEGMENT8,
                      i.GROUP_ID,
                      i.REFERENCE5,
                      i.REFERENCE10,
                      i.REFERENCE6,
                      i.REFERENCE_DATE,
                      i.REFERENCE1,
                      i.REFERENCE2);


         UPDATE JHL_OFA_GL_INTERFACE
            SET OGLI_POSTED = 'Y', OGLI_POSTED_DATE = SYSDATE
          WHERE OGLI_NO = I.OGLI_NO;

         UPDATE JHL_OFA_NON_RCT_GL_INTER
            SET OGLI_POSTED = 'Y', OGLI_POSTED_DATE = SYSDATE
          WHERE OGLI_NO = I.OGLI_NO;

         COMMIT;
      END LOOP;



      COMMIT;
   END;

   PROCEDURE log_voucher_error (vou_no VARCHAR, v_error_msg VARCHAR)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO JHL_OFA_VOUCHER_ERROR_LOG (OVEL_NO,
                                             V_VOU_NO,
                                             OVEL_ERROR_MSG,
                                             OVEL_DATE)
           VALUES (OFA_OVEL_NO_SEQ.NEXTVAL,
                   vou_no,
                   v_error_msg,
                   SYSDATE);

      COMMIT;
   END;

   PROCEDURE CREATE_INDIVIDUAL_SUPPLIER_NEW (
      v_cust_ref_no    NUMBER,
      v_agent_no       NUMBER DEFAULT NULL)
   IS
      CURSOR SUPPLIERS
      IS
         SELECT C.V_NAME VENDOR_NAME,
                DECODE (C.V_STATUS, 'A', 'Y', 'N') ENABLED_FLAG,
                'INDIVIDUAL' TYPE_OF_SUPPLIER,
                'Immediate' TERMS_NAME,
                'LIFE-CLAIM' PAY_GROUP,
                99 PAY_PRIORITY,
                'UGX' INVOICE_CURRENCY,
                'UGX' PAYMENT_CURRENCY,
                'N' HOLD_FLAG,
                'INVOICE' TERMS_DATE_BASIS,
                'N' INSPEC_REQ_FLAG,
                'N' RCPT_REQUIRED_FLAG,
                'R' MATCH_OPTION,
                'CHECK' PAYM_METHOD_CODE,
                JHL_BI_UTILS.get_ind_customer_pin (C.N_CUST_REF_NO)
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2,
                C.V_LASTUPD_USER LEGACY_REF3,
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF4,
                C.V_LASTUPD_USER LEGACY_REF5,
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF6,
                TO_DATE (D_BIRTH_DATE, 'DD-MM-RRRR') LEGACY_REF7,
                'Uganda' LEGACY_REF9,
                '11' LEGACY_REF11,
                SYSDATE LAST_UPDATE_DATE,
                N_CUST_REF_NO
           FROM GNMT_CUSTOMER_MASTER C
          --WHERE C.N_CUST_REF_NO IN (SELECT N_PAYER_REF_NO FROM GNMT_POLICY WHERE V_CNTR_STAT_CODE = 'NB010')
          WHERE N_CUST_REF_NO = v_cust_ref_no;


      CURSOR SUPPLIERS_SITE (
         v_cust_ref_no NUMBER)
      IS
         SELECT P.V_POLICY_NO VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = P.N_PAYER_REF_NO AND ROWNUM = 1),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = P.N_PAYER_REF_NO AND ROWNUM = 1),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'LIFE-CLAIM' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152037' PREPAYMENT_ACCOUNT_ID,
                '202301' LIABILITY_ACCOUNT,
                JHL_BI_UTILS.get_ind_customer_pin (C.N_CUST_REF_NO)
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2,
                P.V_POLICY_NO LEGACY_REF3,
                p.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                p.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '11' LEGACY_REF9,
                '12' LEGACY_REF10
           FROM GNMT_POLICY P, GNMT_CUSTOMER_MASTER C, GNLU_PAY_METHOD PM
          WHERE     P.N_PAYER_REF_NO = C.N_CUST_REF_NO
                AND P.V_PMT_METHOD_CODE = PM.V_PMT_METHOD_CODE(+)
                --AND V_CNTR_STAT_CODE = 'NB010'
                AND C.N_CUST_REF_NO = v_cust_ref_no
         UNION
         SELECT TO_CHAR ('PYR-' || C.N_CUST_REF_NO) VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'LIFE-COMMISSION' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152121' PREPAYMENT_ACCOUNT_ID,
                '202351' LIABILITY_ACCOUNT,
                JHL_BI_UTILS.get_ind_customer_pin (C.N_CUST_REF_NO)
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2,
                TO_CHAR (NULL) LEGACY_REF3,
                c.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                c.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '13' LEGACY_REF9,
                '12' LEGACY_REF10
           FROM Ammm_Agent_Master AGN, Gnmt_Customer_Master C
          WHERE     AGN.N_Cust_Ref_No = C.N_Cust_Ref_No
                --AND AGN.V_STATUS  'A'
                AND AGN.N_AGENT_NO = NVL (v_agent_no, AGN.N_AGENT_NO)
                AND C.N_CUST_REF_NO = v_cust_ref_no
         UNION
         SELECT TO_CHAR ('PYR-' || C.N_CUST_REF_NO) VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT V_ADD_TWO
                      FROM GNDT_CUSTOMER_ADDRESS
                     WHERE N_CUST_REF_NO = C.N_Cust_Ref_No AND ROWNUM = 1),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'LIFE-CLAIM' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152037' PREPAYMENT_ACCOUNT_ID,
                '202301' LIABILITY_ACCOUNT,
                JHL_BI_UTILS.get_ind_customer_pin (C.N_CUST_REF_NO)
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2,
                TO_CHAR (NULL) LEGACY_REF3,
                c.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                c.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '13' LEGACY_REF9,
                '12' LEGACY_REF10
           FROM Gnmt_Customer_Master C
          WHERE     TO_CHAR (C.N_CUST_REF_NO) NOT IN
                       (SELECT AGN.N_CUST_REF_NO
                          FROM AMMM_AGENT_MASTER AGN
                         WHERE AGN.N_CUST_REF_NO IS NOT NULL
                        UNION ALL
                        SELECT POL.N_PAYER_REF_NO
                          FROM GNMT_POLICY POL
                         WHERE POL.N_PAYER_REF_NO IS NOT NULL)
                AND C.N_CUST_REF_NO = v_cust_ref_no;


      CURSOR SUPPLIER_CONTACT (
         v_cust_ref_no NUMBER)
      IS
         SELECT 'JHL_UG_LIF_OU' OPERATING_UNIT,
                NVL (
                   TRIM (
                      SUBSTR (TRIM (NVL (V_FIRST_NAME, C.V_NAME)),
                              1,
                              INSTR (NVL (V_FIRST_NAME, C.V_NAME), ' ') - 1)),
                   C.V_NAME)
                   FIRST_NAME,
                --NVL(V_FIRST_NAME, C.V_NAME)  FIRST_NAME,

                NVL (
                   TRIM (SUBSTR (TRIM (NVL (V_FIRST_NAME, C.V_NAME)),
                                 INSTR (TRIM (NVL (V_FIRST_NAME, C.V_NAME)),
                                        ' ',
                                        -1,
                                        1))),
                   '.')
                   LAST_NAME,
                --   NVL(V_LAST_NAME,'.')  LAST_NAME,
                NVL (
                   (SELECT V_CONTACT_NUMBER
                      FROM GNDT_CUSTMOBILE_CONTACTS
                     WHERE     N_CUST_REF_NO = C.N_CUST_REF_NO
                           AND V_STATUS = 'A'
                           AND V_Contact_Number NOT LIKE '%@%'
                           AND ROWNUM = 1),
                   '.')
                   PHONE,
                NVL (
                   (SELECT V_CONTACT_NUMBER
                      FROM GNDT_CUSTMOBILE_CONTACTS
                     WHERE     N_CUST_REF_NO = C.N_CUST_REF_NO
                           AND V_STATUS = 'A'
                           AND V_Contact_Number LIKE '%@%'
                           AND ROWNUM = 1),
                   '.')
                   EMAIL_ADDRESS,
                JHL_BI_UTILS.get_ind_customer_pin (C.N_CUST_REF_NO)
                   LEGACY_REF1,
                TO_CHAR (C.N_CUST_REF_NO) LEGACY_REF2
           FROM GNMT_CUSTOMER_MASTER C
          WHERE C.N_CUST_REF_NO = v_cust_ref_no;

      v_supplier_count        NUMBER := 0;
      v_supplier_site_count   NUMBER := 0;
      v_pin_count             NUMBER := 0;
      v_site_count            NUMBER := 0;
      v_contact_count         NUMBER := 0;

      v_osp_pin_no            VARCHAR2 (100);

      v_agent_count           NUMBER;
      v_policy_count          NUMBER;
      v_vendor_type           VARCHAR2 (150);
      v_pay_group             VARCHAR2 (50);
   BEGIN
      FOR I IN SUPPLIERS
      LOOP
         IF JHL_BI_UTILS.CHECK_VALID_PIN (I.LEGACY_REF1) <> 'Y'
         THEN
            INSERT
              INTO JHL_OFA_SUPPLIER_ERRORS (N_CUST_REF_NO, SP_PIN_NO, SP_DATE)
            VALUES (I.N_CUST_REF_NO, I.LEGACY_REF1, SYSDATE);
         END IF;


         IF JHL_BI_UTILS.CHECK_VALID_PIN (I.LEGACY_REF1) = 'Y'
         THEN
            DELETE FROM JHL_OFA_SUPPLIER
                  WHERE N_CUST_REF_NO = I.N_CUST_REF_NO;

            BEGIN
               SELECT COUNT (*)
                 INTO v_supplier_count
                 FROM JHL_OFA_SUPPLIER
                WHERE N_CUST_REF_NO = I.N_CUST_REF_NO;
            --   AND OSP_PIN_NO = I.LEGACY_REF1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_supplier_count := 0;
            END;

            --                        RAISE_ERROR('v_supplier_count=='||v_supplier_count);
            IF v_supplier_count = 0
            THEN
               DELETE FROM JHL_OFA_SUPPLIER
                     WHERE N_CUST_REF_NO = I.N_CUST_REF_NO;
            END IF;


            IF v_supplier_count = 0
            THEN
               INSERT INTO JHL_OFA_SUPPLIER (OSP_NO,
                                             N_CUST_REF_NO,
                                             OSP_PIN_NO,
                                             OSP_DATE,
                                             OSP_ID_NO)
                    VALUES (JHL_OSP_NO_SEQ.NEXTVAL,
                            I.N_CUST_REF_NO,
                            I.LEGACY_REF1,
                            SYSDATE,
                            I.LEGACY_REF2);
            END IF;

            BEGIN
               v_osp_pin_no := I.LEGACY_REF1;
            /*SELECT OSP_PIN_NO
            INTO v_osp_pin_no
            FROM JHL_OFA_SUPPLIER
            WHERE N_CUST_REF_NO =I.N_CUST_REF_NO ;*/
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_error ('Error Getting Pin number');
            END;



            BEGIN
               SELECT COUNT (*)
                 INTO v_pin_count
                 FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
                WHERE     PAY_GROUP IN ('LIFE-CLAIM', 'LIFE-COMMISSION')
                      AND LEGACY_REF1 = I.LEGACY_REF1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_pin_count := 0;
            END;


            ---GET VENDOR  TYPE---
            SELECT COUNT (*)
              INTO v_agent_count
              FROM Ammm_Agent_Master AGN
             WHERE AGN.N_CUST_REF_NO = v_cust_ref_no;

            SELECT COUNT (*)
              INTO v_policy_count
              FROM GNMT_POLICY
             WHERE N_PAYER_REF_NO = v_cust_ref_no;

            --         raise_error('v_agent_count=='||v_agent_count||'v_policy_count=='||v_policy_count||'v_pin_count=='||v_pin_count);

            IF v_agent_count > 0 AND v_policy_count = 0
            THEN
               v_vendor_type := 'AGENTS';
               v_pay_group := 'LIFE-COMMISSION';
            ELSE
               v_vendor_type := I.TYPE_OF_SUPPLIER;
               v_pay_group := I.PAY_GROUP;
            END IF;

            BEGIN
               IF v_pin_count = 0
               THEN
                  INSERT
                    INTO XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM (
                            SEQ_ID,
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
                          NVL (v_vendor_type, I.TYPE_OF_SUPPLIER),
                          I.TERMS_NAME,
                          NVL (v_pay_group, I.PAY_GROUP),
                          I.PAY_PRIORITY,
                          I.INVOICE_CURRENCY,
                          I.PAYMENT_CURRENCY,
                          I.HOLD_FLAG,
                          I.TERMS_DATE_BASIS,
                          I.INSPEC_REQ_FLAG,
                          I.RCPT_REQUIRED_FLAG,
                          I.MATCH_OPTION,
                          I.PAYM_METHOD_CODE,
                          I.LEGACY_REF1,
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
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_error (
                        'I.LEGACY_REF1=='
                     || I.LEGACY_REF1
                     || 'v_cust_ref_no=='
                     || v_cust_ref_no);
            END;



            --             commit;
            --                          raise_error('v_osp_pin_no=='||v_osp_pin_no||'v_pin_count=='||v_pin_count);

            FOR J IN SUPPLIERS_SITE (I.N_CUST_REF_NO)
            LOOP
               --                               raise_error('v_osp_pin_no=='||v_osp_pin_no||'v_pin_count=='||v_pin_count);
               BEGIN
                  SELECT COUNT (*)
                    INTO v_supplier_site_count
                    FROM JHL_OFA_SUPPLIER_SITE
                   WHERE     N_CUST_REF_NO = I.N_CUST_REF_NO
                         AND NVL (V_POLICY_NO, 'XXXX') =
                                NVL (J.LEGACY_REF3, 'XXXX');
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_supplier_site_count := 0;
               END;



               BEGIN
                  SELECT COUNT (*)
                    INTO v_site_count
                    FROM APPS.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM
                   WHERE     LOB_NAME IN ('JHL_UG_LIF_OU')
                         AND PIN_NO = I.LEGACY_REF1
                         AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_site_count := 0;
               END;

               --                                raise_error('v_site_count=='||v_site_count||'site code =='||J.VENDOR_SITE_CODE);

               IF v_site_count = 0
               THEN
                  BEGIN
                     SELECT COUNT (*)
                       INTO v_site_count
                       FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
                      WHERE     PAY_GRP_LKP_CODE IN
                                   ('LIFE-CLAIM', 'LIFE-COMMISSION')
                            AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE
                            AND LEGACY_REF1 = I.LEGACY_REF1
                            AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_site_count := 0;
                  END;
               END IF;


               IF v_supplier_site_count = 0
               THEN
                  INSERT INTO JHL_OFA_SUPPLIER_SITE (OSPC_NO,
                                                     N_CUST_REF_NO,
                                                     V_POLICY_NO,
                                                     OSPC_DATE)
                       VALUES (JHL_OSPC_NO_SEQ.NEXTVAL,
                               I.N_CUST_REF_NO,
                               J.LEGACY_REF3,
                               SYSDATE);
               END IF;

               IF v_site_count = 0
               THEN
                  INSERT
                    INTO XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM (
                            SEQ_ID,
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
                            PREPAYMENT_ACCOUNT_ID,
                            PREPAYMENT_ACCOUNT,
                            LIABILITY_ACCOUNT,
                            LIABILITY_ACCOUNT_ID,
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
                          J.PREPAYMENT_ACCOUNT_ID,
                          J.PREPAYMENT_ACCOUNT_ID,
                          J.LIABILITY_ACCOUNT,
                          J.LIABILITY_ACCOUNT,
                          I.LEGACY_REF1,
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



            FOR C IN SUPPLIER_CONTACT (I.N_CUST_REF_NO)
            LOOP
               BEGIN
                  SELECT COUNT (*)
                    INTO v_contact_count
                    FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                   WHERE     LEGACY_REF1 = v_osp_pin_no
                         AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_contact_count := 0;
               END;

               IF v_contact_count = 0
               THEN
                  INSERT
                    INTO XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM (
                            SEQ_ID,
                            PROCESS_FLAG,
                            OPERATING_UNIT,
                            FIRST_NAME,
                            LAST_NAME,
                            PHONE,
                            EMAIL_ADDRESS,
                            LEGACY_REF1,
                            LEGACY_REF2)
                  VALUES (XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM,
                          1,
                          C.OPERATING_UNIT,
                          C.FIRST_NAME,
                          C.LAST_NAME,
                          C.PHONE,
                          C.EMAIL_ADDRESS,
                          v_osp_pin_no,
                          I.LEGACY_REF2);
               END IF;
            END LOOP;



            BEGIN
               SELECT COUNT (*)
                 INTO v_site_count
                 FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
                WHERE     PAY_GRP_LKP_CODE IN
                             ('LIFE-CLAIM', 'LIFE-COMMISSION')
                      AND LEGACY_REF1 = v_osp_pin_no
                      AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_site_count := 0;
            END;

            --               raise_error('v_site_count=='||v_site_count||'v_policy_count=='||v_policy_count||'v_pin_count=='||v_pin_count);
            IF v_site_count = 0
            THEN
               DELETE FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
                     WHERE     LEGACY_REF1 = v_osp_pin_no
                           AND PAY_GROUP IN ('LIFE-CLAIM', 'LIFE-COMMISSION')
                           AND LEGACY_REF9 = 'Uganda';

               DELETE FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                     WHERE     LEGACY_REF1 = v_osp_pin_no
                           AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
            END IF;
         END IF;
      END LOOP;

      COMMIT;
   --          raise_error('v_osp_pin_no=='||v_osp_pin_no||'v_pin_count=='||v_pin_count);
   END;

   PROCEDURE CREATE_CORPORATE_SUPPLIER_NEW (
      company_code      VARCHAR,
      company_branch    VARCHAR,
      v_agent_no        NUMBER DEFAULT NULL)
   IS
      CURSOR SUPPLIERS
      IS
         SELECT C.V_COMPANY_NAME VENDOR_NAME,
                DECODE (C.V_COMP_STAT, 'A', 'Y', 'N') ENABLED_FLAG,
                'COMPANY' TYPE_OF_SUPPLIER,
                'Immediate' TERMS_NAME,
                'LIFE-CLAIM' PAY_GROUP,
                99 PAY_PRIORITY,
                'UGX' INVOICE_CURRENCY,
                'UGX' PAYMENT_CURRENCY,
                'N' HOLD_FLAG,
                'INVOICE' TERMS_DATE_BASIS,
                'N' INSPEC_REQ_FLAG,
                'N' RCPT_REQUIRED_FLAG,
                'R' MATCH_OPTION,
                'CHECK' PAYM_METHOD_CODE,
                V_REGN_NO LEGACY_REF1,
                TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH)
                   LEGACY_REF2,
                C.V_LASTUPD_USER LEGACY_REF3,
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF4,
                C.V_LASTUPD_USER LEGACY_REF5,
                TO_DATE (NVL (D_CREATED_DATE, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF6,
                NULL LEGACY_REF7,
                'Uganda' LEGACY_REF9,
                '11' LEGACY_REF11,
                SYSDATE LAST_UPDATE_DATE,
                C.V_COMPANY_CODE,
                C.V_COMPANY_BRANCH
           FROM Gnmm_Company_Master C
          WHERE     c.V_COMPANY_CODE = company_code
                AND c.V_COMPANY_BRANCH = company_branch;



      CURSOR SUPPLIER_SITE (
         v_companycode      VARCHAR,
         v_companybranch    VARCHAR)
      IS
         SELECT P.V_POLICY_NO VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NULL ATTENTION_AR_FLAG,
                NVL (
                   (SELECT G.V_POST_BOX
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT G.V_Town
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                NULL PROVINCE,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'LIFE-CLAIM' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152037' PREPAYMENT_ACCOUNT_ID,
                '202301' LIABILITY_ACCOUNT,
                V_REGN_NO LEGACY_REF1,
                TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH)
                   LEGACY_REF2,
                P.V_POLICY_NO LEGACY_REF3,
                p.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                p.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, p.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '11' LEGACY_REF9,
                '11' LEGACY_REF10,
                C.V_COMPANY_CODE,
                C.V_COMPANY_BRANCH
           FROM Gnmt_Policy P,
                Gnmm_Company_Master C,
                GNMM_POLICY_STATUS_MASTER STATUS,
                GNLU_INSTITUTION_TYPE INS,
                GNLU_PAY_METHOD PM
          WHERE     P.V_Company_Code = C.V_Company_Code
                AND P.V_Company_Branch = C.V_Company_Branch
                AND P.V_CNTR_STAT_CODE = STATUS.V_STATUS_CODE
                AND C.V_INST_TYPE = INS.V_INST_TYPE
                AND P.V_PMT_METHOD_CODE = PM.V_PMT_METHOD_CODE
                --AND  V_STATUS_DESC IN ('IN-FORCE')

                AND C.V_COMPANY_CODE = v_companycode
                AND C.V_COMPANY_BRANCH = v_companybranch
         UNION
         SELECT SUBSTR (
                   TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH),
                   1,
                   15)
                   VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NULL ATTENTION_AR_FLAG,
                NVL (
                   (SELECT G.V_POST_BOX
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = AGN.V_Company_Code
                           AND G.V_Company_Branch = AGN.V_Company_Branch),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT G.V_Town
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = AGN.V_Company_Code
                           AND G.V_Company_Branch = AGN.V_Company_Branch),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                NULL PROVINCE,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'LIFE-COMMISSION' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152121' PREPAYMENT_ACCOUNT_ID,
                '202351' LIABILITY_ACCOUNT,
                C.V_REGN_NO LEGACY_REF1,
                TO_CHAR (
                   TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH))
                   LEGACY_REF2,
                TO_CHAR (NULL) LEGACY_REF3,
                C.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (C.V_LASTUPD_INFTIM, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                C.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (C.V_LASTUPD_INFTIM, C.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '12' LEGACY_REF9,
                '11' LEGACY_REF10,
                AGN.V_COMPANY_CODE,
                AGN.V_COMPANY_BRANCH
           FROM GNMM_COMPANY_MASTER C,
                AMMM_AGENT_MASTER AGN,
                GNLU_INSTITUTION_TYPE INS
          WHERE     C.V_Company_Code = AGN.V_Company_Code
                AND C.V_Company_Branch = AGN.V_Company_Branch
                AND C.V_INST_TYPE = INS.V_INST_TYPE
                --AND AGN.V_STATUS = 'A'
                AND AGN.V_COMPANY_CODE = v_companycode
                AND AGN.V_COMPANY_BRANCH = v_companybranch
                AND AGN.N_AGENT_NO = NVL (v_agent_no, AGN.N_AGENT_NO)
         UNION
         SELECT SUBSTR (
                   TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH),
                   1,
                   15)
                   VENDOR_SITE_CODE,
                'N' PURCHASIN_SITE_FLAG,
                'N' RFQ_ONLY_SITE_FLAG,
                'Y' PAY_SITE_FLAG,
                NULL ATTENTION_AR_FLAG,
                NVL (
                   (SELECT G.V_POST_BOX
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   ADDRESS_LINE1,
                NVL (
                   (SELECT G.V_Town
                      FROM Gndt_Company_Address G
                     WHERE     G.V_Company_Code = C.V_Company_Code
                           AND G.V_Company_Branch = C.V_Company_Branch),
                   'KAMPALA')
                   CITY,
                'UGANDA' STATE,
                '+256' ZIP,
                NULL PROVINCE,
                'UG' COUNTRY,
                'INVOICE' TERMS_DATE_BASIS,
                'LIFE-CLAIM' PAY_GRP_LKP_CODE,
                'IMMEDIATE' TERMS_NAME,
                'UGX' INV_CURR_CODE,
                'UGX' PYMT_CURR_CODE,
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                'R' MATCH_OPTION,
                'CHECK' PAYMENT_METHOD_CODE,
                '152037' PREPAYMENT_ACCOUNT_ID,
                '202301' LIABILITY_ACCOUNT,
                V_REGN_NO LEGACY_REF1,
                TO_CHAR (C.V_Company_Code || '-' || c.V_COMPANY_BRANCH)
                   LEGACY_REF2,
                NULL LEGACY_REF3,
                c.V_LASTUPD_USER LEGACY_REF4,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF5,
                c.V_LASTUPD_USER LEGACY_REF6,
                TO_DATE (NVL (D_CREATED_DATE, c.V_LASTUPD_INFTIM),
                         'DD-MM-RRRR')
                   LEGACY_REF7,
                '210' LEGACY_REF8,
                '11' LEGACY_REF9,
                '11' LEGACY_REF10,
                C.V_COMPANY_CODE,
                C.V_COMPANY_BRANCH
           FROM Gnmm_Company_Master C
          WHERE     1 = 1
                AND C.V_COMPANY_CODE = v_companycode
                AND C.V_COMPANY_BRANCH = v_companybranch
                AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
                       (SELECT AGN.V_COMPANY_CODE, AGN.V_COMPANY_BRANCH
                          FROM AMMM_AGENT_MASTER AGN
                         WHERE AGN.V_COMPANY_CODE IS NOT NULL)
                AND (C.V_COMPANY_CODE, C.V_COMPANY_BRANCH) NOT IN
                       (SELECT P.V_COMPANY_CODE, P.V_COMPANY_BRANCH
                          FROM Gnmt_Policy P,
                               GNMM_POLICY_STATUS_MASTER STATUS
                         WHERE     P.V_CNTR_STAT_CODE = STATUS.V_STATUS_CODE
                               AND P.V_COMPANY_CODE IS NOT NULL-- AND  V_STATUS_DESC IN ('IN-FORCE')

                       );


      CURSOR SUPPLIER_CONTACT (
         v_companycode      VARCHAR,
         v_companybranch    VARCHAR)
      IS
         SELECT DISTINCT
                'JHL_UG_LIF_OU' OPERATING_UNIT,
                C.V_COMPANY_NAME FIRST_NAME,
                '.' LAST_NAME,
                NVL (
                   SUBSTR (
                      (SELECT V_Contact_Number
                         FROM Gndt_Compmobile_Contacts H
                        WHERE     H.V_Company_Code = C.V_Company_Code
                              AND H.V_Company_Branch = C.V_Company_Branch
                              AND V_Contact_Number NOT LIKE '%@%'
                              AND ROWNUM = 1),
                      1,
                      30),
                   '.')
                   PHONE,
                NVL (
                   (SELECT V_Contact_Number
                      FROM Gndt_Compmobile_Contacts H
                     WHERE     H.V_Company_Code = C.V_Company_Code
                           AND H.V_Company_Branch = C.V_Company_Branch
                           AND V_Contact_Number LIKE '%@%'
                           AND ROWNUM = 1),
                   '.')
                   EMAIL_ADDRESS,
                V_REGN_NO LEGACY_REF1
           FROM Gnmm_Company_Master C
          WHERE     C.V_COMPANY_CODE = v_companycode
                AND C.V_COMPANY_BRANCH = v_companybranch;



      v_supplier_count        NUMBER := 0;
      v_supplier_site_count   NUMBER := 0;
      v_pin_count             NUMBER := 0;

      v_csp_pin_no            VARCHAR2 (50);
      v_site_count            NUMBER := 0;
      v_contact_count         NUMBER := 0;



      v_agent_count           NUMBER;
      v_policy_count          NUMBER;
      v_vendor_type           VARCHAR2 (150);
      v_pay_group             VARCHAR2 (50);
   BEGIN
      --raise_error('company_code =='||company_code ||'company_branch=='||company_branch ||'v_agent_no =='||v_agent_no);

      FOR I IN SUPPLIERS
      LOOP
         --    raise_error('company_code =='||company_code ||
         --                        'company_branch=='||company_branch ||
         --                        'v_agent_no =='||v_agent_no||
         --                         'Pin =='||I.LEGACY_REF1 );
         --

         IF JHL_BI_UTILS.CHECK_VALID_PIN (I.LEGACY_REF1) <> 'Y'
         THEN
            INSERT INTO JHL_OFA_SUPPLIER_ERRORS (V_COMPANY_CODE,
                                                 V_COMPANY_BRANCH,
                                                 SP_PIN_NO,
                                                 SP_DATE)
                 VALUES (I.V_COMPANY_CODE,
                         I.V_COMPANY_BRANCH,
                         I.LEGACY_REF1,
                         SYSDATE);
         END IF;

         IF JHL_BI_UTILS.CHECK_VALID_PIN (I.LEGACY_REF1) = 'Y'
         THEN
            BEGIN
               SELECT COUNT (*)
                 INTO v_supplier_count
                 FROM JHL_OFA_CO_SUPPLIER
                WHERE     V_COMPANY_CODE = I.V_COMPANY_CODE
                      AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_supplier_count := 0;
            END;

            IF v_supplier_count = 0
            THEN
               SELECT NVL (MAX (CSP_PIN_COUNT), 0)
                 INTO v_pin_count
                 FROM JHL_OFA_CO_SUPPLIER;

               v_pin_count := v_pin_count + 1;

               INSERT INTO JHL_OFA_CO_SUPPLIER (CSP_NO,
                                                V_COMPANY_CODE,
                                                V_COMPANY_BRANCH,
                                                CSP_PIN_NO,
                                                CSP_DATE,
                                                CSP_PIN_COUNT)
                    VALUES (JHL_CSP_NO_SEQ.NEXTVAL,
                            I.V_COMPANY_CODE,
                            I.V_COMPANY_BRANCH,
                            --                                                        'XKEL'||v_pin_count||'C' ,
                            I.LEGACY_REF1,
                            SYSDATE,
                            v_pin_count);
            ELSE
               --                                                     IF  LENGTH(I.LEGACY_REF1) > 6 THEN

               UPDATE JHL_OFA_CO_SUPPLIER
                  SET CSP_PIN_NO = I.LEGACY_REF1
                WHERE     V_COMPANY_CODE = I.V_COMPANY_CODe
                      AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH;
            --                                                     END IF;

            END IF;

            --get PIN NUMBER
            BEGIN
               SELECT CSP_PIN_NO
                 INTO v_csp_pin_no
                 FROM JHL_OFA_CO_SUPPLIER
                WHERE     V_COMPANY_CODE = I.V_COMPANY_CODe
                      AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH;
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_error ('Error Getting Pin number');
            END;

            --                              Raise_error('v_csp_pin_no=='||v_csp_pin_no);

            IF v_csp_pin_no IS NULL
            THEN
               Raise_error ('Pin Number is null');
            END IF;

            BEGIN
               SELECT COUNT (*)
                 INTO v_pin_count
                 FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
                WHERE     PAY_GROUP IN ('LIFE-CLAIM', 'LIFE-COMMISSION')
                      AND LEGACY_REF1 = v_csp_pin_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_pin_count := 0;
            END;



            ---GET VENDOR ---
            SELECT COUNT (*)
              INTO v_agent_count
              FROM Ammm_Agent_Master AGN
             WHERE     AGN.V_COMPANY_CODE = company_code
                   AND AGN.V_COMPANY_BRANCH = company_branch;

            SELECT COUNT (*)
              INTO v_policy_count
              FROM GNMT_POLICY p
             WHERE     p.V_COMPANY_CODE = company_code
                   AND p.V_COMPANY_BRANCH = company_branch;

            IF v_agent_count > 0 AND v_policy_count = 0
            THEN
               v_vendor_type := 'BROKERS';
               v_pay_group := 'LIFE-COMMISSION';
            ELSE
               v_vendor_type := I.TYPE_OF_SUPPLIER;
               v_pay_group := I.PAY_GROUP;
            END IF;



            --raise_error('v_pin_count=='||v_pin_count||'v_csp_pin_no=='||v_csp_pin_no);

            IF v_pin_count = 0
            THEN
               INSERT
                 INTO XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM (
                         SEQ_ID,
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
                       NVL (v_vendor_type, I.TYPE_OF_SUPPLIER),
                       I.TERMS_NAME,
                       NVL (v_pay_group, I.PAY_GROUP),
                       I.PAY_PRIORITY,
                       I.INVOICE_CURRENCY,
                       I.PAYMENT_CURRENCY,
                       I.HOLD_FLAG,
                       I.TERMS_DATE_BASIS,
                       I.INSPEC_REQ_FLAG,
                       I.RCPT_REQUIRED_FLAG,
                       I.MATCH_OPTION,
                       I.PAYM_METHOD_CODE,
                       v_csp_pin_no,
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
                    INTO v_supplier_site_count
                    FROM JHL_OFA_CO_SUPPLIER_SITE
                   WHERE     V_COMPANY_CODE = I.V_COMPANY_CODE
                         AND V_COMPANY_BRANCH = I.V_COMPANY_BRANCH
                         AND NVL (V_POLICY_NO, 'XXXX') =
                                NVL (J.LEGACY_REF3, 'XXXX');
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_supplier_site_count := 0;
               END;



               BEGIN
                  SELECT COUNT (*)
                    INTO v_site_count
                    FROM APPS.XXJIC_AP_SUPPLIER_MAP@JICOFPROD.COM
                   WHERE     LOB_NAME IN ('JHL_UG_LIF_OU')
                         AND PIN_NO = v_csp_pin_no
                         AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_site_count := 0;
               END;

               --raise_error('v_site_count FISRT=='||v_site_count||'v_csp_pin_no=='||v_csp_pin_no||'VENDOR_SITE_CODE=='||J.VENDOR_SITE_CODE);
               --                  IF  J.VENDOR_SITE_CODE = 'GL201801391433' THEN
               --raise_error('v_site_count=='||v_site_count||'v_csp_pin_no=='||v_csp_pin_no||'VENDOR_SITE_CODE=='||J.VENDOR_SITE_CODE);
               --                          END IF;

               IF v_site_count = 0
               THEN
                  BEGIN
                     SELECT COUNT (*)
                       INTO v_site_count
                       FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
                      WHERE     PAY_GRP_LKP_CODE IN
                                   ('LIFE-CLAIM', 'LIFE-COMMISSION')
                            AND VENDOR_SITE_CODE = J.VENDOR_SITE_CODE
                            AND OPERATING_UNIT = 'JHL_UG_LIF_OU'
                            AND LEGACY_REF1 = v_csp_pin_no;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_site_count := 0;
                  END;
               END IF;

               --                                        IF  J.VENDOR_SITE_CODE = 'GL201801391433' THEN
               -- COMMIT;
               --                                       raise_error('v_site_count=='||v_site_count||
               --                                                         'v_supplier_site_count=='||v_supplier_site_count||
               --                                                         'v_csp_pin_no=='||v_csp_pin_no ||
               --                                                         'VENDOR_SITE_CODE=='|| J.VENDOR_SITE_CODE );

               --   END IF;
               IF v_supplier_site_count = 0
               THEN
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

               --                                                    v_site_count :=0;

               IF v_site_count = 0
               THEN
                  INSERT
                    INTO XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM (
                            SEQ_ID,
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
                            LIABILITY_ACCOUNT_ID,
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
                          J.PREPAYMENT_ACCOUNT_ID,
                          J.PREPAYMENT_ACCOUNT_ID,
                          J.LIABILITY_ACCOUNT,
                          J.LIABILITY_ACCOUNT,
                          v_csp_pin_no,
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


            FOR C IN SUPPLIER_CONTACT (I.V_COMPANY_CODE, I.V_COMPANY_BRANCH)
            LOOP
               BEGIN
                  SELECT COUNT (*)
                    INTO v_contact_count
                    FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                   WHERE     LEGACY_REF1 = v_csp_pin_no
                         AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_contact_count := 0;
               END;


               IF v_contact_count = 0
               THEN
                  INSERT
                    INTO XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM (
                            PROCESS_FLAG,
                            OPERATING_UNIT,
                            FIRST_NAME,
                            LAST_NAME,
                            PHONE,
                            EMAIL_ADDRESS,
                            LEGACY_REF1,
                            SEQ_ID,
                            LEGACY_REF2)
                  VALUES (1,
                          C.OPERATING_UNIT,
                          SUBSTR (C.FIRST_NAME, 1, 50),
                          C.LAST_NAME,
                          C.PHONE,
                          C.EMAIL_ADDRESS,
                          v_csp_pin_no,
                          XXJICUG_COM_CONV_SEQ.NEXTVAL@JICOFPROD.COM,
                          I.LEGACY_REF2);
               END IF;
            END LOOP;



            BEGIN
               SELECT COUNT (*)
                 INTO v_site_count
                 FROM XXJICUG_AP_SUPPLIER_SITE_STG@JICOFPROD.COM
                WHERE     PAY_GRP_LKP_CODE IN
                             ('LIFE-CLAIM', 'LIFE-COMMISSION')
                      AND LEGACY_REF1 = v_csp_pin_no
                      AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_site_count := 0;
            END;

            --                                        raise_error('v_site_count=='||v_site_count);

            IF v_site_count = 0
            THEN
               DELETE FROM XXJICUG_AP_SUPPLIER_STG@JICOFPROD.COM
                     WHERE     PAY_GROUP IN ('LIFE-CLAIM', 'LIFE-COMMISSION')
                           AND LEGACY_REF1 = v_csp_pin_no
                           AND LEGACY_REF9 = 'Uganda';

               DELETE FROM XXJICUG_AP_SUPPLIER_CONCT_STG@JICOFPROD.COM
                     WHERE     LEGACY_REF1 = v_csp_pin_no
                           AND OPERATING_UNIT = 'JHL_UG_LIF_OU';
            END IF;
         END IF;
      END LOOP;
   END;



PROCEDURE create_ofa_cancelled_pymt_gl ( voucher_no number default null) IS  
  


cursor vouchers is
SELECT  V_VOU_DESC,V_VOU_NO,TO_DATE(D_VOU_DATE,'DD/MM/RRRR') D_VOU_DATE ,TO_DATE(JHL_GEN_PKG.get_voucher_approval_date (V_VOU_NO ) ,'DD/MM/RRRR') APPROVAL_DATE
FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR')   BETWEEN TO_DATE('01-JAN-20','DD/MM/RRRR')  AND TO_DATE(SYSDATE,'DD/MM/RRRR')
AND JHL_GEN_PKG.IS_VOUCHER_AUTHORIZED(V_VOU_NO) = 'Y'
AND JHL_GEN_PKG.IS_VOUCHER_CANCELLED (V_VOU_NO) = 'N'
--AND JHL_GEN_PKG.IS_VOUCHER_CANCELLED(V_VOU_NO) = 'Y'
AND V_VOU_NO  NOT IN ( SELECT V_DOCU_REF_NO FROM JHL_OFA_GL_PYMT_TRANS WHERE V_DOCU_REF_NO =V_VOU_NO )
--and V_VOU_NO = nvl(voucher_no,V_VOU_NO);
and V_VOU_NO = voucher_no;
--AND V_VOU_NO = '2017059365' ;


v_control_amt  number :=0;


  
  BEGIN
  
  --DELETE FROM JHL_OFA_GL_TRANSACTIONS;
  
--  select  count(*)
--from JHL_OFA_GL_TRANSACTIONS
  
              FOR I IN vouchers LOOP
              
              BEGIN
              v_control_amt :=0;
              
               begin
               SELECT  SUM(decode(V_TYPE,'D', N_AMT,-N_AMT))
               INTO v_control_amt
     
                FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
                WHERE M.N_REF_NO = D.N_REF_NO
                AND M.V_JOURNAL_STATUS = 'C'
                AND NVL(M.V_REMARKS,'N') != 'X'
                AND V_DOCU_TYPE ='VOUCHER'
--                AND V_GL_CODE   IN ('310001')
                and V_DESC   LIKE  ('%PAYMENT CONTROL%') 
--                AND V_DOCU_REF_NO = '2017059365' 
                AND V_DOCU_REF_NO = i.V_VOU_NO              
                AND M.N_REF_NO NOT IN  ( SELECT ORT.N_REF_NO FROM JHL_OFA_GL_PYMT_TRANS ORT WHERE ORT.N_REF_NO =M.N_REF_NO ) ;
                exception
                when others then
                raise_error('getting control amount  '|| i.V_VOU_NO );
                
                end;
              
--raise_error('v_control_amt=='||v_control_amt);
              
              
                   if v_control_amt = 0 then 
                       
                           INSERT INTO JHL_OFA_GL_PYMT_TRANS(OPYT_NO, N_REF_NO, D_DATE, V_BRANCH_CODE, V_LOB_CODE, 
                          V_PROCESS_CODE, V_PROCESS_NAME, V_DOCU_TYPE, V_DOCU_REF_NO, V_GL_CODE, V_DESC, V_TYPE, N_AMT,OFA_ACC_CODE,V_SOURCE_CURRENCY,
                          D_VOU_DATE)
                          
                               SELECT JHL_OPYT_NO_SEQ.NEXTVAL,M.N_REF_NO, M.D_DATE, NVL(V_BRANCH_CODE,'HO'), V_LOB_CODE, nvl(V_PROCESS_CODE,'N/A') V_PROCESS_CODE,nvl((SELECT V_PROCESS_NAME
                            FROM GNMM_PROCESS_MASTER
                            WHERE V_PROCESS_ID = V_PROCESS_CODE),nvl(V_PROCESS_CODE,'N/A')) V_PROCESS_NAME,V_DOCU_TYPE,V_DOCU_REF_NO,V_GL_CODE ,V_DESC ,V_TYPE, N_AMT,

                                                 NVL( (SELECT   OFA_ACC_CODE 
                                                     FROM JHL_ISF_OFA_ACC_MAP
                                                     WHERE trim(ISF_GL_CODE) = trim(D.V_GL_CODE)
                                                     and trim(ACC_DESC)  = trim(D.V_DESC) ),'N') OFA_ACC_CODE
                                                     
                                                     ,'UGX',NVL(I.APPROVAL_DATE,I.D_VOU_DATE)
                            FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
                            WHERE M.N_REF_NO = D.N_REF_NO
                            AND M.V_JOURNAL_STATUS = 'C'
                            AND NVL(M.V_REMARKS,'N') != 'X'
                            AND V_DOCU_TYPE ='VOUCHER'
--                            AND V_GL_CODE  NOT IN ('310001')
        --                    AND V_DOCU_REF_NO = '2017059365' 
                            AND V_DOCU_REF_NO = i.V_VOU_NO              
                            AND M.N_REF_NO NOT IN  ( SELECT ORT.N_REF_NO FROM JHL_OFA_GL_PYMT_TRANS ORT WHERE ORT.N_REF_NO =M.N_REF_NO ) ;
                        
                    end if;
                    

                    
                    
                    EXCEPTION 
                    WHEN OTHERS THEN
                    
                    RAISE_ERROR('Error on V_VOU_NO == ' || I.V_VOU_NO);
                
              END;

             COMMIT;
            END LOOP;
transform_ofa_cancel_py_trans;
  END;



PROCEDURE transform_ofa_cancel_py_trans IS  
 
 

CURSOR  vouchers IS

SELECT DISTINCT V_DOCU_REF_NO
FROM  JHL_OFA_GL_PYMT_TRANS
WHERE  OPYT_PROCESSED <>'Y';


v_vgl_no number;



  
  BEGIN


          FOR VOU IN vouchers LOOP
          
                  SELECT JGL_OFA_VGL_NO_SEQ.NEXTVAL
                  INTO v_vgl_no
                  FROM DUAL;

--v_vgl_no :=to_number(VOU.V_DOCU_REF_NO);
                  
--                  V_DOCU_REF_NO
          
               UPDATE JHL_OFA_GL_PYMT_TRANS
              SET  OPYT_PROCESSED = 'Y',
               OPYT_PROCESSED_DT = SYSDATE,
               OFA_VGL_NO =v_vgl_no , 
               OFA_VGL_CODE =  'OFA_PV_'||to_char(SYSDATE,'YYYY')||'_'||v_vgl_no
              WHERE V_DOCU_REF_NO = VOU.V_DOCU_REF_NO
                  and OPYT_PROCESSED <>'Y';
          
          
-- RAISE_APPLICATION_ERROR(-20001,'v_vgl_no=='||v_vgl_no||'V_LOB_CODE=='||C.V_LOB_CODE||'D_DATE =='||C.D_DATE );
--          DBMS_OUTPUT.PUT_LINE('v_vgl_no:' || v_vgl_no || ' vgl_code:' || 'OFA_JV_'||to_char(C.D_DATE,'YYYY')||'_'||v_vgl_no);
              commit;

          END LOOP;
   
  transform_ofa_py_gl_trans;
  end;


   
  
  
   PROCEDURE transform_ofa_py_gl_trans IS  

    
  cursor VOU_TRANS is
  
   SELECT 'NEW' STATUS, '2024' SET_OF_BOOKS_ID,
    'ISF LIFE' USER_JE_SOURCE_NAME, 'ISF Payments' USER_JE_CATEGORY_NAME, V_SOURCE_CURRENCY CURRENCY_CODE,
    'A' ACTUAL_FLAG, TO_CHAR(D_DATE,'DD-MON-YY') ACCOUNTING_DATE, TO_CHAR(D_DATE,'DD-MON-YY')  DATE_CREATED, 0 CREATED_BY,
    DECODE(V_TYPE,'D',N_AMT,NULL) ENTERED_DR, DECODE(V_TYPE,'C',N_AMT,NULL) ENTERED_CR,
   '221'  SEGMENT1,
  DECODE (V_BRANCH_CODE, 'HO', '210', '000')  SEGMENT2, 
    '00' SEGMENT3,
  DECODE (V_LOB_CODE,  'LOB001', '12',  'LOB003', '11',  '00')  SEGMENT4,
    OFA_ACC_CODE SEGMENT5,
    '00' SEGMENT6,
    '000' SEGMENT7,
    '000' SEGMENT8,
    OFA_VGL_NO GROUP_ID,
    V_PROCESS_CODE|| '-'|| V_PROCESS_NAME JOURNAL_DESCRIPTION,
    V_DESC LINE_DESCRIPTION, 
    OFA_VGL_NO REFERENCE,
    TO_CHAR(D_DATE,'DD-MON-YY') REFERENCE_DATE,
    V_DOCU_REF_NO REFERENCE1,
     'ISF Payments - '||V_DOCU_REF_NO  REFERENCE2,
   NULL  N_REF_NO,
    V_BRANCH_CODE,
    V_LOB_CODE,
    V_PROCESS_CODE,
    D_DATE,
    OFA_VGL_NO, 
    OFA_VGL_CODE,
    V_GL_CODE
    
    FROM 
  
   (SELECT   TO_DATE(D_VOU_DATE,'DD/MM/RRRR') D_DATE , V_BRANCH_CODE, V_LOB_CODE, V_PROCESS_CODE, V_PROCESS_NAME, V_GL_CODE, V_DESC, V_TYPE, SUM(N_AMT) N_AMT,
    V_SOURCE_CURRENCY,OFA_ACC_CODE,OFA_VGL_NO, OFA_VGL_CODE,V_DOCU_REF_NO
    FROM JHL_OFA_GL_PYMT_TRANS
    WHERE 1=1
    AND OPYT_PROCESSED = 'Y'
   AND  OPYT_POSTED = 'N'
--    AND TO_DATE(D_DATE,'DD/MM/RRRR')  BETWEEN TO_DATE('01-JUL-17','DD/MM/RRRR') AND TO_DATE('31-AUG-17','DD/MM/RRRR')
    
    GROUP BY  TO_DATE(D_VOU_DATE,'DD/MM/RRRR') ,V_BRANCH_CODE, V_LOB_CODE, V_PROCESS_CODE, V_PROCESS_NAME, V_GL_CODE, V_DESC, 
    V_TYPE,V_SOURCE_CURRENCY,OFA_ACC_CODE,OFA_VGL_NO, OFA_VGL_CODE,V_DOCU_REF_NO);
      
    



v_vgl_no  number;



  
  BEGIN
  

      
            FOR J IN  VOU_TRANS  LOOP
          
          INSERT INTO JHL_OFA_PYMT_GL_INTER
                (OGLI_NO, STATUS, SET_OF_BOOKS_ID, USER_JE_SOURCE_NAME, USER_JE_CATEGORY_NAME, CURRENCY_CODE, ACTUAL_FLAG, 
                ACCOUNTING_DATE, DATE_CREATED, CREATED_BY, ENTERED_DR, ENTERED_CR, SEGMENT1, SEGMENT2, SEGMENT3, 
                SEGMENT4, SEGMENT5, SEGMENT6, SEGMENT7, SEGMENT8, GROUP_ID, JOURNAL_DESCRIPTION, LINE_DESCRIPTION, REFERENCE,
                 REFERENCE_DATE, REFERENCE1, REFERENCE2, N_REF_NO, V_BRANCH_CODE, V_LOB_CODE, V_PROCESS_CODE,
                 REFERENCE5, REFERENCE6, REFERENCE10,OGLI_PROCESSED,D_DATE,V_DOCU_TYPE,OGLI_POSTED,OFA_VGL_NO,OFA_VGL_CODE,OGLI_PROCESSED_DT,V_GL_CODE)
                 
                 VALUES(
                 
                  JHL_OGLI_NO_SEQ.NEXTVAL,J.STATUS,J.SET_OF_BOOKS_ID,J.USER_JE_SOURCE_NAME,J.USER_JE_CATEGORY_NAME,J.CURRENCY_CODE,J.ACTUAL_FLAG,J.
                ACCOUNTING_DATE,J.DATE_CREATED,J.CREATED_BY,J.ENTERED_DR,J.ENTERED_CR,J.SEGMENT1,J.SEGMENT2,J.SEGMENT3,J.
                SEGMENT4,J.SEGMENT5,J.SEGMENT6,J.SEGMENT7,J.SEGMENT8,J.GROUP_ID,J.JOURNAL_DESCRIPTION,J.LINE_DESCRIPTION,J.REFERENCE,J.
                REFERENCE_DATE,J.REFERENCE1,J.REFERENCE2,J.N_REF_NO,J.V_BRANCH_CODE,J.V_LOB_CODE,J.V_PROCESS_CODE,
                J.JOURNAL_DESCRIPTION,J.N_REF_NO,J.LINE_DESCRIPTION, 'Y',J.D_DATE,j.USER_JE_CATEGORY_NAME, 'N',J.OFA_VGL_NO, J.OFA_VGL_CODE,SYSDATE,j.V_GL_CODE
                 
                 );

--            commit;
          END LOOP;
      

      
       UPDATE JHL_OFA_GL_PYMT_TRANS
        SET OPYT_POSTED = 'Y',
        OPYT_POSTED_DATE = SYSDATE
        WHERE OPYT_PROCESSED  = 'Y'
--         AND TO_DATE(D_DATE,'DD/MM/RRRR')  BETWEEN TO_DATE('01-JUL-17','DD/MM/RRRR') AND TO_DATE('31-AUG-17','DD/MM/RRRR')
         and OPYT_POSTED <> 'Y';
         
   commit;
      
      
  SEND_PYMT_GL_TRANS_TO_OFA;
  end;
  

 
  PROCEDURE SEND_PYMT_GL_TRANS_TO_OFA IS
  
    cursor TRANS is
    

    
    SELECT OGLI_NO, STATUS, SET_OF_BOOKS_ID, USER_JE_SOURCE_NAME, USER_JE_CATEGORY_NAME, CURRENCY_CODE, ACTUAL_FLAG, 
    ACCOUNTING_DATE, trunc(sysdate) DATE_CREATED, CREATED_BY, ENTERED_DR, ENTERED_CR, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5, 
    SEGMENT6, SEGMENT7, SEGMENT8, GROUP_ID, JOURNAL_DESCRIPTION, LINE_DESCRIPTION, to_char(REFERENCE) REFERENCE, REFERENCE_DATE, REFERENCE1, 
    REFERENCE2, N_REF_NO, V_BRANCH_CODE, V_LOB_CODE, 
    V_PROCESS_CODE, REFERENCE5, REFERENCE6, REFERENCE10, OGLI_PROCESSED, V_DOCU_TYPE, OFA_VGL_NO, OFA_VGL_CODE, OGLI_POSTED, D_DATE
    FROM JHL_OFA_PYMT_GL_INTER
       WHERE 1=1
--    AND N_REF_NO = v_n_ref_no
    AND OGLI_PROCESSED = 'Y'
    AND OGLI_POSTED =  'N'
    ORDER BY REFERENCE1 ;
--    AND REFERENCE1 = '2017068678';
--      AND TO_DATE(D_DATE,'DD/MM/RRRR')  BETWEEN TO_DATE('01-JUL-17','DD/MM/RRRR') AND TO_DATE('31-AUG-17','DD/MM/RRRR') ;
    
    BEGIN
    
 

    
            FOR I IN TRANS LOOP
            
                 insert into APPS.gl_interface@JICOFPROD.COM(STATUS,SET_OF_BOOKS_ID,LEDGER_ID,USER_JE_SOURCE_NAME, USER_JE_CATEGORY_NAME,  
             CURRENCY_CODE,ACTUAL_FLAG, ACCOUNTING_DATE, DATE_CREATED, CREATED_BY,ENTERED_DR, ENTERED_CR,SEGMENT1,SEGMENT2,SEGMENT3,
             SEGMENT4,SEGMENT5,SEGMENT6,SEGMENT7,SEGMENT8,GROUP_ID,REFERENCE5,REFERENCE10,REFERENCE6,REFERENCE_DATE, REFERENCE1,REFERENCE2)
             values(
             i.STATUS,i.SET_OF_BOOKS_ID,i.SET_OF_BOOKS_ID,trim(i.USER_JE_SOURCE_NAME),trim(i. USER_JE_CATEGORY_NAME),i.  
             CURRENCY_CODE,i.ACTUAL_FLAG,i. ACCOUNTING_DATE,i. DATE_CREATED,i. CREATED_BY,i.ENTERED_DR,i. ENTERED_CR,i.SEGMENT1,i.SEGMENT2,i.SEGMENT3,i.
             SEGMENT4,i.SEGMENT5,i.SEGMENT6,i.SEGMENT7,i.SEGMENT8,i.GROUP_ID,i.REFERENCE5,i.REFERENCE10,i.REFERENCE6,i.REFERENCE_DATE,i. REFERENCE1,i.REFERENCE2
             );
     
 

              
              UPDATE JHL_OFA_PYMT_GL_INTER 
              SET OGLI_POSTED = 'Y',
                   OGLI_POSTED_DATE = SYSDATE
              WHERE OGLI_NO = I.OGLI_NO;
              
              commit;
            END LOOP;
    
    
     
      
           commit;
    END;
  


   PROCEDURE UPDT_CHQ
   AS
      v_start_date   DATE;
   BEGIN
      v_start_date := SYSDATE;

      INSERT INTO JHL_OFA_CHQ_DETAILS (CQR_NO,
                                       LOB_NAME,
                                       INVOICE_ID,
                                       PAYMENT_VOUCHER,
                                       VENDOR_NAME,
                                       VENDOR_SITE_CODE,
                                       PAYMENT_AMOUNT,
                                       PIN_NO,
                                       POLICY_NO,
                                       LEGACY_ENTITY_ID,
                                       CHECK_NUMBER,
                                       CQR_DATE,
                                       INVOICE_DATE,
                                       PAYMENT_DATE)
         SELECT JHL_CQR_NO_SEQ.NEXTVAL,
                LOB_NAME,
                INVOICE_ID,
                PAYMENT_VOUCHER,
                VENDOR_NAME,
                VENDOR_SITE_CODE,
                PAYMENT_AMOUNT,
                PIN_NO,
                POLICY_NO,
                LEGACY_ENTITY_ID,
                CHECK_NUMBER,
                SYSDATE,
                INVOICE_DATE,
                PAYMENT_DATE
           FROM APPS.XXJIC_AP_CLAIM_MAP@JICOFPROD.COM
          WHERE     LOB_NAME = 'JHL_UG_LIF_OU'
                --AND TRUNC(INVOICE_DATE) >= '01-JAN-18'
                AND CHECK_NUMBER IS NOT NULL
                AND PAYMENT_VOUCHER NOT IN
                       (SELECT PAYMENT_VOUCHER FROM JHL_OFA_CHQ_DETAILS);


      UPDATE PYMT_VOU_MASTER P
         SET V_CHQ_NO =
                (SELECT DISTINCT A.CHECK_NUMBER
                   FROM JHL_OFA_CHQ_DETAILS A
                  WHERE     TRIM (REPLACE (A.PAYMENT_VOUCHER, '-NEW', '')) =
                               P.V_VOU_NO
                        AND ROWNUM = 1)
       WHERE     NVL (V_CHQ_NO, 'X') = 'X'
             AND P.V_VOU_NO IN
                    (SELECT TRIM (REPLACE (B.PAYMENT_VOUCHER, '-NEW', ''))
                       FROM JHL_OFA_CHQ_DETAILS B
                      WHERE TRIM (REPLACE (B.PAYMENT_VOUCHER, '-NEW', '')) =
                               P.V_VOU_NO);

      --   AND V_VOU_NO = '2018020122' ;



      INSERT INTO JHL_OFA_JOBS (OJB_ID,
                                OJB_NAME,
                                OJB_START_DT,
                                OJB_END_DT)
           VALUES (JHL_OJB_ID_SEQ.NEXTVAL,
                   'UPDT_CHQ',
                   v_start_date,
                   SYSDATE);

      COMMIT;
   END UPDT_CHQ;
END JHL_OFA_UTILS;
/