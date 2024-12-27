Begin
--   ORDS.define_module(
--    p_module_name    => 'ISFLIFE',
--    p_base_path      => 'services/',
--
--    p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/ToRetrievePolicyStatus');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/ToRetrievePolicyStatus',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PP_FRM_11_OUTSTANDING.REST_POLICY_STATUS_MASTER(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/PolicyStatusLog');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern        => 'newBusiness/v1/PolicyStatusLog',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PP_FRM_11_OUTSTANDING.REST_POLICY_STATUS_LOG(p_body=>:body);  END;',
						p_items_per_page => 0);


	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/ToRetrievePolicyCurrentStatus');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern        => 'newBusiness/v1/ToRetrievePolicyCurrentStatus',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PP_FRM_11_OUTSTANDING.REST_POLICY_CURRENT_STATUS(p_body=>:body);  END;',
						p_items_per_page => 0);


	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/ExtractionOfPolicyPendingDocuments');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/ExtractionOfPolicyPendingDocuments',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PLCY_PENDING_DOCS_UPD.REST_POLICY_PENDING_DOCS(p_body=>:body);  END;',
						p_items_per_page => 0);

    --
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/ToUpdateTheStatusAndOtherDetailsOfPPendingDocuments');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/ToUpdateTheStatusAndOtherDetailsOfPPendingDocuments',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PLCY_PENDING_DOCS_UPD.REST_POLICY_PENDING_DOCS_UPD(p_body=>:body);  END;',
						p_items_per_page => 0);


	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/PolicyIssuance');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern        => 'newBusiness/v1/PolicyIssuance',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_NB_FRM_04.REST_BPC_POLICY_ISSUE(p_body=>:body);  END;',
						p_items_per_page => 0);


	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/DataForPolicyIssuance');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/DataForPolicyIssuance',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_NB_FRM_04.REST_BPC_POLICY_ISSUE_FETCH(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/PolicyData');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/PolicyData',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_ENG_FRM_01.REST_BPC_POLICY_FETCH(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/PolicyDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/PolicyDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_ENG_FRM_01.REST_BPC_GNMT_POLICY(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/RequestForCustomerRegistration');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/RequestForCustomerRegistration',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_CUST_REGISTRATION.REST_BFN_CUST_REG_REQUEST(p_body=>:body);  END;',
						p_items_per_page => 0);
	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/CompanyRegistrationRequest');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/CompanyRegistrationRequest',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_CMPY_REGISTRATION.REST_BFN_COMP_REG_REQUEST(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'newBusiness/v1/CalculatePremiumAtMemberAndQuotationLevel');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'newBusiness/v1/CalculatePremiumAtMemberAndQuotationLevel',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_PROPOSAL.REST_BFN_PROCESS_QUOTATION(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/OverShortPaymentDetailsByPolicy');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/OverShortPaymentDetailsByPolicy',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PP_FRM_11_OUTSTANDING.REST_PPDT_DN_OVERSHORT_PAYMENT(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'agency/v1/PoliciesSoldByAgentAndHierarchyOfTheAgent');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'agency/v1/PoliciesSoldByAgentAndHierarchyOfTheAgent',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_ENG_FRM_01.REST_BPC_AGENT_DETAIL(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'agency/v1/IdentificationNumbervalidataion');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'agency/v1/IdentificationNumbervalidataion',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_AM_FRM_02.REST_BPC_IDEN_NO_VALIDATION(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'agency/v1/AgentAppointmentDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'agency/v1/AgentAppointmentDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_AM_FRM_02.REST_BFN_AGENT_APPOINTMENT(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'agency/v1/AgentDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'agency/v1/AgentDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_AM_FRM_57_1.REST_BPC_FETCH_AGENT_DETAILS(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'agency/v1/HierarchyOfTheAgent');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'agency/v1/HierarchyOfTheAgent',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_AM_FRM_57_1.REST_BPC_FETCH_HIERARCHY_DETS(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/GroupMemberDataLoading');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/GroupMemberDataLoading',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_GQL_FRM_02.REST_BPC_LOAD_TO_TEMP_TABLE(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/GroupPolicyMemberDataLoading');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/GroupPolicyMemberDataLoading',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_GQL_FRM_02.REST_BPC_TEMP_GND_QUOT_DET(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/LoadingQuotationEventsAndRates');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/LoadingQuotationEventsAndRates',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_QUOTATION_PROCESS(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/ExtractQuotationHeaderDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/ExtractQuotationHeaderDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_QUOTATION_ID_KNI(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/ProcessUnderwriting');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/ProcessUnderwriting',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_PROCESS_UW_WBP(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/GenerateBillForEachSubsidiaryForGroupPolicyWhenMultipleCompainessAreInvolved');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/GenerateBillForEachSubsidiaryForGroupPolicyWhenMultipleCompainessAreInvolved',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PP_FRM_11_OUTSTANDING.REST_GNMT_COMPANY_ACCOUNT(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/FirstBillOfThePolicy');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/FirstBillOfThePolicy',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PP_FRM_11_OUTSTANDING.REST_GNDT_FIRST_BILL(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/BillingDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/BillingDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PP_FRM_11_OUTSTANDING.REST_GNDT_BILL_IND_DETS(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/GeneralLedgerDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/GeneralLedgerDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_GNDT_GL_DETAILS(p_body=>:body);  END;',
						p_items_per_page => 0);


	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/RequestForIssuingReceipt');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/RequestForIssuingReceipt',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_COLLECTION_SERVICE.REST_BFN_RECEIPT_SRV_REQUEST(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/ReceiptDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/ReceiptDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_ENG_FRM_01.REST_BPC_RECEIPT(p_body=>:body);  END;',
						p_items_per_page => 0);


	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'finance/v1/VoucherDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'finance/v1/VoucherDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_ENG_FRM_01.REST_BPC_GET_VOUCHER_DETAILS(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'unitLink/v1/FundDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'unitLink/v1/FundDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_ENG_FRM_01.REST_BPC_FUND_DETAIL(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/ProcessQuotationToLoadQuotationDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/ProcessQuotationToLoadQuotationDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_PROCESS_QUOTATION_WBP(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/ProcessMembers');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/ProcessMembers',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_PROCESS_MEMBERS_WBP(p_body=>:body);  END;',
						p_items_per_page => 0);
	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/GroupPolicyLoadingDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/GroupPolicyLoadingDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_LOADING_WBP(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/ErrorsOfGroupPolicy');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/ErrorsOfGroupPolicy',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_ERROR_WBP(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/GroupPolicyPremiumDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/GroupPolicyPremiumDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_CONTRIBUTION_WBP(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/FreeCoverLimitsVerification');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/FreeCoverLimitsVerification',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GQS_FRM_04.REST_BPC_CHECK_FCL_WBP(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/GenerationOfGroupPolicy');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/GenerationOfGroupPolicy',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GNB_FRM_01.REST_BPC_GEN_POLICY_NO(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/PolicyData');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/PolicyData',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GRP_POL_DET.REST_BPC_POLICY_FETCH(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/QuotationHeader');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/QuotationHeader',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_JHL_GQS_FRM_01.REST_BPC_QUOATION_HEADER(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'group/v1/GroupPolicyIssurance');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'group/v1/GroupPolicyIssurance',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GNB_FRM_01.REST_BPC_ISSUE_POLICY_JOB(p_body=>:body);  END;',
						p_items_per_page => 0);
	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ReinsuranceClaimProvisionDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ReinsuranceClaimProvisionDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_RIDT_CLAIM_RI_PROVISION(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimRecoveryAndRefund');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimRecoveryAndRefund',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_RECOREF_MASTER(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimRecoveryAndRefundDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimRecoveryAndRefundDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_RECOREF_DETAIL(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimProvisionDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimProvisionDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_PROVISION_MASTER(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/PaymentDetailsOfClaimProfessionals');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/PaymentDetailsOfClaimProfessionals',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_PROF_PAYMENT_HIST(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimsEnquiryWithVariousParameters');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimsEnquiryWithVariousParameters',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_NB_QUERY_REQUEST(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ReceipientDetailsToSendRequirementLetter');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ReceipientDetailsToSendRequirementLetter',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_LETTER_DESP_POLICY_LINK(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/DocumentsRequiredFromReceipientForClaimProcessing');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/DocumentsRequiredFromReceipientForClaimProcessing',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_LETTER_DESP_DOC_LINK(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/RecipientsForClaimsDispatch');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/RecipientsForClaimsDispatch',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_LETTER_DESP_CC_LINK(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ListOfProfessionalsNominatedForClaimInvestigation');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ListOfProfessionalsNominatedForClaimInvestigation',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_PROF_FEE_LINK(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/DocumentsRequestedByProfessionals');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/DocumentsRequestedByProfessionals',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_PROF_DOC_LINK(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimInformation');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimInformation',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_MASTER(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimRecepientDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimRecepientDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_LETTER_DESP_LINK(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/InforcePoliciesToRegisterTheClaim');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/InforcePoliciesToRegisterTheClaim',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_INPUT(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimEventDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimEventDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_EVENT_LINK(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/DocumentsRequestedForClaimProcessing');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/DocumentsRequestedForClaimProcessing',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_DOCU_REQUEST(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimDocuments');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimDocuments',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_DOCUMENTS(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/MovementsOfTheClaim');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/MovementsOfTheClaim',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIM_DECESSION_HISTORY(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimPayeeInfo');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimPayeeInfo',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIMANT_MASTER(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimPayeeDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimPayeeDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_GCL_FRM_02.REST_CLDT_CLAIMANT_DETAIL(p_body=>:body);  END;',
						p_items_per_page => 0);

	--
	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimIntimationDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimIntimationDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_CL_GCL_FRM_45.REST_BPC_FECTH_INTIMATION(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/SelectionOfLifePoliciesForClaimProcessing');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/SelectionOfLifePoliciesForClaimProcessing',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_CL_GCL_FRM_45.REST_BPC_GET_LIFE_POLICIES(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/ClaimDetails');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/ClaimDetails',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_CL_GCL_FRM_45.REST_BPC_PROCESS(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'claims/v1/MemberDetailsForClaimProcessing');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'claims/v1/MemberDetailsForClaimProcessing',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_CL_GCL_FRM_45.REST_BPC_SEARCH(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'groupExit/v1/ProcessGroupMemberExits');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'groupExit/v1/ProcessGroupMemberExits',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_PROCESS_EXIT_WDRL_JHL.REST_BPC_PROCESS_EXIT_WDRL_JHL(p_body=>:body);  END;',
						p_items_per_page => 0);

	ORDS.define_template(p_module_name  => 'ISFLIFE',p_pattern=> 'agency/v1/HierarchySubordinatesOfTheAgent');
	ORDS.define_handler(p_module_name   => 'ISFLIFE',
						p_pattern       => 'agency/v1/HierarchySubordinatesOfTheAgent',
						p_method		=> 'POST',
						p_source_type 	=> ORDS.source_type_plsql,
						p_source 		=> 'BEGIN REST_BPG_AM_FRM_57_1.REST_BPC_FETCH_SUBORDINATE_DETS(p_body=>:body);  END;',
						p_items_per_page => 0);
	Commit;
End;
/
