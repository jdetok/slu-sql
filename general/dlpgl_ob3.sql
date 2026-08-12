select spriden_id, rprawrd_accept_amt, robnyud_value_195, robnyud_value_197
from rprawrd 
join robnyud on robnyud_pidm = rprawrd_pidm
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
where rprawrd_aidy_code = '2627'
and rprawrd_fund_code in ('DLPL', 'DLGL');