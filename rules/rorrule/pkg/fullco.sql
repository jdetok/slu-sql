-- from banner 08172026
SELECT  DISTINCT RORSTAT_PIDM
FROM     RORSTAT, ROBINST
WHERE  RORSTAT_PIDM             =  :PIDM                            
   AND     RORSTAT_AIDY_CODE  =  :AIDY                      
 AND EXISTS
    (SELECT 'X'
   FROM SATURN.SGBSTDN E
    WHERE E.SGBSTDN_PIDM = RORSTAT_PIDM
    AND E.SGBSTDN_LEVL_CODE = 'UG'
    AND E.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
    AND E.SGBSTDN_TERM_CODE_EFF =
     (SELECT MAX(F.SGBSTDN_TERM_CODE_EFF)
        FROM SGBSTDN F 
	WHERE SUBSTR(F.SGBSTDN_TERM_CODE_EFF,0,4) <= SUBSTR(ROBINST_AIDY_END_YEAR,0,4)
         AND F.SGBSTDN_PIDM = E.SGBSTDN_PIDM))
 AND NOT EXISTS (SELECT 'X'
  FROM SARAPPD A, STVAPDC
 WHERE A.SARAPPD_PIDM = RORSTAT_PIDM
   AND A.SARAPPD_APDC_CODE = STVAPDC_CODE
   AND STVAPDC_INST_ACC_IND = 'Y'
   AND STVAPDC_SIGNF_IND = 'Y'
   AND A.SARAPPD_TERM_CODE_ENTRY = 
    (SELECT MAX(B.SARAPPD_TERM_CODE_ENTRY) 
       FROM SARAPPD B
      WHERE B.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND SUBSTR(B.SARAPPD_TERM_CODE_ENTRY,0,4) >= SUBSTR(ROBINST_AIDY_END_YEAR,0,4))
   AND A.SARAPPD_APPL_NO = 
    (SELECT MAX(C.SARAPPD_APPL_NO) 
       FROM SARAPPD C
      WHERE C.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND C.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY)
   AND A.SARAPPD_SEQ_NO = 
    (SELECT MAX(D.SARAPPD_SEQ_NO) 
       FROM SARAPPD D
      WHERE D.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND D.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY
	    AND D.SARAPPD_APPL_NO = A.SARAPPD_APPL_NO))
AND EXISTS
  (SELECT 'X'
     FROM ROBNYUD
	WHERE   ROBNYUD_PIDM                       = RORSTAT_PIDM

          AND ((ROBNYUD_VALUE_1                     IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
	  AND   ROBNYUD_VALUE_3                    > '20' || SUBSTR( :AIDY                               ,1,2) || '20'
          AND   ROBNYUD_VALUE_3               <> 'RIF'
          AND   ROBNYUD_VALUE_5                    <> 'CANG')
          OR   (ROBNYUD_VALUE_6                     IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
	  AND   ROBNYUD_VALUE_8                 > '20' || SUBSTR( :AIDY                              ,1,2) || '20'
          AND   ROBNYUD_VALUE_8               <> 'RIF'
          AND   ROBNYUD_VALUE_10                <> 'CANG')
           OR (ROBNYUD_VALUE_11                 IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
	  AND   ROBNYUD_VALUE_13                > '20' || SUBSTR( :AIDY                              ,1,2) || '20'
          AND   ROBNYUD_VALUE_13               <> 'RIF'
          AND   ROBNYUD_VALUE_15                <> 'CANG')
           OR (ROBNYUD_VALUE_16                   IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
	  AND   ROBNYUD_VALUE_18                > '20' || SUBSTR( :AIDY                              ,1,2) || '20'
          AND   ROBNYUD_VALUE_18               <> 'RIF'
          AND   ROBNYUD_VALUE_20                <> 'CANG')))

;

