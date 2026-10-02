with gross_need as (
    select
        pidm, aidy, awarded, 
        cast(rnkneed.f_calc_gross_need(pidm, aidy) as int) as gross,
        cast(rnkneed.f_calc_efc(pidm, aidy) as int) as efc,
        cast(rnkneed.f_calc_oth_resource(pidm, aidy) as int) as resc
    from (
        select 
            a.rprawrd_pidm as pidm, a.rprawrd_aidy_code as aidy,
            nvl(sum(a.rprawrd_offer_amt), 0) as awarded
        from rprawrd a
        where a.rprawrd_offer_amt > 0
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
), need_based as (
    select 
        rprawrd_pidm as pidm, rprawrd_aidy_code as aidy, 
        sum(rprawrd_offer_amt) as need_based
    from rprawrd
    where rprawrd_fund_code in ('DLSL', 'NURSLN', 'FWS', 'PELL', 'SEOG')
    group by rprawrd_pidm, rprawrd_aidy_code
), unmet_need as (
    select 
        pidm, aidy, efc, resc, aid_no_need, awarded, gross,
        case 
            when efc = 0 then (gross - awarded)
            when efc < aid_no_need then (gross - (awarded) + efc) 
            else (gross - (awarded - aid_no_need))
        end as amt
    from non_need
)
select
    spriden_id as bid, spriden_last_name || ', ' || spriden_first_name as name
from sgbstdn a
join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
join robinst on robinst_aidy_code = '2627' and robinst_status_ind = 'A'
join spraddr s on s.spraddr_pidm = a.sgbstdn_pidm and s.spraddr_atyp_code = 'AD' and s.spraddr_seqno = (
    select max(z.spraddr_seqno) from spraddr z
    where z.spraddr_pidm = s.spraddr_pidm
    and z.spraddr_atyp_code = s.spraddr_atyp_code
)
join unmet_need n on n.pidm = a.sgbstdn_pidm and n.aidy = robinst_aidy_code
where a.sgbstdn_coll_code_1 = 'NR'
and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and s.spraddr_stat_code <> 'MO'
and n.amt > 0
and a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff) from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= robinst_aidy_end_year || '20'
)
; 
select * from spraddr;

select * from stvcoll where stvcoll_desc like '%Nurs%';
