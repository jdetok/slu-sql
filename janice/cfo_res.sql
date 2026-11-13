-- cfo housing scholarships/residence halls request
-- for non-athletic run, do not like 'Z%', for only athletic, do like 'Z%'
select spriden_id, rpratrm_fund_code, rfrbase_fund_title, rpratrm_term_code, rpratrm_paid_amt, t.dtl_codes, t.dtl_descs
from rpratrm
join rfrbase on rfrbase_fund_code = rpratrm_fund_code
join spriden on spriden_pidm = rpratrm_pidm and spriden_change_ind is null
left join (
    select
        tbraccd_pidm as pidm, 
        tbraccd_term_code as period,
        listagg(distinct tbraccd_detail_code, ', ') within group (order by tbraccd_detail_code) as dtl_codes,
        listagg(distinct tbbdetc_desc, ', ') within group (order by tbbdetc_desc) as dtl_descs
    from tbraccd
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_dcat_code = 'HOU' and tbbdetc_detail_code <> 'RLAF'
    group by tbraccd_pidm, tbraccd_term_code
) t on t.pidm = rpratrm_pidm and t.period = rpratrm_term_code
where rpratrm_term_code in ('202610', '202620')
and rfrbase_ftyp_code in ('RB-S', 'RM-G', 'RM-S')
-- and rpratrm_fund_code like 'Z%'
and rpratrm_fund_code not like 'Z%'
and rpratrm_paid_amt > 0
;
select * from rfrbase;