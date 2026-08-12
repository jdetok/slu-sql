-- request from Eddie for Allaina in development 7/1/2026
-- student detail awarded under a fund code that joins to a tbracct_a_fund_code starting with '2' or '4'
with aidy as (
    select to_char(sysdate - 365, 'YY') || to_char(sysdate, 'YY') as aidy
    from dual
    where to_char(sysdate, 'MM') <= '08'
    union all
    select to_char(sysdate, 'YY') || to_char(sysdate + 365, 'YY')
    from dual
    where to_char(sysdate, 'MM') >= '07'
), acct as (
    select * from (
        select
            tbracct_detail_code,
            tbracct_a_fund_code,
            row_number() over ( -- most recent effective date for the detail code
                partition by tbracct_detail_code order by tbracct_detc_eff_date desc
            ) as rn
        from tbracct
        where (
            tbracct_a_fund_code like '2%' or tbracct_a_fund_code like '4%'
        )
    )
    where rn = 1
), desg as (
    select * from (
        select
            adrfund_fa_fund_code,
            adrfund_desg,
            adbdesg_name,
            row_number() over (
                partition by adrfund_fa_fund_code order by adrfund_activity_date desc
            ) as rn
        from adrfund
        join adbdesg on adbdesg_desg = adrfund_desg
    )
    where rn = 1
), awards as (
    select 
        a.rprawrd_pidm as pidm,
        a.rprawrd_aidy_code as aidy,
        a.rprawrd_fund_code as fund_sfs,
        c.tbracct_a_fund_code as fund_dev,
        b.rfrbase_detail_code as detl_code,
        d.adrfund_desg as desg_no,
        d.adbdesg_name as desg_name,
        a.rprawrd_accept_amt as acpt,
        a.rprawrd_paid_amt as paid
    from rprawrd a
    join rfrbase b on b.rfrbase_fund_code = a.rprawrd_fund_code and b.rfrbase_active_ind = 'Y'
    left join desg d on d.adrfund_fa_fund_code = a.rprawrd_fund_code
    join acct c on c.tbracct_detail_code = b.rfrbase_detail_code
    where a.rprawrd_awst_code = 'ACPT'
    and a.rprawrd_accept_amt >= 0
), emails as (
    select * from (
        select goremal_pidm as pidm, goremal_emal_code, goremal_email_address
        from goremal
        where goremal_status_ind = 'A'
        and goremal_emal_code in ('SLU', 'PERS')
    )
    pivot(
        min(goremal_email_address) 
        for goremal_emal_code in ('SLU' as email_slu, 'PERS' as email_pers)
    )
), addr as (
    select * from (
        select 
            spraddr_pidm as pidm,
            spraddr_city as city,
            spraddr_stat_code as state,
            nvl(spraddr_natn_code, 'US') as country,
            row_number() over (
                partition by spraddr_pidm
                order by 
                    case spraddr_atyp_code when 'AD' then 1 when 'MA' then 2 end,
                    spraddr_seqno desc
            ) as rn
        from spraddr
        where spraddr_atyp_code in ('AD', 'MA')
    )
    where rn = 1
), sprt as (
    select
        pidm,
        aidy,
        listagg(sport, ', ') within group (order by sport) as sports
    from (
        select distinct pidm, aidy, sport
        from (
            select 
                sgrsprt_pidm as pidm,
                stvactc_desc as sport,
                case 
                    when substr(sgrsprt_term_code,5,2) = '10'
                        then substr(sgrsprt_term_code,3,2) 
                            || substr(to_char(to_number(substr(sgrsprt_term_code,1,4)) + 1),3,2)
                    else
                        substr(to_char(to_number(substr(sgrsprt_term_code,1,4)) - 1),3,2)
                        || substr(sgrsprt_term_code,3,2)
                end as aidy
            from sgrsprt
            join stvactc on stvactc_code = sgrsprt_actc_code
            where sgrsprt_spst_code = 'A'
        )
    )
    group by pidm, aidy
    order by aidy, pidm
), stu as (
    select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_term_code_eff as eff_term,
        a.sgbstdn_levl_code as levl,
        a.sgbstdn_coll_code_1 as coll_1_cde,
        c.stvcoll_desc as coll_1,
        a.sgbstdn_coll_code_2 as coll_2_cde,
        c2.stvcoll_desc as coll_2,
        a.sgbstdn_majr_code_1 as majr_1_cde,
        m.stvmajr_desc as majr_1,
        a.sgbstdn_majr_code_2 as majr_2_cde,
        m2.stvmajr_desc as majr_2,
        a.sgbstdn_majr_code_minr_1 as minr_1_cde,
        n.stvmajr_desc as minr_1,
        a.sgbstdn_majr_code_minr_2 as minr_2_cde,
        n2.stvmajr_desc as minr_2,
        a.sgbstdn_majr_code_conc_1 as conc_1_cde,
        cn.stvmajr_desc as conc_1,
        a.sgbstdn_majr_code_conc_2 as conc_2_cde,
        cn2.stvmajr_desc as conc_2,
        a.sgbstdn_exp_grad_date as exp_grad
    from sgbstdn a
    left join stvcoll c on c.stvcoll_code = a.sgbstdn_coll_code_1
    left join stvcoll c2 on c2.stvcoll_code = a.sgbstdn_coll_code_2
    left join stvmajr m on m.stvmajr_code = a.sgbstdn_majr_code_1
    left join stvmajr m2 on m2.stvmajr_code = a.sgbstdn_majr_code_2
    left join stvmajr n on n.stvmajr_code = a.sgbstdn_majr_code_minr_1
    left join stvmajr n2 on n2.stvmajr_code = a.sgbstdn_majr_code_minr_2
    left join stvmajr cn on cn.stvmajr_code = a.sgbstdn_majr_code_conc_1
    left join stvmajr cn2 on cn2.stvmajr_code = a.sgbstdn_majr_code_conc_2
    where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
)
select 
    a.aidy,
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    e.email_slu,
    e.email_pers,
    r.city,
    r.state,
    r.country,
    s.levl,
    s.coll_1, s.coll_2,
    s.majr_1, s.majr_2,
    s.minr_1, s.minr_2,
    s.conc_1, s.conc_2,
    s.exp_grad,
    sp.sports,
    a.fund_sfs,
    a.fund_dev,
    a.detl_code,
    a.desg_no,
    a.desg_name,
    a.acpt,
    a.paid, 
    (select to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') from dual) as last_update
from awards a
join emails e on e.pidm = a.pidm
join robinst on robinst_aidy_code = a.aidy and robinst_status_ind = 'A'
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
join stu s on s.pidm = a.pidm and s.eff_term = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.pidm
    and z.sgbstdn_term_code_eff <= robinst_aidy_end_year || '20'
    and z.sgbstdn_stst_code in ('AS', 'IL', 'P1')
)
left join addr r on r.pidm = a.pidm
left join sprt sp on sp.pidm = a.pidm and sp.aidy = a.aidy
where a.aidy in (select aidy from aidy)
;


