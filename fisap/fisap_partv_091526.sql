-- FISAP 2627 Part V: 09/15/2026

-- Section C Total Compensation for FWS
-- 12. Total earned compensation for FWS
select sum(rprawrd_paid_amt)
from rprawrd
where rprawrd_fund_code = 'FWS'
and rprawrd_aidy_code = '" & aidy & "'
and rprawrd_aidy_code = '2526'
;

select 
    rprawrd_pidm as pidm,
    spriden_id as bid,
    rprawrd_aidy_code as aidy,
    rprawrd_paid_amt as paid
from rprawrd
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
where rprawrd_fund_code = 'FWS'
and rprawrd_paid_amt is not null
-- and rprawrd_aidy_code = '" & aidy & "'
and rprawrd_aidy_code = '2526'

;
