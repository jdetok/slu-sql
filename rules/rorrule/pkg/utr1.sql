SELECT DISTINCT(RCRAPP1_PIDM)
FROM RCRAPP1
join rcrapp3 on rcrapp3_pidm = rcrapp1_pidm
    and rcrapp3_aidy_code = rcrapp1_aidy_code
    and rcrapp3_seq_no = rcrapp1_seq_no
    and rcrapp3_infc_code = rcrapp1_infc_code
    and rcrapp3_offl_unoffl_ind = '1'
join robinst on robinst_aidy_code = rcrapp1_aidy_code and robinst_status_ind = 'A'
WHERE RCRAPP1_AIDY_CODE = :AIDY                                     
AND RCRAPP1_PIDM = :PIDM
AND NVL(RCRAPP3_YR_IN_COLL_2,'X') NOT IN ('4')
and exists (
    select 1 from rbrapbg
    where rbrapbg_pidm = rcrapp1_pidm
    and rbrapbg_aidy_code = rcrapp1_aidy_code
    and rbrapbg_run_name = 'ACTUAL'
    and rbrapbg_pbgp_code = 'UG'
)
AND EXISTS (
    SELECT RNVAND0_PIDM, RNVAND0_GROSS_NEED FROM RNVAND0
    WHERE  RNVAND0_PIDM = RCRAPP1_PIDM                       
    AND RNVAND0_AIDY_CODE = rcrapp1_aidy_code                                   
    AND RNVAND0_GROSS_NEED >=  63400
)
AND EXISTS (
    select 1 from saradap a
    join sarappd b on a.saradap_pidm = b.sarappd_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
        and b.sarappd_term_code_entry = a.saradap_term_code_entry
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_inst_acc_ind = 'Y'
    where a.saradap_term_code_entry between robinst_aidy_end_year || '00' and robinst_aidy_end_year || '20'
    and a.saradap_levl_code = 'UG'
    and a.saradap_styp_code = 'T'
    and a.saradap_coll_code_1 <> 'PS'
    and a.saradap_pidm = rcrapp1_pidm
)
-- and rcrapp1_pidm = 1461173
-- 170 new, 66 old
;
select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001452867';
-- 1461173
select * from saradap where saradap_pidm = 1461173;

select 1 from saradap a
join sarappd b on a.saradap_pidm = b.sarappd_pidm
    and b.sarappd_appl_no = a.saradap_appl_no
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_signf_ind = 'Y'
    and c.stvapdc_inst_acc_ind = 'Y'
join robinst on robinst_status_ind = 'A' and robinst_aidy_code = '2627'
where a.saradap_term_code_entry between robinst_aidy_end_year || '00' and robinst_aidy_end_year || '20'
and a.saradap_levl_code = 'UG'
and a.saradap_styp_code = 'T'
and a.saradap_coll_code_1 <> 'PS'
and saradap_pidm = 1461173
;

SELECT SORXREF_EDI_QLFR
                FROM SORXREF
                WHERE SORXREF_EDI_VALUE = 'ALL_TERMS'
                AND SORXREF_XLBL_CODE = 'ZSFS_VAR'
                and sorxref_banner_value = '2627';

SELECT DISTINCT(RCRAPP1_PIDM)
FROM RCRAPP1
join rcrapp3 on rcrapp3_pidm = rcrapp1_pidm
    and rcrapp3_aidy_code = rcrapp1_aidy_code
    and rcrapp3_seq_no = rcrapp1_seq_no
    and rcrapp3_infc_code = rcrapp1_infc_code
    and rcrapp3_offl_unoffl_ind = '1'
join robinst on robinst_aidy_code = rcrapp1_aidy_code and robinst_status_ind = 'A'
join robnyud on robnyud_pidm = rcrapp1_pidm
WHERE RCRAPP1_AIDY_CODE = :AIDY
and rcrapp1_pidm = :PIDM
AND RCRAPP1_CURR_REC_IND = 'Y'
AND RCRAPP1_INFC_CODE = 'EDE'
and exists (
    select 1 from rbrapbg
    where rbrapbg_pidm = rcrapp1_pidm
    and rbrapbg_aidy_code = rcrapp1_aidy_code
    and rbrapbg_run_name = 'ACTUAL'
    and rbrapbg_pbgp_code = 'UG'
)
AND NVL(RCRAPP3_YR_IN_COLL_2,'X') NOT IN ('4')
AND EXISTS (
    SELECT RNVAND0_PIDM FROM RNVAND0
    WHERE  RNVAND0_PIDM = RCRAPP1_PIDM                
    AND RNVAND0_AIDY_CODE = rcrapp1_aidy_code                            
    AND RNVAND0_GROSS_NEED between 35001 and 50000
)
AND SUBSTR(ROBNYUD_VALUE_27,0,4) = robinst_aidy_end_year
and exists (
    select 1 from saradap a
    join sarappd b on a.saradap_pidm = b.sarappd_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
        and b.sarappd_term_code_entry = a.saradap_term_code_entry
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_inst_acc_ind = 'Y'
    join robinst on robinst_status_ind = 'A' and robinst_aidy_code = rcrapp1_aidy_code
    where a.saradap_levl_code = 'UG'
    and a.saradap_styp_code in ('1', 'F')
    and a.saradap_coll_code_1 <> 'PS'
    and a.saradap_pidm = rcrapp1_pidm
    and a.saradap_term_code_entry = (
        select max(z.saradap_term_code_entry) from saradap z
        where z.saradap_pidm = a.saradap_pidm
        and z.saradap_term_code_entry between robinst_aidy_end_year || '00' and robinst_aidy_end_year || '20'
    )
)
;