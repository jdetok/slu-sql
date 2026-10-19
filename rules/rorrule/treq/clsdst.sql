SELECT RORSTAT_PIDM
FROM RORSTAT, ROBINST
WHERE ROBINST_STATUS_IND = 'A'
AND ROBINST_AIDY_CODE = RORSTAT_AIDY_CODE
AND (
    EXISTS (
        SELECT 'X'
        FROM SATURN.SGBSTDN E
        WHERE E.SGBSTDN_PIDM = RORSTAT_PIDM
        AND E.SGBSTDN_STST_CODE NOT IN ('AS', 'IL', 'P1')
        AND E.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(F.SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN F 
	        WHERE SUBSTR(F.SGBSTDN_TERM_CODE_EFF,0,4) <= SUBSTR(ROBINST_AIDY_END_YEAR,0,4)
            AND F.SGBSTDN_PIDM = E.SGBSTDN_PIDM
        )
    ) 
    AND NOT EXISTS (
        SELECT 'X'
        FROM SARAPPD A, STVAPDC
        WHERE A.SARAPPD_PIDM = RORSTAT_PIDM
        AND A.SARAPPD_APDC_CODE = STVAPDC_CODE
        AND STVAPDC_INST_ACC_IND = 'Y'
        AND STVAPDC_SIGNF_IND = 'Y'
        AND A.SARAPPD_TERM_CODE_ENTRY = (
            SELECT MAX(B.SARAPPD_TERM_CODE_ENTRY) 
            FROM SARAPPD B
            WHERE B.SARAPPD_PIDM = A.SARAPPD_PIDM
            AND B.SARAPPD_TERM_CODE_ENTRY > ROBINST_AIDY_END_YEAR || '20'
        )
        AND A.SARAPPD_APPL_NO = (
            SELECT MAX(C.SARAPPD_APPL_NO) 
            FROM SARAPPD C
            WHERE C.SARAPPD_PIDM = A.SARAPPD_PIDM
            AND C.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY
        )
        AND A.SARAPPD_SEQ_NO = (
            SELECT MAX(D.SARAPPD_SEQ_NO) 
            FROM SARAPPD D
            WHERE D.SARAPPD_PIDM = A.SARAPPD_PIDM
	        AND D.SARAPPD_TERM_CODE_ENTRY = A.SARAPPD_TERM_CODE_ENTRY
	        AND D.SARAPPD_APPL_NO = A.SARAPPD_APPL_NO)
    )
)		
AND RORSTAT_AIDY_CODE = :AIDY
AND RORSTAT_PIDM = :PIDM
--4318
-- 4641
AND RORSTAT_PIDM    = (select spriden_pidm from spriden where spriden_id = '001275318' and spriden_change_ind is null)
;
select * from sgbstdn where sgbstdn_pidm = (select spriden_pidm from spriden where spriden_id = '001275318' and spriden_change_ind is null)
;
select * from saradap where saradap_pidm = (select spriden_pidm from spriden where spriden_id = '001275318' and spriden_change_ind is null);