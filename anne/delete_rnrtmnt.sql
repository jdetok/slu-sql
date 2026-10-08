-- delete from rnrtmnt
select count(distinct rnrtmnt_pidm) from rnrtmnt
where rnrtmnt_aidy_code = '2627'
and rnrtmnt_request_type = 'H'
and rnrtmnt_fah_rcvd_date is null;

select count(distinct rnrtmnt_pidm) from rnrtmnt
where rnrtmnt_aidy_code = '2627'
and rnrtmnt_request_type = 'H'
and rnrtmnt_fah_rcvd_date is null
;
-- and rnrtmnt_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001133412')

 
select * from gjbprun where gjbprun_job in ('GLOLETT','GLOLETTJ');
select count(distinct rorstat_pidm) from rorstat where rorstat_aidy_code = '2627';

select * from rnrtmnt
-- delete from rnrtmnt
where rnrtmnt_aidy_code = '2627'
and rnrtmnt_request_type = 'H'
and rnrtmnt_fah_rcvd_date is null
-- and rnrtmnt_pidm in (
--     select spriden_pidm from spriden 
--     where spriden_change_ind is null 
--     and spriden_id in ('000097544', '001133412', '001161031', '000111675')
-- )
;