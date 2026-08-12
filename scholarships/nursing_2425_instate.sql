-- averages of specific funds for specific groups of sai ranges

with stu as (
    select
        a.sgbstdn_pidm as pidm, 
        a.sgbstdn_levl_code
    from sgbstdn a
    where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and a.sgbstdn_levl_code = 'UG'
    and a.sgbstdn_coll_code_1 = 'NR'
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= '202600'
    )
), hours as (
    select distinct sfrstcr_pidm as pidm
    from sfrstcr
    where sfrstcr_term_code in ('202510', '202520', '202600')
    and sfrstcr_bill_hr > 0
), instate as (
    select * from (
        select 
            spraddr_pidm as pidm,
            spraddr_stat_code as state,
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
    and state = 'MO'
), fafsa as (
    select
        rcrapp1_pidm as pidm,
        rcrapp4_aidy_code as aidy,
        rcrapp4_sar_efc as sai
    from rcrapp1
    join rcrapp4 
        on rcrapp1_pidm = rcrapp4_pidm 
        and rcrapp1_aidy_code = rcrapp4_aidy_code
        and rcrapp1_seq_no = rcrapp4_seq_no
        and rcrapp1_infc_code = rcrapp4_infc_code
    where rcrapp1_curr_rec_ind = 'Y'
    and rcrapp1_infc_code = 'EDE'
), awards as (
    select
        rprawrd_pidm as pidm,
        rprawrd_aidy_code as aidy,
        rprawrd_fund_code as fund,
        rprawrd_accept_amt as amt
    from rprawrd
    where rprawrd_aidy_code = '2425'
), pell_amt as (
    select pidm, amt from awards where fund = 'PELL'
)
select 
    spriden_id as bid, 
    spriden_last_name || ', ' || spriden_first_name as name,
    b.sai,
    case
        when b.sai is null then null
        when b.sai <= 3000 then 'high' 
        when b.sai <= 10000 then 'mid' 
        when b.sai <= 30000 then 'low'
        else 'vlow'
    end as need_levl,
    c.amt
from stu a
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
left join fafsa b on b.pidm = a.pidm and b.aidy = '2425'
left join awards c on c.pidm = a.pidm and c.aidy = b.aidy
where exists (
    select 1 from hours
    where pidm = a.pidm
)
and exists (
    select 1 from instate
    where pidm = a.pidm
)
;

select * from stvcoll;

select * from rfrbase where rfrbase_fund_code in ('FWS', 'SEOG', 'MOACC', 'MOSCH', 'PELL', 'PURDY') and rfrbase_ftyp_code = 'TU-S';

select * from rtvftyp;

desc rbrapbg;