CREATE OR REPLACE PACKAGE rnkneed  AS
--AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : RNKNEED
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Wed Jul 30 12:16:15 2014
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
--
-- FILE NAME..: rnkneed.sql
-- RELEASE....: 8.37.1
-- OBJECT NAME: rnkneed
-- PRODUCT....: FINAID
-- USAGE......: Package to calculate various Financial Aid need amounts.
-- COPYRIGHT..: Copyright 2003-2019 Ellucian Company L.P. and its affiliates.
--
-- DESCRIPTION:
--
-- This Package contains Functions required to calculate various need
-- amounts in Financial Aid.
--
-- Functions:
--
--  f_calc_act_reduce_need_amt  - Function to calculate the actual reduce need amount.
--
--  f_calc_act_replace_efc_amt  - Function to calculate the actual replace EFC amount.
--
--  f_calc_budget_amt           - Function returns the f_calc_non_pell_budget_amt.
--                                If null, it returns the f_calc_pell_budget_amt.
--
--  f_calc_contract_payment     - Function to return contract payment amount.
--
--  f_calc_contracts            - Function to calculate the total contract amount.
--
--  f_calc_direct_cost_amt      - Function to calculate the sum of direct cost
--                                components by budget type.
--  f_calc_efc                  - Function to calculate the efc amount.
--
--  f_calc_excess_efc_amt       - Function to calculate the excess EFC amount.
--
--  f_calc_exemption_payment    - Function to return exemption payment amount.
--
--  f_calc_exemptions           - Function to calculate the total exemption amount.
--
--  f_calc_gross_need           - Function to calculate the gross need amount.
--
--  f_calc_im_efc               - Function to calculate the IM EFC amount.
--
--  f_calc_im_efc_amt           - Function to calculate the IM EFC amount.
--
--  f_calc_im_excess_efc_amt    - Function to calculate the excess IM EFC amount.
--
--  f_calc_im_gross_need        - Function to calculate the IM gross need amount.
--
--  f_calc_im_unmet_need        - Function to calculate the IM unmet need amount.
--
--  f_calc_load                 - Function to calculate the find the expected enrollment
--                                status.
--
--  f_calc_non_pell_budget_amt  - Function to calculate the non-pell budget amount.
--
--  f_calc_offer_amt            - Function to calculate the offer amount.
--
--  f_calc_oth_resource         - Function to calculate the total other resource amount.
--
--  f_calc_pell_award           - Function to calculate the PELL award.
--
--  f_calc_pell_budget_amt      - Function to calculate the pell budget amount.
--
--  f_calc_pell_efc             - Function to return the Pell EFC.
--
--  f_calc_pell_lt_half_coa     - Function to calculate the pell less than half-time
--                                budget amount.
--
--  f_calc_resource             - Function to calculate the resource amount.
--
--  f_calc_sim_reduce_need_amt  - Function to calculate the simulated reduce need amount.
--
--  f_calc_sim_replace_efc_amt  - Function to calculate the simulated replace EFC amount.
--
--  f_calc_unmet_need           - Function to calculate the unmet need amount.
--
--  f_calc_year_contracts       - Function to calculate the total contract amount
--                                for an aid year for use in RPAARSC
--
--  f_calc_year_exemptions      - Function to calculate the total exemption amount
--                                for an aid year for use in RPAARSC
--
--  f_calc_year_oth_resource    - Function to calculate the total other resource amount
--                                for an aid year for use in RPAARSC
--
--  f_find_efc_ind              - Function to retrieve the efc indicator.
--
--  f_get_need_data             - Function to calculate all information included
--                                in the need view (RNVAND0 amd RNVSND0).
--
--  f_calc_period_pell3_budget_amt - Function to return the budget amount for a specific period.                        -- 83701-1
--
--  f_calc_pell3_lt_half_coa     - Function to calculate the pell 3 less than half-time                                 -- 83701-1
--                                budget amount for a specific period.                                                  -- 83701-1
--
--  f_calc_component_prorated_amt - Function to  return a prorated individual component                                 -- 83701-2
--                                  amount for a period.                                                                -- 83701-2
--
--  f_calc_prorated_period_rnd    - Function to return a rounded prorated budget for a period.                          -- 83701-3
--
--  f_calc_prorated_period_no_rnd - Function to return an unrounded prorated budget for a period.                       -- 83701-3
--
--  f_calc_lth_prort_period_no_rnd - Function to  return an unrounded less than half time                               -- 83701-4
--                                   prorated budget for a period.                                                      -- 83701-4
--
--  f_calc_period_pell_budget_pct  - Function to return the total Pell percent for an Aid Year Budget                   -- 83701-5
--
--  f_calc_pell_ftfy_budget_amt    - Function to return the Full Time Full Year Aid (FTFY) Year Budget                  -- 83701-5
--
-- Procedures:
--
--  p_get_budget_group_data     - Procedure to return budget group and multi-group indicator.
--
--  p_get_crossover_data        - Procedure to return crossover pell award and crossover
--                                aid year for use in awarding forms.
--
--  p_get_need_summary          - Procedure to return the data necessary to populate the Summary
--                                tabs on forms.
--
-- DESCRIPTION END

  SUBTYPE total_amount_type          IS NUMBER;                                                                         -- 81200-1
  SUBTYPE large_amount_type          IS NUMBER(17,2);                                                                   -- 81801-1
  SUBTYPE efc_type                   IS NUMBER(10);                                                                     -- 81802-2
  SUBTYPE amount_type                IS NUMBER(11,2);                                                                   -- 81401-1
  SUBTYPE indicator_type             IS VARCHAR2(1);                                                                    -- 81401-1

  TYPE NeedRecType IS RECORD                                                                                            -- 81401-1
            ( budget_amount             rptneed.rptneed_budget_amount%TYPE,                                             -- 81802-2
              resource_amount           rptneed.rptneed_resource_amount%TYPE,                                           -- 81802-2
              replace_efc_amt           rptneed.rptneed_replace_efc_amt%TYPE,                                           -- 81802-2
              reduce_need_amt           rptneed.rptneed_reduce_need_amt%TYPE,                                           -- 81802-2
              efc_ind                   indicator_type,                                                                 -- 81401-1
              fm_budget_amount          rptneed.rptneed_budget_amount%TYPE,                                             -- 81802-2
              fm_efc_amt                rptneed.rptneed_fm_efc_amt%TYPE,                                                -- 81401-1
              fm_gross_need             rptneed.rptneed_gross_need_amt%TYPE,                                            -- 81802-2
              fm_excess_efc_amt         rptneed.rptneed_excess_efc_amt%TYPE,                                            -- 81802-2
              fm_unmet_need             rptneed.rptneed_unmet_need_amt%TYPE,                                            -- 81802-2
              im_budget_amount          rptneed.rptneed_budget_amount%TYPE,                                             -- 81802-2
              im_efc_amt                rptneed.rptneed_im_efc_amt%TYPE,                                                -- 81401-1
              im_gross_need             rptneed.rptneed_im_gross_need_amt%TYPE,                                         -- 81802-2
              im_excess_efc_amt         rptneed.rptneed_im_excess_efc_amt%TYPE,                                         -- 81802-2
              im_unmet_need             rptneed.rptneed_im_unmet_need_amt%TYPE,                                         -- 81802-2
              offer_amt                 large_amount_type,                                                              -- 81801-1
              pell_award                amount_type                                                                     -- 81401-1
            );                                                                                                          -- 81401-1

FUNCTION f_calc_pell_efc                                                                                                -- 81401-1
           ( p_pidm                     rcrapp2.rcrapp2_pidm%TYPE,                                                      -- 81401-1
             p_aidy_code                rcrapp2.rcrapp2_aidy_code%TYPE                                                  -- 81401-1
           ) RETURN efc_type ;                                                                                          -- 81401-1

FUNCTION f_calc_pell_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run                -- 81401-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 81200-1

FUNCTION f_calc_pell_ftfy_budget_amt                                                                                    -- 83701-5
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,                                                      -- 83701-5
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,                                                 -- 83701-5
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run                -- 83701-5
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 83701-5

FUNCTION f_calc_pell_lt_half_coa
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 81200-1

FUNCTION f_calc_non_pell_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 81200-1
PRAGMA RESTRICT_REFERENCES(f_calc_non_pell_budget_amt, WNDS, WNPS, RNPS);

FUNCTION f_calc_period_budget_amt                                                                                       -- 81401-1
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,                                                      -- 81401-1
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,                                                 -- 81401-1
             p_type_ind                 indicator_type                DEFAULT 'F',                                      -- 81401-1
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 81401-1

FUNCTION f_calc_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_type_ind                 indicator_type                DEFAULT 'F',                                      -- 81401-1
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 81200-1

FUNCTION f_calc_direct_cost_amt                                                                                         -- 81401-1
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,                                                      -- 81401-1
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,                                                 -- 81401-1
             p_type_ind                 indicator_type                DEFAULT 'F',                                      -- 81401-1
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN rptneed.rptneed_fm_direct_cost_amt%TYPE ;                                                           -- 81401-1

FUNCTION f_find_efc_ind
           ( p_pidm                     rbbabud.rbbabud_pidm%TYPE,
             p_aidy_code                rbbabud.rbbabud_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN indicator_type ;

FUNCTION f_calc_efc
           ( p_pidm                      rcrapp4.rcrapp4_pidm%TYPE,
             p_aidy_code                 rcrapp4.rcrapp4_aidy_code%TYPE
           ) RETURN rptneed.rptneed_efc_amt%TYPE ;                                                                      -- 81200-1

FUNCTION f_calc_im_efc
           ( p_pidm                     rcrapp2.rcrapp2_pidm%TYPE,
             p_aidy_code                rcrapp2.rcrapp2_aidy_code%TYPE
           ) RETURN rptneed.rptneed_im_efc_amt%TYPE ;                                                                   -- 81200-1

FUNCTION f_calc_oth_resource
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,                                                      -- 6300-1
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE                                                  -- 6300-1
           ) RETURN NUMBER ;                                                                                            -- 6300-1
PRAGMA RESTRICT_REFERENCES(f_calc_oth_resource, WNDS, WNPS, RNPS);                                                      -- 6300-1

FUNCTION f_calc_exemptions
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,                                                      -- 6300-1
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,                                                 -- 6300-1
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE                                          -- 6300-1
           ) RETURN NUMBER ;                                                                                            -- 6300-1
PRAGMA RESTRICT_REFERENCES(f_calc_exemptions, WNDS, WNPS, RNPS);                                                        -- 6300-1

FUNCTION f_calc_contracts
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,                                                      -- 6300-1
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,                                                 -- 6300-1
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE                                          -- 6300-1
           ) RETURN NUMBER ;                                                                                            -- 6300-1
PRAGMA RESTRICT_REFERENCES(f_calc_contracts, WNDS, WNPS, RNPS);                                                         -- 6300-1

FUNCTION f_calc_load
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,                                                      -- 6300-1
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE                                                  -- 6300-1
           ) RETURN VARCHAR2 ;                                                                                          -- 6300-1

FUNCTION f_calc_resource
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE
           ) RETURN rptneed.rptneed_resource_amount%TYPE ;                                                              -- 81200-1
PRAGMA RESTRICT_REFERENCES(f_calc_resource, WNDS, WNPS, RNPS);

FUNCTION f_calc_act_reduce_need_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(f_calc_act_reduce_need_amt, WNDS, WNPS, RNPS);

FUNCTION f_calc_sim_reduce_need_amt
           ( p_pidm                     rptawrd.rptawrd_pidm%TYPE,
             p_aidy_code                rptawrd.rptawrd_aidy_code%TYPE
           ) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(f_calc_sim_reduce_need_amt, WNDS, WNPS, RNPS);

FUNCTION f_calc_act_replace_efc_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(f_calc_act_replace_efc_amt, WNDS, WNPS, RNPS);

FUNCTION f_calc_sim_replace_efc_amt
           ( p_pidm                    rptawrd.rptawrd_pidm%TYPE,
             p_aidy_code               rptawrd.rptawrd_aidy_code%TYPE
           ) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(f_calc_sim_replace_efc_amt, WNDS, WNPS, RNPS);

FUNCTION f_calc_pell_award
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(f_calc_pell_award, WNDS, WNPS, RNPS);

FUNCTION f_calc_exemption_payment
           ( p_pidm                     tbraccd.tbraccd_pidm%TYPE,
             p_exemption_code           tbraccd.tbraccd_crossref_number%TYPE,
             p_term_code                tbraccd.tbraccd_term_code%TYPE
           ) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(f_calc_exemption_payment, WNDS, WNPS, RNPS);

FUNCTION f_calc_contract_payment
           ( p_pidm                     tbraccd.tbraccd_pidm%TYPE,
             p_contract_pidm            tbraccd.tbraccd_crossref_pidm%TYPE,
             p_contract_number          tbraccd.tbraccd_crossref_number%TYPE,
             p_term_code                tbraccd.tbraccd_term_code%TYPE
           ) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(f_calc_contract_payment, WNDS, WNPS, RNPS);

FUNCTION f_calc_excess_efc_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,                                                      --70100-1
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,                                                 --70100-1
             p_calc_type_ind            VARCHAR2                                                                        --70100-1
           ) RETURN NUMBER ;                                                                                            --70100-1
                                                                                                                        --70100-1
FUNCTION f_calc_gross_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,                                                      --70100-1
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE                                                  --70100-1
           ) RETURN NUMBER ;                                                                                            --70100-1

FUNCTION f_calc_im_excess_efc_amt
           ( p_pidm                    rprawrd.rprawrd_pidm%TYPE,                                                       --70100-1
             p_aidy_code               rprawrd.rprawrd_aidy_code%TYPE,                                                  --70100-1
             p_calc_type_ind           VARCHAR2                                                                         --70100-1
           ) RETURN NUMBER ;                                                                                            --70100-1

FUNCTION f_calc_im_gross_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,                                                      --70100-1
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE                                                  --70100-1
           )  RETURN NUMBER ;                                                                                           --70100-1

FUNCTION f_calc_im_unmet_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,                                                      --70100-1
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,                                                 --70100-1
             p_calc_type_ind            VARCHAR2                                                                        --70100-1
           ) RETURN NUMBER ;                                                                                            --70100-1

FUNCTION f_calc_offer_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,                                                      --70100-1
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,                                                 --70100-1
             p_calc_type_ind            VARCHAR2                                                                        --70100-1
           ) RETURN NUMBER ;                                                                                            --70100-1
PRAGMA RESTRICT_REFERENCES(f_calc_offer_amt, WNDS, WNPS, RNPS);                                                         --70100-1

FUNCTION f_calc_unmet_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,                                                      --70100-1
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,                                                 --70100-1
             p_calc_type_ind            VARCHAR2                                                                        --70100-1
           ) RETURN NUMBER ;                                                                                            --70100-1

FUNCTION f_calc_year_oth_resource                                                                                       -- 80900-2
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,                                                      -- 80900-2
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE                                                  -- 80900-2
           ) RETURN NUMBER ;                                                                                            -- 80900-2
PRAGMA RESTRICT_REFERENCES(f_calc_year_oth_resource, WNDS, WNPS, RNPS);                                                 -- 80900-2
                                                                                                                        -- 80900-2
FUNCTION f_calc_year_exemptions                                                                                         -- 80900-2
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,                                                      -- 80900-2
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,                                                 -- 80900-2
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE                                          -- 80900-2
           ) RETURN NUMBER ;                                                                                            -- 80900-2
PRAGMA RESTRICT_REFERENCES(f_calc_year_exemptions, WNDS, WNPS, RNPS);                                                   -- 80900-2
                                                                                                                        -- 80900-2
FUNCTION f_calc_year_contracts                                                                                          -- 80900-2
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,                                                      -- 80900-2
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,                                                 -- 80900-2
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE                                          -- 80900-2
           ) RETURN NUMBER ;                                                                                            -- 80900-2
PRAGMA RESTRICT_REFERENCES(f_calc_year_contracts, WNDS, WNPS, RNPS);                                                    -- 80900-2

FUNCTION f_get_need_data                                                                                                -- 81401-1
            ( p_pidm                    rprawrd.rprawrd_pidm%TYPE,                                                      -- 81401-1
              p_aidy_code               rprawrd.rprawrd_aidy_code%TYPE,                                                 -- 81401-1
              p_calc_type_ind           indicator_type                DEFAULT 'A',                                      -- 81401-1
              p_run_name                rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
            ) RETURN NeedRecType ;                                                                                      -- 81401-1

-- 83701-6 Begin BFASA-7843
FUNCTION f_calc_period_pell3_budget_amt                                                                                 -- 83701-1
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,                                                      -- 83701-1
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,               -- 83701-1
			 p_period                   rbrapbc.rbrapbc_period%TYPE                                                     -- 83701-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 83701-1

FUNCTION f_calc_pell3_lt_half_coa                                                                                       -- 83701-1
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,                                                      -- 83701-1
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN,               -- 83701-1
			 p_period                   rbrapbc.rbrapbc_period%TYPE                                                     -- 83701-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE ;                                                                -- 83701-1
-- 83701-6 End BFASA-7843

FUNCTION f_calc_prorated_period_rnd                                                                                     -- 83701-3
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,                                                      -- 83701-3
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,                                                 -- 83701-3
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,               -- 83701-3
			 p_period                   rbrapbc.rbrapbc_period%TYPE                                                     -- 83701-3
           ) RETURN NUMBER ;                                                                                            -- 83701-3

FUNCTION f_calc_prorated_period_no_rnd                                                                                  -- 83701-3
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,                                                      -- 83701-3
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,                                                 -- 83701-3
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,               -- 83701-3
			 p_period                   rbrapbc.rbrapbc_period%TYPE                                                     -- 83701-3
           ) RETURN NUMBER ;                                                                                            -- 83701-3

FUNCTION f_calc_lth_prort_period_no_rnd                                                                                 -- 83701-4
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,                                                      -- 83701-4
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,                                                 -- 83701-4
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,               -- 83701-4
			 p_period                   rbrapbc.rbrapbc_period%TYPE                                                     -- 83701-4
           ) RETURN NUMBER;                                                                                             -- 83701-4

FUNCTION f_calc_component_prorated_amt                                                                                  -- 83701-2
           ( p_aidy_code                 rbrapbc.rbrapbc_aidy_code%TYPE,                                                -- 83701-2
             p_pidm                      rbrapbc.rbrapbc_pidm%TYPE,                                                     -- 83701-2
             p_pbtp_code                 rbrapbc.rbrapbc_pbtp_code%TYPE,                                                -- 83701-2
             p_pbcp_code                 rbrapbc.rbrapbc_pbcp_code%TYPE,                                                -- 83701-2
			 p_period                    rbrapbc.rbrapbc_period%TYPE                                                    -- 83701-2
           ) RETURN NUMBER ;                                                                                            -- 83701-2

FUNCTION f_calc_period_pell_budget_pct                                                                                  -- 83701-5
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,                                                      -- 83701-5
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,                                                 -- 83701-5
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run                -- 83701-5
           ) RETURN rfrdefa.rfrdefa_pell_award_pct%TYPE;                                                                -- 83701-5

PROCEDURE p_get_budget_group_data                                                                                       -- 81402-1
            ( p_pidm                              rorstat.rorstat_pidm%TYPE,                                            -- 81402-1
              p_aidy_code                         rorstat.rorstat_aidy_code%TYPE,                                       -- 81402-1
              p_budget_group_out          OUT     rorstat.rorstat_bgrp_code%TYPE,                                       -- 81402-1
              p_budget_group_ind_out      OUT     indicator_type                                                        -- 81402-1
            ) ;                                                                                                         -- 81402-1

PROCEDURE p_get_crossover_data                                                                                          -- 80900-2
            ( p_pidm                    rprawrd.rprawrd_pidm%TYPE,                                                      -- 80900-2
              p_aidy_code               rprawrd.rprawrd_aidy_code%TYPE,                                                 -- 80900-2
              p_pell_award_out    OUT   rprawrd.rprawrd_offer_amt%TYPE,                                                 -- 80900-2
              p_aidy_code_out     OUT   rprawrd.rprawrd_aidy_code%TYPE                                                  -- 80900-2
            ) ;                                                                                                         -- 80900-2

PROCEDURE p_get_need_summary                                                                                            -- 81401-1
            ( p_pidm                           rorstat.rorstat_pidm%TYPE,                                               -- 81401-1
              p_aidy_code                      rprawrd.rprawrd_aidy_code%TYPE,                                          -- 81401-1
              p_aprd_code_out             OUT  rorstat.rorstat_aprd_code%TYPE,                                          -- 81401-1
              p_aprd_code_pell_out        OUT  rorstat.rorstat_aprd_code_pell%TYPE,                                     -- 81401-1
              p_offer_amt_out             OUT  large_amount_type,                                                       -- 81801-1
              p_resource_amt_out          OUT  rptneed.rptneed_resource_amount%TYPE,                                    -- 81802-2
              p_crossover_pell_award_out  OUT  amount_type,                                                             -- 81401-1
              p_crossover_aidy_code_out   OUT  rprawrd.rprawrd_aidy_code%TYPE,                                          -- 81401-1
              p_fm_budget_amt_out         OUT  rptneed.rptneed_budget_amount%TYPE,                                      -- 81802-2
              p_fm_efc_out                OUT  rptneed.rptneed_fm_efc_amt%TYPE,                                         -- 81401-1
              p_fm_gross_need_out         OUT  rptneed.rptneed_gross_need_amt%TYPE,                                     -- 81802-2
              p_fm_unmet_need_out         OUT  rptneed.rptneed_unmet_need_amt%TYPE,                                     -- 81802-2
              p_im_budget_amt_out         OUT  rptneed.rptneed_budget_amount%TYPE,                                      -- 81802-2
              p_im_efc_out                OUT  rptneed.rptneed_im_efc_amt%TYPE,                                         -- 81401-1
              p_im_gross_need_out         OUT  rptneed.rptneed_im_gross_need_amt%TYPE,                                  -- 81802-2
              p_im_unmet_need_out         OUT  rptneed.rptneed_im_unmet_need_amt%TYPE,                                  -- 81802-2
              p_pell_budget_amt_out       OUT  rptneed.rptneed_budget_amount%TYPE,                                      -- 81802-2
              p_pell_efc_out              OUT  efc_type,                                                                -- 81401-1
              p_budget_group_out          OUT  rorstat.rorstat_bgrp_code%TYPE,                                          -- 81401-1
              p_budget_group_ind_out      OUT  indicator_type,                                                          -- 81401-1
              p_bbay_awarded_out          OUT  indicator_type                                                           -- 82201-1
            ) ;                                                                                                         -- 81401-1

