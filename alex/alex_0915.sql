with gpa as (
    select 
        shrlgpa_pidm as pidm,
        shrlgpa_levl_code as levl,
        shrlgpa_hours_attempted as attempted,
        shrlgpa_hours_earned as earned,
        shrlgpa_gpa as gpa
    from shrlgpa
    where shrlgpa_gpa_type_ind = 'I'
), stu as (
    select
        a.sgbstdn_pidm as pidm,
        a.sgbstdn_levl_code as levl
    from sgbstdn a
    where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= '202720'
    )
), fafsa as (
    select
        rcrapp1_pidm as pidm,
        rcrapp1_aidy_code as aidy,
        rcrapp4_sar_efc as sai
    from rcrapp1
    join rcrapp4 on rcrapp4_pidm = rcrapp1_pidm
        and rcrapp4_seq_no = rcrapp1_seq_no
        and rcrapp4_aidy_code = rcrapp1_aidy_code
        and rcrapp4_infc_code = rcrapp1_infc_code
    where rcrapp1_aidy_code = '2627'
    and rcrapp1_curr_rec_ind = 'Y'
    and rcrapp1_infc_code = 'EDE'
), bal as (
    select 
        tbraccd_pidm as pidm,
        spriden_id as bid,
        tbraccd_term_code as term,
        sum(tbraccd_balance) as balance
    from tbraccd
    join spriden on spriden_pidm = tbraccd_pidm and spriden_change_ind is null
    where tbraccd_term_code = '202710'
    group by tbraccd_pidm, spriden_id, tbraccd_term_code
), pplan as (
    select tbbacct_pidm as pidm, tbbacct_deli_code as pmnt_plan
    from tbbacct 
    where tbbacct_deli_code in ('TN', 'DP', 'DM', 'DS', 'SN', 'SP')
)
select
    spriden_id as bid,
    d.balance,
    rokmisc.f_calc_stud_bill_hrs('202710', a.pidm, 'N') as hrs,
    c.sai,
    b.gpa,
    b.earned,
    e.pmnt_plan
from stu a
join spriden on spriden_pidm = a.pidm and spriden_change_ind is null
left join gpa b on b.pidm = a.pidm and b.levl = a.levl
left join fafsa c on c.pidm = a.pidm and c.aidy = '2627'
left join bal d on d.pidm = a.pidm
left join pplan e on e.pidm = a.pidm
;
select 
    tbraccd_pidm as pidm,
    spriden_id as bid,
    tbraccd_term_code as term,
    sum(tbraccd_balance) as balance
from tbraccd
join spriden on spriden_pidm = tbraccd_pidm and spriden_change_ind is null
where tbraccd_term_code = '202710'
group by tbraccd_pidm, spriden_id, tbraccd_term_code
;

select tbbacct_pidm as pidm, tbbacct_deli_code as pmnt_plan
from tbbacct 
where tbbacct_deli_code in ('TN', 'DP', 'DM', 'DS', 'SN', 'SP')
;

