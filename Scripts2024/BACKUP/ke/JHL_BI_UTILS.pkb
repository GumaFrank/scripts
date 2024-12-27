CREATE OR REPLACE PACKAGE BODY             JHL_BI_UTILS AS 


PROCEDURE raise_error (v_msg IN VARCHAR2, v_err_no IN NUMBER := NULL)
 IS
 BEGIN
 IF v_err_no IS NULL
 THEN
 raise_application_error (-20015,
 v_msg
 || ' - '
 || SUBSTR (SQLERRM (SQLCODE), 10)
 );
 ELSE
 raise_application_error (v_err_no,
 v_msg
 || ' - '
 || SUBSTR (SQLERRM (SQLCODE), 10)
 );
 END IF;
 END raise_error;
 
 PROCEDURE POPULATE_GL_TRANS IS 
 
 CURSOR POLICIES IS
 
 select POL.V_POLICY_NO,POL.D_PROPOSAL_SUBMIT,POL.D_ISSUE, POL.D_COMMENCEMENT, POL.V_PLAN_CODE, V_PLAN_NAME, V_PROD_LINE,
        AGN.N_AGENT_NO,AGN.V_AGENT_CODE, NVL (CAGN.V_NAME, CO.V_COMPANY_NAME) AGENT_NAME,
        CU.V_COMPANY_NAME, CU.V_COMPANY_CODE ||'-'||CU.V_COMPANY_BRANCH COMPANY_CODE,
        FREQ.V_PYMT_DESC, V_STATUS_DESC
from GNMT_POLICY POL,GNMM_PLAN_MASTER PROD,   AMMT_POL_AG_COMM COM, AMMM_AGENT_MASTER AGN,
       GNMT_CUSTOMER_MASTER CAGN, GNMM_COMPANY_MASTER CO,GNMM_COMPANY_MASTER CU,    GNLU_FREQUENCY_MASTER FREQ, GNMM_POLICY_STATUS_MASTER PST
where  POL.V_PLAN_CODE = PROD.V_PLAN_CODE
AND POL.V_POLICY_NO = COM.V_POLICY_NO
AND COM.N_AGENT_NO = AGN.N_AGENT_NO
AND AGN.N_CUST_REF_NO = CAGN.N_CUST_REF_NO(+)
AND AGN.V_COMPANY_CODE = CO.V_COMPANY_CODE(+)
AND AGN.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH(+)
AND POL.V_COMPANY_CODE = CU.V_COMPANY_CODE
AND POL.V_COMPANY_BRANCH = CU.V_COMPANY_BRANCH
AND POL.V_CNTR_STAT_CODE = PST.V_STATUS_CODE
AND V_ROLE_CODE = 'SELLING'
AND COM.V_STATUS = 'A'
--AND POL.V_POLICY_NO LIKE 'GL%'
AND V_PROD_LINE = 'LOB003'
AND POL.V_CNTR_STAT_CODE  = 'NB010'
 AND POL.V_PYMT_FREQ = FREQ.V_PYMT_FREQ
 AND POL.V_POLICY_NO NOT  in ( SELECT UFS_POL_NO FROM PGIS_UW_FACTS_GL);
--AND POL.V_POLICY_NO  in( 'GL201100000146');

v_end_date DATE;
v_issued_date DATE;
v_start_date DATE;
v_from_date DATE;
v_to_date DATE;

v_new_prem NUMBER;
v_gross_premium NUMBER;
v_add_premium NUMBER;
v_avg_age NUMBER;
v_cancelled_prem  NUMBER;
v_comm_amt NUMBER;
v_earned_amt NUMBER;
v_emp_count NUMBER;
v_mon_sal  number;
v_sum_assured number;
v_upr_amt  number;
v_refund_amt  number;
v_renew_amt  number;
 
 BEGIN
 
 
-- SELECT *
--FROM PGIS_UW_FACTS_GL


--delete from PGIS_UW_FACTS_GL;

        FOR I IN POLICIES LOOP
        
          v_issued_date  := I.D_COMMENCEMENT;
          v_end_date  := I.D_COMMENCEMENT;
        
                WHILE(v_end_date < SYSDATE ) LOOP
                              SELECT  trunc( to_date(v_end_date,'DD/MM/RRRR'),'MM')
                              INTO  v_from_date
                               from dual;
                               
                  select  last_day(v_from_date)
                  INTO  v_to_date
                   from dual;
                   
                   v_new_prem :=NULL;
                   v_gross_premium := NULL;
                   v_add_premium := NULL;
                   v_avg_age:= NULL;
                   v_cancelled_prem :=null;
                   v_comm_amt  :=null;
                   v_earned_amt   :=null;
                   v_emp_count :=null;
                   v_mon_sal :=null;
                   v_sum_assured  :=null;
                   v_upr_amt  :=null;
                   v_refund_amt   :=null;
                   v_renew_amt  :=null;
                   
                   
                    
                  /*new premium*/
                 BEGIN 
                SELECT  SUM(N_BILL_AMT)
                INTO v_new_prem
               FROM GNMT_QUOTATION a, GNMT_QUOTATION_DETAIL b, GNMT_RAISE_BILL_REQUEST c, GNMM_COMPANY_MASTER d
                WHERE a.V_POLICY_NO = b.V_POLICY_NO
                AND a.V_QUOTATION_ID = b.V_QUOTATION_ID 
                AND NVL(V_QUOT_BACKUP_TYPE,'N') = 'N'
                AND a.V_POLICY_NO = c.V_POLICY_NO
                AND b.N_SEQ_NO = c.N_SEQ_NO
                AND NVL(N_REN_COUNT,0)=0
                AND V_BILL_IDEN = 'SGNB'
                AND a.V_CNTR_STAT_CODE NOT IN ('NB213')
                --AND TRUNC(D_BILL_RAISED) > L_LAST_DATE
                AND TRUNC(D_BILL_RAISED) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
                AND NVL(a.V_COMPANY_CODE,'X') = NVL(d.V_COMPANY_CODE,'X')
                AND NVL(a.V_COMPANY_BRANCH,'X') = NVL(d.V_COMPANY_BRANCH,'X')
                AND a.V_POLICY_NO = I.V_POLICY_NO ;
               
                     EXCEPTION 
                 WHEN OTHERS THEN
                 v_new_prem := NULL;
                 END;
                
