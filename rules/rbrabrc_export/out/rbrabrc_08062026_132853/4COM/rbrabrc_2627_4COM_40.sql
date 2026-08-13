--UNDERGRAD TRANSFER NO SGASTDN
select count(distinct saradap_pidm) from (
SELECT RORALGS_AMT, saradap_pidm
FROM SARADAP X, SARAPPD b, RORALGS, STVAPDC, RORPRST, ROBNYUD
WHERE RORALGS_KEY_1 = 'PBDG'

AND CASE
    WHEN X.SARADAP_STYP_CODE in ('T') AND ROBNYUD_VALUE_120 in ('D', '0', 'O') THEN 'T'
END = RORALGS_KEY_2

-- AND CASE -- OFF CAMPUS HOUSING FLAG IN RORPRST
--     WHEN (RORPRST_XHS IN ('1','3','4')) THEN '1'     --off campus or with family/relative
-- END = RORALGS_KEY_3

AND RORALGS_KEY_4 = '4COM' -- budget component                       

AND CASE -- level code
    WHEN X.SARADAP_LEVL_CODE = 'UG' THEN 'UG'
END = RORALGS_KEY_5

AND CASE -- campus code
    WHEN X.SARADAP_CAMP_CODE = 'FR' THEN 'FR'
END = RORALGS_KEY_6


AND X.SARADAP_COLL_CODE_1 NOT IN ('PS','PL')
AND X.SARADAP_PROGRAM_1 NOT IN ('NR041','NR02','TEAC03','NR06')                  -- from JKB 11/17 added accel nursing, rising teacher
AND X.SARADAP_STYP_CODE = 'T'
AND X.SARADAP_PIDM = RORPRST_PIDM
AND ROBNYUD_PIDM = X.SARADAP_PIDM
AND RORPRST_PERIOD = :PERIOD

-- max saradap term <= passed period	
AND X.SARADAP_TERM_CODE_ENTRY = (
     SELECT MAX(Y.SARADAP_TERM_CODE_ENTRY)
    FROM SARADAP Y, ROBINST
    WHERE Y.SARADAP_PIDM = X.SARADAP_PIDM
	AND Y.SARADAP_TERM_CODE_ENTRY >= (ROBINST_AIDY_END_YEAR || '00')
    AND Y.SARADAP_TERM_CODE_ENTRY <= :PERIOD
	AND ROBINST_AIDY_CODE = :AIDY
)
--max application decision code sequence number
AND b.SARAPPD_SEQ_NO = (SELECT MAX (b.SARAPPD_SEQ_NO)
	FROM SARAPPD Y, ROBINST
	WHERE     Y.SARAPPD_PIDM = b.SARAPPD_PIDM
	AND Y.SARAPPD_SEQ_NO < 99
	AND Y.SARAPPD_TERM_CODE_ENTRY >= (ROBINST_AIDY_END_YEAR || '00')
	AND Y.SARAPPD_TERM_CODE_ENTRY <= :PERIOD
	AND ROBINST_AIDY_CODE = :AIDY           
	AND X.SARADAP_APPL_NO = Y.SARAPPD_APPL_NO) 

   AND STVAPDC_INST_ACC_IND = 'Y'
   AND STVAPDC_SIGNF_IND = 'Y'

AND b.SARAPPD_APDC_CODE = STVAPDC_CODE	
AND X.SARADAP_APPL_NO = b.SARAPPD_APPL_NO
AND X.SARADAP_TERM_CODE_ENTRY = b.SARAPPD_TERM_CODE_ENTRY
AND RORALGS_AIDY_CODE = :AIDY
AND b.SARAPPD_PIDM = X.SARADAP_PIDM	
and not exists (
    select 1
    from tbraccd 
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_type_ind = 'C'
        and tbbdetc_dcat_code = 'HOU'
    where tbraccd_pidm = x.saradap_pidm
    and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
    and tbraccd_term_code = rorprst_period
    group by tbraccd_pidm, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)
)
-- AND X.SARADAP_PIDM = :PIDM
;

SELECT RORALGS_AMT
FROM SARADAP X
JOIN SARAPPD b
    on b.SARAPPD_PIDM = X.SARADAP_PIDM
    and b.SARAPPD_APPL_NO = X.SARADAP_APPL_NO
    and b.SARAPPD_TERM_CODE_ENTRY = X.SARADAP_TERM_CODE_ENTRY
JOIN STVAPDC c ON c.STVAPDC_CODE = b.SARAPPD_APDC_CODE
    AND c.STVAPDC_INST_ACC_IND = 'Y'
    AND c.STVAPDC_SIGNF_IND = 'Y'
JOIN RORPRST on RORPRST_PIDM = X.SARADAP_PIDM
    AND RORPRST_PERIOD = :PERIOD
JOIN ROBNYUD on ROBNYUD_PIDM = X.SARADAP_PIDM
JOIN ROBINST on ROBINST_AIDY_CODE = :AIDY
JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '4COM'
    and RORALGS_KEY_2 = CASE WHEN X.SARADAP_STYP_CODE in ('T') AND ROBNYUD_VALUE_120 in ('D', '0', 'O') THEN 'T' END
    and RORALGS_KEY_5 = X.SARADAP_LEVL_CODE
    and RORALGS_KEY_6 = X.SARADAP_CAMP_CODE
WHERE X.SARADAP_LEVL_CODE = 'UG'
AND X.SARADAP_CAMP_CODE = 'FR'
AND X.SARADAP_STYP_CODE = 'T'
AND X.SARADAP_COLL_CODE_1 NOT IN ('PS','PL')
AND X.SARADAP_PROGRAM_1 NOT IN ('NR041','NR02','TEAC03','NR06')
AND X.SARADAP_TERM_CODE_ENTRY = (
    SELECT MAX(Y.SARADAP_TERM_CODE_ENTRY)
    FROM SARADAP Y
    WHERE Y.SARADAP_PIDM = X.SARADAP_PIDM
	AND Y.SARADAP_TERM_CODE_ENTRY between (ROBINST_AIDY_END_YEAR || '00') and :PERIOD
)
AND X.SARADAP_APPL_NO = (
    SELECT MAX(Y.SARADAP_APPL_NO)
    FROM SARADAP Y
    WHERE Y.SARADAP_PIDM = X.SARADAP_PIDM
	AND Y.SARADAP_TERM_CODE_ENTRY = X.SARADAP_TERM_CODE_ENTRY
)
--max application decision code sequence number
AND b.SARAPPD_SEQ_NO = (
    SELECT MAX(Y.SARAPPD_SEQ_NO)
	FROM SARAPPD Y
	WHERE Y.SARAPPD_PIDM = b.SARAPPD_PIDM
	AND Y.SARAPPD_TERM_CODE_ENTRY between (ROBINST_AIDY_END_YEAR || '00') and :PERIOD
	AND Y.SARAPPD_APPL_NO = X.SARADAP_APPL_NO 
)
and not exists (
    select 1
    from tbraccd 
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_type_ind = 'C'
        and tbbdetc_dcat_code = 'HOU'
    where tbraccd_pidm = x.saradap_pidm
    and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
    and tbraccd_term_code = rorprst_period
    group by tbraccd_pidm, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)
AND X.SARADAP_PIDM = :PIDM
;