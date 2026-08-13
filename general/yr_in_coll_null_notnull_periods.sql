select spriden_id
from rorprst a
join rorprst b on b.rorprst_pidm = a.rorprst_pidm
    and b.rorprst_yr_in_coll is null
    and b.rorprst_period = '202720'
join spriden on spriden_pidm = a.rorprst_pidm and spriden_change_ind is null
where a.rorprst_period = '202710'
and a.rorprst_yr_in_coll is not null
;
