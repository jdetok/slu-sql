-- select distinct bid from (
select 
    spriden_id as bid,
    rpratrm_aidy_code as aidy,
    robnyud_value_194 as start_term,
    robnyud_value_195 as end_term,
    rpratrm_term_code as award_term,
    rpratrm_fund_code as fund,
    rpratrm_accept_amt as acpt,
    rpratrm_paid_amt as paid
from rpratrm
join spriden on spriden_pidm = rpratrm_pidm and spriden_change_ind is null
left join robnyud on robnyud_pidm = rpratrm_pidm
where rpratrm_fund_code in ('DLPL', 'DLGL') 
and rpratrm_aidy_code = '2627'
and rpratrm_awst_code = 'ACPT'
and rpratrm_term_code > robnyud_value_195
-- )
;

select 
    spriden_id as bid,
    robnyud_value_194 as start_term,
    robnyud_value_195 as end_term,
    rpratrm_term_code as award_term,
    rpratrm_fund_code as fund,
    rpratrm_accept_amt as acpt,
    rpratrm_offer_amt as ofrd,
    rpratrm_paid_amt as paid
from robnyud
join spriden on spriden_pidm = robnyud_pidm and spriden_change_ind is null
left join rpratrm on rpratrm_pidm = robnyud_pidm
    and rpratrm_aidy_code = '2627'
    and rpratrm_fund_code in ('DLPL', 'DLGL')
where robnyud_value_197 = 'Y'
and robnyud_value_195 < '202710'
;