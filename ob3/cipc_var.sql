select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    robnyud_value_196 as legacy,
    robnyud_value_195 as end_term,
    rorstat_pgrp_code as pgrp,
    b.rbrapbg_pbgp_code as bgrp_fall,
    c.rbrapbg_pbgp_code as bgrp_spr,
    robnyud_value_198 as ob3_levl,
    a.sgbstdn_levl_code as cur_levl,
    robnyud_value_193 as ob3_cipc,
    m.stvmajr_cipc_code as cur_cipc
from robnyud
join spriden on spriden_pidm = robnyud_pidm and spriden_change_ind is null
join rorstat on rorstat_pidm = robnyud_pidm and rorstat_aidy_code = '2627'
join rbrapbg b on b.rbrapbg_pidm = robnyud_pidm 
    and b.rbrapbg_run_name = 'ACTUAL'
    and b.rbrapbg_period = '202710'
join rbrapbg c on c.rbrapbg_pidm = robnyud_pidm 
    and c.rbrapbg_run_name = 'ACTUAL'
    and c.rbrapbg_period = '202720'
join sgbstdn a on a.sgbstdn_pidm = robnyud_pidm
    and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and (
        (
        (
            select substr(stvmajr_cipc_code, 0, 4) 
            from stvmajr 
            where stvmajr_code = a.sgbstdn_majr_code_1
        ) <> substr(robnyud_value_193, 0, 4)
        ) or a.sgbstdn_levl_code <> robnyud_value_198
    )
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= '202720'
    )
join stvmajr m on m.stvmajr_code = a.sgbstdn_majr_code_1
where robnyud_value_196 = 'Y'
;

select * from stvmajr where stvmajr_cipc_code = 130406;

select * from robnyud where robnyud_value_196 = 'Y';