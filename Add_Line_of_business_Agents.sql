CREATE OR REPLACE PROCEDURE add_missing_line_of_business IS
    CURSOR agent_cursor IS
        SELECT N_AGENT_NO
        FROM ammt_agent_lob
        GROUP BY N_AGENT_NO
        HAVING COUNT(DISTINCT V_LINE_OF_BUSINESS) = 1;

    CURSOR lob_cursor IS
        SELECT 'LOB003' AS lob FROM DUAL
        UNION ALL
        SELECT 'LOB004' AS lob FROM DUAL;

BEGIN
    FOR agent_rec IN agent_cursor LOOP
        FOR lob_rec IN lob_cursor LOOP
            BEGIN
                -- Check if the agent is missing the line of business
                INSERT INTO ammt_agent_lob (
                    N_AGENT_NO, V_LINE_OF_BUSINESS, V_LASTUPD_USER, V_LASTUPD_PROG, D_LASTUPD_INFTIM, V_STATUS
                )
                SELECT agent_rec.N_AGENT_NO, lob_rec.lob, 'system', 'procedure', SYSDATE, 'A'
                FROM DUAL
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM ammt_agent_lob
                    WHERE N_AGENT_NO = agent_rec.N_AGENT_NO
                      AND V_LINE_OF_BUSINESS = lob_rec.lob
                );
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error inserting LOB ' || lob_rec.lob || ' for agent ' || agent_rec.N_AGENT_NO || ': ' || SQLERRM);
            END;
        END LOOP;
    END LOOP;
END;
/
