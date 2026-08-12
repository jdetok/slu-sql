select * from rbrapbg where rbrapbg_activity_date < TO_DATE('12/19/2025', 'MM/DD/YYYY');
select * from rbrapbg;
select count(distinct rbrapbg_pidm) from rbrapbg;
select * from rbrapbc where rbrapbc_activity_date < TO_DATE('12/19/2025', 'MM/DD/YYYY');
select * from rbrapbc;
select * from rbrapbt where rbrapbt_activity_date < TO_DATE('12/19/2025', 'MM/DD/YYYY');
select * from rbrapbt;
desc rbrapbc;

select count (rorstat_pidm) from rorstat where rorstat_aidy_code = '2627';

select rbrapbg_pbgp_code, count(distinct rbrapbg_pidm)  from rbrapbg
group by rbrapbg_pbgp_code;

SELECT a.RORSTAT_PIDM, s.spriden_id
FROM RORSTAT a
INNER JOIN ROBINST r ON r.ROBINST_AIDY_CODE = a.RORSTAT_AIDY_CODE
inner join spriden s on s.spriden_pidm = a.rorstat_pidm and s.spriden_change_ind is null
WHERE a.RORSTAT_AIDY_CODE = :AIDY
-- AND RORSTAT_PIDM = :PIDM
AND (
    EXISTS (
        SELECT 1
        FROM SGBSTDN b
        WHERE b.SGBSTDN_PIDM = a.RORSTAT_PIDM
        AND b.SGBSTDN_LEVL_CODE = 'UG'
        AND b.SGBSTDN_CAMP_CODE <> 'SP'
        AND b.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND b.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN
            WHERE SGBSTDN_PIDM = b.SGBSTDN_PIDM
            AND SGBSTDN_LEVL_CODE = b.SGBSTDN_LEVL_CODE
            AND SGBSTDN_CAMP_CODE = b.SGBSTDN_CAMP_CODE
            AND SGBSTDN_STST_CODE = b.SGBSTDN_STST_CODE
        )
    )
    OR EXISTS (
        SELECT 1
        FROM SARADAP c
        INNER JOIN SARAPPD d 
            ON d.SARAPPD_PIDM = c.SARADAP_PIDM
            AND d.SARAPPD_APPL_NO = c.SARADAP_APPL_NO
            AND d.SARAPPD_TERM_CODE_ENTRY = c.SARADAP_TERM_CODE_ENTRY
        INNER JOIN STVAPDC e
            ON e.STVAPDC_CODE = d.SARAPPD_APDC_CODE
            AND e.STVAPDC_INST_ACC_IND = 'Y'
            AND e.STVAPDC_SIGNF_IND = 'Y'
        WHERE c.SARADAP_PIDM = a.RORSTAT_PIDM
        AND c.SARADAP_CAMP_CODE <> 'SP'
        AND c.SARADAP_LEVL_CODE = 'UG'
        AND c.SARADAP_TERM_CODE_ENTRY = (
            SELECT MAX(SARADAP_TERM_CODE_ENTRY)
            FROM SARADAP
            INNER JOIN SARAPPD
                ON SARAPPD_PIDM = SARADAP_PIDM
                AND SARAPPD_APPL_NO = SARADAP_APPL_NO
                AND SARAPPD_TERM_CODE_ENTRY = SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC
                ON STVAPDC_CODE = SARAPPD_APDC_CODE
                AND STVAPDC_INST_ACC_IND = 'Y'
                AND STVAPDC_SIGNF_IND = 'Y'
            WHERE SARADAP_PIDM = c.SARADAP_PIDM
            AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                (r.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD
        )
        AND d.SARAPPD_SEQ_NO = (
            SELECT MAX(SARAPPD_SEQ_NO)
            FROM SARAPPD
            WHERE SARAPPD_PIDM = d.SARAPPD_PIDM
            AND SARAPPD_SEQ_NO < 99
            AND SARAPPD_TERM_CODE_ENTRY <= d.SARAPPD_TERM_CODE_ENTRY
        ) 
    )
);