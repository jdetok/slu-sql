select spriden_id as bid, spriden_last_name || ', ' || spriden_first_name as name
from sfrstcr a
join spriden on spriden_pidm = a.sfrstcr_pidm and spriden_change_ind is null
where a.sfrstcr_ptrm_code in ('PS2', 'S8B')
and a.sfrstcr_term_code = '202710'
and not exists (
    select 1 from sfrstcr b
    where b.sfrstcr_pidm = a.sfrstcr_pidm and b.sfrstcr_term_code = a.sfrstcr_term_code
    and b.sfrstcr_ptrm_code not in ('PS2', 'S8B')
)
;