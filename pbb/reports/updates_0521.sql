with fall_grp as (
    select rbrapbg_pidm as pidm, rbrapbg_aidy_code as aidy, rbrapbg_pbgp_code as grp
    from rbrapbg
    where rbrapbg_run_name = 'ACTUAL'
    and rbrapbg_period = '202710'
), spr_grp as (
    select rbrapbg_pidm as pidm, rbrapbg_aidy_code as aidy, rbrapbg_pbgp_code as grp
    from rbrapbg
    where rbrapbg_run_name = 'ACTUAL'
    and rbrapbg_period = '202720'
), dt as (select 'group_mismatch_' || to_char(sysdate, 'MMDDYYYY_HHMISS') as t from dual)
select 
    (select t from dt) as ts,
    spriden_id, spriden_last_name || ', ' || spriden_first_name as name, 
    r.rorstat_aidy_code as aidy, r.rorstat_tgrp_code as tgrp, r.rorstat_pgrp_code as pgrp,
    a.grp as fall_group, b.grp as spr_group
from fall_grp a 
join spr_grp b on b.pidm = a.pidm
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
join rorstat r on r.rorstat_pidm = a.pidm and r.rorstat_aidy_code = a.aidy
where a.grp <> b.grp

;

desc rbrapbg;

with dt as (
    select 'pbb_3hsm_6liv_' || to_char(sysdate, 'MMDDYYYY_HHMISS') as t from dual
)
select (select t from dt) as ts, 
    spriden_id, spriden_last_name || ', ' || spriden_first_name as name,
    b.rorstat_tgrp_code as tgrp, b.rorstat_pgrp_code as pgrp
from rbrapbg a
join rorstat b on b.rorstat_pidm = a.rbrapbg_pidm
join spriden on spriden_pidm = a.rbrapbg_pidm and spriden_change_ind is null
join robinst on robinst_aidy_code = b.rorstat_aidy_code
where a.rbrapbg_run_name = 'ACTUAL'
and b.rorstat_aidy_code = '2627'
and a.rbrapbg_period <= robinst_aidy_end_year || '20'
and exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = a.rbrapbg_pidm
    and rbrapbc_period = a.rbrapbg_period
    and rbrapbc_pbcp_code = '3HSM'
    and rbrapbc_pbtp_code = 'CAMP'
    and rbrapbc_run_name = 'ACTUAL'
    and rbrapbc_amt > 0
)
and exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = a.rbrapbg_pidm
    and rbrapbc_period = a.rbrapbg_period
    and rbrapbc_pbcp_code = '6LIV'
    and rbrapbc_pbtp_code = 'CAMP'
	  and rbrapbc_run_name = 'ACTUAL'
    and rbrapbc_amt > 0
)
group by spriden_id, 
    spriden_last_name || ', ' || spriden_first_name,
    b.rorstat_tgrp_code, b.rorstat_pgrp_code

    ;

with dt as (
    select 'no_or_zero_1tui_' || to_char(sysdate, 'MMDDYYYY_HHMISS') as t from dual
), aidy as (
    select '2627' as ay from dual -- make dynamic
), stu_rec as (
    select 
        sgbstdn_pidm as pidm,
        sgbstdn_levl_code as levl,
        sgbstdn_coll_code_1 as coll,
        sgbstdn_program_1 as prog
    from sgbstdn a
    where a.sgbstdn_term_code_eff = (
        select max(sgbstdn_term_code_eff)
        from sgbstdn where sgbstdn_pidm = a.sgbstdn_pidm
    )
), stu_app as (
    select
        a.saradap_pidm as pidm,
        a.saradap_levl_code as levl,
        a.saradap_coll_code_1 as coll,
        a.saradap_program_1 as prog
    from saradap a
    join sarappd b on b.sarappd_pidm = a.saradap_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_inst_acc_ind = 'Y'
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_stdn_acc_ind = 'Y'
    join robinst r on r.robinst_aidy_code = (select ay from aidy)
    where a.saradap_term_code_entry = (
        select max(saradap_term_code_entry)
        from saradap 
        where saradap_pidm = a.saradap_pidm
        and saradap_term_code_entry <= r.robinst_aidy_end_year || '20'
    )
    and b.sarappd_seq_no = (
        select max(sarappd_seq_no)
        from sarappd
        where sarappd_pidm = b.sarappd_pidm
        and sarappd_appl_no = b.sarappd_appl_no
        and sarappd_term_code_entry = b.sarappd_term_code_entry
    )
)
select 
    (select t from dt) as ts,
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    rbrapbg_period as period,
    r.rorstat_tgrp_code as tgrp,
    r.rorstat_pgrp_code as pgrp,
    rbrapbg_pbgp_code as pbgp,
    nvl(nvl(a.levl, b.levl), '-') as levl,
    nvl(nvl(a.coll, b.coll), '-') as coll,
    nvl(nvl(a.prog, b.prog), '-') as prog,
    (
        select sum(rbrapbc_amt)
        from rbrapbc
        where rbrapbc_pidm = rbrapbg_pidm
        and rbrapbc_period = rbrapbg_period
    ) as total_budget
