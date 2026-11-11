-- no athletic
select spriden_id, rpratrm_fund_code, rpratrm_term_code, rpratrm_paid_amt
from rpratrm
join rfrbase on rfrbase_fund_code = rpratrm_fund_code
join spriden on spriden_pidm = rpratrm_pidm and spriden_change_ind is null
where rpratrm_term_code in ('202710', '202720')
and rfrbase_ftyp_code in ('RB-S', 'RM-G', 'RM-S')
and rpratrm_fund_code not like 'Z%'
and rpratrm_paid_amt > 0
;

-- only athletic
select spriden_id, rpratrm_fund_code, rpratrm_term_code, rpratrm_paid_amt
from rpratrm
join rfrbase on rfrbase_fund_code = rpratrm_fund_code
join spriden on spriden_pidm = rpratrm_pidm and spriden_change_ind is null
-- where rpratrm_term_code in ('202610', '202620')
where rpratrm_term_code in ('202610', '202620')
and rfrbase_ftyp_code in ('RB-S', 'RM-G', 'RM-S')
and rpratrm_fund_code like 'Z%'
and rpratrm_paid_amt > 0
;