with today as (
    select 
        to_number(to_char(sysdate, 'yy')) as yr, 
        to_number(to_char(sysdate, 'mm')) as mn
    from dual
), aidy as (
    select 
        (to_char(t.yr-1)) || (to_char(t.yr)) as pastyr,
        (to_char(t.yr)) || (to_char(t.yr+1)) as crntyr,
        (to_char(t.yr+1)) || (to_char(t.yr+2)) as futryr
    from today t
), in_yr as ( -- always keep 2425 and 2526 as Janice will always need that data
    select '2425' from dual union all select '2526' from dual union all
    select pastyr from aidy join today on mn < 8
    union all
    select crntyr from aidy
    union all
    select futryr from aidy join today on mn >= 12
), rstat as (
    select 
        a.rorstat_pidm as pidm,
        a.rorstat_aidy_code as aidy,
        a.rorstat_aprd_code as aid_prd,
        a.rorstat_tgrp_code as trck_grp,
        a.rorstat_pgrp_code as pack_grp,
        -- rorstat budget code before 2627 when we implemented period budget
        -- rbrapbg_pbgp_code for fall,spring for 2627 and laterx
        case when a.rorstat_aidy_code < '2627' then a.rorstat_bgrp_code
                else f.rbrapbg_pbgp_code || ',' || s.rbrapbg_pbgp_code end as budg_grp
    from faismgr.rorstat a
    left join rbrapbg f on f.rbrapbg_pidm = a.rorstat_pidm
        and f.rbrapbg_aidy_code = a.rorstat_aidy_code
        and f.rbrapbg_run_name = 'ACTUAL'
        and f.rbrapbg_period = '20' || substr(a.rorstat_aidy_code,3,2) || '10'
    left join rbrapbg s on s.rbrapbg_pidm = a.rorstat_pidm
        and s.rbrapbg_aidy_code = a.rorstat_aidy_code
        and s.rbrapbg_run_name = 'ACTUAL'
        and s.rbrapbg_period = '20' || substr(a.rorstat_aidy_code,3,2) || '20'
    where a.rorstat_aidy_code in (select * from in_yr)
), awards as (
    select a.rpratrm_aidy_code as aidy,
        a.rpratrm_fund_code as fund,
        rfrbase_fsrc_code as fsrc,
        rfrbase_ftyp_code as ftyp,
        rtvfsrc_ind as fsrc_typ,
        a.rpratrm_period as period,
        a.rpratrm_awst_code as status,
        a.rpratrm_offer_amt as ofrd_amt_prd,
        b.rprawrd_offer_amt as ofrd_amt_yr,
        a.rpratrm_pidm as pidm,
        a.rpratrm_accept_amt as acpt_amt_prd,
        b.rprawrd_accept_amt as acpt_amt_yr,
        a.rpratrm_orig_offer_amt as orig_ofrd_amt_prd,
        a.rpratrm_decline_amt as decl_amt_prd,
        b.rprawrd_decline_amt as decl_amt_yr,
        a.rpratrm_cancel_amt as cncl_amt_prd,
        b.rprawrd_cancel_amt as cncl_amt_yr,
        a.rpratrm_authorize_amt as auth_amt_prd,
        b.rprawrd_authorize_amt as auth_amt_yr,
        a.rpratrm_memo_amt as memo_amt_prd,
        b.rprawrd_memo_amt as memo_amt_yr,
        a.rpratrm_paid_amt as paid_amt_prd,
        b.rprawrd_paid_amt as paid_amt_yr,
        a.rpratrm_paid_date as paid_date_prd,
        a.rpratrm_orig_offer_date as orig_ofrd_date_prd,
        a.rpratrm_term_code as term_code,
        a.rpratrm_awst_date as status_date 
    from rpratrm a
    join rprawrd b
        on b.rprawrd_aidy_code = a.rpratrm_aidy_code
        and b.rprawrd_pidm = a.rpratrm_pidm
        and b.rprawrd_fund_code = a.rpratrm_fund_code
    join rfrbase on rfrbase_fund_code = rpratrm_fund_code
    join rtvfsrc on rtvfsrc_code = rfrbase_fsrc_code
    where a.rpratrm_pidm in (select pidm from rstat)
), efc as (
    select rcrapp1_pidm as pidm, rcrapp1_aidy_code as aidy, rcrapp4_sar_efc as efc
    from rcrapp1
    join rcrapp4 
        on rcrapp1_pidm = rcrapp4_pidm 
        and rcrapp1_aidy_code = rcrapp4_aidy_code
        and rcrapp1_seq_no = rcrapp4_seq_no
        and rcrapp1_infc_code = rcrapp4_infc_code
    where rcrapp1_curr_rec_ind = 'Y'
    and rcrapp1_infc_code = 'EDE'
    and rcrapp1_pidm in (select pidm from rstat)
), reg as (
    select
        x.sgbstdn_pidm as pidm,
        aidy,
        x.sgbstdn_degc_code_1 as degree,
        d.stvdegc_desc as degree_desc,
        x.sgbstdn_majr_code_1 as major,
        m.stvmajr_desc as major_desc,
        m.stvmajr_cipc_code as program_classification,
        i.stvcipc_desc as program_classification_desc,
        x.sgbstdn_coll_code_1 as college,
        c.stvcoll_desc as college_desc,
        x.sgbstdn_levl_code as student_level
    from (
        select 
            a.*, r.robinst_aidy_code as aidy, 
            row_number() over (partition by a.sgbstdn_pidm order by a.sgbstdn_term_code_eff desc) as rn
        from sgbstdn a
        join robinst r on r.robinst_status_ind = 'A' 
        where a.sgbstdn_term_code_eff <= r.robinst_aidy_end_year + 1 || '00'
        and a.sgbstdn_pidm in (select pidm from rstat)
    ) x
    join stvcoll c on c.stvcoll_code = x.sgbstdn_coll_code_1
    join stvdegc d on d.stvdegc_code = x.sgbstdn_degc_code_1
    join stvmajr m on m.stvmajr_code = x.sgbstdn_majr_code_1
    join stvcipc i on i.stvcipc_code = m.stvmajr_cipc_code
    where x.rn = 1 and x.sgbstdn_stst_code in ('AS', 'IL', 'P1')
), adm as (
    select
        x.saradap_pidm as pidm,
        aidy,
        x.saradap_degc_code_1 as degree,
        d.stvdegc_desc as degree_desc,
        x.saradap_majr_code_1 as major,
        m.stvmajr_desc as major_desc,
        m.stvmajr_cipc_code as program_classification,
        i.stvcipc_desc as program_classification_desc,
        x.saradap_coll_code_1 as college,
        c.stvcoll_desc as college_desc,
        x.saradap_levl_code as student_level
    from (
        select 
            a.*, r.robinst_aidy_code as aidy, 
            row_number() over (partition by a.saradap_pidm order by a.saradap_term_code_entry desc) as rn
        from saradap a
        join sarappd b on b.sarappd_pidm = a.saradap_pidm 
            and b.sarappd_term_code_entry = a.saradap_term_code_entry
            and b.sarappd_appl_no = a.saradap_appl_no
        join stvapdc v on v.stvapdc_code = b.sarappd_apdc_code
            and v.stvapdc_signf_ind = 'Y'
            and v.stvapdc_inst_acc_ind = 'Y'
        join robinst r on r.robinst_status_ind = 'A'
        join smrprle p on p.smrprle_program = a.saradap_program_1
        where a.saradap_styp_code in ('F', '1', 'T')
        and a.saradap_term_code_entry = (
            select max(z.saradap_term_code_entry)
            from saradap z
            where z.saradap_pidm = a.saradap_pidm
            and z.saradap_term_code_entry <= robinst_aidy_end_year + 1 || '00'
        )
        and a.saradap_appl_no = (
            select max(z.saradap_appl_no)
            from saradap z
            where z.saradap_pidm = a.saradap_pidm
            and z.saradap_term_code_entry = a.saradap_term_code_entry
        )
        and b.sarappd_seq_no = (
            select max(z.sarappd_seq_no)
            from sarappd z
            where z.sarappd_pidm = b.sarappd_pidm
            and z.sarappd_appl_no = b.sarappd_appl_no
            and z.sarappd_term_code_entry = b.sarappd_term_code_entry
        )
        and a.saradap_pidm in (select pidm from rstat)
    ) x
    join stvcoll c on c.stvcoll_code = x.saradap_coll_code_1
    join stvdegc d on d.stvdegc_code = x.saradap_degc_code_1
    join stvmajr m on m.stvmajr_code = x.saradap_majr_code_1
    join stvcipc i on i.stvcipc_code = m.stvmajr_cipc_code
    where rn = 1
)
select 
    spriden_id as bid,
    spriden_last_name || ', ' || spriden_first_name as name,
    a.*, sg.*, e.efc, r.*, 
    case when rokmisc.f_calc_stud_bill_hrs(period, a.pidm, 'N') is null then 'N' else 'Y' end as registered,
    to_char(sysdate, 'MM/DD/YYYY HH12:MI:SS AM') as lastrun
from rstat a
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
join (select * from reg union all select * from adm) sg on sg.pidm = a.pidm and sg.aidy = a.aidy
left join efc e on e.pidm = a.pidm and e.aidy = a.aidy
left join awards r on r.pidm = a.pidm and r.aidy = a.aidy
;