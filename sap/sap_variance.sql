select 
    spriden_id, spriden_last_name || ', ' || spriden_first_name as name, 
    a.rorsapr_term_code, a.rorsapr_sapr_code, 
    b.rorsapr_term_code, b.rorsapr_sapr_code
from rorsapr a
join rorsapr b 
    on b.rorsapr_pidm = a.rorsapr_pidm
    and b.rorsapr_term_code = '202710'
join spriden on spriden_pidm = a.rorsapr_pidm and spriden_change_ind is null
where a.rorsapr_term_code = '202700'
and a.rorsapr_sapr_code <> b.rorsapr_sapr_code
;

