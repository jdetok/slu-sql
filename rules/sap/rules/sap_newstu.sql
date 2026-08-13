select a.saradap_pidm
from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_signf_ind = 'Y'
    and c.stvapdc_inst_acc_ind = 'Y'
where a.saradap_term_code_entry = (
    select max(z.saradap_term_code_entry) from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry = :TERM
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
and not exists (
    select 1 from shrlgpa z
    where z.shrlgpa_pidm = a.saradap_pidm
    -- and z.shrlgpa_levl_code = a.saradap_levl_code
    and z.shrlgpa_levl_code = case when a.saradap_levl_code = 'AC' then 'UG' else a.saradap_levl_code end
    and z.shrlgpa_gpa_type_ind = 'I'
    and z.shrlgpa_hours_attempted > 0
)
and a.saradap_pidm = (select spriden_pidm from spriden where spriden_id = '001506403' and spriden_change_ind is null)
-- and a.saradap_pidm = (select spriden_pidm from spriden where spriden_id = '001506403' and spriden_change_ind is null)

-- and a.saradap_pidm = :pidm
;

select * from saradap a where a.saradap_pidm = (select spriden_pidm from spriden where spriden_id = '001472490' and spriden_change_ind is null);

-- OLD:
SELECT DISTINCT(SARADAP_PIDM)
FROM SARADAP C, SHRLGPA D, STVAPDC, SARAPPD A
WHERE A.SARAPPD_APDC_CODE = STVAPDC_CODE
AND STVAPDC_INST_ACC_IND = 'Y'
AND STVAPDC_SIGNF_IND = 'Y'
-- AND C.SARADAP_PIDM =:PIDM           
AND C.SARADAP_PIDM = A.SARAPPD_PIDM
AND C.SARADAP_TERM_CODE_ENTRY = (
    SELECT MAX(D.SARADAP_TERM_CODE_ENTRY)
    FROM SARADAP D 
    WHERE D.SARADAP_PIDM = C.SARADAP_PIDM
    AND D.SARADAP_TERM_CODE_ENTRY > :TERM           
)
AND C.SARADAP_PIDM NOT IN (
    SELECT D.SHRLGPA_PIDM
    FROM SHRLGPA E
    WHERE E.SHRLGPA_HOURS_ATTEMPTED > 0
    AND E.SHRLGPA_GPA_TYPE_IND = 'I'
    AND C.SARADAP_PIDM = E.SHRLGPA_PIDM
    AND D.SHRLGPA_PIDM = E.SHRLGPA_PIDM
    AND C.SARADAP_LEVL_CODE = E.SHRLGPA_LEVL_CODE
)
;

select * from gjbprun;

-- SELECT GJBPRUN_VALUE
-- FROM   GJBPRUN
-- WHERE  GJBPRUN_JOB = 'ROPSAPR'
-- AND    GJBPRUN_NUMBER = '03'
-- AND    GJBPRUN_ONE_UP_NO = (SELECT MAX(GJBPRUN_ONE_UP_NO)
--                             FROM   GJBPRUN
--                             WHERE  GJBPRUN_JOB = 'ROPSAPR'
--                             AND    GJBPRUN_NUMBER = '03')

SELECT *
          FROM   GJBPRUN
        --   WHERE  GJBPRUN_JOB like '%SAP%'
        --   AND    GJBPRUN_NUMBER = '03'
        --   AND    GJBPRUN_ONE_UP_NO = (SELECT MAX(GJBPRUN_ONE_UP_NO)
        --                               FROM   GJBPRUN
        --                               WHERE  GJBPRUN_JOB = 'ROPSAPR'
        --   )
        --                               AND    GJBPRUN_NUMBER = '03')
    order by gjbprun_one_up_no desc
    -- order by gjbprun_activity_date desc

;

-- 8440694

SELECT table_name, comments
FROM all_tab_comments
WHERE table_name LIKE '%RUN%'
ORDER BY table_name;