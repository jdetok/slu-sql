-- think this is working as of 7/28/2026å
-- calculate time to degree for legacy purposes
-- assume fall start if it's a summer
select * from (
with term as (
    select '202700' as t from dual
), stu as (
    select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_levl_code as student_level,
        a.sgbstdn_majr_code_1 as major_code,
        a.sgbstdn_degc_code_1 as degree_code,
        a.sgbstdn_program_1 as prog_code,
        m.stvmajr_cipc_code as cipc_code,
        (   -- mininum term in current academic study
            -- UG changing to different bachelor degree doesn't constitute change. Example BS-BA is considered same
            -- minimum term less than current sgbstdn term, > max closed term, >= max new student term
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
                and  (
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
)
select
    a.pidm,
    s.spriden_id as bid,
    a.student_level,
    a.major_code,
    a.degree_code, 
    a.prog_code,
    a.cipc_code,
    a.first_term,
    (select count(term) from terms_hours where pidm = a.pidm and term between a.first_term and (select t from term)) as terms_enrolled
from stu a
join hours b on b.pidm = a.pidm
join spriden s on s.spriden_pidm = a.pidm and s.spriden_change_ind is null
where exists (
    select 1 from awards r
    where r.pidm = a.pidm
    and r.term between a.first_term and (select t from term)
)
)
order by first_term
-- )
;

-- 201320 before changes, expect 201710 after
select robnyud_pidm, robnyud_value_194, robnyud_value_195
from robnyud 
where robnyud_value_194 is not null
or robnyud_value_195 is not null
order by robnyud_value_194 ;

update robnyud set robnyud_value_194 = null, robnyud_value_195 = null
where robnyud_value_194 is not null or robnyud_value_195 is not null;

