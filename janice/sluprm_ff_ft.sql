select is_sluprm, count(distinct bid) from (
select spriden_id as bid,
    case when spriden_pidm in (
        SELECT DISTINCT A.RORSTAT_PIDM
        FROM RORSTAT A, ROBINST R, RORPRST B, SARADAP D, RCRAPP1 R1, 
            RCRAPP2 R2, RCRAPP3 R3,RCRAPP4 R4, RCVEDEA RC, RORPRST RP
        WHERE R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
        AND A.RORSTAT_AIDY_CODE = '2526'
        -- AND A.RORSTAT_PIDM = :PIDM    
        AND B.RORPRST_PIDM = A.RORSTAT_PIDM
        AND D.SARADAP_PIDM = A.RORSTAT_PIDM
        AND R1.RCRAPP1_PIDM = A.RORSTAT_PIDM 
        AND R1.RCRAPP1_AIDY_CODE = A.RORSTAT_AIDY_CODE

        AND R2.RCRAPP2_PIDM = R1.RCRAPP1_PIDM 
        AND R2.RCRAPP2_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND R2.RCRAPP2_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND R2.RCRAPP2_SEQ_NO = R1.RCRAPP1_SEQ_NO

        AND R3.RCRAPP3_PIDM = R1.RCRAPP1_PIDM 
        AND R3.RCRAPP3_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND R3.RCRAPP3_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND R3.RCRAPP3_SEQ_NO = R1.RCRAPP1_SEQ_NO   

        AND R4.RCRAPP4_PIDM = R1.RCRAPP1_PIDM 
        AND R4.RCRAPP4_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND R4.RCRAPP4_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND R4.RCRAPP4_SEQ_NO = R1.RCRAPP1_SEQ_NO

        AND RC.RCVEDEA_PIDM = R1.RCRAPP1_PIDM 
        AND RC.RCVEDEA_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND RC.RCVEDEA_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND RC.RCVEDEA_SEQ_NO = R1.RCRAPP1_SEQ_NO

        AND RP.RORPRST_PIDM = A.RORSTAT_PIDM(+)
        AND RP.RORPRST_PERIOD = D.SARADAP_TERM_CODE_ENTRY(+)
        AND (RP.RORPRST_XHS NOT IN (1,3) OR RP.RORPRST_XHS IS NULL)
        AND R1.RCRAPP1_CURR_REC_IND = 'Y'
        AND R1.RCRAPP1_INFC_CODE = 'EDE'
        AND R1.RCRAPP1_DEGREE_BY_JULY = 2
        AND R3.RCRAPP3_OFFL_UNOFFL_IND = 1
        AND D.SARADAP_STYP_CODE IN ('F', '1')
        and (
            select sorhsch_gpa
            from (
            select g.*,
                    row_number() over (
                    partition by g.sorhsch_pidm
                    order by g.sorhsch_graduation_date desc nulls last,
                                g.sorhsch_activity_date desc,
                                g.sorhsch_sbgi_code
                    ) as rn
            from sorhsch g
            where g.sorhsch_pidm = rorstat_pidm
            )
            where rn = 1
        ) >= '3.0'
        AND D.SARADAP_TERM_CODE_ENTRY = (
            SELECT MAX(Z.SARADAP_TERM_CODE_ENTRY)
            FROM SARADAP Z
            WHERE Z.SARADAP_PIDM = D.SARADAP_PIDM
            AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') 
                AND (R.ROBINST_AIDY_END_YEAR || '20')
        )
        AND NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0) <= 60000
        AND CASE -- AGI/INCOME < 60,000
            WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
                THEN NVL(NVL(RC.RCVEDEA_FTI_PAR_AGI, R1.RCRAPP1_PAR_US_INC), 0)
                + NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0)
            WHEN R2.RCRAPP2_MODEL_CDE = 'I'
                THEN NVL(NVL(RC.RCVEDEA_FTI_AGI, R1.RCRAPP1_US_INC), 0) 
                + NVL(NVL(RC.RCVEDEA_FTI_SPS_AGI, RC.RCVEDEA_SPS_US_INC), 0)
        END <= 60000
        AND CASE -- CASH/INVESTMENT/ASSETS < 50,000
            WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
                THEN (
                    NVL(R1.RCRAPP1_PAR_CASH_AMT, 0) 
                    + NVL(R4.RCRAPP4_PAR_INV_NET_WORTH, 0) 
                    + NVL(R4.RCRAPP4_PAR_BUS_NET_WORTH, 0)
                )
            WHEN R2.RCRAPP2_MODEL_CDE = 'I'
                THEN (
                    NVL(R1.RCRAPP1_CASH_AMT, 0) 
                    + NVL(R4.RCRAPP4_INV_NET_WORTH, 0) 
                    + NVL(R4.RCRAPP4_BUS_NET_WORTH, 0)
                )
        END <= 50000
    ) then 'Y' else 'N' end as is_sluprm,
    case when exists (
        select 1
        from tbraccd 
        join tbbdetc on tbbdetc_detail_code = tbraccd_detail_code
            and tbbdetc_type_ind = 'C'
            and tbbdetc_dcat_code = 'HOU'
        where tbraccd_pidm = rorstat_pidm
        and tbraccd_detail_code not in ('RLAF', 'HCBF', 'HCBS')
        and tbraccd_term_code = '202610'
        group by tbraccd_pidm, tbraccd_term_code
        having sum(tbraccd_amount) > 0
    ) then 'Y' else 'N' end as has_hou_charges
