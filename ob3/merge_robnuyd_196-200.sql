-- UPDATE ROBNYUD FIELDS 196-200 FOR LEGACY BORROWERS (OB3)
-- Written by SFS Justin DeKock 06/11/2026
merge into robnyud r
using (
    with term as (
        select '202700' as t from dual
    ), stu as (
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
            where z.sgbstdn_term_code_eff <= (select t from term)
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
        a.pidm,
        s.spriden_id as student_id,
        l.flg as legacy_rcrlds4,
        'Y' as legacy,
        a.student_level,
        a.program_code,
        a.degree_code
    from stu a
    join hours b on b.pidm = a.pidm
    join spriden s on s.spriden_pidm = a.pidm and s.spriden_change_ind is null
    left join legacy_yn l on l.pidm = a.pidm
    where (
        a.student_level = 'UG'
        and exists (
            select 1
            from rpratrm rp
            inner join rfrbase rb on rb.rfrbase_fund_code = rp.rpratrm_fund_code
            where rp.rpratrm_pidm = a.pidm
            and rp.rpratrm_term_code between (
                select min(z.sgbstdn_term_code_eff)
                from sgbstdn z
                where z.sgbstdn_pidm = a.pidm
                and z.sgbstdn_levl_code = a.student_level
                and z.sgbstdn_stst_code in ('AS', 'IL')
            ) and (select t from term)
            and rb.rfrbase_fsrc_code = 'FEDR'
            and rb.rfrbase_ftyp_code = 'LOAN'
            and rp.rpratrm_paid_amt > 0
        )
    ) or (
        a.student_level <> 'UG'
        and exists (
            select 1
            from rpratrm rp
            inner join rfrbase rb on rb.rfrbase_fund_code = rp.rpratrm_fund_code
            where rp.rpratrm_pidm = a.pidm
            and rp.rpratrm_term_code between (
                select min(z.sgbstdn_term_code_eff)
                from sgbstdn z
                where z.sgbstdn_pidm = a.pidm
                and z.sgbstdn_program_1 = a.program_code
                and z.sgbstdn_stst_code in ('AS', 'IL')
            ) and (select t from term)
            and rb.rfrbase_fsrc_code = 'FEDR'
            and rb.rfrbase_ftyp_code = 'LOAN'
            and rp.rpratrm_paid_amt > 0
        )
    )
) src on (src.pidm = r.robnyud_pidm)
when matched then 
update set
    r.robnyud_value_196 = src.legacy_rcrlds4,
    r.robnyud_value_197 = src.legacy,
    r.robnyud_value_198 = src.student_level,
    r.robnyud_value_199 = src.program_code,
    r.robnyud_value_200 = src.degree_code
;