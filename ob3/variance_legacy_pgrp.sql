select spriden_id, rorstat_pgrp_code
from robnyud a
join rorstat b on b.rorstat_pidm = a.robnyud_pidm
join spriden on spriden_pidm = robnyud_pidm and spriden_change_ind is null
where robnyud_value_197 = 'Y'
and rorstat_aidy_code = '2627'
and rorstat_pgrp_code not like '%L'
and rorstat_pgrp_code not in ('TR-NL', 'FULL', 'U-SPNL', 'UG-PL', 'DEFAUL')
;

select spriden_id, rorstat_pgrp_code
from robnyud a
join rorstat b on b.rorstat_pidm = a.robnyud_pidm
join spriden on spriden_pidm = robnyud_pidm and spriden_change_ind is null
where robnyud_value_197 is null
and rorstat_aidy_code = '2627'
and rorstat_pgrp_code like '%L'
and rorstat_pgrp_code not in ('TR-NL', 'FULL', 'U-SPNL', 'UG-PL', 'DEFAUL')
;

select rorstat_pgrp_code
from rorstat
where rorstat_pgrp_code like '%L'
group by rorstat_pgrp_code;