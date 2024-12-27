SELECT *  FROM GPNC_MEMBER_KYC_BULK_UPD_STG  where scheme_CODE = 'UG-U00283';


update GPNC_MEMBER_KYC_BULK_UPD_STG 
set 
CREATED_BY = 'SKISAKYE', 
LAST_UPDATED_BY = 'SKISAKYE' 
where scheme_CODE = 'UG-U00283';
/
 +Invalid Scheme +Invalid Company +Invalid Member
and ERROR_MESSAGE = ' +Invalid Scheme +Invalid Company +Invalid Member +Invalid Phone Number'
and LAST_UPDATED_BY ='SKISAKYE' and  CREATION_DATE >= '11-NOV-2024';

SELECT * FROM GPNC_MEMBER_KYC_BULK_UPD_STG where CREATION_DATE >= '11-NOV-2024';
/
WHERE BATCH_ID = P_BATCH_SEQ AND STATUS = 'V';

 +Invalid Scheme +Invalid Company +Invalid Member
 

 SELECT * FROM GPNC_MEMBER
             WHERE     SCHEMECODE = R.SCHEME_CODE
                   AND COMPANYCODE = R.COMPANY_CODE
                   AND MEMBERNO = R.MEMBER_CODE;