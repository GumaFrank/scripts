WITH CTE_ISF_GL AS
(
---ISF  TRANSACTIONS----
SELECT 
trunc(accounting_date)accounting_date, segment5,concat(to_char(accounting_date,'ddmmyyyy'),segment5)unique_id,
   sum(nvl(entered_dr, 0))isf_gl_dr,  sum(nvl(entered_cr, 0))isf_gl__cr
FROM xxjicke_gl_interface_stg
WHERE trunc(accounting_date) BETWEEN :start_date AND :end_date
      AND USER_JE_SOURCE_NAME = 'ISF LIFE'
GROUP BY segment5, trunc(accounting_date),concat(to_char(accounting_date,'ddmmyyyy'),segment5)
ORDER BY 1,2
),CTE_OFA_STAGING AS
(
----ISF STAGED TRANSACTIONS IN OFA
SELECT 
/*+ driving_site (n) */
    trunc(accounting_date)                                 accounting_date,
    segment5,
    concat(to_char(accounting_date, 'ddmmyyyy'), segment5) unique_id,
   SUM(nvl(entered_dr, 0))                                ofa_staging_dr,
    SUM(nvl(entered_cr, 0))                                ofa_staging_cr
FROM
    xxjicke_gl_interface_stg@jicofprod.com n
WHERE
    accounting_date BETWEEN :start_date AND :end_date
    AND user_je_source_name = 'ISF LIFE' group by trunc(accounting_date), segment5, concat(to_char(accounting_date, 'ddmmyyyy'), segment5)

ORDER BY
    1,
    2
),CTE_ISF_OFA
AS
(
--/* ISF GL  in OFA TRANSACTIONS  **/
 select
trunc(TRANSACTION_DATE)TRANSACTION_DATE,
segment5,
CONCAT(TO_CHAR(TRANSACTION_DATE,'DDMMYYYY'),segment5)UNIQUE_ID,
sum(NVL(entered_dr, 0)) ofa_dr,
sum(NVL(entered_cr, 0)) ofa_cr

FROM
  XXJIC_ISF_JOURNALS_V
WHERE CURRENCY_CODE = 'KES' 

and TRANSACTION_DATE BETWEEN :start_date AND :end_date
GROUP BY segment5, trunc(TRANSACTION_DATE),CONCAT(TO_CHAR(TRANSACTION_DATE,'DDMMYYYY'),segment5)
ORDER BY 1,2
)

SELECT 
a.ACCOUNTING_DATE,
a.SEGMENT5, 
a.UNIQUE_ID, 
a.ISF_GL_DR, 
a.ISF_GL__CR,
b.OFA_STAGING_DR, 
b.OFA_STAGING_CR,
c.ofa_dr,
c.ofa_cr,
( a.ISF_GL_DR - nvl(c.ofa_dr,0))ISF_OFA_GL_DIFF_DR,
(a.ISF_GL__CR - nvl(c.ofa_cr,0)) ISF_OFA_GL_DIFF_CR,
( a.ISF_GL_DR - nvl(c.ofa_dr,0)) - (a.ISF_GL__CR - nvl(c.ofa_cr,0))   Exception
FROM
 CTE_ISF_GL a left join CTE_OFA_STAGING b
 on a.unique_id = b.unique_id
 left join CTE_ISF_OFA c
 on a.unique_id = c.unique_id
 order by a.ACCOUNTING_DATE,a.SEGMENT5