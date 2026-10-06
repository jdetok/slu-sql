select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    rprawrd_aidy_code as aidy,
    rprawrd_fund_code as fund,
    rfrbase_fund_title as title,
    rfrbase_fsrc_code as fsrc,
    rfrbase_ftyp_code as ftyp,
    rprawrd_accept_amt as acpt,
    rprawrd_paid_amt as paid
from rprawrd
join rfrbase on rfrbase_fund_code = rprawrd_fund_code
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
where rfrbase_ftyp_code in ('RB-S', 'RM-G', 'RM-S', 'BD-S', 'BD-G')
and rprawrd_aidy_code = '2627'
and rprawrd_awst_code = 'ACPT'
and rprawrd_paid_amt > 0
;
select * from rfrbase;