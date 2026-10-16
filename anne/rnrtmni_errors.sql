select * from gjbprun
where gjbprun_job = 'RNRTMNI' 
and gjbprun_one_up_no = 8512211
order by gjbprun_activity_date desc;

select * from gjbpdft
where gjbpdft_job = 'RNRTMNI' ;
-- ORDER  BY gjbpdft_one_up_no DESC, gjbpdft_number;
select * from guroutp where guroutp_one_up_no = 8512211;

-- promising
select * from guboutp
where guboutp_job = 'RNRTMNI'
order by guboutp_date_saved desc;

select * from gjrjprm where gjrjprm_job = 'RNRTMNI';
select * from gjbpdef ;
-- where gjbpdef_one_up_no = 8512211;
SELECT COUNT(*) FROM gjbpdef WHERE gjbpdef_job = 'RNRTMNI';
select * from gjbajobs
where gjbjobs_name = 'RNRTMNI';

select * from gjbrslt
where gjbrslt_job = 'RNRTMNI'
 order by gjbrslt_activity_date desc;

select * from gjrjlis
where gjrjlis_job = 'RNRTMNI';


select * from gjbprun;

SELECT gjbprun_one_up_no,
       gjbprun_number,
       gjbprun_value
FROM   gjbprun
WHERE  gjbprun_job = 'RNRTMNI'
ORDER  BY gjbprun_one_up_no DESC, gjbprun_number;

select * from gjrjlis where gjrjlis_job = 'RNRTMNI';

SELECT gjbpdef_number, gjbpdef_desc
FROM   gjbpdef
WHERE  gjbpdef_job = 'RNRTMNI'
ORDER  BY gjbpdef_number;

SELECT *
FROM   gjrjlis
WHERE  gjrjlis_job = 'RNRTMNI';
--   AND  gjrjlis_one_up_no = :one_up;


SELECT o.guroutp_one_up_no,
       (SELECT COUNT(*) FROM gjbprun p
        WHERE  p.gjbprun_one_up_no = o.guroutp_one_up_no) AS param_rows
FROM   guroutp o
WHERE  o.guroutp_one_up_no IN (
         SELECT gjbprun_one_up_no FROM gjbprun WHERE gjbprun_job = 'RNRTMNI')
   OR  o.guroutp_one_up_no = :one_up
ORDER  BY 1 DESC;