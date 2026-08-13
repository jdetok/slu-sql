-- sequence 1: MED, LOOK FOR ENROLLMENT
SELECT CASE 
    when sysdate >= (select cutoff from sfs_utility.pbdg_cutoff_dates where period = :PERIOD) 
    then case
        WHEN nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD, a.SGBSTDN_PIDM,'N'),0) >= b.RORCRHR_FULL_TIME_CR_HRS 
            THEN RORALGS_AMT
        WHEN nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD, a.SGBSTDN_PIDM,'N'),0) >= b.RORCRHR_HALF_TIME_CR_HRS 
            THEN ROUND(RORALGS_AMT / 2)
        WHEN nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD, a.SGBSTDN_PIDM,'N'),0) < b.RORCRHR_HALF_TIME_CR_HRS 
        and nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD, a.SGBSTDN_PIDM,'N'),0) > 0
            THEN ROUND(RORALGS_AMT / 4)
    END 
end
FROM SGBSTDN a
JOIN RORALGS ON RORALGS_AIDY_CODE = :AIDY
    AND RORALGS_KEY_1 = 'PBDG'
    AND RORALGS_KEY_4 = '7BS'
    AND RORALGS_KEY_5 = a.SGBSTDN_LEVL_CODE
    AND RORALGS_KEY_9 IS NULL
    AND RORALGS_KEY_11 IS NULL
JOIN RORCRHR b 
    ON b.RORCRHR_LEVL_CODE = a.SGBSTDN_LEVL_CODE
    AND b.RORCRHR_AIDY_CODE = :AIDY
    AND b.RORCRHR_PERIOD = :PERIOD
-- WHERE a.SGBSTDN_PIDM = :PIDM
AND a.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN
    WHERE SGBSTDN_PIDM = a.SGBSTDN_PIDM
    AND SGBSTDN_TERM_CODE_EFF <= :PERIOD
)