END rnkneed;
/


CREATE OR REPLACE PACKAGE BODY rnkneed  AS
--AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : RNKNEED1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Tue Oct 21 13:08:23 2014
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
--
-- FILE NAME..: rnkneed1.sql
-- RELEASE....: 8.47.1
-- OBJECT NAME: rnkneed
-- PRODUCT....: FINAID
-- COPYRIGHT..: Copyright 2003-2023 Ellucian Company L.P. and its affiliates.
--

  M_BUDGET_MAX        CONSTANT rptneed.rptneed_budget_amount%TYPE      := 999999999.99;                                 -- 81200-1
  M_RESOURCE_MAX      CONSTANT rptneed.rptneed_resource_amount%TYPE    := 999999999.99;                                 -- 81200-1
  M_LARGE_AMOUNT_MAX  CONSTANT large_amount_type                       := 999999999999999.99;                           -- 81801-1
  M_OLD_FM_EFC_MAX    CONSTANT rptneed.rptneed_fm_efc_amt%TYPE         := 99999;                                        -- 81802-2
  M_NEW_FM_EFC_MAX    CONSTANT rptneed.rptneed_fm_efc_amt%TYPE         := 999999;                                       -- 81802-2
  M_OLD_IM_EFC_MAX    CONSTANT rptneed.rptneed_im_efc_amt%TYPE         := 99999;                                        -- 81802-2
  M_NEW_IM_EFC_MAX    CONSTANT rptneed.rptneed_im_efc_amt%TYPE         := 9999999999;                                   -- 81802-2

  -------------------------------------------------------------------------------------------------

FUNCTION f_calc_exemption_payment
           ( p_pidm                     tbraccd.tbraccd_pidm%TYPE,
             p_exemption_code           tbraccd.tbraccd_crossref_number%TYPE,
             p_term_code                tbraccd.tbraccd_term_code%TYPE
           ) RETURN NUMBER IS

-- define local variables

  exemption_payment_v NUMBER;                                                                                           -- 81200-1

  CURSOR exemption_payment_c IS

  SELECT SUM(TBRACCD_AMOUNT)
    FROM TBRACCD
   WHERE TBRACCD_SRCE_CODE       = 'E'
     AND TBRACCD_PIDM            = p_pidm
     AND TBRACCD_CROSSREF_NUMBER = p_exemption_code
     AND TBRACCD_TERM_CODE       = p_term_code;

BEGIN

  IF NOT exemption_payment_c%ISOPEN THEN
    OPEN exemption_payment_c;
  END IF;

  FETCH exemption_payment_c INTO exemption_payment_v;

  IF exemption_payment_c%NOTFOUND THEN
     exemption_payment_v := NULL;
  END IF;

  CLOSE exemption_payment_c;

  RETURN exemption_payment_v;

END f_calc_exemption_payment;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_contract_payment
           ( p_pidm                     tbraccd.tbraccd_pidm%TYPE,
             p_contract_pidm            tbraccd.tbraccd_crossref_pidm%TYPE,
             p_contract_number          tbraccd.tbraccd_crossref_number%TYPE,
             p_term_code                tbraccd.tbraccd_term_code%TYPE
           ) RETURN NUMBER IS

-- define local variables

  contract_payment_v NUMBER;                                                                                            -- 81200-1

  CURSOR contract_payment_c IS

  SELECT SUM(TBRACCD_AMOUNT)
    FROM TBRACCD
   WHERE TBRACCD_SRCE_CODE       = 'C'
     AND TBRACCD_PIDM            = p_pidm
     AND TBRACCD_CROSSREF_PIDM   = p_contract_pidm
     AND TBRACCD_CROSSREF_NUMBER = p_contract_number
     AND TBRACCD_TERM_CODE       = p_term_code;

BEGIN

  IF NOT contract_payment_c%ISOPEN THEN
    OPEN contract_payment_c;
  END IF;

  FETCH contract_payment_c INTO contract_payment_v;

  IF contract_payment_c%NOTFOUND THEN
     contract_payment_v := NULL;
  END IF;

  CLOSE contract_payment_c;

  RETURN contract_payment_v;

END f_calc_contract_payment;

-------------------------------------------------------------------------------------------------
--  function added for 8.14.1 (Period Budgeting)

FUNCTION f_calc_period_pell_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS

   lv_pell_budget          rptneed.rptneed_budget_amount%TYPE ;
   lv_total                total_amount_type ;

   CURSOR rbrapbc_c IS
     SELECT SUM(rbrapbc_amt)
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_aidy_code     = p_aidy_code
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                       WHERE rbrpbtp_aidy_code = p_aidy_code
                                         AND rbrpbtp_pell_ind  = 'Y')
        AND rbrapbc_period        = robprds_period
        AND robprds_seq_no        = ( SELECT MIN(robprds_seq_no)
                                        FROM robprds,
                                             rbrapbt
                                       WHERE rbrapbt_aidy_code = p_aidy_code
                                         AND rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                     WHERE rbrpbtp_aidy_code = p_aidy_code
                                                                       AND rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

-- Begin 83701-4

   lv_period                   rbrapbc.rbrapbc_period%TYPE;
   lv_period_budget            NUMBER;

   CURSOR tprd_period_c IS
       SELECT rortprd_period
	     FROM rortprd tprd
    LEFT JOIN rorstat stat  ON rorstat_pidm = p_pidm AND rorstat_aidy_code = p_aidy_code
    WHERE rortprd_aidy_code = p_aidy_code AND rortprd_aprd_code = rorstat_aprd_code;

-- END 83701-4
BEGIN

  lv_total := 0;                                                   -- 83701-4
  IF rokpell.f_pell3_exists(p_pidm, p_aidy_code) = 'Y'             -- 83701-4
  THEN                                                             -- 83701-4
     lv_total := 0;                                                -- 83701-4
     OPEN  tprd_period_c;                                          -- 83701-4
     FETCH tprd_period_c INTO lv_period;                           -- 83701-4
	 WHILE tprd_period_c%FOUND LOOP                                -- 83701-4
		SELECT f_calc_prorated_period_no_rnd                       -- 83701-4
             (p_pidm,                                              -- 83701-4
              p_aidy_code,                                         -- 83701-4
			  rb_budget_run.f_actual_run,                          -- 83701-4
              lv_period)                                           -- 83701-4
	      INTO lv_period_budget                                    -- 83701-4
		  FROM DUAL;                                               -- 83701-4
	    lv_total := lv_total + lv_period_budget;                   -- 83701-4
        FETCH tprd_period_c INTO lv_period ;                       -- 83701-4
	 END LOOP;                                                     -- 83701-4
     CLOSE tprd_period_c;                                          -- 83701-4
	 lv_total := ROUND(lv_total,2);                                -- 83701-4
  ELSE                                                             -- 83701-4
     OPEN  rbrapbc_c ;
     FETCH rbrapbc_c INTO lv_total ;
     CLOSE rbrapbc_c ;
  END IF;                                                          -- 83701-4

  IF lv_total IS NULL THEN
      lv_pell_budget := lv_total;
  ELSE
      lv_pell_budget := LEAST(lv_total,M_BUDGET_MAX);
  END IF;

  RETURN lv_pell_budget ;
--
END f_calc_period_pell_budget_amt ;
-- Begin 83701-7
-------------------------------------------------------------------------------------------------
FUNCTION f_calc_period_pell_budget_pct
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run
           ) RETURN rfrdefa.rfrdefa_pell_award_pct%TYPE IS

   lv_pell_percent             rfrdefa.rfrdefa_pell_award_pct%TYPE ;
   lv_total                    rfrdefa.rfrdefa_pell_award_pct%TYPE ;
   lv_period                   rbrapbc.rbrapbc_period%TYPE;
   lv_aprd_code                rortprd.rortprd_aprd_code%TYPE;
   lv_period_budget            NUMBER;

   CURSOR rfrdefa_c IS
       SELECT rfrdefa_pell_award_pct
	     FROM rfrdefa
        WHERE rfrdefa_aidy_code = p_aidy_code
		  AND rfrdefa_aprd_code = lv_aprd_code
		  AND rfrdefa_period    = lv_period;

   CURSOR tprd_period_c IS
       SELECT rortprd_period, rortprd_aprd_code
	     FROM rortprd tprd
    LEFT JOIN rorstat stat  ON rorstat_pidm = p_pidm AND rorstat_aidy_code = p_aidy_code
    WHERE rortprd_aidy_code = p_aidy_code AND rortprd_aprd_code = rorstat_aprd_code;

BEGIN

  lv_total := 0;
  OPEN  tprd_period_c;
  FETCH tprd_period_c INTO lv_period, lv_aprd_code;
  WHILE tprd_period_c%FOUND LOOP
     IF rokpell.f_period_pell_formula_type(lv_period) = '3'
	 THEN
		lv_pell_percent := rokpell.f_pell_3_percent (lv_period);
     ELSE
        OPEN  rfrdefa_c ;
        FETCH rfrdefa_c INTO lv_pell_percent ;
        CLOSE rfrdefa_c ;
     END IF;
	 lv_total := lv_total + lv_pell_percent;
     FETCH tprd_period_c INTO lv_period, lv_aprd_code ;
  END LOOP;
  CLOSE tprd_period_c;
  lv_total := ROUND(lv_total,3);

  RETURN lv_total ;
--
END f_calc_period_pell_budget_pct ;
--End 83701-7
-------------------------------------------------------------------------------------------------
-- function added for 8.37.1 (Pell 3)
-- 83701-1
-- 83701-8 - Modified for BFASA-7843

FUNCTION f_calc_period_pell3_budget_amt
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,
			 p_period                   rbrapbc.rbrapbc_period%TYPE
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS

   lv_pell_budget          rptneed.rptneed_budget_amount%TYPE ;
   lv_total                rptneed.rptneed_budget_amount%TYPE ;

   CURSOR rbrapbc_c IS
     SELECT SUM(rbrapbc_amt)
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                         WHERE rbrpbtp_pell_ind  = 'Y')
        AND rbrapbc_period        = p_period
        AND robprds_seq_no        = ( SELECT robprds_seq_no
                                        FROM robprds,
                                             rbrapbt
                                         WHERE rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
										 AND robprds_period    = p_period
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                       WHERE rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

BEGIN

  OPEN  rbrapbc_c ;
  FETCH rbrapbc_c INTO lv_total ;
  CLOSE rbrapbc_c ;

  IF lv_total IS NULL THEN
      lv_pell_budget := 0;
  ELSE
      lv_pell_budget := LEAST(lv_total,M_BUDGET_MAX);
  END IF;

  RETURN lv_pell_budget ;
--
END f_calc_period_pell3_budget_amt ;

-------------------------------------------------------------------------------------------------
-- function added for 8.37.1 (Pell 3)
-- 83701-2
FUNCTION f_calc_component_prorated_amt
           ( p_aidy_code                 rbrapbc.rbrapbc_aidy_code%TYPE,
             p_pidm                      rbrapbc.rbrapbc_pidm%TYPE,
             p_pbtp_code                 rbrapbc.rbrapbc_pbtp_code%TYPE,
             p_pbcp_code                 rbrapbc.rbrapbc_pbcp_code%TYPE,
			 p_period                    rbrapbc.rbrapbc_period%TYPE
           ) RETURN NUMBER IS

  lv_prorated_amount             NUMBER;

  CURSOR prorated_amount_c IS
       SELECT DECODE (bacyr.robacyr_formula_type, '1', (x.rbrapbc_amt * COALESCE(asch.rfrasch_pell_award_pct, defa.rfrdefa_pell_award_pct) / 100),
                        (DECODE (rokpell.f_get_levl_code(rb_period_term.f_get_student_term(prds.robprds_period),rbrapbc_pidm), NULL,
                                (x.rbrapbc_amt * (COALESCE(prds.robprds_weeks,0) / bacyr.robacyr_weeks)),
                                (x.rbrapbc_amt * (COALESCE(prds.robprds_weeks,0) / racyr.roracyr_weeks)))))
         FROM rbrapbc x
    LEFT JOIN rorstat stat  ON rorstat_pidm = rbrapbc_pidm AND rorstat_aidy_code = rbrapbc_aidy_code
    LEFT JOIN rortprd tprd  ON rortprd_aidy_code = rbrapbc_aidy_code AND rortprd_aprd_code = rorstat_aprd_code AND rortprd_period = rbrapbc_period
    LEFT JOIN robprds prds  ON robprds_period = rortprd_period
    LEFT JOIN robacyr bacyr ON robacyr_acad_year = robprds_acad_year
    LEFT JOIN roracyr racyr ON roracyr_aidy_code = rbrapbc_aidy_code AND roracyr_acad_year = prds.robprds_acad_year AND
                               roracyr_levl_code = rokpell.f_get_levl_code(rb_period_term.f_get_student_term(prds.robprds_period),rbrapbc_pidm)
    LEFT JOIN rfrdefa defa  ON rfrdefa_aidy_code = rbrapbc_aidy_code AND rfrdefa_aprd_code = rortprd_aprd_code AND rfrdefa_period = rbrapbc_period
    LEFT JOIN rfrasch asch  ON rfrasch_aidy_code = rbrapbc_aidy_code AND rfrasch_aprd_code = rortprd_aprd_code AND rfrasch_period = rbrapbc_period AND
                               rfrasch_fund_code = rokpell.f_get_term_pell_fund(rbrapbc_pidm, rbrapbc_period)
        WHERE rbrapbc_aidy_code   = p_aidy_code
          AND rbrapbc_pidm        = p_pidm
          AND rbrapbc_run_name    = rb_budget_run.M_ACTUAL_RUN
          AND rbrapbc_pbtp_code   = p_pbtp_code
          AND rbrapbc_pbcp_code   = p_pbcp_code
		  AND rbrapbc_period      = p_period;

BEGIN

  OPEN  prorated_amount_c;
  FETCH prorated_amount_c INTO lv_prorated_amount ;
  CLOSE prorated_amount_c;

  RETURN lv_prorated_amount ;

END f_calc_component_prorated_amt ;

-- function added for 8.37.1 (Pell 3)
-- 83701-3

FUNCTION f_calc_prorated_period_rnd
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,
			 p_period                   rbrapbc.rbrapbc_period%TYPE
           ) RETURN NUMBER IS

   lv_pell_budget          total_amount_type ;
   lv_total                total_amount_type ;
   lv_prorated_amount      total_amount_type ;
   lv_pbtp_code            rbrapbc.rbrapbc_pbtp_code%TYPE;
   lv_pbcp_code            rbrapbc.rbrapbc_pbcp_code%TYPE;

   CURSOR rbrapbc_c IS
     SELECT rbrapbc_pbtp_code, rbrapbc_pbcp_code
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_aidy_code     = p_aidy_code
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                       WHERE rbrpbtp_aidy_code = p_aidy_code
                                         AND rbrpbtp_pell_ind  = 'Y')
        AND rbrapbc_period        = p_period
        AND robprds_seq_no        = ( SELECT robprds_seq_no
                                        FROM robprds,
                                             rbrapbt
                                       WHERE rbrapbt_aidy_code = p_aidy_code
                                         AND rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
										 AND robprds_period    = p_period
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                     WHERE rbrpbtp_aidy_code = p_aidy_code
                                                                       AND rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

BEGIN

  lv_total := 0;
  OPEN  rbrapbc_c ;
  FETCH rbrapbc_c INTO lv_pbtp_code, lv_pbcp_code ;
  WHILE rbrapbc_c%FOUND LOOP
      SELECT ROUND(f_calc_component_prorated_amt
           ( p_aidy_code, p_pidm, lv_pbtp_code, lv_pbcp_code, p_period ),2)
		INTO lv_prorated_amount
		FROM DUAL;
	  lv_total := lv_total + lv_prorated_amount;
     FETCH rbrapbc_c INTO lv_pbtp_code, lv_pbcp_code ;
  END LOOP;
  CLOSE rbrapbc_c ;

  RETURN lv_total ;
--
END f_calc_prorated_period_rnd ;

-- function added for 8.37.1 (Pell 3)
-- 83701-3

FUNCTION f_calc_prorated_period_no_rnd
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,
			 p_period                   rbrapbc.rbrapbc_period%TYPE
           ) RETURN NUMBER IS

   lv_pell_budget          total_amount_type ;
   lv_total                total_amount_type ;
   lv_prorated_amount      total_amount_type ;
   lv_pbtp_code            rbrapbc.rbrapbc_pbtp_code%TYPE;
   lv_pbcp_code            rbrapbc.rbrapbc_pbcp_code%TYPE;

   CURSOR rbrapbc_c IS
     SELECT rbrapbc_pbtp_code, rbrapbc_pbcp_code
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_aidy_code     = p_aidy_code
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                       WHERE rbrpbtp_aidy_code = p_aidy_code
                                         AND rbrpbtp_pell_ind  = 'Y')
        AND rbrapbc_period        = p_period
        AND robprds_seq_no        = ( SELECT robprds_seq_no
                                        FROM robprds,
                                             rbrapbt
                                       WHERE rbrapbt_aidy_code = p_aidy_code
                                         AND rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
										 AND robprds_period    = p_period
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                     WHERE rbrpbtp_aidy_code = p_aidy_code
                                                                       AND rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

BEGIN

  lv_total := 0;
  OPEN  rbrapbc_c ;
  FETCH rbrapbc_c INTO lv_pbtp_code, lv_pbcp_code ;
  WHILE rbrapbc_c%FOUND LOOP
      SELECT f_calc_component_prorated_amt
           ( p_aidy_code, p_pidm, lv_pbtp_code, lv_pbcp_code, p_period )
		INTO lv_prorated_amount
		FROM DUAL;
	  lv_total := lv_total + lv_prorated_amount;
     FETCH rbrapbc_c INTO lv_pbtp_code, lv_pbcp_code ;
  END LOOP;
  CLOSE rbrapbc_c ;

  RETURN lv_total ;
--
END f_calc_prorated_period_no_rnd ;

-- function added for 8.37.1 (Pell 3)
-- 83701-5

FUNCTION f_calc_lth_prort_period_no_rnd
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run,
			 p_period                   rbrapbc.rbrapbc_period%TYPE
           ) RETURN NUMBER IS

   lv_pell_budget          total_amount_type ;
   lv_total                total_amount_type ;
   lv_prorated_amount      total_amount_type ;
   lv_pbtp_code            rbrapbc.rbrapbc_pbtp_code%TYPE;
   lv_pbcp_code            rbrapbc.rbrapbc_pbcp_code%TYPE;

   CURSOR rbrapbc_c IS
     SELECT rbrapbc_pbtp_code, rbrapbc_pbcp_code
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_aidy_code     = p_aidy_code
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                       WHERE rbrpbtp_aidy_code         = p_aidy_code
                                         AND rbrpbtp_pell_ind          = 'Y')
        AND rbrapbc_pbcp_code    IN ( SELECT rbrpbcp_pbcp_code
                                        FROM rbrpbcp
                                       WHERE rbrpbcp_aidy_code         = p_aidy_code
                                         AND rbrpbcp_pell_lt_half_ind  = 'Y')
        AND rbrapbc_period        = p_period
        AND robprds_seq_no        = ( SELECT robprds_seq_no
                                        FROM robprds,
                                             rbrapbt
                                       WHERE rbrapbt_aidy_code = p_aidy_code
                                         AND rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
										 AND robprds_period    = p_period
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                     WHERE rbrpbtp_aidy_code = p_aidy_code
                                                                       AND rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

BEGIN

  lv_total := 0;
  OPEN  rbrapbc_c ;
  FETCH rbrapbc_c INTO lv_pbtp_code, lv_pbcp_code ;
  WHILE rbrapbc_c%FOUND LOOP
      SELECT f_calc_component_prorated_amt
           ( p_aidy_code, p_pidm, lv_pbtp_code, lv_pbcp_code, p_period )
		INTO lv_prorated_amount
		FROM DUAL;
	  lv_total := lv_total + lv_prorated_amount;
     FETCH rbrapbc_c INTO lv_pbtp_code, lv_pbcp_code ;
  END LOOP;
  CLOSE rbrapbc_c ;

  RETURN lv_total ;
--
END f_calc_lth_prort_period_no_rnd ;
-------------------------------------------------------------------------------------------------

FUNCTION f_calc_pell_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run                -- 81401-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS                                                               -- 81200-1

   lv_pell_budget          rptneed.rptneed_budget_amount%TYPE ;                                                         -- 81200-1
   lv_total                total_amount_type ;                                                                          -- 81200-1

   CURSOR rbracmp_amt_c IS
     SELECT SUM(rbracmp_amt)
     FROM   rbbabud, rbracmp
     WHERE  EXISTS
            (SELECT 'X'
             FROM   rtvbtyp
             WHERE  rtvbtyp_pell_ind    = 'Y'
             AND    rbbabud_btyp_code = rtvbtyp_code)
     AND    rbbabud_btyp_code = rbracmp_btyp_code
     AND    rbbabud_pidm      = p_pidm
     AND    rbbabud_aidy_code = p_aidy_code
     AND    rbracmp_pidm      = p_pidm
     AND    rbracmp_aidy_code = p_aidy_code ;

BEGIN

   IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'N' THEN                                                 -- 81401-1
       OPEN  rbracmp_amt_c ;                                                                                            -- 81401-1
       FETCH rbracmp_amt_c INTO lv_total ;                                                                              -- 81401-1
       CLOSE rbracmp_amt_c ;                                                                                            -- 81401-1
   ELSE                                                                                                                 -- 81401-1
       lv_total :=  f_calc_period_pell_budget_amt                                                                       -- 81401-1
                      ( p_pidm        =>  p_pidm,                                                                       -- 81401-1
                        p_aidy_code   =>  p_aidy_code,                                                                  -- 81401-1
                        p_run_name    =>  p_run_name                                                                    -- 81401-1
                      ) ;                                                                                               -- 81401-1
   END IF;                                                                                                              -- 81401-1

   IF lv_total IS NULL THEN                                                                                             -- 81200-1
       lv_pell_budget := lv_total;                                                                                      -- 81200-1
   ELSE                                                                                                                 -- 81200-1
       lv_pell_budget := LEAST(lv_total,M_BUDGET_MAX);                                                                  -- 81200-1
   END IF;                                                                                                              -- 81200-1

   RETURN lv_pell_budget ;                                                                                              -- 81200-1
--
END f_calc_pell_budget_amt ;
-- Begin 83701-7
-------------------------------------------------------------------------------------------------

FUNCTION f_calc_pell_ftfy_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.f_actual_run
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS

   lv_pell_budget          rptneed.rptneed_budget_amount%TYPE ;
   lv_total                total_amount_type ;
   lv_pell_percent         rfrdefa.rfrdefa_pell_award_pct%TYPE ;
   lv_difference           rfrdefa.rfrdefa_pell_award_pct%TYPE ;
   lv_max_period_budget    total_amount_type ;
   lv_variance             total_amount_type ;
   lv_acad_year_cnt        NUMBER;
   lv_period               rbrapbc.rbrapbc_period%TYPE;
   lv_period_budget        NUMBER;


   CURSOR rbracmp_amt_c IS
     SELECT SUM(rbracmp_amt)
     FROM   rbbabud, rbracmp
     WHERE  EXISTS
            (SELECT 'X'
             FROM   rtvbtyp
             WHERE  rtvbtyp_pell_ind    = 'Y'
             AND    rbbabud_btyp_code = rtvbtyp_code)
     AND    rbbabud_btyp_code = rbracmp_btyp_code
     AND    rbbabud_pidm      = p_pidm
     AND    rbbabud_aidy_code = p_aidy_code
     AND    rbracmp_pidm      = p_pidm
     AND    rbracmp_aidy_code = p_aidy_code ;

   CURSOR rbrapbc_min_period_c IS
     SELECT SUM(rbrapbc_amt)
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_aidy_code     = p_aidy_code
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                       WHERE rbrpbtp_aidy_code = p_aidy_code
                                         AND rbrpbtp_pell_ind  = 'Y')
        AND rbrapbc_period        = robprds_period
        AND robprds_seq_no        = ( SELECT MIN(robprds_seq_no)
                                        FROM robprds,
                                             rbrapbt
                                       WHERE rbrapbt_aidy_code = p_aidy_code
                                         AND rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                     WHERE rbrpbtp_aidy_code = p_aidy_code
                                                                       AND rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

   CURSOR rbrapbc_max_period_c IS
     SELECT SUM(rbrapbc_amt)
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_aidy_code     = p_aidy_code
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                       WHERE rbrpbtp_aidy_code = p_aidy_code
                                         AND rbrpbtp_pell_ind  = 'Y')
        AND rbrapbc_period        = robprds_period
        AND robprds_seq_no        = ( SELECT MAX(robprds_seq_no)
                                        FROM robprds,
                                             rbrapbt
                                       WHERE rbrapbt_aidy_code = p_aidy_code
                                         AND rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                     WHERE rbrpbtp_aidy_code = p_aidy_code
                                                                       AND rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

   CURSOR acad_year_cnt_c IS
       SELECT COUNT(DISTINCT(robprds_acad_year))
	     FROM rortprd tprd
    LEFT JOIN rorstat stat  ON rorstat_pidm = p_pidm AND rorstat_aidy_code = p_aidy_code
    LEFT JOIN robprds prds  ON robprds_period = rortprd_period
    WHERE rortprd_aidy_code = p_aidy_code AND rortprd_aprd_code = rorstat_aprd_code;

   CURSOR tprd_period_c IS
       SELECT rortprd_period
	     FROM rortprd tprd
    LEFT JOIN rorstat stat  ON rorstat_pidm = p_pidm AND rorstat_aidy_code = p_aidy_code
    WHERE rortprd_aidy_code = p_aidy_code AND rortprd_aprd_code = rorstat_aprd_code;

BEGIN

   OPEN  acad_year_cnt_c ;
   FETCH acad_year_cnt_c INTO lv_acad_year_cnt ;
   CLOSE acad_year_cnt_c ;

   IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'N' THEN
       OPEN  rbracmp_amt_c ;
       FETCH rbracmp_amt_c INTO lv_total ;
       CLOSE rbracmp_amt_c ;
   ELSE
-- Start Period with highest COA
       IF rokpell.f_pell3_exists(p_pidm, p_aidy_code) = 'Y'
--	      AND lv_acad_year_cnt > 1
	   THEN
	        lv_total := 0;
            OPEN  tprd_period_c;
            FETCH tprd_period_c INTO lv_period;
	        WHILE tprd_period_c%FOUND LOOP
		       SELECT f_calc_period_pell3_budget_amt
                     (p_pidm,
	         	   rb_budget_run.f_actual_run,
                       lv_period)
	             INTO lv_period_budget
		         FROM DUAL;
               IF lv_period_budget > lv_total THEN
			      lv_total := lv_period_budget;
               END IF;
               FETCH tprd_period_c INTO lv_period ;
	        END LOOP;
            CLOSE tprd_period_c;
	 lv_total := ROUND(lv_total,2);
-- End Period with highest COA
	   ELSE
           OPEN  rbrapbc_min_period_c ;
           FETCH rbrapbc_min_period_c INTO lv_total ;
           CLOSE rbrapbc_min_period_c ;
       END IF;
   END IF;

   IF lv_total IS NULL THEN
       lv_pell_budget := lv_total;
   ELSE
       lv_pell_budget := LEAST(lv_total,M_BUDGET_MAX);
   END IF;
   RETURN lv_pell_budget ;
--
END f_calc_pell_ftfy_budget_amt ;
-- End 83701-7

-------------------------------------------------------------------------------------------------
--  function added for 8.14.1 (Period Budgeting)

FUNCTION f_calc_pell_efc
           ( p_pidm                     rcrapp2.rcrapp2_pidm%TYPE,
             p_aidy_code                rcrapp2.rcrapp2_aidy_code%TYPE
           ) RETURN efc_type IS

   lv_calc_efc                          efc_type ;

   CURSOR pell_efc_c IS
        SELECT rcrapp2_pell_pgi
          FROM rcrapp2,
               rcrapp1
         WHERE rcrapp2_seq_no       = rcrapp1_seq_no
           AND rcrapp2_infc_code    = rcrapp1_infc_code
           AND rcrapp2_pidm         = rcrapp1_pidm
           AND rcrapp2_aidy_code    = rcrapp1_aidy_code
           AND rcrapp1_curr_rec_ind = 'Y'
           AND rcrapp1_pidm         = p_pidm
           AND rcrapp1_aidy_code    = p_aidy_code ;

BEGIN
   OPEN  pell_efc_c ;
   FETCH pell_efc_c INTO lv_calc_efc ;
   IF pell_efc_c%NOTFOUND THEN
       lv_calc_efc := NULL ;
   END IF;
   CLOSE pell_efc_c ;

   RETURN lv_calc_efc ;

END f_calc_pell_efc ;

-------------------------------------------------------------------------------------------------
--  function added for 8.12
FUNCTION f_calc_pell_lt_half_coa
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS

   lv_pell_budget          rptneed.rptneed_budget_amount%TYPE ;
   lv_total                total_amount_type ;

   CURSOR rbracmp_amt_c IS
     SELECT COALESCE(SUM(rbracmp_amt),0)
       FROM rtvbtyp,
            rbracmp
      WHERE rtvbtyp_pell_ind                = 'Y'
        AND rtvbtyp_code                    = rbracmp_btyp_code
        AND rbracmp_pidm                    = p_pidm
        AND rbracmp_aidy_code               = p_aidy_code
        AND EXISTS
           (SELECT 'X'
              FROM rtvcomp
             WHERE rtvcomp_code             = rbracmp_comp_code
               AND rtvcomp_pell_lt_half_ind = 'Y') ;

   CURSOR rbrapbc_c IS                                                                                                  -- 81401-1
     SELECT COALESCE(SUM(rbrapbc_amt),0)                                                                                     -- 81401-1
       FROM robprds, rbrapbc                                                                                            -- 81401-1
      WHERE rbrapbc_pidm          = p_pidm                                                                              -- 81401-1
        AND rbrapbc_aidy_code     = p_aidy_code                                                                         -- 81401-1
        AND rbrapbc_run_name      = p_run_name                                                                          -- 81401-1
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code                                                          -- 81401-1
                                        FROM rbrpbtp                                                                    -- 81401-1
                                       WHERE rbrpbtp_aidy_code         = p_aidy_code                                    -- 81401-1
                                         AND rbrpbtp_pell_ind          = 'Y')                                           -- 81401-1
        AND rbrapbc_pbcp_code    IN ( SELECT rbrpbcp_pbcp_code                                                          -- 81401-1
                                        FROM rbrpbcp                                                                    -- 81401-1
                                       WHERE rbrpbcp_aidy_code         = p_aidy_code                                    -- 81401-1
                                         AND rbrpbcp_pell_lt_half_ind  = 'Y')                                           -- 81401-1
        AND rbrapbc_period        = robprds_period                                                                      -- 81401-1
        AND robprds_seq_no        = ( SELECT MIN(robprds_seq_no)                                                        -- 81401-1
                                        FROM robprds,                                                                   -- 81401-1
                                             rbrapbt                                                                    -- 81401-1
                                       WHERE rbrapbt_aidy_code = p_aidy_code                                            -- 81401-1
                                         AND rbrapbt_pidm      = p_pidm                                                 -- 81401-1
                                         AND rbrapbt_run_name  = p_run_name                                             -- 81401-1
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code                            -- 81401-1
                                                                      FROM rbrpbtp                                      -- 81401-1
                                                                     WHERE rbrpbtp_aidy_code = p_aidy_code              -- 81401-1
                                                                       AND rbrpbtp_pell_ind  = 'Y')                     -- 81401-1
                                         AND rbrapbt_period    = robprds_period );                                      -- 81401-1
