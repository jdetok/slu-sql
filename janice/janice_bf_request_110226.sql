select tbracct_a_fund_code,  
    listagg(rfrbase_detail_code, ',') within group (order by tbracct_a_fund_code) as detail_codes,
    listagg(rfrbase_fund_code, ',') within group (order by tbracct_a_fund_code) as finance_funds
from rfrbase
join tbracct on tbracct_detail_code = rfrbase_detail_code
where tbracct_a_fund_code in ('128819' ,'129002', '151104', '321482', '190100')
and rfrbase_active_ind = 'Y'
and exists (
    select 1 from rpratrm
    where rpratrm_fund_code = rfrbase_fund_code
    and rpratrm_term_code in ('202700')
    and rpratrm_paid_amt > 0
)
group by tbracct_a_fund_code
;

