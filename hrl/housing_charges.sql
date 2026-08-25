-- need the opposite as well (no housing charge, has 2)
select spriden_id as bid, tbraccd_term_code as term, rorstat_pgrp_code as pgrp, rprarsc_actual_amt as rsrc
from tbraccd
join rorstat on rorstat_pidm = tbraccd_pidm 
    and rorstat_aidy_code = substr(tbraccd_term_code, 3, 2) - 1 || substr(tbraccd_term_code, 3, 2)
join spriden on spriden_pidm = tbraccd_pidm and spriden_change_ind is null
join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
    and tbbdetc_type_ind = 'C'
    and tbbdetc_dcat_code = 'HOU'
join rorprst on rorprst_pidm = tbraccd_pidm 
    and rorprst_period = tbraccd_term_code
    and rorprst_xhs <> '2'
left join rprarsc on rprarsc_pidm = tbraccd_pidm 
    and rprarsc_term_code = tbraccd_term_code
    and rprarsc_arsc_code = 'RSLFAS'
where tbraccd_term_code = '202710'
and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
group by spriden_id, tbraccd_term_code, rorstat_pgrp_code, rprarsc_actual_amt
having sum(tbraccd_amount) > 0
;

select spriden_id as bid, rorprst_period as term, rorstat_pgrp_code as pgrp, rprarsc_actual_amt as rsrc
from rorprst
join rorstat on rorstat_pidm = rorprst_pidm 
    and rorstat_aidy_code = substr(rorprst_period, 3, 2) - 1 || substr(rorprst_period, 3, 2)
join spriden on spriden_pidm = rorprst_pidm and spriden_change_ind is null
left join rprarsc on rprarsc_pidm = rorprst_pidm 
    and rprarsc_term_code = rorprst_period
    and rprarsc_arsc_code = 'RSLFAS'
where rorprst_period = '202710'
and rorprst_xhs = '2'
and not exists (
    select 1
    from tbraccd 
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_type_ind = 'C'
        and tbbdetc_dcat_code = 'HOU'
    where tbraccd_pidm = rorprst_pidm
    and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
    and tbraccd_term_code = rorprst_period
    group by tbraccd_pidm, rorstat_pgrp_code, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)
order by rprarsc_actual_amt
;

-- PBI DYNAMIC TERM VERSIONS: 
-- need the opposite as well (no housing charge, has 2)
select spriden_id as bid, tbraccd_term_code as term, rorstat_pgrp_code as pgrp, rprarsc_actual_amt as rsrc
from tbraccd
join rorstat on rorstat_pidm = tbraccd_pidm 
    and rorstat_aidy_code = substr(tbraccd_term_code, 3, 2) - 1 || substr(tbraccd_term_code, 3, 2)
join spriden on spriden_pidm = tbraccd_pidm and spriden_change_ind is null
join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
    and tbbdetc_type_ind = 'C'
    and tbbdetc_dcat_code = 'HOU'
join rorprst on rorprst_pidm = tbraccd_pidm 
    and rorprst_period = tbraccd_term_code
    and rorprst_xhs <> '2'
left join rprarsc on rprarsc_pidm = tbraccd_pidm 
    and rprarsc_term_code = tbraccd_term_code
    and rprarsc_arsc_code = 'RSLFAS'
where tbraccd_term_code = '" & term & "'
and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
group by spriden_id, tbraccd_term_code, rorstat_pgrp_code, rprarsc_actual_amt
having sum(tbraccd_amount) > 0
;

select spriden_id as bid, rorprst_period as term, rorstat_pgrp_code as pgrp, rprarsc_actual_amt as rsrc
from rorprst
join rorstat on rorstat_pidm = rorprst_pidm 
    and rorstat_aidy_code = substr(rorprst_period, 3, 2) - 1 || substr(rorprst_period, 3, 2)
join spriden on spriden_pidm = rorprst_pidm and spriden_change_ind is null
left join rprarsc on rprarsc_pidm = rorprst_pidm 
    and rprarsc_term_code = rorprst_period
    and rprarsc_arsc_code = 'RSLFAS'
where rorprst_period = '" & term & "'
and rorprst_xhs = '2'
and not exists (
    select 1
    from tbraccd 
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_type_ind = 'C'
        and tbbdetc_dcat_code = 'HOU'
    where tbraccd_pidm = rorprst_pidm
    and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
    and tbraccd_term_code = rorprst_period
    group by tbraccd_pidm, rorstat_pgrp_code, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)
order by rprarsc_actual_amt
;


