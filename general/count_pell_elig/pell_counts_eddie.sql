-- pell eligible F,1,T student type count by year
select 
    a.sgbstdn_pidm, 
    c.spriden_id,
    a.sgbstdn_styp_code, 
    b.stvterm_fa_proc_yr,
    d.rcresar_pell_elgbl
from saturn.sgbstdn a
inner join saturn.stvterm b
    on b.stvterm_code = a.sgbstdn_term_code_eff
inner join saturn.spriden c 
    on c.spriden_pidm = a.sgbstdn_pidm
    and c.spriden_change_ind is null
inner join (
   select z.rcrapp1_pidm, z.rcrapp1_aidy_code, y.rcresar_pell_elgbl
   from faismgr.rcrapp1 z
    inner join faismgr.rcresar y
    on y.rcresar_pidm = z.rcrapp1_pidm
    and y.rcresar_aidy_code = z.rcrapp1_aidy_code
    and y.rcresar_infc_code = z.rcrapp1_infc_code
    and y.rcresar_seq_no = z.rcrapp1_seq_no
    and y.rcresar_pell_elgbl is not null
) d on d.rcrapp1_pidm = a.sgbstdn_pidm
    and d.rcrapp1_aidy_code = b.stvterm_fa_proc_yr
where a.sgbstdn_styp_code in ('1', 'F', 'T')
and (b.stvterm_fa_proc_yr >= '2122' 
    and b.stvterm_fa_proc_yr < '3000' ) -- avoid aid years from 90s that are numerically > 2122
group by a.sgbstdn_pidm, c.spriden_id, a.sgbstdn_styp_code, b.stvterm_fa_proc_yr, d.rcresar_pell_elgbl
order by b.stvterm_fa_proc_yr desc;

select 
    stvterm_fa_proc_yr as aid_year,
    count(sgbstdn_pidm) as cnt
from (
    select 
        a.sgbstdn_pidm, 
        c.spriden_id,
        a.sgbstdn_styp_code, 
        b.stvterm_fa_proc_yr,
        d.rcresar_pell_elgbl
    from saturn.sgbstdn a
    inner join saturn.stvterm b
        on b.stvterm_code = a.sgbstdn_term_code_eff
    inner join saturn.spriden c 
        on c.spriden_pidm = a.sgbstdn_pidm
        and c.spriden_change_ind is null
    inner join (
       select z.rcrapp1_pidm, z.rcrapp1_aidy_code, y.rcresar_pell_elgbl
       from faismgr.rcrapp1 z
        inner join faismgr.rcresar y
        on y.rcresar_pidm = z.rcrapp1_pidm
        and y.rcresar_aidy_code = z.rcrapp1_aidy_code
        and y.rcresar_infc_code = z.rcrapp1_infc_code
        and y.rcresar_seq_no = z.rcrapp1_seq_no
        and y.rcresar_pell_elgbl is not null
    ) d on d.rcrapp1_pidm = a.sgbstdn_pidm
        and d.rcrapp1_aidy_code = b.stvterm_fa_proc_yr
    where a.sgbstdn_styp_code in ('1', 'F', 'T')
    and a.sgbstdn_camp_code not in ('SP', 'PS')
    and (b.stvterm_fa_proc_yr >= '2122' 
        and b.stvterm_fa_proc_yr < '3000' ) -- avoid aid years from 90s that are numerically > 2122
    group by a.sgbstdn_pidm, c.spriden_id, a.sgbstdn_styp_code, b.stvterm_fa_proc_yr, d.rcresar_pell_elgbl
    order by b.stvterm_fa_proc_yr desc
)
group by stvterm_fa_proc_yr
order by stvterm_fa_proc_yr desc;
describe sgbstdn;