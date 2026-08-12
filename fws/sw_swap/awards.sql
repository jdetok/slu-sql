select 
    bid, name, aidy, awst,
    acpt_yr,
    paid_yr,
    nvl(fall_acpt, 0) as fall_acpt,
    nvl(fall_paid, 0) as fall_paid,
    nvl(spr_acpt, 0)  as spr_acpt,
    nvl(spr_paid, 0)  as spr_paid from (
    select 
        b.spriden_id as bid,
        b.spriden_last_name || ', ' || b.spriden_first_name as name,
        c.rprawrd_aidy_code as aidy,
        a.rpratrm_term_code as term,
        a.rpratrm_awst_code as awst,
        nvl(a.rpratrm_accept_amt, 0) as acpt,
        nvl(a.rpratrm_paid_amt, 0) as paid,
        nvl(c.rprawrd_accept_amt, 0) as acpt_yr,
        nvl(c.rprawrd_paid_amt, 0) as paid_yr
    from faismgr.rpratrm a
    inner join saturn.spriden b
        on b.spriden_pidm = a.rpratrm_pidm
    inner join faismgr.rprawrd c
        on c.rprawrd_pidm = a.rpratrm_pidm
        and c.rprawrd_aidy_code = a.rpratrm_aidy_code
        and c.rprawrd_fund_code = a.rpratrm_fund_code
    where b.spriden_change_ind is null
    and a.rpratrm_fund_code = 'FWS'
    and a.rpratrm_term_code in ('202610', '202620')
)
pivot (
    sum(acpt) as acpt, 
    sum(paid) as paid 
    for term in ('202610' as fall, '202620' as spr)
)
;

-- VERSION FOR ALTERYX
-- bind variables don't work with pivot, but the alteryx dynamic input lets me replace the strings before sending the query
-- so the job defines text variables and feeds them to the dynamic input - the 'term1' and 'term2' strings are replaced
select 
    bid, name, aidy, awst,
    acpt_yr,
    paid_yr,
    nvl(fall_acpt, 0) as fall_acpt,
    nvl(fall_paid, 0) as fall_paid,
    nvl(spr_acpt, 0)  as spr_acpt,
    nvl(spr_paid, 0)  as spr_paid from (
    select 
        b.spriden_id as bid,
        b.spriden_last_name || ', ' || b.spriden_first_name as name,
        c.rprawrd_aidy_code as aidy,
        a.rpratrm_term_code as term,
        a.rpratrm_awst_code as awst,
        nvl(a.rpratrm_accept_amt, 0) as acpt,
        nvl(a.rpratrm_paid_amt, 0) as paid,
        nvl(c.rprawrd_accept_amt, 0) as acpt_yr,
        nvl(c.rprawrd_paid_amt, 0) as paid_yr
    from faismgr.rpratrm a
    inner join saturn.spriden b
        on b.spriden_pidm = a.rpratrm_pidm
    inner join faismgr.rprawrd c
        on c.rprawrd_pidm = a.rpratrm_pidm
        and c.rprawrd_aidy_code = a.rpratrm_aidy_code
        and c.rprawrd_fund_code = a.rpratrm_fund_code
    where b.spriden_change_ind is null
    and a.rpratrm_fund_code = 'FWS'
    and a.rpratrm_term_code in ('term1', 'term2')
)
pivot (
    sum(acpt) as acpt, 
    sum(paid) as paid 
    for term in ('term1' as fall, 'term2' as spr)
)
;

-- testing with coa in this query, not worth it
with crnt_aidy as (
    select '2526' as aidy from dual
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
)
select 
    bid, name, aidy, awst, unmet_need,
    acpt_yr,
    paid_yr,
    nvl(fall_acpt, 0) as fall_acpt,
    nvl(fall_paid, 0) as fall_paid,
    nvl(spr_acpt, 0)  as spr_acpt,
    nvl(spr_paid, 0)  as spr_paid from (
    select 
        b.spriden_id as bid,
        b.spriden_last_name || ', ' || b.spriden_first_name as name,
        d.amt as unmet_need,
        c.rprawrd_aidy_code as aidy,
        a.rpratrm_term_code as term,
        a.rpratrm_awst_code as awst,
        nvl(a.rpratrm_accept_amt, 0) as acpt,
        nvl(a.rpratrm_paid_amt, 0) as paid,
        nvl(c.rprawrd_accept_amt, 0) as acpt_yr,
        nvl(c.rprawrd_paid_amt, 0) as paid_yr
    from faismgr.rpratrm a
    inner join saturn.spriden b
        on b.spriden_pidm = a.rpratrm_pidm
    inner join faismgr.rprawrd c
        on c.rprawrd_pidm = a.rpratrm_pidm
        and c.rprawrd_aidy_code = a.rpratrm_aidy_code
        and c.rprawrd_fund_code = a.rpratrm_fund_code
    left  join unmet_need d on d.pidm = a.rpratrm_pidm and d.aidy = a.rpratrm_aidy_code
    where b.spriden_change_ind is null
    and a.rpratrm_fund_code = 'FWS'
    and a.rpratrm_term_code in ('202610', '202620')
)
pivot (
    sum(acpt) as acpt, 
    sum(paid) as paid 
    for term in ('202610' as fall, '202620' as spr)
)
;

select * from rpratrm WHERE RPRATRM_PIDM = 1443465 AND RPRATRM_TERM_CODE = '202610' AND RPRATRM_FUND_CODE = 'FWS';