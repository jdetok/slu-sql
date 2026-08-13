-- 01162026 working before touched 
with dt_fname as (
    select to_char(sysdate, 'MMDDYYYY_HH24MISS') as dt, 'pbb_simr_variance_' as fname from dual
), bgrp as (
    select 
        RBRAPBG_PIDM as pidm,
        SPRIDEN_ID as id,
        RBRAPBG_AIDY_CODE as aidy,
        RBRAPBG_PERIOD as period,
        RBRAPBG_RUN_NAME as run_name,
        RBRAPBG_PBGP_CODE as bgrp
    from RBRAPBG
    inner join SPRIDEN on SPRIDEN_PIDM = RBRAPBG_PIDM and SPRIDEN_CHANGE_IND is null
), comp as (
    select 
        RBRAPBC_PIDM as pidm,
        SPRIDEN_ID as id,
        RBRAPBC_AIDY_CODE as aidy,
        RBRAPBC_PERIOD as period,
        RBRAPBC_RUN_NAME as run_name,
        RBRAPBC_PBCP_CODE as pbcp, 
        RBRAPBC_AMT as amt
    from RBRAPBC
    inner join SPRIDEN on SPRIDEN_PIDM = RBRAPBC_PIDM and SPRIDEN_CHANGE_IND is null
    where RBRAPBC_PBTP_CODE = 'CAMP'
), comp_pivot as (
    select * from comp
    PIVOT (
        SUM(amt)
        FOR pbcp IN (
            '1TUI' as TUI,
            '2FEE' as FEE,
            '3HSM' as HSM,
            '4COM' as COM,
            '5CAF' as CAF,
            '6LIV' as LIV,
            '21BF' as BF,
            '22DF' as DF,
            '23PF' as PF,
            '24SF' as SF,
            '7BS' as BS,
            '8TRS' as TRS,
            '9MIS' as MIS
        )
    )
)
select 
    a.id, a.pidm, a.aidy, a.period, a.run_name, a.actual_group, b.simr_run, b.simr_group,
    nvl(to_char(c.TUI), '-') as TUI, 
    nvl(to_char(d.TUI), '-') as TUI_SIMR,
    nvl(to_char(c.FEE), '-') as FEE, 
    nvl(to_char(d.FEE), '-') as FEE_SIMR,
    nvl(to_char(c.HSM), '-') as HSM, 
    nvl(to_char(d.HSM), '-') as HSM_SIMR,
    nvl(to_char(c.COM), '-') as COM, 
    nvl(to_char(d.COM), '-') as COM_SIMR,
    nvl(to_char(c.CAF), '-') as CAF, 
    nvl(to_char(d.CAF), '-') as CAF_SIMR,
    nvl(to_char(c.LIV), '-') as LIV, 
    nvl(to_char(d.LIV), '-') as LIV_SIMR,
    nvl(to_char(c.BS), '-') as BS, 
    nvl(to_char(d.BS), '-') as BS_SIMR,
    nvl(to_char(c.TRS), '-') as TRS, 
    nvl(to_char(d.TRS), '-') as TRS_SIMR,
    nvl(to_char(c.MIS), '-') as MIS, 
    nvl(to_char(d.MIS), '-') as MIS_SIMR,
    nvl(to_char(c.BF), '-') as BF, 
    nvl(to_char(d.BF), '-') as BF_SIMR,
    nvl(to_char(c.DF), '-') as DF, 
    nvl(to_char(d.DF), '-') as DF_SIMR,
    nvl(to_char(c.PF), '-') as PF, 
    nvl(to_char(d.PF), '-') as PF_SIMR,
    nvl(to_char(c.SF), '-') as SF, 
    nvl(to_char(d.SF), '-') as SF_SIMR,
    (select fname from dt_fname) || (select dt from dt_fname) as fname

from (
    select id, pidm, aidy, period, run_name, bgrp as actual_group
    from bgrp where run_name = 'ACTUAL'
) a
join (
    select pidm, period, run_name as simr_run, bgrp as simr_group
    from bgrp where run_name <> 'ACTUAL'
) b on b.pidm = a.pidm and b.period = a.period
left join comp_pivot c
    on c.pidm = a.pidm
    and c.period = a.period
    and c.run_name = a.run_name
left join comp_pivot d
    on d.pidm = b.pidm
    and d.period = b.period
    and d.run_name = b.simr_run
where (
    a.actual_group <> b.simr_group
    or c.TUI <> d.TUI 
    or c.FEE <> d.FEE 
    or c.HSM <> d.HSM 
    or c.COM <> d.COM 
    or c.CAF <> d.CAF 
    or c.LIV <> d.LIV 
    or c.BS <> d.BS 
    or c.TRS <> d.TRS 
    or c.MIS <> d.MIS 
    or c.BF <> d.BF 
    or c.DF <> d.DF 
    or c.PF <> d.PF 
    or c.SF <> d.SF
);


-- JANICE REQUEST: 
maybe we can find some time to talk about this afternoon at 1?  The basic premise is, students have to have <=60000 parent aig and <=5000 parent assets, which is already built in there.  now, once they hvae been awarded the SLUPRM fund code, if we get in a new EDE record for whatever reason, then their income level needs to  compare against <=70000 parent agi.  The asset comparison stays the same.  So I was thinking that after pacakging, I would post a flag somewhere in year specific user defined that indicates a student has the UFRPM packaging group and was awarded  SLUPRM fund >0 and then that could be used to compare to the new AGI figure of <=-70000?  Maybe we don'nt need to meet b/c I just outlined what I would have said, but let me know what you think   we are starting to get corrected records and we will be starting to verify as well.