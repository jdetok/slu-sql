select 
    spriden_id as id,
    spriden_last_name || ', ' || spriden_first_name as name, 
    rorstat_aidy_code as aidy,
    rorstat_aprd_code as aid_period,
    rbrapbc_period as period,
    rbrapbg_pbgp_code as budget_group,
    rbrapbc_pbcp_code as component,
    rbrapbc_amt as amt,
    to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') as last_update
    
from rbrapbc
join spriden on spriden_pidm = rbrapbc_pidm and spriden_change_ind is null
join rorstat on rorstat_pidm = rbrapbc_pidm and rorstat_aidy_code = rbrapbc_aidy_code
join rbrapbg
    on rbrapbg_pidm = rbrapbc_pidm 
    and rbrapbg_period = rbrapbc_period
    and rbrapbg_run_name = rbrapbc_run_name
where rbrapbc_run_name = 'ACTUAL'
and rbrapbc_pbtp_code = 'CAMP'
and rbrapbc_aidy_code = '2627';




select * from rbrapbg;
-- 'pbb_components_by_stu_' || to_char(sysdate, 'MMDDYYYY_HHMISS') as dt