SELECT A.RORSTAT_PIDM
FROM RORSTAT A
WHERE A.RORSTAT_AIDY_CODE = :AIDY                                                 
AND A.RORSTAT_PIDM = :PIDM
AND EXISTS (
    SELECT 1
    FROM ROBNYUD
    WHERE ROBNYUD_PIDM = A.RORSTAT_PIDM
    AND RORSTAT_PGRP_CODE LIKE 'UF%'
    AND (
        ROBNYUD_VALUE_28 LIKE 'IGNA%'
        OR ROBNYUD_VALUE_28 LIKE '2IGNA%'
    )
    AND SUBSTR(ROBNYUD_VALUE_27,0,4)  = '20' || SUBSTR(:AIDY ,3,2)
)

   
 ;

SELECT A.RORSTAT_PIDM
FROM RORSTAT A
WHERE A.RORSTAT_AIDY_CODE = :AIDY
AND A.RORSTAT_PIDM = :PIDM
AND (
    EXISTS (
        SELECT 1
        FROM ROBNYUD
        WHERE ROBNYUD_PIDM = A.RORSTAT_PIDM
        AND RORSTAT_PGRP_CODE LIKE 'UF%'
        AND (
            ROBNYUD_VALUE_28 LIKE 'IGNA%'
            OR ROBNYUD_VALUE_28 LIKE '2IGNA%'
        )
        AND SUBSTR(ROBNYUD_VALUE_27,0,4)  = '20' || SUBSTR(:AIDY ,3,2)
    ) OR EXISTS (
        SELECT 1
        FROM RORSTAT B
        join rbrapbg c on c.rbrapbg_pidm = b.rorstat_pidm
            and c.rbrapbg_aidy_code = b.rorstat_aidy_code
            and c.rbrapbg_run_name = 'ACTUAL'
            and c.rbrapbg_pbgp_code = 'UG'
        WHERE B.RORSTAT_PGRP_CODE  IN ('UG-CO','UG-CON') 
        AND B.RORSTAT_PIDM= A.RORSTAT_PIDM
        AND B.RORSTAT_AIDY_CODE = A.RORSTAT_AIDY_CODE
    ) AND EXISTS (
        SELECT 1
        FROM RPRAWRD
        WHERE RPRAWRD_FUND_CODE = 'IGNA-T'
        AND RPRAWRD_PAID_AMT > 0 
        AND RPRAWRD_AIDY_CODE = '2526'
        AND RPRAWRD_PIDM = A.RORSTAT_PIDM
    )
)

;

select * from rbrapbg;

SELECT A.RORSTAT_PIDM
FROM RORSTAT A 
WHERE A.RORSTAT_AIDY_CODE = :AIDY
-- AND A.RORSTAT_PIDM = :PIDM
AND (
    EXISTS (
        SELECT 1
        FROM ROBNYUD
        WHERE ROBNYUD_PIDM = A.RORSTAT_PIDM
        AND A.RORSTAT_PIDM = ROBNYUD_PIDM
        AND (
            (A.RORSTAT_PGRP_CODE LIKE 'UF%' OR A.RORSTAT_PGRP_CODE LIKE 'UT%')
            AND SUBSTR(ROBNYUD_VALUE_27,0,4)  = '20' || SUBSTR(:AIDY,3,2)
        )
    ) OR EXISTS (
        SELECT 1
        FROM RORSTAT B
        join rbrapbg c on c.rbrapbg_pidm = b.rorstat_pidm
            and c.rbrapbg_aidy_code = b.rorstat_aidy_code
            and c.rbrapbg_run_name = 'ACTUAL'
            and c.rbrapbg_pbgp_code = 'UG'
	    WHERE B.RORSTAT_PGRP_CODE  IN ('UG-CO','UG-CON') 
        AND   B.RORSTAT_PIDM = A.RORSTAT_PIDM
        AND   B.RORSTAT_AIDY_CODE = A.RORSTAT_AIDY_CODE
    ) AND EXISTS (
        SELECT 1
        FROM RPRAWRD
        WHERE RPRAWRD_FUND_CODE = 'SLU'
        AND RPRAWRD_PAID_AMT > 0 
        AND RPRAWRD_AIDY_CODE = '2526'
        AND RPRAWRD_PIDM = A.RORSTAT_PIDM
    )
)

;