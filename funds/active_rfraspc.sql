select rfraspc.*
from rfraspc
join rfrbase on rfrbase_fund_code = rfraspc_fund_code and rfrbase_active_ind = 'Y'
where rfraspc_aidy_code = '" & aidy & "'
;