/* Formatted on 27/04/2023 18:33:51 (QP5 v5.215.12089.38647) */
Hq230019507

SELECT *
  FROM Remt_Receipt_Instruments
 WHERE N_Receipt_Session = 430570;

SELECT ROWID, X.*
  FROM Gndt_Finance_Branch_Banks X
 WHERE X.V_Ins_Code = 'DDA_4';  
 
 DDA_15         164101

SELECT V_Lob_Code,
       V_Par_Non_Par,
       V_Business_Unit_Indicator,
       N_Ref_No
  FROM Gndt_Gl_Details
 WHERE N_Ref_No IN
          (SELECT N_Ref_No
             FROM Gnmt_Gl_Master
            WHERE V_Docu_Ref_No IN (SELECT V_Receipt_No
                                      FROM Remt_Receipt
                                     WHERE N_Receipt_Session = 430570));
                                     
                                     
Select n_receipt_session from remt_receipt where v_receipt_no = 'HQ230008912';

Select * from remt_receipt where n_receipt_session = 430570 and v_receipt_table = 'DETAIL';