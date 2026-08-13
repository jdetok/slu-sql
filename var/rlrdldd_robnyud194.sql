select spriden_id, rlrdldd_period, robnyud_value_194, rlrdldd_enrollment_effect_date, stvterm_start_date
from rlrdldd 
join spriden on spriden_pidm = rlrdldd_pidm and spriden_change_ind is null
join robnyud on robnyud_pidm = rlrdldd_pidm
join stvterm on stvterm_code = robnyud_value_194
where rlrdldd_period = '202710'
and stvterm_start_date <> rlrdldd_enrollment_effect_date
and rlrdldd_period = stvterm_code
;

select robusdf_value_321, spriden_id
from robusdf 
join spriden on spriden_pidm = robusdf_pidm and spriden_change_ind is null
where robusdf_aidy_code = '2627' and robusdf_value_321 is not null;