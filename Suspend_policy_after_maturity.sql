declare
Procedure fpc_update_status_expiry  (p_run_date					date
										,p_user					    varchar2
										,p_prog                     varchar2
										,p_date                     date) is
          
 
 lv_curr_status   varchar2(30);
 lv_status_value  varchar2(30) := 'NB052';
 lv_grp_ind		  varchar2(2);
 lv_plri_flag	  varchar2(3);
 lv_prod_invstype varchar2(2);
 lv_redem_no	  number;
 lv_single_iia	  varchar2(1);
 lv_ref_no		  number;
 ln_cnt_status    number;

 Cursor cr_gmat(p_plancode varchar2) is
   Select count(1) from gnmm_plan_event_link
    where v_plan_code = p_plancode and
          v_event_code = 'GMAT';
 ln_cnt number := 1; --added 07-01-2008 by Roziati for NLC6211
 ln_gmat_policy number;
 ln_gmat_poldet number;
 ln_gmat_polrid number;
-- lv_grp_ind    	varchar2(2);
 lv_payee		varchar2(1);

  cursor cr_cnt_status(p_claim_no cldt_claim_decision_history.v_claim_no%type,
  					   p_sub_claim_no cldt_claim_decision_history.n_sub_claim_no%type)is
  							select count(*)
 cnt
  							from cldt_claim_event_status_link
  							where v_claim_no=p_claim_no
  							and   n_sub_claim_no=p_sub_claim_no
  							and  v_status_code IN ('CLST01','CLST02');

  CURSOR cur_ri_flag (p_status VARCHAR2,p_plan_code varchar2)
      IS
         SELECT v_ri_applicable
           FROM GNMM_PLAN_EVENT_LINK
          WHERE v_plan_code 		= p_plan_code
            AND v_status 			= p_status;

  lv_ri_appli       VARCHAR2 (10);
  lv_scope          VARCHAR2 (10);
  ln_seq_no         NUMBER;
  lb_update				boolean := False;--NLC6067
  lv_cancer_product varchar2(1);--NLC6082
  lv_ext_cov varchar2(1);--NLC6082
  ln_prev_claim number;
  ln_Eti_flag number:=0;---NLC7078
 Begin

