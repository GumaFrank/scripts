SELECT GEN.N_EMAIL_NO,GEN.V_EMAIL_FROM,GEN.V_EMAIL_TO, GEN.V_EMAIL_CC,GEN.V_SUBJECT,GEN.V_CONTENT,GMA.V_ATTACHMENT,GEN.V_SMTP_COUNTRY,
GEN.V_STATUS,GEN.V_EMAIL_PRINT
FROM GNDT_EMAIL_MESSAGES GEN left outer join
GNDT_MAIL_ATT GMA on GEN.N_EMAIL_NO=GMA.N_ID  WHERE GEN.N_EMAIL_NO= 1408301 AND GEN.V_STATUS != 'S' AND GEN.V_EMAIL_PRINT = 'E';

UPDATE GNDT_EMAIL_MESSAGES
SET V_EMAIL_CC='agaba@jubileeuganda.com' , V_EMAIL_TO='nellyagaba@gmail.com'  ,V_STATUS='A',V_EMAIL_PRINT='E' ,V_SMTP_COUNTRY='UG'
WHERE N_EMAIL_NO='1406910';

commit;

exec Bpg_Email.BPC_SEND_EMAIL (1408352);

select * from GNDT_EMAIL_MESSAGES;

desc GNDT_MAIL_ATT;

Select V_PARAM_TAGNAME1,V_PARAM_TAGNAME2, V_PARAM_TAGNAME3, V_PARAM_TAGNAME4 From Wsmt_Consume_Service Where V_WS_NO ='UG';

agaba@jubileeuganda.com

Dear  Ssenkindu Peter ,   We have received a  Policy Premium  amount of  150000 , receipt no. HQ210051235   for policy number UI202000517821 .   Kind Regards,  Customer Service Jubilee Life Insurance Company of Uganda Ltd. Tel +256 (0) 312 178 800|  Email feedback-lifeug@jubileeuganda.com       www.jubileeinsurance.com