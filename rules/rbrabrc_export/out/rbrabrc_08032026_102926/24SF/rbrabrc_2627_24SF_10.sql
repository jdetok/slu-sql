-- only madrid group will get this one, so just need to look for SPSA, FR campus
-- may need one for saradap as well
-- line 447 in madrid tuition rule
-- - janice confirmed don't need saradap for this one

-- join spriden on spriden_change_ind is null and spriden_pidm = a.sgbstdn_pidm

-- fixed version with proper sgrsatt term code retrieval 08/03/2026
SELECT RORALGS_AMT
FROM SGBSTDN a
JOIN SGRSATT b on b.SGRSATT_PIDM = a.SGBSTDN_PIDM
    and b.SGRSATT_ATTS_CODE = 'SPSA'
    and b.SGRSATT_TERM_CODE_EFF = (
        select max(z.SGRSATT_TERM_CODE_EFF)
        from SGRSATT z
        where z.SGRSATT_PIDM = b.SGRSATT_PIDM
        and z.SGRSATT_TERM_CODE_EFF <= :PERIOD
    )
JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '24SF'
    and RORALGS_KEY_5 = a.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_6 = a.SGBSTDN_CAMP_CODE
    and RORALGS_KEY_10 = b.SGRSATT_ATTS_CODE
WHERE a.SGBSTDN_STST_CODE IN  ('AS','IL')
AND a.SGBSTDN_TERM_CODE_EFF = (
    select max(z.SGBSTDN_TERM_CODE_EFF)
    from SGBSTDN z
    where SGBSTDN_PIDM = a.SGBSTDN_PIDM
    and SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND a.SGBSTDN_PIDM = :PIDM

; 

-- old rule from banner 
-- only madrid group will get this one, so just need to look for SPSA, FR campus
-- may need one for saradap as well
-- line 447 in madrid tuition rule
-- - janice confirmed don't need saradap for this one

SELECT RORALGS_AMT
FROM SGBSTDN a, RORALGS, SGRSATT X
WHERE a.SGBSTDN_STST_CODE IN  ('AS','IL')
AND RORALGS_KEY_1 = 'PBDG' 
AND RORALGS_KEY_4 = '24SF'
AND CASE
    WHEN a.SGBSTDN_LEVL_CODE = 'UG' THEN 'UG'
END = RORALGS_KEY_5
AND CASE
    WHEN a.SGBSTDN_CAMP_CODE = 'FR' THEN 'FR'
END = RORALGS_KEY_6
AND CASE -- attribute code
    WHEN X.SGRSATT_ATTS_CODE = 'SPSA' THEN 'SPSA'
END = RORALGS_KEY_10
AND a.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN
    WHERE SGBSTDN_PIDM = a.SGBSTDN_PIDM
    AND SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND X.SGRSATT_TERM_CODE_EFF = :PERIOD
	AND SGRSATT_PIDM = X.SGRSATT_PIDM
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
    AND SARADAP_TERM_CODE_ENTRY <= ('20' || cast(substr(:AIDY, 3, 2) as int) + 1 || '00')
    AND SARADAP_PROGRAM_1 <> a.SGBSTDN_PROGRAM_1
)
AND a.SGBSTDN_PIDM = X.SGRSATT_PIDM
AND a.SGBSTDN_PIDM = :PIDM
AND RORALGS_AIDY_CODE = :AIDY

;