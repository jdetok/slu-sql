select
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    rorstat_pgrp_code,
    rorstat_tgrp_code,
    a.sgbstdn_levl_code,
    stvmajr_cipc_code,
    stvmajr_desc,
    case (
        select nvl(sum(rprawrd_paid_amt), 0) from rprawrd
        where rprawrd_pidm = a.sgbstdn_pidm
        and rprawrd_fund_code in ('DLUL', 'DLSL', 'DLAL', 'DLGL', 'DLPL')
    ) when 0 then 'N' else 'Y' end as dl_paid,
    robnyud_value_193,
    robnyud_value_194,
    robnyud_value_195,
    robnyud_value_196,
    robnyud_value_197,
    robnyud_value_198,
    robnyud_value_199,
    robnyud_value_200
from sgbstdn a
join stvmajr on a.sgbstdn_majr_code_1 = stvmajr_code
join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
join robnyud on robnyud_pidm = a.sgbstdn_pidm
join robinst on robinst_aidy_code = '2627' and robinst_status_ind = 'A'
join rorstat on rorstat_pidm = a.sgbstdn_pidm and rorstat_aidy_code = robinst_aidy_code
where a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff) from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= robinst_aidy_end_year || '20'
)
and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and stvmajr_cipc_code in ('512306', '520301')
;

select rprawrd_fund_code from rprawrd

where rprawrd_fund_code like 'DL%'
    group by rprawrd_fund_code
    ;


select * from sgbstdn
where sgbstdn_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001260354');

select * from rorstat
where rorstat_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001260354');

select * from robdfps order by robdfps_aidy_code desc;
-- where rorcamp_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001260354');

select * from rtvaprd where rtvaprd_code = 'MEDFS';
select * from robprds where robprds_period = '202710';
select * from rortprd where rortprd_aprd_code = 'MEDFS';
select * from rprclss where rprclss_levl_code = 'PM' and rprclss_aidy_code = '2627';
select * from rprclss where rprclss_levl_code = 'UG' and rprclss_aidy_code = '2627';
select * from rprssbp;
select rorprst_yr_in_coll from rorprst;