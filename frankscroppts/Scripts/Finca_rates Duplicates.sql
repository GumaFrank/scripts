select * from GNMM_PREMIUM WHERE V_TABLE_ID in ('$DFCUKMBL2022', '$HFBSWIFTPERSONALNEW2022')  ORDER BY N_START_TERM, N_PREM_RATE;


--UPDATE GNMM_PREMIUM SET N_STRT_GRP_SIZE=0,N_END_GRP_SIZE=9999999,V_QX_OR_PREM_FLAG='P',
--N_START_POLICY_YEAR=0,N_END_POLICY_YEAR=99,N_FROM_INTEREST_RATE=0,N_TO_INTEREST_RATE=9999999,N_START_DEF_PERIOD=0,N_END_DEF_PERIOD=9999999,
--N_FROM_MORTALITY=0,N_TO_MORTALITY=100,N_FROM_PREM_PAY_TERM=0,N_TO_PREM_PAY_TERM=999,N_FROM_GUA_PERIOD=0,N_TO_GUA_PERIOD=999 WHERE V_TABLE_ID='$DFCUKMBL2022';

/*DELETE FROM GNMM_PREMIUM
WHERE rowid in
( SELECT MIN(rowid)
FROM GNMM_PREMIUM WHERE V_TABLE_ID = '$FINCACREDIT2022'
GROUP BY N_START_TERM  
);*/


L
SELECT * FROM GNMT_POLICY_GROUP WHERE V_TABLE_ID in ('$DFCUKMBL2022BandQ', '$HFBSWIFTPERSONALNEW2022') ;


SELECT * FROM GNMM_PLAN_MORT_LINK where V_MORTABLE_ID in ('$DFCUKMBL2022BandQ', '$HFBSWIFTPERSONALNEW2022')  ;

EDIT GNMM_PLAN_MORT_LINK;

after uploading in gnmm_premium, in front end, update motality master, under plan related.

the under plan wizard genral, add the table. ;

SELECT * FROM GNLU_MORTALITY_MASTER WHERE V_MORTABLE_ID ='$TESTKEYA2022';

EDIT GNLU_MORTALITY_MASTER;
EDIT GNMM_PLAN_MORT_LINK;