-- start of working file for RORMESG BCM process
-- look for message code with activity date > sysdate and sysdate < expiration 

select * from rormesg where rormesg_pidm = (select spriden_pidm from spriden where spriden_id = '001031349' and spriden_change_ind is null);

select * from rtvmesg where rtvmesg_code = 'APN';

select * from rtvtreq where rtvtreq;
desc rtvtreq;

-- get all rtvtreq tracking codes 
-- RTVTREQ_LTR_EXCLUDE_IND 
select rrrareq_treq_code, rtvtreq_ltr_exclude_ind 
from rrrareq
join rtvtreq on rrrareq_treq_code = rtvtreq_code
where rrrareq_aidy_code = '2627' 
group by rrrareq_treq_code, rtvtreq_ltr_exclude_ind; 