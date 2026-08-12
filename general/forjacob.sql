select * from (
    select 
        -- a.sgbstdn_pidm,
        spriden_id,
        rprawrd_aidy_code as aidy,
        rprawrd_fund_code as fund,
        rprawrd_awst_code as awst,
        rprawrd_accept_amt as acpt,
        rprawrd_paid_amt as paid
    from sgbstdn a 
    join rprawrd b on b.rprawrd_pidm = a.sgbstdn_pidm 
    join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
    where b.rprawrd_aidy_code in ('2223', '2324', '2425', '2526')
    and b.rprawrd_fund_code in ('DLUL', 'DLGL', 'ALTERN', 'MEDEDW', 'YDP801', 'YDPD18', 'YDPD19', 'MCURA', 'YDPH66', 'MEDDIV', 'YDPV31', 'YDPZ05')
    and b.rprawrd_awst_code in ('ACPT', 'CNCL', 'DECL')
    and a.sgbstdn_stst_code in ('AS', 'IL')
    and a.sgbstdn_levl_code = 'PM'
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff < '202700'
    )
) 
order by aidy desc
;

select * from rfrbase where rfrbase_fund_code in ('DLUL', 'DLGL', 'ALTERN', 'MCURA', 'MEDDIV');
select * from rfraspc where  rfraspc_fund_code in ('DLUL', 'DLGL', 'ALTERN', 'MCURA', 'MEDDIV', 'FWS') and rfraspc_aidy_code = '2627';

select sgbstdN_term_code_eff, sgbstdn_majr_code_1, sgbstdn_coll_code_1, sgbstdn_degc_code_1 from sgbstdn where sgbstdn_levl_code = 'PM' and sgbstdn_coll_code_1 <> 'MD';