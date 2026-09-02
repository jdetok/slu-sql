select distinct rrrareq_pidm
from rrrareq
where rrrareq_aidy_code = :AIDY
and rrrareq_treq_code in (
    'SOR' || case substr(:TERM, 5, 2) when '00' then 'SUM' when '10' then 'FAL' when '20' then 'SPR' end,
    'SOR' || case substr(:TERM, 5, 2) when '20' then 'WIN' end
)
and rrrareq_trst_code = 'M'
and rrrareq_pidm = :PIDM
;