-- Begin 83701-6

   lv_period                   rbrapbc.rbrapbc_period%TYPE;
   lv_period_budget            NUMBER;

   CURSOR tprd_period_c IS
       SELECT rortprd_period
	     FROM rortprd tprd
    LEFT JOIN rorstat stat  ON rorstat_pidm = p_pidm AND rorstat_aidy_code = p_aidy_code
    WHERE rortprd_aidy_code = p_aidy_code AND rortprd_aprd_code = rorstat_aprd_code;

-- END 83701-6
BEGIN

  lv_total := 0;                                                                                                        -- 83701-6
  IF rokpell.f_pell3_exists(p_pidm, p_aidy_code) = 'Y'                                                                  -- 83701-6
  THEN                                                                                                                  -- 83701-6
     lv_total := 0;                                                                                                     -- 83701-6
     OPEN  tprd_period_c;                                                                                               -- 83701-6
     FETCH tprd_period_c INTO lv_period;                                                                                -- 83701-6
	 WHILE tprd_period_c%FOUND LOOP                                                                                     -- 83701-6
		SELECT f_calc_lth_prort_period_no_rnd                                                                           -- 83701-6
             (p_pidm,                                                                                                   -- 83701-6
              p_aidy_code,                                                                                              -- 83701-6
			  rb_budget_run.f_actual_run,                                                                               -- 83701-6
              lv_period)                                                                                                -- 83701-6
	      INTO lv_period_budget                                                                                         -- 83701-6
		  FROM DUAL;                                                                                                    -- 83701-6
	    lv_total := lv_total + lv_period_budget;                                                                        -- 83701-6
        FETCH tprd_period_c INTO lv_period ;                                                                            -- 83701-6
	 END LOOP;                                                                                                          -- 83701-6
     CLOSE tprd_period_c;                                                                                               -- 83701-6
	 lv_total := ROUND(lv_total,2);                                                                                     -- 83701-6
  ELSE                                                                                                                  -- 83701-6
  IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'N' THEN                                                  -- 81401-1
      OPEN  rbracmp_amt_c ;                                                                                             -- 81401-1
      FETCH rbracmp_amt_c INTO lv_total ;                                                                               -- 81401-1
      CLOSE rbracmp_amt_c ;                                                                                             -- 81401-1
  ELSE                                                                                                                  -- 81401-1
      OPEN  rbrapbc_c ;                                                                                                 -- 81401-1
      FETCH rbrapbc_c INTO lv_total ;                                                                                   -- 81401-1
      CLOSE rbrapbc_c ;                                                                                                 -- 81401-1
  END IF;                                                                                                               -- 81401-1
  END IF;                                                                                                               -- 83701-6

   lv_pell_budget := LEAST(lv_total,M_BUDGET_MAX);

   RETURN lv_pell_budget ;

END f_calc_pell_lt_half_coa ;

-------------------------------------------------------------------------------------------------
--  function added for 8.37.1  - BFASA-6353
-- 83701-1
-- 83701-8 - Modified for BFASA-7843

FUNCTION f_calc_pell3_lt_half_coa
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN,
			 p_period                   rbrapbc.rbrapbc_period%TYPE
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS

   lv_pell_budget          rptneed.rptneed_budget_amount%TYPE ;
   lv_total                total_amount_type ;

   CURSOR rbrapbc_c IS
     SELECT COALESCE(SUM(rbrapbc_amt),0)
       FROM robprds, rbrapbc
      WHERE rbrapbc_pidm          = p_pidm
        AND rbrapbc_run_name      = p_run_name
        AND rbrapbc_pbtp_code    IN ( SELECT rbrpbtp_pbtp_code
                                        FROM rbrpbtp
                                       WHERE rbrpbtp_pell_ind          = 'Y')
        AND rbrapbc_pbcp_code    IN ( SELECT rbrpbcp_pbcp_code
                                        FROM rbrpbcp
                                       WHERE rbrpbcp_pell_lt_half_ind  = 'Y')
        AND rbrapbc_period        = p_period
        AND robprds_seq_no        = ( SELECT robprds_seq_no
                                        FROM robprds,
                                             rbrapbt
                                       WHERE rbrapbt_pidm      = p_pidm
                                         AND rbrapbt_run_name  = p_run_name
										 AND robprds_period    = p_period
                                         AND rbrapbt_pbtp_code IN ( SELECT rbrpbtp_pbtp_code
                                                                      FROM rbrpbtp
                                                                     WHERE rbrpbtp_pell_ind  = 'Y')
                                         AND rbrapbt_period    = robprds_period );

BEGIN

   OPEN  rbrapbc_c ;
   FETCH rbrapbc_c INTO lv_total ;
   CLOSE rbrapbc_c ;


   lv_pell_budget := LEAST(COALESCE(lv_total,0),M_BUDGET_MAX);

   RETURN lv_pell_budget ;

END f_calc_pell3_lt_half_coa ;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_non_pell_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS

   lv_non_pell_budget         rptneed.rptneed_budget_amount%TYPE ;                                                      -- 81200-1
   lv_total                    total_amount_type ;                                                                      -- 81200-1

   CURSOR rbracmp_amt_c IS
     SELECT SUM(rbracmp_amt)
     FROM   rbbabud, rbracmp
     WHERE  NOT EXISTS
            (SELECT 'X'
             FROM   rtvbtyp
             WHERE  rtvbtyp_pell_ind    = 'Y'
             AND    rbbabud_btyp_code = rtvbtyp_code)
     AND    rbbabud_btyp_code = rbracmp_btyp_code
     AND    rbbabud_pidm      = p_pidm
     AND    rbbabud_aidy_code = p_aidy_code
     AND    rbracmp_pidm      = p_pidm
     AND    rbracmp_aidy_code = p_aidy_code ;

BEGIN
   OPEN rbracmp_amt_c ;
   FETCH rbracmp_amt_c INTO lv_total ;                                                                                  -- 81200-1
   IF rbracmp_amt_c%NOTFOUND THEN
      lv_total := NULL ;                                                                                                -- 81200-1
   END IF;
   CLOSE rbracmp_amt_c ;

   IF lv_total IS NULL THEN                                                                                             -- 81200-1
       lv_non_pell_budget := lv_total;                                                                                  -- 81200-1
   ELSE                                                                                                                 -- 81200-1
       lv_non_pell_budget := LEAST(lv_total,M_BUDGET_MAX);                                                              -- 81200-1
   END IF;                                                                                                              -- 81200-1

   RETURN lv_non_pell_budget ;                                                                                          -- 81200-1

END f_calc_non_pell_budget_amt ;

-------------------------------------------------------------------------------------------------
-- function added for 8.14.1 (Period Budgeting)

