-- 2/20/2026 change all the calls to stud_credit_hrs to stud_bill_hrs
select rbrabrc_abrc_code, rbrabrc_seq_no, rbrabrc_validated_ind, rbrabrc_sql_statement
from rbrabrc
where rbrabrc_aidy_code = '2627'
and (regexp_like(rbrabrc_sql_statement, 'F_CALC_STUD_CREDIT_HRS') or rbrabrc_validated_ind = 'N')
--and rbrabrc_abrc_code = '6LIV';