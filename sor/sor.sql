select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    robusdf_value_321 as comp_date,
    robusdf_value_322 as styp,
    robusdf_value_323 as enrl_fal,
    robusdf_value_324 as enrl_wtr,
    robusdf_value_325 as enrl_spr,
    robusdf_value_326 as enrl_smr,
    rcrlds4_proc_date,
    rcrlds4_lifemax_loan_total
from robusdf
left join rcrlds4 on rcrlds4_pidm = robusdf_pidm
    and rcrlds4_aidy_code = robusdf_aidy_code
    and rcrlds4_curr_rec_ind = 'Y'
    and rcrlds4_infc_code = 'EDE'
join spriden on spriden_pidm = robusdf_pidm and spriden_change_ind is null
where robusdf_aidy_code = '2627'
and robusdf_value_321 is not null
;

select * from robusdf where robusdf_pidm = 1289005;

