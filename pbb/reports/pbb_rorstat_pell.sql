with dt as (
    select 'pbb_rorstat_pell_' || to_char(sysdate, 'MMDDYYYY_HHMISS') as t from dual
)
select (select t from dt) as ts, 
    spriden_id, spriden_last_name || ', ' || spriden_first_name as name,
    b.rorstat_tgrp_code as tgrp, b.rorstat_pgrp_code as pgrp,
    max(case when a.rbrapbg_period = '202710' then a.rbrapbg_pbgp_code end) as pbgp_fall,
    max(case when a.rbrapbg_period = '202720' then a.rbrapbg_pbgp_code end) as pbgp_spr
from rbrapbg a
join rorstat b on b.rorstat_pidm = a.rbrapbg_pidm
join (
    select rcresar_pidm, rcresar_aidy_code
    from rcrapp1
    join rcresar on rcresar_pidm = rcrapp1_pidm
        and rcresar_aidy_code = rcrapp1_aidy_code
        and rcresar_seq_no = rcrapp1_seq_no
        and rcresar_infc_code = rcrapp1_infc_code
    where rcrapp1_infc_code = 'EDE'
    and rcrapp1_curr_rec_ind = 'Y'
    and rcresar_pell_elgbl = 'Y'
) c on c.rcresar_pidm = a.rbrapbg_pidm
    and c.rcresar_aidy_code = b.rorstat_aidy_code
join spriden on spriden_pidm = a.rbrapbg_pidm and spriden_change_ind is null
where a.rbrapbg_run_name = 'ACTUAL'
and b.rorstat_aidy_code = '2627'
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = '1TUI'
    and rbrapbc_amt > 0
)
group by spriden_id, 
    spriden_last_name || ', ' || spriden_first_name,
    b.rorstat_tgrp_code, b.rorstat_pgrp_code    
;

desc rcresar;