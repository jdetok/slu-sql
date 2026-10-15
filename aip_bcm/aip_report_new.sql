-- select AIP status and student info for students assigned AIPs and have current sgbstdn
select 
    a.gcraact_pidm as pidm,
    b.spriden_id as bid,
    b.spriden_last_name || ', ' || b.spriden_first_name as name,
    a.gcraact_gcbactm_id || ': ' || d.gcbactm_name as aip,
    a.gcraact_gcvasts_id || ': ' || c.gcvasts_status_rule_name as status,
    a.gcraact_display_start_date as date_asgn,
    a.gcraact_user_response_date as date_compl,
    e.sgbstdn_levl_code as levl,
    e.sgbstdn_coll_code_1 || ': ' || f.stvcoll_desc as coll,
    e.sgbstdn_program_1 || ': ' || g.smrprle_program_desc as prog
from gcraact a
join spriden b on b.spriden_pidm = a.gcraact_pidm and b.spriden_change_ind is null
join gcvasts c on c.gcvasts_surrogate_id = a.gcraact_gcvasts_id 
join gcbactm d on d.gcbactm_surrogate_id = a.gcraact_gcbactm_id
join sgbstdn e on e.sgbstdn_pidm = a.gcraact_pidm and e.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.gcraact_pidm
    and z.sgbstdn_term_code_eff <= (
        select y.robinst_aidy_end_year || '20' from robinst y
        where robinst_status_ind = 'A'
        and robinst_aidy_code = case
            when to_char(sysdate, 'MM') < '08' then to_char(sysdate - 365, 'YY') || to_char(sysdate, 'YY')
            else to_char(sysdate, 'YY') || to_char(sysdate + 365, 'YY')
        end 
    )
)
join stvcoll f on f.stvcoll_code = e.sgbstdn_coll_code_1
join smrprle g on g.smrprle_program = e.sgbstdn_program_1
where a.gcraact_gcbactm_id > 2 -- 1 and 2 are test AIPs 
;