-- select count(*) from (
with ps1ps2 as (
    select sfrstcr_pidm as pidm, count(distinct sfrstcr_ptrm_code) as pots
    from sfrstcr
    where sfrstcr_ptrm_code in ('PS1', 'PS2')
    and sfrstcr_bill_hr > '0'
    group by sfrstcr_pidm
), psf1 as (
    select sfrstcr_pidm as pidm
    from sfrstcr
    where sfrstcr_ptrm_code in ('PSF', '1')
    and sfrstcr_bill_hr > '0'
), maxterm as (
    select sgbstdn_pidm as pidm, max(sgbstdn_term_code_eff) as term
    from sgbstdn
    where sgbstdn_term_code_eff <= :period
    group by sgbstdn_pidm
)
select case
    when (c.pidm is not null or (b.pidm is not null and b.pots = 2)) then roralgs_amt
    when b.pidm is not null and b.pots = 1 then roralgs_amt / 2
end as amt
from sgbstdn a
inner join maxterm m on m.pidm = a.sgbstdn_pidm
inner join roralgs on roralgs_aidy_code = :aidy
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '2FEE'
    and roralgs_key_7 = 'PS'
left join ps1ps2 b on b.pidm = a.sgbstdn_pidm
left join psf1 c on c.pidm = a.sgbstdn_pidm
where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and a.sgbstdn_term_code_eff = m.term
-- exclude global grads
and not exists (
    select 1 from sgrsatt
    where sgrsatt_pidm = a.sgbstdn_pidm
    and sgrsatt_atts_code in ('GG2', 'GG3', 'GG4', 'GG5', 'GG6')
    and sgrsatt_term_code_eff = (
        select max(z.sgrsatt_term_code_eff)
        from sgrsatt z
        where z.sgrsatt_pidm = sgrsatt_pidm
        and z.sgrsatt_term_code_eff <= a.sgbstdn_term_code_eff
    )
)
-- )

;


-- SPS SEQUENCES ======================================================
-- UG AND GR GET THE SAME 120 OR 60 REGARDLESS OF LEVEL
-- BASED ON PART OF TERM ENROLLMENT
-- sequence 100 - UG PS FULL TERM
-- P1 FOR ACTIVE STUDENTS IS ONLY NECESSARY FOR SPS
SELECT CASE 
    -- BOTH PARTS OF TERM GET FULL
    WHEN ( -- both PS1 AND PS2        
        EXISTS (
            SELECT 'X' FROM SFRSTCR
            WHERE SFRSTCR_PIDM = a.SGBSTDN_PIDM
            AND SFRSTCR_PTRM_CODE = 'PS1'
            AND SFRSTCR_BILL_HR > '0'
        )
        AND EXISTS (
            SELECT 'X' FROM SFRSTCR
            WHERE SFRSTCR_PIDM = a.SGBSTDN_PIDM
            AND SFRSTCR_PTRM_CODE = 'PS2'
            AND SFRSTCR_BILL_HR > '0'
        )
    ) OR EXISTS ( -- ONLY PSF
            SELECT 'X' FROM SFRSTCR
            WHERE SFRSTCR_PIDM = a.SGBSTDN_PIDM
            AND SFRSTCR_PTRM_CODE = 'PSF'
            AND SFRSTCR_BILL_HR > '0'
    ) OR EXISTS ( -- ONLY 1
            SELECT 'X' FROM SFRSTCR
            WHERE SFRSTCR_PIDM = a.SGBSTDN_PIDM
            AND SFRSTCR_PTRM_CODE = '1'
            AND SFRSTCR_BILL_HR > '0'    
    ) THEN RORALGS_AMT
    -- ONLY ONE PART OF TERM GETS HALF
    WHEN EXISTS (
        SELECT 'X' FROM SFRSTCR
        WHERE SFRSTCR_PIDM = a.SGBSTDN_PIDM
        AND SFRSTCR_PTRM_CODE in ('PS1', 'PS2') -- FINDS PS1 OR PS2
        AND SFRSTCR_BILL_HR > '0'
    ) THEN RORALGS_AMT / 2
END
FROM SGBSTDN a, RORALGS
WHERE RORALGS_KEY_1 = 'PBDG' 
AND RORALGS_KEY_4 = '2FEE'
AND CASE 
    WHEN a.SGBSTDN_COLL_CODE_1 = 'PS' then 'PS' 
END = RORALGS_KEY_7
-- sgbstdn term
AND a.SGBSTDN_TERM_CODE_EFF = (
    SELECT MAX(SGBSTDN_TERM_CODE_EFF)
    FROM SGBSTDN
    WHERE SGBSTDN_PIDM = a.SGBSTDN_PIDM
    AND SGBSTDN_TERM_CODE_EFF <= :PERIOD
)
-- EXCLUDE GLOBAL GRADS
AND a.SGBSTDN_PIDM NOT IN (
    SELECT SGRSATT_PIDM
    FROM SGRSATT
    WHERE SGRSATT_ATTS_CODE IN ('GG2','GG3','GG4','GG5','GG6')
    AND SGRSATT_TERM_CODE_EFF = (
        SELECT MAX(z.SGRSATT_TERM_CODE_EFF)
        FROM SGRSATT z
        WHERE z.SGRSATT_PIDM = SGRSATT_PIDM
        AND z.SGRSATT_TERM_CODE_EFF <= a.SGBSTDN_TERM_CODE_EFF
    )
)
AND a.SGBSTDN_STST_CODE IN  ('AS','IL','P1') -- P1 only needed for SPS
AND RORALGS_AIDY_CODE = :AIDY
--AND a.SGBSTDN_PIDM = :PIDM
-- ;
