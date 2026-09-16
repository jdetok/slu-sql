-- CM_current_aidy
select case when to_char(sysdate, 'MM') < '08' 
    then to_char(to_number(to_char(sysdate,'YY')) - 1) || to_char(sysdate, 'YY')
    else to_char(sysdate, 'YY') || to_char(to_number(to_char(sysdate,'YY')) + 1) 
end as aidy from dual where :pidm = :pidm
;

-- CM_current_aidy_desc
select case when to_char(sysdate, 'MM') < '08' 
    then '20' || to_char(to_number(to_char(sysdate,'YY')) - 1) || to_char(sysdate, ' - YYYY')
    else to_char(sysdate, 'YYYY - ') || to_char(to_number(to_char(sysdate,'YYYY')) + 1) 
end || ' Financial Aid Year' as aidy from dual where :pidm = :pidm
;