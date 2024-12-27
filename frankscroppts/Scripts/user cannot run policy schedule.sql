--NDAMALI and RACHIENG
select * from dba_users where username='NDAMALI';
--@Shakir  please note that the user BKAIGWA can run it


select * from dba_role_privs where grantee= 'PKIMATHI';

select * From dba_role_privs where grantee='JHLISFUADM';


REVOKE R203, R204, R208, R212, R201, R207,  R202, R205, R214, R213, R206, R209, R211, RAGENT, R200, RSUPER FROM MNAMISANGO;

select * from dba_synonyms where owner='PUBLIC' and table_owner='JHLISFUADM';

--select user from dual;
select * From dba_objects where owner='JHLISFUADM' and status='INVALID';

EDIT gnmt_user where v_user_id in ('JNALUSIBA','MNAMISANGO');

--update    gnmt_user set V_DEPT_CODE='BD'    ,V_STRING_LANG_PREFERENCE='EN' where V_USER_ID='NDAMALI';


FOR CASHIER, ADD TO GNDT_FINANCE_BRANCH_USERS
