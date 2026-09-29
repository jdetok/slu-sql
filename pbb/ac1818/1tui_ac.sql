select a.sgbstdn_pidm
from sgbstdn a
join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
where a.sgbstdn_coll_code_1 = 'AC'
and a.sgbstdn_levl_code = 'AC'
and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= :PERIOD
)
;