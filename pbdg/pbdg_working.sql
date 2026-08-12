select * from sgrsatt
-- where sgrsatt_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001430127');
where sgrsatt_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001362605');

select spriden_id
from rbrapbc 
join spriden on spriden_change_ind is null and spriden_pidm = rbrapbc_pidm
JOIN SGRSATT b on b.SGRSATT_PIDM = rbrapbc_pidm
    and b.SGRSATT_ATTS_CODE = 'SPSA'
    and b.SGRSATT_TERM_CODE_EFF = (
        select max(z.SGRSATT_TERM_CODE_EFF)
        from SGRSATT z
        where z.SGRSATT_PIDM = b.SGRSATT_PIDM
        and z.SGRSATT_TERM_CODE_EFF <= :PERIOD
    )
where rbrapbc_run_name = 'ACTUAL' 
and rbrapbc_pbcp_code = '22DF' 
and rbrapbc_period = '202710';

select * from roralgs where RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '5CAF'
    -- and RORALGS_KEY_10 = 'SPSA';
;

select spriden_id, rprawrd_accept_amt, robnyud_value_195, robnyud_value_197
from rprawrd 
join robnyud on robnyud_pidm = rprawrd_pidm
join spriden on spriden_pidm = rprawrd_pidm and spriden_change_ind is null
where rprawrd_aidy_code = '2627'
and rprawrd_fund_code in ('DLPL', 'DLGL');

select spriden_id
from robnyud
join spriden on spriden_pidm = robnyud_pidm and spriden_change_ind is null
where robnyud_value_195 = '202710';

select * from roralgs where roralgs_key_4 = '2FEE' and roralgs_key_5 = 'PM' and roralgs_key_10 = 'M3';

update roralgs set roralgs_amt = 831 where roralgs_key_4 = '2FEE' and roralgs_key_5 = 'PM' and roralgs_key_10 = 'M3' and roralgs_amt = 811;

select count(distinct gcraact_pidm) from gcraact
where gcraact_gcbactm_id = 3
and gcraact_gcvasts_id = 2
and gcraact_user_response_date between to_date('07/01/2025', 'MM/DD/YYYY') and to_date('06/30/2026', 'MM/DD/YYYY');

select count(distinct gcraact_pidm) from gcraact
where gcraact_gcbactm_id = 3
and gcraact_gcvasts_id <> 2
and gcraact_display_start_date between to_date('07/01/2025', 'MM/DD/YYYY') and to_date('06/30/2026', 'MM/DD/YYYY');
select * from gcvasts;

select * from roralgs where
RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '6LIV';
    -- and roralgs_key_3 = '1'
    -- and roralgs_key_5 = 'UG';

    select * from roralgs where roralgs_amt = 128;