-- BASE POPULATION (assigns AIP)
select a.sgbstdn_pidm
from saturn.sgbstdn a
left join (
    select sgrsatt_pidm, sgrsatt_atts_code, sgrsatt_term_code_eff,
        row_number() over ( partition by sgrsatt_pidm order by sgrsatt_term_code_eff desc ) as rn
    from sgrsatt
    where sgrsatt_term_code_eff <= case 
        when to_char(sysdate, 'MM') < '08' then to_char(sysdate, 'YYYY') else to_char(to_char(sysdate, 'YYYY') + 1)
    end || '20'
) b on b.sgrsatt_pidm = a.sgbstdn_pidm and b.rn = 1
where a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= case 
        when to_char(sysdate, 'MM') < '08' then to_char(sysdate, 'YYYY') else to_char(to_char(sysdate, 'YYYY') + 1)
    end || '20'
)
and a.sgbstdn_stst_code in ('AS','IL')
and a.sgbstdn_levl_code not in ('AC')
and (
    b.sgrsatt_atts_code is null
    or b.sgrsatt_atts_code not in ('SGI','SPNT','SPNU','SPNS','SPSY')
)
and not exists (
    select 1 from gcraact
    where gcraact_pidm = a.sgbstdn_pidm
    and gcraact_gcbactm_id = 4
    and gcraact_gcvasts_id = 1
)
;

select gcraact_pidm from gcraact
where gcraact_gcbactm_id = 4
and gcraact_gcvasts_id = 1
;

select * from gcvasts;


select * from gcbapst order by gcbapst_activity_date desc;


select * from gcbajob order by gcbajob_creation_date desc;


-- NOT COMPLETE QUERY
select a.gcraact_pidm
from gcraact a
join saturn.sgbstdn b on b.sgbstdn_pidm = a.gcraact_pidm
and b.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = b.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= case 
        when to_char(sysdate, 'MM') < '08' then to_char(sysdate, 'YYYY') else to_char(to_char(sysdate, 'YYYY') + 1)
    end || '20'
)
left join saturn.sgrsatt c on c.sgrsatt_pidm = b.sgbstdn_pidm
and c.sgrsatt_term_code_eff = (
    select max(z.sgrsatt_term_code_eff)
    from sgrsatt z
    where z.sgrsatt_pidm = c.sgrsatt_pidm
    and z.sgrsatt_term_code_eff <= case 
        when to_char(sysdate, 'MM') < '08' then to_char(sysdate, 'YYYY') else to_char(to_char(sysdate, 'YYYY') + 1)
    end || '20'
)
where a.gcraact_gcbactm_id = 3
and a.gcraact_gcvasts_id = 1
and b.sgbstdn_stst_code in ('AS','IL')
and b.sgbstdn_levl_code not in ('AC')
and (
    c.sgrsatt_atts_code is null
    or c.sgrsatt_atts_code not in ('SGI','SPNT','SPNU','SPNS','SPSY')
)

;



select * from gcraact where gcraact_gcbactm_id = 4
;

select a.gcraact_pidm
from gcraact a

join saturn.sgbstdn b
  on b.sgbstdn_pidm = a.gcraact_pidm
 and not exists (
       select 1
       from saturn.sgbstdn b2
       where b2.sgbstdn_pidm = b.sgbstdn_pidm
         and b2.sgbstdn_term_code_eff > b.sgbstdn_term_code_eff
 )

left join saturn.sgrsatt c
  on c.sgrsatt_pidm = b.sgbstdn_pidm
 and not exists (
       select 1
       from saturn.sgrsatt c2
       where c2.sgrsatt_pidm = c.sgrsatt_pidm
         and c2.sgrsatt_term_code_eff > c.sgrsatt_term_code_eff
 )

where a.gcraact_gcbactm_id = 3
  and a.gcraact_gcvasts_id = 1
  and b.sgbstdn_stst_code in ('AS','IL')
  and b.sgbstdn_levl_code not in ('AC')
  and (
        c.sgrsatt_atts_code is null
     or c.sgrsatt_atts_code not in ('SGI','SPNT','SPNU','SPNS','SPSY')
  )
  ;

  select * from robusdf where robusdf_aidy_code = '2627' and robusdf_value_321 is not null;