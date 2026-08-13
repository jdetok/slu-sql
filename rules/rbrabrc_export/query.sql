-- select rbrabrc sql statements with their rule code and sequence number
-- aid year, rule code, and sequence number are all optional bind variables
-- if only sequence X from rule R is needed, that can be queried by passing 
-- those to the :rule and :seq variables
select 
    rbrabrc_aidy_code as aidy, rbrabrc_abrc_code as rule, rbrabrc_seq_no as seq,
    rbrabrc_sql_statement as sql
from rbrabrc
where rbrabrc_aidy_code = nvl(:aidy, rbrabrc_aidy_code)
and rbrabrc_abrc_code like nvl('%' || :rule || '%', rbrabrc_abrc_code)
and rbrabrc_seq_no = nvl(:seq, rbrabrc_seq_no);