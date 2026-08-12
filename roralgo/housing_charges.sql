-- need the opposite as well (no housing charge, has 2)
select spriden_id as bid, tbraccd_term_code as term, rprarsc_actual_amt as rsrc
from tbraccd
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
group by spriden_id, tbraccd_term_code, rprarsc_actual_amt
having sum(tbraccd_amount) > 0
;

select spriden_id as bid, rorprst_period as term, rprarsc_actual_amt as rsrc
from rorprst
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
    group by tbraccd_pidm, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)
order by rprarsc_actual_amt
;



