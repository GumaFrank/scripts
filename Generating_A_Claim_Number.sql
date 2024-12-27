Exec bpc_lapse_reversal('UI201900481042');
/
select v_cntr_stat_code,v_cntr_prem_stat_code from gnmt_policy where v_policy_no='UI201900481042';
/
select V_POLICY_NO, V_CNTR_STAT_CODE, D_PREM_DUE_DATE, D_NEXT_OUT_DATE, V_CNTR_PREM_STAT_CODE
from GNMT_POLICY where V_POLICY_NO ='UI201900481042';
/