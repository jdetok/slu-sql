-- 001226352	1232219
-- 001435785	1443999
update rpratrm set rpratrm_paid_amt = rpratrm_offer_amt
-- select * from rpratrm
where rpratrm_term_code = '202620'
and rpratrm_fund_code = 'FWS'
and rpratrm_pidm in ('1232219', '1443999')
;
update rprawrd set rprawrd_paid_amt = rprawrd_offer_amt
-- select * from rprawrd
where rprawrd_aidy_code = '2526'
and rprawrd_fund_code = 'FWS'
and rprawrd_pidm in ('1232219', '1443999')
;