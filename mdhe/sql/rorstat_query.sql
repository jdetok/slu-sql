select
    a.rorstat_pidm as "rorstat_pidm",
    b.spriden_id as "banner_id",
    c.spbpers_ssn as "spbpers_ssn",
    a.rorstat_aidy_code as "aidy",
    a.rorstat_bgrp_code as "bgrp",
    a.rorstat_tgrp_code as "tgrp",
    a.rorstat_pgrp_code as "pgrp"
from faismgr.rorstat a
inner join saturn.spriden b on b.spriden_pidm = a.rorstat_pidm
inner join saturn.spbpers c on c.spbpers_pidm = a.rorstat_pidm
where b.spriden_change_ind is null
and c.spbpers_ssn is not null
and a.rorstat_aidy_code = ( -- '202610'
    select 
    case
        when to_char(sysdate, 'MM') >= 6 -- current date in june or later
        then to_char(sysdate, 'YY') || to_char(sysdate+365, 'YY')
        when to_char(sysdate, 'MM') < 6 -- current date before june
        then to_char(sysdate-365, 'YY') || to_char(sysdate, 'YY')
    end
    from dual
)
fetch first 5 rows only;