from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
join rorstat r on r.rorstat_pidm = rbrapbg_pidm and r.rorstat_aidy_code = (select ay from aidy)
left join stu_rec a on a.pidm = rbrapbg_pidm
left join stu_app b on b.pidm = rbrapbg_pidm
where rbrapbg_run_name = 'ACTUAL'
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = '1TUI'
    and rbrapbc_amt > 0
)

;

-- =================

with dt as (
    select '\\ds.slu.edu\DEP\Enrollment Retention Management\Alteryx Reports\Student Financial Services\pbb_reports\missing_or_zero_component\' || 'component' || '\zero_or_missing_' || 'component' || '_' || to_char(sysdate, 'MMDDYYYY_HHMISS') || '.csv' as t from dual
), aidy as (
    select 'aidy' as ay from dual -- make dynamic
), stu_rec as (
    select 
        sgbstdn_pidm as pidm,
        sgbstdn_levl_code as levl,
        sgbstdn_coll_code_1 as coll,
        sgbstdn_program_1 as prog
    from sgbstdn a
    where a.sgbstdn_term_code_eff = (
        select max(sgbstdn_term_code_eff)
        from sgbstdn where sgbstdn_pidm = a.sgbstdn_pidm
    )
), stu_app as (
    select
        a.saradap_pidm as pidm,
        a.saradap_levl_code as levl,
        a.saradap_coll_code_1 as coll,
        a.saradap_program_1 as prog
    from saradap a
    join sarappd b on b.sarappd_pidm = a.saradap_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_inst_acc_ind = 'Y'
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_stdn_acc_ind = 'Y'
    join robinst r on r.robinst_aidy_code = (select ay from aidy)
    where a.saradap_term_code_entry = (
        select max(saradap_term_code_entry)
        from saradap 
        where saradap_pidm = a.saradap_pidm
        and saradap_term_code_entry <= r.robinst_aidy_end_year || '20'
    )
    and b.sarappd_seq_no = (
        select max(sarappd_seq_no)
        from sarappd
        where sarappd_pidm = b.sarappd_pidm
        and sarappd_appl_no = b.sarappd_appl_no
        and sarappd_term_code_entry = b.sarappd_term_code_entry
    )
)
select 
    (select t from dt) as ts,
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    'component' as component,
    rbrapbg_period as period,
    r.rorstat_tgrp_code as tgrp,
    r.rorstat_pgrp_code as pgrp,
    rbrapbg_pbgp_code as pbgp,
    nvl(nvl(a.levl, b.levl), '-') as levl,
    nvl(nvl(a.coll, b.coll), '-') as coll,
    nvl(nvl(a.prog, b.prog), '-') as prog,
    (
        select sum(rbrapbc_amt)
        from rbrapbc
        where rbrapbc_pidm = rbrapbg_pidm
        and rbrapbc_period = rbrapbg_period
    ) as total_budget
from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
join rorstat r on r.rorstat_pidm = rbrapbg_pidm and r.rorstat_aidy_code = (select ay from aidy)
left join stu_rec a on a.pidm = rbrapbg_pidm
left join stu_app b on b.pidm = rbrapbg_pidm
where rbrapbg_run_name = 'ACTUAL'
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = 'component'
    and rbrapbc_amt > 0
)

;



--=====

