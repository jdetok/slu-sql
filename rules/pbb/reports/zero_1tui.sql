
desc stvapdc;
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
);

with fall_grp as (
    select rbrapbg_pidm as pidm, rbrapbg_pbgp_code as grp
    from rbrapbg
    where rbrapbg_run_name = 'ACTUAL'
    and rbrapbg_period = '202710'
), spr_grp as (
    select rbrapbg_pidm as pidm, rbrapbg_pbgp_code as grp
    from rbrapbg
    where rbrapbg_run_name = 'ACTUAL'
    and rbrapbg_period = '202720'
), dt as (select 'group_mismatch_' || to_char(sysdate, 'MMDDYYYY_HHMISS') as t from dual)
select 
    (select t from dt) as ts,
    spriden_id, spriden_last_name || ', ' || spriden_first_name as name, 
    a.grp as fall_group, b.grp as spr_group
from fall_grp a 
join spr_grp b on b.pidm = a.pidm
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
where a.grp <> b.grp
;