select 
--    a.tbbacct_pidm as pidm,
    s.spriden_id as student_id,
    p.spbpers_ssn as ssn,
    to_char(p.spbpers_birth_date, 'MM/DD/YYYY') as dob,
    s.spriden_last_name as last_name,
    s.spriden_first_name as first_name,
    s.spriden_mi as middle_name,
    nvl(b.fin_bal, 0) + nvl(c.non_fin_bal, 0) as balance,
    nvl(c.non_fin_bal, 0) as principal,
    nvl(b.fin_bal, 0) as late_fees,
    e.last_payment,
    e.last_payment_date,
    d.oldest_delinq_date_actual,
    case
        when substr(d.oldest_delinq_term, 5, 2) = '00'
            then '07/01/' || to_char(to_number(substr(d.oldest_delinq_term, 0, 4)) - 1)
        when substr(d.oldest_delinq_term, 5, 2) = '10'
            then '12/01/' || to_char(to_number(substr(d.oldest_delinq_term, 0, 4)) - 1)
        when substr(d.oldest_delinq_term, 5, 2) = '20'
            then '05/01/' || substr(d.oldest_delinq_term, 0, 4)
    end as oldest_delinq_date_from_term,
    d.oldest_delinq_term_desc,
    f.latest_delinq_date_actual,
    f.latest_delinq_term_desc,
    m.goremal_email_address as email,
    t.cell_phone,
    t.home_phone,
    r.street1,
    r.street2,
    r.city,
    r.state_abbr,
    r.zip,
    '' as amt_pmt_since_itemization
--    a.tbbacct_bill_code as to_agency
from tbbacct a
join spriden s on s.spriden_pidm = a.tbbacct_pidm and s.spriden_change_ind is null
join spbpers p on p.spbpers_pidm = a.tbbacct_pidm
left join (
    select *
    from (
        select
        spraddr_pidm,
        spraddr_atyp_code as atyp,
        spraddr_street_line1 as street1,
        spraddr_street_line2 as street2,
        spraddr_city as city,
        spraddr_stat_code as state_abbr,
        spraddr_zip as zip,
        row_number() over (
            partition by spraddr_pidm
            order by
                case spraddr_atyp_code
                    when 'MA' then 1
                    when 'LO' then 2
                    when 'BI' then 3
                    when 'AD' then 4
                    when 'DM' then 5
                    when 'PA' then 6
                    else 9
                end,
                nvl(spraddr_from_date, date '1900-01-01') desc,
                spraddr_seqno desc
        ) rn
        from spraddr
        where spraddr_atyp_code in ('MA', 'LO', 'BI', 'AD', 'PA', 'DM')
--        and spraddr_status_ind is null
        and (spraddr_to_date is null or spraddr_to_date >= sysdate)
    )
    where rn = 1
) r on r.spraddr_pidm = a.tbbacct_pidm
left join (
    select *
    from (
        select 
            goremal_pidm,
            goremal_email_address,
            goremal_preferred_ind,
            row_number() over (
                partition by goremal_pidm
                order by
                    case goremal_preferred_ind
                        when 'Y' then 1
                        when 'N' then 2
                        else 0
                    end,
                    goremal_activity_date desc
            ) rn
        from goremal 
        where goremal_emal_code = 'PERS'
        and goremal_status_ind = 'A'
    )
    where rn = 1
) m on m.goremal_pidm = a.tbbacct_pidm    
left join (
    select * from (
        select sprtele_pidm, sprtele_tele_code, (sprtele_phone_area || sprtele_phone_number) as phone
        from sprtele
        where sprtele_status_ind is null 
        and sprtele_tele_code in ('MA', 'CE')
    ) pivot (
        max(phone)
        for sprtele_tele_code in (
            'MA' as home_phone,
            'CE' as cell_phone
        )
    )
    
) t on t.sprtele_pidm = a.tbbacct_pidm
left join (
    select tbraccd_pidm, sum(tbraccd_balance) as fin_bal
    from tbraccd
    where tbraccd_detail_code = 'FIN'
    group by tbraccd_pidm
) b on b.tbraccd_pidm = a.tbbacct_pidm
left join (
    select tbraccd_pidm, sum(tbraccd_balance) as non_fin_bal
    from tbraccd
    where tbraccd_detail_code <> 'FIN'
    group by tbraccd_pidm
) c on c.tbraccd_pidm = a.tbbacct_pidm
left join (
    select 
        tbraccd_pidm, 
        tbraccd_term_code as oldest_delinq_term, 
        stvterm_desc as oldest_delinq_term_desc,
        to_char(tbraccd_effective_date, 'MM/DD/YYYY') as oldest_delinq_date_actual
    from (
        select 
            tbraccd_pidm, 
            tbraccd_term_code,
            stvterm_desc,
            tbraccd_effective_date,
            row_number() over (partition by tbraccd_pidm order by tbraccd_term_code, tbraccd_effective_date) rn
        from tbraccd
        join stvterm on stvterm_code = tbraccd_term_code
        where tbraccd_balance > 0    
    )
    where rn = 1
) d on d.tbraccd_pidm = a.tbbacct_pidm
left join (
    select 
        tbraccd_pidm, 
        tbraccd_term_code as latest_delinq_term, 
        stvterm_desc as latest_delinq_term_desc,
        to_char(tbraccd_effective_date, 'MM/DD/YYYY') as latest_delinq_date_actual
    from (
        select 
            tbraccd_pidm, 
            tbraccd_term_code,
            stvterm_desc,
            tbraccd_effective_date,
            row_number() over (partition by tbraccd_pidm order by tbraccd_term_code desc, tbraccd_effective_date desc) rn
        from tbraccd
        join stvterm on stvterm_code = tbraccd_term_code
        where tbraccd_balance > 0    
    )
    where rn = 1
) f on f.tbraccd_pidm = a.tbbacct_pidm
left join (
    select 
        tbraccd_pidm, 
        tbraccd_amount as last_payment,
        to_char(tbraccd_effective_date, 'MM/DD/YYYY') as last_payment_date
    from (
        select tbraccd_pidm, tbraccd_amount, tbraccd_effective_date,
            row_number() over (partition by tbraccd_pidm order by tbraccd_effective_date desc) rn
        from tbraccd
        join tbbdetc z 
            on z.tbbdetc_detail_code = tbraccd_detail_code
            and z.tbbdetc_dcat_code = 'CSH'
    )
    where rn = 1
) e on e.tbraccd_pidm = a.tbbacct_pidm
where a.tbbacct_bill_code = :bc;
--where a.tbbacct_bill_code in ('EF', 'EC', 'EN');
select * from spraddr;
