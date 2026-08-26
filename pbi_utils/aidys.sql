select distinct stvterm_fa_proc_yr as aidy from stvterm 
where substr(stvterm_code,1,4) between  
    to_char(to_char(sysdate,'YYYY') - 2)    
    and to_char(to_char(sysdate,'YYYY') + 2) 
order by stvterm_fa_proc_yr desc
;