select spriden_id as bid
from rorstat
join spriden on spriden_pidm = rorstat_pidm and spriden_change_ind is null
where rorstat_aidy_code = '2627'
and rorstat_aprd_code = 'LFS'
and exists (
    select 1
    from rprawrd 
    where rprawrd_pidm = rorstat_pidm
    and rprawrd_aidy_code = rorstat_aidy_code
    and rprawrd_fund_code = 'DLUL'
)