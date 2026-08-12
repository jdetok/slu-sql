-- calculate time to degree for legacy purposes
-- assume fall start if it's a summer

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
        -- first term not matching legacy codes OR first term showing transfer
        -- ug uses levl and degc, others use majr and degc
        case a.sgbstdn_levl_code 
            when 'UG' then (
                select min(z.sgbstdn_term_code_eff)
                from sgbstdn z
                where z.sgbstdn_pidm = a.sgbstdn_pidm
                and z.sgbstdn_levl_code = a.sgbstdn_levl_code
                and z.sgbstdn_degc_code_1 = a.sgbstdn_degc_code_1
                and z.sgbstdn_term_code_eff >= nvl((
                    select max(y.sgbstdn_term_code_eff)
                    from sgbstdn y
                    where y.sgbstdn_pidm = a.sgbstdn_pidm
                    and y.sgbstdn_term_code_eff <= a.sgbstdn_term_code_eff
                    and (
                        not (
                            y.sgbstdn_levl_code = a.sgbstdn_levl_code
                            and y.sgbstdn_degc_code_1 = a.sgbstdn_degc_code_1
                        ) 
                        or y.sgbstdn_styp_code = 'T'
                    )
                ), '000000')
            ) else (
                select min(z.sgbstdn_term_code_eff)
                from sgbstdn z
                where z.sgbstdn_pidm = a.sgbstdn_pidm
                and z.sgbstdn_degc_code_1 = a.sgbstdn_degc_code_1
                and z.sgbstdn_majr_code_1 = a.sgbstdn_majr_code_1
                and z.sgbstdn_term_code_eff >= nvl((
                    select max(y.sgbstdn_term_code_eff)
                    from sgbstdn y
                    where y.sgbstdn_pidm = a.sgbstdn_pidm
                    and y.sgbstdn_term_code_eff <= a.sgbstdn_term_code_eff
                    and (
                        not (
                            y.sgbstdn_majr_code_1 = a.sgbstdn_majr_code_1
                            and y.sgbstdn_degc_code_1 = a.sgbstdn_degc_code_1
                        ) 
                        or y.sgbstdn_styp_code = 'T'
                    )
                ), '000000')
            )
        end as first_term
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
    s.spriden_id as student_id,
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
-- and spriden_id = '000416971' 
;

desc stvstyp;
select stvstyp_code, stvstyp_desc
from stvstyp
group by stvstyp_code, stvstyp_desc;
    
select sfrstcr_pidm as pidm, sfrstcr_term_code as term, sum(sfrstcr_bill_hr) as hrs from sfrstcr
where sfrstcr_bill_hr > 0
group by sfrstcr_pidm, sfrstcr_term_code;