desc rbrapbg;

select 
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    rbrapbg_pbgp_code,
    (
        select sum(rbrapbc_amt)
        from rbrapbc
        where rbrapbc_pidm = rbrapbg_pidm
        and rbrapbc_period = rbrapbg_period
    ) as total_budget
from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
where rbrapbg_run_name = 'ACTUAL'
and rbrapbg_pbgp_code in ('PM', 'PL')
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = '1TUI'
    and rbrapbc_amt > 0
)
;

select * from rbrabrc where rbrabrc_abrc_code = '6LIV' and rbrabrc_validated_ind = 'N';
desc rorprst;

desc saradap;
select SARADAP_FULL_PART_IND 
from saradap
group by SARADAP_FULL_PART_IND;

desc goremal;