select * from (
    select
        adrfund_fa_fund_code,
        b.rfrbase_detail_code,
        adrfund_desg,
        adbdesg_name
        -- row_number() over (
        --     partition by adrfund_fa_fund_code order by adrfund_activity_date asc
        -- ) as rn
    from adrfund
    join adbdesg on adbdesg_desg = adrfund_desg
    join rfrbase b on b.rfrbase_fund_code = adrfund_fa_fund_code and b.rfrbase_active_ind = 'Y'
    where adrfund_fa_fund_code = 'YDPR93'
)
-- where rn = 1
;

 select * from (
        select
            tbracct_detail_code,
            tbracct_a_fund_code
            -- row_number() over ( -- most recent effective date for the detail code
            --     partition by tbracct_detail_code order by tbracct_detc_eff_date desc
            -- ) as rn
        from tbracct
        where (
            tbracct_a_fund_code like '2%' or tbracct_a_fund_code like '4%'
        )
        and tbracct_detail_code = 'Y707'
    );
    -- where rn = 1

    select * from rprawrd where rprawrd_fund_code = 'YDP707' and rprawrd_aidy_code = '2526';
with aidy as (
    select to_char(sysdate - 365, 'YY') || to_char(sysdate, 'YY') as aidy
    from dual
    where to_char(sysdate, 'MM') <= '08'
    union all
    select to_char(sysdate, 'YY') || to_char(sysdate + 365, 'YY')
    from dual
    where to_char(sysdate, 'MM') >= '07'
), acct as (
    select * from (
        select
            tbracct_detail_code,
            tbracct_a_fund_code,
            row_number() over ( -- most recent effective date for the detail code
                partition by tbracct_detail_code order by tbracct_detc_eff_date desc
            ) as rn
        from tbracct
        where (
            tbracct_a_fund_code like '2%' or tbracct_a_fund_code like '4%'
        )
    )
    where rn = 1
), desg as (
    select * from (
        select
            adrfund_fa_fund_code,
            adrfund_desg,
            adbdesg_name,
            row_number() over (
                partition by adrfund_fa_fund_code order by adrfund_activity_date desc
            ) as rn
        from adrfund
        join adbdesg on adbdesg_desg = adrfund_desg
    )
    where rn = 1
), awards as (
    select 
        a.rprawrd_pidm as pidm,
        a.rprawrd_aidy_code as aidy,
        a.rprawrd_fund_code as fund_sfs,
        c.tbracct_a_fund_code as fund_dev,
        b.rfrbase_detail_code as detl_code,
        d.adrfund_desg as desg_no,
        d.adbdesg_name as desg_name,
        a.rprawrd_accept_amt as acpt,
        a.rprawrd_paid_amt as paid
    from rprawrd a
    join rfrbase b on b.rfrbase_fund_code = a.rprawrd_fund_code and b.rfrbase_active_ind = 'Y'
    left join desg d on d.adrfund_fa_fund_code = a.rprawrd_fund_code
    join acct c on c.tbracct_detail_code = b.rfrbase_detail_code
    where a.rprawrd_awst_code = 'ACPT'
    and a.rprawrd_accept_amt >= 0
    and rprawrd_fund_code = 'YDP707' and rprawrd_aidy_code = '2526'
)
  select * from awards;

  select * from (
        select goremal_pidm as pidm, goremal_emal_code, goremal_email_address
        from goremal
        where goremal_status_ind = 'A'
        and goremal_emal_code in ('SLU', 'PERS')
        and goremal_pidm = 1453261
    )
    pivot(
        min(goremal_email_address) 
        for goremal_emal_code in ('SLU' as email_slu, 'PERS' as email_pers)
    )
    ;
    
