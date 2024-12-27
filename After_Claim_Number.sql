SELECT 	gqb.N_BACKUP_REF_NO V_QUOTATION_ID,
       	gqb.V_POLICY_NO V_POLICY_NO,
       	gqb.N_SEQ_NO,
		gqb.N_CUST_REF_NO,
		gqb.V_CURRENCY_CODE,
		gqb.V_SC_PATTERN_CODE,
		gqb.D_DOB,
		gqb.d_issue_date,
		gqb.N_AGE_at_entry,
		gqb.V_PLRI_CODE,
		gqb.V_PARENT_PLRI_CODE,
		gqb.D_CNTR_START_DATE,
		gqb.D_CNTR_END_DATE,
		gqb.V_CNTR_STAT_CODE,
		gqb.D_RIDER_START,
		gqb.D_RIDER_END,
		gqb.V_RIDER_STAT_CODE,
		gqb.D_PLRI_START_DATE,
		gqb.D_PLRI_END_DATE,
		gqb.N_SA_AMOUNT,
		gqb.V_PLRI_FLAG,
		nvl(gqb.V_PNPAR_FLAG,'N'),
		gqb.V_BASESUB_FLAG,
		gqb.V_WOP_STATUS,
		gqb.v_jointlife,
		gqbd.V_EVENT_CODE,
		gqbd.V_PARENT_EVENT_CODE,
		gqbd.N_AMT_PAYABLE,
		gqbd.N_MAX_DAYS,
		gqbd.V_PYMT_FREQ,
		gqbd.V_FRE_FLAG,
		gqbd.v_pay_criteria,
		gqbd.n_plri_sa,
		gpel.n_max_age,
		gpel.V_SUBEVENTS_FLAG,
		gpel.V_INSTS_FLAG,
		gpel.V_BENEFICIARY_FLAG,
		gpel.V_ETI_FLAG,
		gpel.V_RPU_FLAG,
		gpel.V_CLAIM_TYPE,
		cte.d_event_date,
		cte.v_root_cause,
		cte.V_EXCLUSION_CODE,
		cte.d_intimation_date
FROM 	GNMM_QUOT_BACKUP gqb,
		GNMT_QUOT_BACKUP_DTL gqbd,
		GNMM_PLAN_EVENT_LINK gpel,
		CLDT_TEMP_EVENT cte
WHERE 	gqbd.n_backup_ref_no 		= gqb.n_backup_ref_no
AND 	gpel.v_plan_code 			= gqb.v_plri_code
AND 	gpel.v_event_code 			= gqbd.v_event_code
AND 	gpel.v_parent_event_code 	= gqbd.v_parent_event_code
AND 	gpel.v_register_claim='Y'
AND 	gqbd.v_event_code 			= cte.v_event_code
AND 	trunc(cte.d_event_date) BETWEEN trunc(gqb.d_plri_start_date) AND trunc(gqb.d_plri_end_date )
AND 	n_max_slno = (SELECT MAX(n_max_slno)
			   	  		FROM GNMM_QUOT_BACKUP gqbs
				  		where 	trunc(cte.d_event_date)  BETWEEN trunc(gqbs.d_plri_start_date) AND trunc(gqbs.d_plri_end_date)
				  		AND 	gqbs.v_policy_no 	= gqb.v_policy_no
				  		and 	gqbs.n_seq_no 		= gqb.n_seq_no
				  		and 	gqbs.v_plri_code	=	gqb.v_plri_code
				  		and 	gqbs.n_cust_ref_no 	= gqb.n_cust_ref_no )
                        AND GQB.V_POLICY_NO= 'GL202503385232'
/
SELECT 	gqb.N_BACKUP_REF_NO V_QUOTATION_ID,
       	gqb.V_POLICY_NO V_POLICY_NO,
       	gqb.N_SEQ_NO,
		gqb.N_CUST_REF_NO,
		gqb.V_CURRENCY_CODE,
		gqb.V_SC_PATTERN_CODE,
		gqb.D_DOB,
		gqb.d_issue_date,
		gqb.N_AGE_at_entry,
		gqb.V_PLRI_CODE,
		gqb.V_PARENT_PLRI_CODE,
		gqb.D_CNTR_START_DATE,
		gqb.D_CNTR_END_DATE,
		gqb.V_CNTR_STAT_CODE,
		gqb.D_RIDER_START,
		gqb.D_RIDER_END,
		gqb.V_RIDER_STAT_CODE,
		gqb.D_PLRI_START_DATE,
		gqb.D_PLRI_END_DATE,
		gqb.N_SA_AMOUNT,
		gqb.V_PLRI_FLAG,
		nvl(gqb.V_PNPAR_FLAG,'N'),
		gqb.V_BASESUB_FLAG,
		gqb.V_WOP_STATUS,
		gqb.v_jointlife,
		gqbd.V_EVENT_CODE,
		gqbd.V_PARENT_EVENT_CODE,
		gqbd.N_AMT_PAYABLE,
		gqbd.N_MAX_DAYS,
		gqbd.V_PYMT_FREQ,
		gqbd.V_FRE_FLAG,
		gqbd.v_pay_criteria,
		gqbd.n_plri_sa,
		gpel.n_max_age,
		gpel.V_SUBEVENTS_FLAG,
		gpel.V_INSTS_FLAG,
		gpel.V_BENEFICIARY_FLAG,
		gpel.V_ETI_FLAG,
		gpel.V_RPU_FLAG,
		gpel.V_CLAIM_TYPE,
		cte.d_event_date,
		cte.v_root_cause,
		cte.V_EXCLUSION_CODE,
		cte.d_intimation_date
