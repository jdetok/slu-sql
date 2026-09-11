select 
    spriden_id as bid,
    spbpers_ssn as ssn,
    spriden_last_name || ', ' || spriden_first_name as name,
    rprawrd_awst_code as awst,
    rprawrd_fund_code as fund,
    rprawrd_offer_amt as offer_amt
from rprawrd 
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
left join spbpers on spbpers_pidm = rprawrd_pidm
where rprawrd_fund_code in ('DLUL', 'DLAL', 'DLGL', 'DLPL', 'DLSL')
and rprawrd_awst_code in ('OFRD', 'ACPT')
and (rprawrd_paid_amt is null or rprawrd_paid_amt = 0)
and rprawrd_aidy_code = '" & aidy & "'
;
select * from spbpers;