with dt as (
    select '\\ds.slu.edu\DEP\Enrollment Retention Management\Alteryx Reports\Student Financial Services\pbb_reports\missing_or_zero_component\' || 'component' || '\zero_or_missing_' || 'component' || '_' || to_char(sysdate, 'MMDDYYYY_HHMISS') || '.csv' as t from dual
), aidy as (
    select 'aidy' as ay from dual -- make dynamic
), stu_rec as (
    select 
        sgbstdn_pidm as pidm,
        sgbstdn_levl_code as levl,
        sgbstdn_coll_code_1 as coll,
        sgbstdn_program_1 as prog
    from sgbstdn a
    where a.sgbstdn_term_code_eff = (
        select max(sgbstdn_term_code_eff)
        from sgbstdn where sgbstdn_pidm = a.sgbstdn_pidm
    )
), stu_app as (
    select
        a.saradap_pidm as pidm,
        a.saradap_levl_code as levl,
        a.saradap_coll_code_1 as coll,
        a.saradap_program_1 as prog
    from saradap a
    join sarappd b on b.sarappd_pidm = a.saradap_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_inst_acc_ind = 'Y'
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_stdn_acc_ind = 'Y'
    join robinst r on r.robinst_aidy_code = (select ay from aidy)
    where a.saradap_term_code_entry = (
        select max(saradap_term_code_entry)
        from saradap 
        where saradap_pidm = a.saradap_pidm
        and saradap_term_code_entry <= r.robinst_aidy_end_year || '20'
    )
    and b.sarappd_seq_no = (
        select max(sarappd_seq_no)
        from sarappd
        where sarappd_pidm = b.sarappd_pidm
        and sarappd_appl_no = b.sarappd_appl_no
        and sarappd_term_code_entry = b.sarappd_term_code_entry
    )
)
select 
    (select t from dt) as ts,
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    'component' as component,
    rbrapbg_period as period,
    r.rorstat_tgrp_code as tgrp,
    r.rorstat_pgrp_code as pgrp,
    rbrapbg_pbgp_code as pbgp,
    nvl(nvl(a.levl, b.levl), '-') as levl,
    nvl(nvl(a.coll, b.coll), '-') as coll,
    nvl(nvl(a.prog, b.prog), '-') as prog,
    (
        select sum(rbrapbc_amt)
        from rbrapbc
        where rbrapbc_pidm = rbrapbg_pidm
        and rbrapbc_period = rbrapbg_period
    ) as total_budget
from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
join rorstat r on r.rorstat_pidm = rbrapbg_pidm and r.rorstat_aidy_code = (select ay from aidy)
left join stu_rec a on a.pidm = rbrapbg_pidm
left join stu_app b on b.pidm = rbrapbg_pidm
where rbrapbg_run_name = 'ACTUAL'
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = 'component'
    and rbrapbc_amt > 0
)

;

with dt as (
    select '\\ds.slu.edu\DEP\Enrollment Retention Management\Alteryx Reports\Student Financial Services\pbb_reports\missing_or_zero_component\' || 'component' || '\zero_or_missing_' || 'component' || '_' || to_char(sysdate, 'MMDDYYYY_HHMISS') || '.csv' as t from dual
), aidy as (
    select 'aidy' as ay from dual -- make dynamic
), stu_rec as (
    select 
        sgbstdn_pidm as pidm,
        sgbstdn_levl_code as levl,
        sgbstdn_coll_code_1 as coll,
        sgbstdn_program_1 as prog
    from sgbstdn a
    where a.sgbstdn_term_code_eff = (
        select max(sgbstdn_term_code_eff)
        from sgbstdn where sgbstdn_pidm = a.sgbstdn_pidm
    )
), stu_app as (
    select
        a.saradap_pidm as pidm,
        a.saradap_levl_code as levl,
        a.saradap_coll_code_1 as coll,
        a.saradap_program_1 as prog
    from saradap a
    join sarappd b on b.sarappd_pidm = a.saradap_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_inst_acc_ind = 'Y'
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_stdn_acc_ind = 'Y'
    join robinst r on r.robinst_aidy_code = (select ay from aidy)
    where a.saradap_term_code_entry = (
        select max(saradap_term_code_entry)
        from saradap 
        where saradap_pidm = a.saradap_pidm
        and saradap_term_code_entry <= r.robinst_aidy_end_year || '20'
    )
    and b.sarappd_seq_no = (
        select max(sarappd_seq_no)
        from sarappd
        where sarappd_pidm = b.sarappd_pidm
        and sarappd_appl_no = b.sarappd_appl_no
        and sarappd_term_code_entry = b.sarappd_term_code_entry
    )
)
select 
    (select t from dt) as ts,
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    'component' as component,
    rbrapbg_period as period,
    r.rorstat_tgrp_code as tgrp,
    r.rorstat_pgrp_code as pgrp,
    rbrapbg_pbgp_code as pbgp,
    nvl(nvl(a.levl, b.levl), '-') as levl,
    nvl(nvl(a.coll, b.coll), '-') as coll,
    nvl(nvl(a.prog, b.prog), '-') as prog,
    (
        select sum(rbrapbc_amt)
        from rbrapbc
        where rbrapbc_pidm = rbrapbg_pidm
        and rbrapbc_period = rbrapbg_period
    ) as total_budget
