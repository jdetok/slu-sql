select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    robusdf_value_321 as comp_date,
    robusdf_value_322 as levl_srv,
    robusdf_value_323 as enrl_fal,
    robusdf_value_324 as enrl_wtr,
    robusdf_value_325 as enrl_spr,
    robusdf_value_326 as enrl_smr,
    s.sgbstdn_levl_code as levl_bnr,
    s.sgbstdn_coll_code_1 as coll_cde,
    sc.stvcoll_desc as coll,
    s.sgbstdn_majr_code_1 as majr_cde,
    m.stvmajr_desc as majr,
    nvl(rokmisc.f_calc_stud_bill_hrs(robinst_aidy_end_year || '10', robusdf_pidm, 'N'), 0) as hrs,
    rcrlds4_proc_date,
    rcrlds4_lifemax_loan_total
from robusdf
join robinst on robinst_aidy_code = robusdf_aidy_code and robinst_status_ind = 'A'
join spriden on spriden_pidm = robusdf_pidm and spriden_change_ind is null
left join sgbstdn s on s.sgbstdn_pidm = robusdf_pidm
    and s.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and s.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff) from sgbstdn z
        where z.sgbstdn_pidm = s.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= (robinst_aidy_end_year + 1) || '00' 
    )
left join stvmajr m on m.stvmajr_code = s.sgbstdn_majr_code_1
left join stvcoll sc on sc.stvcoll_code = s.sgbstdn_coll_code_1
left join rcrlds4 on rcrlds4_pidm = robusdf_pidm
    and rcrlds4_aidy_code = robusdf_aidy_code
    and rcrlds4_curr_rec_ind = 'Y'
    and rcrlds4_infc_code = 'EDE'

where robusdf_aidy_code = '2627'
and robusdf_value_321 is not null
;

select * from robusdf where robusdf_pidm = 1289005;

select * from robinst;