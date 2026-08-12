select 
    s.spriden_id as student_id,
    s.spriden_last_name || ', ' || s.spriden_first_name as name,
    e.email_slu,
    e.email_pers,
    a.sgbstdn_levl_code as student_level,
    a.sgbstdn_program_1 as program_code,
    p.smrprle_program_desc as program,
    a.sgbstdn_term_code_eff as in_prog_since_term,
    t.stvterm_desc as in_prog_since_term_desc
from sgbstdn a
inner join spriden s on s.spriden_pidm = a.sgbstdn_pidm 
    and s.spriden_change_ind is null
inner join gobintl g on g.gobintl_pidm = a.sgbstdn_pidm
    and g.gobintl_natn_code_legal = 'US' -- exclude international
inner join smrprle p on p.smrprle_program = a.sgbstdn_program_1
inner join stvterm t on t.stvterm_code = a.sgbstdn_term_code_eff
inner join (
    select goremal_pidm, email_slu, email_pers from (
        select goremal_pidm, goremal_emal_code, goremal_email_address
        from goremal
        where goremal_status_ind = 'A'
    ) 
    pivot (
        max(goremal_email_address)
        for goremal_emal_code in ('SLU' as email_slu, 'PERS' as email_pers)
    )
) e on e.goremal_pidm = a.sgbstdn_pidm
where a.sgbstdn_stst_code in ('AS', 'IL')
and a.sgbstdn_styp_code <> '4' -- exclude 1818
and a.sgbstdn_term_code_eff = (
    select max(sgbstdn_term_code_eff)
    from sgbstdn
    where sgbstdn_term_code_eff <= :term
    and sgbstdn_pidm = a.sgbstdn_pidm
)
and not exists (
    select 1
    from rpratrm r
    inner join rfrbase b on b.rfrbase_fund_code = r.rpratrm_fund_code
    where r.rpratrm_pidm = a.sgbstdn_pidm
    and r.rpratrm_term_code between a.sgbstdn_term_code_eff and :term
    and b.rfrbase_fsrc_code = 'FEDR'
    and b.rfrbase_ftyp_code = 'LOAN'
)
and not exists (
    select 1
    from shrdgmr
    where shrdgmr_pidm = a.sgbstdn_pidm
    and shrdgmr_term_code_grad in ('202620', '202700')
);
