-- 100 new
--UG PL ENROLLED PART TIME 
with stu as (
    select 
        x.sgbstdn_pidm as pidm,
        x.sgbstdn_levl_code,
        x.sgbstdn_camp_code,
        x.sgbstdn_coll_code_1,
        nvl(rokmisc.f_calc_stud_bill_hrs(:period, x.sgbstdn_pidm, 'N'), 0) as hrs
    from sgbstdn x
    where x.sgbstdn_stst_code in ('AS','IL','P1')
    and x.sgbstdn_levl_code = 'UG'
    and x.sgbstdn_camp_code = 'FR'
    and x.sgbstdn_coll_code_1 = 'PL'
    and x.sgbstdn_term_code_eff = (
        select max(y.sgbstdn_term_code_eff)
        from sgbstdn y
        where y.sgbstdn_pidm = x.sgbstdn_pidm
        and y.sgbstdn_term_code_eff <= :period
    )
)
select roralgs_amt * hrs
from stu
inner join roralgs 
    on roralgs_aidy_code = :aidy
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = sgbstdn_levl_code
    and roralgs_key_6 = sgbstdn_camp_code
    and roralgs_key_7 = sgbstdn_coll_code_1
    and roralgs_key_12 = 'PT'
where hrs between 1 and 11
and pidm = :pidm
;

-- 110 new
--UG PL ENROLLED FULL TIME OR NOT ENROLLED WITH SGASTDN
with stu as (
    select 
        x.sgbstdn_pidm as pidm,
        x.sgbstdn_levl_code,
        x.sgbstdn_camp_code,
        x.sgbstdn_coll_code_1,
        nvl(rokmisc.f_calc_stud_bill_hrs(:period, x.sgbstdn_pidm, 'N'), 0) as hrs
    from sgbstdn x
    where x.sgbstdn_stst_code in ('AS','IL','P1')
    and x.sgbstdn_levl_code = 'UG'
    and x.sgbstdn_camp_code = 'FR'
    and x.sgbstdn_coll_code_1 = 'PL'
    and x.sgbstdn_term_code_eff = (
        select max(y.sgbstdn_term_code_eff)
        from sgbstdn y
        where y.sgbstdn_pidm = x.sgbstdn_pidm
        and y.sgbstdn_term_code_eff <= :period
    )
    and not exists (
        select 1
        from saradap
        inner join sarappd
            on sarappd_pidm = saradap_pidm
            and sarappd_appl_no = saradap_appl_no
            and sarappd_term_code_entry = saradap_term_code_entry
        inner join stvapdc
            on stvapdc_code = sarappd_apdc_code
            and stvapdc_inst_acc_ind = 'Y'
            and stvapdc_signf_ind = 'Y'
        where saradap_pidm = x.sgbstdn_pidm
        and saradap_term_code_entry > x.sgbstdn_term_code_eff 
        and saradap_term_code_entry <= ('20' || cast(substr(:aidy, 2, 2) as int) + 1 || '00')
        and saradap_program_1 <> x.sgbstdn_program_1
    )
)
select roralgs_amt
from stu
inner join roralgs on roralgs_aidy_code = :aidy
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = sgbstdn_levl_code
    and roralgs_key_6 = sgbstdn_camp_code
    and roralgs_key_7 = sgbstdn_coll_code_1
    and roralgs_key_12 = 'FT'
where pidm = :pidm
;

-- 120 new
-- UG PL NOT ENROLLED NO SGASTDN
with stu as (
    select  
        a.saradap_pidm as pidm,
        a.saradap_levl_code,
        a.saradap_camp_code,
        a.saradap_coll_code_1,
        saradap_term_code_entry, saradap_appl_no, sarappd_seq_no
    from saradap a
    inner join sarappd b 
        on b.sarappd_pidm = a.saradap_pidm
        and b.sarappd_appl_no = a.saradap_appl_no
        and b.sarappd_term_code_entry = a.saradap_term_code_entry
    inner join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
        and c.stvapdc_inst_acc_ind = 'Y'
        and c.stvapdc_signf_ind = 'Y'
    where a.saradap_term_code_entry = (
        select max(z.saradap_term_code_entry)
        from saradap z
        inner join robinst on robinst_aidy_code = :aidy
        where z.saradap_pidm = a.saradap_pidm
        and z.saradap_term_code_entry between (robinst_aidy_end_year || '00') and :period
    )
    and b.sarappd_seq_no = (
        select max(y.sarappd_seq_no)
        from sarappd y
        inner join robinst on robinst_aidy_code = :aidy
        and y.sarappd_pidm = b.sarappd_pidm
        and y.sarappd_seq_no < 99
        and y.sarappd_term_code_entry = b.sarappd_term_code_entry    
        and y.sarappd_appl_no = b.sarappd_appl_no
    )
    and a.saradap_levl_code = 'UG'
    and a.saradap_camp_code = 'FR'
    and a.saradap_coll_code_1 = 'PL'
)
select roralgs_amt
from stu
inner join roralgs on roralgs_aidy_code = :aidy
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = saradap_levl_code
    and roralgs_key_6 = saradap_camp_code
    and roralgs_key_7 = saradap_coll_code_1
    and roralgs_key_12 = 'FT'
where pidm = :pidm
;


select spriden_id from spriden where spriden_change_ind is null and spriden_pidm = 1272468;
select * from sgbstdn where sgbstdn_pidm = 1272468;