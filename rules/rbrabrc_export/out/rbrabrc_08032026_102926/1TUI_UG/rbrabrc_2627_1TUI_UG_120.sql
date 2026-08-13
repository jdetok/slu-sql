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
-- where pidm = :pidm