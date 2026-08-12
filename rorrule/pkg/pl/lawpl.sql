-- LEGACY GRAD PACKAGING GROUP
-- 202 rows
SELECT RORSTAT_PIDM
FROM RORSTAT
JOIN ROBINST on ROBINST_AIDY_CODE = RORSTAT_AIDY_CODE and ROBINST_STATUS_IND = 'A'
JOIN ROBNYUD on ROBNYUD_PIDM = RORSTAT_PIDM
WHERE RORSTAT_AIDY_CODE = :AIDY
AND RORSTAT_PIDM = :PIDM
AND ROBNYUD_VALUE_197 = 'Y'
AND ROBNYUD_VALUE_198 = 'PL'
AND (
    EXISTS (
        SELECT 1
        FROM SATURN.SGBSTDN E
        JOIN SATURN.STVMAJR M on M.STVMAJR_CODE = E.SGBSTDN_MAJR_CODE_1
            and substr(M.STVMAJR_CIPC_CODE, 0, 4) = substr(ROBNYUD_VALUE_193, 0, 4)
        WHERE E.SGBSTDN_PIDM = RORSTAT_PIDM
        and E.SGBSTDN_FULL_PART_IND <> 'F'
        AND E.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND E.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(F.SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN F
            WHERE F.SGBSTDN_PIDM = E.SGBSTDN_PIDM
            AND SUBSTR(F.SGBSTDN_TERM_CODE_EFF,0,4) <= SUBSTR(ROBINST_AIDY_END_YEAR,0,4)
        )   
    )
    AND NOT EXISTS (
        SELECT 1
        FROM SARADAP a
        JOIN SATURN.STVMAJR M on M.STVMAJR_CODE = a.SARADAP_MAJR_CODE_1
            and substr(M.STVMAJR_CIPC_CODE, 0, 4) <> substr(ROBNYUD_VALUE_193, 0, 4)
        JOIN SARAPPD b on b.SARAPPD_PIDM = a.SARADAP_PIDM
            AND b.SARAPPD_TERM_CODE_ENTRY = a.SARADAP_TERM_CODE_ENTRY
            AND b.SARAPPD_APPL_NO = a.SARADAP_APPL_NO
        JOIN STVAPDC c on c.STVAPDC_CODE = b.SARAPPD_APDC_CODE
            AND c.STVAPDC_INST_ACC_IND = 'Y'
            AND c.STVAPDC_SIGNF_IND = 'Y'
        WHERE a.SARADAP_PIDM = RORSTAT_PIDM
        AND a.SARADAP_FULL_PART_IND <> 'F'
        AND a.SARADAP_TERM_CODE_ENTRY = (
            SELECT MAX(z.SARADAP_TERM_CODE_ENTRY)
            FROM SARADAP z
            WHERE z.SARADAP_PIDM = a.SARADAP_PIDM
            AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (ROBINST_AIDY_END_YEAR || '10') AND ((ROBINST_AIDY_END_YEAR + 1) || '00')
        )
        AND a.SARADAP_APPL_NO = (
            SELECT MAX(z.SARADAP_APPL_NO)
            FROM SARADAP z
            WHERE z.SARADAP_PIDM = a.SARADAP_PIDM
            AND z.SARADAP_TERM_CODE_ENTRY = a.SARADAP_TERM_CODE_ENTRY
        )
        AND b.SARAPPD_SEQ_NO = (
            SELECT MAX(z.SARAPPD_SEQ_NO)
            FROM SARAPPD z
            WHERE z.SARAPPD_PIDM = b.SARAPPD_PIDM
            AND z.SARAPPD_TERM_CODE_ENTRY = b.SARAPPD_TERM_CODE_ENTRY
            AND z.SARAPPD_APPL_NO = b.SARAPPD_APPL_NO
        )
        and not exists (
            select 1
            from sgbstdn z
            where z.sgbstdn_pidm = a.saradap_pidm
            and z.sgbstdn_term_code_eff = a.saradap_term_code_entry
            and z.sgbstdn_levl_code = 'PL'
            and z.sgbstdn_majr_code_1 = 'LAW'
            and z.sgbstdn_majr_code_2 = a.saradap_majr_code_1
        )
    )
)
;