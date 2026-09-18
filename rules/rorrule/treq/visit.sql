-- og banner 9/17
-- 1005
SELECT DISTINCT(RORSTAT_PIDM)
  FROM RORSTAT
 WHERE (RORSTAT_PIDM IN
   (SELECT A.SARADAP_PIDM
      FROM SATURN.SARADAP A
         WHERE A.SARADAP_PIDM = RORSTAT_PIDM
           AND A.SARADAP_STYP_CODE IN ('X','Y')
           AND A.SARADAP_TERM_CODE_ENTRY =
              (SELECT MAX(B.SARADAP_TERM_CODE_ENTRY)                                 
                 FROM SARADAP B
                WHERE B.SARADAP_TERM_CODE_ENTRY IN
                (SELECT SORXREF_EDI_QLFR
                    FROM SORXREF
                WHERE SORXREF_EDI_VALUE = 'ALL_TERMS'
                  AND SORXREF_XLBL_CODE = 'ZSFS_VAR'
                  AND SORXREF_BANNER_VALUE = RORSTAT_AIDY_CODE)
                  AND B.SARADAP_PIDM = A.SARADAP_PIDM))
    OR ((RORSTAT_PIDM IN
      (SELECT D.SGBSTDN_PIDM
         FROM SATURN.SGBSTDN D
        WHERE D.SGBSTDN_PIDM = RORSTAT_PIDM
          AND D.SGBSTDN_STYP_CODE IN ('X','Y')
          AND D.SGBSTDN_TERM_CODE_EFF =
             (SELECT MAX(E.SGBSTDN_TERM_CODE_EFF)
                FROM SGBSTDN E
               WHERE E.SGBSTDN_PIDM = D.SGBSTDN_PIDM))
    AND RORSTAT_PIDM NOT IN
       (SELECT E.SARADAP_PIDM
          FROM SATURN.SARADAP E
          WHERE E.SARADAP_TERM_CODE_ENTRY IN
                (SELECT SORXREF_EDI_QLFR
                    FROM SORXREF
                WHERE SORXREF_EDI_VALUE = 'ALL_TERMS'
                  AND SORXREF_XLBL_CODE = 'ZSFS_VAR'
                  AND SORXREF_BANNER_VALUE = RORSTAT_AIDY_CODE)
            AND E.SARADAP_PIDM=RORSTAT_PIDM))))
AND RORSTAT_AIDY_CODE = :AIDY     
-- AND RORSTAT_PIDM =: PIDM
;

SELECT DISTINCT RORSTAT_PIDM
FROM RORSTAT
JOIN ROBINST on ROBINST_AIDY_CODE = RORSTAT_AIDY_CODE and ROBINST_STATUS_IND = 'A'
where RORSTAT_AIDY_CODE = :AIDY 
AND ( exists (
    SELECT 1
    FROM SARADAP A
    join sarappd b on b.sarappd_pidm = a.saradap_pidm 
        and b.sarappd_term_code_entry = a.saradap_term_code_entry
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_inst_acc_ind = 'Y'
    WHERE A.SARADAP_PIDM = RORSTAT_PIDM
    AND A.SARADAP_STYP_CODE in ('X','Y')
    AND A.SARADAP_TERM_CODE_ENTRY = (
        SELECT MAX(B.SARADAP_TERM_CODE_ENTRY)                                  
        FROM SARADAP B
        WHERE B.SARADAP_TERM_CODE_ENTRY <= robinst_aidy_end_year + 1 || '00'
        AND B.SARADAP_PIDM = A.SARADAP_PIDM
    )
    and a.saradap_appl_no = (
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
) OR ( exists (
    SELECT 1
    FROM SATURN.SGBSTDN D
    WHERE D.SGBSTDN_PIDM = RORSTAT_PIDM
    AND D.SGBSTDN_STYP_CODE in ('X','Y')
    AND D.SGBSTDN_STST_CODE IN ('AS','P1')
          AND D.SGBSTDN_TERM_CODE_EFF <= robinst_aidy_end_year || '20'
) and not exists (
    SELECT 1
    FROM SATURN.SARADAP E
    WHERE E.SARADAP_TERM_CODE_ENTRY <= robinst_aidy_end_year + 1 || '00'
    AND E.SARADAP_PIDM = RORSTAT_PIDM
)))
AND RORSTAT_PIDM =: PIDM
;