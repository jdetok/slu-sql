-- GR PA WITH SGBSTDN RECORD
SELECT (RORALGS_AMT / case when (
    exists (
        select 1 from sfrstcr
        where sfrstcr_pidm = a.sgbstdn_pidm
        and sfrstcr_term_code = :PERIOD
        and sfrstcr_ptrm_code in ('PS2', 'S8B')
    ) and not exists (
        select 1 from sfrstcr
        where sfrstcr_pidm = a.sgbstdn_pidm
        and sfrstcr_term_code = :PERIOD
        and sfrstcr_ptrm_code not in ('PS2', 'S8B')
    )
) then 2 else 1 end) as amt
FROM SGBSTDN a
join robinst on robinst_aidy_code = :AIDY and robinst_status_ind = 'A'
join sgrchrt b on b.SGRCHRT_PIDM = a.SGBSTDN_PIDM
    and b.sgrchrt_term_code_eff = (
        select max(z.sgrchrt_term_code_eff) from sgrchrt z
        where z.sgrchrt_pidm = b.sgrchrt_pidm
        and b.sgrchrt_term_code_eff <= :PERIOD
    )
join roralgs on roralgs_aidy_code = :AIDY
    AND RORALGS_KEY_1 = 'PBDG' 
    AND RORALGS_KEY_4 = '8TRS'
    AND RORALGS_KEY_5 = a.SGBSTDN_LEVL_CODE
    AND RORALGS_KEY_9 = a.SGBSTDN_MAJR_CODE_1
    AND RORALGS_KEY_11 = CASE
        WHEN b.SGRCHRT_CHRT_CODE = ('PA' || ROBINST_AIDY_START_YEAR) THEN ('PA' || ROBINST_AIDY_START_YEAR)
        WHEN b.SGRCHRT_CHRT_CODE = ('PA' || ROBINST_AIDY_END_YEAR) THEN ('PA' || ROBINST_AIDY_END_YEAR)
    END
WHERE a.SGBSTDN_STST_CODE IN  ('AS','IL')
AND a.SGBSTDN_LEVL_CODE = 'GR'
AND a.SGBSTDN_MAJR_CODE_1 = 'PA'
AND a.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(z.SGBSTDN_TERM_CODE_EFF) FROM SGBSTDN z
    WHERE z.SGBSTDN_PIDM = a.SGBSTDN_PIDM
    AND z.SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND NOT EXISTS (
    SELECT 1 FROM SARADAP z
    JOIN SARAPPD y
        ON y.SARAPPD_PIDM = z.SARADAP_PIDM
        AND y.SARAPPD_APPL_NO = z.SARADAP_APPL_NO
        AND y.SARAPPD_TERM_CODE_ENTRY = z.SARADAP_TERM_CODE_ENTRY
    JOIN STVAPDC x
        ON x.STVAPDC_CODE = y.SARAPPD_APDC_CODE
        AND x.STVAPDC_INST_ACC_IND = 'Y'
        AND x.STVAPDC_SIGNF_IND = 'Y'
    WHERE z.SARADAP_PIDM = a.SGBSTDN_PIDM
    and z.saradap_term_code_entry = (
        select max(s.saradap_term_code_entry) from saradap s
        where s.saradap_pidm = z.saradap_pidm
        and s.saradap_term_code_entry between a.SGBSTDN_TERM_CODE_EFF 
            and ('20' || cast(substr(:AIDY, 3, 2) as int) + 1 || '00')
    ) 
    and z.saradap_appl_no = (
        select max(s.saradap_appl_no) from saradap s
        where s.saradap_pidm = z.saradap_pidm
        and s.saradap_term_code_entry = z.saradap_term_code_entry
    )
    and y.sarappd_seq_no = (
        select max(z.sarappd_seq_no) from sarappd z
        where z.sarappd_pidm = y.sarappd_pidm
        and z.sarappd_term_code_entry = y.sarappd_term_code_entry
    )
    AND z.SARADAP_PROGRAM_1 <> a.SGBSTDN_PROGRAM_1
)
-- AND a.SGBSTDN_PIDM = :PIDM
and a.sgbstdn_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001516529')
;
-- sequence 1 - UG, GR, LAW WITH SGBSTDN RECORD
SELECT (RORALGS_AMT / case when (
    exists (
        select 1 from sfrstcr
        where sfrstcr_pidm = a.sgbstdn_pidm
        and sfrstcr_term_code = :PERIOD
        and sfrstcr_ptrm_code in ('PS2', 'S8B')
    ) and not exists (
        select 1 from sfrstcr
        where sfrstcr_pidm = a.sgbstdn_pidm
        and sfrstcr_term_code = :PERIOD
        and sfrstcr_ptrm_code not in ('PS2', 'S8B')
    )
) then 2 else 1 end) as amt
FROM SGBSTDN a
join roralgs on roralgs_aidy_code = :AIDY
    AND RORALGS_KEY_1 = 'PBDG' 
    AND RORALGS_KEY_4 = '8TRS'
    AND RORALGS_KEY_5 = a.SGBSTDN_LEVL_CODE
    AND RORALGS_KEY_9 is null
    AND RORALGS_KEY_11 is null
