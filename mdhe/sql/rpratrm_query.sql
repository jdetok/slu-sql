select a.rpratrm_pidm as "pidm",
	b.spriden_id as "banner_id",
	a.rpratrm_aidy_code as "aidy",
	a.rpratrm_term_code as "period",
    case 
        when substr(a.rpratrm_term_code, 5, 2) = '10' then 'fall'
        when substr(a.rpratrm_term_code, 5, 2) = '20' then 'spring'
    end as period_desc,
	a.rpratrm_fund_code as "fund_bnr",
    case
        when a.rpratrm_fund_code in ('MOACC', 'ESTSTG') then 'MOACC'
        when a.rpratrm_fund_code in ('MOSCH', 'ESTSTS') then 'MOSCH'
    end as "fund_mo",
    case
        when a.rpratrm_fund_code in ('MOACC', 'ESTSTG') then 'Access Missouri'
        when a.rpratrm_fund_code in ('MOSCH', 'ESTSTS') then 'Bright Flight'
    end as "award_name",
	a.rpratrm_awst_code as "status",
	nvl(a.rpratrm_accept_amt, 0) as "amt_award",
	nvl(a.rpratrm_paid_amt, 0) as "amt_paid"

from faismgr.rpratrm a
	inner join saturn.spriden b
	on a.rpratrm_pidm = b.spriden_pidm

where a.rpratrm_fund_code in ('ESTSTG', 'MOACC', 'ESTSTS', 'MOSCH')
	and a.rpratrm_aidy_code = '2526'
	and a.rpratrm_term_code >= '202610'
	and b.spriden_change_ind is null;
    