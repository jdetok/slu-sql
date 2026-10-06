select
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    stvmajr_cipc_code,
    robnyud_value_193,
    robnyud_value_194,
    robnyud_value_195,
    robnyud_value_196,
    robnyud_value_197,
    robnyud_value_198,
    robnyud_value_199,
    robnyud_value_200
from sgbstdn a
join stvmajr on a.sgbstdn_majr_code_1 = stvmajr_code
join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
join robnyud on robnyud_pidm = a.sgbstdn_pidm
where a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff) from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= '202720'
)
and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and stvmajr_cipc_code in ('512306', '520301')
;