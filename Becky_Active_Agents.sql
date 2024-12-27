/* Formatted on 18/07/2024 17:52:15 (QP5 v5.215.12089.38647) */
/*
Author: Frank Bagambe
Date:  18-JUL-2024
Desc:  Fetching all active Agents and their Leadership

--create view FRA_Active_Agents as 

*/


SELECT *
  FROM (SELECT A.V_Agent_Code,
               B.V_Name,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 30, N_Manager_No, 0)))
                          Usm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS Unit_Sales_Manager,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 20, N_Manager_No, 0)))
                          Asm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS Agency_Sales_Manager,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 15, N_Manager_No, 0)))
                          Rsm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS Regional_Sales_Manager,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 10, N_Manager_No, 0)))
                          Nsm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS National_Sales_Manager,
               (SELECT W.V_Agent_Status_Desc
                  FROM Ammm_Agent_Status W
                 WHERE W.V_Agent_Status_Code = A.V_Status AND ROWNUM = 1)
                  AS Agent_Status_Desc,
               D.V_Iden_No AS "National ID",
               B.D_Birth_Date,
               B.V_Marital_Status,
               B.V_Sex,
               (SELECT E.V_Contact_Number
                  FROM Gndt_Custmobile_Contacts E
                 WHERE E.N_Cust_Ref_No = A.N_Cust_Ref_No AND ROWNUM = 1)
                  AS "Contact/Email",
               A.D_Appointment,
               A.D_Termination
          FROM Ammm_Agent_Master A
               JOIN Gnmt_Customer_Master B
                  ON A.N_Cust_Ref_No = B.N_Cust_Ref_No
               LEFT JOIN Gndt_Customer_Identification D
                  ON     A.N_Cust_Ref_No = D.N_Cust_Ref_No
                     AND D.V_Iden_Code = 'NIC'
               LEFT JOIN Ammm_Agent_Master G
                  ON A.N_Currently_Reporting_To = G.N_Agent_No
               LEFT JOIN Gnmt_Customer_Master H
                  ON G.N_Cust_Ref_No = H.N_Cust_Ref_No
        UNION
        SELECT A.V_Agent_Code,
               B.V_Name,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 30, N_Manager_No, 0)))
                          Usm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS Unit_Sales_Manager,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 20, N_Manager_No, 0)))
                          Asm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS Agency_Sales_Manager,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 15, N_Manager_No, 0)))
                          Rsm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS Regional_Sales_Manager,
               (SELECT Jhl_Utils.Agent_Name (
                          SUM (DECODE (N_Manager_Level, 10, N_Manager_No, 0)))
                          Nsm
                  FROM Ammt_Agent_Hierarchy K
                 WHERE K.N_Agent_No = A.N_Agent_No AND V_Status = 'A')
                  AS National_Sales_Manager,
               (SELECT W.V_Agent_Status_Desc
                  FROM Ammm_Agent_Status W
                 WHERE W.V_Agent_Status_Code = A.V_Status AND ROWNUM = 1)
                  AS Agent_Status_Desc,
               D.V_Iden_No AS "National ID",
               B.D_Birth_Date,
               B.V_Marital_Status,
               B.V_Sex,
               (SELECT E.V_Contact_Number
                  FROM Gndt_Custmobile_Contacts E
                 WHERE E.N_Cust_Ref_No = A.N_Cust_Ref_No AND ROWNUM = 1)
                  AS "Contact/Email",
               A.D_Appointment,
               A.D_Termination
          FROM Ammm_Agent_Master A
               JOIN Gnmt_Customer_Master B
                  ON A.N_Cust_Ref_No = B.N_Cust_Ref_No
               LEFT JOIN Gndt_Customer_Identification D
                  ON     A.N_Cust_Ref_No = D.N_Cust_Ref_No
                     AND D.V_Iden_Code = 'NIC'
               LEFT JOIN Ammm_Agent_Master G
                  ON A.N_Currently_Reporting_To = G.N_Agent_No
               LEFT JOIN Gnmm_Company_Master H
                  ON     G.V_Company_Code = H.V_Company_Code
                     AND G.V_Company_Branch = H.V_Company_Branch)
 WHERE AGENT_STATUS_DESC = 'Active'
 