-- new
select rorstat_pidm
from rorstat
join robinst on robinst_status_ind = 'A' and robinst_aidy_code = rorstat_aidy_code
where rorstat_aidy_code = :AIDY
and rorstat_pidm = :PIDM
and exists (
    select 1 from sgbstdn s
    where s.sgbstdn_pidm = rorstat_pidm
    and s.sgbstdn_stst_code not in ('AS', 'IL', 'P1')
    and s.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff) from sgbstdn z
        where z.sgbstdn_pidm = s.sgbstdn_pidm
        and substr(z.sgbstdn_term_code_eff, 0 , 4) <= robinst_aidy_end_year
    )
)
and not exists (
    select 1 from saradap a
    join sarappd b on a.saradap_pidm = b.sarappd_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
        and b.sarappd_term_code_entry = a.saradap_term_code_entry
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_inst_acc_ind = 'Y'
    where a.saradap_pidm = rorstat_pidm
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
;

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
-- AND RORSTAT_PIDM = :PIDM
;