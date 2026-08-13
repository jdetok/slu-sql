-- scan rules for issues with regex

-- find instances of wrong argument order in f_calc_stud_bill_hrs calls (pidm passed before period)
select *
from rbrabrc
where regexp_like(rbrabrc_sql_statement, 'DEN');
-- where regexp_like(rbrabrc_sql_statement, 'F_CALC_STUD_BILL_HRS\s*\(\s*[^,]*pidm[^,]*,', 'i');

select * from sgbstdn where sgbstdn_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001452603') order by sgbstdn_term_code_eff;