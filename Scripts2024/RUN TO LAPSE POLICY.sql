exec gen_outstanding_prem_test(user,user,sysdate,'UI201800368991');

exec bpg_ps_common.bpc_move_policy_to_grace(user,user,sysdate);

exec bpg_policy_servicing.bpc_initiate_lapse(user,user,sysdate,'UI201800368991');

