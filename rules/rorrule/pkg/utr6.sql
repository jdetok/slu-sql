-- expect 001500766
-- 1509461
select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001500766';
desc rnkneed;

select x.rcrapp1_pidm
from (
    select rcrapp1_pidm, rcrapp1_aidy_code
    from rcrapp1
    join rcrapp3 on rcrapp3_pidm = rcrapp1_pidm
        and rcrapp3_aidy_code = rcrapp1_aidy_code
        and rcrapp3_seq_no = rcrapp1_seq_no
        and rcrapp3_infc_code = rcrapp1_infc_code
        and rcrapp3_offl_unoffl_ind = '1'
        AND nvl(rcrapp3_yr_in_coll_2, 'x') not in ('4')
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
where rnkneed.f_calc_gross_need(rcrapp1_pidm, rcrapp1_aidy_code) < 1

;
select *
from rcrapp1
    join rcrapp3 on rcrapp3_pidm = rcrapp1_pidm
        and rcrapp3_aidy_code = rcrapp1_aidy_code
        and rcrapp3_seq_no = rcrapp1_seq_no
        and rcrapp3_infc_code = rcrapp1_infc_code
        -- and rcrapp3_offl_unoffl_ind = '1'
        -- AND nvl(rcrapp3_yr_in_coll_2, 'x') not in ('4')
where rcrapp1_pidm =  1509461
AND RCRAPP1_CURR_REC_IND = 'Y'
    AND RCRAPP1_INFC_CODE = 'EDE'
;

select * from rcrapp1 where rcrapp1_pidm =  1509461;
select * from rorstat where rorstat_pidm =  1509461;
select * from saradap where saradap_pidm =  1509461;
select * from stvstyp;

SELECT DISTINCT(RCRAPP1_PIDM)
  FROM RCRAPP1,  RCRAPP3, RBRAPBG
  WHERE RCRAPP1_AIDY_CODE = :AIDY                                         
        -- AND RCRAPP1_PIDM = :PIDM                                        
        AND RCRAPP1_CURR_REC_IND = 'Y'
        AND RCRAPP1_INFC_CODE = 'EDE'
   AND RBRAPBG_PBGP_CODE = 'UG'
   AND RBRAPBG_RUN_NAME = 'ACTUAL'
   AND RCRAPP1_PIDM = RBRAPBG_PIDM
   AND RCRAPP1_AIDY_CODE = RBRAPBG_AIDY_CODE

        AND RCRAPP3_PIDM = RCRAPP1_PIDM        
        AND RCRAPP3_PIDM = RCRAPP1_PIDM
        AND RCRAPP1_PIDM = RBRAPBG_PIDM
        AND RCRAPP3_PIDM = RCRAPP1_PIDM
        AND RCRAPP3_AIDY_CODE = RCRAPP1_AIDY_CODE
        AND RCRAPP3_INFC_CODE = RCRAPP1_INFC_CODE
        AND RCRAPP3_SEQ_NO = RCRAPP1_SEQ_NO
        AND RCRAPP3_OFFL_UNOFFL_IND = '1'
        AND NVL(RCRAPP3_YR_IN_COLL_2,'X') NOT IN ('4')
--
         AND EXISTS (SELECT RNVAND0_PIDM FROM RNVAND0
          WHERE RNVAND0_PIDM = RCRAPP1_PIDM
        AND RNVAND0_AIDY_CODE = RCRAPP1_AIDY_CODE
        AND RNVAND0_GROSS_NEED <  1)
--
        AND (EXISTS
(SELECT 'X'
  FROM SARAPPD A, STVAPDC
 WHERE A.SARAPPD_PIDM = RCRAPP1_PIDM
   AND A.SARAPPD_APDC_CODE = STVAPDC_CODE
   AND STVAPDC_INST_ACC_IND = 'Y'
   AND STVAPDC_SIGNF_IND = 'Y'
   AND A.SARAPPD_TERM_CODE_ENTRY||LPAD(A.SARAPPD_APPL_NO,2,0)||LPAD(A.SARAPPD_SEQ_NO,2,0) = 
    (SELECT MAX(B.SARAPPD_TERM_CODE_ENTRY||LPAD(B.SARAPPD_APPL_NO,2,0)||LPAD(B.SARAPPD_SEQ_NO,2,0)) 
       FROM SARAPPD B
      WHERE B.SARAPPD_PIDM = A.SARAPPD_PIDM
	    AND B.SARAPPD_TERM_CODE_ENTRY IN
                (SELECT SORXREF_EDI_QLFR
                    FROM SORXREF
                WHERE SORXREF_EDI_VALUE = 'ALL_TERMS'
                  AND SORXREF_XLBL_CODE = 'ZSFS_VAR'
                  AND SORXREF_BANNER_VALUE = RCRAPP1_AIDY_CODE)
            AND B.SARAPPD_PIDM=RCRAPP1_PIDM)
   AND EXISTS 
    (SELECT 'X'
	   FROM SARADAP
      WHERE SARADAP_LEVL_CODE = 'UG'
            AND SARADAP_STYP_CODE = 'T'
            AND SARADAP_COLL_CODE_1 <> 'PS'
	    AND SARADAP_PIDM = A.SARAPPD_PIDM
		AND SARADAP_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY
		AND SARADAP_APPL_NO = A.SARAPPD_APPL_NO)))
;