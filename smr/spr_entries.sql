select * from (
with term as (
    select :term as term from dual
), fafsa as (
    select rcrapp1_pidm as pidm, rcrapp1_aidy_code as aidy, rcrapp4_sar_efc as sai
    from rcrapp1
    join rcrapp4 on rcrapp4_pidm = rcrapp1_pidm
        and rcrapp1_aidy_code = rcrapp4_aidy_code
        and rcrapp1_infc_code = rcrapp4_infc_code
        and rcrapp1_seq_no = rcrapp4_seq_no
    where rcrapp1_infc_code = 'EDE'
    and rcrapp1_curr_rec_ind = 'Y'
), awarded as (
    select
        rpratrm_pidm as pidm, rpratrm_term_code,
        sum(rpratrm_offer_amt) as ofrd,
        sum(rpratrm_accept_amt) as acpt,
        sum(rpratrm_paid_amt) as paid
    from rpratrm
    where rpratrm_offer_amt is not null
    and rpratrm_accept_amt is not null
    group by rpratrm_pidm, rpratrm_term_code
)
select 
    distinct spriden_id as id, 
    spriden_pidm,
    spriden_last_name || ', ' || spriden_first_name as name, 
    a.saradap_term_code_entry as period,
    r.rorstat_aprd_code as aprd, 
    r.rorstat_tgrp_code as tgrp,  
    g.rbrapbg_pbgp_code as bgrp_fall,
    h.rbrapbg_pbgp_code as bgrp_spr,
    r.rorstat_pgrp_code as pgrp,
    a.saradap_levl_code as levl, 
    a.saradap_coll_code_1 as college, 
    a.saradap_program_1 as program,
    nvl(rokmisc.f_calc_stud_bill_hrs(a.saradap_term_code_entry, a.saradap_pidm, 'N'), 0) as hrs,
    f.sai, 
    s.ofrd as total_ofrd, 
    s.acpt as total_acpt,
    s.paid as total_paid,
    robnyud_value_28,
    robusdf_value_170,
    robusdf_value_189,
    r.rorstat_awd_ltr_ind
from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm 
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_inst_acc_ind = 'Y'
join spriden on spriden_pidm = a.saradap_pidm and spriden_change_ind is null
join robinst on robinst_aidy_end_year = substr(saradap_term_code_entry, 0, 4)
join robusdf on robusdf_pidm = a.saradap_pidm and robusdf_aidy_code = robinst_aidy_code
join robnyud on robnyud_pidm = a.saradap_pidm
left join fafsa f on f.pidm = a.saradap_pidm and f.aidy = robinst_aidy_code
left join awarded s on s.pidm = a.saradap_pidm and s.rpratrm_term_code = a.saradap_term_code_entry
left join rorstat r on r.rorstat_pidm = a.saradap_pidm
    and r.rorstat_aidy_code = robinst_aidy_code
left join rbrapbg g on g.rbrapbg_pidm = a.saradap_pidm
    and g.rbrapbg_period = substr(:term, 0, 4) || '10'
    and g.rbrapbg_run_name = 'ACTUAL'
left join rbrapbg h on h.rbrapbg_pidm = a.saradap_pidm
    and h.rbrapbg_period = substr(:term, 0, 4) || '20'
    and h.rbrapbg_run_name = 'ACTUAL'
where saradap_term_code_entry = (select term from term)
and stvapdc_signf_ind = 'Y'
and stvapdc_inst_acc_ind = 'Y'
and b.sarappd_seq_no = (
    select max(sarappd_seq_no)b
    from sarappd 
    where sarappd_pidm = b.sarappd_pidm
    and sarappd_appl_no = b.sarappd_appl_no
    and sarappd_term_code_entry = b.sarappd_term_code_entry
)
) 
-- where id in ('001431193', '001014444')
;

select * from rbrapbg g 
where g.rbrapbg_pidm = 1018494
and g.rbrapbg_period = '202720'
and g.rbrapbg_run_name = 'ACTUAL'
;
select * from robinst;

-- for pbi
with term as (
    select '" & term & "' as term from dual
), fafsa as (
    select rcrapp1_pidm as pidm, rcrapp1_aidy_code as aidy, rcrapp4_sar_efc as sai
    from rcrapp1
    join rcrapp4 on rcrapp4_pidm = rcrapp1_pidm
        and rcrapp1_aidy_code = rcrapp4_aidy_code
        and rcrapp1_infc_code = rcrapp4_infc_code
        and rcrapp1_seq_no = rcrapp4_seq_no
    where rcrapp1_infc_code = 'EDE'
    and rcrapp1_curr_rec_ind = 'Y'
), awarded as (
    select
        rpratrm_pidm as pidm, rpratrm_term_code,
        sum(rpratrm_offer_amt) as ofrd,
        sum(rpratrm_accept_amt) as acpt,
        sum(rpratrm_paid_amt) as paid
    from rpratrm
    where rpratrm_offer_amt is not null
    and rpratrm_accept_amt is not null
    group by rpratrm_pidm, rpratrm_term_code
)
select 
    distinct spriden_id as id, 
    spriden_last_name || ', ' || spriden_first_name as name, 
    a.saradap_term_code_entry as period,
    r.rorstat_aprd_code as aprd, 
    r.rorstat_tgrp_code as tgrp,  
    g.rbrapbg_pbgp_code as bgrp_fall,
    h.rbrapbg_pbgp_code as bgrp_spr,
    r.rorstat_pgrp_code as pgrp,
    a.saradap_levl_code as levl, 
    a.saradap_coll_code_1 as college, 
    a.saradap_program_1 as program,
    nvl(rokmisc.f_calc_stud_bill_hrs(a.saradap_term_code_entry, a.saradap_pidm, 'N'), 0) as hrs,
    f.sai, 
    s.ofrd as total_ofrd, 
    s.acpt as total_acpt,
    s.paid as total_paid,
    robnyud_value_28,
    robusdf_value_170,
    robusdf_value_189,
    r.rorstat_awd_ltr_ind
from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm 
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_inst_acc_ind = 'Y'
join spriden on spriden_pidm = a.saradap_pidm and spriden_change_ind is null
join robinst on robinst_aidy_end_year = substr(saradap_term_code_entry, 0, 4)
join robusdf on robusdf_pidm = a.saradap_pidm and robusdf_aidy_code = robinst_aidy_code
join robnyud on robnyud_pidm = a.saradap_pidm
left join fafsa f on f.pidm = a.saradap_pidm and f.aidy = robinst_aidy_code
left join awarded s on s.pidm = a.saradap_pidm and s.rpratrm_term_code = a.saradap_term_code_entry
left join rorstat r on r.rorstat_pidm = a.saradap_pidm
    and r.rorstat_aidy_code = robinst_aidy_code
left join rbrapbg g on g.rbrapbg_pidm = a.saradap_pidm
    and g.rbrapbg_period = substr('" & term & "', 0, 4) || '10'
    and g.rbrapbg_run_name = 'ACTUAL'
left join rbrapbg h on h.rbrapbg_pidm = a.saradap_pidm
    and h.rbrapbg_period = substr('" & term & "', 0, 4) || '20'
    and h.rbrapbg_run_name = 'ACTUAL'
where saradap_term_code_entry = (select term from term)
and stvapdc_signf_ind = 'Y'
and stvapdc_inst_acc_ind = 'Y'
and b.sarappd_seq_no = (
    select max(sarappd_seq_no)
    from sarappd 
    where sarappd_pidm = b.sarappd_pidm
    and sarappd_appl_no = b.sarappd_appl_no
    and sarappd_term_code_entry = b.sarappd_term_code_entry
)
;