----ISF TRANSACTONS--------
SELECT
    TRUNC(accounting_date)accounting_date,
    segment5,
    nvl(entered_dr,0) DR,
    nvl(entered_cr,0) CR,
    reference10,
    group_id

FROM
    xxjicke_gl_interface_stg
WHERE
     accounting_date >= '01-JAN-2022'
     AND trunc(accounting_date) BETWEEN :start_date AND :end_date
 MINUS
---OFA TRANSACTIONS-----
SELECT
    trunc(transaction_date) transaction_date,
     segment5,
    nvl(entered_dr,0)entered_dr,
    nvl(entered_cr,0)entered_cr,
    description,
    group_id
FROM
    xxjic_isf_journals_v
   WHERE   trunc(transaction_date)  BETWEEN :start_date AND :end_date