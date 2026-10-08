
SELECT table_name, comments
FROM all_tab_comments
WHERE table_name LIKE '%TMAC%'
ORDER BY table_name;

select * from stvmajr where stvmajr_code = 'BIOL';
desc stvmajr;

SELECT column_name, data_type, data_length
FROM all_tab_columns
WHERE table_name like 'RPRLAPP%' 
AND column_name like '%AMT%';