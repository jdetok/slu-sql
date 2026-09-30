-- Report request from Janice 9/30/2026 to compare students aid paid in a term to their term budget
select * from (
with pbb as (
    select 
        rbrapbc_pidm as pidm,
        rbrapbc_aidy_code as aidy,
        rbrapbc_period as term,
        sum(rbrapbc_amt) as budg
    from rbrapbc
    where rbrapbc_run_name = 'ACTUAL'
    and rbrapbc_pbtp_code = 'CAMP'
    group by rbrapbc_pidm, rbrapbc_aidy_code, rbrapbc_period
    order by rbrapbc_pidm, rbrapbc_period
), awards as (
    select
        rpratrm_pidm as pidm,
        rpratrm_term_code as term,
        sum(rpratrm_offer_amt) as ofrd
    from rpratrm
    group by rpratrm_pidm, rpratrm_term_code
)
select 
    -- a.pidm,
    spriden_id as bid,
    a.aidy,
    max(case when substr(a.term, 5, 2) = '10' then a.budg end) as fall_budg,
    max(case when substr(a.term, 5, 2) = '10' then b.ofrd end) as fall_ofrd,
    max(case when substr(a.term, 5, 2) = '20' then a.budg end) as spr_budg,
    max(case when substr(a.term, 5, 2) = '20' then b.ofrd end) as spr_ofrd
from pbb a
join awards b on a.pidm = b.pidm and a.term = b.term
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
group by spriden_id, a.aidy
) where fall_ofrd > fall_budg or spr_ofrd > spr_budg
;