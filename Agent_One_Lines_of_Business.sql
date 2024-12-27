
SELECT N_AGENT_NO
        FROM ammt_agent_lob 
        WHERE N_AGENT_NO 
         IN 
        ('1252',
'1472',
'8028',
'7084',
'3282',
'5842',
'7748',
'5073',
'6964',
'5182',
'2822',
'6445',
'6924',
'3102',
'2142',
'3922',
'3022',
'5125',
'4242',
'2182',
'2245',
'486',
'5822',
'6984',
'468',
'4902',
'1352',
'3042',
'446',
'2342',
'7304',
'6524',
'1332',
'1412',
'7144',
'7204',
'1473',
'1452',
'4482',
'6604',
'6884',
'5202',
'7166',
'1392',
'5802',
'6324',
'2183',
'4842',
'5102',
'1272',
'2762',
'4982',
'4402',
'4803',
'7124')
  GROUP BY N_AGENT_NO
        HAVING COUNT(DISTINCT V_LINE_OF_BUSINESS) = 1;

select *
from ammt_agent_lob where N_AGENT_NO ='3282'
3282  LOB003
6924  LOB003
8028  LOB003





DECLARE
    CURSOR agent_cursor IS
        SELECT N_AGENT_NO
        FROM ammt_agent_lob
        GROUP BY N_AGENT_NO
        HAVING COUNT(DISTINCT V_LINE_OF_BUSINESS) = 1;

    CURSOR lob_cursor IS
        SELECT 'LOB003' AS lob FROM DUAL
        UNION ALL
        SELECT 'LOB004' AS lob FROM DUAL;

    v_lastupd_user VARCHAR2(30) := 'system';
    v_lastupd_prog VARCHAR2(30) := 'AM_FRM_53';
    v_status VARCHAR2(1) := 'A';

BEGIN
    FOR agent_rec IN agent_cursor LOOP
        FOR lob_rec IN lob_cursor LOOP
            BEGIN
                -- Check if the agent is missing the line of business
                INSERT INTO ammt_agent_lob (
                    N_AGENT_NO, V_LINE_OF_BUSINESS, V_LASTUPD_USER, V_LASTUPD_PROG, D_LASTUPD_INFTIM, V_STATUS
                )
                SELECT agent_rec.N_AGENT_NO, lob_rec.lob, v_lastupd_user, v_lastupd_prog, SYSDATE, v_status
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






DECLARE
    CURSOR agent_cursor IS
        SELECT N_AGENT_NO
        FROM ammt_agent_lob
        WHERE N_AGENT_NO  IN 
        ('1252',
'1472',
'8028',
'7084',
'3282',
'5842',
'7748',
'5073',
'6964',
'5182',
'2822',
'6445',
'6924',
'3102',
'2142',
'3922',
'3022',
'5125',
'4242',
'2182',
'2245',
'486',
'5822',
'6984',
'468',
'4902',
'1352',
'3042',
'446',
'2342',
'7304',
'6524',
'1332',
'1412',
'7144',
'7204',
'1473',
'1452',
'4482',
'6604',
'6884',
'5202',
'7166',
'1392',
'5802',
'6324',
'2183',
'4842',
'5102',
'1272',
'2762',
'4982',
'4402',
'4803',
'7124')
  GROUP BY N_AGENT_NO
        HAVING COUNT(DISTINCT V_LINE_OF_BUSINESS) = 1;

    CURSOR lob_cursor IS
        SELECT 'LOB003' AS lob FROM DUAL
        UNION ALL
        SELECT 'LOB004' AS lob FROM DUAL;

    v_lastupd_user VARCHAR2(30) := 'system';
    v_lastupd_prog VARCHAR2(30) := 'AM_FRM_53';
    v_status VARCHAR2(1) := 'A';

BEGIN
    FOR agent_rec IN agent_cursor LOOP
        FOR lob_rec IN lob_cursor LOOP
            BEGIN
                -- Check if the agent is missing the line of business
                INSERT INTO ammt_agent_lob (
                    N_AGENT_NO, V_LINE_OF_BUSINESS, V_LASTUPD_USER, V_LASTUPD_PROG, D_LASTUPD_INFTIM, V_STATUS
                )
                SELECT agent_rec.N_AGENT_NO, lob_rec.lob, v_lastupd_user, v_lastupd_prog, SYSDATE, v_status
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
