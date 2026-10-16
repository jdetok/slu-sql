-- old award data pre 0506
-- in the ODS db

select * from slu_sis.plus_swfile_rs;

select table_name, comments 
FROM all_tab_comments
where owner = 'SLU_SIS'
and table_name like '%SWFILE%';

-- AWARD DATA WITH FUND TITLES
select sf_out_fund_mnem, sf_out_fund, sf_out_fund_desc
from slu_sis.PLUS_SWFILE_RS -- award data
join SLU_SIS.PLUS_SFFILE_RS on sw_out_fund = sf_out_fund
where sf_out_fund_mnem in ('SCH-E', 'SCH-D', 'SCHDE', 'SCHRT', 'SCHTE')
;

select distinct sf_out_fund_mnem from slu_sis.PLUS_SfFILE_RS;
select * from slu_sis.plus_swfile_rs;


select * from SLU_SIS.PLUS_SFFILE_rs
-- where sf_out_fund_desc like '%Feraldo%'
where sf_out_fund_mnem = 'SCH-E'
; -- fund names (join to sf_out_fund)

select *  from slu_sis.PLUS_SfFILE_fy;