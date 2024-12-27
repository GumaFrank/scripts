select * from  GNDT_ROLE_PROG
select * from GNLU_PROG_MASTER
select * from JHL_ROLE


SET DEFINE OFF;
-- DEFINING ROLES THAT WER NOT DEFINED JUST LIKE kENYA 
-- ADDING ROLES
/*
R242    Masters
R240    POLICY ISSUANCE AND APPROVAL
RNORMAL    
R232    Manager-Underwriter
R090    Missing
R237    GL - Administrator
R235    GL - Management 1
R241    DMS ENQUIRY
R243    Claims Masters
R236    GL - Supervisor 1
R244    Missing
RUW    Missing
R233    Agency Manager
R234    GL - Management 2
RCS      missing
R238    GL - Client Service

*/

Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R242', 'Masters');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R240', 'POLICY ISSUANCE AND APPROVAL');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R232', 'Manager-Underwriter');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R237', 'GL - Administrator');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R235', 'GL - Management 1');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R241', 'DMS ENQUIRY');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R243', 'Claims Masters');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R236', 'GL - Supervisor 1');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R233', 'Agency Manager');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R234', 'GL - Management 2');
Insert into JHLISFUADM.JHL_ROLE
   (V_ROLE_NAME, V_ROLE_DESC)
 Values
   ('R238', 'GL - Client Service');   
COMMIT;
