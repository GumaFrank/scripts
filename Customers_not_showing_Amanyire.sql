select a.V_TYPE_OF_BUS_OPER, a.* from gnmt_customer_master a where n_cust_ref_no=284287;
          
  update  gnmt_customer_master
  set V_TYPE_OF_BUS_OPER='E'
  where n_cust_ref_no=284287;
  
  select distinct V_TYPE_OF_BUS_OPER from gnmt_customer_master 
  
  
  
  select * from  GNLU_OCCUP_MASTER  WHERE V_OCCUP_CODE  IN 
('BM',
'BMRG',
'113',
'114',
'BUSN',
'BUSW',
'177',
'BOTQ')