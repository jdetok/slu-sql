-- random janice request 7/15/2026
select spriden_id as bid, rorstat_pckg_comp_date
from rorstat 
join spriden on spriden_pidm = rorstat_pidm and spriden_change_ind is null
where rorstat_pgrp_code like 'UG%'
and rorstat_pckg_comp_date < to_date('07/10/2026', 'MM/DD/YYYY')
and rorstat_aidy_code = '2627'
;