from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
join rorstat r on r.rorstat_pidm = rbrapbg_pidm and r.rorstat_aidy_code = (select ay from aidy)
left join stu_rec a on a.pidm = rbrapbg_pidm
left join stu_app b on b.pidm = rbrapbg_pidm
where rbrapbg_run_name = 'ACTUAL'
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = 'component'
    and rbrapbc_amt > 0
)

;

with dt as (
    select '\\ds.slu.edu\DEP\Enrollment Retention Management\Alteryx Reports\Student Financial Services\pbb_reports\missing_or_zero_component\' || 'component' || '\zero_or_missing_' || 'component' || '_' || to_char(sysdate, 'MMDDYYYY_HHMISS') || '.csv' as t from dual
), aidy as (
    select 'aidy' as ay from dual -- make dynamic
), stu_rec as (
    select 
        sgbstdn_pidm as pidm,
        sgbstdn_levl_code as levl,
        sgbstdn_coll_code_1 as coll,
        sgbstdn_program_1 as prog
    from sgbstdn a
    where a.sgbstdn_term_code_eff = (
        select max(sgbstdn_term_code_eff)
        from sgbstdn where sgbstdn_pidm = a.sgbstdn_pidm
    )
), stu_app as (
    select
        a.saradap_pidm as pidm,
        a.saradap_levl_code as levl,
        a.saradap_coll_code_1 as coll,
        a.saradap_program_1 as prog
    from saradap a
    join sarappd b on b.sarappd_pidm = a.saradap_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_inst_acc_ind = 'Y'
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_stdn_acc_ind = 'Y'
    join robinst r on r.robinst_aidy_code = (select ay from aidy)
    where a.saradap_term_code_entry = (
        select max(saradap_term_code_entry)
        from saradap 
        where saradap_pidm = a.saradap_pidm
        and saradap_term_code_entry <= r.robinst_aidy_end_year || '20'
    )
    and b.sarappd_seq_no = (
        select max(sarappd_seq_no)
        from sarappd
        where sarappd_pidm = b.sarappd_pidm
        and sarappd_appl_no = b.sarappd_appl_no
        and sarappd_term_code_entry = b.sarappd_term_code_entry
    )
)
select 
    (select t from dt) as ts,
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    'component' as component,
    rbrapbg_period as period,
    r.rorstat_tgrp_code as tgrp,
    r.rorstat_pgrp_code as pgrp,
    rbrapbg_pbgp_code as pbgp,
    nvl(nvl(a.levl, b.levl), '-') as levl,
    nvl(nvl(a.coll, b.coll), '-') as coll,
    nvl(nvl(a.prog, b.prog), '-') as prog,
    (
        select sum(rbrapbc_amt)
        from rbrapbc
        where rbrapbc_pidm = rbrapbg_pidm
        and rbrapbc_period = rbrapbg_period
    ) as total_budget
from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
join rorstat r on r.rorstat_pidm = rbrapbg_pidm and r.rorstat_aidy_code = (select ay from aidy)
left join stu_rec a on a.pidm = rbrapbg_pidm
left join stu_app b on b.pidm = rbrapbg_pidm
where rbrapbg_run_name = 'ACTUAL'
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = 'component'
    and rbrapbc_amt > 0
)

;

