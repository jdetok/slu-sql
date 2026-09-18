-- select sum(remaining_fws) from (
select
    spriden_id,
    rprawrd_aidy_code,
    rprawrd_accept_amt,
    case rjrsear_pidm
        when null then rprawrd_accept_amt
        else rprawrd_accept_amt - nvl(rprawrd_paid_amt, 0)
    end as remaining_fws
from rprawrd
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
left join rjrsear on rjrsear_pidm = rprawrd_pidm and rjrsear_aidy_code = rprawrd_aidy_code
where rprawrd_aidy_code = '2627'
and rprawrd_fund_code = 'FWS'
and rprawrd_awst_code = 'ACPT'
-- )
;