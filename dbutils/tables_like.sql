
SELECT table_name, comments
FROM all_tab_comments
WHERE table_name LIKE '%GJB%'
ORDER BY table_name;

select * from stvmajr where stvmajr_code = 'BIOL';
desc stvmajr;

SELECT table_name, column_name, data_type, data_length
FROM all_tab_columns
-- WHERE table_name like 'RPRLAPP%' 
where column_name like '%ONE_UP%';

SELECT table_name, comments
FROM   all_tab_comments
WHERE  owner = 'GENERAL'
  AND  (table_name LIKE 'GJB%' OR table_name LIKE 'GJR%' OR table_name LIKE 'GUR%JOB%')
ORDER  BY table_name;

SELECT table_name, column_name
FROM   all_tab_columns
-- WHERE  owner = 'BANINST1'  -- or your Banner owner, e.g. GENERAL
  where  column_name LIKE '%ONE_UP_NO%'
ORDER  BY table_name;