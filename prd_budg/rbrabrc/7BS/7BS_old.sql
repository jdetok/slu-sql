-- books and supplies

--BOOKS AND SUPPLIES seq #1  captured
select 
   case 
        when a.sgbstdn_levl_code = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr >= 12 then 535
        WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('00') and rorenrl_finaid_bill_hr < 6 then 0
        when a.sgbstdn_levl_code = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('00') then 119
	WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr >= 12 then 535
        when a.sgbstdn_levl_code = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr >= 12 then 710
        when a.sgbstdn_levl_code = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('00') and rorenrl_finaid_bill_hr >= 12 then 158
        when a.sgbstdn_levl_code = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr >= 6 then 720
        when a.sgbstdn_levl_code = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('00') and rorenrl_finaid_bill_hr >= 6 then 158
        when a.sgbstdn_levl_code = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr >= 12 then 125
        when a.sgbstdn_levl_code = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr BETWEEN 6 AND 11 then 270
	WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr BETWEEN 6 AND 11 then 270
        when a.sgbstdn_levl_code = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr < 6 then 134
	WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr < 6 then 134
        when a.sgbstdn_levl_code = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr BETWEEN 6 AND 11  then 355
        when a.sgbstdn_levl_code = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr < 6  then 178
        when a.sgbstdn_levl_code = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('00') and rorenrl_finaid_bill_hr < 12  then 79
        when a.sgbstdn_levl_code = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr < 6  then 355
        when a.sgbstdn_levl_code = 'PL' and RBRAPBG_PBGP_CODE LIKE 'GR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('00') and rorenrl_finaid_bill_hr < 6  then 79
        when a.sgbstdn_levl_code = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' AND SUBSTR(RORENRL_TERM_CODE,5,2) IN ('10','20') and rorenrl_finaid_bill_hr < 12 then 125
     END   
from sgbstdn a, rorenrl, rbrapbg
where a.sgbstdn_pidm = rorenrl_pidm
and a.sgbstdn_stst_code = 'AS'
and a.sgbstdn_term_code_eff = (select max(b.sgbstdn_term_code_eff)
                              from sgbstdn b
                              where b.sgbstdn_term_code_eff <= :period
                              and b.sgbstdn_pidm = a.sgbstdn_pidm)
AND RBRAPBG_PIDM = rorenrl_PIDM
AND RBRAPBG_PERIOD = rorenrl_term_code
and RBRAPBG_AIDY_CODE = :aidy
and rorenrl_enrr_code = 'STANDARD'
and rorenrl_term_code = :period
and a.sgbstdn_pidm = :pidm
--;

--BOOKS AND SUPPLIES seq #2  actual enrollment
select
   case when a.sgbstdn_levl_code = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' and reg.tot_bill_hours >= 12 then 535
        WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' and reg.tot_bill_hours >= 12 then 535
        when a.sgbstdn_levl_code = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' and reg.tot_bill_hours >= 6 then 710
        when a.sgbstdn_levl_code = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' and reg.tot_bill_hours >= 12 then 710
        when a.sgbstdn_levl_code = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' and reg.tot_bill_hours >= 12 then 125  
        when a.sgbstdn_levl_code = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' and reg.tot_bill_hours BETWEEN 6 AND 11 then 270
         WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' and reg.tot_bill_hours BETWEEN 6 AND 11 then 270
        when a.sgbstdn_levl_code = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' and reg.tot_bill_hours < 6 then 134
         WHEN A.SGBSTDN_LEVL_CODE = 'UG' and A.SGBSTDN_COLL_CODE_1 = 'PS' and reg.tot_bill_hours < 6 then 134
        when a.sgbstdn_levl_code = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' and reg.tot_bill_hours < 6 then 178
        when a.sgbstdn_levl_code = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' and reg.tot_bill_hours < 12 then 355
        when a.sgbstdn_levl_code = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' and reg.tot_bill_hours < 12 then 125
     END  amt
