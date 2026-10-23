-- LIV | TRS | MIS
-- look for existence of PS2 or S8A part of term codes and NO OTHER part of term
-- specifically SPS, 

-- 2FEE changes (make new rule for spring only)
-- what does the new rule need to look for? 
-- based on time status rather than hours for everybody

-- GR TUITION: DONE
-- if they have PS15 attr or PS% cohort, 15% off
-- change sequences 233 235 236
-- 233 - 13 from old rule

select case
    when nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD, x.sgbstdn_pidm, 'N'), 0) > 0
    then case when (b.sgrsatt_atts_code is not null or c.sgrchrt_chrt_code is not null)
        then round(roralgs_amt * nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD, x.sgbstdn_pidm, 'N'), 0) * 0.85)
        else round(roralgs_amt * nvl(rokmisc.f_calc_stud_bill_hrs(:PERIOD, x.sgbstdn_pidm, 'N'), 0))
    end
end as calc_amt
from sgbstdn x 
left join sgrsatt b on b.sgrsatt_pidm = x.sgbstdn_pidm
    and b.sgrsatt_term_code_eff = (
        select max(y.sgrsatt_term_code_eff)
        from sgrsatt y
        where y.sgrsatt_term_code_eff <= :PERIOD
        and y.sgrsatt_pidm =  b.sgrsatt_pidm
    )
    and sgrsatt_atts_code in ('PS15')
left join sgrchrt c on c.sgrchrt_pidm = x.sgbstdn_pidm
    and c.sgrchrt_chrt_code like 'PS%'
    and c.sgrchrt_term_code_eff = (
        select max(z.sgrchrt_term_code_eff) from sgrchrt z
        where z.sgrchrt_pidm = c.sgrchrt_pidm
        and z.sgrchrt_term_code_eff <= :PERIOD
    )
join roralgs on roralgs_aidy_code = :AIDY
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = x.sgbstdn_levl_code
    and roralgs_key_6 = x.sgbstdn_camp_code
    and roralgs_key_7 = x.sgbstdn_coll_code_1
    and roralgs_key_9 is null
    and roralgs_key_10 is null
    and roralgs_key_11 is null
where x.sgbstdn_levl_code = 'GR'
and x.sgbstdn_camp_code = 'FR'
and x.sgbstdn_coll_code_1 = 'PS'
and x.sgbstdn_stst_code in  ('AS','IL','P1')
and x.sgbstdn_term_code_eff = (
    select max(y.sgbstdn_term_code_eff)
    from sgbstdn y
    where y.sgbstdn_pidm = x.sgbstdn_pidm
    and y.sgbstdn_term_code_eff <= :PERIOD
)
and x.sgbstdn_pidm = :PIDM
;

-- 235
select case when (b.sgrsatt_atts_code is not null or c.sgrchrt_chrt_code is not null)
    then round((roralgs_amt * 12) * 0.85) else round(roralgs_amt * 12)
end as calc_amt
from sgbstdn x 
left join sgrsatt b on b.sgrsatt_pidm = x.sgbstdn_pidm
    and b.sgrsatt_term_code_eff = (
        select max(y.sgrsatt_term_code_eff)
        from sgrsatt y
        where y.sgrsatt_term_code_eff <= :PERIOD
        and y.sgrsatt_pidm =  b.sgrsatt_pidm
    )
    and sgrsatt_atts_code in ('PS15')
left join sgrchrt c on c.sgrchrt_pidm = x.sgbstdn_pidm
    and c.sgrchrt_chrt_code like 'PS%'
    and c.sgrchrt_term_code_eff = (
        select max(z.sgrchrt_term_code_eff) from sgrchrt z
        where z.sgrchrt_pidm = c.sgrchrt_pidm
        and z.sgrchrt_term_code_eff <= :PERIOD
    )
join roralgs on roralgs_aidy_code = :AIDY
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = x.sgbstdn_levl_code
    and roralgs_key_6 = x.sgbstdn_camp_code
    and roralgs_key_7 = x.sgbstdn_coll_code_1
    and roralgs_key_9 is null
    and roralgs_key_10 is null
    and roralgs_key_11 is null