--                to be changed
--                /*gross premium*/
--            BEGIN
--                SELECT  SUM(N_RECEIPT_AMT)
--                  INTO v_gross_premium
--                FROM REMT_RECEIPT
--                WHERE V_POLICY_NO =  i.V_POLICY_NO
--                AND V_RECEIPT_TABLE = 'DETAIL'
--                AND V_RECEIPT_STATUS = 'RE001'
--                 AND TRUNC(D_RECEIPT_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
--                 EXCEPTION 
--                 WHEN OTHERS THEN
--                 v_gross_premium := NULL;
--                 END;
--                 
                 
                 /*add premium*/
               BEGIN  
                 SELECT SUM(N_TRN_AMT)
                 INTO v_add_premium
                FROM GNDT_BILL_TRANS a, GNMM_COMPANY_MASTER b, LU_CODES c
                WHERE V_BILL_TYPE = 'DN'
                --AND NVL(N_BILL_BAL_AMT,0) > 0
                --AND V_POLICY_NO LIKE '%813'
                and NVL(a.V_COMPANY_CODE,'X') = NVL(b.V_COMPANY_CODE,'X')
                and NVL(a.V_COMPANY_BRANCH,'X') = NVL(b.V_COMPANY_BRANCH,'X')
                and TRUNC(D_BILL_RAISED_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
                and V_BILL_SOURCE = LU_CODE
                and LU_TYPE = 'BILL'
                AND V_TRN_TYPE = 'PYMT'
                AND V_BILL_BAL_TYPE != 'R'
                AND V_BILL_SOURCE  NOT IN ( 'SGNB','SGRB')
                AND V_POLICY_NO = I.V_POLICY_NO;
                 EXCEPTION 
                 WHEN OTHERS THEN
                 v_add_premium := NULL;
                 END;
                 
                 
                  /*RENEWAL*/
               BEGIN  
                 SELECT SUM(N_TRN_AMT)
                 INTO v_renew_amt
                FROM GNDT_BILL_TRANS a, GNMM_COMPANY_MASTER b, LU_CODES c
                WHERE V_BILL_TYPE = 'DN'
                --AND NVL(N_BILL_BAL_AMT,0) > 0
                --AND V_POLICY_NO LIKE '%813'
                and NVL(a.V_COMPANY_CODE,'X') = NVL(b.V_COMPANY_CODE,'X')
                and NVL(a.V_COMPANY_BRANCH,'X') = NVL(b.V_COMPANY_BRANCH,'X')
                and TRUNC(D_BILL_RAISED_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
                and V_BILL_SOURCE = LU_CODE
                and LU_TYPE = 'BILL'
                AND V_TRN_TYPE = 'PYMT'
                AND V_BILL_BAL_TYPE != 'R'
                AND V_BILL_SOURCE   IN ('SGRB')
                AND V_POLICY_NO = I.V_POLICY_NO;
                 EXCEPTION 
                 WHEN OTHERS THEN
                 v_renew_amt := NULL;
                 END;
                 
                 
                 
                 
                 /* REFUND */
                 
      
            BEGIN           
                             
            SELECT SUM(-N_TRN_AMT)
            INTO v_refund_amt
            FROM GNDT_BILL_TRANS a, GNMM_COMPANY_MASTER b, LU_CODES c
            WHERE V_BILL_TYPE = 'CN'
            --AND NVL(N_BILL_BAL_AMT,0) > 0
            --AND V_POLICY_NO LIKE '%813'
            and NVL(a.V_COMPANY_CODE,'X') = NVL(b.V_COMPANY_CODE,'X')
            and NVL(a.V_COMPANY_BRANCH,'X') = NVL(b.V_COMPANY_BRANCH,'X')
            and TRUNC(D_BILL_RAISED_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
            and V_BILL_SOURCE = LU_CODE
            and LU_TYPE = 'BILL'
            AND V_TRN_TYPE = 'RPMT'
            AND V_BILL_BAL_TYPE != 'R'
            AND LU_CODE  IN ( 'SGPR','SGOB')
            AND V_POLICY_NO =  I.V_POLICY_NO;

            EXCEPTION 
            WHEN OTHERS THEN
            v_refund_amt := NULL;
            END;

                 
                 /*avg age*/
                 begin
                   select  ceil (avg(N_AGE_ENTRY))
                   into v_avg_age
                   FROM GNMT_POLICY a,  GNMT_POLICY_DETAIL b
                   where a.V_POLICY_NO = b.V_POLICY_NO
                   and  a.V_POLICY_NO = I.V_POLICY_NO
                   AND TRUNC(D_APPOINTMENT) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                    EXCEPTION 
                 WHEN OTHERS THEN
                 v_avg_age := NULL;
                 END;
                 
                 
                   /*cancelled premium*/
             /*  BEGIN
                SELECT  SUM(N_RECEIPT_AMT)
                  INTO v_gross_premium
                FROM REMT_RECEIPT
                WHERE V_POLICY_NO =  i.V_POLICY_NO
                AND V_RECEIPT_TABLE = 'DETAIL'
                AND V_RECEIPT_STATUS <> 'RE001'
                 AND TRUNC(D_RECEIPT_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                 EXCEPTION 
                 WHEN OTHERS THEN
                 v_cancelled_prem := NULL;
                 END;*/
                 
                 /*commissoin */
                 
                 begin
                 
                 SELECT  SUM(N_COMM_AMT) 
                 into v_comm_amt
                FROM AMMT_COMMISSION_INTIMATION a, AMMT_POL_COMM_DETAIL b, GNDT_BILL_TRANS c, GNMM_COMPANY_MASTER d,AMMM_AGENT_MASTER z
                WHERE A.V_POLICY_NO = B.V_POLICY_NO
                --And B.N_Comm_Intimation_Seq = A.N_Comm_Intimation_Seq(+)
                AND A.N_COMM_GEN_SEQ = B.N_COMM_SEQ
                --And A.V_Receipt_No =B.V_Receipt_No
                AND a.N_SEQ_NO = b.N_SEQ_NO
                AND a.V_PLAN_CODE = b.V_PLAN_CODE
                AND V_COMM_PROCESS_CODE IN ('G','C', 'R')
                AND N_BILL_TRN_NO = 1
                AND V_POSTED_REF_NO = V_BILL_NO
                AND NVL(c.V_COMPANY_CODE,'X') = NVL(d.V_COMPANY_CODE,'X')
                AND NVL(c.V_COMPANY_BRANCH,'X') = NVL(d.V_COMPANY_BRANCH,'X')
                and b.N_AGENT_NO = z.N_AGENT_NO
                 and b.N_AGENT_NO  = i.N_AGENT_NO 
                 and a.V_POLICY_NO  =  i.V_POLICY_NO
                and TRUNC(D_BILL_RAISED_DATE)    BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                
                       EXCEPTION 
                 WHEN OTHERS THEN
                 v_comm_amt := NULL;
                 END;
                 
                 v_earned_amt :=  (NVL(v_new_prem,0) +  NVL(v_add_premium,0) ) * TO_NUMBER(TO_CHAR(v_from_date,'MM')) / 12;
                 
                 
                   /*EMP COUNT*/
                 begin
                   select  COUNT(*)
                   into v_emp_count
                   FROM GNMT_POLICY a,  GNMT_POLICY_DETAIL b
                   where a.V_POLICY_NO = b.V_POLICY_NO
                   and  a.V_POLICY_NO = I.V_POLICY_NO
                   AND TRUNC(D_ENTRY_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                    EXCEPTION 
                 WHEN OTHERS THEN
                 v_emp_count := NULL;
                 END;
                 
                 if v_emp_count = 0 then
                 v_emp_count := null;
                 end if;
                 
                 
                       /*monthly sal*/
                 begin
                   select  sum(N_SALARY)
                   into v_mon_sal
                   FROM GNMT_POLICY a,  GNMT_POLICY_DETAIL b
                   where a.V_POLICY_NO = b.V_POLICY_NO
                   and  a.V_POLICY_NO = I.V_POLICY_NO
                   AND TRUNC(D_ENTRY_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                    EXCEPTION 
                 WHEN OTHERS THEN
                 v_mon_sal := NULL;
                 END;
                 
                 
                                        /*monthly sal*/
                 begin
                   select  sum(N_SUM_COVERED)
                   into v_sum_assured
                   FROM GNMT_POLICY a,  GNMT_POLICY_DETAIL b
                   where a.V_POLICY_NO = b.V_POLICY_NO
                   and  a.V_POLICY_NO = I.V_POLICY_NO
                   AND TRUNC(D_ENTRY_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                    EXCEPTION 
                 WHEN OTHERS THEN
                 v_sum_assured := NULL;
                 END;
                 
                 
                 v_upr_amt := (NVL(v_new_prem,0) +  NVL(v_add_premium,0) );
                 
                 v_gross_premium  := (NVL(v_new_prem,0) +  NVL(v_add_premium,0) + NVL(v_refund_amt,0)+ NVL(v_renew_amt,0)  );
                
                
                IF    (v_new_prem IS NOT NULL OR
                        v_gross_premium IS NOT NULL OR
                        v_add_premium IS NOT NULL or
                        v_avg_age IS NOT NULL or
                        v_cancelled_prem is not null or
                        v_comm_amt  is not null OR
                        NVL(v_earned_amt,0)  <> 0  OR
                         NVL(v_emp_count,0)  <> 0  or
                        NVL( v_mon_sal,0) <> 0 OR
                        NVL( v_sum_assured,0)  <> 0 OR
                        NVL( v_upr_amt,0) <>  0  OR
                          NVL( v_refund_amt,0)  <> 0 OR
                        NVL( v_renew_amt,0) <>  0 
                        
                         ) THEN
                
                   insert into PGIS_UW_FACTS_GL(
                   UFS_CLASS_CODE,
                   UFS_POL_NO,
                   UFS_PERIOD,
                   UFS_PREMIUM,
                   UFS_ADDL_PREMIUM,
                   UFS_BUS_TYPE,
                   UFS_AVG_AGE,
                   UFS_CANCELLED_PREMIUM,
                   UFS_COMM,
                   UFS_CR_DT,
                   UFS_CR_ID,
                   UFS_CUST_CODE, 
                   UFS_CUST_NAME, 
                   UFS_DIVN_CODE,
                   UFS_EARNED_PREMIUM,
                   UFS_EMP_COUNT,
                    UFS_MONTH_SAL,
                    UFS_POL_COUNT,
                    UFS_POL_SRC_OF_BUS,
                    UFS_PR_APPRV_DT, 
                    UFS_PR_PREM_TYPE,
                    UFS_PROD_CODE,
                    UFS_REFUND_PREMIUM,
                    UFS_RENEW_PREMIUM,
                    UFS_RISK_COUNT,
                    UFS_SI, 
                    UFS_SRC_CODE, 
                    UFS_UPD_DT, 
                    UFS_UPD_ID, 
                    UFS_UPR,
                     UFS_NEW_PREMIUM,
                   PRD_START_DATE, 
                   PRD_END_DATE,
                   UFS_DATE,
                   UFS_POL_STATUS,
                   UFS_COUNTRY_CODE)
                   
                   values(
                   I.V_PROD_LINE,
                   i.V_POLICY_NO,
                   TO_NUMBER(TO_CHAR(v_from_date,'YYYYMM')),
                   v_gross_premium,
                   v_add_premium,
                   'GROUP LIFE',
                   v_avg_age,
                   v_cancelled_prem,
                   v_comm_amt,
                   v_from_date,
                   'JHLISFADMIN',
                      I.COMPANY_CODE,
                     I.V_COMPANY_NAME,
                     'HQS',
                     v_earned_amt,
                      v_emp_count,
                     v_mon_sal,
                    1,
                    'BROKER',
                    I.D_ISSUE,
                    I.V_PYMT_DESC,
                    I.V_PLAN_CODE,
                    v_refund_amt,
                         v_renew_amt,
                    v_emp_count,
                    v_sum_assured,
                    I.V_AGENT_CODE,
                       v_from_date,
                   'JHLISFADMIN',
                  v_upr_amt  , 
                   v_new_prem,
                   v_from_date,
                   v_to_date,
                   SYSDATE,
                   I.V_STATUS_DESC,
                   'KENYA');
                  END IF;
                   
                   
                 v_end_date := ADD_MONTHS(trunc( to_date(v_end_date,'DD/MM/RRRR'),'MM'),1);
                END LOOP;
                
        
COMMIT;
        END LOOP;


 
 END;
 
  PROCEDURE POPULATE_IL_TRANS IS 
 
 CURSOR POLICIES IS
 
 select POL.V_POLICY_NO,POL.D_PROPOSAL_SUBMIT,POL.D_ISSUE, POL.D_COMMENCEMENT, POL.D_PROPOSAL_DATE, POL.V_PLAN_CODE, V_PLAN_NAME, V_PROD_LINE,
        AGN.N_AGENT_NO,AGN.V_AGENT_CODE, NVL (CAGN.V_NAME, CO.V_COMPANY_NAME) AGENT_NAME,
        CU.V_NAME, CU.N_CUST_REF_NO, POL.V_PYMT_FREQ, POL.N_CONTRIBUTION,
        FREQ.V_PYMT_DESC,V_POLICY_BRANCH,N_CHANNEL_NO,V_CNTR_STAT_CODE, V_STATUS_DESC, V_PMT_METHOD_NAME
from GNMT_POLICY POL,GNMM_PLAN_MASTER PROD,   AMMT_POL_AG_COMM COM, AMMM_AGENT_MASTER AGN,
       GNMT_CUSTOMER_MASTER CAGN, GNMM_COMPANY_MASTER CO,GNMT_CUSTOMER_MASTER CU,    
       GNLU_FREQUENCY_MASTER FREQ, GNMM_POLICY_STATUS_MASTER PST, GNLU_PAY_METHOD PAY
where  POL.V_PLAN_CODE = PROD.V_PLAN_CODE
AND POL.V_POLICY_NO = COM.V_POLICY_NO
AND COM.N_AGENT_NO = AGN.N_AGENT_NO
AND AGN.N_CUST_REF_NO = CAGN.N_CUST_REF_NO(+)
AND AGN.V_COMPANY_CODE = CO.V_COMPANY_CODE(+)
AND AGN.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH(+)
AND POL.N_PAYER_REF_NO = CU.N_CUST_REF_NO
 AND POL.V_CNTR_STAT_CODE = PST.V_STATUS_CODE
AND V_ROLE_CODE = 'SELLING'
AND COM.V_STATUS = 'A'
AND POL.V_PMT_METHOD_CODE = PAY.V_PMT_METHOD_CODE(+)
--AND POL.V_POLICY_NO LIKE 'GL%'
AND V_PROD_LINE <> 'LOB003'
--AND POL.V_CNTR_STAT_CODE IN ( 'NB010', 'NB020','NB022')
 AND POL.V_PYMT_FREQ = FREQ.V_PYMT_FREQ
--AND POL.V_POLICY_NO ='IL201400510301';
 AND POL.V_POLICY_NO NOT  in ( SELECT UFS_POL_NO FROM PGIS_UW_FACTS_GL_TST);


v_end_date DATE;
v_issued_date DATE;
v_start_date DATE;
v_from_date DATE;
v_to_date DATE;
v_ann_date DATE;
v_beg_date DATE;
v_new_prem NUMBER;
v_gross_premium NUMBER;
v_add_premium NUMBER;
v_avg_age NUMBER;
v_cancelled_prem  NUMBER;
v_comm_amt NUMBER;
v_earned_amt NUMBER;
v_emp_count NUMBER;
v_mon_sal  number;
v_sum_assured number;
v_upr_amt  number;
v_refund_amt  number;
v_outstanding_amt  number;
v_renew_amt  number;
v_bill_amt  number;


v_count number; 
v_bill_count number; 

v_chn_desc VARCHAR2(200);

v_branch VARCHAR2(200);
v_pol_count number; 
v_max_period number;
 
 BEGIN

        FOR I IN POLICIES LOOP
        v_count :=0;
         v_bill_count :=0;
         v_pol_count :=0;
          v_issued_date  := I.D_ISSUE;
          v_end_date  := I.D_PROPOSAL_DATE;
          v_ann_date   :=  add_months(I.D_COMMENCEMENT,12);
          
          
--          if (v_end_date is null) then
--                  select least(least ( nvl(min(D_Ref_Date),sysdate), nvl(I.D_COMMENCEMENT,sysdate)), nvl(I.D_ISSUE,sysdate))
--                  into v_end_date
--                   FROM Gndt_Bill_Trans A
--                     where v_policy_no = i.V_POLICY_NO;
--
--          end if;
          
            select nvl(min(D_Ref_Date),sysdate)
                  into v_end_date
                   FROM Gndt_Bill_Trans A
                     where v_policy_no = i.V_POLICY_NO;
          

          
           begin
           select   count(*)
           into v_pol_count
            from PGIS_UW_FACTS_GL
            where  UFS_POL_NO = i.V_POLICY_NO;
            exception
            when others then
            v_pol_count :=0;
            end;
            
--            if v_pol_count > 0 then
--           select  max(UFS_PERIOD), max(PRD_START_DATE)
--               into v_max_period, v_end_date
--            from PGIS_UW_FACTS_GL
--            where  UFS_POL_NO =i.V_POLICY_NO;
--            
--    
--           delete  from PGIS_UW_FACTS_GL
--            where  UFS_POL_NO =i.V_POLICY_NO
--            and UFS_PERIOD = v_max_period;
--            
--            end if;
          
--          raise_error('v_count=='||v_count || 'v_end_date=='||v_end_date ||'v_beg_date=='||v_beg_date ||'v_issued_date ==' ||v_issued_date
--                  ||'v_to_date=='||v_to_date ||' i.V_POLICY_NO =='||  i.V_POLICY_NO||'v_new_prem=='||v_new_prem || 'v_max_period=='||v_max_period);
          
                              SELECT  trunc( to_date( I.D_COMMENCEMENT,'DD/MM/RRRR'),'MM')
                              INTO  v_beg_date
                               from dual;
        
                WHILE(v_end_date <= SYSDATE ) LOOP
                              SELECT  trunc( to_date(v_end_date,'DD/MM/RRRR'),'MM')
                              INTO  v_from_date
                               from dual;
                               
                  select  last_day(v_from_date) 
                  INTO  v_to_date
                   from dual;

                   v_count := v_count+1;
--                   v_new_prem :=NULL;
                   v_gross_premium := NULL;
                   v_add_premium := NULL;
                   v_avg_age:= NULL;
                   v_cancelled_prem :=null;
                   v_comm_amt  :=null;
                   v_earned_amt   :=null;
                   v_emp_count :=null;
                   v_mon_sal :=null;
                   v_sum_assured  :=null;
                   v_upr_amt  :=null;
                   v_refund_amt   :=null;
                   v_renew_amt  :=null;
                   v_outstanding_amt := null;
                   v_bill_amt := null;
                   
                   
                   -- Let us check if there is a bill raised in this particular period then we increase the bill count
                   -- The new premium is the first 12 premiums, Renew is the premium thereafter
                   
                   select SUM(DECODE (V_Bill_Type,  'DN', N_Trn_Amt,  'CN', - N_Trn_Amt))
                   INTO v_bill_amt
                    FROM Gndt_Bill_Trans A
                     where  NVL (V_Cancel_Status, 'N') = 'N'
                         AND N_Trn_Amt != 0
                            AND N_Bill_Trn_No > 1
            --                AND V_BILL_TYPE = 'DN'
            --                 A.V_Policy_No NOT LIKE 'GL%'
                            and v_policy_no = i.V_POLICY_NO
                             AND TRUNC (D_Ref_Date)  BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                             
                             if(v_bill_amt is not null) then
                                     v_bill_count := v_bill_count+1;
                              end if;
                              
                                        
         -- Get the regional manager code that will then link us to the branch 
         if I.N_CHANNEL_NO = 10 then
                 v_branch:= JHL_GEN_PKG.GET_AGENCY_HIERARCHY(I.N_AGENT_NO,'15');
                 
                 if v_branch is null then
                        v_branch:= 'HO';
                 end if;
                 
         else
                    v_branch:= 'BANCA';  
                 
         end if;
                  
                  --raise_error(  'v_branch=='||v_branch);


             if  v_bill_count <=12  then
                   BEGIN
                   select SUM(DECODE (V_Bill_Type,  'DN', N_Trn_Amt,  'CN', - N_Trn_Amt))
                       INTO v_new_prem
                    FROM Gndt_Bill_Trans A
                     where  NVL (V_Cancel_Status, 'N') = 'N'
                         AND N_Trn_Amt != 0
                            AND N_Bill_Trn_No > 1
            --                AND V_BILL_TYPE = 'DN'
            --                 A.V_Policy_No NOT LIKE 'GL%'
                            and v_policy_no = i.V_POLICY_NO
                             AND TRUNC (D_Ref_Date)  BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                             
                                    EXCEPTION 
                         WHEN OTHERS THEN
                         v_new_prem := NULL;
                 END;
                 
             else
                     v_new_prem := NULL;
               
             END IF;
                 
--                 raise_error('v_count=='||v_count ||'v_beg_date=='||v_beg_date ||'v_issued_date ==' ||v_issued_date
--                  ||'v_to_date=='||v_to_date ||' i.V_POLICY_NO =='||  i.V_POLICY_NO||'v_new_prem=='||v_new_prem);
        
                 
                 
              if  v_bill_count >12  then
                   BEGIN
                   select SUM(DECODE (V_Bill_Type,  'DN', N_Trn_Amt,  'CN', -N_Trn_Amt))
                       INTO v_renew_amt
                    FROM Gndt_Bill_Trans A
                     where  NVL (V_Cancel_Status, 'N') = 'N'
                         AND N_Trn_Amt != 0
                            AND N_Bill_Trn_No > 1
            --                AND V_BILL_TYPE = 'DN'
            --                 A.V_Policy_No NOT LIKE 'GL%'
                            and v_policy_no = i.V_POLICY_NO
                             AND TRUNC (D_Ref_Date)  BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                             
                             
                                    EXCEPTION 
                         WHEN OTHERS THEN
                         v_renew_amt := NULL;
                 END;
                 
                  else
                     v_renew_amt := NULL;               
                 END IF;
                 
                 

                 


                 


            BEGIN           
                             
--            SELECT SUM(-N_TRN_AMT)
--            INTO v_refund_amt
--            FROM GNDT_BILL_TRANS a, LU_CODES c
--            WHERE V_BILL_TYPE = 'CN'
--            --AND NVL(N_BILL_BAL_AMT,0) > 0
--            --AND V_POLICY_NO LIKE '%813'
----            and NVL(a.V_COMPANY_CODE,'X') = NVL(b.V_COMPANY_CODE,'X')
----            and NVL(a.V_COMPANY_BRANCH,'X') = NVL(b.V_COMPANY_BRANCH,'X')
--            and TRUNC(D_BILL_RAISED_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
--            and V_BILL_SOURCE = LU_CODE
--            and LU_TYPE = 'BILL'
--            AND V_TRN_TYPE = 'RPMT'
--            AND V_BILL_BAL_TYPE != 'R'
--            AND LU_CODE  IN ( 'SGPR','SGOB')
--            AND V_POLICY_NO =  I.V_POLICY_NO;

            SELECT SUM(N_ACCUM_DEPOSIT)
            INTO v_refund_amt
            FROM PSDT_DEPOSIT_PAYOUT
            WHERE D_PAID BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
            AND V_POLICY_NO =  I.V_POLICY_NO;

            EXCEPTION 
            WHEN OTHERS THEN
            v_refund_amt := NULL;
            END;
            
            -- Get the Outstanding amount in a given period --
            
             BEGIN
               
                SELECT SUM(N_AMOUNT) 
                INTO v_outstanding_amt 
                FROM PPMT_OUTSTANDING_PREMIUM 
                WHERE V_POLICY_NO = I.V_POLICY_NO 
                AND V_STATUS='A'
                AND TRUNC (D_DUE_DATE)  BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);

                EXCEPTION 
                WHEN OTHERS THEN
                v_outstanding_amt := NULL;
                
            END;

                 
                 /*avg age*/
                 begin
                   select N_PROPOSER_AGE
                   into v_avg_age
                   FROM GNMT_POLICY a
                   WHERE  a.V_POLICY_NO = I.V_POLICY_NO;             
                    EXCEPTION 
                 WHEN OTHERS THEN
                 v_avg_age := NULL;
                 END;
                 
                 
                   /*cancelled premium*/
                   
                   BEGIN
                 select SUM(N_VOU_AMOUNT)
                 INTO v_cancelled_prem
                FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
                where PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND V_VOU_NO IN (SELECT  V_VOU_NO
                FROM PYDT_VOUCHER_POLICY_CLIENT
                WHERE V_POLICY_NO =   i.V_POLICY_NO)
                AND V_VOU_DESC = 'CANCELLATION - COOLING OFF'
                AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR') BETWEEN  TRUNC(v_from_date) AND TRUNC(v_to_date);
                 EXCEPTION 
                 WHEN OTHERS THEN
                 v_cancelled_prem := NULL;
                 END;
                 
                 
                 
                       BEGIN
                   select SUM(DECODE (V_Bill_Type,  'DN', N_Trn_Amt,  'CN', -N_Trn_Amt))
                       INTO v_gross_premium
                    FROM Gndt_Bill_Trans A
                     where  NVL (V_Cancel_Status, 'N') = 'N'
                         AND N_Trn_Amt != 0
                            AND N_Bill_Trn_No > 1
            --                AND V_BILL_TYPE = 'DN'
            --                 A.V_Policy_No NOT LIKE 'GL%'
                            and v_policy_no = i.V_POLICY_NO
                             AND TRUNC (D_Ref_Date)  BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                             
                                    EXCEPTION 
                         WHEN OTHERS THEN
                         v_gross_premium := NULL;
                 END;
                 
                 
                 
                 /*commissoin */
                 
                 begin
                 
                 SELECT  SUM(N_COMM_AMT) 
                 into v_comm_amt
                FROM AMMT_COMMISSION_INTIMATION a, AMMT_POL_COMM_DETAIL b, GNDT_BILL_TRANS c ,AMMM_AGENT_MASTER z
                WHERE A.V_POLICY_NO = B.V_POLICY_NO
                --And B.N_Comm_Intimation_Seq = A.N_Comm_Intimation_Seq(+)
                AND A.N_COMM_GEN_SEQ = B.N_COMM_SEQ
                --And A.V_Receipt_No =B.V_Receipt_No
                AND a.N_SEQ_NO = b.N_SEQ_NO
                AND a.V_PLAN_CODE = b.V_PLAN_CODE
                AND V_COMM_PROCESS_CODE IN ('G','C', 'R')
                AND N_BILL_TRN_NO = 1
                AND V_POSTED_REF_NO = V_BILL_NO
--                AND NVL(c.V_COMPANY_CODE,'X') = NVL(d.V_COMPANY_CODE,'X')
--                AND NVL(c.V_COMPANY_BRANCH,'X') = NVL(d.V_COMPANY_BRANCH,'X')
                and b.N_AGENT_NO = z.N_AGENT_NO
                 and b.N_AGENT_NO  = i.N_AGENT_NO 
                 and a.V_POLICY_NO  =  i.V_POLICY_NO
                and TRUNC(D_BILL_RAISED_DATE)    BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
                
                       EXCEPTION 
                 WHEN OTHERS THEN
                 v_comm_amt := NULL;
                 END;
                 
                 if i.V_PYMT_FREQ = 12 then
                 v_earned_amt :=  (NVL(v_new_prem,0) +  NVL(v_add_premium,0) ) * TO_NUMBER(TO_CHAR(v_from_date,'MM')) / 12;
                 
                 elsif  i.V_PYMT_FREQ = 6 then
                 v_earned_amt :=  (NVL(v_new_prem,0) +  NVL(v_add_premium,0) ) * TO_NUMBER(TO_CHAR(v_from_date,'MM')) / 6;
                 
                  elsif i.V_PYMT_FREQ = 3 then
                 v_earned_amt :=  (NVL(v_new_prem,0) +  NVL(v_add_premium,0) ) * TO_NUMBER(TO_CHAR(v_from_date,'MM')) / 3;
                 
                  elsif  i.V_PYMT_FREQ = 1 then
                 v_earned_amt :=  (NVL(v_new_prem,0) +  NVL(v_add_premium,0) ) * TO_NUMBER(TO_CHAR(v_from_date,'MM')) / 1;
                 
                 end if;
                 
                 
                 
                 
                 
--                   /*EMP COUNT*/
--                 begin
--                   select  COUNT(*)
--                   into v_emp_count
--                   FROM GNMT_POLICY a,  GNMT_POLICY_DETAIL b
--                   where a.V_POLICY_NO = b.V_POLICY_NO
--                   and  a.V_POLICY_NO = I.V_POLICY_NO
--                   AND TRUNC(D_ENTRY_DATE) BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date);
--                    EXCEPTION 
--                 WHEN OTHERS THEN
--                 v_emp_count := NULL;
--                 END;
--                 
--                 if v_emp_count = 0 then
--                 v_emp_count := null;
--                 end if;
                 
                 v_emp_count := 1;
                 

                 
                 
       /*sum asured */
                 begin
                   select  sum(N_SUM_COVERED)
                   into v_sum_assured
                   FROM GNMT_POLICY a
                   where  a.V_POLICY_NO = I.V_POLICY_NO;
               
                    EXCEPTION 
                 WHEN OTHERS THEN
                 v_sum_assured := NULL;
                 END;
                 
                 
                 v_upr_amt := (NVL(v_new_prem,0) +  NVL(v_add_premium,0) );
                 
                 
                 begin
                SELECT  V_DESCRIPTION
                INTO v_chn_desc
                FROM  AMMM_CHANNEL_MASTER
                WHERE N_CHANNEL_NO  = I.N_CHANNEL_NO;
                
                         EXCEPTION 
                 WHEN OTHERS THEN
                 v_chn_desc := NULL;
                 END;

                 
--                 v_gross_premium  := i.N_CONTRIBUTION;--(NVL(v_new_prem,0) +  NVL(v_add_premium,0) + NVL(v_refund_amt,0)+ NVL(v_renew_amt,0)  );
                
--                
--                IF    (v_new_prem IS NOT NULL OR
--                        v_gross_premium IS NOT NULL OR
--                        v_add_premium IS NOT NULL or
--                        v_avg_age IS NOT NULL or
--                        v_cancelled_prem is not null or
--                        v_comm_amt  is not null OR
--                        NVL(v_earned_amt,0)  <> 0  OR
--                         NVL(v_emp_count,0)  <> 0  or
--                        NVL( v_mon_sal,0) <> 0 OR
--                        NVL( v_sum_assured,0)  <> 0 OR
--                        NVL( v_upr_amt,0) <>  0  OR
--                          NVL( v_refund_amt,0)  <> 0 OR
--                        NVL( v_renew_amt,0) <>  0 
--                        
--                         ) THEN
                
                   insert into PGIS_UW_FACTS_GL_TST(
                   UFS_CLASS_CODE,
                   UFS_POL_NO,
                   UFS_PERIOD,
                   UFS_PREMIUM,
                   UFS_ADDL_PREMIUM,
                   UFS_BUS_TYPE,
                   UFS_AVG_AGE,
                   UFS_CANCELLED_PREMIUM,
                   UFS_COMM,
                   UFS_CR_DT,
                   UFS_CR_ID,
                   UFS_CUST_CODE, 
                   UFS_CUST_NAME, 
                   UFS_DIVN_CODE,
                   UFS_EARNED_PREMIUM,
                   UFS_EMP_COUNT,
                    UFS_MONTH_SAL,
                    UFS_POL_COUNT,
                    UFS_POL_SRC_OF_BUS,
                    UFS_PR_APPRV_DT, 
                    UFS_PR_PREM_TYPE,
                    UFS_PROD_CODE,
                    UFS_REFUND_PREMIUM,
                    UFS_RENEW_PREMIUM,
                    UFS_RISK_COUNT,
                    UFS_SI, 
                    UFS_SRC_CODE, 
                    UFS_UPD_DT, 
                    UFS_UPD_ID, 
                    UFS_UPR,            
                   UFS_NEW_PREMIUM,
                   PRD_START_DATE, 
                   PRD_END_DATE,
                   UFS_DATE,
                   UFS_POL_STATUS,
                   UFS_PREMIUM_OS,
                   UFS_PAY_METHOD,
                   UFS_COUNTRY_CODE)
                   
                   values(
                   I.V_PROD_LINE,
                   i.V_POLICY_NO,
                   TO_NUMBER(TO_CHAR(v_from_date,'YYYYMM')),
                   v_gross_premium,
                   v_add_premium,
                   'INDIVIDUAL LIFE',
                   v_avg_age,
                   v_cancelled_prem,
                   v_comm_amt,
                   v_from_date,
                   'JHLISFADMIN',
                      I.N_CUST_REF_NO,
                     I.V_NAME,
                     v_branch,
                     -- I.V_POLICY_BRANCH,
                     v_earned_amt,
                      v_emp_count,
                     v_mon_sal,
                    1,
                    v_chn_desc,
                    I.D_ISSUE,
                    I.V_PYMT_DESC,
                    I.V_PLAN_CODE,
                    v_refund_amt,
                    v_renew_amt,
                    v_emp_count,
                    v_sum_assured,
                    I.V_AGENT_CODE,
                       v_from_date,
                   'JHLISFADMIN',
                  v_upr_amt  ,
                   v_new_prem,
                   v_from_date,
                   v_to_date,
                   SYSDATE,
                   I.V_STATUS_DESC,
                   v_outstanding_amt,
                   I.V_PMT_METHOD_NAME,
                   'KENYA');
--                  END IF;
                   
                   
                 v_end_date := ADD_MONTHS(trunc( to_date(v_end_date,'DD/MM/RRRR'),'MM'),1);
                    
                END LOOP;          

            COMMIT;               


        END LOOP;

COMMIT;
 
 END;
 
 
 

 
--  PROCEDURE GET_REVIVAL_PREMIUM_TEST
--   IS                
--     
--   BEGIN
--   
----   NULL;
--   
--   DELETE FROM JHL_COL_REVIVAL_DTLS;
--
--         INSERT INTO JHL_COL_REVIVAL_DTLS (JRD_NO,
--                                       V_POLICY_NO,
--                                       LN_OUTS_PREM,
--                                       LN_OUTS_PREM_INT)
--              VALUES (JHL_JRD_NO_SEQ.NEXTVAL,
--                      '06',
--                      -100,
--                      -100);
--                      COMMIT;
--END;


PROCEDURE GET_REVIVAL_PREMIUM_TEST 
   IS
      V_POLICY_NO VARCHAR2 (40);
     LN_OUTS_PREM       NUMBER;
      LN_OUTS_PREM_INT   NUMBER;

      REV_OS_DT          DATE;

      LV_LAPS_CHK        VARCHAR2 (2);
      P_BASE_SUB         VARCHAR (1);

      CURSOR POL
      IS
         SELECT DISTINCT A.V_POLICY_NO,
                         V_CNTR_STAT_CODE,
                         D_PREM_DUE_DATE,
                         V_PYMT_FREQ
           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
                AND V_ROLE_CODE = 'SELLING'
                AND C.V_STATUS = 'A'
                AND A.V_POLICY_NO NOT LIKE 'GL%'
                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
                and A.V_POLICY_NO ='197242';
--                AND C.N_AGENT_NO IN
--                       (1218, 28020, 54560, 28779, 40560, 17358, 34620, 22778)
--         UNION
--         SELECT DISTINCT A.V_POLICY_NO,
--                         V_CNTR_STAT_CODE,
--                         D_PREM_DUE_DATE,
--                         V_PYMT_FREQ
--           FROM GNMT_POLICY A, AMMT_POL_AG_COMM C
--          WHERE     A.V_POLICY_NO = C.V_POLICY_NO
--                --And V_Role_Code = 'SELLING'
--                AND C.V_STATUS = 'A'
--                AND A.V_POLICY_NO NOT LIKE 'GL%'
--                AND V_CNTR_STAT_CODE IN ('NB022', 'NB025')
--                AND C.N_AGENT_NO IN (65620, 72770, 22778);
                
     
   BEGIN
   
--   DELETE FROM JHL_COL_REVIVAL_DTLS;
--
--         INSERT INTO JHL_COL_REVIVAL_DTLS (JRD_NO,
--                                       V_POLICY_NO,
--                                       LN_OUTS_PREM,
--                                       LN_OUTS_PREM_INT)
--              VALUES (JHL_JRD_NO_SEQ.NEXTVAL,
--                      v_pol_no,
--                      -100,
--                      -100);


--      DELETE FROM JHL_COL_REVIVAL_DTLS WHERE V_POLICY_NO = v_pol_no;
--
      FOR I IN POL
      LOOP
         --              RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);
         IF I.V_CNTR_STAT_CODE IN ('NB022', 'NB025')
         THEN
            P_BASE_SUB := 'A';
         ELSIF I.V_CNTR_STAT_CODE = 'NB010'
         THEN
            LV_LAPS_CHK := 'N';
            P_BASE_SUB := 'A';
         END IF;


         REV_OS_DT := I.D_PREM_DUE_DATE;

         WHILE NOT (TRUNC (REV_OS_DT) > TRUNC (SYSDATE))
         LOOP
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                   TO_NUMBER (I.V_PYMT_FREQ));
         END LOOP;

         REV_OS_DT :=
            BFN_NEW_ADD_MONTHS (TRUNC (REV_OS_DT),
                                - (TO_NUMBER (I.V_PYMT_FREQ))+1);


         IF LV_LAPS_CHK = 'Y'
         THEN
            REV_OS_DT :=
               BFN_NEW_ADD_MONTHS (TRUNC (I.D_PREM_DUE_DATE),
                                   - (TO_NUMBER (I.V_PYMT_FREQ)));
         END IF;

         BPG_REINSTATE_ENQUIRY.BPC_GET_ENQREVIVAL_PREM (I.V_POLICY_NO,
                                                        1,
                                                        'A',
                                                        TRUNC (REV_OS_DT),
                                                        SYSDATE,
                                                        LN_OUTS_PREM,
                                                        LN_OUTS_PREM_INT,
                                                        'P',
                                                        I.V_CNTR_STAT_CODE,
                                                        'N');

         INSERT INTO JHL_COL_REVIVAL_DTLS (JRD_NO,
                                       V_POLICY_NO,
                                       LN_OUTS_PREM,
                                       LN_OUTS_PREM_INT)
              VALUES (JHL_JRD_NO_SEQ.NEXTVAL,
                      I.V_POLICY_NO,
                      LN_OUTS_PREM,
                      LN_OUTS_PREM_INT);
      --                       RAISE_APPLICATION_ERROR(-20001,'ln_outs_prem=='||ln_outs_prem ||'ln_outs_prem_int=='||ln_outs_prem_int);


      END LOOP;

      COMMIT;
   END;
   
  PROCEDURE POPULATE_IL_UW IS 
     CURSOR POLICIES IS
                SELECT V_PROD_LINE UFS_CLASS_CODE, 
           POL.V_POLICY_NO UFS_POL_NO,       
           TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM')) UFS_PERIOD,
           --BIL.D_REF_DATE,
           SUM( DECODE (BIL.V_Bill_Type,  'DN', N_Trn_Amt,  'CN', -N_Trn_Amt)) UFS_PREMIUM,      
                      --JHL_GEN_PKG.get_contributions(POL.V_POLICY_NO,d_ref_date) CONTRIB_COUNT, 
                     -- JHL_GEN_PKG.is_new_prem(POL.V_POLICY_NO,d_ref_date) NEW_PREM, 
                           
          DECODE( JHL_GEN_PKG.is_new_prem(POL.V_POLICY_NO,d_ref_date), 'Y',sum(BIL.N_TRN_AMT),NULL ) UFS_NEW_PREMIUM,
           DECODE( JHL_GEN_PKG.is_new_prem(POL.V_POLICY_NO,d_ref_date), 'N',sum(BIL.N_TRN_AMT),NULL ) UFS_RENEW_PREMIUM,
           ''UFS_ADDL_PREMIUM,
           (
            select SUM(N_VOU_AMOUNT)
                FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
                where PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
                AND V_VOU_NO IN (SELECT  V_VOU_NO
                FROM PYDT_VOUCHER_POLICY_CLIENT
                WHERE V_POLICY_NO =   POL.V_POLICY_NO)
                AND V_VOU_DESC = 'CANCELLATION - COOLING OFF'
--                AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR') BETWEEN  TRUNC(v_from_date) AND TRUNC(v_to_date)
                 AND TO_NUMBER(TO_CHAR( D_VOU_DATE,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
                ) 
           
           UFS_CANCELLED_PREMIUM,
                ( SELECT SUM(N_AMOUNT) 
                FROM PPMT_OUTSTANDING_PREMIUM  OP
                WHERE OP.V_POLICY_NO = POL.V_POLICY_NO 
                AND OP.V_STATUS='A'
                AND TO_NUMBER(TO_CHAR( OP.D_DUE_DATE,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
                )  UFS_PREMIUM_OS,
--          (
--                  SELECT  SUM(N_COMM_AMT) 
--                FROM AMMT_COMMISSION_INTIMATION a, AMMT_POL_COMM_DETAIL b, GNDT_BILL_TRANS c 
--                WHERE A.V_POLICY_NO = B.V_POLICY_NO
--                --And B.N_Comm_Intimation_Seq = A.N_Comm_Intimation_Seq(+)
--                AND A.N_COMM_GEN_SEQ = B.N_COMM_SEQ
--                --And A.V_Receipt_No =B.V_Receipt_No
--                AND a.N_SEQ_NO = b.N_SEQ_NO
--                AND a.V_PLAN_CODE = b.V_PLAN_CODE
--                AND V_COMM_PROCESS_CODE IN ('G','C', 'R')
--                AND c.N_BILL_TRN_NO = 1
--                AND a.V_POSTED_REF_NO = c.V_BILL_NO
----                AND NVL(c.V_COMPANY_CODE,'X') = NVL(d.V_COMPANY_CODE,'X')
----                AND NVL(c.V_COMPANY_BRANCH,'X') = NVL(d.V_COMPANY_BRANCH,'X')
----                and b.N_AGENT_NO = z.N_AGENT_NO
--                 and b.N_AGENT_NO  = AGN.N_AGENT_NO
--                 and a.V_POLICY_NO  =  pol.V_POLICY_NO
----                and TRUNC(c.D_BILL_RAISED_DATE)    BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
--                     AND TO_NUMBER(TO_CHAR(  c.D_BILL_RAISED_DATE,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
--          
--          )
           ''UFS_COMM,
           ''   UFS_EARNED_PREMIUM,
              ( SELECT SUM(N_ACCUM_DEPOSIT)

            FROM PSDT_DEPOSIT_PAYOUT PD
            WHERE TO_NUMBER(TO_CHAR(PD.D_PAID,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
            AND PD.V_POLICY_NO =  pol.V_POLICY_NO )UFS_REFUND_PREMIUM,
           'INDIVIDUAL LIFE' UFS_BUS_TYPE,
            NULL UFS_AVG_AGE,
           POL.V_LASTUPD_INFTIM UFS_CR_DT,
           POL.V_LASTUPD_USER UFS_CR_ID,
           CU.N_CUST_REF_NO UFS_CUST_CODE,
           CU.V_NAME UFS_CUST_NAME, 
           DECODE(AGN.N_CHANNEL_NO,10,NVL(JHL_GEN_PKG.GET_AGENCY_HIERARCHY(AGN.N_AGENT_NO,'15'),'HO'),'BANCA') UFS_DIVN_CODE,
           1 UFS_EMP_COUNT,
           ''UFS_MONTH_SAL,
           1 UFS_POL_COUNT,
           ( SELECT  V_DESCRIPTION FROM  AMMM_CHANNEL_MASTER WHERE N_CHANNEL_NO = AGN.N_CHANNEL_NO) UFS_POL_SRC_OF_BUS,
           POL.D_ISSUE UFS_PR_APPRV_DT, 
            FREQ.V_PYMT_DESC UFS_PR_PREM_TYPE,
            PROD.V_PLAN_CODE UFS_PROD_CODE,
            1 UFS_RISK_COUNT,
            POL.N_SUM_COVERED UFS_SI, 
           AGN.V_AGENT_CODE UFS_SRC_CODE, 
            SYSDATE UFS_UPD_DT, 
            'JHLISFADMIN' UFS_UPD_ID, 
            '' UFS_UPR,
            (SELECT trunc( to_date(D_REF_DATE,'DD/MM/RRRR'),'MM')from dual)PRD_START_DATE, 
           (select  last_day(D_REF_DATE)  from dual) PRD_END_DATE,
           SYSDATE UFS_DATE,
           PST.V_STATUS_DESC UFS_POL_STATUS,
           PAY.V_PMT_METHOD_NAME UFS_PAY_METHOD,
           BIL.V_ADJUSTED_FROM UFS_PREMIUM_SRC,
           'KENYA'UFS_COUNTRY_CODE       


FROM GNMT_POLICY POL,GNMM_PLAN_MASTER PROD,   AMMT_POL_AG_COMM COM, AMMM_AGENT_MASTER AGN,
       GNMT_CUSTOMER_MASTER CAGN, GNMM_COMPANY_MASTER CO,GNMT_CUSTOMER_MASTER CU,    
       GNLU_FREQUENCY_MASTER FREQ, GNMM_POLICY_STATUS_MASTER PST, GNLU_PAY_METHOD PAY, GNDT_BILL_TRANS BIL
WHERE  POL.V_PLAN_CODE = PROD.V_PLAN_CODE
AND POL.V_POLICY_NO = COM.V_POLICY_NO
AND COM.N_AGENT_NO = AGN.N_AGENT_NO
AND AGN.N_CUST_REF_NO = CAGN.N_CUST_REF_NO(+)
AND AGN.V_COMPANY_CODE = CO.V_COMPANY_CODE(+)
AND AGN.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH(+)
AND POL.N_PAYER_REF_NO = CU.N_CUST_REF_NO
AND POL.V_CNTR_STAT_CODE = PST.V_STATUS_CODE
AND V_ROLE_CODE = 'SELLING'
AND COM.V_STATUS = 'A'
AND POL.V_PMT_METHOD_CODE = PAY.V_PMT_METHOD_CODE(+)
AND V_PROD_LINE <> 'LOB003'
AND BIL.V_Policy_No NOT LIKE 'GL%'
AND POL.V_PYMT_FREQ = FREQ.V_PYMT_FREQ
AND BIL.V_POLICY_NO = POL.V_POLICY_NO
AND BIL.V_POLICY_NO = COM.V_POLICY_NO
AND NVL (BIL.V_Cancel_Status, 'N') = 'N'
AND BIL.N_Trn_Amt != 0
AND BIL.N_Bill_Trn_No > 1
--AND BIL.D_REF_DATE BETWEEN '01-AUG-2018' AND '22-AUG-2018'
AND TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYY')) = 2018
AND TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM')) <> 201807 
--AND POL.V_POLICY_NO = 'IL201200085752'


GROUP BY 
V_PROD_LINE , 
POL.V_POLICY_NO,
POL.V_LASTUPD_INFTIM ,
POL.V_LASTUPD_USER ,
CU.N_CUST_REF_NO ,
CU.V_NAME , 
AGN.N_CHANNEL_NO ,
POL.D_ISSUE , 
FREQ.V_PYMT_DESC ,
PROD.V_PLAN_CODE ,
POL.N_SUM_COVERED , 
AGN.V_AGENT_CODE ,    
D_REF_DATE,  
V_STATUS_DESC ,
PAY.V_PMT_METHOD_NAME ,
 BIL.V_ADJUSTED_FROM,
AGN.N_AGENT_NO;
     
     
  BEGIN  
  
        FOR I IN POLICIES LOOP    
                 INSERT INTO PGIS_UW_FACTS_IL
                               (UFS_CLASS_CODE,
                               UFS_POL_NO,
                               UFS_PERIOD,
                               UFS_PREMIUM,            
                               UFS_NEW_PREMIUM,
                                UFS_RENEW_PREMIUM,
                               UFS_ADDL_PREMIUM,
                               UFS_CANCELLED_PREMIUM,
                               UFS_PREMIUM_OS,
                               UFS_COMM,
                               UFS_EARNED_PREMIUM,
                                UFS_REFUND_PREMIUM,
                               UFS_BUS_TYPE,
                               UFS_AVG_AGE,
                               UFS_CR_DT,
                               UFS_CR_ID,
                               UFS_CUST_CODE, 
                               UFS_CUST_NAME, 
                               UFS_DIVN_CODE,
                               UFS_EMP_COUNT,
                                UFS_MONTH_SAL,
                                UFS_POL_COUNT,
                                UFS_POL_SRC_OF_BUS,
                                UFS_PR_APPRV_DT, 
                                UFS_PR_PREM_TYPE,
                                UFS_PROD_CODE,
                                UFS_RISK_COUNT,
                                UFS_SI, 
                                UFS_SRC_CODE, 
                                UFS_UPD_DT, 
                                UFS_UPD_ID, 
                                UFS_UPR,
                               PRD_START_DATE, 
                               PRD_END_DATE,
                               UFS_DATE,
                               UFS_POL_STATUS,
                               UFS_PAY_METHOD,
                               UFS_PREMIUM_SRC,
                               UFS_COUNTRY_CODE)
                               
                               VALUES(
                               I.UFS_CLASS_CODE, 
                               I.UFS_POL_NO,       
                               I.UFS_PERIOD,
                               I.UFS_PREMIUM,                                               
                               I.UFS_NEW_PREMIUM,
                               I.UFS_RENEW_PREMIUM,
                               I.UFS_ADDL_PREMIUM,
                               I.UFS_CANCELLED_PREMIUM,
                               I.UFS_PREMIUM_OS,
                               I.UFS_COMM,
                               I.UFS_EARNED_PREMIUM,
                               I.UFS_REFUND_PREMIUM,
                               I.UFS_BUS_TYPE,
                               I.UFS_AVG_AGE,
                               I.UFS_CR_DT,
                               I.UFS_CR_ID,
                               I.UFS_CUST_CODE,
                               I.UFS_CUST_NAME, 
                               I.UFS_DIVN_CODE,
                               I.UFS_EMP_COUNT,
                               I.UFS_MONTH_SAL,
                               I.UFS_POL_COUNT,
                               I.UFS_POL_SRC_OF_BUS,
                               I.UFS_PR_APPRV_DT, 
                               I.UFS_PR_PREM_TYPE,
                               I.UFS_PROD_CODE,
                               I.UFS_RISK_COUNT,
                               I.UFS_SI, 
                               I.UFS_SRC_CODE, 
                               I.UFS_UPD_DT, 
                               I.UFS_UPD_ID, 
                               I.UFS_UPR,
                               I.PRD_START_DATE, 
                               I.PRD_END_DATE,
                               I.UFS_DATE,
                               I.UFS_POL_STATUS,
                               I.UFS_PAY_METHOD,
                               I.UFS_PREMIUM_SRC,
                               I.UFS_COUNTRY_CODE
                               
                               );

--                        SELECT V_PROD_LINE UFS_CLASS_CODE, 
--                       POL.V_POLICY_NO UFS_POL_NO,       
--                       TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM')) UFS_PERIOD,
--                       --BIL.D_REF_DATE,
--                       SUM( DECODE (BIL.V_Bill_Type,  'DN', N_Trn_Amt,  'CN', -N_Trn_Amt)) UFS_PREMIUM,      
--                                  --JHL_GEN_PKG.get_contributions(POL.V_POLICY_NO,d_ref_date) CONTRIB_COUNT, 
--                                 -- JHL_GEN_PKG.is_new_prem(POL.V_POLICY_NO,d_ref_date) NEW_PREM, 
--                                       
--                      DECODE( JHL_GEN_PKG.is_new_prem(POL.V_POLICY_NO,d_ref_date), 'Y',sum(BIL.N_TRN_AMT),NULL ) UFS_NEW_PREMIUM,
--                       DECODE( JHL_GEN_PKG.is_new_prem(POL.V_POLICY_NO,d_ref_date), 'N',sum(BIL.N_TRN_AMT),NULL ) UFS_RENEW_PREMIUM,
--                       ''UFS_ADDL_PREMIUM,
--                       (
--                        select SUM(N_VOU_AMOUNT)
--                            FROM Pymt_Voucher_Root PM, Pymt_Vou_Master PV
--                            where PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO
--                            AND V_VOU_NO IN (SELECT  V_VOU_NO
--                            FROM PYDT_VOUCHER_POLICY_CLIENT
--                            WHERE V_POLICY_NO =   POL.V_POLICY_NO)
--                            AND V_VOU_DESC = 'CANCELLATION - COOLING OFF'
--            --                AND TO_DATE(D_VOU_DATE,'DD/MM/RRRR') BETWEEN  TRUNC(v_from_date) AND TRUNC(v_to_date)
--                             AND TO_NUMBER(TO_CHAR( D_VOU_DATE,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
--                            ) 
--                       
--                       UFS_CANCELLED_PREMIUM,
--                            ( SELECT SUM(N_AMOUNT) 
--                            FROM PPMT_OUTSTANDING_PREMIUM  OP
--                            WHERE OP.V_POLICY_NO = POL.V_POLICY_NO 
--                            AND OP.V_STATUS='A'
--                            AND TO_NUMBER(TO_CHAR( OP.D_DUE_DATE,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
--                            )  UFS_PREMIUM_OS,
--                      (
--                              SELECT  SUM(N_COMM_AMT) 
--                            FROM AMMT_COMMISSION_INTIMATION a, AMMT_POL_COMM_DETAIL b, GNDT_BILL_TRANS c 
--                            WHERE A.V_POLICY_NO = B.V_POLICY_NO
--                            --And B.N_Comm_Intimation_Seq = A.N_Comm_Intimation_Seq(+)
--                            AND A.N_COMM_GEN_SEQ = B.N_COMM_SEQ
--                            --And A.V_Receipt_No =B.V_Receipt_No
--                            AND a.N_SEQ_NO = b.N_SEQ_NO
--                            AND a.V_PLAN_CODE = b.V_PLAN_CODE
--                            AND V_COMM_PROCESS_CODE IN ('G','C', 'R')
--                            AND c.N_BILL_TRN_NO = 1
--                            AND a.V_POSTED_REF_NO = c.V_BILL_NO
--            --                AND NVL(c.V_COMPANY_CODE,'X') = NVL(d.V_COMPANY_CODE,'X')
--            --                AND NVL(c.V_COMPANY_BRANCH,'X') = NVL(d.V_COMPANY_BRANCH,'X')
--            --                and b.N_AGENT_NO = z.N_AGENT_NO
--                             and b.N_AGENT_NO  = AGN.N_AGENT_NO
--                             and a.V_POLICY_NO  =  pol.V_POLICY_NO
--            --                and TRUNC(c.D_BILL_RAISED_DATE)    BETWEEN TRUNC(v_from_date) AND TRUNC(v_to_date)
--                                 AND TO_NUMBER(TO_CHAR(  c.D_BILL_RAISED_DATE,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
--                      
--                      )
--                       UFS_COMM,
--                       ''   UFS_EARNED_PREMIUM,
--                          ( SELECT SUM(N_ACCUM_DEPOSIT)
--
--                        FROM PSDT_DEPOSIT_PAYOUT PD
--                        WHERE TO_NUMBER(TO_CHAR(PD.D_PAID,'YYYYMM'))  =  TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM'))
--                        AND PD.V_POLICY_NO =  pol.V_POLICY_NO )UFS_REFUND_PREMIUM,
--                       'INDIVIDUAL LIFE' UFS_BUS_TYPE,
--                        NULL UFS_AVG_AGE,
--                       POL.V_LASTUPD_INFTIM UFS_CR_DT,
--                       POL.V_LASTUPD_USER UFS_CR_ID,
--                       CU.N_CUST_REF_NO UFS_CUST_CODE,
--                       CU.V_NAME UFS_CUST_NAME, 
--                       DECODE(AGN.N_CHANNEL_NO,10,NVL(JHL_GEN_PKG.GET_AGENCY_HIERARCHY(AGN.N_AGENT_NO,'15'),'HO'),'BANCA') UFS_DIVN_CODE,
--                       1 UFS_EMP_COUNT,
--                       ''UFS_MONTH_SAL,
--                       1 UFS_POL_COUNT,
--                       ( SELECT  V_DESCRIPTION FROM  AMMM_CHANNEL_MASTER WHERE N_CHANNEL_NO = AGN.N_CHANNEL_NO) UFS_POL_SRC_OF_BUS,
--                       POL.D_ISSUE UFS_PR_APPRV_DT, 
--                        FREQ.V_PYMT_DESC UFS_PR_PREM_TYPE,
--                        PROD.V_PLAN_CODE UFS_PROD_CODE,
--                        1 UFS_RISK_COUNT,
--                        POL.N_SUM_COVERED UFS_SI, 
--                       AGN.V_AGENT_CODE UFS_SRC_CODE, 
--                        SYSDATE UFS_UPD_DT, 
--                        'JHLISFADMIN' UFS_UPD_ID, 
--                        '' UFS_UPR,
--                        (SELECT trunc( to_date(D_REF_DATE,'DD/MM/RRRR'),'MM')from dual)PRD_START_DATE, 
--                       (select  last_day(D_REF_DATE)  from dual) PRD_END_DATE,
--                       SYSDATE UFS_DATE,
--                       PST.V_STATUS_DESC UFS_POL_STATUS,
--                       PAY.V_PMT_METHOD_NAME UFS_PAY_METHOD,
--                       BIL.V_ADJUSTED_FROM UFS_PREMIUM_SRC,
--                       'KENYA'UFS_COUNTRY_CODE       
--
--
--            FROM GNMT_POLICY POL,GNMM_PLAN_MASTER PROD,   AMMT_POL_AG_COMM COM, AMMM_AGENT_MASTER AGN,
--                   GNMT_CUSTOMER_MASTER CAGN, GNMM_COMPANY_MASTER CO,GNMT_CUSTOMER_MASTER CU,    
--                   GNLU_FREQUENCY_MASTER FREQ, GNMM_POLICY_STATUS_MASTER PST, GNLU_PAY_METHOD PAY, GNDT_BILL_TRANS BIL
--            WHERE  POL.V_PLAN_CODE = PROD.V_PLAN_CODE
--            AND POL.V_POLICY_NO = COM.V_POLICY_NO
--            AND COM.N_AGENT_NO = AGN.N_AGENT_NO
--            AND AGN.N_CUST_REF_NO = CAGN.N_CUST_REF_NO(+)
--            AND AGN.V_COMPANY_CODE = CO.V_COMPANY_CODE(+)
--            AND AGN.V_COMPANY_BRANCH = CO.V_COMPANY_BRANCH(+)
--            AND POL.N_PAYER_REF_NO = CU.N_CUST_REF_NO
--            AND POL.V_CNTR_STAT_CODE = PST.V_STATUS_CODE
--            AND V_ROLE_CODE = 'SELLING'
--            AND COM.V_STATUS = 'A'
--            AND POL.V_PMT_METHOD_CODE = PAY.V_PMT_METHOD_CODE(+)
--            AND V_PROD_LINE <> 'LOB003'
--            AND BIL.V_Policy_No NOT LIKE 'GL%'
--            AND POL.V_PYMT_FREQ = FREQ.V_PYMT_FREQ
--            AND BIL.V_POLICY_NO = POL.V_POLICY_NO
--            AND BIL.V_POLICY_NO = COM.V_POLICY_NO
--            AND NVL (BIL.V_Cancel_Status, 'N') = 'N'
--            AND BIL.N_Trn_Amt != 0
--            AND BIL.N_Bill_Trn_No > 1
--            --AND TO_NUMBER(TO_CHAR(BIL.D_REF_DATE,'YYYYMM')) = 201808 
--            --AND POL.V_POLICY_NO = 'IL201200085752'
--
--
--            GROUP BY 
--            V_PROD_LINE , 
--            POL.V_POLICY_NO,
--            POL.V_LASTUPD_INFTIM ,
--            POL.V_LASTUPD_USER ,
--            CU.N_CUST_REF_NO ,
--            CU.V_NAME , 
--            AGN.N_CHANNEL_NO ,
--            POL.D_ISSUE , 
--            FREQ.V_PYMT_DESC ,
--            PROD.V_PLAN_CODE ,
--            POL.N_SUM_COVERED , 
--            AGN.V_AGENT_CODE ,    
--            D_REF_DATE,  
--            V_STATUS_DESC ,
--            PAY.V_PMT_METHOD_NAME ,
--             BIL.V_ADJUSTED_FROM,
--            AGN.N_AGENT_NO;
                   
        COMMIT;      


        END LOOP;
 
 END;

FUNCTION GET_AGENT_NAME
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2 IS

    CURSOR C1 IS
    SELECT V_AGENT_CODE||'-'||TRIM(V_COMPANY_NAME)||' ('||TRIM(V_ADD_THREE)||')'
    FROM AMMM_AGENT_MASTER a, GNMM_COMPANY_MASTER b, GNDT_COMPANY_ADDRESS c
    WHERE A.V_COMPANY_CODE = b.V_COMPANY_CODE
    AND A.V_COMPANY_BRANCH = B.V_COMPANY_BRANCH
    AND b.V_COMPANY_CODE = c.V_COMPANY_CODE(+)
    AND B.V_COMPANY_BRANCH =C.V_COMPANY_BRANCH(+)
    AND a.N_AGENT_NO = P_AGENT_NO
  AND ROWNUM =1      
    UNION
    SELECT V_AGENT_CODE||'-'||TRIM(V_NAME)||' ('||TRIM(c.V_ADD_THREE)||')' AGENCY 
    FROM AMMM_AGENT_MASTER a, GNMT_CUSTOMER_MASTER b, GNDT_CUSTOMER_ADDRESS c
    WHERE a.N_CUST_REF_NO = b.N_CUST_REF_NO
    AND b.N_CUST_REF_NO = c.N_CUST_REF_NO
    AND N_AGENT_NO=P_AGENT_NO
 AND ROWNUM =1;

    V_TEMP VARCHAR2 (200);

    BEGIN


        IF C1%ISOPEN THEN CLOSE C1; END IF;
        OPEN C1;
        FETCH C1 INTO V_TEMP;
           
        RETURN V_TEMP;

    END;

    FUNCTION get_all_agn_persistancy(v_date date, v_m_start number, v_m_end number) RETURN number IS

    v_per number;

    BEGIN

SELECT
        ROUND(SUM(PERS_STATUS_6M)/COUNT(PERS_STATUS_6M)*100,2) PERS
        into v_per
        FROM
        (
        SELECT N_AGENT_NO, V_POLICY_NO, 
        DECODE(JHL_SALESFORCE_UTILS.WOP_STATUS(V_POLICY_NO), 'YES', 1, DECODE(V_CNTR_STAT_DESC, 'IN-FORCE',1,0)) PERS_STATUS_6M
        FROM JHL_SALESFORCE_DIGITAL_DATA
        WHERE V_CNTR_STAT_DESC IN ('IN-FORCE','LAPSE','APL LAPSE','SURRENDERED')
        AND N_AGENT_LEVEL=40
        AND MONTHS_BETWEEN(TO_DATE(v_date, 'dd-MM-RRRR'), D_COMMENCEMENT) >= v_m_start --6 OR 12
        AND MONTHS_BETWEEN(TO_DATE(v_date, 'dd-MM-RRRR'), D_COMMENCEMENT) < v_m_end     --12 OR 24
        ) Z;
       -- WHERE N_AGENT_NO IN ($agent->n_agent_no)
--       WHERE N_AGENT_NO = v_agn_no
--        GROUP BY N_AGENT_NO;
        
        return v_per  ;
               
--        exception
--        when others then
--        return 0;

    END; 
    
    
     FUNCTION AGENT_NAME
    (P_AGENT_NO IN AMMM_AGENT_MASTER.N_AGENT_NO%TYPE)
  RETURN VARCHAR2 IS
    V_TEMP VARCHAR2 (200);

    BEGIN
            
--            SELECT V_AGENT_CODE||'-'||TRIM(V_NAME)||' ('||TRIM(V_ADD_THREE)||')' INTO V_TEMP
--            FROM AMMM_AGENT_MASTER a, GNMT_CUSTOMER_MASTER b, GNDT_CUSTOMER_ADDRESS c
--            WHERE a.N_CUST_REF_NO = b.N_CUST_REF_NO
--            AND b.N_CUST_REF_NO = c.N_CUST_REF_NO
--            AND a.N_AGENT_NO = P_AGENT_NO
--            AND ROWNUM =1;
--    EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--            V_TEMP := 'X';

            SELECT AGENCY INTO V_TEMP
            FROM
            (
            SELECT V_AGENT_CODE||'-'||TRIM(V_NAME)||' ('||TRIM(c.V_ADD_THREE)||')' AGENCY, c.N_ADD_SEQ_NO--INTO V_TEMP
            FROM AMMM_AGENT_MASTER a, GNMT_CUSTOMER_MASTER b, GNDT_CUSTOMER_ADDRESS c
            WHERE a.N_CUST_REF_NO = b.N_CUST_REF_NO
            AND b.N_CUST_REF_NO = c.N_CUST_REF_NO
            AND N_AGENT_NO=P_AGENT_NO
            ORDER BY N_ADD_SEQ_NO DESC
            )
            WHERE ROWNUM=1;
           
            RETURN V_TEMP;

    END;  
    
    
     FUNCTION RIDER_PREMIUM
    (P_POLICY_NO IN VARCHAR2)
  RETURN NUMBER IS
    V_TEMP NUMBER;

    BEGIN
            
            SELECT SUM(N_RIDER_PREMIUM) INTO V_TEMP
            FROM GNMT_POLICY_RIDERS
            WHERE V_POLICY_NO = P_POLICY_NO;
           
            RETURN V_TEMP;


    END;
    
    
     FUNCTION GET_PREV_STATUS
    (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE)
  RETURN VARCHAR2 IS
    V_TEMP VARCHAR2 (200);
    V_MULTI VARCHAR2 (2);
    V_USER VARCHAR2 (200);
    

    BEGIN
            
        SELECT PREV_STATUS INTO V_TEMP
        FROM
        (
        SELECT V_POLICY_NO, V_PREV_STAT_CODE, y.V_STATUS_DESC PREV_STATUS, V_CURR_STAT_CODE, z.V_STATUS_DESC CURR_STATUS, N_SEQ
        FROM GN_CONTRACT_STATUS_LOG x, GNMM_POLICY_STATUS_MASTER y, GNMM_POLICY_STATUS_MASTER z
        WHERE V_PLRI_FLAG='P'
        AND v_policy_no like P_POLICY_NO
        AND V_PREV_STAT_CODE = y.V_STATUS_CODE
        AND V_CURR_STAT_CODE = z.V_STATUS_CODE
        ORDER BY N_SEQ DESC
        )
        WHERE ROWNUM=1;

        RETURN V_TEMP;


    END;     
    
 
FUNCTION Get_Claim_Adjusted_Amt (p_claim_no IN CLDT_PROVISION_DETAIL.V_CLAIM_NO%TYPE) RETURN NUMBER IS
    v_rt NUMBER;
    

    BEGIN
         
        SELECT  SUM(NVL(DECODE(V_PROV_TYPE, 'INC-PROV', N_AMOUNT, -N_AMOUNT),0))
         INTO v_rt
        FROM CLDT_PROVISION_DETAIL A
        WHERE  V_PROV_TYPE  IN ( 'INC-PROV', 'DEC-PROV')
        --AND V_AMOUNT_TYPE <> 'I'
        AND V_CLAIM_NO = p_claim_no;

        RETURN v_rt;


    END;    
    
    
    FUNCTION Get_Date_Diff (v_from_dt DATE , v_to_dt DATE ) RETURN NUMBER IS
    v_rt NUMBER;
    

    BEGIN
    
          select  abs(  NVL(v_from_dt, TRUNC(SYSDATE)) - trunc(v_to_dt))
          into v_rt
          from dual;


        RETURN v_rt;


    END;    
    
    
    
    FUNCTION GET_CUR_POL_STATUS
    (P_POLICY_NO IN GNMT_POLICY.V_POLICY_NO%TYPE)
  RETURN VARCHAR2 IS
    V_TEMP VARCHAR2 (200);
    V_MULTI VARCHAR2 (2);
    V_USER VARCHAR2 (200);
    

    BEGIN
    
    SELECT V_STATUS_DESC
    INTO V_TEMP
    FROM GNMT_POLICY POL, GNMM_POLICY_STATUS_MASTER POL_STATUS
    WHERE POL.V_CNTR_STAT_CODE = POL_STATUS.V_STATUS_CODE
    AND POL.V_POLICY_NO = P_POLICY_NO;
            


        RETURN V_TEMP;


    END;   



FUNCTION get_cleared_pol_apl (p_policy_no   IN GNMT_POLICY.V_POLICY_NO%TYPE,
                              v_type           VARCHAR,
                              v_end_date       DATE)
   RETURN NUMBER
IS
   v_amt         NUMBER;
   v_apl_trans   NUMBER;
   v_apl_vou     NUMBER;
BEGIN
   IF (v_type = 'P')
   THEN
      SELECT SUM (NVL (APLT.N_APL_TRANS_REPAID, 0))
        INTO v_apl_trans
        FROM PSMT_POLICY_APL APL, PSDT_APL_TRANSACTION APLT
       WHERE     APL.N_apl_ref_no = APLT.N_apl_ref_no
             AND APLT.V_apl_trans_cleared = 'Y'
             AND APL.V_POLICY_NO = p_policy_no
             AND TRUNC (APLT.D_apl_trans_cleared) >=
                    TRUNC (v_end_date);


      SELECT SUM (NVL (N_RECREF_AMOUNT, 0))
        INTO v_apl_vou
        FROM CLDT_RECOREF_MASTER
       WHERE     V_POLICY_NO = p_policy_no
             AND V_RECREF_CODE = '12'
             AND V_RECREF_FLAG = 'S';
   ELSE
      SELECT SUM (NVL (APLT.N_INT_PAID, 0))
        INTO v_apl_trans
        FROM PSMT_POLICY_APL APL, PSDT_APL_TRANSACTION APLT
       WHERE     APL.N_apl_ref_no = APLT.N_apl_ref_no
             AND APLT.V_apl_trans_cleared = 'Y'
             AND APL.V_POLICY_NO = p_policy_no
             AND TRUNC (APLT.D_apl_trans_cleared) >=
                    TRUNC (v_end_date);


      SELECT SUM (NVL (N_RECREF_AMOUNT, 0))
        INTO v_apl_vou
        FROM CLDT_RECOREF_MASTER
       WHERE     V_POLICY_NO = p_policy_no
         AND V_RECREF_CODE = '13'
         AND V_RECREF_FLAG = 'S';
         
   END IF;
   
    SELECT DECODE(NVL(v_apl_vou,0),0, NVL(v_apl_trans,0), NVL(v_apl_vou,0) )
    INTO v_amt
    FROM DUAL;


        RETURN v_amt;


    END;


FUNCTION get_claim_type(claim_no   VARCHAR, v_vou_desc VARCHAR)
   RETURN VARCHAR IS
   
   v_desc VARCHAR2(200);
BEGIN

            BEGIN
            SELECT H.V_DESCRIPTION
            INTO v_desc
            FROM CLDT_CLAIM_EVENT_POLICY_LINK G,CLLU_TYPE_MASTER H
            WHERE   G.V_CLAIM_TYPE = H.V_CLAIM_TYPE
            AND G.V_CLAIM_NO = claim_no;
            EXCEPTION
            WHEN OTHERS THEN
            v_desc := v_vou_desc;
            END;
            
            IF NVL(v_desc,v_vou_desc)  IN ('Claims Payment', 'Maturity claim') THEN 
              v_desc := 'Maturity';
            ELSIF  NVL(v_desc,v_vou_desc)  IN ('Death claim') THEN  
               v_desc := 'Death';
            END IF;
            
             IF v_vou_desc  IN ('TOTAL SURRENDER - LIFE') THEN
              v_desc := 'Surrender';
             END IF;
             
             
                 IF v_vou_desc  IN ('CASH PAYMENT') THEN
              v_desc := 'Partial Payment';
             END IF;
             
            

RETURN NVL(v_desc,v_vou_desc);

END;


FUNCTION get_prev_rct_dt(pol_no VARCHAR, v_cur_date DATE)
   RETURN DATE IS
   
   v_prev_dt  DATE;
BEGIN

         SELECT  MAX(RCT.D_RECEIPT_DATE)
         INTO v_prev_dt
         FROM REMT_RECEIPT RCT
         WHERE  RCT.V_RECEIPT_TABLE = 'DETAIL'
         AND RCT.V_POLICY_NO = pol_no
         AND RCT.D_RECEIPT_DATE <v_cur_date;
         
         RETURN v_prev_dt;
END;


FUNCTION get_prev_rct_amt(pol_no VARCHAR, v_date DATE)
   RETURN NUMBER IS
   
   v_amt  NUMBER;
BEGIN

         SELECT  SUM(RCT.N_RECEIPT_AMT)
         INTO v_amt
         FROM REMT_RECEIPT RCT
         WHERE  RCT.V_RECEIPT_TABLE = 'DETAIL'
         AND RCT.V_POLICY_NO = pol_no
         AND TRUNC(RCT.D_RECEIPT_DATE) = TRUNC(v_date);
         
         RETURN v_amt;
END;

PROCEDURE POPULATE_BI_DATE IS 

  v_dt date;
  v_day_count number;
  v_wk_count  number;
   v_wk_start_dt date;
   v_wk_end_dt date;
 BEGIN
 
 v_dt := '01-JAN-20';
 v_day_count := 1;
  v_wk_count  := 1;
  
 v_wk_start_dt := '01-JAN-20';
   v_wk_end_dt  := '01-JAN-20';
   
   DELETE FROM JHL_BI_DATES;
 
 WHILE(v_dt <= TRUNC(SYSDATE))
         LOOP
         
         insert into JHL_BI_DATES (BID_NO, BID_DATE, BID_WEEK, BID_WK_START_DATE, BID_WK_END_DATE)
         VALUES(v_day_count,v_dt,v_wk_count,v_wk_start_dt,v_wk_end_dt);
         
               v_dt :=v_dt+1;
               v_day_count :=v_day_count+1;
               v_wk_count := CEIL((v_day_count/7) );
         
         END LOOP;
  
 END;
 
 
 FUNCTION get_wk_start_end(v_wk_no NUMBER, v_type VARCHAR)
   RETURN DATE IS
   
   v_st_date  DATE;
    v_end_date  DATE;
    v_date  DATE;
BEGIN

          select to_date('01-JAN-20') + (7*v_wk_no) -1, to_date('01-JAN-20') + (7*v_wk_no) -7
          into v_end_date, v_st_date
           from dual;
           
           if  v_type ='S' THEN
               v_date :=v_st_date;
           ELSE 
               v_date :=v_end_date;
           end if;
         
         RETURN TRUNC(v_date);
END;



 FUNCTION get_wk_start_end_desc(v_wk_no NUMBER) RETURN VARCHAR IS
   
    v_st_date  DATE;
    v_end_date  DATE;
    v_desc  VARCHAR2(200);
BEGIN

          select to_date('01-JAN-20') + (7*v_wk_no) -1, to_date('01-JAN-20') + (7*v_wk_no) -7
          into v_end_date, v_st_date
           from dual;
           
             select  TO_CHAR(v_end_date,'MON') || ' '||TO_CHAR(v_st_date,'DD') || '-'||TO_CHAR(v_end_date,'DD') || ' 2020'
           into v_desc
           from dual;
         
        
  
         
         RETURN v_desc;
END;


 FUNCTION get_policy_scheme(v_pol_no  VARCHAR) RETURN VARCHAR IS
   
    p_name  VARCHAR2(300);
BEGIN

        SELECT CU.V_COMPANY_NAME
        INTO p_name
        FROM GNMT_POLICY POL,GNMM_COMPANY_MASTER CU
        WHERE  POL.V_COMPANY_CODE = CU.V_COMPANY_CODE
        AND POL.V_COMPANY_BRANCH = CU.V_COMPANY_BRANCH
        AND POL.V_POLICY_NO =v_pol_no;
         
         RETURN p_name;
         
   EXCEPTION
   WHEN OTHERS THEN
   RETURN NULL;
         
END;


/* Formatted on 09/05/2020 15:17:31 (QP5 v5.139.911.3011) */
FUNCTION get_policy_status_user (P_Policy_No VARCHAR, v_st VARCHAR)
   RETURN VARCHAR
IS
   v_user   VARCHAR2 (200);


   CURSOR POL
   IS
      SELECT V_LASTUPD_USER, V_UNDERWRITER
        FROM GNMT_POLICY POL
       WHERE POL.V_POLICY_NO = P_Policy_No;
BEGIN
   FOR i IN POL
   LOOP
      IF v_st = 'I'
      THEN
         BEGIN
            SELECT V_LASTUPD_USER
              INTO v_user
              FROM GN_CONTRACT_STATUS_LOG
             WHERE     V_POLICY_NO = P_Policy_No
                   AND V_PREV_STAT_CODE LIKE 'NB099%'
                   AND V_CURR_STAT_CODE = 'NB010'
                   AND V_PLRI_FLAG = 'P'
                   AND  ROWNUM =1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

--         RETURN v_user;
      ELSIF v_st = 'Q'
      THEN
         BEGIN
            SELECT V_LASTUPD_USER
              INTO v_user
              FROM GN_CONTRACT_STATUS_LOG
             WHERE     V_POLICY_NO = P_Policy_No
                   AND V_PREV_STAT_CODE IS NULL
                   AND ((V_CURR_STAT_CODE = 'NB054'))
                   AND V_PLRI_FLAG = 'P';
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

--         RETURN v_user;
         
      ELSIF v_st = 'INIT'
      THEN
         BEGIN
            SELECT DECODE(A.V_LASTUPD_USER,'134',A.V_LASTUPD_PROG,'124',A.V_LASTUPD_PROG,'139',A.V_LASTUPD_PROG,A.V_LASTUPD_USER)
              INTO v_user
              FROM GN_CONTRACT_STATUS_LOG A
             WHERE     A.V_POLICY_NO = P_Policy_No
             AND  A.V_PLRI_FLAG = 'P'
             AND A.N_SEQ IN    (  SELECT MIN( L.N_SEQ)
                                         FROM GN_CONTRACT_STATUS_LOG L
                                         WHERE      L.V_POLICY_NO = P_Policy_No
                                         AND L.V_PLRI_FLAG = 'P');

         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN NULL;
         END;

--         RETURN v_user;
         
      ELSIF v_st = 'UW'
      THEN

         BEGIN
--               RAISE_ERROR('HERER');
            SELECT DISTINCT V_LASTUPD_USER
              INTO v_user
              FROM GN_CONTRACT_STATUS_LOG
             WHERE     V_POLICY_NO = P_Policy_No
                  AND V_PREV_STAT_CODE IN ( 'NB054','NB053')
                AND V_LASTUPD_PROG ='NB_FRM_01'
                 AND V_CURR_STAT_CODE IS NOT NULL
                   AND V_PLRI_FLAG = 'P';
                   
--                   RAISE_ERROR('HERER'||v_user);
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN null;
         END;
         
      ELSE
         RETURN I.V_UNDERWRITER;
      END IF;
   END LOOP;
   
       RETURN v_user;
--EXCEPTION
--   WHEN OTHERS
--   THEN
--      RETURN NULL;
END;


    FUNCTION GET_POL_STATUS
    (P_STATUS_CODE IN GNMM_POLICY_STATUS_MASTER.V_STATUS_CODE%TYPE)
  RETURN VARCHAR2 IS
    V_TEMP VARCHAR2 (200);
    V_MULTI VARCHAR2 (2);
    V_USER VARCHAR2 (200);
    

    BEGIN
    
    SELECT V_STATUS_DESC
    INTO V_TEMP
    FROM GNMM_POLICY_STATUS_MASTER POL_STATUS
    WHERE  POL_STATUS.V_STATUS_CODE = P_STATUS_CODE;
            


        RETURN V_TEMP;

EXCEPTION 
WHEN OTHERS THEN
RETURN NULL;
    END;   

FUNCTION is_policy_annuity (P_Policy_No VARCHAR)
   RETURN VARCHAR
IS
   v_user   VARCHAR2 (200);


   CURSOR POL
   IS
      SELECT V_POLICY_NO
        FROM GNMT_POLICY POL
       WHERE POL.V_POLICY_NO = P_Policy_No
       AND V_PLAN_CODE  IN ('BANY001','BSANN01');
      
  BEGIN
             FOR I IN POL LOOP
             RETURN 'Y';
             END LOOP;
             
             RETURN 'N';
  
  END;
  
  
  
  
  FUNCTION duplicate_pin_count (v_pin_no  VARCHAR)
   RETURN NUMBER
IS
   v_count   NUMBER;
   p_pin_no VARCHAR2(200);
      
  BEGIN
  
            SELECT  A.V_IDEN_NO ,  count(distinct V_NAME )
            into p_pin_no, v_count
            FROM GNMT_CUSTOMER_MASTER  C,  GNMT_POLICY POL,GNDT_CUSTOMER_IDENTIFICATION A
            WHERE  C.N_CUST_REF_NO = POL.N_PAYER_REF_NO 
            AND  C.N_CUST_REF_NO =  A. N_CUST_REF_NO
            AND A.V_IDEN_CODE = 'PIN'
            AND A.V_STATUS ='A'
            and A.V_IDEN_NO= v_pin_no
            GROUP BY  A.V_IDEN_NO 
            ORDER BY 2 DESC;
           
    RETURN  v_count;

  END;


  FUNCTION get_bill_time (p_bill_no  VARCHAR,p_code VARCHAR )
   RETURN NUMBER
IS
   v_count   NUMBER;
--   p_code VARCHAR2(20);
--   p_name VARCHAR2(200);
   v_mem_count   NUMBER;
      
  BEGIN
  
              
           /*   SELECT  LU_CODE, V_SHORT_NAME
              INTO  p_code, p_name
             FROM GNDT_BILL_TRANS BILL,LU_CODES C
             WHERE  BILL.V_BILL_SOURCE = C.LU_CODE
             AND N_BILL_TRN_NO > 1
             AND N_TRN_AMT != 0
            AND BILL.V_POLICY_NO LIKE 'GL%'
             AND NVL (V_CANCEL_STATUS, 'N') = 'N'
            -- AND V_BILL_SOURCE = 'SGNB'
             AND C.V_SHORT_NAME  <>  'Servicing'
             AND V_LASTUPD_USER <>  'JHLISFADMIN'
             AND V_BILL_NO =p_bill_no; */
             
             select  COUNT(DISTINCT N_SEQ_NO)
             INTO v_mem_count
             FROM GNDT_BILL_IND_DETS
             WHERE V_BILL_NO  =p_bill_no; 
             
             --new business
            IF  p_code  in(  'SGNB','SGUB') THEN
            
                    SELECT  CASE 
                                  WHEN v_mem_count between 100 and 999  then 90
                                  WHEN v_mem_count between 1000 and 9999  then 230
                                  WHEN v_mem_count between 10000 and 39999  then 290
                                  WHEN v_mem_count  >=40000   then 390
                                  ELSE  60
                                 END TM_TAKEN
                                                  
                                  into v_count
                    FROM DUAL;
                    
                               
    RETURN  v_count;
            
            END IF;
            
            
            
            
              --renewal
            IF  p_code =  'SGRB' THEN
            
                    SELECT  CASE 
                                  WHEN v_mem_count between 100 and 999  then 90
                                  WHEN v_mem_count between 1000 and 9999  then 220
                                  WHEN v_mem_count between 10000 and 39999  then 290
                                  WHEN v_mem_count  >=40000   then 410
                                  ELSE  60
                                 END TM_TAKEN
                                                  
                                  into v_count
                    FROM DUAL;
                    
                               
    RETURN  v_count;
            
            END IF;
            
            
                          --exits
            IF  p_code =  'SGOB' THEN
            
                    SELECT  CASE 
                                  WHEN v_mem_count between 100 and 999  then 70
                                  WHEN v_mem_count between 1000 and 9999  then 210
                                  WHEN v_mem_count between 10000 and 39999  then 260
                                  WHEN v_mem_count  >=40000   then 360
                                  ELSE  45
                                 END TM_TAKEN
                                                  
                                  into v_count
                    FROM DUAL;
                    
                               
    RETURN  v_count;
            
            END IF;
            
                                --entrants
            IF  p_code in( 'SGEB','SGAB') THEN
            
                    SELECT  CASE 
                                  WHEN v_mem_count between 100 and 999  then 80
                                  WHEN v_mem_count between 1000 and 9999  then 130
                                  WHEN v_mem_count between 10000 and 39999  then 270
                                  WHEN v_mem_count  >=40000   then 370
                                  ELSE  60
                                 END TM_TAKEN
                                                  
                                  into v_count
                    FROM DUAL;
                    
                               
              RETURN  v_count;
            
            END IF;
                 
                               --refunds
            IF  p_code in( 'SGPR') THEN
                                          
              RETURN  30;
            
            END IF;
            
            

           
    RETURN  v_count;

  END;
  
/* Formatted on 28/05/2020 16:56:40 (QP5 v5.139.911.3011) */
FUNCTION get_voucher_status (p_vou_no VARCHAR)
   RETURN VARCHAR
IS
   v_st_desc   VARCHAR2 (500);
BEGIN
   v_st_desc := NULL;

   BEGIN
      SELECT DISTINCT
             'Voucher In OFA Staging table - Follow up the OFA IT Team'
        INTO v_st_desc
        FROM XXJICKE_AP_INVOICES_STG@JICOFPROD.COM
       WHERE OPERATING_UNIT = 'JHL_KE_LIF_OU' 
       AND VOUCHER_NUM = p_vou_no;
   --            EXCEPTION
   --            when others then
   --              v_st_desc :=NULL;
   END;


   IF v_st_desc IS NULL
   THEN
      SELECT 'Voucher Has not Flown to OFA - Consult the ISF IT team'
        INTO v_st_desc
        FROM JHL_OFA_VOUCHER_ERRORS
       WHERE V_VOU_NO = p_vou_no;
   END IF;



   IF v_st_desc IS NULL
   THEN
      SELECT 'Voucher Needs to be pushed to OFA Consult the ISF IT team'
        INTO v_st_desc
        FROM PYMT_VOUCHER_ROOT PM, PYMT_VOU_MASTER PV
       WHERE PM.V_MAIN_VOU_NO = PV.V_MAIN_VOU_NO AND V_VOU_NO = p_vou_no
             AND V_VOU_NO NOT IN
                    (SELECT A.PAYMENT_VOUCHER
                       FROM APPS.
                            XXJIC_AP_CLAIM_MAP@JICOFPROD.COM A
                      WHERE A.LOB_NAME = 'JHL_KE_LIF_OU'
                            AND A.PAYMENT_VOUCHER = p_vou_no
                     UNION ALL
                     SELECT B.VOUCHER_NUM
                       FROM XXJICKE_AP_INVOICES_STG@JICOFPROD.COM B
                      WHERE B.OPERATING_UNIT = 'JHL_KE_LIF_OU'
                            AND B.VOUCHER_NUM = p_vou_no);
   END IF;
   
   RETURN v_st_desc;
END;



FUNCTION Get_Productivity_Avg(P_USERNAME VARCHAR2, P_TRANS_TYPE VARCHAR2, P_GROUPING VARCHAR2)  RETURN OBJ_JHL_GL_PROD_AVG
 is
    V_AVG OBJ_JHL_GL_PROD_AVG;
    BEGIN
    V_AVG:=  OBJ_JHL_GL_PROD_AVG(0, 0, 0, 0 );
      SELECT USER_TRANSACTION_AVERAGE, GROUPING_TRANSACTION_AVERAGE, USER_TIME_AVERAGE, GROUPING_TIME_AVERAGE
      INTO V_AVG.USER_AVG_TRANS,  V_AVG.GROUP_AVG_TRANS, V_AVG.USER_AVG_TIME, V_AVG.GROUP_AVG_TIME  
      FROM JHL_GL_PROD_MATRIX_SUM 
      WHERE CREATED_BY = P_USERNAME
      AND TRANSACTION_TYPE = P_TRANS_TYPE 
      AND GROUPING =P_GROUPING;
      RETURN V_AVG;
      EXCEPTION  WHEN OTHERS THEN RETURN  V_AVG;
    END;
   
 
 FUNCTION get_other_pol_count (v_cust_code  number, v_pol VARCHAR,  v_arrears  VARCHAR Default 'N') RETURN NUMBER
IS
 v_pol_count NUMBER; 
BEGIN


            SELECT count(*)
            into v_pol_count
            FROM Gnmt_Policy B
            where B.N_Payer_Ref_No = v_cust_code
            and B.V_Policy_No <> v_pol;
            
           
 
        IF   v_arrears = 'L' AND  v_pol_count >0 THEN
        
                    SELECT count(*)
                        into v_pol_count
                        FROM Gnmt_Policy B
                        where B.N_Payer_Ref_No = v_cust_code
                        and B.V_Policy_No <> v_pol
                        AND  V_CNTR_STAT_CODE IN ('NB022', 'NB025');
                        
                        return nvl(v_pol_count,0); 
        
        END IF; 
        
                IF   v_arrears = 'A' AND  v_pol_count >0 THEN
        
                    SELECT count(*)
                        into v_pol_count
                        FROM Gnmt_Policy B,
                                 (SELECT  MAX(D_DUE_DATE),V_POLICY_NO
                                FROM Ppmt_Outstanding_Premium
                                WHERE V_POLICY_NO  NOT LIKE 'GL%'
                                GROUP BY V_POLICY_NO
                                HAVING  TRUNC(MAX(D_DUE_DATE)) < TRUNC(SYSDATE)) ARREARS
                        where B.N_Payer_Ref_No = v_cust_code
                        AND B.V_Policy_No  = ARREARS.V_POLICY_NO
                        and B.V_Policy_No <> v_pol;
                        

                        return nvl(v_pol_count,0); 
        
        END IF; 
        
        
   
 return nvl(v_pol_count,0); 
 
 
END;


FUNCTION get_voucher_payment_date (v_vou_no VARCHAR,v_amt NUMBER,v_date date  )
      RETURN date
   IS
      v_pymt_date  DATE;
      v_count number := 0;

   

   
      BEGIN

            Select  MAX(PAYMENT_DATE)
                   into v_pymt_date
    FROM JHL_OFA_CHQ_DETAILS c
    WHERE PAYMENT_VOUCHER = v_vou_no;
        
    RETURN v_pymt_date;
    
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN NULL;
      END;



 PROCEDURE GENERATE_POL_AMOUNTS(v_pol_no VARCHAR) IS


CURSOR C1 IS 
SELECT SUM(N_RATE) RATE,V_PLRI_CODE 
FROM PSDT_PLAN_SURVIVAL_BREAKUP 
WHERE V_POLICY_NO =v_pol_no
AND V_PLRI_CODE NOT IN ('BJUB010',
                                   'BFP001',
                                   'BFP002',
                                   'BJUB012',
                                   'BJUB015',
                                   'BJUB018',
                                   'BMRTA20',
                                   'BMRTA15',
                                   'BMRTA10',
                                   'BMRTA05',
                                   'BMRSPREM',
                                   'BTERM01')
GROUP BY V_PLRI_CODE

UNION

SELECT N_AMT_PAYABLE *100 RATE  ,B.V_PLAN_CODE
FROM GNMM_PLAN_EVENT_LINK A, GNMT_POLICY B 
WHERE A.V_PLAN_CODE= B.V_PLAN_CODE
AND A.V_PLAN_CODE IN ('BJUB010','BFP001','BFP002','BJUB012','BJUB015','BJUB018')
AND A.V_EVENT_CODE = 'GMAT'
AND B.V_POLICY_NO =v_pol_no; 

CURSOR POLICIES IS 
SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
AND Jhl_gen_pkg.Get_maturity_month_bal2 (A.V_policy_no) = 'Y'
   AND V_grp_ind_flag = 'I'
     AND A.N_seq_no = 1
    AND C.V_plan_code NOT IN ('BJUB010',
                                   'BFP001',
                                   'BFP002',
                                   'BJUB012',
                                   'BJUB015',
                                   'BJUB018',
                                   'BMRTA20',
                                   'BMRTA15',
                                   'BMRTA10',
                                   'BMRTA05',
                                   'BMRSPREM',
                                   'BTERM01')
AND C.V_POLICY_NO  = v_pol_no

union 

SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
AND Jhl_Gen_Pkg.Get_Maturity_Month_Bal (A.v_policy_no) = 'Y'
AND Jhl_Gen_Pkg.Get_Num_Os (A.v_policy_no) = 'Y'
AND V_grp_ind_flag = 'I'
AND A.N_seq_no = 1
AND C.N_Term <= 5
AND C.V_Plan_Code IN ( 'BFP001', 'BFP002')
AND C.V_POLICY_NO  = v_pol_no


union 

SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
  AND Jhl_Gen_Pkg.Get_Maturity_Month_Bal (A.v_policy_no) = 'Y'
AND V_grp_ind_flag = 'I'
AND A.N_seq_no = 1
AND C.N_Term >5
AND C.N_Term <=10
AND C.V_Plan_Code IN ( 'BFP001', 'BFP002')
AND C.V_POLICY_NO  = v_pol_no

union 

SELECT  A.N_IND_SA,A.V_cntr_stat_code
FROM    GNMT_POLICY C, Gnmt_policy_detail A
WHERE C.V_POLICY_NO NOT LIKE 'GL%'
AND A.V_policy_no = C.V_policy_no
 AND Jhl_Gen_Pkg.Get_Maturity_Month_Bal3 (A.v_policy_no) = 'Y'
AND V_grp_ind_flag = 'I'
AND A.N_seq_no = 1
AND C.N_Term >5
 AND C.N_Term > 10
AND C.V_Plan_Code IN ( 'BFP001', 'BFP002')
AND C.V_POLICY_NO  = v_pol_no;


 V_RATE NUMBER := 0;
 V_PLAN VARCHAR2 (50);
 V_COMPUTED_SA  NUMBER := 0;
 V_LOAN_BAL NUMBER  := 0; 
 V_LOAN_INT NUMBER  := 0;
 LN_ACTUAL_BONUS NUMBER  := 0;
 LN_INTERIM_BONUS NUMBER := 0;
 V_DUE_APL NUMBER := 0;
 V_DUE_APL_INT NUMBER := 0;
 V_GROSS_CLAIMS NUMBER := 0;
 V_CP_CALC_SA NUMBER := 0;
 V_CP_TOTAL_BONUS  NUMBER := 0;
  V_CP_INTERIM  NUMBER := 0;
  V_CP_NFP_BAL NUMBER := 0;
  V_CP_PREM_DUE  NUMBER := 0;
  V_CP_TOTAL_DEDUCT NUMBER := 0;
  V_CP_GROSS_CLAIM NUMBER := 0;
  V_CP_LOAN_BAL NUMBER := 0;
  V_CP_NET_CLAIM  NUMBER := 0;
  N_VALUE_CSV  NUMBER  :=NULL;


  BEGIN
  
    DELETE FROM JHL_POL_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;
--    commit;
    OPEN C1;
    V_RATE := 0;
        FETCH C1 INTO V_RATE,V_PLAN ;
    CLOSE C1;
  
  FOR I IN POLICIES LOOP
    V_COMPUTED_SA := I.N_IND_SA - (V_RATE/100* I.N_IND_SA);
    
    IF I.V_cntr_stat_code = 'NB014' THEN
         V_CP_CALC_SA := I.N_IND_SA     ;
    ELSE 
         V_CP_CALC_SA := NVL(V_COMPUTED_SA,I.N_IND_SA)     ;
    END IF;    
    
--  DELETE FROM PS_RB_CRB_TEMP;
  -- DELETE FROM PS_PLAN_BONUS_YEAR_TEMP;                                                                             
  
 BPG_POLICY_SERVICING_V2.BPC_GET_ACTUAL_INTERIM_BONUS(v_pol_no,1,NULL,NULL,'Q',TRUNC(SYSDATE)+1,'CL',NULL,1,LN_ACTUAL_BONUS,LN_INTERIM_BONUS,USER,USER,SYSDATE);
 IF V_PLAN IN ('RJSMAXE01','RJSMAXE02','RSMAXE01','RSMAXE02')THEN
  V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS/2;
  V_CP_INTERIM := LN_INTERIM_BONUS/2; 
 ELSIF
  V_PLAN IN ('RWLF001','RWLF002','RJMAXE01','RJMAXE02') THEN
  V_CP_TOTAL_BONUS := 0;
  V_CP_INTERIM := 0; 
 ELSE
     V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS;
  V_CP_INTERIM := LN_INTERIM_BONUS;
     
 END IF;  
    
 BPG_POLICY_SERVICING.BPC_GET_LOAN_DUE_DETAILS(V_POL_NO,1,SYSDATE,V_LOAN_BAL,V_LOAN_INT);
     V_CP_LOAN_BAL := V_LOAN_BAL+V_LOAN_INT;
 
 BPG_POLICY_SERVICING.BPC_GET_APL_DUE_DETAILS (V_POL_NO, 1,TRUNC(SYSDATE), V_DUE_APL, V_DUE_APL_INT);
  V_CP_NFP_BAL := V_DUE_APL+V_DUE_APL_INT;
  V_CP_PREM_DUE := BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE(V_POL_NO); 
  V_CP_TOTAL_DEDUCT :=    V_CP_LOAN_BAL + V_CP_NFP_BAL + V_CP_PREM_DUE + 2.50;
   
  V_CP_GROSS_CLAIM := (V_CP_TOTAL_BONUS + V_CP_INTERIM + V_CP_CALC_SA );
  V_CP_NET_CLAIM := V_CP_GROSS_CLAIM - V_CP_TOTAL_DEDUCT;
  BPG_CSV.BPC_CALC_PAIDUPRT_CSV(V_POL_NO,1,NULL,NULL,SYSDATE,N_VALUE_CSV);
  
  
  
--  V_CP_GROSS_CLAIM :=571461.45;
--  V_CP_TOTAL_BONUS := 123256.95;
--  V_CP_TOTAL_DEDUCT := 2.5;
  
  
   INSERT INTO JHL_POL_AMOUNTS(V_POLICY_NO, POL_ACTUAL_BONUS_AMT, 
   POL_INTERIM_BONUS_AMT, POL_CSV_AMOUNT, POL_LOAN_BAL, POL_LOAN_INT, 
   POL_DUE_APL_AMT, POL_DUE_APL_INT, POL_PREM_DUE, 
   POL_TOTAL_DEDUCT, POL_GROSS_CLAIM, POL_NET_CLAIM,POL_NFP_BAL,POL_TOTAL_BONUS,
   POL_DV_TYPE, POL_DATE,POL_SURR_VALUE)
   VALUES( V_POL_NO,V_CP_TOTAL_BONUS, V_CP_INTERIM, nvl(N_VALUE_CSV,0),
   V_LOAN_BAL, V_LOAN_INT,V_DUE_APL,V_DUE_APL_INT,V_CP_PREM_DUE,
   V_CP_TOTAL_DEDUCT,V_CP_GROSS_CLAIM,V_CP_NET_CLAIM,V_CP_NFP_BAL,V_CP_TOTAL_BONUS,
   'M', SYSDATE,nvl(N_VALUE_CSV,0)
   );

--       commit; 
     
END LOOP;


--raise_error('hihhihihihi');
--    commit; 
    
      DBMS_OUTPUT.PUT_LINE ('v_pol_no :'||v_pol_no); 
  DBMS_APPLICATION_INFO.SET_CLIENT_INFO('v_pol_no '||v_pol_no);
    DBMS_OUTPUT.PUT_LINE ('V_CP_GROSS_CLAIM :'||V_CP_GROSS_CLAIM); 
  DBMS_APPLICATION_INFO.SET_CLIENT_INFO('V_CP_GROSS_CLAIM '||V_CP_GROSS_CLAIM);
     DBMS_APPLICATION_INFO.SET_ACTION ('Amounts Successfully computed'); 
       DBMS_APPLICATION_INFO.SET_CLIENT_INFO('Amounts Successfully computed');

END;
   
 
 function get_amt_to_words(v_amt number)
  return Char is
V_AMT_TO_WD  VARCHAR2(4000) := NULL;
begin
    V_AMT_TO_WD   := NULL;
  SELECT DECODE( ((v_amt-TRUNC(v_amt))*100),0,SPELL_NUMBER(TRUNC(v_amt)),SPELL_NUMBER(TRUNC(v_amt))||' Shillings '||SPELL_NUMBER((v_amt-TRUNC(v_amt))*100 )||' Cents ') 
  INTO V_AMT_TO_WD 
   from dual;
   
  RETURN(V_AMT_TO_WD);
  
  EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
  
end;  


 PROCEDURE GENERATE_POL_AMOUNTS_SUR(v_pol_no VARCHAR) IS

CURSOR POLICIES IS 
SELECT  *
FROM    GNMT_POLICY C
WHERE  C.V_POLICY_NO  = v_pol_no ; 




 V_RATE NUMBER := 0;
 V_PLAN VARCHAR2 (50);
 V_COMPUTED_SA  NUMBER := 0;
 V_LOAN_BAL NUMBER;
 V_LOAN_INT NUMBER;
 LN_ACTUAL_BONUS NUMBER;
 LN_INTERIM_BONUS NUMBER;
 V_DUE_APL NUMBER;
 V_DUE_APL_INT NUMBER;
 V_GROSS_CLAIMS NUMBER;
 V_CP_CALC_SA NUMBER;
 V_CP_TOTAL_BONUS  NUMBER;
  V_CP_INTERIM  NUMBER;
  V_CP_NFP_BAL NUMBER;
  V_CP_PREM_DUE  NUMBER;
  V_CP_TOTAL_DEDUCT NUMBER;
  V_CP_GROSS_CLAIM NUMBER;
  V_CP_LOAN_BAL NUMBER;
  V_CP_NET_CLAIM  NUMBER;
  N_VALUE_CSV  NUMBER  :=NULL;


  BEGIN
  
    DELETE FROM JHL_POL_AMOUNTS WHERE V_POLICY_NO =  v_pol_no;

  
  FOR I IN POLICIES LOOP

 BPG_POLICY_SERVICING.BPC_GET_LOAN_DUE_DETAILS(V_POL_NO,1,SYSDATE,V_LOAN_BAL,V_LOAN_INT);
     V_CP_LOAN_BAL := V_LOAN_BAL+V_LOAN_INT;

-- BPG_POLICY_SERVICING_V2.BPC_GET_ACTUAL_INTERIM_BONUS(v_pol_no,1,NULL,NULL,'Q',TRUNC(SYSDATE)+1,'CL',NULL,1,LN_ACTUAL_BONUS,LN_INTERIM_BONUS,USER,USER,SYSDATE);
  Bpg_policy_servicing_v2.Bpc_Get_Actual_Interim_Bonus(v_pol_no,NULL,null,null,'P',sysdate,'NB010', null, null,LN_ACTUAL_BONUS, LN_INTERIM_BONUS, user, user, sysdate);
  V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS +LN_INTERIM_BONUS;
  V_CP_INTERIM := LN_INTERIM_BONUS;
 
    

 
 BPG_POLICY_SERVICING.BPC_GET_APL_DUE_DETAILS (V_POL_NO, 1,TRUNC(SYSDATE), V_DUE_APL, V_DUE_APL_INT);
  V_CP_NFP_BAL := V_DUE_APL+V_DUE_APL_INT;
  V_CP_PREM_DUE := BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE(V_POL_NO); 
  V_CP_TOTAL_DEDUCT :=    V_CP_LOAN_BAL + V_CP_NFP_BAL + V_CP_PREM_DUE + 2.50;
   
  V_CP_GROSS_CLAIM := (V_CP_TOTAL_BONUS + V_CP_INTERIM + V_CP_CALC_SA );
  V_CP_NET_CLAIM := V_CP_GROSS_CLAIM - V_CP_TOTAL_DEDUCT;
  BPG_CSV.BPC_CALC_PAIDUPRT_CSV(V_POL_NO,1,NULL,NULL,SYSDATE,N_VALUE_CSV);
  
   INSERT INTO JHL_POL_AMOUNTS(V_POLICY_NO, POL_ACTUAL_BONUS_AMT, 
   POL_INTERIM_BONUS_AMT, POL_CSV_AMOUNT, POL_LOAN_BAL, POL_LOAN_INT, 
   POL_DUE_APL_AMT, POL_DUE_APL_INT, POL_PREM_DUE, 
   POL_TOTAL_DEDUCT, POL_GROSS_CLAIM, POL_NET_CLAIM,POL_NFP_BAL,POL_TOTAL_BONUS,
   POL_DV_TYPE, POL_DATE,POL_SURR_VALUE)
   VALUES( V_POL_NO,V_CP_TOTAL_BONUS, V_CP_INTERIM, N_VALUE_CSV,
   V_LOAN_BAL, V_LOAN_INT,V_DUE_APL,V_DUE_APL_INT,V_CP_PREM_DUE,
   V_CP_TOTAL_DEDUCT,V_CP_GROSS_CLAIM,V_CP_NET_CLAIM,V_CP_NFP_BAL,V_CP_TOTAL_BONUS,
   'T', SYSDATE,NVL(N_VALUE_CSV,0)
   );

--       commit; 
     
END LOOP;
--raise_error('hihhihihihi');
    commit; 

END;



 function get_bfn_count (P_policy_no varchar2, p_survival_date date)  return number is
ln_cnt number(10);
begin

    select count(1)  into ln_cnt
    from PSMT_POLICY_SURVIVAL 
    where V_POLICY_NO=P_policy_no
    and D_SURVIVAL_DATE<=p_survival_date
    and V_STATUS = 'A';
    
return ln_cnt;

exception
    when others then
        return 0;
end;


 function get_emp_id (P_policy_no varchar2, v_cust_ref_no varchar2, v_type varchar2 )  return varchar2 is

emp_id varchar2(200);
--iden_no varchar2(200);
begin

    select   MAX(DECODE(v_type,'I',P.V_IDEN_NO,'IDEN', BPG_GEN.BFN_IDEN_DESC (P.V_IDEN_CODE) ,P.V_EMP_ID))
    INTO emp_id
    from  GNMT_POLICY_DETAIL P
    where V_POLICY_NO=P_policy_no
    and N_CUST_REF_NO = v_cust_ref_no
    and V_STATUS = 'A';
    
RETURN emp_id;

--exception
--    when others then
--        return null;
end;


FUNCTION get_policy_amounts (v_pol_no VARCHAR,   v_amt_type VARCHAR)
      RETURN NUMBER
   IS

      
 
CURSOR C1 IS 
SELECT SUM(N_RATE) RATE,V_PLRI_CODE 
FROM PSDT_PLAN_SURVIVAL_BREAKUP 
WHERE V_POLICY_NO =v_pol_no
AND V_PLRI_CODE NOT IN ('BJUB010',
                                   'BFP001',
                                   'BFP002',
                                   'BJUB012',
                                   'BJUB015',
                                   'BJUB018',
                                   'BMRTA20',
                                   'BMRTA15',
                                   'BMRTA10',
                                   'BMRTA05',
                                   'BMRSPREM',
                                   'BTERM01')
GROUP BY V_PLRI_CODE

UNION

SELECT N_AMT_PAYABLE *100 RATE  ,B.V_PLAN_CODE
FROM GNMM_PLAN_EVENT_LINK A, GNMT_POLICY B 
WHERE A.V_PLAN_CODE= B.V_PLAN_CODE
AND A.V_PLAN_CODE IN ('BJUB010','BFP001','BFP002','BJUB012','BJUB015','BJUB018')
AND A.V_EVENT_CODE = 'GMAT'
AND B.V_POLICY_NO =v_pol_no; 

cursor POLICIES IS
SELECT A.N_IND_SA,A.V_cntr_stat_code, C.V_Plan_Code, POL_AMTS.*
FROM JHL_POLICY_AMOUNTS POL_AMTS, GNMT_POLICY C, Gnmt_policy_detail A
WHERE    POL_AMTS.V_policy_no= C.V_policy_no
AND C.V_policy_no= A.V_policy_no 
AND C.V_POLICY_NO NOT LIKE 'GL%'
AND V_grp_ind_flag = 'I'
AND A.N_seq_no = 1
--AND POL_AMTS.V_POLICY_NO=  'IL201200057531'
AND POL_AMTS.V_POLICY_NO= v_pol_no;
   

 V_RATE NUMBER := 0;
 V_PLAN VARCHAR2 (50);
 V_COMPUTED_SA  NUMBER := 0;
 V_LOAN_BAL NUMBER  := 0; 
 V_LOAN_INT NUMBER  := 0;
 LN_ACTUAL_BONUS NUMBER  := 0;
 LN_INTERIM_BONUS NUMBER := 0;
 V_DUE_APL NUMBER := 0;
 V_DUE_APL_INT NUMBER := 0;
 V_GROSS_CLAIMS NUMBER := 0;
 V_CP_CALC_SA NUMBER := 0;
 V_CP_TOTAL_BONUS  NUMBER := 0;
  V_CP_INTERIM  NUMBER := 0;
  V_CP_NFP_BAL NUMBER := 0;
  V_CP_PREM_DUE  NUMBER := 0;
  V_CP_TOTAL_DEDUCT NUMBER := 0;
  V_CP_GROSS_CLAIM NUMBER := 0;
  V_CP_LOAN_BAL NUMBER := 0;
  V_CP_NET_CLAIM  NUMBER := 0;
  N_VALUE_CSV  NUMBER  :=NULL;

   
      BEGIN
      
             OPEN C1;
                  V_RATE := 0;
                FETCH C1 INTO V_RATE,V_PLAN ;
            CLOSE C1;
            
            
      
      
   FOR I IN POLICIES LOOP
   /*ASSIGN AMOUNTS*/
    LN_ACTUAL_BONUS := NVL(I.POL_ACTUAL_BONUS_AMT,0);
    LN_INTERIM_BONUS := NVL(I.POL_INTERIM_BONUS_AMT,0);
    V_DUE_APL := NVL(I.POL_DUE_APL,0);
    V_DUE_APL_INT := NVL(I.POL_DUE_APL_INT,0);
    V_CP_LOAN_BAL := NVL(I.POL_LOAN,0)  + NVL(I.POL_LOAN_INT,0) ;
    
    
    V_COMPUTED_SA := I.N_IND_SA - (V_RATE/100* I.N_IND_SA);
    
    IF I.V_cntr_stat_code = 'NB014' THEN
         V_CP_CALC_SA := I.N_IND_SA     ;
    ELSE 
         V_CP_CALC_SA := NVL(V_COMPUTED_SA,I.N_IND_SA)     ;
    END IF;    
    
 

 IF V_PLAN IN ('RJSMAXE01','RJSMAXE02','RSMAXE01','RSMAXE02')THEN
  V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS/2;
  V_CP_INTERIM := LN_INTERIM_BONUS/2; 
 ELSIF
  V_PLAN IN ('RWLF001','RWLF002','RJMAXE01','RJMAXE02') THEN
  V_CP_TOTAL_BONUS := 0;
  V_CP_INTERIM := 0; 
 ELSE
     V_CP_TOTAL_BONUS := LN_ACTUAL_BONUS;
  V_CP_INTERIM := LN_INTERIM_BONUS;
     
 END IF;  
    


  V_CP_NFP_BAL := V_DUE_APL+V_DUE_APL_INT;
  V_CP_PREM_DUE := BPG_GEN.BFN_RETURN_RECEIPT_OS_DUE(V_POL_NO); 
  V_CP_TOTAL_DEDUCT :=    V_CP_LOAN_BAL + V_CP_NFP_BAL + V_CP_PREM_DUE + 2.50;
   
  V_CP_GROSS_CLAIM := (V_CP_TOTAL_BONUS + V_CP_INTERIM + V_CP_CALC_SA );
  V_CP_NET_CLAIM := V_CP_GROSS_CLAIM - V_CP_TOTAL_DEDUCT;
  
--   RAISE_ERROR(
-- 'V_DUE_APL ==' || V_DUE_APL ||
-- 'V_DUE_APL_INT ==' || V_DUE_APL_INT ||
-- 'V_CP_PREM_DUE ==' || V_CP_PREM_DUE ||
-- 'V_CP_NFP_BAL ==' || V_CP_NFP_BAL ||
-- 'V_CP_LOAN_BAL ==' || V_CP_LOAN_BAL ||
-- 'V_CP_TOTAL_DEDUCT ==' || V_CP_TOTAL_DEDUCT ||
-- 'V_CP_CALC_SA ==' || V_CP_CALC_SA ||
--  'V_CP_INTERIM ==' || V_CP_INTERIM ||
--   'V_CP_TOTAL_BONUS ==' || V_CP_TOTAL_BONUS ||
--    'V_CP_GROSS_CLAIM ==' || V_CP_GROSS_CLAIM ||
--     'V_CP_NET_CLAIM ==' || V_CP_NET_CLAIM 
-- );

     
END LOOP;
--     RAISE_ERROR(
-- 'v_amt_type ==' || v_amt_type
--);

IF v_amt_type = 'PREM' THEN
    RETURN V_CP_PREM_DUE; 
END IF;

IF v_amt_type = 'DEDUCT' THEN
    RETURN V_CP_TOTAL_DEDUCT; 
END IF;

IF v_amt_type = 'GROSS' THEN
    RETURN V_CP_GROSS_CLAIM; 
END IF;

IF v_amt_type = 'NET' THEN
    RETURN V_CP_NET_CLAIM; 
END IF;

--IF v_amt_type = 'NET' THEN
    RETURN V_CP_NET_CLAIM; 
--END IF;
         
    
--      EXCEPTION
--         WHEN OTHERS
--         THEN
--            RETURN 0;
      END;


function  get_ri_arrangement_amt ( p_amt_type VARCHAR , p_ri_policy_no VARCHAR, 
                                                  p_treaty_code VARCHAR , p_reinsurer_code VARCHAR   ) return Number  is
v_ri_amount  NUMBER ;
begin

   IF P_AMT_TYPE ='SHARE_PER' THEN
        SELECT  MAX(N_SHARE_PERCENT)
        INTO v_ri_amount
         FROM RIMT_POLICY_ARRANGEMENTS ARR
        WHERE   ARR.V_RI_POLICY_NO  = p_ri_policy_no
        AND ARR.V_TREATY_CODE = p_treaty_code
        AND ARR.V_REINSURER_CODE =p_reinsurer_code;
   END IF; 
   
   
     IF P_AMT_TYPE ='SHARE_AMT' THEN
        SELECT  MAX(N_SHARE_AMT)
        INTO v_ri_amount
         FROM RIMT_POLICY_ARRANGEMENTS ARR
        WHERE   ARR.V_RI_POLICY_NO  = p_ri_policy_no
        AND ARR.V_TREATY_CODE = p_treaty_code
        AND ARR.V_REINSURER_CODE =p_reinsurer_code;
   END IF; 
   
   
     IF P_AMT_TYPE ='CEDED_AMT' THEN
        SELECT  sum(N_SA_CEDED)
        INTO v_ri_amount
         FROM RIMT_POLICY_ARRANGEMENTS ARR
        WHERE   ARR.V_RI_POLICY_NO  = p_ri_policy_no
        AND ARR.V_REINSURER_CODE =p_reinsurer_code;
   END IF; 

  RETURN NVL(v_ri_amount,0);
end;


FUNCTION is_voucher_annuity (p_vou_no VARCHAR)
   RETURN VARCHAR
IS
   v_user   VARCHAR2 (200);


   CURSOR VOU
   IS
      SELECT  B.V_VOU_NO,V_POLICY_NO
    FROM PYMT_VOUCHER_ROOT A,PYMT_VOU_MASTER B,PYDT_VOUCHER_POLICY_CLIENT E
    WHERE  A.V_MAIN_VOU_NO = B.V_MAIN_VOU_NO
    AND A.V_MAIN_VOU_NO = E.V_MAIN_VOU_NO
    AND JHL_BI_UTILS.is_policy_annuity(V_POLICY_NO) = 'Y'
    and B.V_VOU_NO = p_vou_no;
      
  BEGIN
             FOR I IN VOU LOOP
             RETURN 'Y';
             END LOOP;
             
             RETURN 'N';
  
  END;
  
  
    FUNCTION get_ind_customer_pin (v_cust_ref_no  number) RETURN VARCHAR
IS
   p_pin_no VARCHAR2(200);
      
  BEGIN
  
           SELECT  max(V_IDEN_NO)
           INTO p_pin_no
          FROM GNDT_CUSTOMER_IDENTIFICATION
         WHERE    V_IDEN_CODE = 'PIN'
         and V_STATUS = 'A'
         AND N_CUST_REF_NO =  v_cust_ref_no;
           
    RETURN  p_pin_no;
    
    EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;

  END;



   FUNCTION get_co_customer_pin (v_companycode  VARCHAR, v_companybranch VARCHAR) RETURN VARCHAR
IS
   p_pin_no VARCHAR2(200);
      
  BEGIN
          SELECT V_REGN_NO
          INTO p_pin_no
           FROM Gnmm_Company_Master C
            WHERE   C.V_COMPANY_CODE =    v_companycode
            and C.V_COMPANY_BRANCH = v_companybranch;
                       
    RETURN  p_pin_no;
    
    EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;

  END;
  
  
  FUNCTION CHECK_VALID_PIN (V_PIN_NO VARCHAR) RETURN VARCHAR2
   IS
      V_RET_VALUE       VARCHAR2 (1) := 'N';
      V_VALIDITY_VALUE   VARCHAR2 (1) := 'N';

      V_CO_NAME         VARCHAR2 (500);
   BEGIN
      IF NVL (LENGTH (V_PIN_NO), 0) <> 11
      THEN
         V_VALIDITY_VALUE := 'N';
      elsif TRIM (SUBSTR (V_PIN_NO, 1, 1)) NOT IN  ('A','P') THEN
      V_VALIDITY_VALUE := 'N';
      ELSE
         IF (LENGTH (
                TRIM (
                   TRANSLATE (
                      TRIM (SUBSTR (V_PIN_NO, 1, 1)),
                      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                      ' ')))
                IS NOT NULL
             OR LENGTH (
                   TRIM (
                      TRANSLATE (
                         TRIM (SUBSTR (V_PIN_NO, 11, 11)),
                         'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                         ' ')))
                   IS NOT NULL)
         THEN
            V_VALIDITY_VALUE := 'N';
         ELSE
            V_VALIDITY_VALUE := 'Y';
         END IF;
         
          IF   nvl( LENGTH(TRIM(TRANSLATE(V_PIN_NO, ' +-.0123456789',' '))),0) = 2 THEN
              V_VALIDITY_VALUE := 'Y';
          ELSE
           V_VALIDITY_VALUE := 'N';
         END IF; 
         
      END IF;

      --    RAISE_ERROR('V_PIN_NO=='||V_PIN_NO||' V_VALIDITY_VALUE=='||V_VALIDITY_VALUE||'LEN='||NVL(LENGTH(V_PIN_NO),0));

     


      IF (V_VALIDITY_VALUE = 'N')
      THEN
         V_RET_VALUE := 'N';
      ELSE
         V_RET_VALUE := 'Y';
      END IF;

      --RAISE_ERROR('v_payer_value=='||v_payer_value||'V_VALIDITY_VALUE=='||V_VALIDITY_VALUE||'v_ret_value=='||v_ret_value);

      RETURN V_RET_VALUE;
   END;
   
   
   
FUNCTION get_identifier_count (v_cust_ref_no  number,v_code VARCHAR2) RETURN NUMBER
IS
   v_count NUMBER;
      
  BEGIN
  
           SELECT  count(*)
           INTO v_count
          FROM GNDT_CUSTOMER_IDENTIFICATION
         WHERE    V_IDEN_CODE = v_code
         and V_STATUS = 'A'
         AND N_CUST_REF_NO =  v_cust_ref_no;
           
    RETURN  v_count;
    
    EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;

  END;



END JHL_BI_UTILS;

/