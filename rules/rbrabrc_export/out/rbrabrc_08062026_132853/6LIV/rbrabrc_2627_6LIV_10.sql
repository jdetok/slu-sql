--Living expenses for off cmapus students
--less than half time time housing and food
SELECT 
case 
    when sysdate >= (select cutoff from sfs_utility.pbdg_cutoff_dates where period = :PERIOD) 
    then case
        when (nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD,X.SGBSTDN_PIDM,'N'),0) < RORCRHR_HALF_TIME_CR_HRS 
            and nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD,X.SGBSTDN_PIDM,'N'),0) > 0)
        then 0
    end 
end
FROM SGBSTDN X
JOIN RORCRHR on RORCRHR_PERIOD = :PERIOD
    AND RORCRHR_LEVL_CODE = X.SGBSTDN_LEVL_CODE
JOIN RORPRST on RORPRST_PIDM = X.SGBSTDN_PIDM
    AND RORPRST_PERIOD = :PERIOD
JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    and RORALGS_KEY_4 = '6LIV'
    and RORALGS_KEY_3 = CASE
        WHEN (RORPRST_XHS = '1' OR RORPRST_XHS IS NULL) THEN '1'   --off campus 
        WHEN (RORPRST_XHS IN ('3','4')) THEN '3'  --with family/relative
    END
    -- and RORALGS_KEY_2 = case x.SGBSTDN_STYP_CODE when 'T' then 'T' end
    and RORALGS_KEY_5 = X.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_9 is null
WHERE X.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX (Y.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y
    WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND X.SGBSTDN_STST_CODE IN  ('AS','IL','P1')
-- AND X.SGBSTDN_PIDM = :PIDM
--END
;

    --Living expenses for off cmapus students
--less than half time time housing and food
SELECT 
case 
    when sysdate >= (select cutoff from sfs_utility.pbdg_cutoff_dates where period = :PERIOD) 
    then case
        when (nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD,X.SGBSTDN_PIDM,'N'),0) < RORCRHR_HALF_TIME_CR_HRS 
            and nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD,X.SGBSTDN_PIDM,'N'),0) > 0)
        then 0
    end 
end

FROM SGBSTDN X, RORCRHR, RORALGS, RORPRST
WHERE RORALGS_KEY_1 = 'PBDG'
AND RORALGS_KEY_4 = '6LIV' -- budget component 	
AND CASE -- OFF CAMPUS HOUSING FLAG IN RORPRST
    WHEN (RORPRST_XHS = '1' OR RORPRST_XHS IS NULL) THEN '1'   --off campus 
	WHEN (RORPRST_XHS IN ('3','4')) THEN '3'  --with family/relative
END = RORALGS_KEY_3

AND X.SGBSTDN_TERM_CODE_EFF = (SELECT MAX (Y.SGBSTDN_TERM_CODE_EFF)
            FROM SGBSTDN Y
                WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
                    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD)

AND X.SGBSTDN_PIDM = RORPRST_PIDM
AND RORPRST_PERIOD = :PERIOD

AND RORCRHR_AIDY_CODE = :AIDY
AND RORCRHR_LEVL_CODE = X.SGBSTDN_LEVL_CODE
AND RORCRHR_PERIOD = :PERIOD

AND X.SGBSTDN_STST_CODE IN  ('AS','IL','P1')
-- AND X.SGBSTDN_PIDM = :PIDM
AND RORALGS_AIDY_CODE = :AIDY
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

;
--END