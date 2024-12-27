/*
Updating customers PIN  CUSTOMERS Who only have SID and NIC, then PIN is missing  
*/

DECLARE
    CURSOR customer_cursor IS
        SELECT N_CUST_REF_NO
        FROM GNDT_CUSTOMER_IDENTIFICATION
        GROUP BY N_CUST_REF_NO
        HAVING COUNT(DISTINCT V_IDEN_CODE) = 2
           AND SUM(CASE WHEN V_IDEN_CODE = 'SID' THEN 1 ELSE 0 END) = 1
           AND SUM(CASE WHEN V_IDEN_CODE = 'PIN' THEN 1 ELSE 0 END) = 1;

    cust_record customer_cursor%ROWTYPE;
    v_pin Varchar2(50);
BEGIN
    OPEN customer_cursor;

    LOOP
        FETCH customer_cursor INTO cust_record;
        EXIT WHEN customer_cursor%NOTFOUND;

        -- Get the V_IDEN_NO of the PIN record for this customer
        SELECT V_IDEN_NO INTO v_pin 
        FROM GNDT_CUSTOMER_IDENTIFICATION
        WHERE N_CUST_REF_NO = cust_record.N_CUST_REF_NO
          AND V_IDEN_CODE = 'PIN'
        FETCH FIRST 1 ROWS ONLY;

        -- Insert the new record with V_IDEN_CODE as 'NIC' and V_IDEN_NO as the PIN's V_IDEN_NO
        INSERT INTO GNDT_CUSTOMER_IDENTIFICATION (
            N_CUST_REF_NO, V_IDEN_CODE, V_IDEN_NO, D_ISSUE, D_EXPIRY, V_STATUS, V_LASTUPD_USER, V_LASTUPD_PROG, V_LASTUPD_INFTIM
        ) 
        VALUES (
            cust_record.N_CUST_REF_NO, 'NIC', v_pin, NULL, NULL, 'A', 'FBAGAMBE', 'CUSTOMER', SYSDATE
        );

    END LOOP;

    CLOSE customer_cursor;
END;

--- COMMIT;


 SELECT N_CUST_REF_NO
        FROM GNDT_CUSTOMER_IDENTIFICATION
        GROUP BY N_CUST_REF_NO
        HAVING COUNT(DISTINCT V_IDEN_CODE) = 1
           AND SUM(CASE WHEN V_IDEN_CODE = 'SID' THEN 1 ELSE 0 END) = 1;
          -- AND SUM(CASE WHEN V_IDEN_CODE = 'PIN' THEN 1 ELSE 0 END) = 1;
           
  select * from GNDT_CUSTOMER_IDENTIFICATION where  N_CUST_REF_NO =10033
  
  5649
7730
8418
9317
9779
10823
11442
11957
13979
14801