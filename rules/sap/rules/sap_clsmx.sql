select a.sgbstdn_pidm
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
        ) * 1.25
    ), 180
)
and a.sgbstdn_pidm = :pidm
;