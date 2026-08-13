select distinct a.sgbstdn_pidm
from sgbstdn a 
join shrlgpa b on b.shrlgpa_pidm = a.sgbstdn_pidm
    and b.shrlgpa_levl_code = case when a.sgbstdn_levl_code = 'AC' then 'UG' else a.sgbstdn_levl_code end
    and b.shrlgpa_gpa_type_ind = 'I'
join shrlgpa c on c.shrlgpa_pidm = a.sgbstdn_pidm
    and c.shrlgpa_levl_code = case when a.sgbstdn_levl_code = 'AC' then 'UG' else a.sgbstdn_levl_code end
    and c.shrlgpa_gpa_type_ind = 'O'
where a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff) from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= :term
)
and a.sgbstdn_levl_code = 'AC'
and (b.shrlgpa_gpa < 1.995 or c.shrlgpa_hours_earned < (c.shrlgpa_hours_attempted * 0.665))
and a.sgbstdn_pidm = :pidm

;