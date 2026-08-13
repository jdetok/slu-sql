select spriden_id as bid, spriden_last_name || ', ' || spriden_first_name as name
from sgbstdn a
join stvmajr m on m.stvmajr_code = a.sgbstdn_majr_code_1
join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
where a.sgbstdn_stst_code in ('AS','IL', 'P1')
and m.stvmajr_cipc_code = '511201'
and a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= '202620'
)
;

select spriden_id, spriden_last_name || ', ' || spriden_first_name as name, sgbstdn.*
from sgbstdn
join spriden on spriden_pidm = sgbstdn_pidm and spriden_change_ind is null
where spriden_id = '000241123'
and sgbstdn_levl_code <> 'UG';

-- UG PB RORRULE
SELECT A.RORSTAT_PIDM
FROM RORSTAT A
INNER JOIN ROBINST R ON R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
join spriden on spriden_pidm = rorstat_pidm and spriden_change_ind is null
WHERE A.RORSTAT_AIDY_CODE = :AIDY   
-- AND RORSTAT_PIDM = :PIDM   
AND (
    EXISTS (
        SELECT 1
        FROM SGBSTDN B
        WHERE B.SGBSTDN_PIDM = A.RORSTAT_PIDM
        AND B.SGBSTDN_LEVL_CODE = 'UG'
        AND B.SGBSTDN_CAMP_CODE <> 'SP'
        AND B.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND B.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(Z.SGBSTDN_TERM_CODE_EFF) FROM SGBSTDN Z
            WHERE Z.SGBSTDN_PIDM = B.SGBSTDN_PIDM
            AND Z.SGBSTDN_TERM_CODE_EFF <= (R.ROBINST_AIDY_END_YEAR || '00')
        )
        AND NOT EXISTS ( -- NO NEWER SARADAP RECORD FOR A DIFFERENT LEVEL
            SELECT 1
            FROM SARADAP C
            INNER JOIN SARAPPD D 
                ON D.SARAPPD_PIDM = C.SARADAP_PIDM
                AND D.SARAPPD_APPL_NO = C.SARADAP_APPL_NO
                AND D.SARAPPD_TERM_CODE_ENTRY = C.SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC E
                ON E.STVAPDC_CODE = D.SARAPPD_APDC_CODE
                AND E.STVAPDC_INST_ACC_IND = 'Y'
                AND E.STVAPDC_SIGNF_IND = 'Y'
            WHERE C.SARADAP_PIDM = A.RORSTAT_PIDM
            AND D.SARAPPD_SEQ_NO = (
                SELECT MAX(Z.SARAPPD_SEQ_NO) FROM SARAPPD Z
                WHERE Z.SARAPPD_PIDM = D.SARAPPD_PIDM
                AND Z.SARAPPD_TERM_CODE_ENTRY = D.SARAPPD_TERM_CODE_ENTRY
                AND Z.SARAPPD_APPL_NO = D.SARAPPD_APPL_NO
            )
            AND C.SARADAP_LEVL_CODE <> 'UG'
            AND C.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD   
        )
    )
    OR EXISTS (
        SELECT 1
        FROM SARADAP C
        INNER JOIN SARAPPD D 
            ON D.SARAPPD_PIDM = C.SARADAP_PIDM
            AND D.SARAPPD_APPL_NO = C.SARADAP_APPL_NO
            AND D.SARAPPD_TERM_CODE_ENTRY = C.SARADAP_TERM_CODE_ENTRY
        INNER JOIN STVAPDC E
            ON E.STVAPDC_CODE = D.SARAPPD_APDC_CODE
            AND E.STVAPDC_INST_ACC_IND = 'Y'
            AND E.STVAPDC_SIGNF_IND = 'Y'
        WHERE C.SARADAP_PIDM = A.RORSTAT_PIDM
        AND C.SARADAP_LEVL_CODE = 'UG'
        AND C.SARADAP_CAMP_CODE <> 'SP'
        AND C.SARADAP_TERM_CODE_ENTRY = (
            SELECT MAX(Z.SARADAP_TERM_CODE_ENTRY) FROM SARADAP Z
            WHERE Z.SARADAP_PIDM = C.SARADAP_PIDM
            AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD   
            AND Z.SARADAP_APPL_NO = C.SARADAP_APPL_NO
        )
        AND D.SARAPPD_SEQ_NO = (
            SELECT MAX(Z.SARAPPD_SEQ_NO) FROM SARAPPD Z
            WHERE Z.SARAPPD_PIDM = D.SARAPPD_PIDM
            AND Z.SARAPPD_TERM_CODE_ENTRY = D.SARAPPD_TERM_CODE_ENTRY
            AND Z.SARAPPD_APPL_NO = D.SARAPPD_APPL_NO
        ) 
    )
)
and spriden_id = '000241123';