with dt as (
    select '\\ds.slu.edu\DEP\Enrollment Retention Management\Alteryx Reports\Student Financial Services\pbb_reports\missing_or_zero_component\' || 'component' || '\zero_or_missing_' || 'component' || '_' || to_char(sysdate, 'MMDDYYYY_HHMISS') || '.csv' as t from dual
), aidy as (
    select 'aidy' as ay from dual -- make dynamic
), stu_rec as (
    select 
        sgbstdn_pidm as pidm,
        sgbstdn_levl_code as levl,
        sgbstdn_coll_code_1 as coll,
        sgbstdn_program_1 as prog
    from sgbstdn a
    where a.sgbstdn_term_code_eff = (
        select max(sgbstdn_term_code_eff)
        from sgbstdn where sgbstdn_pidm = a.sgbstdn_pidm
    )
), stu_app as (
    select
        a.saradap_pidm as pidm,
        a.saradap_levl_code as levl,
        a.saradap_coll_code_1 as coll,
        a.saradap_program_1 as prog
    from saradap a
    join sarappd b on b.sarappd_pidm = a.saradap_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
    join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_inst_acc_ind = 'Y'
        and c.stvapdc_signf_ind = 'Y'
        and c.stvapdc_stdn_acc_ind = 'Y'
    join robinst r on r.robinst_aidy_code = (select ay from aidy)
    where a.saradap_term_code_entry = (
        select max(saradap_term_code_entry)
        from saradap 
        where saradap_pidm = a.saradap_pidm
        and saradap_term_code_entry <= r.robinst_aidy_end_year || '20'
    )
    and b.sarappd_seq_no = (
        select max(sarappd_seq_no)
        from sarappd
        where sarappd_pidm = b.sarappd_pidm
        and sarappd_appl_no = b.sarappd_appl_no
        and sarappd_term_code_entry = b.sarappd_term_code_entry
    )
)
select 
    (select t from dt) as ts,
    spriden_id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    'component' as component,
    rbrapbg_period as period,
    r.rorstat_tgrp_code as tgrp,
    r.rorstat_pgrp_code as pgrp,
    rbrapbg_pbgp_code as pbgp,
    nvl(nvl(a.levl, b.levl), '-') as levl,
    nvl(nvl(a.coll, b.coll), '-') as coll,
    nvl(nvl(a.prog, b.prog), '-') as prog,
    (
        select sum(rbrapbc_amt)
        from rbrapbc
        where rbrapbc_pidm = rbrapbg_pidm
        and rbrapbc_period = rbrapbg_period
    ) as total_budget
from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
join rorstat r on r.rorstat_pidm = rbrapbg_pidm and r.rorstat_aidy_code = (select ay from aidy)
left join stu_rec a on a.pidm = rbrapbg_pidm
left join stu_app b on b.pidm = rbrapbg_pidm
where rbrapbg_run_name = 'ACTUAL'
and not exists (
    select 1
    from rbrapbc
    where rbrapbc_pidm = rbrapbg_pidm
    and rbrapbc_period = rbrapbg_period
    and rbrapbc_pbcp_code = 'component'
    and rbrapbc_amt > 0
)

;

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
    from rprawrd
    where rprawrd_aidy_code = b.rorstat_aidy_code
    and rprawrd_pidm = a.rbrapbg_pidm
    and rprawrd_fund_code = 'PELL'
) 
group by spriden_id, 
    spriden_last_name || ', ' || spriden_first_name,
    b.rorstat_tgrp_code, b.rorstat_pgrp_code 

    ;


