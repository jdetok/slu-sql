select 'MEDFS', a.rorstat_pidm
from rorstat a
inner join robinst b on b.robinst_aidy_code = :aidy
where a.rorstat_aidy_code = :aidy
and a.rorstat_pidm = :pidm
and (
    exists (
        select 1
        from sgbstdn z
        where z.sgbstdn_pidm = a.rorstat_pidm
        and (
            z.sgbstdn_levl_code = 'PM'
            or (
                z.sgbstdn_coll_code_1 = 'MD'
                and z.sgbstdn_program_1 = 'MDSC11'
            )
        )
        and z.sgbstdn_stst_code in ('AS', 'IL')
        and z.sgbstdn_term_code_eff <= b.robinst_aidy_end_year || '20'
    ) or exists ( 
        select 1
        from saradap z
        inner join sarappd y on y.sarappd_pidm = z.saradap_pidm
            and y.sarappd_term_code_entry = z.saradap_term_code_entry
            and y.sarappd_appl_no = z.saradap_appl_no
        inner join stvapdc x on x.stvapdc_code = y.sarappd_apdc_code
            and x.stvapdc_inst_acc_ind = 'Y'
            and x.stvapdc_signf_ind = 'Y'
        where z.saradap_pidm = a.rorstat_aidy_code
        and (
            z.saradap_levl_code = 'PM'
            or (
                z.saradap_coll_code_1 = 'MD'
                and z.saradap_program_1 = 'MDSC11'
            )
        )
        and z.saradap_term_code_entry = (
            select max(w.saradap_term_code_entry)
            from saradap w
            where w.saradap_pidm = z.saradap_pidm
            and w.saradap_term_code_entry <= b.robinst_aidy_end_year || '20'
        )
        and y.sarappd_seq_no = (
            select max(v.sarappd_seq_no)
            from sarappd v
            where v.sarappd_pidm = y.sarappd_pidm
            and v.sarappd_term_code_entry = y.sarappd_term_code_entry
            and v.sarappd_appl_no = y.sarappd_appl_no
        )
    )
)
 
;

-- 829 -> 860