--  Terminating the policy status

  for cr_policy in (select v_policy_no,v_cntr_stat_code,n_sum_covered,
  								d_commencement,d_policy_end_date,a.v_plan_code
  						from 	gnmt_policy a, gnmm_plan_master b
  						where	a.v_plan_code = b.v_plan_code 
  						and a.v_policy_no='UI201900434584'
  						and   	b.v_prod_line not in ('LOB003')-- 'LOB004') --added on 07-01-2008 by Roziati for NLC6211
  						and   	v_cntr_stat_code IN ('NB010','NB014','NB016','NB219')   --'NB219' added by saravanan for NLC10001437
  						  and   to_date(to_CHAR(d_policy_end_date,'dd/mm/yyyy'),'dd/mm/yyyy')<
  								to_date(to_CHAR(p_run_date,'dd/mm/yyyy'),'dd/mm/yyyy') )
  loop

	begin
	Savepoint loop_start;

        open  cr_gmat(cr_policy.v_plan_code);
        fetch cr_gmat into ln_gmat_policy;
        close cr_gmat;

        ln_eti_flag:=bpg_claims_reuse.bfn_eti_exist(cr_policy.v_policy_no);--NLC7078
        if ln_gmat_policy >0 and ln_Eti_flag =0 then
          ln_gmat_policy:=0;
          end if;
        lb_update := bpg_claims_reuse.bfn_validate_maturity(cr_policy.v_policy_no,null,cr_policy.v_plan_code,ln_gmat_policy); --NLC6067
        dbms_application_info.set_action(ln_cnt || ' pol ' || cr_policy.v_policy_no);
		dbms_application_info.set_client_info(' policy ');
		ln_cnt := ln_cnt + 1; 						--added on 07-01-2008 by Roziati for NLC6211
		if lb_update = True then --NLC6067
		ln_prev_claim:=0;  --Start NLC6082
        lv_cancer_product:=bpg_claim_processing.bfn_get_cancer_product(cr_policy.v_plan_code);
        lv_ext_cov:=bpg_claim_processing.bfn_get_ext_term(cr_policy.v_policy_no,1,cr_policy.v_plan_code,cr_policy.v_plan_code);
        ln_prev_claim:=bpg_claim_processing.bfn_get_prev_cancer_amt(cr_policy.v_policy_no,1,cr_policy.v_plan_code,cr_policy.v_plan_code,null,'P');
        if nvl(lv_cancer_product,'N')='Y' and nvl(lv_ext_cov,'N')='N' and nvl(ln_prev_claim,0)>0 then
           if nvl(ln_gmat_policy,0)>=0 then
	           bpg_claims_reuse.bpc_cancer_extend_coverage(cr_policy.v_policy_no,
			                                               null,
			                                               cr_policy.v_plan_code,
			                                               cr_policy.v_plan_code,
			                                               cr_policy.n_sum_covered,
			                                               cr_policy.d_policy_end_date,
			                                               'P',
						                                   'P',
					     								   p_user,
					     								   p_prog,
					     								   p_date);
          end if;
        elsif nvl(lv_cancer_product,'N')='N' or nvl(lv_ext_cov,'N')='Y' or nvl(ln_prev_claim,0)<=0 then   --end
	       -- If ln_gmat_policy <=0 then
	           DBMS_OUTPUT.PUT_LINE('Policy PLAN CODE ='||cr_policy.v_plan_code);
	           DBMS_OUTPUT.PUT_LINE('ln_gmat_policy ='||ln_gmat_policy);
		       update 	gnmt_policy
		         set   	v_cntr_stat_code 		= lv_status_value,
			            v_cntr_prem_stat_code 	= lv_status_value
		       where 	v_policy_no  	   	    = cr_policy.v_policy_no;

		        bpg_gen.bpc_insert_contract_status_log(cr_policy.v_policy_no	,
		     								0,
		     								cr_policy.v_plan_code 		,
		     								cr_policy.v_plan_code 	,
		     								lv_plri_flag 		,
		     								lv_status_value   	,
		     								p_user 				,
		     								p_prog 				,
		     								p_date 				);
	       -- End if;
	      end if;
      end if;
	   EXCEPTION WHEN OTHERS THEN
			DECLARE
			 XX VARCHAR2(4000) ;
			BEGIN
			    XX := SQLERRM;
			    ROLLBACK TO LOOP_START;
				INSERT INTO PSMT_LAPSE_EXCEPTION
				(V_POLICY_NO,N_SEQ_NO,D_PREM_UPTO,D_LAPSED,D_EXCEPTION,V_EXCEPTION_STATUS,
				V_STATUS,V_LASTUPD_USER,V_LASTUPD_PROG,V_LASTUPD_INFTIM,V_ERR_MSG)
				VALUES
				(cr_policy.v_policy_no,1,SYSDATE,SYSDATE + 1,SYSDATE,'U',
					'A',USER,P_PROG,P_DATE,XX);
			END;
	   END;
    end loop;

    --  Updating the policy Deatil status
  ln_cnt := 1; --added on 07-01-2008 by Roziati for NLC6211
  for cr_policy_detail in (select gpd.v_policy_no,gpd.n_seq_no,gpd.v_cntr_stat_code,
  								gpd.d_cntr_start_date,gpd.d_cntr_end_date,
  								gp.v_plan_code v_plan_code,gpd.n_ind_sa
  						from 	gnmt_policy_detail gpd,
  								gnmt_policy gp,gnmm_plan_master pm
  						where	gpd.v_plan_code = pm.v_plan_code    
  						and gp.v_policy_no='UI201900434584'
  						and   	pm.v_prod_line not in ('LOB003')-- 'LOB004')   --added on 07-01-2008 by Roziati for NLC6211
  						and 	gp.v_policy_no = gpd.v_policy_no
  						AND		gpd.v_cntr_stat_code IN ('NB010','NB014','NB016','NB219')--'NB219' added by saravanan for NLC10001437
  						and		to_date(to_CHAR(gpd.d_cntr_end_date,'dd/mm/yyyy'),'dd/mm/yyyy')<
  								to_date(to_CHAR(p_run_date,'dd/mm/yyyy'),'dd/mm/yyyy') )
	loop

       dbms_application_info.set_action(ln_cnt || ' pol ' || cr_policy_detail.v_policy_no);
	   dbms_application_info.set_client_info(' policy det ');
	   ln_cnt := ln_cnt + 1;

       Bpg_Gen.bpc_life_or_group_policy (cr_policy_detail.v_policy_no, lv_grp_ind);
       Bpg_claims.bpc_chk_applicability(cr_policy_detail.v_policy_no,cr_policy_detail.n_seq_no,lv_payee);


		begin
		savepoint loop_start;

        open  cr_gmat(cr_policy_detail.v_plan_code);
        fetch cr_gmat into ln_gmat_poldet;
        close cr_gmat;
        ln_eti_flag:=bpg_claims_reuse.bfn_eti_exist(cr_policy_detail.v_policy_no);--NLC7078
        if ln_gmat_poldet >0 and ln_Eti_flag =0 then
          ln_gmat_poldet:=0;
          end if;
        lb_update := bpg_claims_reuse.bfn_validate_maturity(cr_policy_detail.v_policy_no,cr_policy_detail.n_seq_no,
                                                            cr_policy_detail.v_plan_code,ln_gmat_poldet);--NLC6067
        if lb_update = True then
           ln_prev_claim:=0;    --Start NLC6082
           lv_cancer_product:=bpg_claim_processing.bfn_get_cancer_product(cr_policy_detail.v_plan_code);
           lv_ext_cov:=bpg_claim_processing.bfn_get_ext_term(cr_policy_detail.v_policy_no,cr_policy_detail.n_seq_no,
                                                             cr_policy_detail.v_plan_code,cr_policy_detail.v_plan_code);
           ln_prev_claim:=bpg_claim_processing.bfn_get_prev_cancer_amt(cr_policy_detail.v_policy_no,cr_policy_detail.n_seq_no,
                                                                       cr_policy_detail.v_plan_code,cr_policy_detail.v_plan_code,null,'P');
           if nvl(lv_cancer_product,'N')='Y' and nvl(lv_ext_cov,'N')='N' and nvl(ln_prev_claim,0)>0 then
               if nvl(ln_gmat_policy,0)>=0 then
		           bpg_claims_reuse.bpc_cancer_extend_coverage(cr_policy_detail.v_policy_no,
				                                               cr_policy_detail.n_seq_no,
				                                               cr_policy_detail.v_plan_code,
				                                               cr_policy_detail.v_plan_code,
				                                               cr_policy_detail.n_ind_sa,
				                                               cr_policy_detail.d_cntr_end_date,
				                                               'P',
				                                               'PD',
						     								   p_user,
						     								   p_prog,
						     								   p_date);
               end if;
          elsif nvl(lv_cancer_product,'N')='N' or nvl(lv_ext_cov,'N')='Y' or nvl(ln_prev_claim,0)<=0 then	--end
	         --If ln_gmat_poldet <=0 then
	           DBMS_OUTPUT.PUT_LINE('PLAN CODE ='||cr_policy_detail.v_plan_code);
	           DBMS_OUTPUT.PUT_LINE('ln_gmat_poldet ='||ln_gmat_poldet);
	           update   gnmt_policy_detail
	     	   set   	v_cntr_stat_code 	  = lv_status_VALUE,
						v_cntr_prem_stat_code = lv_status_value
	     	   where 	v_policy_no	 		  = cr_policy_detail.v_policy_no
	     	   and	  	n_seq_no		 	  = cr_policy_detail.n_seq_no;

              update gndt_charge_pol_load_dis_dets
		         set v_status               = 'I'
		       where v_policy_no 	        = 	cr_policy_detail.v_policy_no
		         and n_seq_no  			    = 	cr_policy_detail.n_seq_no
		         and v_plri_code 			=	cr_policy_detail.v_plan_code
		         and v_parent_plri_code 	= 	cr_policy_detail.v_plan_code;

 			  update gnmt_charge_policy_link_master
				 set  v_status          = 'I'
		      where v_policy_no 		= 	cr_policy_detail.v_policy_no
		        and n_seq_no  			= 	cr_policy_detail.n_seq_no
		        and v_plri_code 		=	cr_policy_detail.v_plan_code
		        and v_parent_plri_code 	= 	cr_policy_detail.v_plan_code;


			 update gnmt_policy_event_link
			    set  v_status               =   'I'
			  where  v_policy_no 			= 	cr_policy_detail.v_policy_no
			    and   n_seq_no  			= 	cr_policy_detail.n_seq_no
			    and   v_plri_code 			=	cr_policy_detail.v_plan_code
			    and   v_parent_plri_code 	= 	cr_policy_detail.v_plan_code;


             IF lv_grp_ind = 'I'           THEN
                lv_scope := 'IP';
                ln_seq_no := NULL;
             ELSIF lv_grp_ind = 'G'        THEN
                ln_seq_no := cr_policy_detail.n_seq_no;
                lv_scope := 'GP';
             END IF;

             Bpg_Ri_Intimation.BPC_intimate_ri(lv_scope,cr_policy_detail.v_policy_no,ln_seq_no,lv_payee);



           bpg_policy.bpc_insert_claim_quot_backup(cr_policy_detail.v_policy_no,
													ln_seq_no,
													cr_policy_detail.d_cntr_end_date,
													p_user,
													p_prog,
													p_date,
													'Y'--p_quot_flag
													);


          bpg_gen.bpc_insert_contract_status_log(cr_policy_detail.v_policy_no	,
												cr_policy_detail.n_seq_no,
												cr_policy_detail.v_plan_code 	,
												cr_policy_detail.v_plan_code 	,
												'P' 		,
												lv_status_value   	,
												p_user 				,
												p_prog 				,
												p_date 				);
         --end if;
	   end if;
	   end if;
	   EXCEPTION WHEN OTHERS THEN
			DECLARE
			 XX VARCHAR2(4000) ;
			BEGIN
			    XX := SQLERRM;
			    ROLLBACK TO LOOP_START;
				INSERT INTO PSMT_LAPSE_EXCEPTION
				(V_POLICY_NO,N_SEQ_NO,D_PREM_UPTO,D_LAPSED,D_EXCEPTION,V_EXCEPTION_STATUS,
				V_STATUS,V_LASTUPD_USER,V_LASTUPD_PROG,V_LASTUPD_INFTIM,V_ERR_MSG)
				VALUES
				(cr_policy_detail.v_policy_no,1,SYSDATE,SYSDATE + 1,SYSDATE,'U',
					'A',USER,P_PROG,P_DATE,XX);
			END;
	   END;

    end loop;

