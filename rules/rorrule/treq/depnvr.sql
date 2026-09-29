-- from banner 9/22
SELECT DISTINCT(RCRAPP1_PIDM) 
FROM RCRAPP2, RCRAPP3, RCRAPP1 
WHERE   RCRAPP1_VERIFICATION_MSG = '2' 
AND  RCRAPP2_MODEL_CDE = 'D' 
AND  RCRAPP1_CURR_REC_IND = 'Y' 
AND  RCRAPP3_OFFL_UNOFFL_IND <> '2' 
AND  RCRAPP1_PIDM = (select spriden_pidm from spriden where spriden_id = '001507858' and spriden_change_ind is null)
AND  RCRAPP1_AIDY_CODE = :AIDY   
AND RCRAPP1_AIDY_CODE = RCRAPP2_AIDY_CODE 
AND RCRAPP1_PIDM      = RCRAPP2_PIDM      
AND RCRAPP1_INFC_CODE = RCRAPP2_INFC_CODE 
AND RCRAPP1_SEQ_NO    = RCRAPP2_SEQ_NO  
AND RCRAPP1_AIDY_CODE = RCRAPP3_AIDY_CODE 
AND RCRAPP1_PIDM      = RCRAPP3_PIDM      
AND RCRAPP1_INFC_CODE = RCRAPP3_INFC_CODE 
AND RCRAPP1_SEQ_NO    = RCRAPP3_SEQ_NO
;

select rcrapp1_pidm
from rcrapp1
join rcrapp2 on rcrapp2_pidm = rcrapp1_pidm
    and rcrapp2_aidy_code = rcrapp1_aidy_code
    and rcrapp2_infc_code = rcrapp1_infc_code
    and rcrapp2_seq_no = rcrapp1_seq_no
join rcrapp3 on rcrapp3_pidm = rcrapp1_pidm
    and rcrapp3_aidy_code = rcrapp1_aidy_code
    and rcrapp3_infc_code = rcrapp1_infc_code
    and rcrapp3_seq_no = rcrapp1_seq_no
where rcrapp1_curr_rec_ind = 'Y'
and rcrapp1_infc_code = 'EDE'
and rcrapp1_verification_msg = '2'
and rcrapp2_model_cde = 'D'
and rcrapp3_offl_unoffl_ind <> '2'
and rcrapp1_aidy_code = :AIDY
and rcrapp1_pidm = :PIDM
;
-- AND  RCRAPP1_PIDM = (select spriden_pidm from spriden where spriden_id = '001507858' and spriden_change_ind is null)