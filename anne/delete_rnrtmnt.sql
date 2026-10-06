-- delete from rnrtmnt
select *  from rnrtmnt
where rnrtmnt_aidy_code = '2627'
and rnrtmnt_request_type = 'H'
and rnrtmnt_fah_rcvd_date is null
and rnrtmnt_pidm = (select spriden_pidm from spriden where spriden_change_ind is null and spriden_id = '001133412')
;