--LAW NOT ENROLLED WITH SGASTDN
SELECT RORALGS_AMT 
FROM SGBSTDN X
JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '1TUI'
    and RORALGS_KEY_5 = X.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_12 = CASE
	    WHEN X.SGBSTDN_FULL_PART_IND = 'P' THEN '8TO11'
	    WHEN (X.SGBSTDN_FULL_PART_IND = 'F' OR X.SGBSTDN_FULL_PART_IND IS NULL) THEN '12+'
    END
WHERE X.SGBSTDN_STST_CODE IN  ('AS','IL','P1')
AND X.SGBSTDN_LEVL_CODE = 'PL'
-- AND X.SGBSTDN_PIDM = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001111350')
AND X.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(Y.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y
    WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND NOT EXISTS (
    SELECT 1
    FROM SARADAP a
    INNER JOIN SARAPPD b
        ON SARAPPD_PIDM = SARADAP_PIDM
        AND SARAPPD_APPL_NO = SARADAP_APPL_NO
        AND SARAPPD_TERM_CODE_ENTRY = SARADAP_TERM_CODE_ENTRY
    INNER JOIN STVAPDC c
        ON STVAPDC_CODE = SARAPPD_APDC_CODE
        AND STVAPDC_INST_ACC_IND = 'Y'
        AND STVAPDC_SIGNF_IND = 'Y'
    WHERE SARADAP_PIDM = X.SGBSTDN_PIDM
    AND SARADAP_PROGRAM_1 = X.SGBSTDN_PROGRAM_1
    AND SARADAP_TERM_CODE_ENTRY > X.SGBSTDN_TERM_CODE_EFF 
    AND SARADAP_TERM_CODE_ENTRY <= ('20' || cast(substr(:AIDY, 3, 2) as int) + 1 || '00')
    AND SARADAP_APPL_NO = (
        select max(z.saradap_appl_no)
        from saradap z
        where z.saradap_pidm = a.saradap_pidm
        and z.saradap_term_code_entry = a.saradap_term_code_entry
    )
    and b.sarappd_seq_no = (
        select max(z.sarappd_seq_no)
        from sarappd z
        where z.sarappd_pidm = b.sarappd_pidm
        and z.sarappd_appl_no = b.sarappd_appl_no
        and z.sarappd_term_code_entry = b.sarappd_term_code_entry
    )
)
--END
;
select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001111350';
select * from saradap where saradap_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001111350');