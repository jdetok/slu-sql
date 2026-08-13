-- seq 1
--Fees
--seq 1 hours have been frozen

SELECT 
   CASE 
    -- ug not PS FT, PT, LHT
    WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 <> 'PS' and RORENRL_FINAID_ADJ_HR >= 12 then 422
    WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 <> 'PS' and RORENRL_FINAID_ADJ_HR BETWEEN 6 AND 11 then 270
    WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 <> 'PS' and RORENRL_FINAID_ADJ_HR < 6 then 0
    -- ug PS FT, PT
    WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' AND RORENRL_FINAID_ADJ_HR >= 6 then 100
    WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' AND RORENRL_FINAID_ADJ_HR < 6 THEN 50
    -- GR, not GG, PS 
    WHEN A.SGBSTDN_LEVL_CODE = 'GR' and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6') AND A.SGBSTDN_COLL_CODE_1 = 'PS' then 100
    -- GR, not GG, (not PS?)?, FT, PT
    WHEN A.SGBSTDN_LEVL_CODE = 'GR' and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6') AND RORENRL_FINAID_ADJ_HR >= 12  then 387
    WHEN A.SGBSTDN_LEVL_CODE = 'GR' and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6') AND RORENRL_FINAID_ADJ_HR <  12 then 235
    -- LAW FT, PT
    WHEN A.SGBSTDN_LEVL_CODE = 'PL' AND RORENRL_FINAID_ADJ_HR >= 12  then 387
    WHEN A.SGBSTDN_LEVL_CODE = 'PL' AND RORENRL_FINAID_ADJ_HR <  12 then 235
    -- MED 1,2,3,4
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND A.SGBSTDN_STYP_CODE = 'P' AND A.SGBSTDN_TERM_CODE_ADMIT = 
    '20'||SUBSTR(:aidy,3,2)||'15' THEN 1707 --M1 FEE
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND ATTR.SGRSATT_ATTS_CODE = 'M1' THEN 703 --M2 FEE
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND ATTR.SGRSATT_ATTS_CODE = 'M2' THEN 653 --M3 FEE
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' AND ATTR.SGRSATT_ATTS_CODE = 'M3' THEN 536 --M4 FEE

   END
FROM RORENRL,SGBSTDN A, (
    SELECT SGRSATT_PIDM, SGRSATT_ATTS_CODE
    FROM SGRSATT A
    WHERE A.SGRSATT_ATTS_CODE in ('GG2','GG3','GG4','GG5','GG6')
    AND A.SGRSATT_TERM_CODE_EFF = (
        SELECT MAX(M.SGRSATT_TERM_CODE_EFF)
        FROM SGRSATT M
        AND M.SGRSATT_TERM_CODE_EFF = '20'||SUBSTR(:aidy,1,2)||'15'
        AND  A.SGRSATT_PIDM = M.SGRSATT_PIDM
    )
) ATTR 
WHERE A.SGBSTDN_PIDM = RORENRL_PIDM
AND A.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(B.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN B
    WHERE A.SGBSTDN_PIDM = B.SGBSTDN_PIDM
    AND B.SGBSTDN_TERM_CODE_EFF <= :PERIOD
    )
AND ATTR.SGRSATT_PIDM(+) = RORENRL_PIDM               
AND RORENRL_TERM_CODE = :PERIOD
AND RORENRL_ENRR_CODE = 'STANDARD'
AND RORENRL_PIDM = :PIDM
-- ;

-- seq 2
--seq 2 actual hours

SELECT 
  CASE
    WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'UG'
             and b.SGBSTDN_COLL_CODE_1 <> 'PS' 
             and z.sfrstcr_term_code = :PERIOD) >= 12 THEN 422
        WHEN (SELECT  SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'UG'
             and b.SGBSTDN_COLL_CODE_1 <> 'PS' 
             and z.sfrstcr_term_code = :PERIOD) BETWEEN 6 AND 11 THEN 270
        WHEN (SELECT  SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'UG'
             and b.SGBSTDN_COLL_CODE_1 <> 'PS' 
             and z.sfrstcr_term_code = :PERIOD) < 6 THEN 0
         WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'UG'
             and b.SGBSTDN_COLL_CODE_1 = 'PS' 
             and z.sfrstcr_term_code = :PERIOD) >= 6 THEN 100
        WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'UG'
             and b.SGBSTDN_COLL_CODE_1 = 'PS'
             and z.sfrstcr_term_code = :PERIOD) < 6 THEN 50
WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'GR'
             and b.SGBSTDN_COLL_CODE_1 = 'PS'
             and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6')
             and z.sfrstcr_term_code = :PERIOD) >= 6 THEN 100     
      WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'GR'
             and b.SGBSTDN_COLL_CODE_1 = 'PS'
             and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6')
             and z.sfrstcr_term_code = :PERIOD) < 6 THEN 50
        WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'GR'
             and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6')
             and z.sfrstcr_term_code = :PERIOD) >= 12 THEN 387
        WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'GR'
             and z.sfrstcr_term_code = :PERIOD) BETWEEN 6 AND 11 THEN 235
  WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'GR'
             and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6')
             and z.sfrstcr_term_code = :PERIOD) < 6 THEN 0
        WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'PL'
             and z.sfrstcr_term_code = :PERIOD) >= 12 THEN 387
        WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code = 'PL'
             and z.sfrstcr_term_code = :PERIOD) < 12 THEN 235

       END
  FROM SFRSTCR Z, SGBSTDN B, (SELECT SGRSATT_PIDM, SGRSATT_ATTS_CODE
                                FROM SGRSATT A
                                WHERE A.SGRSATT_ATTS_CODE in ('GG2','GG3','GG4','GG5','GG6')
                                AND A.SGRSATT_TERM_CODE_EFF = (SELECT MAX(M.SGRSATT_TERM_CODE_EFF)
                                                            FROM SGRSATT M
                                                            WHERE  M.SGRSATT_TERM_CODE_EFF = '20'||SUBSTR(:aidy,1,2)||'15'
                                                            AND  A.SGRSATT_PIDM =  M.SGRSATT_PIDM)) ATTR 
  WHERE Z.SFRSTCR_RSTS_CODE IN ('RE','RW')
  AND Z.SFRSTCR_TERM_CODE = :PERIOD
  AND Z.SFRSTCR_PIDM = B.SGBSTDN_PIDM
  AND B.SGBSTDN_TERM_CODE_EFF =                               
                                                  (SELECT MAX(A.SGBSTDN_TERM_CODE_EFF)                                                                            
                                                  FROM SGBSTDN A             
                                                  WHERE A.SGBSTDN_PIDM = B.SGBSTDN_PIDM
                                                  AND A.SGBSTDN_TERM_CODE_EFF <= :PERIOD)
   AND ATTR.SGRSATT_PIDM(+) = Z.SFRSTCR_PIDM                                                  
   AND Z.SFRSTCR_PIDM = :PIDM
-- ;

-- seq 3
--SEQ 3 MED
SELECT 
CASE SGRCHRT_CHRT_CODE
    WHEN '2024MD' THEN 1072
    WHEN '2025MD' THEN 536
    WHEN '2026MD' THEN 653
    WHEN '2027MD' THEN 703
END
FROM SGBSTDN, SGRCHRT, (
    SELECT SUM(SFRSTCR_CREDIT_HR) TOTAL_HOURS
    FROM SFRSTCR
    WHERE SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
    AND SFRSTCR_TERM_CODE = :PERIOD
    AND SFRSTCR_PIDM = :PIDM
) Z
 WHERE SGBSTDN_PIDM = :PIDM
   AND TOTAL_HOURS > 0
   AND SGBSTDN_TERM_CODE_EFF = (SELECT MAX(SGBSTDN_TERM_CODE_EFF)
                                  FROM SGBSTDN
                                 WHERE SGBSTDN_PIDM = :PIDM
                                   AND SGBSTDN_TERM_CODE_EFF <= :PERIOD)
   AND SGRCHRT_PIDM = SGBSTDN_PIDM
   AND SGRCHRT_CHRT_CODE IN ('2024MD', '2025MD', '2026MD', '2027MD')
   AND SGRCHRT_TERM_CODE_EFF = (SELECT MAX(SGRCHRT_TERM_CODE_EFF)
                                  FROM SGRCHRT
                                 WHERE SGRCHRT_PIDM = SGBSTDN_PIDM
                                   AND SGRCHRT_TERM_CODE_EFF <= :PERIOD)
-- ;

-- seq 4
-- DEFAULT SEQ 4

SELECT 
   CASE 
    WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 <> 'PS' then 422
    WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS'  then 100
    WHEN A.SGBSTDN_LEVL_CODE = 'GR'  and ATTR.SGRSATT_ATTS_CODE NOT IN ('GG2','GG3','GG4','GG5','GG6') then 387
    WHEN A.SGBSTDN_LEVL_CODE = 'PL' then 387
    WHEN A.SGBSTDN_LEVL_CODE = 'PM' THEN 1316 
   END
      FROM SGBSTDN A, (SELECT SGRSATT_PIDM, SGRSATT_ATTS_CODE
                                FROM SGRSATT A
                                WHERE A.SGRSATT_ATTS_CODE in ('GG2','GG3','GG4','GG5','GG6')
                                AND A.SGRSATT_TERM_CODE_EFF = (SELECT MAX(M.SGRSATT_TERM_CODE_EFF)
                                                            FROM SGRSATT M
                                                            WHERE  M.SGRSATT_TERM_CODE_EFF = '20'||SUBSTR(:aidy,1,2)||'15'
                                                            AND  A.SGRSATT_PIDM =  M.SGRSATT_PIDM)) ATTR 
           WHERE A.SGBSTDN_TERM_CODE_EFF = 
               (SELECT MAX(B.SGBSTDN_TERM_CODE_EFF)
                  FROM SGBSTDN B
                 WHERE A.SGBSTDN_PIDM = B.SGBSTDN_PIDM
                   AND B.SGBSTDN_TERM_CODE_EFF <= :PERIOD
               )
AND A.SGBSTDN_PIDM = :PIDM
AND ATTR.SGRSATT_PIDM(+) = A.SGBSTDN_PIDM
-- ;