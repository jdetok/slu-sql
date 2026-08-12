select spriden_id, rprawrd_fund_code
from rprawrd
join spriden on spriden_change_ind is null and spriden_pidm = rprawrd_pidm
where rprawrd_awst_code = 'ACPT'
and rprawrd_aidy_code = '2627'

and (
    (
        rprawrd_fund_code = 'DLPL'
        and not exists (
            select 1
            from rbrapbc
            where rbrapbc_pbcp_code  = 'PLLF'
            and rbrapbc_run_name = 'ACTUAL'
            and rbrapbc_pidm = rprawrd_pidm
            and rbrapbc_aidy_code = rprawrd_aidy_code
        )        
    ) or (
        rprawrd_fund_code = 'DLGL'
        and not exists (
            select 1
            from rbrapbc
            where rbrapbc_pbcp_code = 'GPLF'
            and rbrapbc_run_name = 'ACTUAL'
            and rbrapbc_pidm = rprawrd_pidm
            and rbrapbc_aidy_code = rprawrd_aidy_code
        )     
    )
)

and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pbcp_code in ('GPFL', 'UNLF', 'SULF', 'PLLF')
    and rbrapbc_run_name = 'ACTUAL'
    and rbrapbc_pidm = rprawrd_pidm
    and rbrapbc_aidy_code = rprawrd_aidy_code
);


select * from rbrpbcp;
select * from rbrapbc;

--GRAD DEN WITH SGASTDN
SELECT RORALGS_AMT, spriden_id
FROM SGBSTDN X
join spriden on spriden_change_ind is null and spriden_pidm = sgbstdn_pidm
INNER JOIN RORALGS on RORALGS_AIDY_CODE = :AIDY
    AND RORALGS_KEY_1 = 'PBDG'
    AND RORALGS_KEY_4 = '1TUI'
    AND RORALGS_KEY_5 = X.SGBSTDN_LEVL_CODE
    AND RORALGS_KEY_7 = X.SGBSTDN_MAJR_CODE_1
WHERE X.SGBSTDN_MAJR_CODE_1 = 'DEN'
-- AND X.SGBSTDN_PIDM = :pidm
AND X.SGBSTDN_STST_CODE IN  ('AS','IL','P1')
AND X.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(Y.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y
    WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD
);