from rorstat
join spriden on spriden_pidm = rorstat_pidm and spriden_change_ind is null
where rorstat_aidy_code = '2526'
) group by is_sluprm
;

SELECT DISTINCT A.RORSTAT_PIDM
        FROM RORSTAT A, ROBINST R, RORPRST B, SARADAP D, RCRAPP1 R1, 
            RCRAPP2 R2, RCRAPP3 R3,RCRAPP4 R4, RCVEDEA RC, RORPRST RP
        WHERE R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
        AND A.RORSTAT_AIDY_CODE = '2627'
        -- AND A.RORSTAT_PIDM = :PIDM    
        AND B.RORPRST_PIDM = A.RORSTAT_PIDM
        AND D.SARADAP_PIDM = A.RORSTAT_PIDM
        AND R1.RCRAPP1_PIDM = A.RORSTAT_PIDM 
        AND R1.RCRAPP1_AIDY_CODE = A.RORSTAT_AIDY_CODE

        AND R2.RCRAPP2_PIDM = R1.RCRAPP1_PIDM 
        AND R2.RCRAPP2_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND R2.RCRAPP2_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND R2.RCRAPP2_SEQ_NO = R1.RCRAPP1_SEQ_NO

        AND R3.RCRAPP3_PIDM = R1.RCRAPP1_PIDM 
        AND R3.RCRAPP3_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND R3.RCRAPP3_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND R3.RCRAPP3_SEQ_NO = R1.RCRAPP1_SEQ_NO   

        AND R4.RCRAPP4_PIDM = R1.RCRAPP1_PIDM 
        AND R4.RCRAPP4_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND R4.RCRAPP4_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND R4.RCRAPP4_SEQ_NO = R1.RCRAPP1_SEQ_NO

        AND RC.RCVEDEA_PIDM = R1.RCRAPP1_PIDM 
        AND RC.RCVEDEA_INFC_CODE = R1.RCRAPP1_INFC_CODE
        AND RC.RCVEDEA_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
        AND RC.RCVEDEA_SEQ_NO = R1.RCRAPP1_SEQ_NO

        AND RP.RORPRST_PIDM = A.RORSTAT_PIDM(+)
        AND RP.RORPRST_PERIOD = D.SARADAP_TERM_CODE_ENTRY(+)
        AND (RP.RORPRST_XHS NOT IN (1,3) OR RP.RORPRST_XHS IS NULL)
        AND R1.RCRAPP1_CURR_REC_IND = 'Y'
        AND R1.RCRAPP1_INFC_CODE = 'EDE'
        AND R1.RCRAPP1_DEGREE_BY_JULY = 2
        AND R3.RCRAPP3_OFFL_UNOFFL_IND = 1
        AND D.SARADAP_STYP_CODE IN ('F', '1')
        -- AND G.SHRLGPA_GPA >= '3.0'
        and (
            select sorhsch_gpa
            from (
            select g.*,
                    row_number() over (
                    partition by g.sorhsch_pidm
                    order by g.sorhsch_graduation_date desc nulls last,
                                g.sorhsch_activity_date desc,
                                g.sorhsch_sbgi_code
                    ) as rn
            from sorhsch g
            where g.sorhsch_pidm = rorstat_pidm
            )
            where rn = 1
        ) >= '3.0'
        AND D.SARADAP_TERM_CODE_ENTRY = (
            SELECT MAX(Z.SARADAP_TERM_CODE_ENTRY)
            FROM SARADAP Z
            WHERE Z.SARADAP_PIDM = D.SARADAP_PIDM
            AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') 
                AND (R.ROBINST_AIDY_END_YEAR || '20')
        )
        AND NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0) <= 60000
        AND CASE -- AGI/INCOME < 60,000
            WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
                THEN NVL(NVL(RC.RCVEDEA_FTI_PAR_AGI, R1.RCRAPP1_PAR_US_INC), 0)
                + NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0)
            WHEN R2.RCRAPP2_MODEL_CDE = 'I'
                THEN NVL(NVL(RC.RCVEDEA_FTI_AGI, R1.RCRAPP1_US_INC), 0) 
                + NVL(NVL(RC.RCVEDEA_FTI_SPS_AGI, RC.RCVEDEA_SPS_US_INC), 0)
        END <= 60000
        AND CASE -- CASH/INVESTMENT/ASSETS < 50,000
            WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
                THEN (
                    NVL(R1.RCRAPP1_PAR_CASH_AMT, 0) 
                    + NVL(R4.RCRAPP4_PAR_INV_NET_WORTH, 0) 
                    + NVL(R4.RCRAPP4_PAR_BUS_NET_WORTH, 0)
                )
            WHEN R2.RCRAPP2_MODEL_CDE = 'I'
                THEN (
                    NVL(R1.RCRAPP1_CASH_AMT, 0) 
                    + NVL(R4.RCRAPP4_INV_NET_WORTH, 0) 
                    + NVL(R4.RCRAPP4_BUS_NET_WORTH, 0)
                )
        END <= 50000