FUNCTION f_calc_period_budget_amt
           ( p_pidm                     rbrapbc.rbrapbc_pidm%TYPE,
             p_aidy_code                rbrapbc.rbrapbc_aidy_code%TYPE,
             p_type_ind                 indicator_type                DEFAULT 'F',
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS

   lv_budget_amt                        rptneed.rptneed_budget_amount%TYPE ;
   lv_total                             total_amount_type ;

   CURSOR rbrapbc_c IS
     SELECT SUM(rbrapbc_amt)
     FROM   rbrpbtp, rbrapbc
     WHERE  rbrapbc_pidm          = p_pidm
     AND    rbrapbc_aidy_code     = p_aidy_code
     AND    rbrapbc_run_name      = p_run_name
     AND    rbrapbc_pbtp_code     = rbrpbtp_pbtp_code
     AND    rbrapbc_aidy_code     = rbrpbtp_aidy_code
     AND    rbrpbtp_efc_ind       = p_type_ind ;

BEGIN

   IF p_type_ind = 'P' THEN
       lv_total :=  f_calc_period_pell_budget_amt
                      ( p_pidm        =>  p_pidm,
                        p_aidy_code   =>  p_aidy_code,
                        p_run_name    =>  p_run_name
                      ) ;
   ELSE
       OPEN  rbrapbc_c ;
       FETCH rbrapbc_c INTO lv_total ;
       CLOSE rbrapbc_c ;
   END IF;

   IF lv_total IS NULL THEN
       lv_budget_amt := lv_total;
   ELSE
       lv_budget_amt := LEAST(lv_total,M_BUDGET_MAX);
   END IF;

   RETURN lv_budget_amt ;

END f_calc_period_budget_amt ;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_budget_amt
           ( p_pidm                     rbracmp.rbracmp_pidm%TYPE,
             p_aidy_code                rbracmp.rbracmp_aidy_code%TYPE,
             p_type_ind                 indicator_type                DEFAULT 'F',                                      -- 81401-1
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN rptneed.rptneed_budget_amount%TYPE IS                                                               -- 81200-1

  lv_calc_budget              rptneed.rptneed_budget_amount%TYPE ;                                                      -- 81200-1

BEGIN

  IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'N' THEN                                                  -- 81401-1
      lv_calc_budget := f_calc_non_pell_budget_amt(p_pidm, p_aidy_code) ;                                               -- 81401-1
                                                                                                                        -- 81401-1
      IF lv_calc_budget IS NULL THEN                                                                                    -- 81401-1
--        lv_calc_budget := COALESCE(f_calc_pell_budget_amt(p_pidm, p_aidy_code),0) ;                                        -- 81401-1
          lv_calc_budget := f_calc_pell_budget_amt(p_pidm, p_aidy_code) ;                                               -- 82201-2
      END IF;                                                                                                           -- 81401-1
  ELSE                                                                                                                  -- 81401-1
--      lv_calc_budget := COALESCE(f_calc_period_budget_amt                                                                  -- 81401-1
      lv_calc_budget := f_calc_period_budget_amt                                                                        -- 82201-2
                              ( p_pidm       =>  p_pidm,                                                                -- 81401-1
                                p_aidy_code  =>  p_aidy_code,                                                           -- 81401-1
                                p_type_ind   =>  p_type_ind,                                                            -- 81401-1
                                p_run_name   =>  p_run_name                                                             -- 81401-1
--                            ),0) ;                                                                                    -- 81401-1
                              ) ;                                                                                       -- 82201-2
  END IF ;

  RETURN lv_calc_budget ;                                                                                               -- 81200-1

END f_calc_budget_amt ;

-------------------------------------------------------------------------------------------------
-- function added for 8.14.1 (Period Budgeting)

FUNCTION f_calc_direct_cost_amt
           ( p_pidm                       rbrapbc.rbrapbc_pidm%TYPE,
             p_aidy_code                  rbrapbc.rbrapbc_aidy_code%TYPE,
             p_type_ind                   indicator_type                DEFAULT 'F',
             p_run_name                   rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN
           ) RETURN rptneed.rptneed_fm_direct_cost_amt%TYPE IS

   lv_budget_amt                          rptneed.rptneed_fm_direct_cost_amt%TYPE ;
   lv_total                               total_amount_type ;

   CURSOR rbrapbc_c IS
     SELECT SUM(rbrapbc_amt)
       FROM rbrpbcp,
            rbrpbtp,
            rbrapbc
      WHERE rbrapbc_pidm             = p_pidm
        AND rbrapbc_aidy_code        = p_aidy_code
        AND rbrapbc_run_name         = p_run_name
        AND rbrapbc_pbtp_code        = rbrpbtp_pbtp_code
        AND rbrapbc_aidy_code        = rbrpbtp_aidy_code
        AND rbrpbtp_efc_ind          = p_type_ind
        AND rbrapbc_aidy_code        = rbrpbcp_aidy_code
        AND rbrapbc_pbcp_code        = rbrpbcp_pbcp_code
        AND rbrpbcp_direct_cost_ind  = 'Y' ;

BEGIN

   IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'Y' THEN
       OPEN  rbrapbc_c ;
       FETCH rbrapbc_c INTO lv_total ;
       CLOSE rbrapbc_c ;
   END IF;

   IF lv_total IS NULL THEN
       lv_budget_amt := lv_total;
   ELSE
       lv_budget_amt := LEAST(lv_total,M_BUDGET_MAX);
   END IF;

   RETURN lv_budget_amt ;

END f_calc_direct_cost_amt ;

-------------------------------------------------------------------------------------------------

FUNCTION f_find_efc_ind
           ( p_pidm                     rbbabud.rbbabud_pidm%TYPE,
             p_aidy_code                rbbabud.rbbabud_aidy_code%TYPE,
             p_run_name                 rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN                -- 81401-1
           ) RETURN indicator_type IS

   lv_efc_ind                           rbbabud.rbbabud_tfc_ind%TYPE ;

   CURSOR rbbabud_tfc_ind_c IS
     SELECT rbbabud_tfc_ind
     FROM   rbbabud
     WHERE  NOT EXISTS
            (SELECT 'X'
             from   rtvbtyp
             where  rtvbtyp_pell_ind    = 'Y'
             and    rbbabud_btyp_code = rtvbtyp_code )
     AND    rbbabud_pidm      = p_pidm
     AND    rbbabud_aidy_code = p_aidy_code ;

   CURSOR rbbabud_tfc_ind_2_c IS
     SELECT rbbabud_tfc_ind
     FROM   rbbabud
     WHERE  EXISTS
            (SELECT 'X'
             from   rtvbtyp
             where  rtvbtyp_pell_ind    = 'Y'
             and    rbbabud_btyp_code = rtvbtyp_code )
     AND    rbbabud_pidm      = p_pidm
     AND    rbbabud_aidy_code = p_aidy_code ;

   CURSOR robinst_method_ind_c IS
     SELECT robinst_method_ind
     FROM   robinst
     WHERE  robinst_aidy_code = p_aidy_code ;

BEGIN
   IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'N' THEN                                                 -- 81401-1
       OPEN rbbabud_tfc_ind_c ;                                                                                         -- 81401-1
       FETCH rbbabud_tfc_ind_c INTO lv_efc_ind ;                                                                        -- 81401-1
       IF rbbabud_tfc_ind_c%NOTFOUND THEN                                                                               -- 81401-1
          lv_efc_ind := NULL ;                                                                                          -- 81401-1
       END IF;                                                                                                          -- 81401-1
       CLOSE rbbabud_tfc_ind_c ;                                                                                        -- 81401-1
                                                                                                                        -- 81401-1
       IF lv_efc_ind IS NULL THEN                                                                                       -- 81401-1
         OPEN rbbabud_tfc_ind_2_c ;                                                                                     -- 81401-1
         FETCH rbbabud_tfc_ind_2_c INTO lv_efc_ind ;                                                                    -- 81401-1
         IF rbbabud_tfc_ind_2_c%NOTFOUND THEN                                                                           -- 81401-1
            lv_efc_ind := NULL ;                                                                                        -- 81401-1
         END IF;                                                                                                        -- 81401-1
         CLOSE rbbabud_tfc_ind_2_c ;                                                                                    -- 81401-1
       END IF;                                                                                                          -- 81401-1
   ELSE                                                                                                                 -- 81401-1
       IF rbk_period_budget.f_im_budget_exists                                                                          -- 81401-1
            ( p_pidm      =>  p_pidm,                                                                                   -- 81401-1
              p_aidy_code =>  p_aidy_code,                                                                              -- 81401-1
              p_run_name  =>  p_run_name) = 'Y' THEN                                                                    -- 81401-1
           lv_efc_ind := 'I';                                                                                           -- 81401-1
       ELSE                                                                                                             -- 81401-1
           IF rbk_period_budget.f_fm_budget_exists                                                                      -- 81401-1
               ( p_pidm      =>  p_pidm,                                                                                -- 81401-1
                 p_aidy_code =>  p_aidy_code,                                                                           -- 81401-1
                 p_run_name  =>  p_run_name) = 'Y' THEN                                                                 -- 81401-1
              lv_efc_ind := 'F';                                                                                        -- 81401-1
           END IF;                                                                                                      -- 81401-1
       END IF;                                                                                                          -- 81401-1
   END IF;                                                                                                              -- 81401-1

   IF lv_efc_ind IS NULL THEN                                                                                           -- 81401-1
       OPEN  robinst_method_ind_c ;                                                                                     -- 81401-1
       FETCH robinst_method_ind_c INTO lv_efc_ind ;                                                                     -- 81401-1
       IF robinst_method_ind_c%NOTFOUND THEN                                                                            -- 81401-1
           lv_efc_ind := NULL ;                                                                                         -- 81401-1
       END IF;                                                                                                          -- 81401-1
       CLOSE robinst_method_ind_c ;                                                                                     -- 81401-1
   END IF;                                                                                                              -- 81401-1

  RETURN lv_efc_ind ;

END f_find_efc_ind ;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_efc
           ( p_pidm                     rcrapp4.rcrapp4_pidm%TYPE,
             p_aidy_code                rcrapp4.rcrapp4_aidy_code%TYPE
           ) RETURN rptneed.rptneed_efc_amt%TYPE IS                                                                     -- 81200-1

   lv_calc_efc                          rptneed.rptneed_fm_efc_amt%TYPE ;                                               -- 81200-1
   lv_fm_efc_max                        rptneed.rptneed_fm_efc_amt%TYPE ;                                               -- 81802-2

   lv_efc                               rcrapp4.rcrapp4_c_inst_1_tot_fam_ctrb%TYPE ;                                    -- 81802-1
   lv_sc                                rcrapp2.rcrapp2_c_1_ctrb_for_stdt%TYPE ;                                        -- 81802-1
   lv_pc                                rcrapp2.rcrapp2_c_par_1_ctrb_for_stdt%TYPE;                                     -- 81802-1
   lv_infc_code                         rcrapp4.rcrapp4_infc_code%TYPE;
   lv_seq_no                            rcrapp4.rcrapp4_seq_no%TYPE;
   lv_end_year                          robinst.robinst_aidy_end_year%TYPE;

   CURSOR rcrapp4_tot_fam_ctrb_c IS
     SELECT rcrapp4_c_inst_1_tot_fam_ctrb,
            rcrapp2_c_1_ctrb_for_stdt,
            rcrapp2_c_par_1_ctrb_for_stdt,
            rcrapp4_infc_code,
            rcrapp4_seq_no
       FROM rcrapp4,
            rcrapp2,
            rcrapp1
     WHERE  rcrapp4_seq_no       = rcrapp1_seq_no
     AND    rcrapp4_infc_code    = rcrapp1_infc_code
     AND    rcrapp4_pidm         = p_pidm
     AND    rcrapp4_aidy_code    = p_aidy_code
     AND    rcrapp2_seq_no       = rcrapp1_seq_no
     AND    rcrapp2_infc_code    = rcrapp1_infc_code
     AND    rcrapp2_pidm         = p_pidm
     AND    rcrapp2_aidy_code    = p_aidy_code
     AND    rcrapp1_curr_rec_ind = 'Y'
     AND    rcrapp1_pidm         = p_pidm
     AND    rcrapp1_aidy_code    = p_aidy_code ;

BEGIN
   lv_end_year := rb_common.f_sel_robinst_aidy_end_year(p_aidy_code);

   IF lv_end_year <= 2014 THEN
     lv_fm_efc_max  :=  M_OLD_FM_EFC_MAX;                                                                               -- 81802-2
   ELSE                                                                                                                 -- 81802-2
     lv_fm_efc_max  :=  M_NEW_FM_EFC_MAX;                                                                               -- 81802-2
   END IF;                                                                                                              -- 81802-2

   OPEN rcrapp4_tot_fam_ctrb_c ;
   FETCH rcrapp4_tot_fam_ctrb_c INTO lv_efc,
                                     lv_sc,
                                     lv_pc,
                                     lv_infc_code,
                                     lv_seq_no;

    -- Use EFM SAI as EFC, ONLY for aid years => 2425 are the current record.
    -- Return EFC = 0 for aid years => 2425 and EFM SAI is less than zero.
    IF lv_end_year >= 2025 THEN
       IF lv_efc < 0
       THEN
           lv_calc_efc := 0;
       ELSE
           lv_calc_efc := lv_efc;
       END IF;
   ELSIF lv_efc IS NULL OR lv_efc = 0 THEN
       IF lv_sc IS NULL AND                                                                                             -- 81802-2
          lv_pc IS NULL THEN                                                                                            -- 81802-2
           lv_calc_efc :=  NULL ;                                                                                       -- 81802-2
       ELSE                                                                                                             -- 81802-2
          lv_calc_efc :=  LEAST((COALESCE(lv_sc,0) + COALESCE(lv_pc,0)),lv_fm_efc_max) ;                                          -- 81802-2
       END IF;                                                                                                          -- 81802-2
   ELSE                                                                                                                 -- 81802-2
       lv_calc_efc := lv_efc;                                                                                           -- 81802-2
   END IF;                                                                                                              -- 81802-2
   CLOSE rcrapp4_tot_fam_ctrb_c ;
--
   RETURN lv_calc_efc ;                                                                                                 -- 81200-1
--
END f_calc_efc ;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_im_efc
           ( p_pidm                     rcrapp2.rcrapp2_pidm%TYPE,
             p_aidy_code                rcrapp2.rcrapp2_aidy_code%TYPE
           ) RETURN rptneed.rptneed_im_efc_amt%TYPE IS                                                                  -- 81200-1

   lv_calc_im_efc                       rptneed.rptneed_im_efc_amt%TYPE ;                                               -- 81200-1
   lv_im_efc_max                        rptneed.rptneed_im_efc_amt%TYPE ;                                               -- 81802-2

   lv_im_1_tfc                          rcrapp2.rcrapp2_im_1_tfc%TYPE ;                                                 -- 81500-1                                                                                 -- 81200-1
   lv_im_1_sc                           rcrapp2.rcrapp2_im_1_sc%TYPE ;                                                  -- 81500-1
   lv_im_1_pc                           rcrapp2.rcrapp2_im_1_pc%TYPE ;                                                  -- 81500-1

   CURSOR rcrapp2_im_1_tfc_c IS                                                                                         -- 81500-1
     SELECT rcrapp2_im_1_tfc,                                                                                           -- 81500-1
            rcrapp2_im_1_sc,                                                                                            -- 81500-1
            rcrapp2_im_1_pc                                                                                             -- 81500-1
     FROM   rcrapp2, rcrapp1                                                                                            -- 81500-1
     WHERE  rcrapp2_seq_no       = rcrapp1_seq_no                                                                       -- 81500-1
     AND    rcrapp2_infc_code    = rcrapp1_infc_code                                                                    -- 81500-1
     AND    rcrapp2_pidm         = p_pidm                                                                               -- 81500-1
     AND    rcrapp2_aidy_code    = p_aidy_code                                                                          -- 81500-1
     AND    rcrapp1_curr_rec_ind = 'Y'                                                                                  -- 81500-1
     AND    rcrapp1_pidm         = p_pidm                                                                               -- 81500-1
     AND    rcrapp1_aidy_code    = p_aidy_code ;                                                                        -- 81500-1

BEGIN
   IF rb_common.f_sel_robinst_aidy_end_year(p_aidy_code) <= 2014 THEN                                                   -- 81802-2
     lv_im_efc_max  :=  M_OLD_IM_EFC_MAX;                                                                               -- 81802-2
   ELSE                                                                                                                 -- 81802-2
     lv_im_efc_max  :=  M_NEW_IM_EFC_MAX;                                                                               -- 81802-2
   END IF;                                                                                                              -- 81802-2

  OPEN rcrapp2_im_1_tfc_c ;                                                                                             -- 81500-1
   FETCH rcrapp2_im_1_tfc_c INTO lv_im_1_tfc,                                                                           -- 81500-1
                                 lv_im_1_sc,                                                                            -- 81500-1
                                 lv_im_1_pc ;                                                                           -- 81500-1
   CLOSE rcrapp2_im_1_tfc_c ;                                                                                           -- 81500-1

   IF lv_im_1_tfc IS NULL OR                                                                                            -- 81500-1
      lv_im_1_tfc = 0     THEN                                                                                          -- 81500-1
       IF lv_im_1_sc IS NULL AND                                                                                        -- 81500-1
          lv_im_1_pc IS NULL THEN                                                                                       -- 81500-1
           lv_calc_im_efc :=  NULL ;                                                                           -- 81802-1
       ELSE                                                                                                             -- 81500-1
          lv_calc_im_efc :=  LEAST((COALESCE(lv_im_1_sc,0) + COALESCE(lv_im_1_pc,0)),lv_im_efc_max) ;                             -- 81802-2
       END IF;                                                                                                          -- 81500-1
   ELSE                                                                                                                 -- 81500-1
       lv_calc_im_efc := lv_im_1_tfc;                                                                                   -- 81500-1
   END IF;                                                                                                              -- 81500-1

   RETURN lv_calc_im_efc ;                                                                                              -- 81200-1
--
END f_calc_im_efc ;

-------------------------------------------------------------------------------------------------

-- 6210-2
-- 6300-1  Replaced the bulk of the code and replaced it with three new functions
--         to calculate the resource amount.
--

FUNCTION f_calc_resource
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE
           ) RETURN rptneed.rptneed_resource_amount%TYPE IS                                                             -- 81200-1

  resource_amt_v                        rptneed.rptneed_resource_amount%TYPE;                                           -- 81200-1
  lv_total                              total_amount_type ;                                                             -- 81200-1

BEGIN

  lv_total := COALESCE(f_calc_oth_resource (p_pidm,                                                                          -- 81200-1
                                       p_aidy_code),0) +
              COALESCE(f_calc_exemptions (p_pidm,
                                     p_aidy_code,
                                     p_load),0) +
              COALESCE(f_calc_contracts (p_pidm,
                                    p_aidy_code,
                                    p_load),0);

-- *DEBUG* DBMS_OUTPUT.PUT_LINE ('resource_amt_v = ' || resource_amt_v);

  resource_amt_v := LEAST(lv_total,M_RESOURCE_MAX);                                                                     -- 81200-1

  RETURN resource_amt_v;

END f_calc_resource;

-------------------------------------------------------------------------------------------------
--
-- 6300-1  Added function to return the other resources total to support the Resource
--         Maintenance Form (RPAARSC).
--
FUNCTION f_calc_oth_resource
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE
           ) RETURN NUMBER IS

  misc_field_v                          VARCHAR2(1);

  oth_act_amt_v                         NUMBER;                                                                         -- 81200-1
  oth_est_amt_v                         NUMBER;                                                                         -- 81200-1

  CURSOR calc_resource_amt_c IS
  SELECT SUM(COALESCE(DECODE(RPRARSC_ACTUAL_AMT,'',RPRARSC_EST_AMT,                                                          -- 60400
                    RPRARSC_ACTUAL_AMT),0)),                                                                            -- 60400
         SUM(COALESCE(RPRARSC_EST_AMT,0))
    FROM RPRARSC
   WHERE RPRARSC_PIDM      = p_pidm
     AND ( ( RPRARSC_AIDY_CODE  = p_aidy_code                                                                           -- 80900-1
     AND     RPRARSC_TERM_CODE IS NULL                                                                                  -- 80900-1
           )                                                                                                            -- 80900-1
      OR   ( RPRARSC_TERM_CODE IS NOT NULL                                                                              -- 80900-1
     AND     RPRARSC_TERM_CODE IN ( SELECT RORPRDS_TERM_CODE                                                            -- 80900-1
                                      FROM RORPRDS,                                                                     -- 80900-1
                                           RORTPRD,                                                                     -- 80900-1
                                           RORSTAT                                                                      -- 80900-1
                                     WHERE RORSTAT_PIDM      = p_pidm                                                   -- 80900-1
                                       AND RORSTAT_AIDY_CODE = p_aidy_code                                              -- 80900-1
                                       AND RORPRDS_PERIOD    = RORTPRD_PERIOD                                           -- 80900-1
                                       AND RORTPRD_AIDY_CODE = p_aidy_code                                              -- 80900-1
                                       AND RORTPRD_APRD_CODE = RORSTAT_APRD_CODE                                        -- 80900-1
                                  )                                                                                     -- 80900-1
           )                                                                                                            -- 80900-1
         );                                                                                                             -- 80900-1

   CURSOR check_resource_amt_c IS
   SELECT 'X'
     FROM RPRARSC
    WHERE RPRARSC_PIDM      = p_pidm
     AND ( ( RPRARSC_AIDY_CODE  = p_aidy_code                                                                           -- 80900-1
     AND     RPRARSC_TERM_CODE IS NULL                                                                                  -- 80900-1
           )                                                                                                            -- 80900-1
      OR   ( RPRARSC_TERM_CODE IS NOT NULL                                                                              -- 80900-1
     AND     RPRARSC_TERM_CODE IN ( SELECT RORPRDS_TERM_CODE                                                            -- 80900-1
                                      FROM RORPRDS,                                                                     -- 80900-1
                                           RORTPRD,                                                                     -- 80900-1
                                           RORSTAT                                                                      -- 80900-1
                                     WHERE RORSTAT_PIDM      = p_pidm                                                   -- 80900-1
                                       AND RORSTAT_AIDY_CODE = p_aidy_code                                              -- 80900-1
                                       AND RORPRDS_PERIOD    = RORTPRD_PERIOD                                           -- 80900-1
                                       AND RORTPRD_AIDY_CODE = p_aidy_code                                              -- 80900-1
                                       AND RORTPRD_APRD_CODE = RORSTAT_APRD_CODE                                        -- 80900-1
                                  )                                                                                     -- 80900-1
           )                                                                                                            -- 80900-1
         )                                                                                                              -- 80900-1
      AND RPRARSC_ACTUAL_AMT IS NOT NULL;

--

BEGIN

-- Calculate Resource Amount

  IF NOT calc_resource_amt_c%ISOPEN THEN
    OPEN calc_resource_amt_c;
  END IF;

  FETCH calc_resource_amt_c
   INTO oth_act_amt_v,
        oth_est_amt_v;

  IF calc_resource_amt_c%NOTFOUND THEN
--     oth_act_amt_v := NULL;                                                                                           -- 60400
--     oth_est_amt_v := NULL;                                                                                           -- 60400
     oth_act_amt_v := 0;                                                                                                -- 60400
     oth_est_amt_v := 0;                                                                                                -- 60400
  END IF;

  CLOSE calc_resource_amt_c;

--  SELECT COALESCE(oth_act_amt_v, 0),                                                                                       -- 60400
--         COALESCE(oth_est_amt_v, 0)                                                                                        -- 60400
--    INTO oth_act_amt_v,                                                                                               -- 60400
--         oth_est_amt_v                                                                                                -- 60400
--    FROM DUAL;                                                                                                        -- 60400

  IF NOT check_resource_amt_c%ISOPEN THEN
    OPEN check_resource_amt_c;
  END IF;

  FETCH check_resource_amt_c
   INTO misc_field_v;

  IF check_resource_amt_c%NOTFOUND THEN
     oth_act_amt_v := oth_est_amt_v;
  END IF;

  CLOSE check_resource_amt_c;

-- *DEBUG* DBMS_OUTPUT.PUT_LINE ('oth_act_amt_v = ' || oth_act_amt_v);

  RETURN oth_act_amt_v;

END f_calc_oth_resource;

-------------------------------------------------------------------------------------------------
--
-- 6300-1  Added function to return the exemptions total to support the Resource
--         Maintenance Form (RPAARSC).
--
FUNCTION f_calc_exemptions
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE
           ) RETURN NUMBER IS

-- define local variables

  misc_field_v                          VARCHAR2(1);

  exe_act_amt_v                         NUMBER;                                                                         -- 81200-1
  exe_est_amt_v                         NUMBER;                                                                         -- 81200-1

  always_use_est_ind_v                  rpbopts.rpbopts_always_use_est_ind%TYPE;
  interface_exempt_ind_v                rpbopts.rpbopts_interface_exempt_ind%TYPE;
  assume_full_time_ind_v                rpbopts.rpbopts_assume_full_time_ind%TYPE;
  interface_3party_ind_v                rpbopts.rpbopts_interface_3party_ind%TYPE;
  default_option_ind_v                  rpbopts.rpbopts_default_option_ind%TYPE;
  threequarter_time_pct_v               rpbopts.rpbopts_3quarter_time_pct%TYPE;
  half_time_pct_v                       rpbopts.rpbopts_half_time_pct%TYPE;
  less_half_time_pct_v                  rpbopts.rpbopts_less_half_time_pct%TYPE;

--

  CURSOR get_resource_options_c IS
  SELECT RPBOPTS_ALWAYS_USE_EST_IND,
         RPBOPTS_INTERFACE_EXEMPT_IND,
         RPBOPTS_ASSUME_FULL_TIME_IND,
         RPBOPTS_INTERFACE_3PARTY_IND,
         RPBOPTS_DEFAULT_OPTION_IND,
         COALESCE(RPBOPTS_3QUARTER_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_HALF_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_LESS_HALF_TIME_PCT,0) * .01
    FROM RPBOPTS
   WHERE RPBOPTS_AIDY_CODE = p_aidy_code;

  CURSOR calc_exemption_amt_c IS