from sgbstdn a,rbrapbg,(select sum(sfrstcr_bill_hr) tot_bill_hours,sfrstcr_pidm,sfrstcr_term_code
              from sfrstcr, stvrsts
              where sfrstcr_term_code = :period
              and sfrstcr_rsts_code = stvrsts_code
              and stvrsts_incl_sect_enrl = 'Y'
              group by sfrstcr_pidm, sfrstcr_term_code) reg
 where reg.sfrstcr_pidm(+) = a.sgbstdn_pidm
 and a.sgbstdn_stst_code = 'AS'
 and a.sgbstdn_term_code_eff = (select max(b.sgbstdn_term_code_eff)
                              from sgbstdn b
                              where b.sgbstdn_term_code_eff <= reg.sfrstcr_term_code
                              and b.sgbstdn_pidm = reg.sfrstcr_pidm)
 AND rbrapbg_pidm = a.sgbstdn_pidm
 AND reg.SFRSTCR_TERM_CODE(+) = RBRAPBG_PERIOD
 and a.sgbstdn_pidm = :pidm
--;

--Books and supplies - default seq 3
select
   case when STDN.SGBSTDN_LEVL_CODE = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' then 535
        WHEN STDN.SGBSTDN_LEVL_CODE = 'UG' and STDN.SGBSTDN_COLL_CODE_1 = 'PS' then 535
        when STDN.SGBSTDN_LEVL_CODE = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' then 710
        when STDN.SGBSTDN_LEVL_CODE = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 710
        when STDN.SGBSTDN_LEVL_CODE = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 125  
        when ADAP.SARADAP_LEVL_CODE = 'UG' and RBRAPBG_PBGP_CODE LIKE 'UG%' then 535
        WHEN ADAP.SARADAP_LEVL_CODE = 'UG' AND ADAP.SARADAP_COLL_CODE_1 = 'PS' then 535
        when ADAP.SARADAP_LEVL_CODE = 'GR' and RBRAPBG_PBGP_CODE LIKE 'GR%' then 710
        when ADAP.SARADAP_LEVL_CODE = 'PL' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 710
        when ADAP.SARADAP_LEVL_CODE = 'PM' and RBRAPBG_PBGP_CODE LIKE 'PR%' then 125           
     END  amt
FROM RBRAPBG, (SELECT SGBSTDN_PIDM, SGBSTDN_LEVL_CODE,SGBSTDN_COLL_CODE_1, SGBSTDN_MAJR_CODE_1, SGBSTDN_CAMP_CODE 
                  FROM SGBSTDN
                  WHERE SGBSTDN_TERM_CODE_EFF = (SELECT MAX (B.SGBSTDN_TERM_CODE_EFF) 
                                                FROM SGBSTDN B
                                               WHERE SGBSTDN_PIDM = SGBSTDN_PIDM
                                               AND B.SGBSTDN_TERM_CODE_EFF <= :PERIOD))STDN,

(SELECT SARADAP_PIDM, SARADAP_LEVL_CODE, SARADAP_COLL_CODE_1, SARADAP_MAJR_CODE_1, SARADAP_CAMP_CODE
                    FROM SARADAP
                    WHERE SARADAP_TERM_CODE_ENTRY = (SELECT MAX (B.SARADAP_TERM_CODE_ENTRY)
                                          FROM SARADAP B, ROBINST
                                          WHERE SARADAP_PIDM = B.SARADAP_PIDM
                                          AND ROBINST_AIDY_CODE = :AIDY
                                          AND B.SARADAP_TERM_CODE_ENTRY <= ROBINST_CURRENT_TERM_CODE))ADAP
WHERE STDN.SGBSTDN_PIDM(+) = RBRAPBG_PIDM
AND ADAP.SARADAP_PIDM(+) = RBRAPBG_PIDM
AND RBRAPBG_AIDY_CODE = :AIDY                       
AND RBRAPBG_PIDM    = :PIDM
--;