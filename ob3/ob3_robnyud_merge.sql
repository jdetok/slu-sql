-- use most current legacy logic from time to degree query for all robnyud legacy fields
merge into robnyud r using (
    with term as (
        select '202700' as t from dual
    ), stu as (
        select
            a.sgbstdn_pidm as pidm,
            a.sgbstdn_levl_code as student_level,
            a.sgbstdn_majr_code_1 as major_code,
            a.sgbstdn_degc_code_1 as degree_code,
            m.stvmajr_cipc_code as cipc_code,
            ( 
                select min(z.sgbstdn_term_code_eff)
                from sgbstdn z
                join stvmajr zm on zm.stvmajr_code = z.sgbstdn_majr_code_1
                where z.sgbstdn_pidm = a.sgbstdn_pidm
                and z.sgbstdn_term_code_eff <= a.sgbstdn_term_code_eff
                and (
                    (
                        a.sgbstdn_levl_code = 'UG'
                        and (
                            (a.sgbstdn_degc_code_1 like 'B%' and z.sgbstdn_degc_code_1 like 'B%')
                            or (a.sgbstdn_degc_code_1 = 'CERT' and z.sgbstdn_degc_code_1 = 'CERT')
                        )
                    ) or (
                        a.sgbstdn_levl_code <> 'UG'
                        and zm.stvmajr_cipc_code = m.stvmajr_cipc_code
                    )
                )
                -- min term >= max term with new student type not matching current program
                and z.sgbstdn_term_code_eff >= nvl((
                    select max(y.sgbstdn_term_code_eff)
                    from sgbstdn y
                    where y.sgbstdn_pidm = a.sgbstdn_pidm
                    and y.sgbstdn_term_code_eff <= a.sgbstdn_term_code_eff
                    and y.sgbstdn_styp_code in ('T', 'P', 'G', 'R')
                    and (
                    not (
                            (
                                a.sgbstdn_levl_code = 'UG'
                                and (
                                    (a.sgbstdn_degc_code_1 like 'B%' and y.sgbstdn_degc_code_1 like 'B%')
                                    or (a.sgbstdn_degc_code_1 = 'CERT' and y.sgbstdn_degc_code_1 = 'CERT')
                                )
                            ) or (
                                a.sgbstdn_levl_code <> 'UG'
                                and zm.stvmajr_cipc_code = m.stvmajr_cipc_code
                            )
                        )
                    )
                ), '000000')
                -- min term > max term with a closed record
                and z.sgbstdn_term_code_eff > nvl((
                    select max(y.sgbstdn_term_code_eff)
                    from sgbstdn y
                    where y.sgbstdn_pidm = a.sgbstdn_pidm
                    and y.sgbstdn_term_code_eff <= a.sgbstdn_term_code_eff
                    and y.sgbstdn_stst_code in (select stvstst_code from stvstst where stvstst_reg_ind = 'N')
                ), '000000')
            ) as first_term
        from sgbstdn a
        join stvmajr m on m.stvmajr_code = a.sgbstdn_majr_code_1
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
    ), awards as (
        select rp.rpratrm_pidm as pidm, rp.rpratrm_term_code as term
        from rpratrm rp
        inner join rfrbase rb on rb.rfrbase_fund_code = rp.rpratrm_fund_code
        where rb.rfrbase_fsrc_code = 'FEDR'
        and rb.rfrbase_ftyp_code = 'LOAN'
        and rp.rpratrm_paid_amt > 0
    ), terms_hours as (
        select sfrstcr_pidm as pidm, sfrstcr_term_code as term, sum(sfrstcr_bill_hr) as hrs from sfrstcr
        where sfrstcr_bill_hr > 0
        and substr(sfrstcr_term_code, 5, 2) <> '00'
        group by sfrstcr_pidm, sfrstcr_term_code
    ), legacy_yn as (
        select rcrlds4_pidm as pidm, rcrlds4_ln_limit_except_flg as flg
        from rcrlds4
        where rcrlds4_aidy_code = '2627'
        and rcrlds4_infc_code = 'EDE'
        and rcrlds4_curr_rec_ind = 'Y'
    )
    select
        a.pidm,
        s.spriden_id as bid,
        l.flg as legacy_rcrlds4,
        'Y' as legacy,
        a.student_level,
        a.major_code,
        a.degree_code, 
        a.cipc_code
    from stu a
    join hours b on b.pidm = a.pidm
    left join legacy_yn l on l.pidm = a.pidm
    join spriden s on s.spriden_pidm = a.pidm and s.spriden_change_ind is null
    where exists (
        select 1 from awards r
        where r.pidm = a.pidm
        and r.term between a.first_term and (select t from term)

    )
) src on (src.pidm = r.robnyud_pidm)
when matched then update set
    r.robnyud_value_193 = src.cipc_code,
    r.robnyud_value_196 = src.legacy_rcrlds4,
    r.robnyud_value_197 = src.legacy,
    r.robnyud_value_198 = src.student_level,
    r.robnyud_value_199 = src.major_code,
    r.robnyud_value_200 = src.degree_code
;