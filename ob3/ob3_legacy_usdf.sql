-- select student_level, count(*) from (
with stu as (
    select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_levl_code as student_level,
        a.sgbstdn_program_1 as program_code,
        a.sgbstdn_degc_code_1 as degree_code
    from sgbstdn a
    where a.sgbstdn_stst_code in ('AS', 'IL')
    and a.sgbstdn_styp_code <> '4' -- exclude 1818
    and a.sgbstdn_program_1 not in ('NODE04', 'NODE19', 'NODEAI')
    and a.sgbstdn_levl_code in ('UG', 'GR', 'PL', 'PM')
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_term_code_eff <= :term
        and z.sgbstdn_pidm = a.sgbstdn_pidm
    )
), hours as (
    select distinct sfrstcr_pidm as pidm
    from sfrstcr
    where sfrstcr_term_code in ('202620', '202700')
    and sfrstcr_bill_hr > 0
), legacy_yn as (
    select rcrlds4_pidm as pidm, rcrlds4_ln_limit_except_flg as flg
    from rcrlds4
    where rcrlds4_aidy_code = '2627'
    and rcrlds4_infc_code = 'EDE'
    and rcrlds4_curr_rec_ind = 'Y'
)
select 
    robnyud_value_196,
    robnyud_value_197,
    robnyud_value_198,
    robnyud_value_199,
    robnyud_value_200,
    a.pidm,
    s.spriden_id as student_id,
    -- s.spriden_first_name || ' ' || s.spriden_last_name as name,
    l.flg as legacy_rcrlds4,
    'Y' as legacy,
    a.student_level,
    a.program_code,
    a.degree_code
from robnyud
join stu a on a.pidm = robnyud_pidm
join hours b on b.pidm = a.pidm
join spriden s on s.spriden_pidm = a.pidm and s.spriden_change_ind is null
left join legacy_yn l on l.pidm = a.pidm
where (
    a.student_level = 'UG' 
    and exists ( -- paid between first term with level and :term
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
) or (
    a.student_level <> 'UG'
    and exists ( -- paid between first term with program and :term
        select 1
        from rpratrm r
        inner join rfrbase b on b.rfrbase_fund_code = r.rpratrm_fund_code
        where r.rpratrm_pidm = a.pidm
        and r.rpratrm_term_code between (
            select min(z.sgbstdn_term_code_eff)
            from sgbstdn z
            where z.sgbstdn_pidm = a.pidm
            and z.sgbstdn_program_1 = a.program_code
            and z.sgbstdn_stst_code in ('AS', 'IL')
        ) and :term
        and b.rfrbase_fsrc_code = 'FEDR'
        and b.rfrbase_ftyp_code = 'LOAN'
        and r.rpratrm_paid_amt > 0
    )
)

;
-- UDPATE SCRIPT
update (
    with stu as (
        select
            a.sgbstdn_pidm as pidm,
            a.sgbstdn_levl_code as student_level,
            a.sgbstdn_program_1 as program_code,
            a.sgbstdn_degc_code_1 as degree_code
        from sgbstdn a
        where a.sgbstdn_stst_code in ('AS', 'IL')
        and a.sgbstdn_styp_code <> '4' -- exclude 1818
        and a.sgbstdn_program_1 not in ('NODE04', 'NODE19', 'NODEAI')
        and a.sgbstdn_levl_code in ('UG', 'GR', 'PL', 'PM')
        and a.sgbstdn_term_code_eff = (
            select max(z.sgbstdn_term_code_eff)
            from sgbstdn z
            where z.sgbstdn_term_code_eff <= :term
            and z.sgbstdn_pidm = a.sgbstdn_pidm
        )
    ), hours as (
        select distinct sfrstcr_pidm as pidm
        from sfrstcr
        where sfrstcr_term_code in ('202620', '202700')
        and sfrstcr_bill_hr > 0
    ), legacy_yn as (
        select rcrlds4_pidm as pidm, rcrlds4_ln_limit_except_flg as flg
        from rcrlds4
        where rcrlds4_aidy_code = '2627'
        and rcrlds4_infc_code = 'EDE'
        and rcrlds4_curr_rec_ind = 'Y'
    )
    select 
        robnyud_value_196,
        robnyud_value_197,
        robnyud_value_198,
        robnyud_value_199,
        robnyud_value_200,
        a.pidm,
        s.spriden_id as student_id,
        -- s.spriden_first_name || ' ' || s.spriden_last_name as name,
        l.flg as legacy_rcrlds4,
        'Y' as legacy,
        a.student_level,
        a.program_code,
        a.degree_code
    from robnyud
    join stu a on a.pidm = robnyud_pidm
    join hours b on b.pidm = a.pidm
    join spriden s on s.spriden_pidm = a.pidm and s.spriden_change_ind is null
    left join legacy_yn l on l.pidm = a.pidm
    where (
        a.student_level = 'UG' 
        and exists ( -- paid between first term with level and :term
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
    ) or (
        a.student_level <> 'UG'
        and exists ( -- paid between first term with program and :term
            select 1
            from rpratrm r
            inner join rfrbase b on b.rfrbase_fund_code = r.rpratrm_fund_code
            where r.rpratrm_pidm = a.pidm
            and r.rpratrm_term_code between (
                select min(z.sgbstdn_term_code_eff)
                from sgbstdn z
                where z.sgbstdn_pidm = a.pidm
                and z.sgbstdn_program_1 = a.program_code
                and z.sgbstdn_stst_code in ('AS', 'IL')
            ) and :term
            and b.rfrbase_fsrc_code = 'FEDR'
            and b.rfrbase_ftyp_code = 'LOAN'
            and r.rpratrm_paid_amt > 0
        )
    )
)
set robnyud_value_196 = legacy_rcrlds4,
    robnyud_value_197 = legacy,
    robnyud_value_198 = student_level,
    robnyud_value_199 = program_code,
    robnyud_value_200 = degree_code
;

select robnyud_value_196,
    robnyud_value_197 ,
    robnyud_value_198 ,
    robnyud_value_199 ,
    robnyud_value_200 
from robnyud where robnyud_value_197 = 'Y';