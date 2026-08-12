select *
    -- sgbstdn_pidm as pidm, 
    -- spriden_id as bid, 
    -- sgbstdn_term_code_eff as term, 
    -- sgbstdn_stst_code as stst, 
    -- sgbstdn_styp_code as styp, 
    -- sgbstdn_levl_code as levl, 
    -- sgbstdn_degc_code_1 as degc, 
    -- sgbstdn_program_1 as prog,
    -- sgbstdn_majr_code_1 as majr, 
    -- stvmajr_cipc_code as cipc
from sgbstdn 
join stvmajr on stvmajr_code = sgbstdn_majr_code_1
join spriden on spriden_pidm = sgbstdn_pidm and spriden_change_ind is null
-- where sgbstdn_pidm = 35744
where spriden_id = '001456234'
order by sgbstdn_term_code_eff;

select sgbstdn_degc_code_1, stvdegc_desc, count(*)
from sgbstdn
join stvdegc on sgbstdn_degc_code_1 = stvdegc_code
where sgbstdn_levl_code like 'UG'
and sgbstdn_term_code_eff >= '202010'
group by sgbstdn_degc_code_1, stvdegc_desc;

select max(y.sgbstdn_term_code_eff)
from sgbstdn y
where y.sgbstdn_pidm = 35744
and y.sgbstdn_term_code_eff <= '202700'
and y.sgbstdn_stst_code in (select stvstst_code from stvstst where stvstst_reg_ind = 'N')
and not (
    (
        a.sgbstdn_levl_code = 'UG'
        and (
            (a.sgbstdn_degc_code_1 like 'B%' and y.sgbstdn_degc_code_1 like 'B%')
            or (a.sgbstdn_degc_code_1 = 'CERT' and y.sgbstdn_degc_code_1 = 'CERT')
        )
    ) or (
        a.sgbstdn_levl_code <> 'UG'
        and (
            zm.stvmajr_cipc_code = m.stvmajr_cipc_code
            or (
                y.sgbstdn_majr_code_1 = a.sgbstdn_majr_code_1
                and y.sgbstdn_degc_code_1 = a.sgbstdn_degc_code_1
            )
        )
    )
)
;
