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
