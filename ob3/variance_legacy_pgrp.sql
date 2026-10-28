select spriden_id, rorstat_pgrp_code
from robnyud a
join rorstat b on b.rorstat_pidm = a.robnyud_pidm
join spriden on spriden_pidm = robnyud_pidm and spriden_change_ind is null
where robnyud_value_197 = 'Y'
and rorstat_aidy_code = '2627'
and rorstat_pgrp_code not like '%L'
and rorstat_pgrp_code not like 'U%'
and rorstat_pgrp_code not like 'FULL%'
and rorstat_pgrp_code not like '2ND%'
and rorstat_pgrp_code not in ('TR-NL', 'DEFAUL', 'NAT', 'NODEGR')
;

select spriden_id, rorstat_pgrp_code
from robnyud a
join rorstat b on b.rorstat_pidm = a.robnyud_pidm
join spriden on spriden_pidm = robnyud_pidm and spriden_change_ind is null
where robnyud_value_197 is null
and rorstat_aidy_code = '2627'
and rorstat_pgrp_code like '%L'
and rorstat_pgrp_code not like 'U%'
and rorstat_pgrp_code not like 'FULL%'
and rorstat_pgrp_code not like '2ND%'
and rorstat_pgrp_code not in ('TR-NL', 'DEFAUL', 'NAT', 'NODEGR')
;

select rorstat_pgrp_code
from rorstat
where rorstat_pgrp_code like '%L'
group by rorstat_pgrp_code
;

select robnyud_value_197 from robnyud where robnyud_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '000476966');
select * from rorstat where rorstat_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '000476966')
and rorstat_aidy_code = '2627'
and rorstat_pgrp_code not like '%L'
;

select * from roralgo;