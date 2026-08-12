with crnt_month as (
    select cast(to_char(sysdate, 'MM') as int) as m from dual
),
crnt_aidy as (
    select case 
        when m between 5 and 8 then to_char(sysdate-365, 'YY') || to_char(sysdate, 'YY')
        else to_char(sysdate, 'YY') || to_char(sysdate+365, 'YY')
    end as aidy
    from crnt_month
    union all
    select case 
        when m between 5 and 8 then to_char(sysdate, 'YY') || to_char(sysdate+365, 'YY')
        else null
    end as aidy
    from crnt_month
), stu as (
    select a.sgbstdn_pidm as pidm, 
        a.sgbstdn_coll_code_1 as coll_code,
        c.stvcoll_desc as college,
        a.sgbstdn_program_1 as prog_code,
        b.smrprle_program_desc as program,
        a.sgbstdn_majr_code_1 as major_code,
        d.stvmajr_desc as major,
        a.sgbstdn_majr_code_minr_1 as minor_code,
        e.stvmajr_desc as minor
    from sgbstdn a
    inner join smrprle b on b.smrprle_program = a.sgbstdn_program_1
    inner join stvcoll c on c.stvcoll_code = a.sgbstdn_coll_code_1
    inner join stvmajr d on d.stvmajr_code = a.sgbstdn_majr_code_1
    left join stvmajr e on e.stvmajr_code = a.sgbstdn_majr_code_minr_1
    where a.sgbstdn_term_code_eff = (
        select max(sgbstdn_term_code_eff)
        from sgbstdn
        where sgbstdn_pidm = a.sgbstdn_pidm
    )
), gross_need as (
    select
        pidm, aidy, awarded, 
        nvl(cast(rnkneed.f_calc_gross_need(pidm, aidy) as int), 0) as gross,
        nvl(cast(rnkneed.f_calc_efc(pidm, aidy) as int), 0) as efc,
        nvl(cast(rnkneed.f_calc_oth_resource(pidm, aidy) as int), 0) as resc
    from (
        select 
            a.rprawrd_pidm as pidm, a.rprawrd_aidy_code as aidy,
            nvl(sum(a.rprawrd_offer_amt), 0) as awarded
        from rprawrd a
        where a.rprawrd_aidy_code in (select aidy from crnt_aidy)
        and a.rprawrd_offer_amt > 0
        group by a.rprawrd_pidm, a.rprawrd_aidy_code
    ) a
), non_need as (
    select pidm, aidy, efc, gross, awarded, resc, nvl(aid_no_need, 0) as aid_no_need
    from gross_need
    left join (
        select rprawrd_pidm, rprawrd_aidy_code, 
            sum(rprawrd_offer_amt) as aid_no_need
        from rprawrd
        join rfraspc 
            on rfraspc_fund_code = rprawrd_fund_code
            and rfraspc_aidy_code = rprawrd_aidy_code
        where rfraspc_reduce_need_ind = 'N'
        group by rprawrd_pidm, rprawrd_aidy_code
    ) b on rprawrd_pidm = pidm and rprawrd_aidy_code = aidy
), unmet_need as (
    select 
        pidm, aidy, efc, resc, aid_no_need,
        case 
            when efc = 0 then (gross - awarded)
            when efc < aid_no_need then (gross - (awarded) + efc) 
            else (gross - (awarded - aid_no_need))
        end as amt
    from non_need
), dataset as (
    select 
        a.rpratrm_pidm as pidm,
        b.spriden_id as id, 
        (b.spriden_last_name || ', ' || b.spriden_first_name) as name, 
        g.goremal_email_address as email,
        a.rpratrm_aidy_code as aidy,
        d.amt as unmet_need,
        d.efc,
        case when r.rcrapp1_verification_msg = '1' then 'Y' else 'N' end as verif_msg,
        case when t.rrrareq_pidm is not null then t.rrrareq_trst_code else 'NA' end as clactn_status,
        case when c.rjrsear_pidm is not null then 'Y' else 'N' end as has_rjrsear_rec, 
        nvl(c.rjrsear_place_cde, '-') as dept,
        a.rpratrm_term_code as period,
        s.coll_code,
        s.college,
        s.prog_code,
        s.program,
        s.major_code,
        s.major,
        s.minor_code,
        s.minor,
        a.rpratrm_fund_code as fund,
        a.rpratrm_awst_code as fws_status,
        nvl(a.rpratrm_offer_amt, 0) as ofrd,
        nvl(a.rpratrm_accept_amt, 0) as acpt,
        nvl(a.rpratrm_paid_amt, 0) as paid,
        to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') as lastrun
    from faismgr.rpratrm a
    inner join saturn.spriden b 
        on b.spriden_pidm = a.rpratrm_pidm and b.spriden_change_ind is null
    inner join goremal g on g.goremal_pidm = a.rpratrm_pidm
        and g.goremal_emal_code = 'SLU'
        and g.goremal_status_ind = 'A'
    inner join stu s on s.pidm = a.rpratrm_pidm
    inner join unmet_need d on d.pidm = a.rpratrm_pidm and d.aidy = a.rpratrm_aidy_code
    left join faismgr.rjrsear c on c.rjrsear_pidm = a.rpratrm_pidm  
        and c.rjrsear_aidy_code = a.rpratrm_aidy_code
    left Join faismgr.rcrapp1 r 
        on r.rcrapp1_pidm = a.rpratrm_pidm 
        and r.rcrapp1_aidy_code = a.rpratrm_aidy_code
        and r.rcrapp1_infc_code = 'EDE'
        and r.rcrapp1_curr_rec_ind = 'Y'
        and r.rcrapp1_verification_msg = '1'
    left join faismgr.rrrareq t
        on t.rrrareq_pidm = a.rpratrm_pidm
        and t.rrrareq_aidy_code = a.rpratrm_aidy_code
        and t.rrrareq_treq_code = 'CLACTN'
    where a.rpratrm_aidy_code in (select aidy from crnt_aidy)
    and a.rpratrm_fund_code = 'FWS'
    -- and spriden_id = ''
)
select * from dataset;

desc rnkneed;

