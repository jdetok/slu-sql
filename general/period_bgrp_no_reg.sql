select spriden_id as bid, spriden_last_name || ', ' || spriden_first_name as name from rbrapbg
join spriden on spriden_pidm = rbrapbg_pidm and spriden_change_ind is null
where rbrapbg_run_name = 'ACTUAL'
and RBRAPBG_PERIOD = '202710'
and RBRAPBG_PBGP_CODE = 'MR'
and not exists (
    select 1 from sfrstcr
    where sfrstcr_pidm = rbrapbg_pidm
    and sfrstcr_term_code = rbrapbg_period
    and sfrstcr_bill_hr > 0
)
;