--  SELECT SUM(DECODE(f_calc_exemption_payment(TBBESTU_PIDM,                                                            -- 60400
-- 70800-3
  SELECT SUM(COALESCE(DECODE(f_calc_exemption_payment(TBBESTU_PIDM,                                                          -- 60400
                                             TBBESTU_EXEMPTION_CODE,
                                             TBBESTU_TERM_CODE),
                    '',DECODE(assume_full_time_ind_v,
                              'Y', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT),
                              DECODE(p_load,
                                     '2', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT)
                                          * threequarter_time_pct_v,
                                     '3', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT)
                                          * half_time_pct_v,
                                     '4', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT)
                                          * less_half_time_pct_v,
                                     COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT))),
                    f_calc_exemption_payment(TBBESTU_PIDM,
                                             TBBESTU_EXEMPTION_CODE,
--                                           TBBESTU_TERM_CODE))),                                                      -- 60400
                                             TBBESTU_TERM_CODE)),0)),                                                   -- 60400
         SUM(COALESCE(COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT),0))
        FROM RPREXPT,
--             STVTERM,                                                                                                 -- 080900-1
             TBBESTU
       WHERE TBBESTU_EXEMPTION_CODE = RPREXPT_EXEMPTION_CODE (+)
         AND TBBESTU_TERM_CODE      = RPREXPT_TERM_CODE (+)
--         AND STVTERM_FA_PROC_YR     = p_aidy_code                                                                     -- 080900-1
--         AND STVTERM_CODE           = TBBESTU_TERM_CODE                                                               -- 080900-1
         AND (TBBESTU_TERM_CODE IN (SELECT RORPRDS_TERM_CODE                                                            -- 080900-1
                                      FROM RORPRDS, RORTPRD, RORSTAT
                                     WHERE RORSTAT_PIDM = p_pidm
                                       AND RORSTAT_AIDY_CODE = p_aidy_code
                                       AND RORPRDS_PERIOD = RORTPRD_PERIOD
                                       AND RORTPRD_AIDY_CODE = p_aidy_code
                                       AND RORTPRD_APRD_CODE = RORSTAT_APRD_CODE))
         AND COALESCE(TBBESTU_DEL_IND,'X') <> 'D'
         AND COALESCE(RPREXPT_EXCLUDE_RESOURCE, 'N') = 'N'                                                                   -- 70800-2
         AND TBBESTU_PIDM           = p_pidm;

--

  CURSOR check_exemption_amt_c IS
  SELECT 'X'
    FROM RPREXPT,
--         STVTERM,                                                                                                     -- 080900-1
         TBBESTU
   WHERE f_calc_exemption_payment(TBBESTU_PIDM,
                                  TBBESTU_EXEMPTION_CODE,
                                  TBBESTU_TERM_CODE) IS NOT NULL
     AND TBBESTU_EXEMPTION_CODE = RPREXPT_EXEMPTION_CODE (+)
     AND TBBESTU_TERM_CODE      = RPREXPT_TERM_CODE (+)
--   AND STVTERM_FA_PROC_YR     = p_aidy_code                                                                           -- 080900-1
--   AND TBBESTU_TERM_CODE      = STVTERM_CODE                                                                          -- 080900-1
     AND (TBBESTU_TERM_CODE IN (SELECT RORPRDS_TERM_CODE                                                                -- 080900-1
                                  FROM RORPRDS, RORTPRD, RORSTAT
                                 WHERE RORSTAT_PIDM = p_pidm
                                   AND RORSTAT_AIDY_CODE = p_aidy_code
                                   AND RORPRDS_PERIOD = RORTPRD_PERIOD
                                   AND RORTPRD_AIDY_CODE = p_aidy_code
                                   AND RORTPRD_APRD_CODE = RORSTAT_APRD_CODE))
     AND COALESCE(TBBESTU_DEL_IND,'X') <> 'D'
     AND COALESCE(RPREXPT_EXCLUDE_RESOURCE, 'N') = 'N'                                                                       -- 70800-2
     AND TBBESTU_PIDM           = p_pidm;

BEGIN

-- Obtain Resource Options

  IF NOT get_resource_options_c%ISOPEN THEN
    OPEN get_resource_options_c;
  END IF;

  FETCH get_resource_options_c
   INTO always_use_est_ind_v,
        interface_exempt_ind_v,
        assume_full_time_ind_v,
        interface_3party_ind_v,
        default_option_ind_v,
        threequarter_time_pct_v,
        half_time_pct_v,
        less_half_time_pct_v;

  IF get_resource_options_c%NOTFOUND THEN
     always_use_est_ind_v    := NULL;
     interface_exempt_ind_v  := 'N';
     assume_full_time_ind_v  := NULL;
     interface_3party_ind_v  := 'N';
     default_option_ind_v    := NULL;
--     threequarter_time_pct_v := NULL;                                                                                 -- 60400
--     half_time_pct_v         := NULL;                                                                                 -- 60400
--     less_half_time_pct_v    := NULL;                                                                                 -- 60400
     threequarter_time_pct_v := 0;                                                                                      -- 60400
     half_time_pct_v         := 0;                                                                                      -- 60400
     less_half_time_pct_v    := 0;                                                                                      -- 60400
  END IF;

  CLOSE get_resource_options_c;

--  SELECT COALESCE( threequarter_time_pct_v, 0),                                                                            -- 60400
--         COALESCE( half_time_pct_v, 0),                                                                                    -- 60400
--         COALESCE( less_half_time_pct_v, 0)                                                                                -- 60400
--    INTO threequarter_time_pct_v,                                                                                     -- 60400
--         half_time_pct_v,                                                                                             -- 60400
--         less_half_time_pct_v                                                                                         -- 60400
--    FROM DUAL;                                                                                                        -- 60400

-- Calculating Actual Resource Amount

<<UCN4>>

-- 60211-1
  IF interface_exempt_ind_v = 'N' THEN
     exe_act_amt_v := 0;
     exe_est_amt_v := 0;
  ELSE

    IF NOT calc_exemption_amt_c%ISOPEN THEN
      OPEN calc_exemption_amt_c;
    END IF;

    FETCH calc_exemption_amt_c
     INTO exe_act_amt_v,
          exe_est_amt_v;

    IF calc_exemption_amt_c%NOTFOUND THEN
--       exe_act_amt_v := NULL;                                                                                         -- 60400
--       exe_est_amt_v := NULL;                                                                                         -- 60400
       exe_act_amt_v := 0;                                                                                              -- 60400
       exe_est_amt_v := 0;                                                                                              -- 60400
    END IF;

    CLOSE calc_exemption_amt_c;

--    SELECT COALESCE(exe_act_amt_v, 0),                                                                                     -- 60400
--           COALESCE(exe_est_amt_v, 0)                                                                                      -- 60400
--      INTO exe_act_amt_v,                                                                                             -- 60400
--           exe_est_amt_v                                                                                              -- 60400
--      FROM DUAL;                                                                                                      -- 60400

    IF assume_full_time_ind_v = 'N' THEN
        IF p_load = '2' THEN
            exe_est_amt_v := exe_est_amt_v * threequarter_time_pct_v;
        ELSE
            IF p_load = '3' THEN
                exe_est_amt_v := exe_est_amt_v * half_time_pct_v;
            ELSE
                IF p_load = '4' THEN
                    exe_est_amt_v := exe_est_amt_v * less_half_time_pct_v;
                END IF;
            END IF;
        END IF;
    END IF;

    IF NOT check_exemption_amt_c%ISOPEN THEN
      OPEN check_exemption_amt_c;
    END IF;

    FETCH check_exemption_amt_c
     INTO misc_field_v;

    IF check_exemption_amt_c%NOTFOUND THEN
       exe_act_amt_v := exe_est_amt_v;
    END IF;

    CLOSE check_exemption_amt_c;

  END IF;

  IF always_use_est_ind_v = 'Y' THEN
     exe_act_amt_v := exe_est_amt_v;
  END IF;

-- *DEBUG* DBMS_OUTPUT.PUT_LINE ('exe_act_amt_v = ' || exe_act_amt_v);

  RETURN exe_act_amt_v;

END f_calc_exemptions;

-------------------------------------------------------------------------------------------------
--
-- 6300-1  Added function to return the contracts total to support the Resource
--         Maintenance Form (RPAARSC).
--
FUNCTION f_calc_contracts
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE
           ) RETURN NUMBER IS

-- define local variables

  misc_field_v                          VARCHAR2(1);

  con_act_amt_v                         NUMBER;                                                                         -- 81200-1
  con_est_amt_v                         NUMBER;                                                                         -- 81200-1

  always_use_est_ind_v                  rpbopts.rpbopts_always_use_est_ind%TYPE;
  interface_exempt_ind_v                rpbopts.rpbopts_interface_exempt_ind%TYPE;
  assume_full_time_ind_v                rpbopts.rpbopts_assume_full_time_ind%TYPE;
  interface_3party_ind_v                rpbopts.rpbopts_interface_3party_ind%TYPE;
  default_option_ind_v                  rpbopts.rpbopts_default_option_ind%TYPE;
  threequarter_time_pct_v               rpbopts.rpbopts_3quarter_time_pct%TYPE;
  half_time_pct_v                       rpbopts.rpbopts_half_time_pct%TYPE;
  less_half_time_pct_v                  rpbopts.rpbopts_less_half_time_pct%TYPE;

--
  CURSOR get_resource_options_c IS
  SELECT RPBOPTS_ALWAYS_USE_EST_IND,
         RPBOPTS_INTERFACE_EXEMPT_IND,
         RPBOPTS_ASSUME_FULL_TIME_IND,
         RPBOPTS_INTERFACE_3PARTY_IND,
         RPBOPTS_DEFAULT_OPTION_IND,
         COALESCE(RPBOPTS_3QUARTER_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_HALF_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_LESS_HALF_TIME_PCT,0) * .01
    FROM RPBOPTS
   WHERE RPBOPTS_AIDY_CODE = p_aidy_code;

--
  CURSOR calc_contract_amt_c IS
--  SELECT SUM(DECODE(f_calc_contract_payment(TBBCSTU_STU_PIDM,                                                         -- 60400
-- 70800-3
  SELECT SUM(COALESCE(DECODE(f_calc_contract_payment(TBBCSTU_STU_PIDM,                                                       -- 60400
                                            TBBCSTU_CONTRACT_PIDM,
                                            TBBCSTU_CONTRACT_NUMBER,
                                            TBBCSTU_TERM_CODE),
                    '',DECODE(assume_full_time_ind_v,
                              'Y', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT),
                                 DECODE(p_load,
                                         '2', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT)
                                          * threequarter_time_pct_v,
                                         '3', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT)
                                          * half_time_pct_v,
                                         '4', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT)
                                          * less_half_time_pct_v,
                                         COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT))),
                       f_calc_contract_payment(TBBCSTU_STU_PIDM,
                                            TBBCSTU_CONTRACT_PIDM,
                                            TBBCSTU_CONTRACT_NUMBER,
--                                            TBBCSTU_TERM_CODE))),                                                     -- 60400
                                            TBBCSTU_TERM_CODE)),0)),                                                    -- 60400
         SUM(COALESCE(COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT),0))
    FROM RPRCONT,
--         STVTERM,                                                                                                     -- 080900-1
         TBBCSTU
   WHERE TBBCSTU_CONTRACT_PIDM   = RPRCONT_CONTRACT_PIDM (+)
     AND TBBCSTU_CONTRACT_NUMBER = RPRCONT_CONTRACT_NO (+)
     AND TBBCSTU_TERM_CODE       = RPRCONT_TERM_CODE (+)
--     AND STVTERM_FA_PROC_YR      = p_aidy_code                                                                        -- 080900-1
--     AND STVTERM_CODE            = TBBCSTU_TERM_CODE                                                                  -- 080900-1
     AND (TBBCSTU_TERM_CODE IN (SELECT RORPRDS_TERM_CODE                                                                -- 080900-1
                                  FROM RORPRDS, RORTPRD, RORSTAT
                                 WHERE RORSTAT_PIDM = p_pidm
                                   AND RORSTAT_AIDY_CODE = p_aidy_code
                                   AND RORPRDS_PERIOD = RORTPRD_PERIOD
                                   AND RORTPRD_AIDY_CODE = p_aidy_code
                                   AND RORTPRD_APRD_CODE = RORSTAT_APRD_CODE))
     AND COALESCE(TBBCSTU_DEL_IND,'X') <> 'D'
     AND COALESCE(RPRCONT_EXCLUDE_RESOURCE, 'N') = 'N'                                                                        -- 70800-2
     AND TBBCSTU_STU_PIDM        = p_pidm;

--
    CURSOR check_contract_amt_c IS
    SELECT 'X'
      FROM RPRCONT,
--           STVTERM,                                                                                                   -- 080900-1
           TBBCSTU
     WHERE f_calc_contract_payment(TBBCSTU_STU_PIDM,
                                   TBBCSTU_CONTRACT_PIDM,
                                   TBBCSTU_CONTRACT_NUMBER,
                                   TBBCSTU_TERM_CODE) IS NOT NULL
       AND TBBCSTU_CONTRACT_PIDM   = RPRCONT_CONTRACT_PIDM (+)
       AND TBBCSTU_CONTRACT_NUMBER = RPRCONT_CONTRACT_NO (+)
       AND TBBCSTU_TERM_CODE       = RPRCONT_TERM_CODE (+)
--       AND STVTERM_FA_PROC_YR      = p_aidy_code                                                                      -- 080900-1
--       AND STVTERM_CODE            = TBBCSTU_TERM_CODE                                                                -- 080900-1
       AND (TBBCSTU_TERM_CODE IN (SELECT RORPRDS_TERM_CODE                                                              -- 080900-1
                                    FROM RORPRDS, RORTPRD, RORSTAT
                                   WHERE RORSTAT_PIDM = p_pidm
                                     AND RORSTAT_AIDY_CODE = p_aidy_code
                                     AND RORPRDS_PERIOD = RORTPRD_PERIOD
                                     AND RORTPRD_AIDY_CODE = p_aidy_code
                                     AND RORTPRD_APRD_CODE = RORSTAT_APRD_CODE))
       AND COALESCE(TBBCSTU_DEL_IND,'X') <> 'D'
       AND COALESCE(RPRCONT_EXCLUDE_RESOURCE, 'N') = 'N'                                                                     -- 70800-2
       AND TBBCSTU_STU_PIDM        = p_pidm;

BEGIN

-- Obtain Resource Options

  IF NOT get_resource_options_c%ISOPEN THEN
    OPEN get_resource_options_c;
  END IF;

  FETCH get_resource_options_c
   INTO always_use_est_ind_v,
        interface_exempt_ind_v,
        assume_full_time_ind_v,
        interface_3party_ind_v,
        default_option_ind_v,
        threequarter_time_pct_v,
        half_time_pct_v,
        less_half_time_pct_v;

  IF get_resource_options_c%NOTFOUND THEN
     always_use_est_ind_v    := NULL;
     interface_exempt_ind_v  := 'N';
     assume_full_time_ind_v  := NULL;
     interface_3party_ind_v  := 'N';
     default_option_ind_v    := NULL;
--     threequarter_time_pct_v := NULL;                                                                                 -- 60400
--     half_time_pct_v         := NULL;                                                                                 -- 60400
--     less_half_time_pct_v    := NULL;                                                                                 -- 60400
     threequarter_time_pct_v := 0;                                                                                      -- 60400
     half_time_pct_v         := 0;                                                                                      -- 60400
     less_half_time_pct_v    := 0;                                                                                      -- 60400
  END IF;

  CLOSE get_resource_options_c;

--  SELECT COALESCE( threequarter_time_pct_v, 0),                                                                            -- 60400
--         COALESCE( half_time_pct_v, 0),                                                                                    -- 60400
--         COALESCE( less_half_time_pct_v, 0)                                                                                -- 60400
--    INTO threequarter_time_pct_v,                                                                                     -- 60400
--         half_time_pct_v,                                                                                             -- 60400
--         less_half_time_pct_v                                                                                         -- 60400
--    FROM DUAL;                                                                                                        -- 60400

-- Calculating Actual Resource Amount

-- 60211-1
  IF interface_3party_ind_v = 'N' THEN
     con_act_amt_v := 0;
     con_est_amt_v := 0;
  ELSE

-- Calculating Actual Contract Amount

    IF NOT calc_contract_amt_c%ISOPEN THEN
      OPEN calc_contract_amt_c;
    END IF;

    FETCH calc_contract_amt_c
     INTO con_act_amt_v,
          con_est_amt_v;

    IF calc_contract_amt_c%NOTFOUND THEN
--       con_act_amt_v := NULL;                                                                                         -- 60400
--       con_est_amt_v := NULL;                                                                                         -- 60400
       con_act_amt_v := 0;                                                                                              -- 60400
       con_est_amt_v := 0;                                                                                              -- 60400
    END IF;

    CLOSE calc_contract_amt_c;

--    SELECT COALESCE(con_act_amt_v, 0),                                                                                     -- 60400
--           COALESCE(con_est_amt_v, 0)                                                                                      -- 60400
--      INTO con_act_amt_v,                                                                                             -- 60400
--           con_est_amt_v                                                                                              -- 60400
--      FROM DUAL;                                                                                                      -- 60400

-- Prorate Estimated Resource Based Upon Applicant's Enrollment Status

    IF assume_full_time_ind_v = 'N' THEN
        IF p_load = '2' THEN
            con_est_amt_v := con_est_amt_v * threequarter_time_pct_v;
        ELSE
            IF p_load = '3' THEN
                con_est_amt_v := con_est_amt_v * half_time_pct_v;
            ELSE
                IF p_load = '4' THEN
                    con_est_amt_v := con_est_amt_v * less_half_time_pct_v;
                END IF;
            END IF;
        END IF;
    END IF;

    IF NOT check_contract_amt_c%ISOPEN THEN
      OPEN check_contract_amt_c;
    END IF;

    FETCH check_contract_amt_c
     INTO misc_field_v;

    IF check_contract_amt_c%NOTFOUND THEN
       con_act_amt_v := con_est_amt_v;
    END IF;

    CLOSE check_contract_amt_c;

  END IF;

<<UCN7>>
  IF always_use_est_ind_v = 'Y' THEN
     con_act_amt_v := con_est_amt_v;
  END IF;

-- *DEBUG* DBMS_OUTPUT.PUT_LINE ('con_act_amt_v = ' || con_act_amt_v);

  RETURN con_act_amt_v;

END f_calc_contracts;

-------------------------------------------------------------------------------------------------
--
-- 6300-1  Added function to return the expected enrollment.
--
FUNCTION f_calc_load
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN VARCHAR2 IS

-- define local variables

  exp_enroll_status                     rorstat.rorstat_xes%TYPE;                                                       -- 81802-1
  est_enroll_pell_ind                   rpbopts.rpbopts_est_enroll_pell_ind%TYPE;                                       -- 80000-1
  default_option_ind                    rpbopts.rpbopts_default_option_ind%TYPE;                                        -- 80000-1

  CURSOR  calc_load_c IS
    SELECT rcrapp1_exp_enroll_status
      FROM rcrapp1
     WHERE rcrapp1_curr_rec_ind = 'Y'
       AND rcrapp1_pidm         = p_pidm
       AND rcrapp1_aidy_code    = p_aidy_code;

  CURSOR  new_calc_load_c IS                                                                                            -- 81802-1
    SELECT rorstat_xes                                                                                                  -- 81802-1
      FROM rorstat                                                                                                      -- 81802-1
     WHERE rorstat_pidm         = p_pidm                                                                                -- 81802-1
       AND rorstat_aidy_code    = p_aidy_code;                                                                          -- 81802-1
  /* 70800-1 */
  CURSOR  calc_default_load_c IS
    SELECT rpbopts_est_enroll_pell_ind,                                                                                 -- 80000-1
           rpbopts_default_option_ind
      FROM rpbopts
     WHERE rpbopts_aidy_code = p_aidy_code;

BEGIN

  OPEN  calc_default_load_c;                                                                                            -- 80000-1
  FETCH calc_default_load_c INTO est_enroll_pell_ind,                                                                   -- 80000-1
                                 default_option_ind;                                                                    -- 80000-1
  IF calc_default_load_c%NOTFOUND THEN                                                                                  -- 80000-1
      est_enroll_pell_ind := 'N';                                                                                       -- 80000-1
      default_option_ind  := NULL;                                                                                      -- 80000-1
  END IF;                                                                                                               -- 80000-1
  CLOSE calc_default_load_c;                                                                                            -- 80000-1

  IF est_enroll_pell_ind = 'N' THEN                                                                                     -- 80000-1
      exp_enroll_status := default_option_ind;                                                                          -- 80000-1
  ELSE                                                                                                                  -- 80000-1
      IF rb_common.f_sel_robinst_aidy_end_year(p_aidy_code) <= 2014 THEN                                                -- 81802-1
          OPEN  calc_load_c;
          FETCH calc_load_c INTO exp_enroll_status;
          CLOSE calc_load_c;
      ELSE                                                                                                              -- 81802-1
          OPEN  new_calc_load_c;                                                                                        -- 81802-1
          FETCH new_calc_load_c INTO exp_enroll_status;                                                                 -- 81802-1
          CLOSE new_calc_load_c;                                                                                        -- 81802-1
      END IF;                                                                                                         -- 81802-1

    /* 70800-1 */
