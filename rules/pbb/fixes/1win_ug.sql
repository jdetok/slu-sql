select rokmisc.f_calc_stud_bill_hrs(robinst_aidy_end_year || '18', rorstat_pidm, 'N') * roralgs_amt as amt, spriden_id
from rorstat
join spriden on spriden_pidm = rorstat_pidm and spriden_change_ind is null
join robinst on robinst_aidy_code = rorstat_aidy_code and robinst_status_ind = 'A'
join roralgs on roralgs_aidy_code = rorstat_aidy_code
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1WIN'
where rorstat_aidy_code = :AIDY
-- and rorstat_pidm = :PIDM
and exists (
    select 1 from sfrstcr
    where sfrstcr_pidm = rorstat_pidm
    and sfrstcr_term_code = robinst_aidy_end_year || '18'
    and sfrstcr_bill_hr > 0
)
;
select * from roralgs;

select * from sfrstcr
    where sfrstcr_pidm = (select spriden_pidm from spriden where spriden_id = '001401477' and spriden_change_ind is null)
    and sfrstcr_term_code = '202718'
    and sfrstcr_bill_hr > 0
;

-- 001513680
-- 001401477


select * from sfbetrm where sfbetrm_pidm = (select spriden_pidm from spriden where spriden_id = '001401477' and spriden_change_ind is null);
select * from sgbstdn where sgbstdn_pidm = (select spriden_pidm from spriden where spriden_id = '001401477' and spriden_change_ind is null);
select * from rorstat where rorstat_pidm = (select spriden_pidm from spriden where spriden_id = '001401477' and spriden_change_ind is null);
select * from rbrapbg where rbrapbg_pidm = (select spriden_pidm from spriden where spriden_id = '001401477' and spriden_change_ind is null);