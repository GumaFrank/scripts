/* Formatted on 26/08/2020 14:54:57 (QP5 v5.256.13226.35538) */

-- AML FLAGGED TRANSACTION REPORT

SELECT COUNT(DISTINCT RECEIPT_NUMBER) FROM 
(
SELECT DAUG.pkg_utils.GET_SCHEME (SCHEME_CODE) AS schemecode,
       DAUG.PKG_UTILS.GET_SCHEME_COMPANY (scheme_code, COMPANY_CODE) AS companyname,
       DAUG.pkg_utils.GET_MEMBERNAME (member_code) AS membername,
       c_receipt AS receipt_number,
       TO_NUMBER (MEMBER_CONT_REG) AS "Member Registered",
       TO_NUMBER (MEMBER_CONT_UNREG) AS "Member Unregistered",
       TO_NUMBER (EMP_CONT_REG) AS "Employer Registered",
       TO_NUMBER (EMP_CONT_UNREG) AS "Employer Unregistered",
       TO_NUMBER (VOL_CONT_REG) AS "Voluntary Registered",
       TO_NUMBER (VOL_CONT_unREG) AS "Voluntary Unregistered",
       TO_NUMBER (SPL_CONT_REG) AS "Special Registered",
       TO_NUMBER (SPL_CONT_UNREG) AS "Special Unregistered",
       TO_NUMBER (nssf_member) AS "NSSF Member",
       TO_NUMBER (NSSF_EMP) AS "NSSF Employer",
       TO_CHAR (FROM_DATE, 'dd-mon-yyyy') AS Allocation_month,
       DECODE (ft.STATUS,
               'R', 'REJECTED',
               'Y', 'APPROVED',
               'N', 'PENDING APPROVAL') AS STATUS
  FROM DAUG.gpnc_receipts_transfer re, DAUG.AML_FLAGGED_transfers ft
 WHERE re.TRANSFER_ID = ft.TRANSFER_ID
 AND ALLOCATION_MONTH BETWEEN '01-JAN-2023' AND '31-DEC-2023'
 
UNION ALL

SELECT DAUG.pkg_utils.GET_SCHEME (SCHEME_CODE) AS schemecode,
       DAUG.PKG_UTILS.GET_SCHEME_COMPANY (scheme_code, COMPANY_CODE) AS companyname,
       DAUG.pkg_utils.GET_MEMBERNAME (member_code) AS membername,
       c_receipt AS receipt_number,
       TO_NUMBER (MEMBER_CONT) AS "Member Registered",
       TO_NUMBER (ra.MEMBER_CONT_UNREG) AS "Member Unregistered",
       TO_NUMBER (ra.EMP_CONT) AS "Employer Registered",
       TO_NUMBER (ra.EMP_CONT_UNREG) AS "Employer Unregistered",
       TO_NUMBER (VOL_CONT) AS "Voluntary Registered",
       0 AS "Voluntary Unregistered",
       TO_NUMBER (spl_cont) AS "Special Registered",
       0 AS "Special Unregistered",
       TO_NUMBER (nssf_member) AS "NSSF Member",
       TO_NUMBER (NSSF_EMP) AS "NSSF Employer",
       TO_CHAR (FROM_DATE, 'dd-mon-yyyy') AS Allocation_month,
       DECODE (fc.STATUS,
               'R', 'REJECTED',
               'Y', 'APPROVED',
               'N', 'PENDING APPROVAL') AS STATUS
  FROM DAUG.gpnc_receipts_allocation ra, DAUG.AML_FLAGGED_CONTRIBUTIONS fc
 WHERE ra.allocation_id = fc.ALLOCATION_ID
 AND ALLOCATION_MONTH BETWEEN '01-JAN-2023' AND '31-DEC-2023'
)
--WHERE  ALLOCATION_MONTH BETWEEN '01-JAN-2023' AND '31-DEC-2023'