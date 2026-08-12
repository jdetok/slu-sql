with term as (
    select '202710' as t from dual
), term2 as (
    select '202720' as t from dual
), tmst as (
    select * from (
        select
            sfrthst_pidm as pidm,
            sfrthst_term_code as term,
            sfrthst_tmst_code as thst,
            row_number() over (
                partition by sfrthst_pidm, sfrthst_term_code
                order by sfrthst_tmst_date desc
            ) as rn
        from sfrthst
        where sfrthst_term_code = (select t from term)
    ) 
    where rn = 1
), stu as (
    select 
        spriden_id as bid,
        a.sgbstdn_pidm as pidm,
        b.rorstat_aidy_code as aidy,
        a.sgbstdn_levl_code as levl
    from sgbstdn a
    join rorstat b
        on b.rorstat_pidm = a.sgbstdn_pidm
        and b.rorstat_aidy_code = substr((select t from term), 3, 2) - 1 || substr((select t from term), 3, 2)
        and b.rorstat_appl_rcvd_date is not null
    join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
    where a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= (select t from term2)
    )
    and a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
    and a.sgbstdn_levl_code <> 'PL' -- law students excluded
)
select 
    -- bid, levl, thst
    a.pidm
from stu a
join tmst b on b.pidm = a.pidm
where thst in ('LH', 'HT', '3Q')
and not exists (
    select 1 from robusdf
    where robusdf_pidm = a.pidm
    and robusdf_aidy_code = a.aidy
    and robusdf_value_321 is not null
)
;



select a.pidm from (
    select 
        spriden_id as bid,
        a.sgbstdn_pidm as pidm,
        b.rorstat_aidy_code as aidy,
        a.sgbstdn_levl_code as levl
    from sgbstdn a
    join rorstat b
        on b.rorstat_pidm = a.sgbstdn_pidm
        and b.rorstat_aidy_code = '2627'
        and b.rorstat_appl_rcvd_date is not null
    join spriden on spriden_pidm = a.sgbstdn_pidm and spriden_change_ind is null
    where a.sgbstdn_term_code_eff = (
        select max(z.sgbstdn_term_code_eff)
        from sgbstdn z
        where z.sgbstdn_pidm = a.sgbstdn_pidm
        and z.sgbstdn_term_code_eff <= '202720'
    )
    
) a
-- join (
--     select * from (
--         select
--             sfrthst_pidm as pidm,
--             sfrthst_term_code as term,
--             sfrthst_tmst_code as thst,
--             row_number() over (
--                 partition by sfrthst_pidm, sfrthst_term_code
--                 order by sfrthst_tmst_date desc
--             ) as rn
--         from sfrthst
--         where sfrthst_term_code = '202710'
--     ) 
--     where rn = 1
-- ) b on b.pidm = a.pidm
-- where thst in ('LH', 'HT', '3Q')
where not exists (
    select 1 from robusdf
    where robusdf_pidm = a.pidm
    and robusdf_aidy_code = a.aidy
    and robusdf_value_321 is not null
)
;


select a.sgbstdn_pidm
from sgbstdn a
join rorstat b
    on b.rorstat_pidm = a.sgbstdn_pidm
    and b.rorstat_aidy_code = '2627'
    and b.rorstat_appl_rcvd_date is not null
join sfrthst c
on c.sfrthst_pidm = a.sgbstdn_pidm
and c.sfrthst_term_code = '202710'
and c.sfrthst_tmst_date = (
    select max(z.sfrthst_tmst_date)
    from sfrthst z
    where z.sfrthst_pidm = c.sfrthst_pidm
    and z.sfrthst_term_code = c.sfrthst_term_code
)
where a.sgbstdn_stst_code in ('AS', 'IL', 'P1')
and a.sgbstdn_levl_code <> 'PL' -- law students excluded
and a.sgbstdn_term_code_eff = (
    select max(z.sgbstdn_term_code_eff)
    from sgbstdn z
    where z.sgbstdn_pidm = a.sgbstdn_pidm
    and z.sgbstdn_term_code_eff <= '202720'
)
and c.sfrthst_tmst_code in ('LH', 'HT', '3Q')
and not exists (
    select 1 from robusdf
    where robusdf_pidm = a.sgbstdn_pidm
    and robusdf_aidy_code = b.rorstat_aidy_code
    and robusdf_value_321 is not null
)
;

select * from sfrthst where sfrthst_pidm =  (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001031349');

select substr('202710', 3, 2) - 1 || substr('202710', 3, 2) from dual;
select substr('202710', 3, 2) -1  from dual;

select rorstat_appl_rcvd_date from rorstat;