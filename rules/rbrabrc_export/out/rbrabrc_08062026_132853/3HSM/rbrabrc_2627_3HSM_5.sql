select tbraccd_pidm
from tbraccd
join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
    and tbbdetc_type_ind = 'C'
    and tbbdetc_dcat_code = 'HOU'
where tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
and tbraccd_term_code = :period
and tbraccd_pidm = :pidm
group by tbraccd_pidm, tbraccd_term_code
having sum(tbraccd_amount) > 0
;

select count(distinct rbrapbc_pidm) from rbrapbc where rbrapbc_run_name = 'ACTUAL' and rbrapbc_period = '202710' and rbrapbc_pbcp_code = '3HSM';

select roralgs_amt
from (
    select tbraccd_pidm, a.sgbstdn_levl_code
    from tbraccd
    join sgbstdn a on a.sgbstdn_pidm = tbraccd_pidm
        and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
        and a.sgbstdn_levl_code in ('UG', 'GR', 'PL', 'PM')
        and a.sgbstdn_term_code_eff = (
            select max(z.sgbstdn_term_code_eff)
            from sgbstdn z
            where z.sgbstdn_pidm = a.sgbstdn_pidm
            and z.sgbstdn_term_code_eff <= :period
        )
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_type_ind = 'C'
        and tbbdetc_dcat_code = 'HOU'
    where tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
    and tbraccd_term_code = :period
    and tbraccd_pidm = :pidm
    group by tbraccd_pidm, a.sgbstdn_levl_code, tbraccd_term_code
    having sum(tbraccd_amount) > 0
) a
join roralgs on roralgs_aidy_code = :aidy
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_2 is null
    and roralgs_key_4 = '3HSM'
    and roralgs_key_5 = a.sgbstdn_levl_code
;
select * from roralgs where roralgs_key_4 = '3HSM';