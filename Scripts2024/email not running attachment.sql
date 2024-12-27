  	SELECT ROWID,A.*
  	FROM GNMT_EMAIL_CONFIGURATIONS A
  	WHERE V_REPORT_ID = 'PS_LTR_A03'
  	AND V_STATUS = 'A';

select * from is_report_master where v_report_name='PS_LTR_A03';
--
select * From gnmt_policy;

--2038	PS_LTR_A03	LORNA	SQL	21/10/2016 10:58:10	A			Premium Statement (Receipt Based)-UG

Exec 	  		bpg_email.BPC_CREATE_EMAIL_PRINT  ( P_POLICY_NO 	=>'UI201200000061',
																			 			P_TRIG_RPT_ID	=> 'PS_LTR_A03',
																			 			P_DATE 				=> SYSDATE,
																			 			P_PROGRAM			=> 'RAMESH',
																			 			P_FILE_PATH 	=> 'C:\TEMP\RAMESH',
																			 			P_SEQ_NO 			=> 1,
																			 			P_REF_NO			=> 1,
																			 			P_EMAIL_PRINT	=> 'E',
																			 			P_AGENT_NO		=> 12345,
																			 			P_EMAIL_NO	 	=> :LN_EMAIL_NO);
PRINT :LN_EMAIL_NO;
SELECT * FROM GNDT_EMAIL_MESSAGES WHERE N_EMAIL_NO=1408304;  