-- GR PB RORRULE
SELECT A.RORSTAT_PIDM
FROM RORSTAT A
join spriden on spriden_pidm = rorstat_pidm and spriden_change_ind is null
INNER JOIN ROBINST R ON R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
WHERE A.RORSTAT_AIDY_CODE = :AIDY   
-- AND RORSTAT_PIDM = :PIDM   
AND (
    EXISTS (
        SELECT 1
        FROM SGBSTDN B
        WHERE B.SGBSTDN_PIDM = A.RORSTAT_PIDM
        AND B.SGBSTDN_LEVL_CODE = 'GR'
        AND B.SGBSTDN_CAMP_CODE <> 'SP'
        AND B.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND B.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(Z.SGBSTDN_TERM_CODE_EFF) FROM SGBSTDN Z
            WHERE Z.SGBSTDN_PIDM = B.SGBSTDN_PIDM
            AND Z.SGBSTDN_TERM_CODE_EFF <= (R.ROBINST_AIDY_END_YEAR || '00')
        )
        AND NOT EXISTS ( -- NO NEWER SARADAP RECORD FOR A DIFFERENT LEVEL
            SELECT 1
            FROM SARADAP C
            INNER JOIN SARAPPD D 
                ON D.SARAPPD_PIDM = C.SARADAP_PIDM
                AND D.SARAPPD_APPL_NO = C.SARADAP_APPL_NO
                AND D.SARAPPD_TERM_CODE_ENTRY = C.SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC E
                ON E.STVAPDC_CODE = D.SARAPPD_APDC_CODE
                AND E.STVAPDC_INST_ACC_IND = 'Y'
                AND E.STVAPDC_SIGNF_IND = 'Y'
            WHERE C.SARADAP_PIDM = A.RORSTAT_PIDM
            AND D.SARAPPD_SEQ_NO = (
                SELECT MAX(Z.SARAPPD_SEQ_NO) FROM SARAPPD Z
                WHERE Z.SARAPPD_PIDM = D.SARAPPD_PIDM
                AND Z.SARAPPD_TERM_CODE_ENTRY = D.SARAPPD_TERM_CODE_ENTRY
                AND Z.SARAPPD_APPL_NO = D.SARAPPD_APPL_NO
            )
            AND C.SARADAP_LEVL_CODE <> 'GR'
            AND C.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD   
        )
    )
    OR EXISTS (
        SELECT 1
        FROM SARADAP C
        INNER JOIN SARAPPD D 
            ON D.SARAPPD_PIDM = C.SARADAP_PIDM
            AND D.SARAPPD_APPL_NO = C.SARADAP_APPL_NO
            AND D.SARAPPD_TERM_CODE_ENTRY = C.SARADAP_TERM_CODE_ENTRY
        INNER JOIN STVAPDC E
            ON E.STVAPDC_CODE = D.SARAPPD_APDC_CODE
            AND E.STVAPDC_INST_ACC_IND = 'Y'
            AND E.STVAPDC_SIGNF_IND = 'Y'
        WHERE C.SARADAP_PIDM = A.RORSTAT_PIDM
        AND C.SARADAP_LEVL_CODE = 'GR'
        AND C.SARADAP_CAMP_CODE <> 'SP'
        AND C.SARADAP_TERM_CODE_ENTRY = (
            SELECT MAX(Z.SARADAP_TERM_CODE_ENTRY) FROM SARADAP Z
            WHERE Z.SARADAP_PIDM = C.SARADAP_PIDM
            AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD   
            AND Z.SARADAP_APPL_NO = C.SARADAP_APPL_NO
        )
        AND D.SARAPPD_SEQ_NO = (
            SELECT MAX(Z.SARAPPD_SEQ_NO) FROM SARAPPD Z
            WHERE Z.SARAPPD_PIDM = D.SARAPPD_PIDM
            AND Z.SARAPPD_TERM_CODE_ENTRY = D.SARAPPD_TERM_CODE_ENTRY
            AND Z.SARAPPD_APPL_NO = D.SARAPPD_APPL_NO
        ) 
    )
);
-- and spriden_id = '000241123';