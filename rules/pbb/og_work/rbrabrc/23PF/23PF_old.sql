-- PKTF PERIOD BUDGET RULE - written by JD 10/3/2025
-- Parks Tech Fee (previously PARKS_TECH_FEE)
-- OIGINAL RULE FROM ELLUCIAN CONSULTANT
SELECT
  CASE
    WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code ='UG'
             and b.SGBSTDN_COLL_CODE_1 IN ('SE', 'PK')
              and substr(z.sfrstcr_term_code, 5,2)  IN ('10', '20')
             and z.sfrstcr_term_code = :PERIOD) >= 12 THEN 330
  WHEN (SELECT SUM(Z.SFRSTCR_CREDIT_HR)
             from sfrstcr z
             where z.sfrstcr_pidm = b.sgbstdn_pidm
             and b.sgbstdn_levl_code ='UG'
             and b.SGBSTDN_COLL_CODE_1 IN ('SE', 'PK')
             and substr(z.sfrstcr_term_code, 5,2)  IN ('10', '20')
             and z.sfrstcr_term_code = :PERIOD) < 12 THEN 165

END
FROM SFRSTCR Z, SGBSTDN B
WHERE Z.SFRSTCR_RSTS_CODE IN ('RE','RW')
  AND Z.SFRSTCR_TERM_CODE = :PERIOD
  AND Z.SFRSTCR_PIDM = B.SGBSTDN_PIDM
  AND B.SGBSTDN_TERM_CODE_EFF =
      (SELECT MAX(A.SGBSTDN_TERM_CODE_EFF)
      FROM SGBSTDN A
      WHERE A.SGBSTDN_PIDM = B.SGBSTDN_PIDM
      AND A.SGBSTDN_TERM_CODE_EFF <= :PERIOD)
   AND Z.SFRSTCR_PIDM = :PIDM