select * from rbrabrc where rbrabrc_aidy_code = '2627' 
and regexp_like(substr(rbrabrc_abrc_code, 1, 1), '^[[:digit:]]+$');

select * from rtvabrc where regexp_like(substr(rtvabrc_code, 1, 1), '^[[:digit:]]+$');

select * from rtvpbcp where regexp_like(substr(rtvpbcp_code, 1, 1), '^[[:digit:]]+$');

select * from rtvpbgp where rtvpbgp_code not like '%-%';

select * from roralgs where roralgs_aidy_code = '2627';