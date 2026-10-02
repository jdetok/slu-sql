-- mimic RPAELAP banner screen, requested from Janice 10/02/2026
-- initial purpose to find students with FAO lender/return/guarantor IDs
select 
    rprlapp_aidy_code as aidy,
    rprlapp_pidm as pidm,
    b.spriden_id as bid,
    rprlapp_ssn as ssn,
    rprlapp_citz_ind as citizen,
    rprlapp_appl_no as appl_no,
    rprlapp_el_seq_no as seq_no,
    rprlapp_model_cde as depend,
    rprlapp_in_default as in_dflt,
    rprlapp_loan_period as loan_period,
    rprlapp_lnst_code as loan_status,
    rprlapp_el_status as appl_status,
    rprlapp_alt_loan_prog_type_cde as prog_code,
    c.spriden_id as lend_code, 
    c.spriden_last_name as lend_desc,
    d.spriden_id as rtrn_code,
    d.spriden_last_name as rtrn_desc,
    e.spriden_id as guar_code,
    e.spriden_last_name as guar_desc,
    rprlapp_request_amt as request_amt,
    rprlapp_recommend_amt as recommend_amt,
    rprlapp_max_elig_amt as max_elig_amt,
    rprlapp_approve_amt as approve_amt,
    rprlapp_el_process_type as proc_type,
    rprlapp_record_type as rec_type,
    rprlapp_loan_type as loan_type,
    rprlapp_create_date as create_date,
    rprlapp_sub_date as sub_date,
    rprlapp_approve_date as approve_date,
    rprlapp_el_date_sent as el_sent_date,
    rprlapp_el_loan_id as el_loan_id,
    rprlapp_driver_lic_no as license,
    rprlapp_alt_loan_sb_ind as stud_borrow,
    rprlapp_cred_dif_nm_ind as cred_other_name,
    rprlapp_alt_bor_loan_debt as loan_debt,
    rprlapp_address as addr1,
    rprlapp_addr_line2 as addr2,
    rprlapp_city as city,
    rprlapp_state as state,
    rprlapp_zip as zip,
    rprlapp_natn_code as natn,
    rprlapp_phone_no as phone

from rprlapp
join spriden b on b.spriden_pidm = rprlapp_pidm and b.spriden_change_ind is null
join spriden c on c.spriden_pidm = rprlapp_lender_pidm and c.spriden_change_ind is null
join spriden d on d.spriden_pidm = rprlapp_return_pidm and d.spriden_change_ind is null
join spriden e on e.spriden_pidm = rprlapp_guar_pidm and e.spriden_change_ind is null
where rprlapp_fund_code = 'ALTERN'
and rprlapp_aidy_code = '2627'
-- and (
--     regexp_like(rprlapp_alt_loan_prog_type_cde, '^(FAO){1,2}$')
--     or regexp_like(c.spriden_id, '^(FAO){1,2}$')
--     or regexp_like(c.spriden_last_name, '^(FAO){1,2}$')
--     or regexp_like(d.spriden_id, '^(FAO){1,2}$')
--     or regexp_like(d.spriden_last_name, '^(FAO){1,2}$')
--     or regexp_like(e.spriden_id, '^(FAO){1,2}$')
--     or regexp_like(e.spriden_last_name, '^(FAO){1,2}$')
-- )
;

SELECT column_name, data_type, data_length
FROM all_tab_columns
WHERE table_name like 'RPRLAPP%' 
AND column_name like '%SSN%';

select * from rprlapp where rprlapp_pidm = 1370510;