select distinct stvterm_code as term
from stvterm
where substr(stvterm_code, 0, 4) between 
    to_char(extract(year from sysdate) - 2)
    and to_char(extract(year from sysdate) + 1)
and substr(stvterm_code, 5, 2) in ('00', '10', '20') 
order by stvterm_code desc
;