--      IF (calc_load_c%NOTFOUND) OR (exp_enroll_status IS NULL) OR (exp_enroll_status = 5) THEN                        -- 81802-1
      IF (exp_enroll_status IS NULL) OR (exp_enroll_status = 5) THEN                                                    -- 81802-1
          exp_enroll_status := default_option_ind;                                                                      -- 80000-1
      END IF;                                                                                                           -- 80000-1
--    OPEN  calc_default_load_c;                                                                                        -- 80000-1
--    FETCH calc_default_load_c INTO exp_enroll_status;                                                                 -- 80000-1
--    IF (calc_default_load_c%NOTFOUND) THEN                                                                            -- 80000-1
--      exp_enroll_status := NULL;                                                                                      -- 80000-1
--    END IF;                                                                                                           -- 80000-1
--    CLOSE calc_default_load_c;                                                                                        -- 80000-1
--  END IF;                                                                                                             -- 80000-1

  END IF;

  IF exp_enroll_status IS NULL THEN
    exp_enroll_status := 1;
  END IF;

  RETURN exp_enroll_status;

END f_calc_load;

-------------------------------------------------------------------------------------------------
--
-- 080900-1 Replaced term codes with periods and rprcrss with robprds.
--
FUNCTION f_calc_act_reduce_need_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables
    p_reduce_need_amt                   rptneed.rptneed_reduce_need_amt%TYPE ;                                          -- 81802-2

    CURSOR act_reduce_need IS
     select sum(COALESCE(reduce_need_amt,0))                                                                                 -- 80900-1
       from                                                                                                             -- 80900-1
            ( select sum(COALESCE(rpratrm_offer_amt, 0)) reduce_need_amt                                                     -- 80900-1
             from rfrbase,                                                                                              -- 80900-1
                  rfraspc,                                                                                              -- 80900-1
                  rpratrm                                                                                               -- 80900-1
            where rpratrm_pidm                   = p_pidm                                                               -- 80900-1
              and rfrbase_fund_code              = rpratrm_fund_code                                                    -- 80900-1
              and rpratrm_fund_code              = rfraspc_fund_code                                                    -- 80900-1
              and rpratrm_aidy_code              = rfraspc_aidy_code                                                    -- 80900-1
              and rfraspc_reduce_need_ind        = 'Y'                                                                  -- 80900-1
              and rfrbase_fed_fund_id            = 'PELL'                                                               -- 80900-1
              and ( ( rpratrm_period            IN ( select rortprd_period                                              -- 80900-1
                                                       from rortprd,                                                    -- 80900-1
                                                            rorstat                                                     -- 80900-1
                                                      where rorstat_pidm      = p_pidm                                  -- 80900-1
                                                        and rorstat_aidy_code = p_aidy_code                             -- 80900-1
                                                        and rorstat_aidy_code = rortprd_aidy_code                       -- 80900-1
                                                        and rorstat_aprd_code = rortprd_aprd_code                       -- 80900-1
                                                   )                                                                    -- 80900-1
                    )                                                                                                   -- 80900-1
               or   ( rpratrm_period        NOT IN ( select rortprd_period                                              -- 80900-1
                                                       from rortprd,                                                    -- 80900-1
                                                            rorstat                                                     -- 80900-1
                                                      where rorstat_pidm      = p_pidm                                  -- 80900-1
                                                        and rorstat_aidy_code = p_aidy_code                             -- 80900-1
                                                        and rorstat_aidy_code = rortprd_aidy_code                       -- 80900-1
                                                        and rorstat_aprd_code = rortprd_aprd_code                       -- 80900-1
                                                   )                                                                    -- 80900-1
              and     rpratrm_period            IN ( select robprds_period                                              -- 80900-1
                                                       from robprds                                                     -- 80900-1
                                                      where robprds_aidy_code_cross IS NULL                             -- 80900-1
                                                   )                                                                    -- 80900-1
              and     rpratrm_aidy_code          = p_aidy_code                                                          -- 80900-1
                    )                                                                                                   -- 80900-1
                  )                                                                                                     -- 80900-1
            UNION ALL                                                                                                   -- 08090101-1
--            UNION                                                                                                     -- 80900-1
            select sum(COALESCE(rprawrd_offer_amt, 0)) reduce_need_amt                                                       -- 80900-1
             from rfrbase,                                                                                              -- 80900-1
                  rfraspc,                                                                                              -- 80900-1
                  rprawrd                                                                                               -- 80900-1
            where rprawrd_pidm                       = p_pidm                                                           -- 80900-1
              and rfrbase_fund_code                  = rprawrd_fund_code                                                -- 80900-1
              and rprawrd_fund_code                  = rfraspc_fund_code                                                -- 80900-1
              and rprawrd_aidy_code                  = rfraspc_aidy_code                                                -- 80900-1
              and rfraspc_reduce_need_ind            = 'Y'                                                              -- 80900-1
              and COALESCE(rfrbase_fed_fund_id,'*')      <> 'PELL'                                                           -- 80900-1
              and rprawrd_aidy_code                  = p_aidy_code                                                      -- 80900-1
           ) ;                                                                                                          -- 80900-1

BEGIN
    OPEN act_reduce_need;
    FETCH act_reduce_need INTO p_reduce_need_amt;
    CLOSE act_reduce_need;

    RETURN COALESCE(p_reduce_need_amt,0);

END f_calc_act_reduce_need_amt;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_sim_reduce_need_amt
           ( p_pidm                     rptawrd.rptawrd_pidm%TYPE,
             p_aidy_code                rptawrd.rptawrd_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables
    p_reduce_need_amt                   rptneed.rptneed_reduce_need_amt%TYPE ;                                          -- 81802-2
    lv_add_crossover_amt                rptawrd.rptawrd_offer_amt%TYPE ;                                                -- 81802-2
    lv_subtract_crossover_amt           rptawrd.rptawrd_offer_amt%TYPE ;                                                -- 81802-2

    CURSOR sim_reduce_need IS
        select sum(COALESCE(rptawrd_offer_amt, 0))
          from rptawrd r
         where exists
                  (select 'X'
                     from rftaspc
                    where rftaspc_reduce_need_ind = 'Y'
                      and r.rptawrd_fund_code = rftaspc_fund_code
                      and r.rptawrd_aidy_code = rftaspc_aidy_code)
           and rptawrd_pidm      = p_pidm
           and rptawrd_aidy_code = p_aidy_code;

-- 81500-2 new cursor
-- subtract off crossover period amounts that are not in the base aid period for the student
    CURSOR subtract_crossover_amt_cur IS
     select sum(COALESCE(rpratrm_offer_amt,0))
       from rfrbase,
            rpratrm,
            rptawrd
      where rptawrd_pidm                   = p_pidm
        and rptawrd_aidy_code              = p_aidy_code
        and rptawrd_fund_code              = rfrbase_fund_code
        and rfrbase_fed_fund_id            = 'PELL'
        and rpratrm_pidm                   = rptawrd_pidm
        and rpratrm_fund_code              = rptawrd_fund_code
        and rpratrm_aidy_code              = rptawrd_aidy_code
        and rpratrm_period NOT IN ( select rortprd_period
                                      from rortprd,
                                           rorstat
                                     where rorstat_pidm      = p_pidm
                                       and rorstat_aidy_code = p_aidy_code
                                       and rorstat_aidy_code = rortprd_aidy_code
                                       and rorstat_aprd_code = rortprd_aprd_code);

-- 81500-2 new cursor
-- add in crossover period amounts for periods that are in the base aid period for the student
-- but which were awarded in the crossover aid year
    CURSOR add_crossover_amt_cur IS
     select sum(COALESCE(B.rpratrm_offer_amt,0))
       from rfrbase A,
            rpratrm B
      where B.rpratrm_pidm                 = p_pidm
        and B.rpratrm_fund_code            = A.rfrbase_fund_code
        and A.rfrbase_fed_fund_id          = 'PELL'
        and B.rpratrm_period  IN ( select rortprd_period
                                     from rortprd,
                                          rorstat
                                    where rorstat_pidm      = B.rpratrm_pidm
                                      and rorstat_aidy_code = p_aidy_code
                                      and rorstat_aidy_code = rortprd_aidy_code
                                      and rorstat_aprd_code = rortprd_aprd_code)
        and B.rpratrm_aidy_code            <> p_aidy_code
        and exists
            (select D.rpratrm_period
               from rfrbase C,
                    rpratrm D,
                    rptawrd
              where rptawrd_pidm                   = B.rpratrm_pidm
                and rptawrd_aidy_code              = p_aidy_code
                and rptawrd_fund_code              = C.rfrbase_fund_code
                and C.rfrbase_fed_fund_id          = 'PELL'
                and D.rpratrm_pidm                 = rptawrd_pidm
                and D.rpratrm_fund_code            = rptawrd_fund_code
                and D.rpratrm_aidy_code            = rptawrd_aidy_code
                and D.rpratrm_offer_amt            = 0
                and D.rpratrm_period               = B.rpratrm_period) ;

BEGIN
    OPEN sim_reduce_need;
    FETCH sim_reduce_need INTO p_reduce_need_amt;
    IF sim_reduce_need%NOTFOUND THEN
        p_reduce_need_amt := 0;
    END IF;
    CLOSE sim_reduce_need;

    OPEN subtract_crossover_amt_cur;                                                    -- 81500-2
    FETCH subtract_crossover_amt_cur INTO lv_subtract_crossover_amt;                    -- 81500-2
    IF subtract_crossover_amt_cur%NOTFOUND THEN                                         -- 81500-2
        lv_subtract_crossover_amt := 0;                                                 -- 81500-2
    END IF;                                                                             -- 81500-2
    CLOSE subtract_crossover_amt_cur;                                                   -- 81500-2

    OPEN add_crossover_amt_cur;                                                         -- 81500-2
    FETCH add_crossover_amt_cur INTO lv_add_crossover_amt;                              -- 81500-2
    IF add_crossover_amt_cur%NOTFOUND THEN                                              -- 81500-2
        lv_add_crossover_amt := 0;                                                      -- 81500-2
    END IF;                                                                             -- 81500-2
    CLOSE add_crossover_amt_cur;                                                        -- 81500-2

    p_reduce_need_amt := COALESCE(p_reduce_need_amt,0)                                       -- 81500-2
                       + COALESCE(lv_add_crossover_amt,0)                                    -- 81500-2
                       - COALESCE(lv_subtract_crossover_amt,0);                              -- 81500-2
--
    RETURN COALESCE(p_reduce_need_amt,0);
--
END f_calc_sim_reduce_need_amt;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_act_replace_efc_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables
    p_replace_efc_amt                   rptneed.rptneed_replace_efc_amt%TYPE ;                                          -- 81802-2

    CURSOR act_replace_efc IS
        select sum(COALESCE(rprawrd_offer_amt, 0))
          from rprawrd r
         where exists
                  (select 'X'
                     from rfraspc
                    where rfraspc_replace_tfc_ind = 'Y'
                      and r.rprawrd_fund_code = rfraspc_fund_code
                      and r.rprawrd_aidy_code = rfraspc_aidy_code)
           and rprawrd_pidm      = p_pidm
           and rprawrd_aidy_code = p_aidy_code;

BEGIN
    OPEN act_replace_efc;
    FETCH act_replace_efc INTO p_replace_efc_amt;
    IF act_replace_efc%NOTFOUND THEN
--        p_replace_efc_amt := NULL;                                                                                    -- 60400
        p_replace_efc_amt := 0;                                                                                         -- 60400
    END IF;
    CLOSE act_replace_efc;
--
--    RETURN p_replace_efc_amt;                                                                                         -- 60400
    RETURN COALESCE(p_replace_efc_amt,0);                                                                                    -- 60400
--
END f_calc_act_replace_efc_amt;

-------------------------------------------------------------------------------------------------

FUNCTION f_calc_sim_replace_efc_amt
           ( p_pidm                     rptawrd.rptawrd_pidm%TYPE,
             p_aidy_code                rptawrd.rptawrd_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables
    p_replace_efc_amt                   rptneed.rptneed_replace_efc_amt%TYPE ;                                         -- 81802-2


    CURSOR sim_replace_efc IS
        select sum(COALESCE(rptawrd_offer_amt, 0))
          from rptawrd r
         where exists
                  (select 'X'
                     from rftaspc
                    where rftaspc_replace_tfc_ind = 'Y'
                      and r.rptawrd_fund_code = rftaspc_fund_code
                      and r.rptawrd_aidy_code = rftaspc_aidy_code)
           and rptawrd_pidm      = p_pidm
           and rptawrd_aidy_code = p_aidy_code ;

BEGIN
    OPEN sim_replace_efc;
    FETCH sim_replace_efc INTO p_replace_efc_amt;
    IF sim_replace_efc%NOTFOUND THEN
--        p_replace_efc_amt := NULL;                                                                                    -- 60400
        p_replace_efc_amt := 0;                                                                                         -- 60400
    END IF;
    CLOSE sim_replace_efc;
--
--    RETURN p_replace_efc_amt;                                                                                         -- 60400
    RETURN COALESCE(p_replace_efc_amt,0);                                                                                    -- 60400
--
END f_calc_sim_replace_efc_amt;

-------------------------------------------------------------------------------------------------

-- 6210-2

FUNCTION f_calc_pell_award
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables

  pell_award_v rprawrd.rprawrd_offer_amt%TYPE;

  CURSOR calc_pell_award_c IS

  SELECT SUM(COALESCE(RPRAWRD_OFFER_AMT, 0))
    FROM RPRAWRD R
   WHERE EXISTS
          (SELECT 'X'
             FROM RFRBASE
            WHERE RFRBASE_FED_FUND_ID = 'PELL'
              AND R.RPRAWRD_FUND_CODE = RFRBASE_FUND_CODE )
     AND RPRAWRD_PIDM = p_pidm
     AND RPRAWRD_AIDY_CODE = p_aidy_code;

BEGIN

  IF NOT calc_pell_award_c%ISOPEN THEN
    OPEN calc_pell_award_c;
  END IF;

  FETCH calc_pell_award_c INTO pell_award_v;

  IF calc_pell_award_c%NOTFOUND THEN
     pell_award_v := NULL;
  END IF;

  CLOSE calc_pell_award_c;

  RETURN pell_award_v;

END f_calc_pell_award;

-------------------------------------------------------------------------------------------------
--  added for 7.1

FUNCTION f_calc_excess_efc_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,
             p_calc_type_ind            VARCHAR2
           ) RETURN NUMBER IS


  replace_efc_amt_v                     rptneed.rptneed_replace_efc_amt%TYPE ;                                          -- 81802-2
  efc_amt_v                             rptneed.rptneed_fm_efc_amt%TYPE;                                                -- 81200-1
  excess_efc_amt_v                      rptneed.rptneed_excess_efc_amt%TYPE ;                                           -- 81802-2

BEGIN

  IF p_calc_type_ind = 'A' THEN
    replace_efc_amt_v := f_calc_act_replace_efc_amt(p_pidm, p_aidy_code);
  ELSE
    replace_efc_amt_v := f_calc_sim_replace_efc_amt(p_pidm, p_aidy_code);
  END IF;

  efc_amt_v          := f_calc_efc(p_pidm, p_aidy_code);                                                                -- 81802-2

  IF efc_amt_v IS NULL THEN                                                                                           -- 81802-2
     excess_efc_amt_v := replace_efc_amt_v;                                                                           -- 81802-2
  ELSE                                                                                                                -- 81802-2
    IF replace_efc_amt_v > efc_amt_v THEN
       excess_efc_amt_v := replace_efc_amt_v - efc_amt_v;
    ELSE
       excess_efc_amt_v := 0;
    END IF;
  END IF;                                                                                                             -- 81802-2

  RETURN excess_efc_amt_v;

END f_calc_excess_efc_amt;

-------------------------------------------------------------------------------------------------
--  added for 7.1

FUNCTION f_calc_gross_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables

  load_v                                rcrapp1.rcrapp1_exp_enroll_status%TYPE;
  gross_need_v                          rptneed.rptneed_gross_need_amt%TYPE ;                                           -- 81802-2
  lv_fm_efc                             rptneed.rptneed_fm_efc_amt%TYPE;                                                -- 81802-2

BEGIN

  load_v              := f_calc_load (p_pidm, p_aidy_code);

  lv_fm_efc           :=  f_calc_efc(p_pidm, p_aidy_code);                                                              -- 81802-2

  IF lv_fm_efc IS NULL THEN                                                                                             -- 81802-1
      gross_need_v := 0;                                                                                                -- 81802-1
  ELSE                                                                                                                  -- 81802-1
      gross_need_v          := f_calc_budget_amt                                                                        -- 81401-1
                                   ( p_pidm       =>  p_pidm,                                                           -- 81401-1
                                     p_aidy_code  =>  p_aidy_code,                                                      -- 81401-1
                                     p_type_ind   =>  'F')                      -                                       -- 81401-1
                                lv_fm_efc                                       -                                       -- 81802-2
                                f_calc_resource(p_pidm, p_aidy_code,load_v);                                            -- 81802-2
  END IF;                                                                                                               -- 81802-2

  IF gross_need_v < 0 THEN
     gross_need_v     := 0;
  END IF;

  RETURN gross_need_v;

END f_calc_gross_need;

-------------------------------------------------------------------------------------------------
--  added for 7.1

FUNCTION f_calc_im_excess_efc_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,
             p_calc_type_ind            VARCHAR2
           ) RETURN NUMBER IS

-- define local variables

  replace_efc_amt_v                     rptneed.rptneed_replace_efc_amt%TYPE;                                           -- 81802-2
  im_efc_amt_v                          rptneed.rptneed_im_efc_amt%TYPE;                                                -- 81200-1
  im_excess_efc_amt_v                   rptneed.rptneed_im_excess_efc_amt%TYPE;                                         -- 81802-2

BEGIN

  IF p_calc_type_ind = 'A' THEN
    replace_efc_amt_v := f_calc_act_replace_efc_amt(p_pidm, p_aidy_code);
  ELSE
    replace_efc_amt_v := f_calc_sim_replace_efc_amt(p_pidm, p_aidy_code);
  END IF;

  im_efc_amt_v        := f_calc_im_efc(p_pidm, p_aidy_code);                                                            -- 81802-2

  IF im_efc_amt_v IS NULL THEN                                                                                -- 81802-2
     im_excess_efc_amt_v := replace_efc_amt_v;                                                                        -- 81802-2
  ELSE                                                                                                                -- 81802-2
    IF replace_efc_amt_v > im_efc_amt_v THEN
       im_excess_efc_amt_v := replace_efc_amt_v - im_efc_amt_v;
    ELSE
       im_excess_efc_amt_v := 0;
    END IF;
  END IF;                                                                                                             -- 81802-2

  RETURN im_excess_efc_amt_v;

END f_calc_im_excess_efc_amt;

-------------------------------------------------------------------------------------------------
--  added for 7.1

FUNCTION f_calc_im_gross_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables

  load_v                                rcrapp1.rcrapp1_exp_enroll_status%TYPE;
  im_gross_need_v                       rptneed.rptneed_im_gross_need_amt%TYPE ;                                        -- 81802-2
  lv_im_efc                             rptneed.rptneed_im_efc_amt%TYPE;                                                -- 81802-2

BEGIN

  load_v              := f_calc_load (p_pidm, p_aidy_code);

  lv_im_efc           := f_calc_im_efc(p_pidm, p_aidy_code);                                                           -- 81802-1

  IF lv_im_efc IS NULL THEN                                                                                             -- 81802-1
      im_gross_need_v  :=  0;                                                                                           -- 81802-1
  ELSE                                                                                                                  -- 81802-1
      im_gross_need_v     := f_calc_budget_amt                                                                          -- 81802-1
                                 ( p_pidm       =>  p_pidm,                                                             -- 81802-1
                                   p_aidy_code  =>  p_aidy_code,                                                        -- 81802-1
                                   p_type_ind   =>  'I')                       -                                        -- 81802-1
                             lv_im_efc                                         -                                        -- 81802-1
                             f_calc_resource(p_pidm, p_aidy_code,load_v);                                               -- 81802-1
  END IF;                                                                                                               -- 81802-1

  IF im_gross_need_v < 0 THEN
     im_gross_need_v  := 0;
  END IF;

  RETURN im_gross_need_v;

END f_calc_im_gross_need;

-------------------------------------------------------------------------------------------------
--  added for 7.1

FUNCTION f_calc_im_unmet_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,
             p_calc_type_ind            VARCHAR2
           ) RETURN NUMBER IS

-- define local variables

  reduce_need_amt_v                     rptneed.rptneed_reduce_need_amt%TYPE ;                                          -- 81802-2
  im_unmet_need_v                       rptneed.rptneed_im_unmet_need_amt%TYPE ;                                        -- 81802-2

BEGIN

  IF p_calc_type_ind = 'A' THEN
    reduce_need_amt_v := f_calc_act_reduce_need_amt(p_pidm, p_aidy_code);
  ELSE
    reduce_need_amt_v := f_calc_sim_reduce_need_amt(p_pidm, p_aidy_code);
  END IF;

  im_unmet_need_v     :=   f_calc_im_gross_need (p_pidm,p_aidy_code)
                         - f_calc_im_excess_efc_amt (p_pidm,p_aidy_code,p_calc_type_ind)
                         - reduce_need_amt_v;

  RETURN im_unmet_need_v;

END f_calc_im_unmet_need;

-------------------------------------------------------------------------------------------------
--  added for 7.1

FUNCTION f_calc_offer_amt
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,
             p_calc_type_ind            VARCHAR2
           ) RETURN NUMBER IS

-- define local variables

  replace_efc_amt_v                     rptneed.rptneed_replace_efc_amt%TYPE ;                                          -- 81802-2
  reduce_need_amt_v                     rptneed.rptneed_reduce_need_amt%TYPE ;                                          -- 81802-2
  offer_amt_v                           large_amount_type;                                                              -- 81801-1
  lv_total                              large_amount_type;                                                              -- 81801-1