--Terminating policy riders
    ln_cnt := 1;
    for cr_policy_riders in (select gpr.v_policy_no,gpr.n_seq_no,v_rider_status,
  								d_rider_start,d_rider_end,gpr.v_plan_code,
  								v_parent_plri_code,v_plri_flag,gpr.n_rider_sa
  						from 	gnmt_policy_riders gpr,
  								gnmt_policy_detail gpd,gnmm_plan_master pm
  						where	gpr.v_plan_code = pm.v_plan_code
  						and   	pm.v_prod_line not in ('LOB003')-- 'LOB004')     --added on 07-01-08 by Roziati for NLC6211
  						and		gpr.v_rider_stat_code IN ('NB010','NB014','NB016','NB219')  --'NB219' added by saravanan for NLC10001437
  						and		gpr.v_policy_no = gpd.v_policy_no    
  						and gpr.v_policy_no='UI201900434584'
  						and		gpr.n_seq_no    = gpd.n_seq_no
  						and		to_date(to_CHAR(d_rider_end,'dd/mm/yyyy'),'dd/mm/yyyy')<= --added "<=" for  NC100000907
  								to_date(to_CHAR(p_run_date,'dd/mm/yyyy'),'dd/mm/yyyy') )
	loop

        dbms_application_info.set_action(ln_cnt || ' pol ' || cr_policy_riders.v_policy_no);
		dbms_application_info.set_client_info(' policy rid ');
		ln_cnt := ln_cnt + 1;

		begin
		savepoint loop_start;
        open  cr_gmat(cr_policy_riders.v_plan_code);
        fetch cr_gmat into ln_gmat_polrid;
        close cr_gmat;
        ln_eti_flag:=bpg_claims_reuse.bfn_eti_exist(cr_policy_riders.v_policy_no);--NLC7078
        if ln_gmat_polrid >0 and ln_Eti_flag =0 then
          ln_gmat_polrid:=0;
          end if;
        lb_update := bpg_claims_reuse.bfn_validate_maturity(cr_policy_riders.v_policy_no,cr_policy_riders.n_seq_no,
                                                            cr_policy_riders.v_plan_code,ln_gmat_polrid);   --NLC6067
        if  lb_update = True then
        ln_prev_claim :=0;  --Start NLC6082
        lv_cancer_product:=bpg_claim_processing.bfn_get_cancer_product(cr_policy_riders.v_plan_code);
        lv_ext_cov:=bpg_claim_processing.bfn_get_ext_term(cr_policy_riders.v_policy_no,cr_policy_riders.n_seq_no,
                                                          cr_policy_riders.v_plan_code,cr_policy_riders.v_parent_plri_code);
        ln_prev_claim:=bpg_claim_processing.bfn_get_prev_cancer_amt(cr_policy_riders.v_policy_no,cr_policy_riders.n_seq_no,
                                                                    cr_policy_riders.v_plan_code,cr_policy_riders.v_parent_plri_code,null,'P');
        if nvl(lv_cancer_product,'N')='Y' and nvl(lv_ext_cov,'N')='N' and nvl(ln_prev_claim,0)>0 then
           if nvl(ln_gmat_polrid,0)>=0 then
	           bpg_claims_reuse.bpc_cancer_extend_coverage(cr_policy_riders.v_policy_no,
	                                                       cr_policy_riders.n_seq_no,
	                                                       cr_policy_riders.v_plan_code,
	                                                       cr_policy_riders.v_parent_plri_code,
	                                                       cr_policy_riders.n_rider_sa,
	                                                       cr_policy_riders.d_rider_end,
	                                                       cr_policy_riders.v_plri_flag,
	                                                       'OR',
					     								   p_user,
					     								   p_prog,
					     								   p_date);
		  end if;
        elsif nvl(lv_cancer_product,'N')='N' or nvl(lv_ext_cov,'N')='Y' or  nvl(ln_prev_claim,0)<=0 then --end
        DBMS_OUTPUT.PUT_LINE('PLAN CODE ='||cr_policy_riders.v_plan_code);
        DBMS_OUTPUT.PUT_LINE('ln_gmat_polrid ='||ln_gmat_polrid);
        --If ln_gmat_polrid <=0 then  --> NLC6067, remove this condition and replaced it with if lb_update = True
      		  update gnmt_policy_riders
         		set
         		      --v_status = 'I' , (commented by Roziati for NLC6047 on 26-10-2007 as requested by Senthil Manickam and adviced from Srini)
         		      v_rider_status = 'I' ,
         		      v_rider_stat_code = lv_status_value,
         		      v_rider_prem_stat_code = lv_status_value   --added on 07-01-08
         		where v_policy_no = cr_policy_riders.v_policy_no
         		and	  n_seq_no	  = cr_policy_riders.n_seq_no
         		and   v_plan_code = cr_policy_riders.v_plan_code
         		and   v_parent_plri_code = cr_policy_riders.v_parent_plri_code;



         		update GNDT_CHARGE_POL_LOAD_DIS_DETS
					set v_status = 'I'
					where v_policy_no 			= 	cr_policy_riders.v_policy_no 	and
			    		  n_seq_no  			= 	cr_policy_riders.n_seq_no 	and
			      		  v_plri_code 			=	cr_policy_riders.v_plan_code and
				          v_parent_plri_code 	= 	cr_policy_riders.v_parent_plri_code;

 				update gnmt_charge_policy_link_master
					set 	v_status = 'I'
					where v_policy_no 			= 	cr_policy_riders.v_policy_no 	and
			    		  n_seq_no  			= 	cr_policy_riders.n_seq_no 	and
			      		  v_plri_code 			=	cr_policy_riders.v_plan_code and
				          v_parent_plri_code 	= 	cr_policy_riders.v_parent_plri_code;

   				update gnmt_policy_event_link
					set 	v_status = 'I'
					where v_policy_no 			= 	cr_policy_riders.v_policy_no 	and
			    		  n_seq_no  			= 	cr_policy_riders.n_seq_no 	and
			      		  v_plri_code 			=	cr_policy_riders.v_plan_code and
				          v_parent_plri_code 	= 	cr_policy_riders.v_parent_plri_code;


                  IF lv_grp_ind = 'I'           THEN
                     lv_scope := 'IP';
                     ln_seq_no := NULL;
                  ELSIF lv_grp_ind = 'G'        THEN
                     ln_seq_no := cr_policy_riders.n_seq_no;
                     lv_scope := 'GP';
                  END IF;


  				bpg_gen_ri_intimation.BPC_CLAIMS_RI(cr_policy_riders.v_policy_no,
  				                                    cr_policy_riders.n_seq_no
  				                                    ,null   --     ,p_claim_no
  				                                    ,null   --     ,p_sub_claim_no
  				                                    ,cr_policy_riders.v_plan_code
  				                                    ,null
  				                                    ,null
  				                                    ,cr_policy_riders.d_rider_end
  				                                    ,null
  				                                    ,'EXIT'
  				                                    ,'N');

               bpg_policy.bpc_insert_claim_quot_backup(cr_policy_riders.v_policy_no,
									ln_seq_no,
									cr_policy_riders.d_rider_end,
									p_user,
									p_prog,
									p_date,
									'Y'--p_quot_flag
									);

         		bpg_gen.bpc_insert_contract_status_log(cr_policy_riders.v_policy_no	,
     								cr_policy_riders.n_seq_no 			,
     								cr_policy_riders.v_plan_code 		,
     								cr_policy_riders.v_parent_plri_code 	,
     								cr_policy_riders.v_plri_flag 		,
     								lv_status_value			   	,
     								p_user 				,
     								p_prog 				,
     								p_date 				);

      		--add on 04.10.2005	NLC2627
			bpg_prem_calc.bpc_incr_decr_rider_premium(
													  p_policy_no		=> cr_policy_riders.v_policy_no
													 ,p_seq_no			=> cr_policy_riders.n_seq_no
													 ,p_plan_code		=> cr_policy_riders.v_plan_code
													 ,p_parent_plri_code=> cr_policy_riders.v_parent_plri_code
													 ,p_incr_decr		=> 'D'
													 ,p_user 			=> p_user
													 ,p_prog			=> p_prog
													 ,p_date			=> p_date);
	 end if;
     end if;
	 EXCEPTION WHEN OTHERS THEN
		DECLARE
		 XX VARCHAR2(4000) ;
		BEGIN
		    XX := SQLERRM;
		    ROLLBACK TO LOOP_START;
			INSERT INTO PSMT_LAPSE_EXCEPTION
			(V_POLICY_NO,N_SEQ_NO,D_PREM_UPTO,D_LAPSED,D_EXCEPTION,V_EXCEPTION_STATUS,
			V_STATUS,V_LASTUPD_USER,V_LASTUPD_PROG,V_LASTUPD_INFTIM,V_ERR_MSG)
			VALUES
			(cr_policy_riders.v_policy_no,1,SYSDATE,SYSDATE + 1,SYSDATE,'U',
				'A',USER,P_PROG,P_DATE,XX);
		END;
	 END;
	end loop;

  ln_cnt := 1;
  for cr_policy_suspend in (select v_policy_no,v_cntr_stat_code,
  								d_commencement,d_policy_end_date,gp.v_plan_code
  						from 	gnmt_policy gp, gnmm_plan_master pm
  						where	gp.v_plan_code = pm.v_plan_code  
  						and gp.v_policy_no='UI201900434584'
  						and  	pm.v_prod_line not in ('LOB003')-- 'LOB004') --added on 07-01-2008 by Roziati for NLC6211
  						and 	v_cntr_stat_code IN ('NB010','NB014','NB016','NB219')  --'NB219' added by saravanan for NLC10001437
  						  and   to_date(to_CHAR(d_policy_end_date,'dd/mm/yyyy'),'dd/mm/yyyy')<=
  								to_date(to_CHAR(p_run_date,'dd/mm/yyyy'),'dd/mm/yyyy'))
  loop

		dbms_application_info.set_client_info('Policy suspend expiry');
        dbms_application_info.set_action(ln_cnt || ' pol ' || cr_policy_suspend.v_policy_no);
		dbms_application_info.set_client_info(' policy sus');
		ln_cnt := ln_cnt + 1;

    for cr_gmat_event in (select v_policy_no,n_seq_no,v_claim_no,n_sub_claim_no,v_plri_code
    					  from
    					  cldt_claim_event_policy_link
    					  where v_policy_no=cr_policy_suspend.v_policy_no
    					  and v_parent_event_code ='GMAT'
    					  and v_plri_code=cr_policy_suspend.v_plan_code) loop
	begin
		Savepoint loop_start;

  		open cr_cnt_status(cr_gmat_event.v_claim_no,cr_gmat_event.n_sub_claim_no);
  	    fetch cr_cnt_status into ln_cnt_status;
  	    close cr_cnt_status;

      if ln_cnt_status > 0 then
      --claim is Notified / Pending update the status to POLICY SUSPENDED
            update 	gnmt_policy
       		set   	v_cntr_stat_code 	= 'NB211',
       				v_cntr_prem_stat_code = 'NB211',
					v_lastupd_user      = user,
					v_lastupd_prog      = 'BPC_UPDATE_STATUS_EXPIRY' ,
					v_lastupd_inftim     = sysdate
       		where 	v_policy_no  	   	= cr_gmat_event.v_policy_no
        	 and    v_plan_code         = cr_gmat_event.v_plri_code;--NLC6082


 	     	update 	gnmt_policy_detail
    	    set   	v_cntr_stat_code 		= 'NB211',
					v_cntr_prem_stat_code 	= 'NB211',
    	    		v_lastupd_user      = user,
					v_lastupd_prog      = 'BPC_UPDATE_STATUS_EXPIRY' ,
					v_lastupd_inftim    = sysdate
     	    where 	v_policy_no	 		= cr_gmat_event.v_policy_no
     	    and	  	n_seq_no		 	= cr_gmat_event.n_seq_no
     	    and    v_plan_code          = cr_gmat_event.v_plri_code;--NLC6082
      end if;

	   EXCEPTION WHEN OTHERS THEN
			DECLARE
			 XX VARCHAR2(4000) ;
			BEGIN
			    XX := SQLERRM;
			    ROLLBACK TO LOOP_START;
				INSERT INTO PSMT_LAPSE_EXCEPTION
				(V_POLICY_NO,N_SEQ_NO,D_PREM_UPTO,D_LAPSED,D_EXCEPTION,V_EXCEPTION_STATUS,
				V_STATUS,V_LASTUPD_USER,V_LASTUPD_PROG,V_LASTUPD_INFTIM,V_ERR_MSG)
				VALUES
				(cr_policy_suspend.v_policy_no,1,SYSDATE,SYSDATE + 1,SYSDATE,'U',
					'A',USER,P_PROG,P_DATE,XX);
			END;
	   END;
  	end loop;
  end loop;

