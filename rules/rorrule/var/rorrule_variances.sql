-- use this in python script
-- query the rules, run the rule (have to remove pidm bind)
select rorgdat_grp_code, rorgdat_aidy_code, rorgdat_type_ind, rorgdat_slct, rorcmpl_sql_statement
from rorgdat
join rorcmpl on rorcmpl_slct = rorgdat_slct
where rorgdat_aidy_code = :aidy
and rorgdat_type_ind = 'P';