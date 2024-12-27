-- updating pin for Customers who only has NIC

DECLARE
    CURSOR customer_cursor IS
        SELECT N_CUST_REF_NO
        FROM GNDT_CUSTOMER_IDENTIFICATION
        GROUP BY N_CUST_REF_NO
        HAVING COUNT(DISTINCT V_IDEN_CODE) = 1
           --AND SUM(CASE WHEN V_IDEN_CODE = 'SID' THEN 1 ELSE 0 END) = 1
           AND SUM(CASE WHEN V_IDEN_CODE = 'NIC' THEN 1 ELSE 0 END) = 1;

    cust_record customer_cursor%ROWTYPE;
    v_nic Varchar2(50);
BEGIN
    OPEN customer_cursor;

    LOOP
        FETCH customer_cursor INTO cust_record;
        EXIT WHEN customer_cursor%NOTFOUND;

        -- Get the V_IDEN_NO of the NIC record for this customer
        SELECT V_IDEN_NO INTO v_nic 
        FROM GNDT_CUSTOMER_IDENTIFICATION
        WHERE N_CUST_REF_NO = cust_record.N_CUST_REF_NO
          AND V_IDEN_CODE = 'NIC'
        FETCH FIRST 1 ROWS ONLY;

        -- Insert the new record with V_IDEN_CODE as 'PIN' and V_IDEN_NO as the NIC's V_IDEN_NO
        INSERT INTO GNDT_CUSTOMER_IDENTIFICATION (
            N_CUST_REF_NO, V_IDEN_CODE, V_IDEN_NO, D_ISSUE, D_EXPIRY, V_STATUS, V_LASTUPD_USER, V_LASTUPD_PROG, V_LASTUPD_INFTIM
        ) 
        VALUES (
            cust_record.N_CUST_REF_NO, 'PIN', v_nic, NULL, NULL, 'A', 'FBAGAMBE', 'CUSTOMER', SYSDATE
        );

    END LOOP;

    CLOSE customer_cursor;
END;

commit;


select * from gnmt_policy_detail where v_policy_no ='UI202000575825'

select * from GNDT_CUSTOMER_IDENTIFICATION where N_CUST_REF_NO =410230