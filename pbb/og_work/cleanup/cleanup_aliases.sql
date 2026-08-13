select * from rbrabrc where rbrabrc_validated_ind = 'N';

-- find statements that use the same "X" alias for multiple tables
-- fixed all these 6/18/2026
select rbrabrc_abrc_code, rbrabrc_seq_no 
from rbrabrc 
where regexp_like(rbrabrc_sql_statement, '^FROM\s[A-Za-z]+\sX,\s[A-Za-z]+\sX', 'm')
order by rbrabrc_abrc_code, rbrabrc_seq_no;

-- do one to find starts with spaces
-- have to use [[:blank]] over \r\n\t escape sequences as oracle follows posix regex standards
SELECT rbrabrc_abrc_code, rbrabrc_seq_no 
FROM rbrabrc 
where regexp_like(rbrabrc_sql_statement, '^[[:blank:]]*'||CHR(10))
ORDER BY rbrabrc_abrc_code, rbrabrc_seq_no; 