-- rework 
SELECT DISTINCT RORSTAT_PIDM
FROM RORSTAT 
JOIN ROBINST on ROBINST_AIDY_CODE = RORSTAT_AIDY_CODE
WHERE RORSTAT_AIDY_CODE = :AIDY
AND RORSTAT_PIDM = :PIDM
AND EXISTS (
    SELECT 1
    FROM SATURN.SGBSTDN E
    WHERE E.SGBSTDN_PIDM = RORSTAT_PIDM
    AND E.SGBSTDN_LEVL_CODE = 'UG'
    AND E.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
    AND E.SGBSTDN_TERM_CODE_EFF = (
        SELECT MAX(F.SGBSTDN_TERM_CODE_EFF)
        FROM SGBSTDN F 
	    WHERE SUBSTR(F.SGBSTDN_TERM_CODE_EFF,0,4) <= SUBSTR(ROBINST_AIDY_END_YEAR,0,4)
        AND F.SGBSTDN_PIDM = E.SGBSTDN_PIDM
    )
)
AND NOT EXISTS (
    SELECT 1
    FROM SARAPPD a
    JOIN STVAPDC b on b.STVAPDC_CODE = a.SARAPPD_APDC_CODE
        and b.STVAPDC_INST_ACC_IND = 'Y'
        and b.STVAPDC_SIGNF_IND = 'Y'
    WHERE a.SARAPPD_PIDM = RORSTAT_PIDM
    AND a.SARAPPD_TERM_CODE_ENTRY = (
        SELECT MAX(z.SARAPPD_TERM_CODE_ENTRY) 
        FROM SARAPPD z
        WHERE z.SARAPPD_PIDM = a.SARAPPD_PIDM
	    AND SUBSTR(z.SARAPPD_TERM_CODE_ENTRY,0,4) >= SUBSTR(ROBINST_AIDY_END_YEAR,0,4)
    )
    AND A.SARAPPD_APPL_NO = (
        SELECT MAX(z.SARAPPD_APPL_NO) 
        FROM SARAPPD z
        WHERE z.SARAPPD_PIDM = a.SARAPPD_PIDM
	    AND z.SARAPPD_TERM_CODE_ENTRY = a.SARAPPD_TERM_CODE_ENTRY
    )
    AND A.SARAPPD_SEQ_NO = (
        SELECT MAX(z.SARAPPD_SEQ_NO) 
        FROM SARAPPD z
        WHERE z.SARAPPD_PIDM = a.SARAPPD_PIDM
	    AND z.SARAPPD_TERM_CODE_ENTRY = a.SARAPPD_TERM_CODE_ENTRY
	    AND z.SARAPPD_APPL_NO = a.SARAPPD_APPL_NO
    )
)
AND EXISTS (
    SELECT 1
    FROM ROBNYUD
	WHERE ROBNYUD_PIDM = RORSTAT_PIDM
    AND (
        (
            ROBNYUD_VALUE_1 IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
            AND (
                (
                    ROBNYUD_VALUE_3 > '20' || SUBSTR(:AIDY, 1, 2) || '20'
                    AND ROBNYUD_VALUE_3 <> 'RIF'
                ) or ( ROBNYUD_VALUE_3 is null )
            )
            AND ROBNYUD_VALUE_5 <> 'CANG'
        ) OR (
            ROBNYUD_VALUE_6 IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
	        AND (
                (
                    ROBNYUD_VALUE_8 > '20' || SUBSTR(:AIDY, 1, 2) || '20'
                    AND ROBNYUD_VALUE_8 <> 'RIF'
                ) or ( ROBNYUD_VALUE_8 is null )
            ) 
            AND ROBNYUD_VALUE_10 <> 'CANG'
        ) OR (
            ROBNYUD_VALUE_11 IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
	        AND (
                (
                    ROBNYUD_VALUE_13 > '20' || SUBSTR(:AIDY, 1, 2) || '20'
                    AND ROBNYUD_VALUE_13 <> 'RIF'
                ) or ( ROBNYUD_VALUE_13 is null )
            )
            AND ROBNYUD_VALUE_15 <> 'CANG'
        ) OR (
            ROBNYUD_VALUE_16 IN ('FACHEX','EXCHNG','REM-ST','REM-CS','SSMFCS' )
	        AND (
                (
                    ROBNYUD_VALUE_18 > '20' || SUBSTR(:AIDY, 1, 2) || '20'
                    AND ROBNYUD_VALUE_18 <> 'RIF'
                ) or ( ROBNYUD_VALUE_18 is null )
            )
            AND ROBNYUD_VALUE_20 <> 'CANG'
        )
    )
);