-- Author Engineer Frank Bagambe Guma
-- Find tables referenced by gnmt_policy
SELECT 
    ac.constraint_name,
    ac.table_name AS referenced_table,
    acc.column_name AS referenced_column,
    ac_r.table_name AS referenced_by_table,
    acc_r.column_name AS referenced_by_column
FROM 
    all_constraints ac
    JOIN all_cons_columns acc ON ac.constraint_name = acc.constraint_name
    JOIN all_constraints ac_r ON ac.r_constraint_name = ac_r.constraint_name
    JOIN all_cons_columns acc_r ON ac_r.constraint_name = acc_r.constraint_name
WHERE 
    ac.constraint_type = 'R'
    AND ac.table_name = 'GNMT_POLICY'

---- Find tables referencing gnmt_policy

SELECT 
    ac.constraint_name,
    ac_r.table_name AS referenced_table,
    acc_r.column_name AS referenced_column,
    ac.table_name AS referenced_by_table,
    acc.column_name AS referenced_by_column
FROM 
    all_constraints ac
    JOIN all_cons_columns acc ON ac.constraint_name = acc.constraint_name
    JOIN all_constraints ac_r ON ac.r_constraint_name = ac_r.constraint_name
    JOIN all_cons_columns acc_r ON ac_r.constraint_name = acc_r.constraint_name
WHERE 
    ac.constraint_type = 'R'
    AND ac_r.table_name = 'GNMT_POLICY';


select * from GNDT_POLICY_CORRES_ADDRESS

select * from PPDT_POLICY_DEDUCTION_DETAILS

select * from GNMT_POLICY_COMPANIES

select * from GNMM_PLAN_MASTER