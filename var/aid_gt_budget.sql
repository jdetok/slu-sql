-- Janice request 9/9 - all aid offered for year > the year budget
-- select count(distinct pidm) from (
with fl as (
    select robinst_aidy_end_year || '10' as term
    from robinst
    where robinst_status_ind = 'A'
    and robinst_aidy_code = :aidy
), sp as (
    select robinst_aidy_end_year || '20' as term
    from robinst
    where robinst_status_ind = 'A'
    and robinst_aidy_code = :aidy
), bgrp as (
    select 
        rbrapbg_pidm as pidm,
        rbrapbg_aidy_code as aidy,
        case 
            when max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end) 
            = max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end)
            or max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end) is null
            then max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end)
            when max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end) is null
            then max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end)
            else 
                max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end) 
                || ', ' || 
                max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end)
        end as bgrp
    from rbrapbg
    where rbrapbg_run_name = 'ACTUAL'
    group by rbrapbg_pidm, rbrapbg_aidy_code
), budg as (
    select 
        rbrapbc_pidm as pidm,
        rbrapbc_aidy_code as aidy,
        sum(rbrapbc_amt) as budg
    from rbrapbc
    where rbrapbc_run_name = 'ACTUAL'
    and rbrapbc_pbtp_code = 'CAMP'
    group by rbrapbc_pidm, rbrapbc_aidy_code
), ofrd as (
    select
        a.rprawrd_pidm as pidm,
        a.rprawrd_aidy_code as aidy,
        sum(a.rprawrd_offer_amt) as ofrd
    from rprawrd a
    group by a.rprawrd_pidm, a.rprawrd_aidy_code
), gross_need as (
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
    -- join rfraspc 
    --     on rfraspc_fund_code = rprawrd_fund_code
    --     and rfraspc_aidy_code = rprawrd_aidy_code
    -- where rfraspc_reduce_need_ind = 'Y'
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
    spriden_id as bid, 
    spriden_last_name || ', ' || spriden_first_name as name,
    a.aidy, 
    b.bgrp, 
    c.budg, 
    a.ofrd, 
    d.efc as sai,
    d.amt as unmet_need,
    d.gross as gross_need,
    e.need_based,
    d.resc
from ofrd a
join bgrp b on b.pidm = a.pidm and b.aidy = a.aidy
join budg c on c.pidm = a.pidm and c.aidy = a.aidy
join unmet_need d on d.pidm = a.pidm and d.aidy = a.aidy
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
left join need_based e on e.pidm = a.pidm and e.aidy = a.aidy
where a.aidy = :aidy
and a.ofrd > c.budg
;

-- PBI version
with fl as (
    select robinst_aidy_end_year || '10' as term
    from robinst
    where robinst_status_ind = 'A'
    and robinst_aidy_code = '" & aidy &"'
), sp as (
    select robinst_aidy_end_year || '20' as term
    from robinst
    where robinst_status_ind = 'A'
    and robinst_aidy_code = '" & aidy & "'
), bgrp as (
    select 
        rbrapbg_pidm as pidm,
        rbrapbg_aidy_code as aidy,
        case 
            when max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end) 
            = max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end)
            or max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end) is null
            then max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end)
            when max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end) is null
            then max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end)
            else 
                max(case when rbrapbg_period = (select term from fl) then rbrapbg_pbgp_code end) 
                || ', ' || 
                max(case when rbrapbg_period = (select term from sp) then rbrapbg_pbgp_code end)
        end as bgrp
    from rbrapbg
    where rbrapbg_run_name = 'ACTUAL'
    group by rbrapbg_pidm, rbrapbg_aidy_code
), budg as (
    select 
        rbrapbc_pidm as pidm,
        rbrapbc_aidy_code as aidy,
        sum(rbrapbc_amt) as budg
    from rbrapbc
    where rbrapbc_run_name = 'ACTUAL'
    and rbrapbc_pbtp_code = 'CAMP'
    group by rbrapbc_pidm, rbrapbc_aidy_code
), ofrd as (
    select
        a.rprawrd_pidm as pidm,
        a.rprawrd_aidy_code as aidy,
        sum(a.rprawrd_offer_amt) as ofrd
    from rprawrd a
    group by a.rprawrd_pidm, a.rprawrd_aidy_code
), gross_need as (
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
    join rfraspc 
        on rfraspc_fund_code = rprawrd_fund_code
        and rfraspc_aidy_code = rprawrd_aidy_code
    where rfraspc_reduce_need_ind = 'Y'
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
    spriden_id as bid, 
    spriden_last_name || ', ' || spriden_first_name as name,
    a.aidy, 
    b.bgrp, 
    c.budg, 
    a.ofrd, 
    d.efc as sai,
    d.amt as unmet_need,
    d.gross as gross_need,
    e.need_based,
    d.resc
from ofrd a
join bgrp b on b.pidm = a.pidm and b.aidy = a.aidy
join budg c on c.pidm = a.pidm and c.aidy = a.aidy
join unmet_need d on d.pidm = a.pidm and d.aidy = a.aidy
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
left join need_based e on e.pidm = a.pidm and e.aidy = a.aidy
where a.aidy = '" & aidy & "'
and a.ofrd > c.budg
;