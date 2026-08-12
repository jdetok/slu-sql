select distinct a.sgbstdn_pidm
from sgbstdn a
join shrlgpa b on b.shrlgpa_pidm = a.sgbstdn_pidm
    and b.shrlgpa_levl_code = a.sgbstdn_levl_code
    and b.shrlgpa_gpa_type_ind = 'O'
where a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff) from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= :term
)
and a.sgbstdn_levl_code <> 'PM'
and b.shrlgpa_hours_attempted >= nvl(
    (
        (
            select z.smbpgen_req_credits_overall from smbpgen z
            where z.smbpgen_program = a.sgbstdn_program_1
            and z.smbpgen_term_code_eff = (
                select max(y.smbpgen_term_code_eff) from smbpgen y
                where y.smbpgen_program = z.smbpgen_program
                and y.smbpgen_term_code_eff <= :term
                and y.smbpgen_active_ind = 'Y'
            )
        ) * 1.5
    ), 180
)
and a.sgbstdn_pidm = :pidm
;

-- OLD

SELECT DISTINCT SGBSTDN_PIDM
FROM SGBSTDN B, SHRLGPA
WHERE B.SGBSTDN_LEVL_CODE = SHRLGPA_LEVL_CODE
AND B.SGBSTDN_PIDM = SHRLGPA_PIDM
-- AND B.SGBSTDN_PIDM = :PIDM       
AND B.SGBSTDN_LEVL_CODE <> 'PM'
AND SHRLGPA_GPA_TYPE_IND = 'O'
AND B.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(A.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN A
    WHERE A.SGBSTDN_TERM_CODE_EFF <= :TERM                              
    AND B.SGBSTDN_PIDM = A.SGBSTDN_PIDM   
)
AND SHRLGPA_HOURS_ATTEMPTED > NVL(
    (
        (
            SELECT C.SMBPGEN_REQ_CREDITS_OVERALL
            FROM SMBPGEN C
            WHERE C.SMBPGEN_PROGRAM = B.SGBSTDN_PROGRAM_1
            AND C.SMBPGEN_TERM_CODE_EFF = (
                SELECT MAX (D.SMBPGEN_TERM_CODE_EFF)
                FROM SMBPGEN D
                WHERE D.SMBPGEN_PROGRAM = C.SMBPGEN_PROGRAM
                AND D.SMBPGEN_TERM_CODE_EFF <= :TERM                   
                AND D.SMBPGEN_ACTIVE_IND = 'Y'
            )
        ) * 1.5
    ), 180
)

;