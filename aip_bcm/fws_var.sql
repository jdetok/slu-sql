select '$' || rprawrd_offer_amt as amt from rprawrd 
where rprawrd_aidy_code = :CM_aidyearcode
and rprawrd_fund_code = 'FWS'
and rprawrd_pidm = :pidm;

select '$' || rprawrd_offer_amt as amt from rprawrd 
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
where rprawrd_fund_code = 'FWS'
and rprawrd_aidy_code = case 
    when to_char(sysdate, 'MM') < '08' 
        then to_char(to_number(to_char(sysdate,'YY')) - 1) || to_char(sysdate, 'YY')
    else to_char(sysdate, 'YY') || to_char(to_number(to_char(sysdate,'YY')) + 1)
end
-- and rprawrd_pidm = :pidm
;
select '$' || rprawrd_accept_amt as amt, spriden_id from rprawrd 
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
where rprawrd_fund_code = 'FWS'
and rprawrd_awst_code = 'ACPT'
and rprawrd_aidy_code = case 
    when to_char(sysdate, 'MM') < '08' 
        then to_char(to_number(to_char(sysdate,'YY')) - 1) || to_char(sysdate, 'YY')
    else to_char(sysdate, 'YY') || to_char(to_number(to_char(sysdate,'YY')) + 1)
end
-- and rprawrd_pidm = :pidm
;

select '$' || rprawrd_accept_amt as amt from rprawrd 
where rprawrd_aidy_code = :CM_aidyearcode
and rprawrd_fund_code = 'FWS'
and rprawrd_awst_code = 'ACPT'
and rprawrd_pidm = :pidm
;

select spriden_id, rprawrd_accept_amt from rprawrd 
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
where rprawrd_aidy_code = '2627'
and rprawrd_fund_code = 'FWS'
;

-- fws accept no job
select rprawrd_pidm from rprawrd
where rprawrd_fund_code = 'FWS'
and rprawrd_awst_code = 'ACPT'
and rprawrd_aidy_code = case 
    when to_char(sysdate, 'MM') < '08' 
        then to_char(to_number(to_char(sysdate,'YY')) - 1) || to_char(sysdate, 'YY')
    else to_char(sysdate, 'YY') || to_char(to_number(to_char(sysdate,'YY')) + 1)
end
and (rprawrd_paid_amt is null or rprawrd_paid_amt = 0)
and not exists (
    select 1 from rjrsear
    where rjrsear_pidm = rprawrd_pidm
    and rjrsear_aidy_code = rprawrd_aidy_code
)
;

select * from robinst order by robinst_aidy_code desc;

select * from rjrsear where rjrsear_aidy_code = '2627';