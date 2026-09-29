SELECT DISTINCT(RCRAPP3_PIDM) 
FROM RCRAPP1, RCRAPP3 
WHERE  (RCRAPP3_REJ_REASON_PRTY_1 IS NOT NULL or rcrapp3_offl_unoffl_ind = '2')
-- AND  RCRAPP3_PIDM = :PIDM  
AND  RCRAPP3_AIDY_CODE = :AIDY   
AND RCRAPP1_CURR_REC_IND = 'Y'  
AND RCRAPP1_AIDY_CODE = RCRAPP3_AIDY_CODE 
AND RCRAPP1_PIDM = RCRAPP3_PIDM      
AND RCRAPP1_INFC_CODE = RCRAPP3_INFC_CODE 
AND RCRAPP1_SEQ_NO = RCRAPP3_SEQ_NO
-- AND  RCRAPP1_PIDM = (select spriden_pidm from spriden where spriden_id = '001507858' and spriden_change_ind is null)

;
select rcrapp1_pidm
from rcrapp1
join rcrapp3 on rcrapp3_pidm = rcrapp1_pidm
    and rcrapp3_aidy_code = rcrapp1_aidy_code
    and rcrapp3_infc_code = rcrapp1_infc_code
    and rcrapp3_seq_no = rcrapp1_seq_no
where rcrapp1_curr_rec_ind = 'Y'
and rcrapp1_infc_code = 'EDE'
and (rcrapp3_rej_reason_prty_1 is not null or rcrapp3_offl_unoffl_ind = '2')
and rcrapp1_aidy_code = :AIDY
and rcrapp1_pidm = :PIDM
;