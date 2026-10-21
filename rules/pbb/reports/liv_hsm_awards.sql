-- janice pbb report 04/08/2026

-- could you create a dashboard that shows coa component .RBRPBCP_PBCP_CODE = 6 LIV AND RBRPBCP1.DISPLAY_AMOUNT = 7880 AND THEY HAVE A HOUSING AWARD > 0  FUND CODES SLUAAH, SLUHOU, SLUPTH, SLUCHA
-- i awarded over 5000 housing awards yesterday and need to be sure no one is living with parent

desc rbrpbcp;
desc rbrapbc;

select rbrapbc_pidm, rbrapbc_aidy_code, rbrapbc_period, rbrapbc_pbtp_code, rbrapbc_pbcp_code, rbrapbc_amt
from rbrapbc 
order by rbrapbc_period desc
fetch first 100 rows only;