with dt_fname as (
    select to_char(sysdate, 'MMDDYYYY_HH24MISS') as dt, 'pbb_simr_variance_' as fname from dual
), bgrp as (
    select 
        RBRAPBG_PIDM as pidm,
        SPRIDEN_ID as id,
        RBRAPBG_AIDY_CODE as aidy,
        RBRAPBG_PERIOD as period,
        RBRAPBG_RUN_NAME as run_name,
        RBRAPBG_PBGP_CODE as bgrp,
        RBRAPBG_PBGP_CODE_LOCK_IND as lock_ind
    from RBRAPBG
    inner join SPRIDEN on SPRIDEN_PIDM = RBRAPBG_PIDM and SPRIDEN_CHANGE_IND is null
), comp as (
    select 
        RBRAPBC_PIDM as pidm,
        SPRIDEN_ID as id,
        RBRAPBC_AIDY_CODE as aidy,
        RBRAPBC_PERIOD as period,
        RBRAPBC_RUN_NAME as run_name,
        RBRAPBC_PBCP_CODE as pbcp, 
        RBRAPBC_AMT as amt
    from RBRAPBC
    inner join SPRIDEN on SPRIDEN_PIDM = RBRAPBC_PIDM and SPRIDEN_CHANGE_IND is null
    where RBRAPBC_PBTP_CODE = 'CAMP'
), comp_pivot as (
    select * from comp
    PIVOT (
        SUM(amt)
        FOR pbcp IN (
            '1TUI' as TUI,
            '2FEE' as FEE,
            '3HSM' as HSM,
            '4COM' as COM,
            '5CAF' as CAF,
            '6LIV' as LIV,
            '21BF' as BF,
            '22DF' as DF,
            '23PF' as PF,
            '24SF' as SF,
            '7BS' as BS,
            '8TRS' as TRS,
            '9MIS' as MIS
        )
    )
),
main_q AS (
    SELECT 
        a.id, a.pidm, a.aidy, a.period, a.run_name, a.lock_ind, a.actual_group,
        b.simr_run, b.simr_group,
        NVL(TO_CHAR(c.TUI), '-') AS TUI,
        NVL(TO_CHAR(d.TUI), '-') AS TUI_SIMR,
        NVL(TO_CHAR(c.FEE), '-') AS FEE,
        NVL(TO_CHAR(d.FEE), '-') AS FEE_SIMR,
        NVL(TO_CHAR(c.HSM), '-') AS HSM,
        NVL(TO_CHAR(d.HSM), '-') AS HSM_SIMR,
        NVL(TO_CHAR(c.COM), '-') AS COM,
        NVL(TO_CHAR(d.COM), '-') AS COM_SIMR,
        NVL(TO_CHAR(c.CAF), '-') AS CAF,
        NVL(TO_CHAR(d.CAF), '-') AS CAF_SIMR,
        NVL(TO_CHAR(c.LIV), '-') AS LIV,
        NVL(TO_CHAR(d.LIV), '-') AS LIV_SIMR,
        NVL(TO_CHAR(c.BS), '-')  AS BS,
        NVL(TO_CHAR(d.BS), '-')  AS BS_SIMR,
        NVL(TO_CHAR(c.TRS), '-') AS TRS,
        NVL(TO_CHAR(d.TRS), '-') AS TRS_SIMR,
        NVL(TO_CHAR(c.MIS), '-') AS MIS,
        NVL(TO_CHAR(d.MIS), '-') AS MIS_SIMR,
        NVL(TO_CHAR(c.BF), '-')  AS BF,
        NVL(TO_CHAR(d.BF), '-')  AS BF_SIMR,
        NVL(TO_CHAR(c.DF), '-')  AS DF,
        NVL(TO_CHAR(d.DF), '-')  AS DF_SIMR,
        NVL(TO_CHAR(c.PF), '-')  AS PF,
        NVL(TO_CHAR(d.PF), '-')  AS PF_SIMR,
        NVL(TO_CHAR(c.SF), '-')  AS SF,
        NVL(TO_CHAR(d.SF), '-')  AS SF_SIMR,
        (SELECT fname || dt FROM dt_fname) AS fname
    from (
        select id, pidm, aidy, period, run_name, bgrp as actual_group, lock_ind
        from bgrp where run_name = 'ACTUAL'
    ) a
    join (
        select pidm, period, run_name as simr_run, bgrp as simr_group
        from bgrp where run_name <> 'ACTUAL'
    ) b on b.pidm = a.pidm and b.period = a.period
    left join comp_pivot c
        on c.pidm = a.pidm
        and c.period = a.period
        and c.run_name = a.run_name
    left join comp_pivot d
        on d.pidm = b.pidm
        and d.period = b.period
        and d.run_name = b.simr_run
    where (
        a.actual_group <> b.simr_group
        or c.TUI <> d.TUI 
        or c.FEE <> d.FEE 
        or c.HSM <> d.HSM 
        or c.COM <> d.COM 
        or c.CAF <> d.CAF 
        or c.LIV <> d.LIV 
        or c.BS <> d.BS 
        or c.TRS <> d.TRS 
        or c.MIS <> d.MIS 
        or c.BF <> d.BF 
        or c.DF <> d.DF 
        or c.PF <> d.PF 
        or c.SF <> d.SF
    )
)
SELECT
    m.*
FROM main_q m

UNION ALL

SELECT
    'NO DIFFERENCES FOUND' AS id,
    NULL AS pidm,
    NULL AS aidy,
    NULL AS period,
    NULL AS run_name,
    NULL AS lock_ind,
    NULL AS actual_group,
    NULL AS simr_run,
    NULL AS simr_group,
    NULL AS TUI, NULL AS TUI_SIMR,
    NULL AS FEE, NULL AS FEE_SIMR,
    NULL AS HSM, NULL AS HSM_SIMR,
    NULL AS COM, NULL AS COM_SIMR,
    NULL AS CAF, NULL AS CAF_SIMR,
    NULL AS LIV, NULL AS LIV_SIMR,
    NULL AS BS,  NULL AS BS_SIMR,
    NULL AS TRS, NULL AS TRS_SIMR,
    NULL AS MIS, NULL AS MIS_SIMR,
    NULL AS BF,  NULL AS BF_SIMR,
    NULL AS DF,  NULL AS DF_SIMR,
    NULL AS PF,  NULL AS PF_SIMR,
    NULL AS SF,  NULL AS SF_SIMR,
    (SELECT fname || dt FROM dt_fname) AS fname
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM main_q)
;