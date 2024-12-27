 /*
 select *from ammm_agent_master WHERE V_AGENT_CODE = 'A0007677'; --V_COMPANY_CODE
 /
 
 select * from gnmm_company_master where V_COMPANY_NAME = 'CENTENARY BANK - MAPEERA STANDARD' ; --V_COMPANY_CODE
 /
 
 
 */
 
 SELECT 
 A.N_AGENT_NO,
 A.N_CHANNEL_NO,
 A.V_COMPANY_CODE,
 A.V_AGENT_CODE,
 A.N_CURRENTLY_REPORTING_TO,
 B.V_COMPANY_NAME
 FROM ammm_agent_master A, gnmm_company_master B
 WHERE A.V_COMPANY_CODE = B.V_COMPANY_CODE 
 AND B.V_COMPANY_NAME LIKE '%BANK%'
 --AND  A.N_CHANNEL_NO ='110'
 /
 
 --JOIN gnmm_company_master B
 
 
  --A.V_COMPANY_CODE = B.V_COMPANY_CODE ;
 --/