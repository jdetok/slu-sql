select
    spriden_id, rpratrm_term_code, rpratrm_fund_code, rpratrm_offer_amt, rpratrm_accept_amt
from rpratrm
join spriden on spriden_change_ind is null and spriden_pidm = rpratrm_pidm
where rpratrm_term_code = '202700'
and rpratrm_fund_code = 'FWS'
and rpratrm_offer_amt > 0;

desc rpratrm;