BEGIN

  IF p_calc_type_ind = 'A' THEN
    replace_efc_amt_v := f_calc_act_replace_efc_amt(p_pidm, p_aidy_code);
  ELSE
    replace_efc_amt_v := f_calc_sim_replace_efc_amt(p_pidm, p_aidy_code);
  END IF;

  IF p_calc_type_ind = 'A' THEN
    reduce_need_amt_v := f_calc_act_reduce_need_amt(p_pidm, p_aidy_code);
  ELSE
    reduce_need_amt_v := f_calc_sim_reduce_need_amt(p_pidm, p_aidy_code);
  END IF;

--offer_amt_v         := replace_efc_amt_v + reduce_need_amt_v;                                                         -- 81801-1
  lv_total            := replace_efc_amt_v + reduce_need_amt_v;                                                         -- 81801-1

  IF lv_total IS NULL THEN                                                                                              -- 81200-1
      offer_amt_v := lv_total;                                                                                          -- 81200-1
  ELSE                                                                                                                  -- 81200-1
      offer_amt_v := LEAST(lv_total,M_LARGE_AMOUNT_MAX);                                                                -- 81200-1
  END IF;                                                                                                               -- 81200-1

  RETURN offer_amt_v;

END f_calc_offer_amt;

-------------------------------------------------------------------------------------------------
--  added for 7.1

FUNCTION f_calc_unmet_need
           ( p_pidm                     rprawrd.rprawrd_pidm%TYPE,
             p_aidy_code                rprawrd.rprawrd_aidy_code%TYPE,
             p_calc_type_ind            VARCHAR2
           ) RETURN NUMBER IS

-- define local variables

  reduce_need_amt_v                     rptneed.rptneed_reduce_need_amt%TYPE ;                                          -- 81802-2
  unmet_need_v                          rptneed.rptneed_unmet_need_amt%TYPE ;                                           -- 81802-2

BEGIN

  IF p_calc_type_ind = 'A' THEN
    reduce_need_amt_v := f_calc_act_reduce_need_amt(p_pidm, p_aidy_code);
  ELSE
    reduce_need_amt_v := f_calc_sim_reduce_need_amt(p_pidm, p_aidy_code);
  END IF;

  unmet_need_v          := f_calc_gross_need (p_pidm,p_aidy_code) -
                         f_calc_excess_efc_amt (p_pidm,p_aidy_code,p_calc_type_ind) -
                         reduce_need_amt_v;

  RETURN unmet_need_v;

END f_calc_unmet_need;

-------------------------------------------------------------------------------------------------
-- added in 8.9
--

FUNCTION f_calc_year_oth_resource
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE
           ) RETURN NUMBER IS

-- define local variables

  misc_field_v                          VARCHAR2(1);

  oth_act_amt_v                         NUMBER;                                                                         -- 81200-1
  oth_est_amt_v                         NUMBER;                                                                         -- 81200-1

--

  CURSOR calc_resource_amt_c IS
  SELECT SUM(COALESCE(DECODE(RPRARSC_ACTUAL_AMT,'',RPRARSC_EST_AMT,
                    RPRARSC_ACTUAL_AMT),0)),
         SUM(COALESCE(RPRARSC_EST_AMT,0))
    FROM RPRARSC
   WHERE RPRARSC_PIDM           = p_pidm
     AND ( ( RPRARSC_AIDY_CODE  = p_aidy_code
     AND     RPRARSC_TERM_CODE IS NULL
           )
      OR   ( RPRARSC_TERM_CODE IS NOT NULL
     AND     RPRARSC_TERM_CODE IN ( SELECT RORPRDS_TERM_CODE
                                      FROM RORPRDS,
                                           ROBPRDS
                                     WHERE ( ROBPRDS_AIDY_CODE       = p_aidy_code
                                        OR   ROBPRDS_AIDY_CODE_CROSS = p_aidy_code
                                           )
                                       AND robprds_period = rorprds_period
                                 )
           )
         );

   CURSOR check_resource_amt_c IS
   SELECT 'X'
     FROM RPRARSC
    WHERE RPRARSC_PIDM      = p_pidm
     AND ( ( RPRARSC_AIDY_CODE  = p_aidy_code
     AND     RPRARSC_TERM_CODE IS NULL
           )
      OR   ( RPRARSC_TERM_CODE IS NOT NULL
     AND     RPRARSC_TERM_CODE IN ( SELECT RORPRDS_TERM_CODE
                                      FROM RORPRDS,
                                           ROBPRDS
                                     WHERE ( ROBPRDS_AIDY_CODE       = p_aidy_code
                                        OR   ROBPRDS_AIDY_CODE_CROSS = p_aidy_code
                                           )
                                       AND robprds_period = rorprds_period
                                  )
           )
         )
      AND RPRARSC_ACTUAL_AMT   IS NOT NULL;

--

BEGIN

-- Calculate Resource Amount

  IF NOT calc_resource_amt_c%ISOPEN THEN
    OPEN calc_resource_amt_c;
  END IF;

  FETCH calc_resource_amt_c
   INTO oth_act_amt_v,
        oth_est_amt_v;

  IF calc_resource_amt_c%NOTFOUND THEN
     oth_act_amt_v := 0;
     oth_est_amt_v := 0;
  END IF;

  CLOSE calc_resource_amt_c;

  IF NOT check_resource_amt_c%ISOPEN THEN
    OPEN check_resource_amt_c;
  END IF;

  FETCH check_resource_amt_c
   INTO misc_field_v;

  IF check_resource_amt_c%NOTFOUND THEN
     oth_act_amt_v := oth_est_amt_v;
  END IF;

  CLOSE check_resource_amt_c;

  RETURN oth_act_amt_v;

END f_calc_year_oth_resource;

-------------------------------------------------------------------------------------------------
-- added in 8.9
--

FUNCTION f_calc_year_exemptions
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE
           ) RETURN NUMBER IS

-- define local variables

  misc_field_v                          VARCHAR2(1);

  exe_act_amt_v                         NUMBER;                                                                         -- 81200-1
  exe_est_amt_v                         NUMBER;                                                                         -- 81200-1

  always_use_est_ind_v                  rpbopts.rpbopts_always_use_est_ind%TYPE;
  interface_exempt_ind_v                rpbopts.rpbopts_interface_exempt_ind%TYPE;
  assume_full_time_ind_v                rpbopts.rpbopts_assume_full_time_ind%TYPE;
  interface_3party_ind_v                rpbopts.rpbopts_interface_3party_ind%TYPE;
  default_option_ind_v                  rpbopts.rpbopts_default_option_ind%TYPE;
  threequarter_time_pct_v               rpbopts.rpbopts_3quarter_time_pct%TYPE;
  half_time_pct_v                       rpbopts.rpbopts_half_time_pct%TYPE;
  less_half_time_pct_v                  rpbopts.rpbopts_less_half_time_pct%TYPE;

  CURSOR get_resource_options_c IS
  SELECT RPBOPTS_ALWAYS_USE_EST_IND,
         RPBOPTS_INTERFACE_EXEMPT_IND,
         RPBOPTS_ASSUME_FULL_TIME_IND,
         RPBOPTS_INTERFACE_3PARTY_IND,
         RPBOPTS_DEFAULT_OPTION_IND,
         COALESCE(RPBOPTS_3QUARTER_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_HALF_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_LESS_HALF_TIME_PCT,0) * .01
    FROM RPBOPTS
   WHERE RPBOPTS_AIDY_CODE = p_aidy_code;

  CURSOR calc_exemption_amt_c IS
  SELECT SUM(COALESCE(DECODE(f_calc_exemption_payment(TBBESTU_PIDM,
                                             TBBESTU_EXEMPTION_CODE,
                                             TBBESTU_TERM_CODE),
                    '',DECODE(assume_full_time_ind_v,
                              'Y', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT),
                              DECODE(p_load,
                                     '2', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT)
                                          * threequarter_time_pct_v,
                                     '3', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT)
                                          * half_time_pct_v,
                                     '4', COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT)
                                          * less_half_time_pct_v,
                                     COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT))),
                    f_calc_exemption_payment(TBBESTU_PIDM,
                                             TBBESTU_EXEMPTION_CODE,
                                             TBBESTU_TERM_CODE)),0)),
         SUM(COALESCE(COALESCE(TBBESTU_MAX_STUDENT_AMOUNT, RPREXPT_ESTIMATED_AMT),0))
        FROM RPREXPT,
             TBBESTU
       WHERE TBBESTU_EXEMPTION_CODE    = RPREXPT_EXEMPTION_CODE (+)
         AND TBBESTU_TERM_CODE         = RPREXPT_TERM_CODE (+)
         AND TBBESTU_TERM_CODE        IN ( SELECT RORPRDS_TERM_CODE
                                             FROM RORPRDS,
                                                  ROBPRDS
                                            WHERE ( ROBPRDS_AIDY_CODE       = p_aidy_code
                                               OR   ROBPRDS_AIDY_CODE_CROSS = p_aidy_code
                                                  )
                                              AND robprds_period = rorprds_period )
         AND COALESCE(TBBESTU_DEL_IND,'X') <> 'D'
         AND COALESCE(RPREXPT_EXCLUDE_RESOURCE, 'N') = 'N'
         AND TBBESTU_PIDM              = p_pidm;

  CURSOR check_exemption_amt_c IS
  SELECT 'X'
    FROM RPREXPT,
         TBBESTU
   WHERE f_calc_exemption_payment(TBBESTU_PIDM,
                                  TBBESTU_EXEMPTION_CODE,
                                  TBBESTU_TERM_CODE) IS NOT NULL
     AND TBBESTU_EXEMPTION_CODE    = RPREXPT_EXEMPTION_CODE (+)
     AND TBBESTU_TERM_CODE         = RPREXPT_TERM_CODE (+)
     AND TBBESTU_TERM_CODE        IN ( SELECT RORPRDS_TERM_CODE
                                         FROM RORPRDS,
                                              ROBPRDS
                                        WHERE ( ROBPRDS_AIDY_CODE       = p_aidy_code
                                           OR   ROBPRDS_AIDY_CODE_CROSS = p_aidy_code
                                              )
                                          AND robprds_period = rorprds_period )
     AND COALESCE(TBBESTU_DEL_IND,'X') <> 'D'
     AND COALESCE(RPREXPT_EXCLUDE_RESOURCE, 'N') = 'N'
     AND TBBESTU_PIDM              = p_pidm;


BEGIN

-- Obtain Resource Options

  IF NOT get_resource_options_c%ISOPEN THEN
    OPEN get_resource_options_c;
  END IF;

  FETCH get_resource_options_c
   INTO always_use_est_ind_v,
        interface_exempt_ind_v,
        assume_full_time_ind_v,
        interface_3party_ind_v,
        default_option_ind_v,
        threequarter_time_pct_v,
        half_time_pct_v,
        less_half_time_pct_v;

  IF get_resource_options_c%NOTFOUND THEN
     always_use_est_ind_v    := NULL;
     interface_exempt_ind_v  := 'N';
     assume_full_time_ind_v  := NULL;
     interface_3party_ind_v  := 'N';
     default_option_ind_v    := NULL;
     threequarter_time_pct_v := 0;
     half_time_pct_v         := 0;
     less_half_time_pct_v    := 0;
  END IF;

  CLOSE get_resource_options_c;

-- Calculating Actual Resource Amount

<<UCN4>>

  IF interface_exempt_ind_v = 'N' THEN
     exe_act_amt_v := 0;
     exe_est_amt_v := 0;
  ELSE

    IF NOT calc_exemption_amt_c%ISOPEN THEN
      OPEN calc_exemption_amt_c;
    END IF;

    FETCH calc_exemption_amt_c
     INTO exe_act_amt_v,
          exe_est_amt_v;

    IF calc_exemption_amt_c%NOTFOUND THEN
       exe_act_amt_v := 0;
       exe_est_amt_v := 0;
    END IF;

    CLOSE calc_exemption_amt_c;

    IF assume_full_time_ind_v = 'N' THEN
        IF p_load = '2' THEN
            exe_est_amt_v := exe_est_amt_v * threequarter_time_pct_v;
        ELSE
            IF p_load = '3' THEN
                exe_est_amt_v := exe_est_amt_v * half_time_pct_v;
            ELSE
                IF p_load = '4' THEN
                    exe_est_amt_v := exe_est_amt_v * less_half_time_pct_v;
                END IF;
            END IF;
        END IF;
    END IF;

    IF NOT check_exemption_amt_c%ISOPEN THEN
      OPEN check_exemption_amt_c;
    END IF;

    FETCH check_exemption_amt_c
     INTO misc_field_v;

    IF check_exemption_amt_c%NOTFOUND THEN
       exe_act_amt_v := exe_est_amt_v;
    END IF;

    CLOSE check_exemption_amt_c;

  END IF;

  IF always_use_est_ind_v = 'Y' THEN
     exe_act_amt_v := exe_est_amt_v;
  END IF;

  RETURN exe_act_amt_v;

END f_calc_year_exemptions;

-------------------------------------------------------------------------------------------------
-- added in 8.9
--

FUNCTION f_calc_year_contracts
           ( p_pidm                     rcrapp1.rcrapp1_pidm%TYPE,
             p_aidy_code                rcrapp1.rcrapp1_aidy_code%TYPE,
             p_load                     rcrapp1.rcrapp1_exp_enroll_status%TYPE
           ) RETURN NUMBER IS

-- define local variables

  misc_field_v                          VARCHAR2(1);

  con_act_amt_v                         NUMBER;                                                                         -- 81200-1
  con_est_amt_v                         NUMBER;                                                                         -- 81200-1

  always_use_est_ind_v                  rpbopts.rpbopts_always_use_est_ind%TYPE;
  interface_exempt_ind_v                rpbopts.rpbopts_interface_exempt_ind%TYPE;
  assume_full_time_ind_v                rpbopts.rpbopts_assume_full_time_ind%TYPE;
  interface_3party_ind_v                rpbopts.rpbopts_interface_3party_ind%TYPE;
  default_option_ind_v                  rpbopts.rpbopts_default_option_ind%TYPE;
  threequarter_time_pct_v               rpbopts.rpbopts_3quarter_time_pct%TYPE;
  half_time_pct_v                       rpbopts.rpbopts_half_time_pct%TYPE;
  less_half_time_pct_v                  rpbopts.rpbopts_less_half_time_pct%TYPE;

--

  CURSOR get_resource_options_c IS
  SELECT RPBOPTS_ALWAYS_USE_EST_IND,
         RPBOPTS_INTERFACE_EXEMPT_IND,
         RPBOPTS_ASSUME_FULL_TIME_IND,
         RPBOPTS_INTERFACE_3PARTY_IND,
         RPBOPTS_DEFAULT_OPTION_IND,
         COALESCE(RPBOPTS_3QUARTER_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_HALF_TIME_PCT,0) * .01,
         COALESCE(RPBOPTS_LESS_HALF_TIME_PCT,0) * .01
    FROM RPBOPTS
   WHERE RPBOPTS_AIDY_CODE = p_aidy_code;

--

  CURSOR calc_contract_amt_c IS
  SELECT SUM(COALESCE(DECODE(f_calc_contract_payment(TBBCSTU_STU_PIDM,
                                            TBBCSTU_CONTRACT_PIDM,
                                            TBBCSTU_CONTRACT_NUMBER,
                                            TBBCSTU_TERM_CODE),
                    '',DECODE(assume_full_time_ind_v,
                              'Y', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT),
                                 DECODE(p_load,
                                         '2', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT)
                                          * threequarter_time_pct_v,
                                         '3', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT)
                                          * half_time_pct_v,
                                         '4', COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT)
                                          * less_half_time_pct_v,
                                         COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT))),
                       f_calc_contract_payment(TBBCSTU_STU_PIDM,
                                            TBBCSTU_CONTRACT_PIDM,
                                            TBBCSTU_CONTRACT_NUMBER,
                                            TBBCSTU_TERM_CODE)),0)),
         SUM(COALESCE(COALESCE(TBBCSTU_MAX_STUDENT_AMOUNT, RPRCONT_ESTIMATED_AMT),0))
    FROM RPRCONT,
         TBBCSTU
   WHERE TBBCSTU_CONTRACT_PIDM     = RPRCONT_CONTRACT_PIDM (+)
     AND TBBCSTU_CONTRACT_NUMBER   = RPRCONT_CONTRACT_NO (+)
     AND TBBCSTU_TERM_CODE         = RPRCONT_TERM_CODE (+)
     AND TBBCSTU_TERM_CODE        IN ( SELECT RORPRDS_TERM_CODE
                                         FROM RORPRDS,
                                              ROBPRDS
                                        WHERE ( ROBPRDS_AIDY_CODE       = p_aidy_code
                                           OR   ROBPRDS_AIDY_CODE_CROSS = p_aidy_code
                                              )
                                          AND robprds_period            = rorprds_period )
     AND COALESCE(TBBCSTU_DEL_IND,'X') <> 'D'
     AND COALESCE(RPRCONT_EXCLUDE_RESOURCE, 'N') = 'N'
     AND TBBCSTU_STU_PIDM          = p_pidm;

--

    CURSOR check_contract_amt_c IS
    SELECT 'X'
      FROM RPRCONT,
           TBBCSTU
     WHERE f_calc_contract_payment(TBBCSTU_STU_PIDM,
                                   TBBCSTU_CONTRACT_PIDM,
                                   TBBCSTU_CONTRACT_NUMBER,
                                   TBBCSTU_TERM_CODE) IS NOT NULL
       AND TBBCSTU_CONTRACT_PIDM     = RPRCONT_CONTRACT_PIDM (+)
       AND TBBCSTU_CONTRACT_NUMBER   = RPRCONT_CONTRACT_NO (+)
       AND TBBCSTU_TERM_CODE         = RPRCONT_TERM_CODE (+)
       AND TBBCSTU_TERM_CODE        IN ( SELECT RORPRDS_TERM_CODE
                                           FROM RORPRDS,
                                                ROBPRDS
                                        WHERE ( ROBPRDS_AIDY_CODE       = p_aidy_code
                                           OR   ROBPRDS_AIDY_CODE_CROSS = p_aidy_code
                                              )
                                          AND robprds_period            = rorprds_period )
       AND COALESCE(TBBCSTU_DEL_IND,'X') <> 'D'
       AND COALESCE(RPRCONT_EXCLUDE_RESOURCE, 'N') = 'N'
       AND TBBCSTU_STU_PIDM          = p_pidm;

BEGIN

-- Obtain Resource Options

  IF NOT get_resource_options_c%ISOPEN THEN
    OPEN get_resource_options_c;
  END IF;

  FETCH get_resource_options_c
   INTO always_use_est_ind_v,
        interface_exempt_ind_v,
        assume_full_time_ind_v,
        interface_3party_ind_v,
        default_option_ind_v,
        threequarter_time_pct_v,
        half_time_pct_v,
        less_half_time_pct_v;

  IF get_resource_options_c%NOTFOUND THEN
     always_use_est_ind_v    := NULL;
     interface_exempt_ind_v  := 'N';
     assume_full_time_ind_v  := NULL;
     interface_3party_ind_v  := 'N';
     default_option_ind_v    := NULL;
     threequarter_time_pct_v := 0;
     half_time_pct_v         := 0;
     less_half_time_pct_v    := 0;
  END IF;

  CLOSE get_resource_options_c;


-- Calculating Actual Resource Amount

  IF interface_3party_ind_v = 'N' THEN
     con_act_amt_v := 0;
     con_est_amt_v := 0;
  ELSE

-- Calculating Actual Contract Amount

    IF NOT calc_contract_amt_c%ISOPEN THEN
      OPEN calc_contract_amt_c;
    END IF;

    FETCH calc_contract_amt_c
     INTO con_act_amt_v,
          con_est_amt_v;

    IF calc_contract_amt_c%NOTFOUND THEN
       con_act_amt_v := 0;
       con_est_amt_v := 0;
    END IF;

    CLOSE calc_contract_amt_c;

-- Prorate Estimated Resource Based Upon Applicant's Enrollment Status

    IF assume_full_time_ind_v = 'N' THEN
        IF p_load = '2' THEN
            con_est_amt_v := con_est_amt_v * threequarter_time_pct_v;
        ELSE
            IF p_load = '3' THEN
                con_est_amt_v := con_est_amt_v * half_time_pct_v;
            ELSE
                IF p_load = '4' THEN
                    con_est_amt_v := con_est_amt_v * less_half_time_pct_v;
                END IF;
            END IF;
        END IF;
    END IF;

    IF NOT check_contract_amt_c%ISOPEN THEN
      OPEN check_contract_amt_c;
    END IF;

    FETCH check_contract_amt_c
     INTO misc_field_v;

    IF check_contract_amt_c%NOTFOUND THEN
       con_act_amt_v := con_est_amt_v;
    END IF;

    CLOSE check_contract_amt_c;

  END IF;

<<UCN7>>
  IF always_use_est_ind_v = 'Y' THEN
     con_act_amt_v := con_est_amt_v;
  END IF;

-- *DEBUG* DBMS_OUTPUT.PUT_LINE ('con_act_amt_v = ' || con_act_amt_v);

  RETURN con_act_amt_v;

END f_calc_year_contracts;

-------------------------------------------------------------------------------------------------
--  procedure added for 8.14.1 (Period Budgeting)

