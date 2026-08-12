-- GRAD PB RORRULE

-- 001501850 | 1510557 going into review

SELECT A.RORSTAT_PIDM, spriden_id
FROM RORSTAT A
join spriden on spriden_pidm = rorstat_pidm and spriden_change_ind is null
INNER JOIN ROBINST R ON R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
WHERE A.RORSTAT_AIDY_CODE = :AIDY   
--AND RORSTAT_PIDM = :PIDM   
AND (
     EXISTS (
        SELECT 1
        FROM SGBSTDN B
        WHERE B.SGBSTDN_PIDM = A.RORSTAT_PIDM
        AND B.SGBSTDN_LEVL_CODE = 'GR'
        AND B.SGBSTDN_CAMP_CODE <> 'SP'
        AND B.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND B.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN
            WHERE SGBSTDN_PIDM = B.SGBSTDN_PIDM
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
            SELECT MAX(SARADAP_TERM_CODE_ENTRY)
            FROM SARADAP
            WHERE SARADAP_PIDM = C.SARADAP_PIDM
            AND SARADAP_TERM_CODE_ENTRY BETWEEN 
                (R.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD   
        )
        AND D.SARAPPD_SEQ_NO = (
            SELECT MAX(SARAPPD_SEQ_NO)
            FROM SARAPPD
            WHERE SARAPPD_PIDM = D.SARAPPD_PIDM
            AND SARAPPD_APPL_NO = D.SARAPPD_APPL_NO
            AND SARAPPD_SEQ_NO < 99
            AND SARAPPD_TERM_CODE_ENTRY = D.SARAPPD_TERM_CODE_ENTRY
        ) 
    )
);
select * from saradap 
join sarappd 
    on sarappd_pidm = saradap_pidm
    and sarappd_appl_no = saradap_appl_no
where saradap_pidm = 1510557;

select * from sarappd a
where a.sarappd_pidm = 1510557
and a.sarappd_seq_no = (
    select max(z.sarappd_seq_no)
    from sarappd z
    where z.sarappd_pidm = a.sarappd_pidm
    and z.sarappd_appl_no = a.sarappd_appl_no
);