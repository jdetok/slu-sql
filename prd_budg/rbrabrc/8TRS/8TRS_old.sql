--TRANSPORTATION seq #1 
SELECT 
   CASE     
WHEN A.SGBSTDN_LEVL_CODE = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' then 1060
    WHEN A.SGBSTDN_LEVL_CODE = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' then 1165
    WHEN A.SGBSTDN_LEVL_CODE = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 1165
   WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND A.SGBSTDN_STYP_CODE = 'P' AND A.SGBSTDN_TERM_CODE_ADMIT = 
    '20'||SUBSTR(:aidy,3,2)||'15' THEN 1225 --M1 FEE
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND ATTR.SGRSATT_ATTS_CODE = 'M1' THEN 1225 --M2 FEE
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND ATTR.SGRSATT_ATTS_CODE = 'M2' THEN 1350 --M3 FEE
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND ATTR.SGRSATT_ATTS_CODE = 'M3' THEN 1350 --M4 FEE
   END
      FROM SGBSTDN A, RBRAPBG,(SELECT SGRSATT_PIDM, SGRSATT_ATTS_CODE
                                FROM SGRSATT A
                                WHERE A.SGRSATT_ATTS_CODE in ('M1','M2','M3','M4')
                                AND A.SGRSATT_TERM_CODE_EFF = (SELECT MAX(M.SGRSATT_TERM_CODE_EFF)
                                                            FROM SGRSATT M
                                                            where M.SGRSATT_TERM_CODE_EFF = '20'||SUBSTR(:aidy,1,2)||'15'
                                                            AND  A.SGRSATT_PIDM =  M.SGRSATT_PIDM)) ATTR 
         WHERE A.SGBSTDN_TERM_CODE_EFF = 
               (SELECT MAX(B.SGBSTDN_TERM_CODE_EFF)
                  FROM SGBSTDN B
                 WHERE A.SGBSTDN_PIDM = B.SGBSTDN_PIDM
                   AND B.SGBSTDN_TERM_CODE_EFF <= :PERIOD
               )
AND ATTR.SGRSATT_PIDM(+) = A.SGBSTDN_PIDM 
AND RBRAPBG_PIDM = SGBSTDN_PIDM
AND RBRAPBG_PERIOD = :PERIOD
AND A.SGBSTDN_PIDM = :PIDM

-- 2

select 
   CASE
       WHEN A.SGBSTDN_LEVL_CODE = 'UG' then 1060
    WHEN A.SGBSTDN_LEVL_CODE IN ('GR','PL') then 1165
 WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = a.sgbstdn_pidm
             and a.sgbstdn_levl_code = 'PM'
             AND ATTR.SGRSATT_ATTS_CODE = 'M1'
             and z.sfrstcr_term_code = :PERIOD) > 0  THEN 1225
        WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = a.sgbstdn_pidm
             and a.sgbstdn_levl_code = 'PM'
             AND ATTR.SGRSATT_ATTS_CODE = 'M2'
             and z.sfrstcr_term_code = :PERIOD) > 0 THEN 1225
        WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = a.sgbstdn_pidm
             and a.sgbstdn_levl_code = 'PM'
             AND ATTR.SGRSATT_ATTS_CODE = 'M3'
             and z.sfrstcr_term_code = :PERIOD) > 0 THEN 1350
      
      WHEN (SELECT SUM(z.sfrstcr_credit_hr)
             FROM sfrstcr z
             WHERE z.sfrstcr_pidm = a.sgbstdn_pidm
             AND a.sgbstdn_levl_code = 'PM'
             AND a.sgbstdn_styp_code  = 'P'
             AND a.sgbstdn_term_code_admit = :PERIOD
             AND z.sfrstcr_term_code = :PERIOD) > 0 THEN 1350
END
from sgbstdn a,(SELECT SGRSATT_PIDM, SGRSATT_ATTS_CODE
                                FROM SGRSATT A
                                WHERE A.SGRSATT_ATTS_CODE in ('M1','M2','M3','M4')
                                AND A.SGRSATT_TERM_CODE_EFF = (SELECT MAX(M.SGRSATT_TERM_CODE_EFF)
                                                            FROM SGRSATT M
                                                            --WHERE M.SGRSATT_PIDM = RCRAPP1_PIDM
                                                            where M.SGRSATT_TERM_CODE_EFF = '20'||SUBSTR(:aidy,1,2)||'15'
                                                            AND  A.SGRSATT_PIDM =  M.SGRSATT_PIDM)) ATTR 
where a.sgbstdn_term_code_eff = (select max(b.sgbstdn_term_code_eff)
                              from sgbstdn b
                              where b.sgbstdn_term_code_eff <= :period
                              and b.sgbstdn_pidm = a.sgbstdn_pidm)
AND ATTR.SGRSATT_PIDM(+) = A.SGBSTDN_PIDM                               
and a.sgbstdn_pidm = :pidm

-- --transportation default
select
CASE 
    WHEN STDN.SGBSTDN_LEVL_CODE = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' then 1060
    WHEN STDN.SGBSTDN_LEVL_CODE = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' then 1165
    WHEN STDN.SGBSTDN_LEVL_CODE = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 1165
    WHEN STDN.SGBSTDN_LEVL_CODE = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 1350
    WHEN ADAP.SARADAP_LEVL_CODE = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' then 1060
    WHEN ADAP.SARADAP_LEVL_CODE = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' then 1165
    WHEN ADAP.SARADAP_LEVL_CODE = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 1165
    WHEN ADAP.SARADAP_LEVL_CODE = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 1225
END amt    
FROM RBRAPBG, (SELECT SGBSTDN_PIDM, SGBSTDN_LEVL_CODE,SGBSTDN_COLL_CODE_1, SGBSTDN_MAJR_CODE_1, SGBSTDN_CAMP_CODE 
                  FROM SGBSTDN
                  WHERE SGBSTDN_TERM_CODE_EFF = (SELECT MAX (B.SGBSTDN_TERM_CODE_EFF) 
                                                FROM SGBSTDN B
                                               WHERE SGBSTDN_PIDM = SGBSTDN_PIDM
                                               AND B.SGBSTDN_TERM_CODE_EFF <= :PERIOD))STDN,
(SELECT SARADAP_PIDM, SARADAP_LEVL_CODE, SARADAP_COLL_CODE_1, SARADAP_MAJR_CODE_1, SARADAP_CAMP_CODE
                    FROM SARADAP
                    WHERE SARADAP_TERM_CODE_ENTRY = (SELECT MAX (B.SARADAP_TERM_CODE_ENTRY)
                                          FROM SARADAP B
                                          WHERE SARADAP_PIDM = B.SARADAP_PIDM
                                          
                                          AND B.SARADAP_TERM_CODE_ENTRY <= :PERIOD))ADAP
WHERE STDN.SGBSTDN_PIDM(+) = RBRAPBG_PIDM
AND ADAP.SARADAP_PIDM(+) = RBRAPBG_PIDM
AND RBRAPBG_AIDY_CODE = :AIDY                       
AND RBRAPBG_PIDM    = :PIDM