FUNCTION f_get_need_data
            ( p_pidm                    rprawrd.rprawrd_pidm%TYPE,
              p_aidy_code               rprawrd.rprawrd_aidy_code%TYPE,
              p_calc_type_ind           indicator_type                DEFAULT 'A',
              p_run_name                rbrapbc.rbrapbc_run_name%TYPE DEFAULT rb_budget_run.M_ACTUAL_RUN
            ) RETURN NeedRecType IS

  lv_NeedRec                            NeedRecType;
  lv_load                               rorstat.rorstat_xes%TYPE;                                                       -- 81801-1
  lv_fm_efc_max                         rptneed.rptneed_fm_efc_amt%TYPE;                                                -- 81802-2
  lv_im_efc_max                         rptneed.rptneed_im_efc_amt%TYPE;                                                -- 81802-2

BEGIN

  lv_NeedRec.efc_ind           := f_find_efc_ind
                                    ( p_pidm          =>  p_pidm,
                                      p_aidy_code     =>  p_aidy_code,
                                      p_run_name      =>  p_run_name
                                    ) ;

  lv_load                      := f_calc_load
                                    ( p_pidm       =>  p_pidm,
                                      p_aidy_code  =>  p_aidy_code
                                    ) ;

-- budget processing

  IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'N' THEN
      lv_NeedRec.budget_amount    := f_calc_budget_amt
                                       ( p_pidm       =>  p_pidm,
                                         p_aidy_code  =>  p_aidy_code
                                       );
      lv_NeedRec.fm_budget_amount := lv_NeedRec.budget_amount;
      lv_NeedRec.im_budget_amount := lv_NeedRec.budget_amount;
  ELSE
      lv_NeedRec.fm_budget_amount := f_calc_period_budget_amt
                                       ( p_pidm          =>  p_pidm,
                                         p_aidy_code     =>  p_aidy_code,
                                         p_type_ind      =>  'F',
                                         p_run_name      =>  p_run_name
                                       ) ;
      lv_NeedRec.budget_amount := lv_NeedRec.fm_budget_amount;
      IF lv_NeedRec.efc_ind = 'I' THEN
          lv_NeedRec.im_budget_amount := f_calc_period_budget_amt
                                           ( p_pidm          =>  p_pidm,
                                             p_aidy_code     =>  p_aidy_code,
                                             p_type_ind      =>  'I',
                                             p_run_name      =>  p_run_name
                                           ) ;
          lv_NeedRec.budget_amount := lv_NeedRec.im_budget_amount;
     END IF;
  END IF;

  lv_NeedRec.resource_amount   := f_calc_resource(p_pidm, p_aidy_code,lv_load);

  IF p_calc_type_ind = 'A' THEN
    lv_NeedRec.replace_efc_amt := f_calc_act_replace_efc_amt(p_pidm, p_aidy_code);
  ELSE
    lv_NeedRec.replace_efc_amt := f_calc_sim_replace_efc_amt(p_pidm, p_aidy_code);
  END IF;

  IF p_calc_type_ind = 'A' THEN
    lv_NeedRec.reduce_need_amt := f_calc_act_reduce_need_amt(p_pidm, p_aidy_code);
  ELSE
    lv_NeedRec.reduce_need_amt := f_calc_sim_reduce_need_amt(p_pidm, p_aidy_code);
  END IF;

  IF rb_common.f_sel_robinst_aidy_end_year(p_aidy_code) <= 2014 THEN                                                    -- 81802-2
      lv_fm_efc_max  :=  M_OLD_FM_EFC_MAX;                                                                              -- 81802-2
      lv_im_efc_max  :=  M_OLD_IM_EFC_MAX;                                                                              -- 81802-2
  ELSE                                                                                                                  -- 81802-2
      lv_fm_efc_max  :=  M_NEW_FM_EFC_MAX;                                                                              -- 81802-2
      lv_im_efc_max  :=  M_NEW_IM_EFC_MAX;                                                                              -- 81802-2
  END IF;                                                                                                               -- 81802-2

-- FM Processing

  lv_NeedRec.fm_efc_amt        := f_calc_efc                                                                            -- 82201-2
                                    ( p_pidm       =>  p_pidm,                                                          -- 82201-2
                                      p_aidy_code  =>  p_aidy_code                                                      -- 82201-2
                                    ) ;                                                                                 -- 82201-2

  IF lv_NeedRec.fm_budget_amount IS NULL THEN                                                                           -- 81802-1
      GOTO im_processing;                                                                                               -- 81802-1
  END IF;                                                                                                               -- 81802-1

  IF lv_NeedRec.fm_efc_amt IS NULL THEN                                                                                 -- 81802-1
      lv_NeedRec.fm_gross_need := 0;                                                                                    -- 81802-1
  ELSE                                                                                                                  -- 81802-1
      lv_NeedRec.fm_gross_need     := lv_NeedRec.fm_budget_amount  -                                                    -- 81802-1
                                      COALESCE(lv_NeedRec.fm_efc_amt,lv_fm_efc_max) -                                        -- 81802-1
                                      lv_NeedRec.resource_amount;                                                       -- 81802-1
  END IF;                                                                                                               -- 81802-1

  IF lv_NeedRec.fm_gross_need < 0 THEN
      lv_NeedRec.fm_gross_need     := 0;
  END IF;

  IF lv_NeedRec.fm_efc_amt IS NULL THEN                                                                                 -- 81802-2
     lv_NeedRec.fm_excess_efc_amt := lv_NeedRec.replace_efc_amt;                                                        -- 81802-2
  ELSE                                                                                                                  -- 81802-2
    IF lv_NeedRec.replace_efc_amt > lv_NeedRec.fm_efc_amt THEN
       lv_NeedRec.fm_excess_efc_amt := lv_NeedRec.replace_efc_amt -
                                       lv_NeedRec.fm_efc_amt;
    ELSE
       lv_NeedRec.fm_excess_efc_amt := 0;
    END IF;
  END IF;                                                                                                               -- 81802-2

  lv_NeedRec.fm_unmet_need     := lv_NeedRec.fm_gross_need     -                                                        -- 81802-2
                                  lv_NeedRec.fm_excess_efc_amt -
                                  lv_NeedRec.reduce_need_amt;

-- IM Processing

   << im_processing >>                                                                                                  -- 81802-1

  lv_NeedRec.im_efc_amt        := f_calc_im_efc                                                                         -- 82201-2
                                    ( p_pidm       =>  p_pidm,                                                          -- 82201-2
                                      p_aidy_code  =>  p_aidy_code                                                      -- 82201-2
                                    ) ;                                                                                 -- 82201-2

  IF lv_NeedRec.im_budget_amount IS NULL THEN                                                                           -- 82201-1
      GOTO end_processing;                                                                                              -- 82201-1
  END IF;                                                                                                               -- 82201-1

  IF lv_NeedRec.im_efc_amt IS NULL THEN                                                                                 -- 81802-2
      lv_NeedRec.im_gross_need := 0;                                                                                    -- 81802-2
  ELSE                                                                                                                  -- 81802-2
      lv_NeedRec.im_gross_need     := lv_NeedRec.im_budget_amount              -                                        -- 81802-2
                                      COALESCE(lv_NeedRec.im_efc_amt,lv_im_efc_max) -                                        -- 81802-2
                                      lv_NeedRec.resource_amount;                                                       -- 81802-2
  END IF;                                                                                                               -- 81802-2

  IF lv_NeedRec.im_gross_need < 0 THEN
      lv_NeedRec.im_gross_need     := 0;
  END IF;

  IF lv_NeedRec.im_efc_amt IS NULL THEN                                                                                 -- 81802-2
     lv_NeedRec.im_excess_efc_amt := lv_NeedRec.replace_efc_amt;                                                        -- 81802-2
  ELSE                                                                                                                  -- 81802-2
    IF lv_NeedRec.replace_efc_amt > lv_NeedRec.im_efc_amt THEN
       lv_NeedRec.im_excess_efc_amt := lv_NeedRec.replace_efc_amt -
                                       lv_NeedRec.im_efc_amt;
    ELSE
       lv_NeedRec.im_excess_efc_amt := 0;
    END IF;
  END IF;                                                                                                               -- 81802-2

  lv_NeedRec.im_unmet_need     := lv_NeedRec.im_gross_need     -                                                        -- 81802-2
                                  lv_NeedRec.im_excess_efc_amt -
                                  lv_NeedRec.reduce_need_amt;

-- If FM processing, null IM values else null FM values

  IF lv_NeedRec.efc_ind = 'F' THEN
     lv_NeedRec.im_budget_amount  := NULL;
     lv_NeedRec.im_efc_amt        := NULL;
     lv_NeedRec.im_gross_need     := NULL;
     lv_NeedRec.im_excess_efc_amt := NULL;
     lv_NeedRec.im_unmet_need     := NULL;
  END IF;

--  IF lv_NeedRec.fm_efc_amt = lv_fm_efc_max THEN                                                                       -- 81802-2
--     lv_NeedRec.fm_efc_amt  := NULL;                                                                                  -- 81802-2
--  END IF;                                                                                                             -- 81802-2

--  IF lv_NeedRec.im_efc_amt = lv_im_efc_max THEN                                                                       -- 81802-2
--     lv_NeedRec.im_efc_amt  := NULL;                                                                                  -- 81802-2
--  END IF;                                                                                                             -- 81802-2

   << end_processing >>                                                                                                 -- 82201-1

  lv_NeedRec.offer_amt :=  f_calc_offer_amt
                             ( p_pidm          =>  p_pidm,
                               p_aidy_code     =>  p_aidy_code,
                               p_calc_type_ind =>  p_calc_type_ind
                             ) ;

  lv_NeedRec.pell_award :=  f_calc_pell_award
                              ( p_pidm          =>  p_pidm,
                                p_aidy_code     =>  p_aidy_code
                              ) ;

  RETURN lv_NeedRec;

END f_get_need_data;

-------------------------------------------------------------------------------------------------
--  procedure added for 8.14.1 (Period Budgeting)

PROCEDURE p_get_budget_group_data
            ( p_pidm                              rorstat.rorstat_pidm%TYPE,
              p_aidy_code                         rorstat.rorstat_aidy_code%TYPE,
              p_budget_group_out          OUT     rorstat.rorstat_bgrp_code%TYPE,
              p_budget_group_ind_out      OUT     indicator_type
            ) IS

  CURSOR rorstat_c IS
         SELECT rorstat_bgrp_code
           FROM rorstat
          WHERE rorstat_pidm      = p_pidm
            AND rorstat_aidy_code = p_aidy_code ;

  CURSOR rbrapbg_c IS
         SELECT rbrapbg_pbgp_code
           FROM robprds,
                rbrapbg
          WHERE rbrapbg_pidm      = p_pidm
            AND rbrapbg_aidy_code = p_aidy_code
            AND rbrapbg_period    = robprds_period
            AND rbrapbg_run_name  = rb_budget_run.M_ACTUAL_RUN
       ORDER BY robprds_seq_no ;

  CURSOR rbrapbg_ind_c IS
         SELECT '*'
           FROM rbrapbg
          WHERE rbrapbg_pidm       = p_pidm
            AND rbrapbg_aidy_code  = p_aidy_code
            AND rbrapbg_pbgp_code <> p_budget_group_out
            AND rbrapbg_run_name   = rb_budget_run.M_ACTUAL_RUN ;

BEGIN

  IF rbk_period_budget.f_period_budget_enabled(p_aidy_code) = 'N' THEN
      p_budget_group_ind_out    := NULL;
      OPEN  rorstat_c;
      FETCH rorstat_c INTO p_budget_group_out ;
      IF rorstat_c%NOTFOUND THEN
          p_budget_group_out       := NULL;
      END IF;
      CLOSE rorstat_c;
  ELSE
      OPEN  rbrapbg_c;
      FETCH rbrapbg_c INTO p_budget_group_out ;
      IF rbrapbg_c%NOTFOUND THEN
          p_budget_group_out       := NULL;
          p_budget_group_ind_out   := NULL;
      END IF;
      CLOSE rbrapbg_c;

      IF p_budget_group_out IS NOT NULL THEN
          OPEN  rbrapbg_ind_c;
          FETCH rbrapbg_ind_c INTO p_budget_group_ind_out ;
          IF rbrapbg_ind_c%NOTFOUND THEN
             p_budget_group_ind_out    := NULL;
          END IF;
          CLOSE rbrapbg_ind_c;
      END IF;

  END IF;

END p_get_budget_group_data;

-------------------------------------------------------------------------------------------------
-- added in 8.9
--

PROCEDURE p_get_crossover_data
            ( p_pidm                    rprawrd.rprawrd_pidm%TYPE,
              p_aidy_code               rprawrd.rprawrd_aidy_code%TYPE,
              p_pell_award_out    OUT   rprawrd.rprawrd_offer_amt%TYPE,
              p_aidy_code_out     OUT   rprawrd.rprawrd_aidy_code%TYPE
            ) IS

  CURSOR crossover_c IS
         SELECT SUM(rpratrm_offer_amt), rpratrm_aidy_code
           FROM robinst,                                                                                                -- 81300-1
                rpratrm x
          WHERE rpratrm_pidm                         = p_pidm
            AND rpratrm_fund_code                   IN ( SELECT rfrbase_fund_code
                                                           FROM rfrbase
                                                          WHERE rfrbase_fed_fund_id = 'PELL'
                                                        )
            AND rpratrm_aidy_code                   <> p_aidy_code
            AND rpratrm_aidy_code                    = robinst_aidy_code                                                -- 81300-1
--            AND EXISTS                                                                                                -- 81100-1
--                   ( SELECT 'Y'                                                                                       -- 81100-1
--                       FROM rpratrm                                                                                   -- 81100-1
--                      where rpratrm_pidm            = x.rpratrm_pidm                                                  -- 81100-1
--                        and rpratrm_aidy_code       = p_aidy_code                                                     -- 81100-1
--                        and rpratrm_fund_code       = x.rpratrm_fund_code                                             -- 81100-1
--                        and rpratrm_period          = x.rpratrm_period                                                -- 81100-1
--                   )                                                                                                  -- 81100-1
           AND EXISTS                                                                                                   -- 81100-1
                ( SELECT 'Y'                                                                                            -- 81100-1
                    FROM robprds                                                                                        -- 81100-1
                   WHERE robprds_period = x.rpratrm_period                                                              -- 81100-1
                     AND x.rpratrm_aidy_code IN (robprds_aidy_code,robprds_aidy_code_cross)                             -- 81100-1
                     AND robprds_crossover_ind = 'Y'                                                                    -- 81100-1
                )                                                                                                       -- 81100-1
            AND EXISTS                                                                                                  -- 81100-1
                ( SELECT 'Y'                                                                                            -- 81100-1
                    FROM rorstat y                                                                                      -- 81100-1
                   WHERE rorstat_pidm      = p_pidm                                                                     -- 81100-1
                     AND rorstat_aidy_code = p_aidy_code                                                                -- 81100-1
                     AND ( EXISTS                                                                                       -- 81100-1
                           ( SELECT 'Y'                                                                                 -- 81100-1
                               FROM rortprd,                                                                            -- 81100-1
                                    robprds                                                                             -- 81100-1
                              WHERE rortprd_aprd_code     = y.rorstat_aprd_code                                         -- 81100-1
                                AND rortprd_aidy_code     = y.rorstat_aidy_code                                         -- 81100-1
                                and rortprd_period        = robprds_period                                              -- 81100-1
                                and rortprd_period        = x.rpratrm_period                                            -- 81300-1
                                and robprds_crossover_ind = 'Y'                                                         -- 81100-1
                           )                                                                                            -- 81100-1
                      OR   EXISTS                                                                                       -- 81100-1
                           ( SELECT 'Y'                                                                                 -- 81100-1
                               FROM rortprd,                                                                            -- 81100-1
                                    robprds                                                                             -- 81100-1
                              WHERE rortprd_aprd_code     = y.rorstat_aprd_code_pell                                    -- 81100-1
                                AND rortprd_aidy_code     = y.rorstat_aidy_code                                         -- 81100-1
                                and rortprd_period        = robprds_period                                              -- 81100-1
                                and rortprd_period        = x.rpratrm_period                                            -- 81300-1
                                and robprds_crossover_ind = 'Y'                                                         -- 81100-1
                           )                                                                                            -- 81100-1
                         )                                                                                              -- 81100-1
                )                                                                                                       -- 81100-1
       GROUP BY rpratrm_aidy_code, robinst_aidy_end_year                                                                -- 81300-1
       ORDER BY robinst_aidy_end_year ;                                                                                 -- 81300-1

BEGIN

  OPEN  crossover_c;
  FETCH crossover_c INTO p_pell_award_out,
                         p_aidy_code_out ;
  IF crossover_c%NOTFOUND THEN
      p_pell_award_out := NULL;
      p_aidy_code_out  := NULL;
  END IF;
  CLOSE crossover_c;

END p_get_crossover_data;

-------------------------------------------------------------------------------------------------
--  procedure added for 8.14.1 (Period Budgeting)

PROCEDURE p_get_need_summary                                                                                            -- 81401-1
            ( p_pidm                           rorstat.rorstat_pidm%TYPE,                                               -- 81401-1
              p_aidy_code                      rprawrd.rprawrd_aidy_code%TYPE,                                          -- 81401-1
              p_aprd_code_out             OUT  rorstat.rorstat_aprd_code%TYPE,                                          -- 81401-1
              p_aprd_code_pell_out        OUT  rorstat.rorstat_aprd_code_pell%TYPE,                                     -- 81401-1
              p_offer_amt_out             OUT  large_amount_type,                                                       -- 81801-1
              p_resource_amt_out          OUT  rptneed.rptneed_resource_amount%TYPE,                                    -- 81802-2
              p_crossover_pell_award_out  OUT  amount_type,                                                             -- 81401-1
              p_crossover_aidy_code_out   OUT  rprawrd.rprawrd_aidy_code%TYPE,                                          -- 81401-1
              p_fm_budget_amt_out         OUT  rptneed.rptneed_budget_amount%TYPE,                                      -- 81802-2
              p_fm_efc_out                OUT  rptneed.rptneed_fm_efc_amt%TYPE,                                         -- 81401-1
              p_fm_gross_need_out         OUT  rptneed.rptneed_gross_need_amt%TYPE,                                     -- 81802-2
              p_fm_unmet_need_out         OUT  rptneed.rptneed_unmet_need_amt%TYPE,                                     -- 81802-2
              p_im_budget_amt_out         OUT  rptneed.rptneed_budget_amount%TYPE,                                      -- 81802-2
              p_im_efc_out                OUT  rptneed.rptneed_im_efc_amt%TYPE,                                         -- 81401-1
              p_im_gross_need_out         OUT  rptneed.rptneed_im_gross_need_amt%TYPE,                                  -- 81802-2
              p_im_unmet_need_out         OUT  rptneed.rptneed_im_unmet_need_amt%TYPE,                                  -- 81802-2
              p_pell_budget_amt_out       OUT  rptneed.rptneed_budget_amount%TYPE,                                      -- 81802-1
              p_pell_efc_out              OUT  efc_type,                                                                -- 81401-1
              p_budget_group_out          OUT  rorstat.rorstat_bgrp_code%TYPE,                                          -- 81401-1
              p_budget_group_ind_out      OUT  indicator_type,                                                          -- 81401-1
              p_bbay_awarded_out          OUT  indicator_type                                                           -- 82201-1
            ) IS

  lv_NeedRec                                   NeedRecType;

  CURSOR rorstat_c IS
         SELECT rorstat_aprd_code,
                rorstat_aprd_code_pell
           FROM rorstat
          WHERE rorstat_pidm      = p_pidm
            AND rorstat_aidy_code = p_aidy_code ;

BEGIN

  lv_NeedRec  :=  f_get_need_data
                    ( p_pidm              =>  p_pidm,
                      p_aidy_code         =>  p_aidy_code
                     ) ;

  OPEN  rorstat_c;
  FETCH rorstat_c INTO p_aprd_code_out,
                       p_aprd_code_pell_out ;
  IF rorstat_c%NOTFOUND THEN
      p_aprd_code_out       := NULL;
      p_aprd_code_pell_out  := NULL;
  END IF;
  CLOSE rorstat_c;

  p_offer_amt_out                  :=  lv_NeedRec.offer_amt;
  p_resource_amt_out               :=  lv_NeedRec.resource_amount;

  p_get_crossover_data
            ( p_pidm            =>  p_pidm,
              p_aidy_code       =>  p_aidy_code,
              p_pell_award_out  =>  p_crossover_pell_award_out,
              p_aidy_code_out   =>  p_crossover_aidy_code_out
            );

  p_fm_budget_amt_out              :=  lv_NeedRec.fm_budget_amount;
  p_fm_efc_out                     :=  lv_NeedRec.fm_efc_amt;
  p_fm_gross_need_out              :=  lv_NeedRec.fm_gross_need;
  p_fm_unmet_need_out              :=  lv_NeedRec.fm_unmet_need;
  p_im_budget_amt_out              :=  lv_NeedRec.im_budget_amount;
  p_im_efc_out                     :=  lv_NeedRec.im_efc_amt;
  p_im_gross_need_out              :=  lv_NeedRec.im_gross_need ;
  p_im_unmet_need_out              :=  lv_NeedRec.im_unmet_need;
  p_pell_budget_amt_out            :=  f_calc_pell_budget_amt(p_pidm,p_aidy_code);
  p_pell_efc_out                   :=  f_calc_pell_efc(p_pidm,p_aidy_code);

  p_get_budget_group_data
            ( p_pidm                   =>  p_pidm,
              p_aidy_code              =>  p_aidy_code,
              p_budget_group_out       =>  p_budget_group_out,
              p_budget_group_ind_out   =>  p_budget_group_ind_out
            );

  p_bbay_awarded_out               :=  rpk_bbay.f_bbay_awarded
                                                  ( p_pidm       =>  p_pidm,
                                                    p_aidy_code  =>  p_aidy_code
                                                  );

END p_get_need_summary;

-------------------------------------------------------------------------------------------------

END rnkneed;        /* this ends the package */
/
