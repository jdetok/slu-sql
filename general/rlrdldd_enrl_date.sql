select 
    bid, name, rlrdldd_fund_code,
    disb1_period, disb1_gross_amt, disb1_fee_amt, disb1_net_amt, disb1_enroll_dt,
    disb2_period, disb2_gross_amt, disb2_fee_amt, disb2_net_amt, disb2_enroll_dt,
    robnyud_value_194, robnyud_value_195, robnyud_value_196
from (
    select 
        spriden_id as bid,
        spriden_last_name || ', ' || spriden_first_name as name,
        rlrdldd_period,
        rlrdldd_fund_code,
        rlrdldd_disb_no,
        rlrdldd_gross_amt,
        rlrdldd_fee_amt,
        rlrdldd_net_amt,
        rlrdldd_enrollment_effect_date,
        robnyud_value_194,
        robnyud_value_195,
        robnyud_value_196
    from rlrdldd a
    join spriden on spriden_pidm = a.rlrdldd_pidm and spriden_change_ind is null
    join robnyud on robnyud_pidm = rlrdldd_pidm
    and rlrdldd_aidy_code = '2627'
) pivot (
    max(rlrdldd_period) as period,
    max(rlrdldd_gross_amt) as gross_amt,
    max(rlrdldd_fee_amt) as fee_amt,
    max(rlrdldd_net_amt) as net_amt,
    max(rlrdldd_enrollment_effect_date) as enroll_dt
    for rlrdldd_disb_no in (1 as disb1, 2 as disb2)
) order by bid, rlrdldd_fund_code

;

select distinct stvterm_fa_proc_yr as aidy from stvterm 
where substr(stvterm_code,1,4) between 
    to_char(to_char(sysdate,'YYYY') - 2) 
    and to_char(to_char(sysdate,'YYYY') + 2)
order by stvterm_fa_proc_yr desc
;