WHERE a.SGBSTDN_STST_CODE IN  ('AS','IL')
AND a.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN
    WHERE SGBSTDN_PIDM = a.SGBSTDN_PIDM
    AND SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND NOT EXISTS (
    SELECT 1
    FROM SARADAP z
    JOIN SARAPPD y
        ON y.SARAPPD_PIDM = z.SARADAP_PIDM
        AND y.SARAPPD_APPL_NO = z.SARADAP_APPL_NO
        AND y.SARAPPD_TERM_CODE_ENTRY = z.SARADAP_TERM_CODE_ENTRY
    JOIN STVAPDC x
        ON x.STVAPDC_CODE = y.SARAPPD_APDC_CODE
        AND x.STVAPDC_INST_ACC_IND = 'Y'
        AND x.STVAPDC_SIGNF_IND = 'Y'
    WHERE z.SARADAP_PIDM = a.SGBSTDN_PIDM
    and z.saradap_term_code_entry = (
        select max(s.saradap_term_code_entry) from saradap s
        where s.saradap_pidm = z.saradap_pidm
        and s.saradap_term_code_entry between a.SGBSTDN_TERM_CODE_EFF 
            and ('20' || cast(substr(:AIDY, 3, 2) as int) + 1 || '00')
    ) 
    and z.saradap_appl_no = (
        select max(s.saradap_appl_no) from saradap s
        where s.saradap_pidm = z.saradap_pidm
        and s.saradap_term_code_entry = z.saradap_term_code_entry
    )
    and y.sarappd_seq_no = (
        select max(z.sarappd_seq_no) from sarappd z
        where z.sarappd_pidm = y.sarappd_pidm
        and z.sarappd_term_code_entry = y.sarappd_term_code_entry
    )
    AND z.SARADAP_PROGRAM_1 <> a.SGBSTDN_PROGRAM_1
)
-- AND a.SGBSTDN_PIDM = :PIDM
and a.sgbstdn_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001516529')
;

select roralgs_amt
from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_inst_acc_ind = 'Y'
    and c.stvapdc_signf_ind = 'Y'
join robinst on robinst_aidy_code = :AIDY and robinst_status_ind = 'A'
join roralgs on roralgs_aidy_code = :AIDY
    AND RORALGS_KEY_1 = 'PBDG' 
    AND RORALGS_KEY_4 = '8TRS'
    AND RORALGS_KEY_5 = a.saradap_levl_code
where a.saradap_term_code_entry = (
    select max(z.saradap_term_code_entry) from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry between (robinst_aidy_end_year || '00') and :PERIOD
) 
and a.saradap_appl_no = (
    select max(z.saradap_appl_no) from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry = a.saradap_term_code_entry
)
and b.sarappd_seq_no = (
    select max(z.sarappd_seq_no) from sarappd z
    where z.sarappd_pidm = b.sarappd_pidm
    and z.sarappd_appl_no = b.sarappd_appl_no
    and z.sarappd_term_code_entry = b.sarappd_term_code_entry
)
and a.saradap_pidm = :PIDM
;

select * from saradap a
join sarappd b on a.saradap_pidm = b.sarappd_pidm
    and b.sarappd_appl_no = a.saradap_appl_no
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_signf_ind = 'Y'
    and c.stvapdc_inst_acc_ind = 'Y'
join robinst on robinst_status_ind = 'A' and robinst_aidy_code = '2627'
where a.saradap_term_code_entry = (
    select max(z.saradap_term_code_entry) from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry between robinst_aidy_end_year || '00' and robinst_aidy_end_year || '20'
)
and a.saradap_appl_no = (
    select max(z.saradap_appl_no) from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry = a.saradap_term_code_entry
)
and b.sarappd_seq_no = (
    select max(z.sarappd_seq_no) from sarappd z
    where z.sarappd_pidm = b.sarappd_pidm
    and z.sarappd_appl_no = b.sarappd_appl_no
    and z.sarappd_term_code_entry = b.sarappd_term_code_entry
)
and a.saradap_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001516529');