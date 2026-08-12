-- new with sarappd
select 
    a.sarappd_pidm as "pidm",
    b.spriden_id as "banner_id",
    UPPER(b.spriden_last_name) as "lname",
    UPPER(b.spriden_first_name) as "fname",
    SUBSTR(b.spriden_search_mi, 0, 1) as "mname",
    a.sarappd_term_code_entry as "period",
    d.stvterm_fa_proc_yr as "aidy",
    c.spbpers_ssn as "ssn",
    e.rorstat_bgrp_code as "bgrp",
    e.rorstat_tgrp_code as "tgrp",
    e.rorstat_pgrp_code as "pgrp",
    case when f.rcrapp1_pidm is not null then 'Y' else 'N'
    end as "filed_fafsa",
    f.rcrapp1_seq_no as "isir_num",
    f.rcrapp1_citz_ind as "citz_ind",
    f.rcrapp4_ssa_citizen_ind as "ssa_citz_ind",
    f.rcrapp1_ins as "rcrapp1_ins",
    f.rcrapp4_sec_ins_match_ind as "rcrapp4_sec_ins_match_ind"
from (
    select w.sarappd_pidm, w.sarappd_term_code_entry,
        max(w.sarappd_seq_no)
    from saturn.sarappd w
    inner join stvapdc v on v.stvapdc_code = w.sarappd_apdc_code
    where v.stvapdc_inst_acc_ind = 'Y'
    and v.stvapdc_signf_ind = 'Y'
    and w.sarappd_term_code_entry = '202610'
    group by w.sarappd_pidm, w.sarappd_term_code_entry
) a
inner join saturn.spriden b on b.spriden_pidm = a.sarappd_pidm
inner join saturn.spbpers c on c.spbpers_pidm = a.sarappd_pidm
inner join saturn.stvterm d on d.stvterm_code = a.sarappd_term_code_entry
left join faismgr.rorstat e on e.rorstat_pidm = a.sarappd_pidm 
    and e.rorstat_aidy_code = d.stvterm_fa_proc_yr
left join (
    select 
    y.rcrapp1_pidm, 
    y.rcrapp1_aidy_code,
    y.rcrapp1_seq_no,
    y.rcrapp1_citz_ind,
    y.rcrapp1_ins,
    x.rcrapp4_ssa_citizen_ind,
    x.rcrapp4_sec_ins_match_ind
    from faismgr.rcrapp1 y
    inner join faismgr.rcrapp4 x
        on x.rcrapp4_pidm = y.rcrapp1_pidm
        and x.rcrapp4_aidy_code = y.rcrapp1_aidy_code
        and x.rcrapp4_infc_code = y.rcrapp1_infc_code
        and x.rcrapp4_seq_no = y.rcrapp1_seq_no
		where y.rcrapp1_curr_rec_ind = 'Y'
    and y.rcrapp1_infc_code = 'EDE'
    order by y.rcrapp1_pidm
) f on f.rcrapp1_pidm = a.sarappd_pidm and f.rcrapp1_aidy_code = d.stvterm_fa_proc_yr
where b.spriden_change_ind is null
and a.sarappd_term_code_entry = ( -- '202610'
    select 
    case
        when to_char(sysdate, 'MM') >= 6 -- current date in june or later
        then to_char(sysdate+365, 'YYYY') || '10'
        
        when to_char(sysdate, 'MM') < 6 -- current date before june
        then to_char(sysdate, 'YYYY') || '20'
    end as "period"
    from dual
)
--order by "pidm";
union

-- og with sgbstdn
select 
    a.sgbstdn_pidm as "pidm",
    b.spriden_id as "banner_id",
    UPPER(b.spriden_last_name) as "lname",
    UPPER(b.spriden_first_name) as "fname",
    SUBSTR(b.spriden_search_mi, 0, 1) as "mname",
    a.sgbstdn_term_code_eff as "period",
    d.stvterm_fa_proc_yr as "aidy",
    c.spbpers_ssn as "ssn",
    e.rorstat_bgrp_code as "bgrp",
    e.rorstat_tgrp_code as "tgrp",
    e.rorstat_pgrp_code as "pgrp",
    case when f.rcrapp1_pidm is not null then 'Y' else 'N'
    end as "filed_fafsa",
    f.rcrapp1_seq_no as "isir_num",
    f.rcrapp1_citz_ind as "citz_ind",
    f.rcrapp4_ssa_citizen_ind as "ssa_citz_ind",
    f.rcrapp1_ins as "rcrapp1_ins",
    f.rcrapp4_sec_ins_match_ind as "rcrapp4_sec_ins_match_ind"
from saturn.sgbstdn a
inner join saturn.spriden b on b.spriden_pidm = a.sgbstdn_pidm
inner join saturn.spbpers c on c.spbpers_pidm = a.sgbstdn_pidm
inner join saturn.stvterm d on d.stvterm_code = a.sgbstdn_term_code_eff
left join faismgr.rorstat e on e.rorstat_pidm = a.sgbstdn_pidm 
    and e.rorstat_aidy_code = d.stvterm_fa_proc_yr
left join (
    select 
    y.rcrapp1_pidm, 
    y.rcrapp1_aidy_code,
    y.rcrapp1_seq_no,
    y.rcrapp1_citz_ind,
    y.rcrapp1_ins,
    x.rcrapp4_ssa_citizen_ind,
    x.rcrapp4_sec_ins_match_ind
    from faismgr.rcrapp1 y
    inner join faismgr.rcrapp4 x
        on x.rcrapp4_pidm = y.rcrapp1_pidm
        and x.rcrapp4_aidy_code = y.rcrapp1_aidy_code
        and x.rcrapp4_infc_code = y.rcrapp1_infc_code
        and x.rcrapp4_seq_no = y.rcrapp1_seq_no
		where y.rcrapp1_curr_rec_ind = 'Y'
    and y.rcrapp1_infc_code = 'EDE'
    order by y.rcrapp1_pidm
) f on f.rcrapp1_pidm = a.sgbstdn_pidm and f.rcrapp1_aidy_code = d.stvterm_fa_proc_yr
where b.spriden_change_ind is null
and a.sgbstdn_stst_code in ('AS','IL')
and a.sgbstdn_levl_code not in ('AC')
and a.sgbstdn_term_code_eff = ( -- '202610'
    select 
    case
        when to_char(sysdate, 'MM') >= 6 -- current date in june or later
        then to_char(sysdate+365, 'YYYY') || '10'
        
        when to_char(sysdate, 'MM') < 6 -- current date before june
        then to_char(sysdate, 'YYYY') || '20'
    end as "period"
    from dual
)
order by "pidm";

select w.sarappd_pidm, w.sarappd_term_code_entry,
    max(w.sarappd_seq_no)
from saturn.sarappd w
inner join stvapdc v on v.stvapdc_code = w.sarappd_apdc_code
where v.stvapdc_inst_acc_ind = 'Y'
and v.stvapdc_signf_ind = 'Y'
and w.sarappd_term_code_entry = '202610'
group by w.sarappd_pidm, w.sarappd_term_code_entry
order by w.sarappd_pidm;

