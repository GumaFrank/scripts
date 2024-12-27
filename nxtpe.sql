/* 
Author: Eng Frank Bagambe
Date: 09-sep-2024
Descript: Requested by Nxtpe 
 */
SELECT *
  FROM (SELECT K.V_POLICY_NO,
               K.N_CONTRIBUTION,
               'UGX' AS CURRENCY,
              -- R.V_PYMT_FREQ,                              -- IN GNMT_POLICY
               
               DECODE (R.V_PYMT_FREQ,
                                                            '01', 'Monthly',
                                                            '03', 'Quarterly',
                                                            '06', 'Half-Yearly',
                                                            '12', 'Yearly',
                                                            'Yearly')
                                                    Frequency,
               
               R.V_PYMT_FREQ AS "INTERVAL",                -- IN   GNMT_POLICY
               (SELECT Q.V_CONTACT_NUMBER
                  FROM Gndt_custmobile_contacts Q
                 WHERE     Q.N_CUST_REF_NO = C.N_CUST_REF_NO
                       AND Q.V_CONTACT_CODE ='CONT010'
                       AND ROWNUM = 1)
                  AS CONTACT_NUMBER,
               --R.V_PLAN_CODE, --IN GNMT_POLICY
               (SELECT M.V_PLAN_NAME
                  FROM gnmm_plan_master M
                 WHERE M.V_PLAN_CODE = R.V_PLAN_CODE)
                  PLAN_NAME,
               (SELECT V_IDEN_NO
                  FROM Gndt_customer_identification CI_NIC
                 WHERE     CI_NIC.N_CUST_REF_NO = C.N_CUST_REF_NO
                       AND CI_NIC.V_IDEN_CODE = 'NIC'
                       AND ROWNUM = 1)
                  AS NIC_ID,
               ---R.V_PROP_IDEN_NO, -- IN GNMT_POLICY
               C.V_NAME,                           --- IN GNMT_CUSTOMER_MASTER
               (SELECT Q.V_CONTACT_NUMBER
                  FROM Gndt_custmobile_contacts Q
                 WHERE     Q.N_CUST_REF_NO = C.N_CUST_REF_NO
                       AND Q.V_CONTACT_NUMBER LIKE '%@%'
                       AND ROWNUM = 1)
                  AS EMAIL,
               D_POLICY_END_DATE,
               D_COMMENCEMENT
          FROM GNMT_POLICY_DETAIL K
               JOIN GNMT_POLICY R
                  ON K.V_POLICY_NO = R.V_POLICY_NO
               JOIN GNMT_CUSTOMER_MASTER C
                  ON K.N_CUST_REF_NO = C.N_CUST_REF_NO
                  WHERE 
 R.V_CNTR_STAT_CODE  IN ('NB010','NB022')
 AND K.V_POLICY_NO LIKE 'UI%'
                  
                  ) --WHERE V_POLICY_NO ='UI202200856760'
                  ORDER BY D_COMMENCEMENT DESC ;
                  /