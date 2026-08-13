
with budg as (
    select rbrapbc_pidm as pidm, rbrapbc_aidy_code as aidy, rbrapbc_period as period, rbrapbg_pbgp_code as pbgp,
        sum(rbrapbc_amt) as amt
    from rbrapbc
    join rbrapbg on rbrapbg_pidm = rbrapbc_pidm
        and rbrapbg_period = rbrapbc_period
        and rbrapbg_run_name = rbrapbc_run_name
    where rbrapbc_run_name = 'ACTUAL'
    and rbrapbc_pbtp_code = 'CAMP'
    group by rbrapbc_pidm, rbrapbc_aidy_code, rbrapbg_pbgp_code, rbrapbc_period
)
select 
    spriden_id, spriden_last_name || ', ' || spriden_first_name as name,
    a.aidy, a.period, a.pbgp, a.amt, to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') as last_update
from budg a
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
where a.aidy = '2627'
;

select * from rbrapbg;