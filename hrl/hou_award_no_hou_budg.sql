select 
    spriden_id as bid, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    rpratrm_term_code as term,
    rpratrm_fund_code as fund, 
    rpratrm_awst_code as awst,
    rpratrm_accept_amt as acpt
from rpratrm
join rfrbase on rfrbase_fund_code = rpratrm_fund_code
    and rfrbase_ftyp_code in ('RM-S', 'RM-G')
join rorprst on rorprst_pidm = rpratrm_pidm 
    and rorprst_period = rpratrm_term_code
    and rorprst_xhs <> '2'
join spriden on spriden_pidm = rpratrm_pidm and spriden_change_ind is null
where rpratrm_term_code = '" & term & "'
and rpratrm_accept_amt > 0


;
select rfrbase_ftyp_code
from rfrbase
where rfrbase_ftyp_code in ('RM-S', 'RM-G')
group by rfrbase_ftyp_code;
