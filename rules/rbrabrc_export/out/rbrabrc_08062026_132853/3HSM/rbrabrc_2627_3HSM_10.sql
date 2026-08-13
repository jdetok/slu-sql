--less than half time time housing and food
SELECT case when  
nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD,X.SGBSTDN_PIDM,'N'),0) < RORCRHR_HALF_TIME_CR_HRS and
nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD,X.SGBSTDN_PIDM,'N'),0) >0  then 0
            end as calc_amt

FROM SGBSTDN X, RORCRHR, RORALGS
WHERE     RORALGS_KEY_1 = 'PBDG'
    AND RORALGS_KEY_4 = '3HSM' -- budget component                        


AND X.SGBSTDN_TERM_CODE_EFF = (SELECT MAX (Y.SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN Y
                WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
                    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD)

AND RORCRHR_AIDY_CODE = :AIDY
AND RORCRHR_LEVL_CODE = X.SGBSTDN_LEVL_CODE
AND RORCRHR_PERIOD = :PERIOD

AND X.SGBSTDN_STST_CODE IN  ('AS','IL','P1')
-- AND X.SGBSTDN_PIDM = :PIDM
AND RORALGS_AIDY_CODE = :AIDY
--END