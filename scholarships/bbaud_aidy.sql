-- PREVIOUS AID YEAR
select
    case when to_char(sysdate, 'MM') < '06'
        then to_number(to_char(sysdate, 'YY')) - 2 || to_number(to_char(sysdate, 'YY') - 1)
        else to_number(to_char(sysdate, 'YY')) - 1 || to_char(sysdate, 'YY')
    end as aidy
from dual
;

-- CURRENT AID YEAR
select
    case when to_char(sysdate, 'MM') < '06'
        then to_number(to_char(sysdate, 'YY')) - 1 || to_char(sysdate, 'YY')
        else to_char(sysdate, 'YY')|| to_number(to_char(sysdate, 'YY') + 1)
    end as aidy
from dual
;