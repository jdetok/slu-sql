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
    and RBRAPBC_RUN_NAME <> 'ACTUAL'
    and RBRAPBC_PBCP_CODE = '23PF';
    
    -- 001343553
    select distinct(rbrapbc_pidm)
    from RBRAPBC
    where RBRAPBC_PBTP_CODE = 'CAMP'
    and RBRAPBC_RUN_NAME <> 'ACTUAL'
    and RBRAPBC_PBCP_CODE = '23PF'