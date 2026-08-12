select distinct a.sgbstdn_pidm
from sgbstdn a 
join shrlgpa b on b.shrlgpa_pidm = a.sgbstdn_pidm
    and b.shrlgpa_levl_code = case when a.sgbstdn_levl_code = 'AC' then 'UG' else a.sgbstdn_levl_code end
    and b.shrlgpa_gpa_type_ind = 'I'
join shrlgpa c on c.shrlgpa_pidm = a.sgbstdn_pidm
    and c.shrlgpa_levl_code = case when a.sgbstdn_levl_code = 'AC' then 'UG' else a.sgbstdn_levl_code end
    and c.shrlgpa_gpa_type_ind = 'O'
where sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff) from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= :term
)
and b.shrlgpa_gpa >= case
    when b.shrlgpa_levl_code in ('UG', 'AC') then 1.995
    when b.shrlgpa_levl_code = 'GR' then 2.995
    when b.shrlgpa_levl_code = 'PL' then 2.095
end
and c.shrlgpa_hours_earned >= (c.shrlgpa_hours_attempted * 0.665)
-- and a.sgbstdn_pidm = :pidm
and a.sgbstdn_pidm = (select spriden_pidm from spriden where spriden_id = '001506403' and spriden_change_ind is null)
;

select * from sgbstdn where sgbstdn_pidm = 1019233;
select a.saradap_pidm, a.saradap_term_code_entry, b.sarappd_apdc_code from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
-- join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
--     and c.stvapdc_signf_ind = 'Y'
--     and c.stvapdc_inst_acc_ind = 'Y'
where a.saradap_pidm = (select spriden_pidm from spriden where spriden_id = '001506403' and spriden_change_ind is null)
-- and a.saradap_term_code_entry = (
--     select max(z.saradap_term_code_entry) from saradap z
--     where z.saradap_pidm = a.saradap_pidm
--     and z.saradap_term_code_entry = :TERM
-- )
-- and a.saradap_appl_no = (
--     select max(z.saradap_appl_no) from saradap z
--     where z.saradap_pidm = a.saradap_pidm
--     and z.saradap_term_code_entry = a.saradap_term_code_entry
-- )
and b.sarappd_seq_no = (
    select max(z.sarappd_seq_no) from sarappd z
    where z.sarappd_pidm = b.sarappd_pidm
    and z.sarappd_term_code_entry = b.sarappd_term_code_entry
    and z.sarappd_appl_no = b.sarappd_appl_no
);