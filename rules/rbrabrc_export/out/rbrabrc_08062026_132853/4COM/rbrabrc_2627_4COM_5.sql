-- Commuter meal plan, component only included in UG COA group
-- UNDERGRAD FRESHMAN WITH SGASTDN AND CHANGED SGASTDN FOR LATER TERM
SELECT RORALGS_AMT
FROM SGBSTDN X
JOIN SGBSTDN Y on Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF > X.SGBSTDN_TERM_CODE_EFF
JOIN RORPRST on RORPRST_PIDM = X.SGBSTDN_PIDM
    AND RORPRST_PERIOD = :PERIOD
JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '4COM'
    and RORALGS_KEY_2 = CASE WHEN X.SGBSTDN_STYP_CODE in ('F', '1') AND RORPRST_XHS_LOCK_IND = 'Y' THEN 'F' END
    and RORALGS_KEY_5 = Y.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_6 = Y.SGBSTDN_CAMP_CODE
-- has freshmen sgastdn record in the aid year	
WHERE X.SGBSTDN_TERM_CODE_EFF BETWEEN ('20' || SUBSTR(:AIDY, 3,2) || '00') AND ('20' || SUBSTR(:AIDY, 3,2) + 1 || '00')
AND X.SGBSTDN_STYP_CODE IN ('F','1') 
AND X.SGBSTDN_STST_CODE IN  ('AS','IL','P1') 
AND X.SGBSTDN_LEVL_CODE = 'UG'
and X.SGBSTDN_CAMP_CODE = 'FR'
AND Y.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(Y1.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y1
    WHERE Y1.SGBSTDN_PIDM = Y.SGBSTDN_PIDM
    AND Y1.SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND Y.SGBSTDN_COLL_CODE_1 NOT IN ('PS','PL')
AND Y.SGBSTDN_PROGRAM_1 NOT IN ('NR041','NR02','TEAC03','NR06')
AND Y.SGBSTDN_STST_CODE IN  ('AS','IL','P1')
AND NOT EXISTS (
    SELECT 1
    FROM SARADAP
    INNER JOIN SARAPPD
        ON SARAPPD_PIDM = SARADAP_PIDM
        AND SARAPPD_APPL_NO = SARADAP_APPL_NO
        AND SARAPPD_TERM_CODE_ENTRY = SARADAP_TERM_CODE_ENTRY
    INNER JOIN STVAPDC
        ON STVAPDC_CODE = SARAPPD_APDC_CODE
        AND STVAPDC_INST_ACC_IND = 'Y'
        AND STVAPDC_SIGNF_IND = 'Y'
    WHERE SARADAP_PIDM = X.SGBSTDN_PIDM
    AND SARADAP_TERM_CODE_ENTRY > X.SGBSTDN_TERM_CODE_EFF 
    AND SARADAP_TERM_CODE_ENTRY <= ('20' || cast(substr(:AIDY, 3, 2) as int) + 1 || '00')
    AND SARADAP_PROGRAM_1 <> X.SGBSTDN_PROGRAM_1
)
and not exists (
    select 1
    from tbraccd 
    join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
        and tbbdetc_type_ind = 'C'
        and tbbdetc_dcat_code = 'HOU'
    where tbraccd_pidm = x.sgbstdn_pidm
    and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
    and tbraccd_term_code = rorprst_period
    group by tbraccd_pidm, tbraccd_term_code
    having sum(tbraccd_amount) > 0
)
-- and X.SGBSTDN_PIDM = :PIDM
;
select '20' || SUBSTR(:AIDY, 3,2) + 1 || '00' from dual;


select * from roralgs where roralgs_key_4 = '6LIV';
select * from rbrabrc where rbrabrc_validated_ind = 'N';