--Added for NLC6067 & NLc6082
ln_cnt := 1;
for cr_rider_suspend in (select v_policy_no,v_rider_stat_code,
  								d_rider_start,d_rider_end,gpr.v_plan_code
  						from 	gnmt_policy_riders gpr, gnmm_plan_master pm
  						where	gpr.v_plan_code = pm.v_plan_code
  						and  	pm.v_prod_line not in ('LOB003') 
  						and gpr.v_policy_no='UI201900434584'
  						and 	gpr.v_rider_stat_code IN ('NB010','NB014','NB016','NB219') --'NB219' added by saravanan for NLC10001437
  						  and   to_date(to_CHAR(d_rider_end,'dd/mm/yyyy'),'dd/mm/yyyy')<=
  								to_date(to_CHAR(p_run_date,'dd/mm/yyyy'),'dd/mm/yyyy'))
  loop

		dbms_application_info.set_client_info('Rider suspend expiry');
        dbms_application_info.set_action(ln_cnt || ' pol ' || cr_rider_suspend.v_policy_no);
		dbms_application_info.set_client_info(' Rider sus');
		ln_cnt := ln_cnt + 1;

    for cr_gmat_event in (select v_policy_no,n_seq_no,v_claim_no,n_sub_claim_no,v_plri_code
    					  from
    					  cldt_claim_event_policy_link
    					  where v_policy_no=cr_rider_suspend.v_policy_no
    					  and v_parent_event_code ='GMAT'
    					  and v_plri_code=cr_rider_suspend.v_plan_code) loop
	begin
		Savepoint loop_start;

  		open cr_cnt_status(cr_gmat_event.v_claim_no,cr_gmat_event.n_sub_claim_no);
  	    fetch cr_cnt_status into ln_cnt_status;
  	    close cr_cnt_status;

      if ln_cnt_status > 0 then
 	     	update 	gnmt_policy_riders
    	    set   	v_rider_stat_code 		= 'NB211',
					v_rider_prem_stat_code 	= 'NB211',
    	    		v_lastupd_user      = user,
					v_lastupd_prog      = 'BPC_UPDATE_STATUS_EXPIRY' ,
					v_lastupd_inftim    = sysdate
     	    where 	v_policy_no	 		= cr_gmat_event.v_policy_no
     	    and	  	n_seq_no		 	= cr_gmat_event.n_seq_no
     	    and     v_plan_code         = cr_gmat_event.v_plri_code;
      end if;

	   EXCEPTION WHEN OTHERS THEN
			DECLARE
			 XX VARCHAR2(4000) ;
			BEGIN
			    XX := SQLERRM;
			    ROLLBACK TO LOOP_START;
				INSERT INTO PSMT_LAPSE_EXCEPTION
				(V_POLICY_NO,N_SEQ_NO,D_PREM_UPTO,D_LAPSED,D_EXCEPTION,V_EXCEPTION_STATUS,
				V_STATUS,V_LASTUPD_USER,V_LASTUPD_PROG,V_LASTUPD_INFTIM,V_ERR_MSG)
				VALUES
				(cr_rider_suspend.v_policy_no,1,SYSDATE,SYSDATE + 1,SYSDATE,'U',
					'A',USER,P_PROG,P_DATE,XX);
			END;
	   END;
  	end loop;
  end loop;
 end;
begin
  fpc_update_status_expiry  (p_run_date=>sysdate,p_user=>user,p_prog=>user,p_date=>sysdate);
end;