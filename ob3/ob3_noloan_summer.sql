with stu as (
    select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_levl_code as student_level,
        a.sgbstdn_program_1 as program_code,
        a.sgbstdn_term_code_eff as in_prog_since_term,
        rokmisc.f_calc_stud_credit_hrs(:term, a.sgbstdn_pidm) as hrs
    from sgbstdn a
    where a.sgbstdn_stst_code in ('AS', 'IL')
    and a.sgbstdn_styp_code <> '4' -- exclude 1818
    and a.sgbstdn_program_1 not in ('NODE04', 'NODE19', 'NODEAI')
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_term_code_eff <= :term
        and z.sgbstdn_pidm = a.sgbstdn_pidm
    )
), emails as (
    select goremal_pidm, email_slu, email_pers from (
        select goremal_pidm, goremal_emal_code, goremal_email_address
        from goremal
        where goremal_status_ind = 'A'
    ) 
    pivot (
        max(goremal_email_address)
        for goremal_emal_code in ('SLU' as email_slu, 'PERS' as email_pers)
    )
)
select 
    s.spriden_id as student_id,
    s.spriden_first_name || ' ' || s.spriden_last_name as name,
    e.email_slu,
    e.email_pers,
    a.student_level,
    a.program_code,
    a.in_prog_since_term,
    a.hrs
from stu a
inner join spriden s on s.spriden_pidm = a.pidm and s.spriden_change_ind is null
left join emails e on e.goremal_pidm = a.pidm
where a.hrs > 0
and not exists (
    select 1
    from rpratrm r
    inner join rfrbase b on b.rfrbase_fund_code = r.rpratrm_fund_code
    where r.rpratrm_pidm = a.pidm
    and r.rpratrm_term_code between (
        select min(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.pidm
        and z.sgbstdn_levl_code = a.student_level
        and z.sgbstdn_stst_code in ('AS', 'IL')
    ) and :term
    and b.rfrbase_fsrc_code = 'FEDR'
    and b.rfrbase_ftyp_code = 'LOAN'
    and r.rpratrm_paid_amt > 0
)
;
-- and not exists (
--     select 1
--     from rpratrm r
--     inner join rfrbase b on b.rfrbase_fund_code = r.rpratrm_fund_code
--     where r.rpratrm_pidm = a.sgbstdn_pidm
--     and r.rpratrm_term_code between a.sgbstdn_term_code_eff and :term
--     and b.rfrbase_fsrc_code = 'FEDR'
--     and b.rfrbase_ftyp_code = 'LOAN'
-- )
-- and not exists (
--     select 1
--     from shrdgmr
--     where shrdgmr_pidm = a.sgbstdn_pidm
--     and shrdgmr_term_code_grad in ('202620', '202700')
-- )