select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_term_code_eff as eff_term,
        a.sgbstdn_levl_code as levl,
        a.sgbstdn_coll_code_1 as coll_1_cde,
        c.stvcoll_desc as coll_1,
        a.sgbstdn_coll_code_2 as coll_2_cde,
        c2.stvcoll_desc as coll_2,
        a.sgbstdn_majr_code_1 as majr_1_cde,
        m.stvmajr_desc as majr_1,
        a.sgbstdn_majr_code_2 as majr_2_cde,
        m2.stvmajr_desc as majr_2,
        a.sgbstdn_majr_code_minr_1 as minr_1_cde,
        n.stvmajr_desc as minr_1,
        a.sgbstdn_majr_code_minr_2 as minr_2_cde,
        n2.stvmajr_desc as minr_2,
        a.sgbstdn_majr_code_conc_1 as conc_1_cde,
        cn.stvmajr_desc as conc_1,
        a.sgbstdn_majr_code_conc_2 as conc_2_cde,
        cn2.stvmajr_desc as conc_2,
        a.sgbstdn_exp_grad_date as exp_grad
    from sgbstdn a
    left join stvcoll c on c.stvcoll_code = a.sgbstdn_coll_code_1
    left join stvcoll c2 on c2.stvcoll_code = a.sgbstdn_coll_code_2
    left join stvmajr m on m.stvmajr_code = a.sgbstdn_majr_code_1
    left join stvmajr m2 on m2.stvmajr_code = a.sgbstdn_majr_code_2
    left join stvmajr n on n.stvmajr_code = a.sgbstdn_majr_code_minr_1
    left join stvmajr n2 on n2.stvmajr_code = a.sgbstdn_majr_code_minr_2
    left join stvmajr cn on cn.stvmajr_code = a.sgbstdn_majr_code_conc_1
    left join stvmajr cn2 on cn2.stvmajr_code = a.sgbstdn_majr_code_conc_2
    where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and a.sgbstdn_pidm = 1453261;