;
SELECT DISTINCT A.RORSTAT_PIDM
FROM RORSTAT A, ROBINST R, RORPRST B, ROBNYUD C, SARADAP D, RCRAPP1 R1, 
    RCRAPP2 R2, RCRAPP3 R3,RCRAPP4 R4, RCVEDEA RC, RORPRST RP
WHERE R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
AND A.RORSTAT_AIDY_CODE = :AIDY     
-- AND A.RORSTAT_PIDM = :PIDM     
AND B.RORPRST_PIDM = A.RORSTAT_PIDM
AND C.ROBNYUD_PIDM = A.RORSTAT_PIDM
AND D.SARADAP_PIDM = A.RORSTAT_PIDM
AND R1.RCRAPP1_PIDM = A.RORSTAT_PIDM 
AND R1.RCRAPP1_AIDY_CODE = A.RORSTAT_AIDY_CODE
AND R2.RCRAPP2_PIDM = R1.RCRAPP1_PIDM 
AND R2.RCRAPP2_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND R2.RCRAPP2_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND R2.RCRAPP2_SEQ_NO = R1.RCRAPP1_SEQ_NO
AND R3.RCRAPP3_PIDM = R1.RCRAPP1_PIDM 
AND R3.RCRAPP3_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND R3.RCRAPP3_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND R3.RCRAPP3_SEQ_NO = R1.RCRAPP1_SEQ_NO   
AND R4.RCRAPP4_PIDM = R1.RCRAPP1_PIDM 
AND R4.RCRAPP4_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND R4.RCRAPP4_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND R4.RCRAPP4_SEQ_NO = R1.RCRAPP1_SEQ_NO
AND RC.RCVEDEA_PIDM = R1.RCRAPP1_PIDM 
AND RC.RCVEDEA_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND RC.RCVEDEA_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND RC.RCVEDEA_SEQ_NO = R1.RCRAPP1_SEQ_NO
AND RP.RORPRST_PIDM = A.RORSTAT_PIDM(+)
AND RP.RORPRST_PERIOD = D.SARADAP_TERM_CODE_ENTRY(+)
AND (RP.RORPRST_XHS NOT IN (1,3) OR RP.RORPRST_XHS IS NULL)
AND R1.RCRAPP1_CURR_REC_IND = 'Y'
AND R1.RCRAPP1_INFC_CODE = 'EDE'
AND R1.RCRAPP1_DEGREE_BY_JULY = 2
AND R3.RCRAPP3_OFFL_UNOFFL_IND = 1
AND D.SARADAP_STYP_CODE IN ('F', '1')
AND C.ROBNYUD_VALUE_29 >= '3.0'
AND D.SARADAP_TERM_CODE_ENTRY = (
    SELECT MAX(Z.SARADAP_TERM_CODE_ENTRY)
    FROM SARADAP Z
    WHERE Z.SARADAP_PIDM = D.SARADAP_PIDM
    AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') 
        AND (R.ROBINST_AIDY_END_YEAR || '20')
)
AND NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0) <= 60000
AND CASE -- AGI/INCOME < 60,000
    WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
        THEN NVL(NVL(RC.RCVEDEA_FTI_PAR_AGI, R1.RCRAPP1_PAR_US_INC), 0)
           + NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0)
    WHEN R2.RCRAPP2_MODEL_CDE = 'I'
        THEN NVL(NVL(RC.RCVEDEA_FTI_AGI, R1.RCRAPP1_US_INC), 0) 
           + NVL(NVL(RC.RCVEDEA_FTI_SPS_AGI, RC.RCVEDEA_SPS_US_INC), 0)
