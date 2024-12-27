SELECT 
    a.V_ROLE_NAME, 
    d.V_ROLE_DESC, 
    a.V_PROG_ID, 
    b.V_PROG_DESC, 
    c.V_USER_NAME,  -- Adjusted to use the correct table alias for V_USER_NAME
    lower(u.V_EMAIL),  -- Added email column
    a.V_MENU_NAME, 
    c.D_APPROVED as ROLE_APPROVED_DATE, 
    E.ACCOUNT_STATUS, 
    E.EXPIRY_DATE, 
    E.LOCK_DATE
FROM 
    GNDT_ROLE_PROG a
JOIN 
    GNLU_PROG_MASTER b ON a.V_PROG_ID = b.V_PROG_ID
JOIN 
    GNDT_UM_USER_PRIVS_TASK c ON a.V_ROLE_NAME = c.V_GRANTROLE_NAME
JOIN 
    JHL_ROLE d ON a.V_ROLE_NAME = d.V_ROLE_NAME
JOIN 
    dba_users E ON E.USERNAME = c.V_USER_NAME -- Adjusted to use the correct table alias for V_USER_NAME
JOIN 
    GNMT_USER u ON c.V_USER_NAME = u.V_USER_ID  -- Join with GNMT_USER to get the email address
WHERE 
    a.V_TYPE = 'F'
    AND a.V_ROLE_NAME NOT IN ('R210') 
    AND a.V_MENU_NAME = b.V_MENU_NAME
    AND NVL(b.V_STATUS,'X') = 'A'
    AND c.V_USER_NAME IN (SELECT V_USER_ID FROM GNMT_USER WHERE V_STAT = 'A')
    order by 5 desc;
