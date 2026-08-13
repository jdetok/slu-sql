--UG PS COLLEGE ENROLLED 
SELECT CASE
    WHEN NVL(ROKMISC.F_CALC_STUD_BILL_HRS(:PERIOD, X.SGBSTDN_PIDM, 'N'), 0) > 0
        THEN round(roralgs_amt * NVL(ROKMISC.F_CALC_STUD_BILL_HRS(:PERIOD, X.SGBSTDN_PIDM, 'N'), 0))
    END as calc_amt
FROM SGBSTDN X 
left join SGRSATT b on b.SGRSATT_PIDM = x.SGBSTDN_PIDM
    AND b.SGRSATT_TERM_CODE_EFF = (
        SELECT MAX(Y.SGRSATT_TERM_CODE_EFF)
        FROM SGRSATT Y
        WHERE Y.SGRSATT_TERM_CODE_EFF <= :PERIOD
        AND Y.SGRSATT_PIDM =  b.SGRSATT_PIDM
    )
    and sgrsatt_atts_code in ('PSMV', 'PS15', 'REGV', 'REGF')
left join RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    AND RORALGS_KEY_4 = '1TUI'
    and RORALGS_KEY_5 = X.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_6 = X.SGBSTDN_CAMP_CODE
    and RORALGS_KEY_7 = X.SGBSTDN_COLL_CODE_1
    and RORALGS_KEY_9 is null
    and (
        RORALGS_KEY_10 = b.SGRSATT_ATTS_CODE
        or (RORALGS_KEY_10 IS NULL and b.SGRSATT_ATTS_CODE is null)
    )
    and RORALGS_KEY_11 is null
WHERE X.SGBSTDN_LEVL_CODE = 'UG'
AND X.SGBSTDN_CAMP_CODE = 'FR'
AND X.SGBSTDN_COLL_CODE_1 = 'PS'
AND X.SGBSTDN_STST_CODE IN  ('AS','IL','P1')
AND X.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(Y.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y
    WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
AND X.SGBSTDN_PIDM = :PIDM
;
select * from roralgs where roralgs_key_7 in ('PS') and roralgs_key_5 = 'UG';

select sgrsatt.*
from sgbstdn 
join sgrsatt on sgrsatt_pidm = sgbstdn_pidm
where sgbstdn_pidm = (select spriden_pidm from spriden where spriden_id = '001515669' and spriden_change_ind is null)
and sgrsatt_term_code_eff = (
    select max(z.sgrsatt_term_code_eff)
    from sgrsatt z
    where z.sgrsatt_pidm = sgrsatt_pidm
    and z.sgrsatt_term_code_eff <= '202720'
)
;

select * from sgbstdn x
join RORALGS on RORALGS_AIDY_CODE = :AIDY
    and RORALGS_KEY_1 = 'PBDG'
    AND RORALGS_KEY_4 = '1TUI'
    and RORALGS_KEY_5 = X.SGBSTDN_LEVL_CODE
    and RORALGS_KEY_6 = X.SGBSTDN_CAMP_CODE
    and RORALGS_KEY_7 = X.SGBSTDN_COLL_CODE_1
    and RORALGS_KEY_9 is null
    and (RORALGS_KEY_10 in ('PSMV', 'PS15')
     or roralgs_key_10 is null)
    and RORALGS_KEY_11 is null
WHERE X.SGBSTDN_LEVL_CODE = 'UG'
AND X.SGBSTDN_CAMP_CODE = 'FR'
AND X.SGBSTDN_COLL_CODE_1 = 'PS'
and sgbstdn_pidm = (select spriden_pidm from spriden where spriden_id = '001515669' and spriden_change_ind is null)
AND X.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(Y.SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN Y
    WHERE Y.SGBSTDN_PIDM = X.SGBSTDN_PIDM
    AND Y.SGBSTDN_TERM_CODE_EFF <= :PERIOD
);

select * from roralgs
 where RORALGS_KEY_1 = 'PBDG'
    AND RORALGS_KEY_4 = '1TUI'
    and RORALGS_KEY_5 = 'UG'
    and RORALGS_KEY_6 = 'FR'
    and RORALGS_KEY_7 = 'PS'
    -- and RORALGS_KEY_9 is null
    and (RORALGS_KEY_10 in ('PSMV', 'PS15')
     or roralgs_key_10 is null)
    and RORALGS_KEY_11 is null;

select ROKMISC.F_CALC_STUD_BILL_HRS('202710', 1524602, 'N') from dual;

select spriden_id from spriden where spriden_pidm = 1253273 and spriden_change_ind is null;

SELECT data_type FROM all_tab_columns
WHERE table_name = 'ROBUSDF' AND column_name = 'ROBUSDF_VALUE_321';

SELECT robusdf_value_321 FROM robusdf
WHERE robusdf_pidm = 1479038 AND robusdf_aidy_code = '2627';

  SELECT DISTINCT robusdf_value_321 FROM robusdf
  WHERE robusdf_aidy_code = '2627'
  FETCH FIRST 20 ROWS ONLY;