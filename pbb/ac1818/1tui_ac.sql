-- 1818 enrolled
select roralgs_amt * rokmisc.f_calc_stud_bill_hrs(:period, a.sgbstdn_pidm, 'N') as amt, spriden_id
from sgbstdn a
join spriden on spriden_pidm = sgbstdn_pidm and spriden_change_ind is null
join robinst on robinst_aidy_code = :AIDY
join roralgs on roralgs_aidy_code = :AIDY
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = a.sgbstdn_levl_code
where a.sgbstdn_levl_code = 'AC'
and a.sgbstdn_coll_code_1 = 'AC'
and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= :period
)
-- and a.sgbstdn_pidm = :pidm
;

-- 1818 not enrolled with sgbstdn
select roralgs_amt * 6 as amt
from sgbstdn a
join robinst on robinst_aidy_code = :AIDY
join roralgs on roralgs_aidy_code = :AIDY
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = a.sgbstdn_levl_code
where a.sgbstdn_levl_code = 'AC'
and a.sgbstdn_coll_code_1 = 'AC'
and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= :period
)
and a.sgbstdn_pidm = :pidm
;

-- 1818 saradap
select roralgs_amt * 6 as amt
from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_signf_ind = 'Y'
    and c.stvapdc_inst_acc_ind = 'Y'
join robinst on robinst_aidy_code = :AIDY
join roralgs on roralgs_aidy_code = :AIDY
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = a.saradap_levl_code
where a.saradap_levl_code = 'AC'
and a.saradap_coll_code_1 = 'AC'
and a.saradap_term_code_entry = (
    select max(z.saradap_term_code_entry) from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry between robinst_aidy_end_year || '00' and :period
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
and a.saradap_pidm = :pidm
;

-- rorrule
SELECT A.RORSTAT_PIDM
FROM RORSTAT A
INNER JOIN ROBINST R ON R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
WHERE A.RORSTAT_AIDY_CODE = :AIDY       
AND RORSTAT_PIDM = :PIDM       
AND (
    EXISTS (
        SELECT 1
        FROM SGBSTDN B
        WHERE B.SGBSTDN_PIDM = A.RORSTAT_PIDM
        AND B.SGBSTDN_LEVL_CODE = 'AC'
        AND B.SGBSTDN_CAMP_CODE <> 'SP'
        AND B.SGBSTDN_STST_CODE IN ('AS', 'IL', 'P1')
        AND B.SGBSTDN_TERM_CODE_EFF = (
            SELECT MAX(Z.SGBSTDN_TERM_CODE_EFF) FROM SGBSTDN Z
            WHERE Z.SGBSTDN_PIDM = B.SGBSTDN_PIDM
            AND Z.SGBSTDN_TERM_CODE_EFF <= :PERIOD 
        )
        AND NOT EXISTS ( -- NO NEWER SARADAP RECORD FOR A DIFFERENT LEVEL
            SELECT 1
            FROM SARADAP C
            INNER JOIN SARAPPD D 
                ON D.SARAPPD_PIDM = C.SARADAP_PIDM
                AND D.SARAPPD_APPL_NO = C.SARADAP_APPL_NO
                AND D.SARAPPD_TERM_CODE_ENTRY = C.SARADAP_TERM_CODE_ENTRY
            INNER JOIN STVAPDC E
                ON E.STVAPDC_CODE = D.SARAPPD_APDC_CODE
                AND E.STVAPDC_INST_ACC_IND = 'Y'
                AND E.STVAPDC_SIGNF_IND = 'Y'
            WHERE C.SARADAP_PIDM = A.RORSTAT_PIDM
            AND D.SARAPPD_SEQ_NO = (
                SELECT MAX(Z.SARAPPD_SEQ_NO) FROM SARAPPD Z
                WHERE Z.SARAPPD_PIDM = D.SARAPPD_PIDM
                AND Z.SARAPPD_TERM_CODE_ENTRY = D.SARAPPD_TERM_CODE_ENTRY
                AND Z.SARAPPD_APPL_NO = D.SARAPPD_APPL_NO
            )
            AND C.SARADAP_LEVL_CODE <> 'AC'
            AND C.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '20') AND :PERIOD       
        )
    )
    OR EXISTS (
        SELECT 1
        FROM SARADAP C
        INNER JOIN SARAPPD D 
            ON D.SARAPPD_PIDM = C.SARADAP_PIDM
            AND D.SARAPPD_APPL_NO = C.SARADAP_APPL_NO
            AND D.SARAPPD_TERM_CODE_ENTRY = C.SARADAP_TERM_CODE_ENTRY
        INNER JOIN STVAPDC E
            ON E.STVAPDC_CODE = D.SARAPPD_APDC_CODE
            AND E.STVAPDC_INST_ACC_IND = 'Y'
            AND E.STVAPDC_SIGNF_IND = 'Y'
        WHERE C.SARADAP_PIDM = A.RORSTAT_PIDM
        AND C.SARADAP_LEVL_CODE = 'AC'
        AND C.SARADAP_CAMP_CODE <> 'SP'
        AND C.SARADAP_TERM_CODE_ENTRY = (
            SELECT MAX(Z.SARADAP_TERM_CODE_ENTRY) FROM SARADAP Z
            WHERE Z.SARADAP_PIDM = C.SARADAP_PIDM
            AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') AND :PERIOD       
            AND Z.SARADAP_APPL_NO = C.SARADAP_APPL_NO
        )
        AND D.SARAPPD_SEQ_NO = (
            SELECT MAX(Z.SARAPPD_SEQ_NO) FROM SARAPPD Z
            WHERE Z.SARAPPD_PIDM = D.SARAPPD_PIDM
            AND Z.SARAPPD_TERM_CODE_ENTRY = D.SARAPPD_TERM_CODE_ENTRY
            AND Z.SARAPPD_APPL_NO = D.SARAPPD_APPL_NO
        ) 
    )
)
;