FROM 	GNMM_QUOT_BACKUP gqb,
		GNMT_QUOT_BACKUP_DTL gqbd,
		GNMM_PLAN_EVENT_LINK gpel,
		CLDT_TEMP_EVENT cte
WHERE 	gqbd.n_backup_ref_no 		= gqb.n_backup_ref_no
AND 	gpel.v_plan_code 			= gqb.v_plri_code
AND 	gpel.v_event_code 			= gqbd.v_event_code
AND 	gpel.v_parent_event_code 	= gqbd.v_parent_event_code
AND 	gpel.v_register_claim='Y'
AND 	gqbd.v_event_code 			= cte.v_event_code
AND 	trunc(cte.d_event_date) BETWEEN trunc(gqb.d_plri_start_date) AND trunc(gqb.d_plri_end_date )
AND 	n_max_slno = (SELECT MAX(n_max_slno)
			   	  		FROM GNMM_QUOT_BACKUP gqbs
				  		where 	trunc(cte.d_event_date)  BETWEEN trunc(gqbs.d_plri_start_date) AND trunc(gqbs.d_plri_end_date)
				  		AND 	gqbs.v_policy_no 	= gqb.v_policy_no
				  		and 	gqbs.n_seq_no 		= gqb.n_seq_no
				  		and 	gqbs.v_plri_code	=	gqb.v_plri_code
				  		and 	gqbs.n_cust_ref_no 	= gqb.n_cust_ref_no )
                        AND     GQB.V_POLICY_NO= 'UI201900481042';
                        /
INSERT INTO CLDT_TEMP_EVENT(V_EVENT_CODE,D_EVENT_DATE) VALUES
('GMAT',TO_DATE('04/10/2024','DD/MM/YYYY'));
/

DECLARE
LV_CLAIM VARCHAR2(30);
BEGIN
INSERT INTO CLDT_TEMP_EVENT(V_EVENT_CODE,D_EVENT_DATE)VALUES
('GMAT',TO_DATE('04/10/2024','DD/MM/YYYY'));
BPG_CLAIMS.BPC_POPULATE_CLAIM_POLICY(334242,NULL,USER,USER,LV_CLAIM); --o/p V_CLAIMNO_LINK
DBMS_OUTPUT.PUT_LINE('LV_CLAIM -'||LV_CLAIM);
END;
/
SET SERVEROUTPUT ON;
/
SELECT * FROM CLDT_CLAIM_INPUT WHERE V_CLAIMNO_LINK='26168';
/
SELECT * FROM GNMM_QUOT_BACKUP WHERE V_POLICY_NO='UI201900481042';
/
EXEC BPC_LAPSE_REVERSAL('UI201900481042');
/
SELECT V_CNTR_STAT_CODE,V_CNTR_PREM_STAT_CODE FROM GNMT_POLICY WHERE V_POLICY_NO='UI201900481042';
/
SELECT * FROM CLDT_INPUT_PAYABLES WHERE N_INPUT_REF_NO IN 
(SELECT N_INPUT_REF_NO FROM CLDT_cLAIM_INPUT WHERE V_CLAIM_NO='MA202413761');

SELECT * FROM CLDT_CLAIM_MESSAGE_LOG WHERE N_INPUT_REF_NO='32148';
/
SELECT * FROM GNMM_ERROR_MASTER WHERE V_ERR_CODE='GCL2228';
/
UPDATE GNMM_QUOT_BACKUP SET V_CNTR_STAT_CODE='NB010' WHERE V_POLICY_NO='UI201900481042';
/
EXEC BPG_MATURITY.BPC_GENERATE_MATURITY(USER,USER,TO_DATE('04/10/2024','DD/MM/YYYY'),TO_DATE('04/10/2024','DD/MM/YYYY'));
/
SELECT * FROM CLDT_CLAIM_EVENT_POLICY_LINK WHERE V_POLICY_NO='UI201900481042';--MA202413761