END <= 60000
AND CASE -- CASH/INVESTMENT/ASSETS < 50,000
    WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
        THEN (
            NVL(R1.RCRAPP1_PAR_CASH_AMT, 0) 
            + NVL(R4.RCRAPP4_PAR_INV_NET_WORTH, 0) 
            + NVL(R4.RCRAPP4_PAR_BUS_NET_WORTH, 0)
        )
    WHEN R2.RCRAPP2_MODEL_CDE = 'I'
        THEN (
            NVL(R1.RCRAPP1_CASH_AMT, 0) 
            + NVL(R4.RCRAPP4_INV_NET_WORTH, 0) 
            + NVL(R4.RCRAPP4_BUS_NET_WORTH, 0)
        )
END <= 50000
;

select * from robnyud where ROBNYUD_VALUE_29 >= '3.0' and robnyud_pidm = (select spriden_pidm from spriden where spriden_id = '001287789' and spriden_change_ind is null);

select * from shrlgpa; 

SELECT DISTINCT A.RORSTAT_PIDM
FROM RORSTAT A, ROBINST R, RORPRST B, SARADAP D, RCRAPP1 R1, 
    RCRAPP2 R2, RCRAPP3 R3,RCRAPP4 R4, RCVEDEA RC, RORPRST RP
WHERE R.ROBINST_AIDY_CODE = A.RORSTAT_AIDY_CODE
AND A.RORSTAT_AIDY_CODE = :AIDY     
-- AND A.RORSTAT_PIDM = :PIDM     
AND B.RORPRST_PIDM = A.RORSTAT_PIDM
-- AND C.ROBNYUD_PIDM = A.RORSTAT_PIDM
AND D.SARADAP_PIDM = A.RORSTAT_PIDM
AND R1.RCRAPP1_PIDM = A.RORSTAT_PIDM 
AND R1.RCRAPP1_AIDY_CODE = A.RORSTAT_AIDY_CODE
AND R2.RCRAPP2_PIDM = R1.RCRAPP1_PIDM 
AND R2.RCRAPP2_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND R2.RCRAPP2_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND R2.RCRAPP2_SEQ_NO = R1.RCRAPP1_SEQ_NO
AND R3.RCRAPP3_PIDM = R1.RCRAPP1_PIDM 
AND R3.RCRAPP3_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND R3.RCRAPP3_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND R3.RCRAPP3_SEQ_NO = R1.RCRAPP1_SEQ_NO   
AND R4.RCRAPP4_PIDM = R1.RCRAPP1_PIDM 
AND R4.RCRAPP4_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND R4.RCRAPP4_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND R4.RCRAPP4_SEQ_NO = R1.RCRAPP1_SEQ_NO
AND RC.RCVEDEA_PIDM = R1.RCRAPP1_PIDM 
AND RC.RCVEDEA_INFC_CODE = R1.RCRAPP1_INFC_CODE
AND RC.RCVEDEA_AIDY_CODE = R1.RCRAPP1_AIDY_CODE
AND RC.RCVEDEA_SEQ_NO = R1.RCRAPP1_SEQ_NO
AND RP.RORPRST_PIDM = A.RORSTAT_PIDM(+)
AND RP.RORPRST_PERIOD = D.SARADAP_TERM_CODE_ENTRY(+)
AND (RP.RORPRST_XHS NOT IN (1,3) OR RP.RORPRST_XHS IS NULL)
AND R1.RCRAPP1_CURR_REC_IND = 'Y'
AND R1.RCRAPP1_INFC_CODE = 'EDE'
AND R1.RCRAPP1_DEGREE_BY_JULY = 2
AND R3.RCRAPP3_OFFL_UNOFFL_IND = 1
AND D.SARADAP_STYP_CODE IN ('F', '1')
-- AND C.ROBNYUD_VALUE_29 >= '3.0'
and (
    select sorhsch_gpa
    from (
    select g.*,
            row_number() over (
            partition by g.sorhsch_pidm
            order by g.sorhsch_graduation_date desc nulls last,
                        g.sorhsch_activity_date desc,
                        g.sorhsch_sbgi_code
            ) as rn
    from sorhsch g
    where g.sorhsch_pidm = rorstat_pidm
    )
    where rn = 1
) >= '3.0'
AND D.SARADAP_TERM_CODE_ENTRY = (
    SELECT MAX(Z.SARADAP_TERM_CODE_ENTRY)
    FROM SARADAP Z
    WHERE Z.SARADAP_PIDM = D.SARADAP_PIDM
    AND Z.SARADAP_TERM_CODE_ENTRY BETWEEN (R.ROBINST_AIDY_END_YEAR || '00') 
        AND (R.ROBINST_AIDY_END_YEAR || '20')
)
AND NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0) <= 60000
AND CASE -- AGI/INCOME < 60,000
    WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
        THEN NVL(NVL(RC.RCVEDEA_FTI_PAR_AGI, R1.RCRAPP1_PAR_US_INC), 0)
           + NVL(NVL(RC.RCVEDEA_FTI_PSP_AGI, RC.RCVEDEA_PSP_US_INC), 0)
    WHEN R2.RCRAPP2_MODEL_CDE = 'I'
        THEN NVL(NVL(RC.RCVEDEA_FTI_AGI, R1.RCRAPP1_US_INC), 0) 
           + NVL(NVL(RC.RCVEDEA_FTI_SPS_AGI, RC.RCVEDEA_SPS_US_INC), 0)
