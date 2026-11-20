select x.rcrapp1_pidm
from (
    select rcrapp1_pidm, rcrapp1_aidy_code
    from rcrapp1
    join rcrapp3 on rcrapp3_pidm = rcrapp1_pidm
        and rcrapp3_aidy_code = rcrapp1_aidy_code
        and rcrapp3_seq_no = rcrapp1_seq_no
        and rcrapp3_infc_code = rcrapp1_infc_code
        and rcrapp3_offl_unoffl_ind = '1'
        AND nvl(rcrapp3_yr_in_coll_2, 'x') <> '4'
    where rcrapp1_aidy_code = :AIDY
    and rcrapp1_pidm = :PIDM
    and rcrapp1_curr_rec_ind = 'Y'
    and rcrapp1_infc_code = 'EDE'
    and exists (
        select 1 from rbrapbg
        where rbrapbg_pidm = rcrapp1_pidm
        and rbrapbg_aidy_code = rcrapp1_aidy_code
        and rbrapbg_run_name = 'ACTUAL'
        and rbrapbg_pbgp_code = 'UG'
    )
    and exists (
        select 1 from saradap a
        join robinst on robinst_status_ind = 'A' and robinst_aidy_code = rcrapp1_aidy_code
        join sarappd b on a.saradap_pidm = b.sarappd_pidm
            and b.sarappd_appl_no = a.saradap_appl_no
            and b.sarappd_term_code_entry = a.saradap_term_code_entry
        join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
            and c.stvapdc_signf_ind = 'Y'
            and c.stvapdc_inst_acc_ind = 'Y'
        where a.saradap_pidm = rcrapp1_pidm
        and a.saradap_levl_code = 'UG'
        and a.saradap_styp_code = 'T'
        and a.saradap_term_code_entry = (
            select max(z.saradap_term_code_entry) from saradap z
            where z.saradap_pidm = a.saradap_pidm
            and substr(z.saradap_term_code_entry, 0 , 4) = robinst_aidy_end_year
        )
        and a.saradap_appl_no = (
            select max(z.saradap_appl_no) from saradap z
            where z.saradap_pidm = a.saradap_pidm
            and z.saradap_term_code_entry = a.saradap_term_code_entry
        )
        and b.sarappd_seq_no = (
            select max(z.sarappd_seq_no) from sarappd z
            where z.sarappd_pidm = b.sarappd_pidm
            and z.sarappd_term_code_entry = b.sarappd_term_code_entry
            and z.sarappd_appl_no = b.sarappd_appl_no
        )
    )
    -- necessary for speed - forces optimizer to execute function call last
    and rownum > 0 
) x
where rnkneed.f_calc_gross_need(rcrapp1_pidm, rcrapp1_aidy_code) between 1 and 29999
;