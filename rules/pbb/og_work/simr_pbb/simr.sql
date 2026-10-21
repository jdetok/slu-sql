desc rbrpbgp;
desc rbrpbcp;
desc rbrapbg;
desc rbrapbc;

select spriden_pidm from spriden where spriden_id = '001493165' and spriden_change_ind is null;

select * from rbrapbg where rbrapbg_pidm = 1501805;
select * from rbrapbc where rbrapbc_pidm = 1501805;

-- build report to compare student simulation vs actual budgets
-- base report starts with students with actual budget

with dt_fname as (
    select to_char(sysdate, 'MMDDYYYY_HH24MISS') as dt, 'pbb_simr_variance_' as fname from dual
), bgrp as (
    select 
        RBRAPBG_PIDM as pidm,
        SPRIDEN_ID as id,
        RBRAPBG_AIDY_CODE as aidy,
        RBRAPBG_PERIOD as period,
        RBRAPBG_RUN_NAME as run_name,
        RBRAPBG_PBGP_CODE as bgrp,
        RBRAPBG_PBGP_CODE_LOCK_IND as lock_ind
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
),
main_q AS (
    SELECT 
        a.id, a.pidm, a.aidy, a.period, a.run_name, a.lock_ind, a.actual_group,
        b.simr_run, b.simr_group,
        NVL(TO_CHAR(c.TUI), '-') AS TUI,
        NVL(TO_CHAR(d.TUI), '-') AS TUI_SIMR,
        NVL(TO_CHAR(c.FEE), '-') AS FEE,
        NVL(TO_CHAR(d.FEE), '-') AS FEE_SIMR,
        NVL(TO_CHAR(c.HSM), '-') AS HSM,
        NVL(TO_CHAR(d.HSM), '-') AS HSM_SIMR,
        NVL(TO_CHAR(c.COM), '-') AS COM,
        NVL(TO_CHAR(d.COM), '-') AS COM_SIMR,
        NVL(TO_CHAR(c.CAF), '-') AS CAF,
        NVL(TO_CHAR(d.CAF), '-') AS CAF_SIMR,
        NVL(TO_CHAR(c.LIV), '-') AS LIV,
        NVL(TO_CHAR(d.LIV), '-') AS LIV_SIMR,
        NVL(TO_CHAR(c.BS), '-')  AS BS,
        NVL(TO_CHAR(d.BS), '-')  AS BS_SIMR,
        NVL(TO_CHAR(c.TRS), '-') AS TRS,
        NVL(TO_CHAR(d.TRS), '-') AS TRS_SIMR,
        NVL(TO_CHAR(c.MIS), '-') AS MIS,
        NVL(TO_CHAR(d.MIS), '-') AS MIS_SIMR,
        NVL(TO_CHAR(c.BF), '-')  AS BF,
        NVL(TO_CHAR(d.BF), '-')  AS BF_SIMR,
        NVL(TO_CHAR(c.DF), '-')  AS DF,
        NVL(TO_CHAR(d.DF), '-')  AS DF_SIMR,
        NVL(TO_CHAR(c.PF), '-')  AS PF,
        NVL(TO_CHAR(d.PF), '-')  AS PF_SIMR,
        NVL(TO_CHAR(c.SF), '-')  AS SF,
        NVL(TO_CHAR(d.SF), '-')  AS SF_SIMR,
        (SELECT fname || dt FROM dt_fname) AS fname
    from (
        select id, pidm, aidy, period, run_name, bgrp as actual_group, lock_ind
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
    )
)
SELECT
    m.*
FROM main_q m

UNION ALL

SELECT
    'NO DIFFERENCES FOUND' AS id,
    NULL AS pidm,
    NULL AS aidy,
    NULL AS period,
    NULL AS run_name,
    NULL AS lock_ind,
    NULL AS actual_group,
    NULL AS simr_run,
    NULL AS simr_group,
    NULL AS TUI, NULL AS TUI_SIMR,
    NULL AS FEE, NULL AS FEE_SIMR,
    NULL AS HSM, NULL AS HSM_SIMR,
    NULL AS COM, NULL AS COM_SIMR,
    NULL AS CAF, NULL AS CAF_SIMR,
    NULL AS LIV, NULL AS LIV_SIMR,
    NULL AS BS,  NULL AS BS_SIMR,
    NULL AS TRS, NULL AS TRS_SIMR,
    NULL AS MIS, NULL AS MIS_SIMR,
    NULL AS BF,  NULL AS BF_SIMR,
    NULL AS DF,  NULL AS DF_SIMR,
    NULL AS PF,  NULL AS PF_SIMR,
    NULL AS SF,  NULL AS SF_SIMR,
    (SELECT fname || dt FROM dt_fname) AS fname
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM main_q);

desc stvapdc;