-- og from banner 09/17
-- 747 rows, > 10 seconds
SELECT DISTINCT(RORSTAT_PIDM)
  FROM RORSTAT, ROBINST
 WHERE ROBINST_STATUS_IND = 'A'
      AND (RORSTAT_PIDM IN 
       (SELECT A.SARADAP_PIDM
	  FROM SATURN.SARADAP A
         WHERE A.SARADAP_PIDM = RORSTAT_PIDM
           AND A.SARADAP_CAMP_CODE = 'SP'
           AND A.SARADAP_STYP_CODE = 'X'
           AND A.SARADAP_TERM_CODE_ENTRY =
              (SELECT MAX(B.SARADAP_TERM_CODE_ENTRY)                                  
	         FROM SARADAP B
                WHERE B.SARADAP_TERM_CODE_ENTRY IN
                (SELECT RORCRHR_TERM_CODE
                    FROM RORCRHR
                WHERE RORCRHR_AIDY_CODE = RORSTAT_AIDY_CODE)
                  AND B.SARADAP_PIDM = A.SARADAP_PIDM)) 
    OR ((RORSTAT_PIDM IN 
      (SELECT D.SGBSTDN_PIDM 
         FROM SATURN.SGBSTDN D
        WHERE D.SGBSTDN_PIDM = RORSTAT_PIDM
          AND D.SGBSTDN_CAMP_CODE = 'SP'
          AND D.SGBSTDN_STYP_CODE = 'X'
          AND D.SGBSTDN_STST_CODE IN ('AS','P1')
          AND D.SGBSTDN_TERM_CODE_EFF =
             (SELECT MAX(E.SGBSTDN_TERM_CODE_EFF)
                FROM SGBSTDN E 
               WHERE SUBSTR(E.SGBSTDN_TERM_CODE_EFF,0,4) <= SUBSTR(ROBINST_AIDY_END_YEAR,0,4)
                 AND E.SGBSTDN_PIDM = D.SGBSTDN_PIDM))
    AND RORSTAT_PIDM NOT IN 
       (SELECT E.SARADAP_PIDM
          FROM SATURN.SARADAP E
          WHERE E.SARADAP_TERM_CODE_ENTRY IN
                (SELECT RORCRHR_TERM_CODE
                    FROM RORCRHR
                WHERE RORCRHR_AIDY_CODE = RORSTAT_AIDY_CODE)
            AND E.SARADAP_PIDM=RORSTAT_PIDM))))
AND RORSTAT_AIDY_CODE = :AIDY        
-- AND RORSTAT_PIDM    =:PIDM
;

-- new
-- 656 rows, < 1 second
select spriden_id from (
    select rorstat_pidm from rorstat
    where rorstat_aidy_code = :AIDY
    and rorstat_tgrp_code = 'MADRID'
-- AND RORSTAT_PIDM = :PIDM
) a
left join (
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
    JOIN SARAATT X on X.SARAATT_PIDM = A.SARADAP_PIDM
        and X.SARAATT_TERM_CODE = (
            SELECT MAX(z.SARAATT_TERM_CODE)
            FROM SARAATT z
            WHERE z.SARAATT_PIDM = X.SARAATT_PIDM
        )
        and X.SARAATT_ATTS_CODE not in ('SPSY', 'SPNS', 'SPNV', 'SPWK', 'SPNU', 'SPNT', 'SGI')
    WHERE A.SARADAP_PIDM = RORSTAT_PIDM
    AND A.SARADAP_CAMP_CODE = 'SP'
    AND A.SARADAP_STYP_CODE = 'X'
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
    JOIN SGRSATT X 
        on X.SGRSATT_PIDM = D.SGBSTDN_PIDM
        and X.SGRSATT_TERM_CODE_EFF = (
            SELECT MAX(z.SGRSATT_TERM_CODE_EFF)
            FROM SGRSATT z
            WHERE z.SGRSATT_PIDM = X.SGRSATT_PIDM
        )
        and X.SGRSATT_ATTS_CODE not in ('SPSY', 'SPNS', 'SPNV', 'SPWK', 'SPNU', 'SPNT', 'SGI')
    WHERE D.SGBSTDN_PIDM = RORSTAT_PIDM
    
    AND D.SGBSTDN_CAMP_CODE = 'SP'
    AND D.SGBSTDN_STYP_CODE = 'X'
    AND D.SGBSTDN_STST_CODE IN ('AS','P1')
          AND D.SGBSTDN_TERM_CODE_EFF <= robinst_aidy_end_year || '20'
) and not exists (
    SELECT 1
    FROM SATURN.SARADAP E
    WHERE E.SARADAP_TERM_CODE_ENTRY <= robinst_aidy_end_year + 1 || '00'
    AND E.SARADAP_PIDM = RORSTAT_PIDM
)))
) b on b.rorstat_pidm = a.rorstat_pidm
join spriden on spriden_change_ind is null and spriden_pidm = a.rorstat_pidm
where b.rorstat_pidm is null
;
select * from rorstat;