where x.sgbstdn_levl_code = 'GR'
and x.sgbstdn_camp_code = 'FR'
and x.sgbstdn_coll_code_1 = 'PS'
and x.sgbstdn_stst_code in  ('AS','IL','P1')
and x.sgbstdn_term_code_eff = (
    select max(y.sgbstdn_term_code_eff)
    from sgbstdn y
    where y.sgbstdn_pidm = x.sgbstdn_pidm
    and y.sgbstdn_term_code_eff <= :PERIOD
)
and x.sgbstdn_pidm = :PIDM
;


-- 236 - 0 rows og rule
select case when (d.saraatt_atts_code is not null or e.sarchrt_chrt_code is not null)
    then round((roralgs_amt * 12) * 0.85) else round(roralgs_amt * 12)
end as calc_amt
from saradap a
join sarappd b on b.sarappd_pidm = a.saradap_pidm
    and b.sarappd_term_code_entry = a.saradap_term_code_entry
    and b.sarappd_appl_no = a.saradap_appl_no
join stvapdc c on c.stvapdc_code = b.sarappd_apdc_code
    and c.stvapdc_inst_acc_ind = 'Y'
    and c.stvapdc_signf_ind = 'Y'
left join saraatt d on d.saraatt_pidm = a.saradap_pidm
    and d.saraatt_term_code = (
        select max(y.saraatt_term_code)
        from saraatt y
        where y.saraatt_term_code <= :PERIOD
        and y.saraatt_pidm =  d.saraatt_pidm
    )
    and d.saraatt_atts_code in ('PS15')
left join sarchrt e on e.sarchrt_pidm = a.saradap_pidm    
    and e.sarchrt_chrt_code like 'PS%'
    and e.sarchrt_term_code_entry = (
        select max(z.sarchrt_term_code_entry) from sarchrt z
        where z.sarchrt_pidm = e.sarchrt_pidm
        and z.sarchrt_term_code_entry <= :PERIOD
    )
join roralgs on roralgs_aidy_code = :AIDY
    and roralgs_key_1 = 'PBDG'
    and roralgs_key_4 = '1TUI'
    and roralgs_key_5 = a.saradap_levl_code
    and roralgs_key_6 = a.saradap_camp_code
    and roralgs_key_7 = a.saradap_coll_code_1
    and roralgs_key_9 is null
    and roralgs_key_10 is null
    and roralgs_key_11 is null
join robinst r on r.robinst_aidy_code = :AIDY and r.robinst_status_ind = 'A'
where a.saradap_term_code_entry = (
    select max(z.saradap_term_code_entry)
    from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry between r.robinst_aidy_end_year || '10' and :PERIOD
)
and a.saradap_appl_no = (
    select max(z.saradap_appl_no) from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry = a.saradap_term_code_entry
)
and b.sarappd_seq_no = (
    select max(z.sarappd_seq_no)
    from sarappd z
    where z.sarappd_pidm = b.sarappd_pidm
    and z.sarappd_appl_no = b.sarappd_appl_no
    and z.sarappd_term_code_entry = b.sarappd_term_code_entry
)
and a.saradap_levl_code = 'GR'
and a.saradap_coll_code_1 = 'PS'
and a.saradap_camp_code = 'FR'
and a.saradap_pidm = :PIDM
;

select * from sarchrt;

select * from sgbstdn x
where x.sgbstdn_levl_code = 'GR'
and x.sgbstdn_camp_code = 'FR'
and x.sgbstdn_coll_code_1 = 'PS'
and x.sgbstdn_stst_code in  ('AS','IL','P1')
and x.sgbstdn_term_code_eff = (
    select max(y.sgbstdn_term_code_eff)
    from sgbstdn y
    where y.sgbstdn_pidm = x.sgbstdn_pidm
    and y.sgbstdn_term_code_eff <= :PERIOD
);
select * from saradap a
join robinst r on r.robinst_aidy_code = :AIDY and r.robinst_status_ind = 'A'
where a.saradap_term_code_entry = (
    select max(z.saradap_term_code_entry)
    from saradap z
    where z.saradap_pidm = a.saradap_pidm
    and z.saradap_term_code_entry between r.robinst_aidy_end_year || '10' and :PERIOD
)
and a.saradap_levl_code = 'GR'
and a.saradap_coll_code_1 = 'PS'
and a.saradap_camp_code = 'FR'
;