END <= 60000
AND CASE -- CASH/INVESTMENT/ASSETS < 50,000
    WHEN R2.RCRAPP2_MODEL_CDE = 'D' 
        THEN (
            NVL(R1.RCRAPP1_PAR_CASH_AMT, 0) 
            + NVL(R4.RCRAPP4_PAR_INV_NET_WORTH, 0) 
            + NVL(R4.RCRAPP4_PAR_BUS_NET_WORTH, 0)
        )
    WHEN R2.RCRAPP2_MODEL_CDE = 'I'
        THEN (
            NVL(R1.RCRAPP1_CASH_AMT, 0) 
            + NVL(R4.RCRAPP4_INV_NET_WORTH, 0) 
            + NVL(R4.RCRAPP4_BUS_NET_WORTH, 0)
        )
END <= 50000;

select distinct sorhsch_pidm
from sorhsch g
where g.sorhsch_activity_date = (
    select max(z.sorhsch_activity_date) from sorhsch z
    where z.sorhsch_pidm = g.sorhsch_pidm
)

;
select distinct sorhsch_pidm
from sorhsch g
where g.sorhsch_activity_date = (
    select max(z.sorhsch_activity_date) from sorhsch z
    where z.sorhsch_pidm = g.sorhsch_pidm
); 

select sorhsch_gpa
from (
  select g.*,
         row_number() over (
           partition by g.sorhsch_pidm
           order by g.sorhsch_graduation_date desc nulls last,
                    g.sorhsch_activity_date desc,
                    g.sorhsch_sbgi_code
         ) as rn
  from sorhsch g
)
where rn = 1
;

select sorhsch_pidm,
       max(sorhsch_sbgi_code) keep (dense_rank first
           order by sorhsch_graduation_date desc nulls last,
                    sorhsch_activity_date desc) as sbgi_code
from sorhsch
group by sorhsch_pidm;