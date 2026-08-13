SELECT RORALGS_AMT
FROM SGBSTDN X
JOIN RORPRST on RORPRST_PIDM = X.SGBSTDN_PIDM
    and RORPRST_PERIOD = :PERIOD
JOIN ROBNYUD on ROBNYUD_PIDM = X.SGBSTDN_PIDM
JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_2 = CASE WHEN X.SGBSTDN_STYP_CODE not in ('F', '1', 'T') THEN 'C' END
    and RORALGS_KEY_3 = CASE WHEN (RORPRST_XHS IN ('1','3','4')) THEN '1' END
    and RORALGS_KEY_4 = '4COM'
    and RORALGS_KEY_5 = X.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_6 = X.SGBSTDN_CAMP_CODE
WHERE X.SGBSTDN_LEVL_CODE = 'UG'
AND X.SGBSTDN_CAMP_CODE = 'FR'
AND X.SGBSTDN_STST_CODE IN ('AS','IL','P1')
AND X.SGBSTDN_COLL_CODE_1 NOT IN ('PS','PL')
AND X.SGBSTDN_PROGRAM_1 NOT IN ('NR041','NR02','TEAC03','NR06') -- from JKB 11/17 added accel nursing, rising teacher
AND X.SGBSTDN_PIDM = :PIDM
AND X.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(Y.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y
    WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND NOT EXISTS (
    select 1 from SGRSATT b
    where b.SGRSATT_PIDM = X.SGBSTDN_PIDM
    and b.SGRSATT_ATTS_CODE = 'SPSA'
    and b.SGRSATT_TERM_CODE_EFF = (
        select max(z.SGRSATT_TERM_CODE_EFF)
        from SGRSATT z
        where z.SGRSATT_PIDM = b.SGRSATT_PIDM
        and z.SGRSATT_TERM_CODE_EFF <= :PERIOD
    )
)
AND NOT EXISTS (
    SELECT 1
    FROM SARADAP x
    INNER JOIN SARAPPD y on y.SARAPPD_PIDM = x.SARADAP_PIDM
        AND y.SARAPPD_APPL_NO = x.SARADAP_APPL_NO
        AND y.SARAPPD_TERM_CODE_ENTRY = x.SARADAP_TERM_CODE_ENTRY
    INNER JOIN STVAPDC z on z.STVAPDC_CODE = SARAPPD_APDC_CODE
        AND z.STVAPDC_INST_ACC_IND = 'Y'
        AND z.STVAPDC_SIGNF_IND = 'Y'
    WHERE x.SARADAP_PIDM = x.SGBSTDN_PIDM
    AND x.SARADAP_TERM_CODE_ENTRY > x.SGBSTDN_TERM_CODE_EFF 
    AND x.SARADAP_TERM_CODE_ENTRY <= ('20' || cast(substr(:AIDY, 3, 2) as int) + 1 || '00')
    AND x.SARADAP_PROGRAM_1 <> X.SGBSTDN_PROGRAM_1
)
and not exists (
    select 1
    from tbraccd 
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_type_ind = 'C'
        and tbbdetc_dcat_code = 'HOU'
    where tbraccd_pidm = x.sgbstdn_pidm
    and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
    and tbraccd_term_code = rorprst_period
    group by tbraccd_pidm, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)