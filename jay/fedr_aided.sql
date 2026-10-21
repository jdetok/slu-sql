-- Federally aided students in most reent aid year
select distinct spriden_id as bid
from rprawrd
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
join robinst r on r.robinst_aidy_code = rprawrd_aidy_code and r.robinst_status_ind = 'A'
where (rprawrd_fund_code like 'DL%L' or rprawrd_fund_code in ('PELL', 'FWS', 'SEOG'))
and r.robinst_aidy_code = (select max(z.robinst_aidy_code) from robinst z where z.robinst_status_ind = 'A')
;
