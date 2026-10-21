-- madrid PB rorrule
SELECT a.RORSTAT_PIDM
FROM RORSTAT a
INNER JOIN ROBINST r ON r.ROBINST_AIDY_CODE = a.RORSTAT_AIDY_CODE
WHERE a.RORSTAT_AIDY_CODE = :AIDY
AND RORSTAT_PIDM = :PIDM
AND (
    EXISTS (
        SELECT 1
        FROM SGBSTDN b
        WHERE b.SGBSTDN_PIDM = a.RORSTAT_PIDM
        AND b.SGBSTDN_CAMP_CODE = 'SP' 
        AND b.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND b.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN
            WHERE SGBSTDN_PIDM = b.SGBSTDN_PIDM
            AND SGBSTDN_LEVL_CODE = b.SGBSTDN_LEVL_CODE
            AND SGBSTDN_CAMP_CODE = b.SGBSTDN_CAMP_CODE
            AND SGBSTDN_STST_CODE = b.SGBSTDN_STST_CODE
        )
    ) OR (
        EXISTS ( -- DEPOSITED MADRID APP
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
                AND e.STVAPDC_STDN_ACC_IND = 'Y'
            WHERE c.SARADAP_PIDM = a.RORSTAT_PIDM
            AND c.SARADAP_CAMP_CODE = 'SP'
            AND c.SARADAP_TERM_CODE_ENTRY = (
                SELECT MAX(SARADAP_TERM_CODE_ENTRY)
                FROM SARADAP
                WHERE SARADAP_PIDM = c.SARADAP_PIDM
                AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                    (r.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD
            )
            AND d.SARAPPD_SEQ_NO = (
                SELECT MAX(SARAPPD_SEQ_NO)
                FROM SARAPPD
                WHERE SARAPPD_PIDM = d.SARAPPD_PIDM
                AND SARAPPD_SEQ_NO < 99
                AND SARAPPD_TERM_CODE_ENTRY = d.SARAPPD_TERM_CODE_ENTRY
            ) 
        )
    ) OR (
        EXISTS ( -- MADRID ADMITTED, NO STL ADMITTED
            SELECT 1
            FROM SARADAP f
            INNER JOIN SARAPPD g
                ON g.SARAPPD_PIDM = f.SARADAP_PIDM
                AND g.SARAPPD_APPL_NO = f.SARADAP_APPL_NO
                AND g.SARAPPD_TERM_CODE_ENTRY = f.SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC h
                ON h.STVAPDC_CODE = g.SARAPPD_APDC_CODE
                AND h.STVAPDC_INST_ACC_IND = 'Y'
                AND h.STVAPDC_SIGNF_IND = 'Y'
                AND h.STVAPDC_STDN_ACC_IND <> 'Y' -- NOT DEPOSITED
            WHERE f.SARADAP_PIDM = a.RORSTAT_PIDM
            AND f.SARADAP_CAMP_CODE = 'SP'
            AND f.SARADAP_TERM_CODE_ENTRY = (
                SELECT MAX(SARADAP_TERM_CODE_ENTRY)
                FROM SARADAP
                WHERE SARADAP_PIDM = f.SARADAP_PIDM
                AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                    (r.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD
            )
            AND g.SARAPPD_SEQ_NO = (
                SELECT MAX(SARAPPD_SEQ_NO)
                FROM SARAPPD
                WHERE SARAPPD_PIDM = g.SARAPPD_PIDM
                AND SARAPPD_SEQ_NO < 99
                AND SARAPPD_TERM_CODE_ENTRY = g.SARAPPD_TERM_CODE_ENTRY
            ) 
        ) AND NOT EXISTS ( -- NO STL ADMITTED
            SELECT 1
            FROM SARADAP i
            INNER JOIN SARAPPD j
                ON j.SARAPPD_PIDM = i.SARADAP_PIDM
                AND j.SARAPPD_APPL_NO = i.SARADAP_APPL_NO
                AND j.SARAPPD_TERM_CODE_ENTRY = i.SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC k
                ON k.STVAPDC_CODE = j.SARAPPD_APDC_CODE
                AND k.STVAPDC_INST_ACC_IND = 'Y'
                AND k.STVAPDC_SIGNF_IND = 'Y'
                AND k.STVAPDC_STDN_ACC_IND <> 'Y' -- NOT DEPOSITED
            WHERE i.SARADAP_PIDM = a.RORSTAT_PIDM
            AND i.SARADAP_CAMP_CODE = 'FR'
            AND i.SARADAP_TERM_CODE_ENTRY = (
                SELECT MAX(SARADAP_TERM_CODE_ENTRY)
                FROM SARADAP
                WHERE SARADAP_PIDM = i.SARADAP_PIDM
                AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                    (r.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD
            )
            AND j.SARAPPD_SEQ_NO = (
                SELECT MAX(SARAPPD_SEQ_NO)
                FROM SARAPPD
                WHERE SARAPPD_PIDM = j.SARAPPD_PIDM
                AND SARAPPD_SEQ_NO < 99
                AND SARAPPD_TERM_CODE_ENTRY = j.SARAPPD_TERM_CODE_ENTRY
            ) 
        )
    )
)

;

select distinct(rorstat_pidm)
from rorstat
inner join rbrapbc on rbrapbc_pidm = rorstat_pidm
where rbrapbc_pbcp_code = '23PF'
and rbrapbc_period = '202710'
and rorstat_aidy_code = '2627'
and rbrapbc_run_name = 'ACTUAL'
and rorstat_tgrp_code <> 'WITHDR';

desc rbrabcp;
desc rbrapbc;


-- 
SELECT a.RORSTAT_PIDM
FROM RORSTAT a
INNER JOIN ROBINST r ON r.ROBINST_AIDY_CODE = a.RORSTAT_AIDY_CODE
WHERE a.RORSTAT_AIDY_CODE = :AIDY
-- AND RORSTAT_PIDM = :PIDM
AND (
    EXISTS (
        SELECT 1
        FROM SGBSTDN b
        WHERE b.SGBSTDN_PIDM = a.RORSTAT_PIDM
        AND b.SGBSTDN_CAMP_CODE = 'SP' 
        AND b.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND b.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN
            WHERE SGBSTDN_PIDM = b.SGBSTDN_PIDM
            AND SGBSTDN_LEVL_CODE = b.SGBSTDN_LEVL_CODE
            AND SGBSTDN_CAMP_CODE = b.SGBSTDN_CAMP_CODE
            AND SGBSTDN_STST_CODE = b.SGBSTDN_STST_CODE
        )
    ) OR (
        EXISTS ( -- DEPOSITED MADRID APP
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
                AND e.STVAPDC_STDN_ACC_IND = 'Y'
            WHERE c.SARADAP_PIDM = a.RORSTAT_PIDM
            AND c.SARADAP_CAMP_CODE = 'SP'
            AND c.SARADAP_TERM_CODE_ENTRY = (
                SELECT MAX(SARADAP_TERM_CODE_ENTRY)
                FROM SARADAP
                WHERE SARADAP_PIDM = c.SARADAP_PIDM
                AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                    (r.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD
            )
            AND d.SARAPPD_SEQ_NO = (
                SELECT MAX(SARAPPD_SEQ_NO)
                FROM SARAPPD
                WHERE SARAPPD_PIDM = d.SARAPPD_PIDM
                AND SARAPPD_SEQ_NO < 99
                AND SARAPPD_TERM_CODE_ENTRY = d.SARAPPD_TERM_CODE_ENTRY
            ) 
        )
    ) OR (
        EXISTS ( -- MADRID ADMITTED, NO STL ADMITTED
            SELECT 1
            FROM SARADAP f
            INNER JOIN SARAPPD g
                ON g.SARAPPD_PIDM = f.SARADAP_PIDM
                AND g.SARAPPD_APPL_NO = f.SARADAP_APPL_NO
                AND g.SARAPPD_TERM_CODE_ENTRY = f.SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC h
                ON h.STVAPDC_CODE = g.SARAPPD_APDC_CODE
                AND h.STVAPDC_INST_ACC_IND = 'Y'
                AND h.STVAPDC_SIGNF_IND = 'Y'
                -- AND h.STVAPDC_STDN_ACC_IND <> 'Y' -- NOT DEPOSITED
                AND h.STVAPDC_STDN_ACC_IND IS NULL
            WHERE f.SARADAP_PIDM = a.RORSTAT_PIDM
            AND f.SARADAP_CAMP_CODE = 'SP'
            AND f.SARADAP_TERM_CODE_ENTRY = (
                SELECT MAX(SARADAP_TERM_CODE_ENTRY)
                FROM SARADAP
                WHERE SARADAP_PIDM = f.SARADAP_PIDM
                AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                    (r.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD
            )
            AND g.SARAPPD_SEQ_NO = (
                SELECT MAX(SARAPPD_SEQ_NO)
                FROM SARAPPD
                WHERE SARAPPD_PIDM = g.SARAPPD_PIDM
                AND SARAPPD_SEQ_NO < 99
                AND SARAPPD_TERM_CODE_ENTRY = g.SARAPPD_TERM_CODE_ENTRY
            ) 
        ) AND NOT EXISTS ( -- NO STL ADMITTED
            SELECT 1
            FROM SARADAP i
            INNER JOIN SARAPPD j
                ON j.SARAPPD_PIDM = i.SARADAP_PIDM
                AND j.SARAPPD_APPL_NO = i.SARADAP_APPL_NO
                AND j.SARAPPD_TERM_CODE_ENTRY = i.SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC k
                ON k.STVAPDC_CODE = j.SARAPPD_APDC_CODE
                AND k.STVAPDC_INST_ACC_IND = 'Y'
                AND k.STVAPDC_SIGNF_IND = 'Y'
                -- AND k.STVAPDC_STDN_ACC_IND <> 'Y' -- NOT DEPOSITED
                AND k.STVAPDC_STDN_ACC_IND IS NULL
            WHERE i.SARADAP_PIDM = a.RORSTAT_PIDM
            AND i.SARADAP_CAMP_CODE = 'FR'
            AND i.SARADAP_TERM_CODE_ENTRY = (
                SELECT MAX(SARADAP_TERM_CODE_ENTRY)
                FROM SARADAP
                WHERE SARADAP_PIDM = i.SARADAP_PIDM
                AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                    (r.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD
            )
            AND j.SARAPPD_SEQ_NO = (
                SELECT MAX(SARAPPD_SEQ_NO)
                FROM SARAPPD
                WHERE SARAPPD_PIDM = j.SARAPPD_PIDM
                AND SARAPPD_SEQ_NO < 99
                AND SARAPPD_TERM_CODE_ENTRY = j.SARAPPD_TERM_CODE_ENTRY
            ) 
        )
    )
)




            ;