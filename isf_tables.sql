SELECT * FROM  AMDT_COMPETITION_AGENTS_SELECT    --TABLE        JHLISFUADM

N_AGENT_NO    TABLE COLUMN    AMMT_POL_AG_COMM    JHLISFUADM
D_TRANSFER_DATE    TABLE COLUMN    AMMT_AGENT_TRANSFER    JHLISFUADM
AMMT_POL_AG_COMM
AMMT_AGENT_TRANSFER 


SELECT * FROM AMMT_POL_AG_COMM
 
SELECT * FROM AMMT_AGENT_TRANSFER WHERE TO_CHAR(D_PROCESSED, 'YYYY') = '2018'

 
 select * from AMMM_AGENT_MASTER
 
 select  dISTINCT 
 (select V_PLAN_NAME from GNMM_PLAN_MASTER where V_PLAN_CODE=V_PLRI_CODE) Product,
 V_CHANNEL_NO, 
  N_PERCENT 
    from AMMM_PLAN_CHANNEL_COMM_LINK