--UG PL ENROLLED PART TIME 
with stu as (
    select 
        x.sgbstdn_pidm as pidm,
        x.sgbstdn_levl_code,
        x.sgbstdn_camp_code,
        x.sgbstdn_coll_code_1,
        nvl(rokmisc.f_calc_stud_bill_hrs(:period, x.sgbstdn_pidm, 'N'), 0) as hrs
    from sgbstdn x
    where x.sgbstdn_stst_code in ('AS','IL','P1')
    and x.sgbstdn_levl_code = 'UG'
    and x.sgbstdn_camp_code = 'FR'
    and x.sgbstdn_coll_code_1 = 'PL'
    and x.sgbstdn_term_code_eff = (
        select max(y.sgbstdn_term_code_eff)
        from sgbstdn y
        where y.sgbstdn_pidm = x.sgbstdn_pidm
        and y.sgbstdn_term_code_eff <= :period
    )
)
select roralgs_amt * hrs
from stu
inner join roralgs 
    on roralgs_aidy_code = :aidy
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = sgbstdn_levl_code
    and roralgs_key_6 = sgbstdn_camp_code
    and roralgs_key_7 = sgbstdn_coll_code_1
    and roralgs_key_12 = 'PT'
where hrs between 1 and 11
-- and pidm = :pidm