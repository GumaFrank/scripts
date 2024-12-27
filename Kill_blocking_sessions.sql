/*
Author: Frank Bagambe
Date 07-NOV-2024
Description: procedure Check and Kill database locks every after 1 hour
*/
        
        CREATE OR REPLACE PROCEDURE Kill_Blocking_Sessions IS
    CURSOR blocking_sessions_cur IS
        SELECT blocker.sid AS blocking_sid, 
               blocker.serial# AS blocking_serial
        FROM v$session waiter
        JOIN v$session blocker
        ON (waiter.blocking_session = blocker.sid)
        WHERE blocker.username IS NOT NULL
          AND blocker.username != 'JHLISFUADM'
        ORDER BY blocker.sid, waiter.sid;

BEGIN
    FOR session IN blocking_sessions_cur LOOP
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Killing blocking session - SID: ' || session.blocking_sid || ', Serial#: ' || session.blocking_serial);
            EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || session.blocking_sid || ', ' || session.blocking_serial || ''' IMMEDIATE';
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Failed to kill session SID: ' || session.blocking_sid || ', Serial#: ' || session.blocking_serial || ' - ' || SQLERRM);
        END;
    END LOOP;
END Kill_Blocking_Sessions;

/

--SET SERVEROUTPUT ON;   Checking a single locking session
EXEC Kill_Blocking_Sessions;

/

/*
Author: Frank Bagambe
Date 07-NOV-2024
Description:  Schedule to Check and Kill database locks every after 1 hour
*/

BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'Manage_ISF_LOCKS',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN Kill_Blocking_Sessions; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=HOURLY; INTERVAL=1',
        enabled         => TRUE
    );
    
    DBMS_OUTPUT.PUT_LINE('Job Manage_ISF_LOCKS created and scheduled to run every hour.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating job: ' || SQLERRM);
END;
/
