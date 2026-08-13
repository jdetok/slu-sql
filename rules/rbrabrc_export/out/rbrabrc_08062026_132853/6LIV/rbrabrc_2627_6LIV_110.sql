SELECT case
    when exists (
        select 1 from SGRSATT b
        where b.SGRSATT_PIDM = a.SGBSTDN_PIDM
        and b.SGRSATT_ATTS_CODE = 'SPSA'
        and b.SGRSATT_TERM_CODE_EFF = (
            select max(z.SGRSATT_TERM_CODE_EFF)
            from SGRSATT z
            where z.SGRSATT_PIDM = b.SGRSATT_PIDM
            and z.SGRSATT_TERM_CODE_EFF <= :PERIOD
        )
    ) then (
        roralgs_amt - (
            select roralgs_amt from roralgs
            where roralgs_aidy_code = :AIDY
            and roralgs_key_1 = 'PBDG'
            and roralgs_key_4 = '5CAF'
        )
    ) else roralgs_amt
end as amt
FROM SGBSTDN a
join spriden on spriden_change_ind is null and spriden_pidm = sgbstdn_pidm
JOIN RORPRST on RORPRST_PIDM = a.SGBSTDN_PIDM
    and RORPRST_PERIOD = :PERIOD
    and RORPRST_XHS <> '2'
JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '6LIV'
    and RORALGS_KEY_2 is null
    and RORALGS_KEY_5 = a.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_6 = a.SGBSTDN_CAMP_CODE
    and RORALGS_KEY_3 = case
        when (
            RORPRST_XHS = '3'
            and (
                a.SGBSTDN_STYP_CODE in ('F', '1')
                and RORPRST_XHS_LOCK_IND = 'Y'
            ) or (
                a.SGBSTDN_STYP_CODE not in ('F', '1')
            )
        ) then '1'
        when (
            RORPRST_XHS in ('1', '4')
            and (
                a.SGBSTDN_STYP_CODE in ('F', '1')
                and RORPRST_XHS_LOCK_IND = 'Y'
            ) or (
                a.SGBSTDN_STYP_CODE not in ('F', '1')
            )
        ) then '3'
    end
WHERE a.SGBSTDN_LEVL_CODE = 'UG'
-- AND a.SGBSTDN_PIDM = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001396580')
AND a.SGBSTDN_CAMP_CODE = 'FR'
AND a.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(Y.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y
    WHERE Y.SGBSTDN_PIDM = a.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND NOT EXISTS (
    SELECT 1
    FROM SARADAP
    INNER JOIN SARAPPD
        ON SARAPPD_PIDM = SARADAP_PIDM
        AND SARAPPD_APPL_NO = SARADAP_APPL_NO
        AND SARAPPD_TERM_CODE_ENTRY = SARADAP_TERM_CODE_ENTRY
    INNER JOIN STVAPDC
        ON STVAPDC_CODE = SARAPPD_APDC_CODE
        AND STVAPDC_INST_ACC_IND = 'Y'
        AND STVAPDC_SIGNF_IND = 'Y'
    WHERE SARADAP_PIDM = a.SGBSTDN_PIDM
    AND SARADAP_TERM_CODE_ENTRY > a.SGBSTDN_TERM_CODE_EFF 
    AND SARADAP_TERM_CODE_ENTRY <= ('20' || substr(:AIDY, 3, 2) || '20')
    AND SARADAP_PROGRAM_1 <> a.SGBSTDN_PROGRAM_1
)
AND a.SGBSTDN_STST_CODE IN  ('AS','IL','P1')

;
select rorprst_xhs from rorprst where rorprst_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001396580') and rorprst_period = '202710';