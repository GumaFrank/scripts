SELECT *
FROM gndt_customer_identification where N_CUST_REF_NO =389883







/
SELECT rowid,a.*
FROM gndt_customer_identification a
WHERE a.V_IDEN_CODE = 'PIN'
AND N_CUST_REF_NO IN (
    SELECT N_CUST_REF_NO
    FROM gndt_customer_identification
    WHERE V_IDEN_CODE = 'PIN'
    GROUP BY N_CUST_REF_NO, V_IDEN_CODE
    HAVING COUNT(V_IDEN_CODE) >2
);

/

DECLARE
    CURSOR cust_cursor IS
        SELECT ROWID AS r_id, N_CUST_REF_NO
        FROM gndt_customer_identification
        WHERE V_IDEN_CODE = 'NIC'
        AND N_CUST_REF_NO IN (
            SELECT N_CUST_REF_NO
            FROM gndt_customer_identification
            WHERE V_IDEN_CODE = 'NIC'
            GROUP BY N_CUST_REF_NO, V_IDEN_CODE
            HAVING COUNT(V_IDEN_CODE) > 2
        );
    v_first_row BOOLEAN := TRUE;
BEGIN
    FOR cust_record IN cust_cursor LOOP
        IF v_first_row THEN
            -- Keep the first row with V_IDEN_CODE = 'NIC'
            v_first_row := FALSE;
        ELSE
            -- Update the second row to V_IDEN_CODE = 'PIN'
            UPDATE gndt_customer_identification
            SET V_IDEN_CODE = 'PIN'
            WHERE ROWID = cust_record.r_id;
            v_first_row := TRUE;
        END IF;
    END LOOP;
    
    COMMIT;
END;

/