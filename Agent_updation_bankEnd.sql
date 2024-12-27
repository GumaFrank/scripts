select n_agent_no
from ammt_agent_lob
where v_status = 'A'
and v_line_of_Business in
                 (
                  select v_prod_line
                  from gnmm_plan_master
                  where v_status = 'A'
                  and v_plan_code = 'BGTL001'
                 )
AND N_AGENT_NO NOT IN
             (
               SELECT N_AGENT_NO FROM AMDT_AGENT_PRODUCT_LINK
               WHERE V_PLAN_CODE = 'BGTL001'
               AND V_STATUS = 'A'
              )

                 
              
select *
from ammt_agent_lob WHERE V_STATUS = 'A'
AND V_LINE_OF_BUSINESS = 'LOB003'
