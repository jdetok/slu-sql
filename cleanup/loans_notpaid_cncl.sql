-- Update loan status to CNCL for loans in OFRD/ACPT but nothing paid

select * from rprawrd
where rprawrd_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rprawrd_awst_code in ('OFRD', 'ACPT')
and (rprawrd_paid_amt is null or rprawrd_paid_amt = 0)
and rprawrd_aidy_code = '2526'
;

select *
from rpratrm
where rpratrm_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rpratrm_awst_code in ('OFRD', 'ACPT')
and (rpratrm_paid_amt is null or rpratrm_paid_amt = 0)
and rpratrm_aidy_code = '2526'
;

-- RPRAWRD updates
update rprawrd set rprawrd_awst_code = 'CNCL'
where rprawrd_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rprawrd_awst_code in ('OFRD', 'ACPT')
and (rprawrd_paid_amt is null or rprawrd_paid_amt = 0)
and rprawrd_aidy_code = '2526'
;
-- RPRATRM updates
update rpratrm set rpratrm_awst_code = 'CNCL'
where rpratrm_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rpratrm_awst_code in ('OFRD', 'ACPT')
and (rpratrm_paid_amt is null or rpratrm_paid_amt = 0)
and rpratrm_aidy_code = '2526'
;

select * from rprawrd
where rprawrd_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rprawrd_awst_code = 'CNCL'
and rprawrd_aidy_code = '2526'
and (rprawrd_paid_amt is null or rprawrd_paid_amt = 0)
;

-- update rprawrd set 
--     rprawrd_cancel_amt = rprawrd_offer_amt,
--     rprawrd_cancel_date = to_date('09/15/2026', 'MM/DD/YYYY'),
--     rprawrd_offer_amt = null,
--     rprawrd_offer_date = null,
--     rprawrd_accept_amt = null,
--     rprawrd_accept_date = null
select * from rprawrd
where rprawrd_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rprawrd_aidy_code = '2526'
and rprawrd_awst_code = 'CNCL'
-- and rprawrd_offer_amt is not null
and rprawrd_user_id = 'SYS'
-- and rprawrd_pidm = 787286
;
-- update rpratrm set 
--     rpratrm_cancel_amt = rpratrm_offer_amt,
--     rpratrm_cancel_date = to_date('09/15/2026', 'MM/DD/YYYY'),
--     rpratrm_offer_amt = null,
--     rpratrm_offer_date = null,
--     rpratrm_accept_amt = null,
--     rpratrm_accept_date = null
select * from rpratrm
where rpratrm_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rpratrm_aidy_code = '2526'
and rpratrm_awst_code = 'CNCL'
-- and rpratrm_offer_amt is not null
and rpratrm_user_id = 'SYS'
-- and rpratrm_pidm = 787286
;

select spriden_pidm from spriden where spriden_id = '000782499' and spriden_change_ind is null;