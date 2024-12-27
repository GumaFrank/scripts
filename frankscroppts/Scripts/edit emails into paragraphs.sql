select * from psmt_sms_master where v_triggering_event ='RECEIPT_RCVD';
update psmt_sms_master
set V_SMS_MESSAGE='Dear <POLHOLNAME>,
We have received a <RECEIPTTYPE> amount of <RECEIPTAMT>, receipt no.<RECEIPTNO>  for policy number<POLICY>.
Kind Regards,
Customer Service
Jubilee Life Insurance Company of Uganda Ltd.
Tel +256 (0) 312 178 800|  Email feedback-lifeug@jubileeuganda.com
www.jubileeinsurance.com'
where v_triggering_event ='RECEIPT_RCVD'; 


