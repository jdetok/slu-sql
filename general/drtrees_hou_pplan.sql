-- need the opposite as well (no housing charge, has 2)
select spriden_id as bid
from tbraccd
join rorstat on rorstat_pidm = tbraccd_pidm 
    and rorstat_aidy_code = substr(tbraccd_term_code, 3, 2) - 1 || substr(tbraccd_term_code, 3, 2)
join spriden on spriden_pidm = tbraccd_pidm and spriden_change_ind is null
join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
    and tbbdetc_type_ind = 'C'
    and tbbdetc_dcat_code = 'HOU'
where tbraccd_term_code = '202710'
and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
group by spriden_id
having sum(tbraccd_amount) > 0
;

desc tbraccd;

select tbbacct_pidm from tbbacct
group by tbbacct_pidm
having count(*) > 1;


SELECT owner, table_name, column_name, data_type
FROM all_tab_columns
WHERE column_name LIKE '%DELI_CODE%'
and OWNER = 'TAISMGR'
ORDER BY table_name;

select spriden_id as bid, 'Y' as has_pplan
from tbbacct 
join spriden on spriden_change_ind is null and spriden_pidm = tbbacct_pidm
where tbbacct_deli_code in ('TN', 'DP', 'DM', 'DS', 'SN', 'SP')
;

select spriden_id as bid, rcrapp4_sar_efc as sai
from rcrapp1 
join rcrapp4 on rcrapp4_pidm = rcrapp1_pidm
    and rcrapp4_aidy_code = rcrapp1_aidy_code
    and rcrapp4_infc_code = rcrapp1_infc_code
    and rcrapp4_seq_no = rcrapp1_seq_no
join spriden on spriden_pidm = rcrapp1_pidm and spriden_change_ind is null
where rcrapp1_curr_rec_ind = 'Y' and rcrapp1_infc_code = 'EDE'
and rcrapp1_aidy_code = '2627'
;
desc rcrapp1;