SELECT * FROM GNMT_POLICY where D_ISSUE is not null and D_DISPATCH_DATE is null order by V_POLICY_NO desc;

select * from PSMT_email_MASTER where V_TRIGGERING_EVENT = 'POL_PREM_NOT';

desc PSMT_email_MASTER;