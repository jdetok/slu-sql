-- SGBSTDN sequence: assumes FT for UG and GR until cutoff date
SELECT case
	when (
            (a.SGBSTDN_LEVL_CODE = 'PL' and a.SGBSTDN_FULL_PART_IND = 'P')
            or (
                sysdate >= (select cutoff from sfs_utility.pbdg_cutoff_dates where period = :PERIOD) and (
                    (
                        a.SGBSTDN_LEVL_CODE = 'UG' 
                        and rokmisc.F_CALC_STUD_BILL_HRS(:PERIOD, a.SGBSTDN_PIDM, 'N') < 12
                    ) or (
                        a.SGBSTDN_LEVL_CODE = 'GR' 
                        and rokmisc.F_CALC_STUD_BILL_HRS(:PERIOD, a.SGBSTDN_PIDM, 'N') < 6
                    )
                )
            ) 
        ) then (RORALGS_AMT / 2)

	else RORALGS_AMT
end as amt
FROM SGBSTDN a
INNER JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    AND RORALGS_KEY_1 = 'PBDG'
    AND RORALGS_KEY_4 = '7BS'
    AND RORALGS_KEY_5 = a.SGBSTDN_LEVL_CODE
    AND RORALGS_KEY_9 IS NULL
    AND RORALGS_KEY_11 IS NULL
WHERE a.SGBSTDN_LEVL_CODE in ('UG', 'GR', 'PL', 'PM')
and a.SGBSTDN_STST_CODE in ('AS', 'IL')
-- AND a.SGBSTDN_PIDM = :PIDM
AND a.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN
    WHERE SGBSTDN_PIDM = a.SGBSTDN_PIDM
    AND SGBSTDN_TERM_CODE_EFF <= :PERIOD
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
    AND SARADAP_TERM_CODE_ENTRY <= ('20' || cast(substr(:AIDY, 3, 2) as int) + 1 || '00')
    AND SARADAP_PROGRAM_1 = a.SGBSTDN_PROGRAM_1
)