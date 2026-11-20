CREATE OR REPLACE PACKAGE ROKMISC AS
--AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : ROKMISC
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Tue May 08 08:57:02 2012
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
--
-- FILE NAME..: rokmisc.sql
-- RELEASE....: 8.14.2
-- OBJECT NAME: ROKMISC
-- PRODUCT....: FINAID
-- USAGE......: Retrieve appropriate class info for financial aid.
-- COPYRIGHT..: Copyright 2003-2012 Datatel+SGHE. All Rights Reserved.
--
-- DESCRIPTION:
--
-- This Package contains functions and procedures required to
-- support the OL:R functionality in financial aid.
--
-- Functions:
--
--   f_calc_attend_fa_credit_hrs    - Calculates the student's financial aid attending
--                                    credit hours for an attendance date.
--
--   f_calc_attend_fa_bill_hrs      - Calculates the student's financial aid attending
--                                    billing hours for an attendance date.
--
--   f_calc_attend_fa_adj_hrs       - Calculates the student's financial aid attending
--                                    adjusted hours for an attendance date.
--
--   f_calc_attend_stud_credit_hrs  - Calculates the student's attending credit hours
--                                    for an attendance date.
--
--   f_calc_attend_stud_bill_hrs    - Calculates the student's attending billing hours
--                                    for an attendance date.
--
--   f_calc_attend_stud_adj_hrs     - Calculates the student's attending adjusted hours
--                                    for an attendance date.
-- 08080000-1
--   f_calc_earned_hours            - Calculates the student's earned hours for a term.
--
--   f_calc_stud_credit_hrs         - Calculates the student's credit hours for a term.
--
--   f_calc_stud_bill_hrs           - Calculates the student's billing hours for a term.
--
--   f_calc_stud_adj_hrs            - Calculates the student's adjusted hours for a term.
--
--   f_get_fa_first_attend_date     - Finds the student's first attendance date for
--                                    financial aid for a term.
--
--   f_get_olr_course_exists        - Finds whether the student is enrolled in open learning
--                                    courses.  The function returns a 'Y' or 'N'.
--
--   f_get_stud_first_attend_date   - Finds the student's first attendance date for a term.
--
-- Procedures:
--
--   p_resched_term_disburse        - Reschedules a student's disbursement schedule for a
--                                    term.
--
--   p_resched_year_disburse        - Reschedules a student's disbursement schedule for all
--                                    terms in an aid year.
--
--   p_resched_fund_term_disburse   - Reschedules a student's disbursement schedule for a
--                                    fund for a term.
--
--   p_resched_fund_year_disburse   - Reschedules a student's disbursement schedule for a
--                                    fund for all terms in an aid year.
--
-- DESCRIPTION END
--
-- declare package functions
--

  FUNCTION f_calc_attend_fa_credit_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_enrr_code                        roratnd.roratnd_enrr_code%TYPE DEFAULT rb_enrollment_rules.M_STANDARD -- 81402-1
             ) RETURN NUMBER;
--  PRAGMA RESTRICT_REFERENCES(f_calc_attend_fa_credit_hrs, WNDS, WNPS, RNPS);                                          -- 81402-1

  -- 081200-2 - moved from being a private member of rokmisc_period to a public member of rokmisc
  --  overwrote previous unused version in rokmisc with logic from rokmisc_period
  FUNCTION f_calc_attend_fa_bill_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_enrr_code                        roratnd.roratnd_enrr_code%TYPE DEFAULT rb_enrollment_rules.M_STANDARD -- 81402-1
             ) RETURN NUMBER ;
--  PRAGMA RESTRICT_REFERENCES(f_calc_attend_fa_bill_hrs, WNDS, WNPS, RNPS);                                            -- 81402-1

  -- 081200-2 - moved from being a private member of rokmisc_period to a public member of rokmisc
  --  overwrote previous unused version in rokmisc with logic from rokmisc_period
  FUNCTION f_calc_attend_fa_adj_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_enrr_code                        roratnd.roratnd_enrr_code%TYPE DEFAULT rb_enrollment_rules.M_STANDARD -- 81402-1
             ) RETURN NUMBER ;
--  PRAGMA RESTRICT_REFERENCES(f_calc_attend_fa_adj_hrs, WNDS, WNPS, RNPS);                                             -- 81402-1

  FUNCTION f_calc_attend_stud_credit_hrs (p_term_code    IN  roratnd.roratnd_term_code%TYPE,
                                          p_pidm         IN  roratnd.roratnd_pidm%TYPE,
                                          p_attend_date  IN  roratnd.roratnd_attend_date%TYPE,
                                          p_repeat_ind   IN  VARCHAR2 DEFAULT 'N')                -- 081200-1
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(f_calc_attend_stud_credit_hrs, WNDS, WNPS, RNPS);

  FUNCTION f_calc_attend_stud_bill_hrs (p_term_code    IN  roratnd.roratnd_term_code%TYPE,
                                        p_pidm         IN  roratnd.roratnd_pidm%TYPE,
                                        p_attend_date  IN  roratnd.roratnd_attend_date%TYPE,
                                        p_repeat_ind   IN  VARCHAR2 DEFAULT 'N')                  -- 081200-1
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(f_calc_attend_stud_bill_hrs, WNDS, WNPS, RNPS);

  FUNCTION f_calc_attend_stud_adj_hrs (p_term_code    IN  roratnd.roratnd_term_code%TYPE,
                                       p_pidm         IN  roratnd.roratnd_pidm%TYPE,
                                       p_attend_date  IN  roratnd.roratnd_attend_date%TYPE,
                                       p_repeat_ind   IN  VARCHAR2 DEFAULT 'N')                   -- 081200-1
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(f_calc_attend_stud_adj_hrs, WNDS, WNPS, RNPS);

/* 08080000-1 */
  FUNCTION f_calc_earned_hours (p_term_code	IN  shrtgpa.shrtgpa_term_code%TYPE,
                                p_pidm	    IN  shrtgpa.shrtgpa_pidm%TYPE)
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(f_calc_earned_hours, WNDS, WNPS, RNPS);

  FUNCTION f_calc_stud_credit_hrs (p_term_code    IN  rorenrl.rorenrl_term_code%TYPE,
                                   p_pidm         IN  rorenrl.rorenrl_pidm%TYPE,
                                   p_repeat_ind   IN  VARCHAR2 DEFAULT 'N')                       -- 081200-1
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(f_calc_stud_credit_hrs, WNDS, WNPS, RNPS);

  FUNCTION f_calc_stud_bill_hrs (p_term_code    IN  rorenrl.rorenrl_term_code%TYPE,
                                 p_pidm         IN  rorenrl.rorenrl_pidm%TYPE,
                                 p_repeat_ind   IN  VARCHAR2 DEFAULT 'N')                         -- 081200-1
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(f_calc_stud_bill_hrs, WNDS, WNPS, RNPS);

  FUNCTION f_calc_stud_adj_hrs (p_term_code    IN  rorenrl.rorenrl_term_code%TYPE,
                                p_pidm         IN  rorenrl.rorenrl_pidm%TYPE,
                                p_repeat_ind   IN  VARCHAR2 DEFAULT 'N')                          -- 081200-1
           RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(f_calc_stud_adj_hrs, WNDS, WNPS, RNPS);

  FUNCTION f_get_stud_first_attend_date (p_term_code    IN  rovstcr.rovstcr_term_code%TYPE,
                                         p_pidm         IN  rovstcr.rovstcr_pidm%TYPE)
           RETURN DATE;

  FUNCTION f_get_fa_first_attend_date (p_term_code    IN  rovstcr.rovstcr_term_code%TYPE,
                                       p_pidm         IN  rovstcr.rovstcr_pidm%TYPE)
           RETURN DATE;

  FUNCTION f_get_olr_course_exists (p_term_code    IN  rovstcr.rovstcr_term_code%TYPE,
                                    p_pidm         IN  rovstcr.rovstcr_pidm%TYPE)
           RETURN VARCHAR2;
-- 70200-1 JMM
FUNCTION f_get_valid_schedule_date(p_aidy_code       IN rpradsb.rpradsb_aidy_code%TYPE,
                                   p_pidm            IN rpradsb.rpradsb_pidm%TYPE,
                                   p_term_code       IN rpradsb.rpradsb_term_code%TYPE,
                                   p_fund_code       IN rpradsb.rpradsb_fund_code%TYPE,
                                   p_sched_date      IN rpradsb.rpradsb_schedule_date%TYPE,
                                   p_curr_sched_date IN rpradsb.rpradsb_schedule_date%TYPE)
RETURN rpradsb.rpradsb_schedule_date%TYPE;
--
-- declare package procedures
--
  PROCEDURE p_resched_term_disburse (p_term_code IN rpradsb.rpradsb_term_code%TYPE,
                                     p_pidm      IN rpradsb.rpradsb_pidm%TYPE);

  PROCEDURE p_resched_year_disburse (p_aidy_code IN rpradsb.rpradsb_aidy_code%TYPE,
                                     p_pidm      IN rpradsb.rpradsb_pidm%TYPE);

  PROCEDURE p_resched_fund_term_disburse (p_term_code IN rpradsb.rpradsb_term_code%TYPE,
                                          p_pidm      IN rpradsb.rpradsb_pidm%TYPE,
                                          p_fund_code IN rpradsb.rpradsb_fund_code%TYPE);

  PROCEDURE p_resched_fund_year_disburse (p_aidy_code IN rpradsb.rpradsb_aidy_code%TYPE,
                                          p_pidm      IN rpradsb.rpradsb_pidm%TYPE,
                                          p_fund_code IN rpradsb.rpradsb_fund_code%TYPE);
--
END ROKMISC;            /* this ends the package spec */
/


CREATE OR REPLACE PACKAGE BODY rokmisc AS
--AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : ROKMISC1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Tue May 08 08:57:44 2012
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
--
-- FILE NAME..: rokmisc1.sql
-- RELEASE....: 8.44
-- OBJECT NAME: ROKMISC
-- PRODUCT....: FINAID
-- COPYRIGHT..: Copyright 2012-2023 Ellucian Company L.P. and its affiliates.
--
-- declare package functions
--
-------------------------------------------------------------------------------------------------
-- new function added in 8.9

  FUNCTION f_get_aidy_code
             ( p_term_code                        stvterm.stvterm_code%TYPE
             ) RETURN stvterm.stvterm_fa_proc_yr%TYPE IS                                                                -- 81000-1

     lv_aidy_code                                 stvterm.stvterm_fa_proc_yr%TYPE ;

     CURSOR stvterm_c IS
            SELECT stvterm_fa_proc_yr
              FROM stvterm
             WHERE stvterm_code = p_term_code;

     BEGIN
       OPEN  stvterm_c ;
       FETCH stvterm_c INTO lv_aidy_code ;
       CLOSE stvterm_c ;

       RETURN lv_aidy_code;

    END f_get_aidy_code ;

-------------------------------------------------------------------------------------------------
-- new function added in 8.9

  FUNCTION f_get_levl_code
             ( p_term_code                        rorenrl.rorenrl_term_code%TYPE,
               p_pidm                             rorenrl.rorenrl_pidm%TYPE
             ) RETURN sgbstdn.sgbstdn_levl_code%TYPE IS

     lv_levl_code                                 sgbstdn.sgbstdn_levl_code%TYPE ;

     CURSOR sgbstdn_c IS
            SELECT sgbstdn_levl_code
              FROM sgbstdn
             WHERE sgbstdn_pidm          = p_pidm
               AND sgbstdn_term_code_eff =
                       ( SELECT MAX(sgbstdn_term_code_eff)
                           FROM sgbstdn
                          WHERE sgbstdn_pidm           = p_pidm
                            AND sgbstdn_term_code_eff <= p_term_code
                       );

     BEGIN
       OPEN  sgbstdn_c ;
       FETCH sgbstdn_c INTO lv_levl_code ;
       CLOSE sgbstdn_c ;

       RETURN lv_levl_code;

    END f_get_levl_code ;

-------------------------------------------------------------------------------------------------
  FUNCTION f_calc_attend_fa_credit_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_enrr_code                        roratnd.roratnd_enrr_code%TYPE DEFAULT rb_enrollment_rules.M_STANDARD -- 081402-1
             ) RETURN NUMBER IS

     -- define local variables

     credit_hours          roratnd.roratnd_finaid_credit_hr%TYPE ;

     CURSOR roratnd_fa_credit_hour_c IS
         SELECT roratnd_finaid_credit_hr
           FROM roratnd x
          WHERE roratnd_pidm                 = p_pidm
            AND roratnd_term_code            = p_term_code
            AND roratnd_enrr_code            = p_enrr_code                                                              -- 081402-1
            AND roratnd_attend_date          =
                   (SELECT MAX(roratnd_attend_date)
                      FROM roratnd
                     WHERE roratnd_pidm         = x.roratnd_pidm
                       AND roratnd_term_code    = x.roratnd_term_code                                                   -- 081402-1
                       AND roratnd_enrr_code    = x.roratnd_enrr_code
                       AND roratnd_attend_date <= p_attend_date)
         UNION                     -- 081402-1
         SELECT rorenrl_finaid_credit_hr                                                                                -- 081402-1
           FROM stvterm,                                                                                                -- 081402-1
                rorenrl                                                                                                 -- 081402-1
          WHERE rorenrl_pidm                 = p_pidm                                                                   -- 081402-1
            AND rorenrl_term_code            = p_term_code                                                              -- 081402-1
            AND rorenrl_term_code            = stvterm_code                                                             -- 081402-1
            AND rorenrl_enrr_code            = p_enrr_code                                                              -- 081402-1                                                      -- 081402-1
            AND stvterm_start_date          <= p_attend_date                                                            -- 081402-1
            AND NOT EXISTS                                                                                              -- 081402-1
                   ( SELECT 'Y'                                                                                         -- 081402-1
                       FROM roratnd                                                                                     -- 081402-1
                      WHERE roratnd_pidm         = p_pidm                                                               -- 081402-1
                        AND roratnd_term_code    = p_term_code                                                          -- 081402-1
                        AND roratnd_enrr_code    = p_enrr_code                                                          -- 081402-1
                   ) ;


     BEGIN
       OPEN roratnd_fa_credit_hour_c ;
       FETCH roratnd_fa_credit_hour_c INTO credit_hours ;
       IF roratnd_fa_credit_hour_c%NOTFOUND THEN
          credit_hours := NULL;
       END IF;
       CLOSE roratnd_fa_credit_hour_c ;
--
       RETURN credit_hours;
--
    END f_calc_attend_fa_credit_hrs ;

-------------------------------------------------------------------------------------------------

  -- 081200-2 - moved from being a private member of rokmisc_period to a public member of rokmisc
  --  overwrote previous unused version in rokmisc with logic from rokmisc_period
  FUNCTION f_calc_attend_fa_bill_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_enrr_code                        roratnd.roratnd_enrr_code%TYPE DEFAULT rb_enrollment_rules.M_STANDARD -- 081402-1
             ) RETURN NUMBER IS

     lv_bill_hours                                roratnd.roratnd_finaid_bill_hr%TYPE ;

     CURSOR fa_bill_hour_c IS
         SELECT roratnd_finaid_bill_hr                                                                                  -- 081402-1
           FROM roratnd x
          WHERE roratnd_pidm                 = p_pidm
            AND roratnd_term_code            = p_term_code
            AND roratnd_enrr_code            = p_enrr_code                                                              -- 081402-1
            AND roratnd_attend_date          =
                   ( SELECT MAX(roratnd_attend_date)
                       FROM roratnd
                      WHERE roratnd_pidm         = x.roratnd_pidm
                        AND roratnd_term_code    = x.roratnd_term_code
                        AND roratnd_enrr_code    = x.roratnd_enrr_code
                        AND roratnd_attend_date <= p_attend_date
                   )
         UNION
         SELECT rorenrl_finaid_bill_hr                                                                                  -- 081402-1
           FROM stvterm,
                rorenrl
          WHERE rorenrl_pidm                 = p_pidm
            AND rorenrl_term_code            = p_term_code
            AND rorenrl_term_code            = stvterm_code
            AND rorenrl_enrr_code            = p_enrr_code                                                              -- 081402-1
            AND stvterm_start_date          <= p_attend_date
            AND NOT EXISTS
                   ( SELECT 'Y'
                       FROM roratnd
                      WHERE roratnd_pidm         = p_pidm
                        AND roratnd_term_code    = p_term_code
                        AND roratnd_enrr_code    = p_enrr_code                                                          -- 081402-1
                   ) ;

     BEGIN
       OPEN  fa_bill_hour_c ;
       FETCH fa_bill_hour_c INTO lv_bill_hours ;
       IF fa_bill_hour_c%NOTFOUND THEN
          lv_bill_hours := NULL;
       END IF;
       CLOSE fa_bill_hour_c ;

       RETURN lv_bill_hours;

    END f_calc_attend_fa_bill_hrs ;
-------------------------------------------------------------------------------------------------

  -- 081200-2 - moved from being a private member of rokmisc_period to a public member of rokmisc
  --  overwrote previous unused version in rokmisc with logic from rokmisc_period
  FUNCTION f_calc_attend_fa_adj_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_enrr_code                        roratnd.roratnd_enrr_code%TYPE DEFAULT rb_enrollment_rules.M_STANDARD -- 081402-1
             ) RETURN NUMBER IS

     lv_adj_hours                                 roratnd.roratnd_finaid_adj_hr%TYPE ;

     CURSOR fa_adj_hour_c IS
         SELECT roratnd_finaid_adj_hr                                                                                   -- 081402-1
           FROM roratnd x
          WHERE roratnd_pidm                 = p_pidm
            AND roratnd_term_code            = p_term_code
            AND roratnd_enrr_code            = p_enrr_code                                                              -- 081402-1
            AND roratnd_attend_date          =
                   (SELECT MAX(roratnd_attend_date)
                      FROM roratnd
                     WHERE roratnd_pidm         = x.roratnd_pidm
                       AND roratnd_term_code    = x.roratnd_term_code
                       AND roratnd_enrr_code    = x.roratnd_enrr_code                                                   -- 081402-1
                       AND roratnd_attend_date <= p_attend_date)
         UNION
         SELECT rorenrl_finaid_adj_hr                                                                                   -- 081402-1
           FROM stvterm,
                rorenrl
          WHERE rorenrl_pidm                 = p_pidm
            AND rorenrl_term_code            = p_term_code
            AND rorenrl_term_code            = stvterm_code
            AND rorenrl_enrr_code            = p_enrr_code                                                              -- 081402-1
            AND stvterm_start_date          <= p_attend_date
            AND NOT EXISTS
                   ( SELECT 'Y'
                       FROM roratnd
                      WHERE roratnd_pidm         = p_pidm
                        AND roratnd_term_code    = p_term_code
                        AND roratnd_enrr_code    = p_enrr_code                                                          -- 081402-1
                   ) ;
     BEGIN
       OPEN  fa_adj_hour_c ;
       FETCH fa_adj_hour_c INTO lv_adj_hours ;
       IF fa_adj_hour_c%NOTFOUND THEN
          lv_adj_hours := NULL;
       END IF;
       CLOSE fa_adj_hour_c ;

       RETURN lv_adj_hours;

    END f_calc_attend_fa_adj_hrs ;

-------------------------------------------------------------------------------------------------

  FUNCTION f_calc_attend_stud_credit_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_repeat_ind                   IN  VARCHAR2 DEFAULT 'N'                                        -- 081200-1
             ) RETURN NUMBER IS

     lv_credit_hours                              rorenrl.rorenrl_finaid_credit_hr%TYPE ;
     lv_levl_code                                 sgbstdn.sgbstdn_levl_code%TYPE;                             -- 80900-1
     lv_aidy_code                                 stvterm.stvterm_fa_proc_yr%TYPE ;                           -- 80900-1

     CURSOR credit_hour_c IS
        SELECT SUM(sfrstcr_credit_hr)
          FROM sfrstcr z
         WHERE sfrstcr_term_code              = p_term_code
           AND sfrstcr_pidm                   = p_pidm
           AND (p_repeat_ind = 'N'                                                                            -- 081200-1
                OR                                                                                            -- 081200-1
                 (p_repeat_ind = 'Y'                                                                          -- 081200-1
                  AND                                                                                         -- 081200-1
                  rokrpts.f_is_repeat_violation( sfrstcr_pidm,                                                -- 081200-1
                                                 sfrstcr_term_code,                                           -- 081200-1
                                                 sfrstcr_crn ) = 'N'                                          -- 081200-1
                 )                                                                                            -- 081200-1
               )                                                                                              -- 081200-1
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorsect
                WHERE rorsect_term_code       = z.sfrstcr_term_code
                  AND rorsect_crn             = z.sfrstcr_crn)
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorclve
                WHERE rorclve_aidy_code       = lv_aidy_code                                                  -- 80900-1
                  AND rorclve_stu_levl_code   = lv_levl_code                                                  -- 80900-1
                  AND rorclve_crse_levl_code  = z.sfrstcr_levl_code)
           AND ROKVIEW.F_GET_CLASS_START_DATE
                         (SFRSTCR_TERM_CODE,
                          SFRSTCR_PIDM,
                          SFRSTCR_CRN,
                          SFRSTCR_PTRM_CODE) <= p_attend_date;

     BEGIN
       lv_aidy_code := f_get_aidy_code(p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       lv_levl_code := f_get_levl_code(p_pidm       =>  p_pidm,                                               -- 80900-1
                                       p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       IF lv_levl_code IS NULL THEN                                                                           -- 80900-1
          lv_credit_hours := NULL;                                                                            -- 80900-1
          RETURN lv_credit_hours;                                                                             -- 80900-1
       END IF;                                                                                                -- 80900-1

       OPEN  credit_hour_c ;
       FETCH credit_hour_c INTO lv_credit_hours ;
       IF credit_hour_c%NOTFOUND THEN
          lv_credit_hours := NULL;
       END IF;
       CLOSE credit_hour_c ;

       RETURN lv_credit_hours;

    END f_calc_attend_stud_credit_hrs ;

-------------------------------------------------------------------------------------------------

  FUNCTION f_calc_attend_stud_bill_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_repeat_ind                   IN  VARCHAR2 DEFAULT 'N'                                        -- 081200-1
             ) RETURN NUMBER IS

     lv_bill_hours                                rorenrl.rorenrl_finaid_bill_hr%TYPE ;
     lv_levl_code                                 sgbstdn.sgbstdn_levl_code%TYPE;                             -- 80900-1
     lv_aidy_code                                 stvterm.stvterm_fa_proc_yr%TYPE ;                           -- 80900-1

     CURSOR bill_hour_c IS
        SELECT SUM(sfrstcr_bill_hr)
          FROM sfrstcr z
         WHERE sfrstcr_term_code              = p_term_code
           AND sfrstcr_pidm                   = p_pidm
           AND (p_repeat_ind = 'N'                                                                            -- 081200-1
                OR                                                                                            -- 081200-1
                 (p_repeat_ind = 'Y'                                                                          -- 081200-1
                  AND                                                                                         -- 081200-1
                  rokrpts.f_is_repeat_violation( sfrstcr_pidm,                                                -- 081200-1
                                                 sfrstcr_term_code,                                           -- 081200-1
                                                 sfrstcr_crn ) = 'N'                                          -- 081200-1
                 )                                                                                            -- 081200-1
               )                                                                                              -- 081200-1
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorsect
                WHERE rorsect_term_code       = z.sfrstcr_term_code
                  AND rorsect_crn             = z.sfrstcr_crn)
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorclve
                WHERE rorclve_aidy_code       = lv_aidy_code                                                  -- 80900-1
                  AND rorclve_stu_levl_code   = lv_levl_code                                                  -- 80900-1
                  AND rorclve_crse_levl_code  = z.sfrstcr_levl_code)
           AND ROKVIEW.F_GET_CLASS_START_DATE
                         (SFRSTCR_TERM_CODE,
                          SFRSTCR_PIDM,
                          SFRSTCR_CRN,
                          SFRSTCR_PTRM_CODE) <= p_attend_date;

     BEGIN
       lv_aidy_code := f_get_aidy_code(p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       lv_levl_code := f_get_levl_code(p_pidm       =>  p_pidm,                                               -- 80900-1
                                       p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       IF lv_levl_code IS NULL THEN                                                                           -- 80900-1
          lv_bill_hours := NULL;                                                                              -- 80900-1
          RETURN lv_bill_hours;                                                                               -- 80900-1
       END IF;                                                                                                -- 80900-1

       OPEN  bill_hour_c ;
       FETCH bill_hour_c INTO lv_bill_hours ;
       IF bill_hour_c%NOTFOUND THEN
          lv_bill_hours := NULL;
       END IF;
       CLOSE bill_hour_c ;

       RETURN lv_bill_hours;

    END f_calc_attend_stud_bill_hrs ;

-------------------------------------------------------------------------------------------------

  FUNCTION f_calc_attend_stud_adj_hrs
             ( p_term_code                        roratnd.roratnd_term_code%TYPE,
               p_pidm                             roratnd.roratnd_pidm%TYPE,
               p_attend_date                      roratnd.roratnd_attend_date%TYPE,
               p_repeat_ind                   IN  VARCHAR2 DEFAULT 'N'                                        -- 081200-1
             ) RETURN NUMBER IS

     lv_adj_hours                                 rorenrl.rorenrl_finaid_adj_hr%TYPE ;
     lv_levl_code                                 sgbstdn.sgbstdn_levl_code%TYPE;                             -- 80900-1
     lv_aidy_code                                 stvterm.stvterm_fa_proc_yr%TYPE ;                           -- 80900-1

     CURSOR adj_hour_c IS
        SELECT SUM(sfrstcr_bill_hr)
          FROM sfrstcr z
         WHERE sfrstcr_term_code                   = p_term_code
           AND sfrstcr_pidm                        = p_pidm
           AND (p_repeat_ind = 'N'                                                                            -- 081200-1
                OR                                                                                            -- 081200-1
                 (p_repeat_ind = 'Y'                                                                          -- 081200-1
                  AND                                                                                         -- 081200-1
                  rokrpts.f_is_repeat_violation( sfrstcr_pidm,                                                -- 081200-1
                                                 sfrstcr_term_code,                                           -- 081200-1
                                                 sfrstcr_crn ) = 'N'                                          -- 081200-1
                 )                                                                                            -- 081200-1
               )                                                                                              -- 081200-1
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorsect
                WHERE rorsect_term_code            = z.sfrstcr_term_code
                  AND rorsect_crn                  = z.sfrstcr_crn)
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorclve
                WHERE rorclve_aidy_code            = lv_aidy_code                                             -- 80900-1
                  AND rorclve_stu_levl_code        = lv_levl_code                                             -- 80900-1
                  AND rorclve_crse_levl_code       = z.sfrstcr_levl_code)
           AND EXISTS
                  (SELECT 'X'
                     FROM stvrsts
                    WHERE z.sfrstcr_rsts_code      = stvrsts_code
                      AND stvrsts_incl_sect_enrl   = 'Y')
           AND NOT EXISTS
               (SELECT 'X'
                  FROM roraudt
                 WHERE (roraudt_gmod_code         = z.sfrstcr_gmod_code
                    OR  roraudt_rsts_code         = z.sfrstcr_rsts_code)
                   AND roraudt_aidy_code          = lv_aidy_code                                              -- 80900-1
               )
           AND ROKVIEW.F_GET_CLASS_START_DATE   (SFRSTCR_TERM_CODE,
                                                 SFRSTCR_PIDM,
                                                 SFRSTCR_CRN,
                                                 SFRSTCR_PTRM_CODE) <= p_attend_date;

     BEGIN
       lv_aidy_code := f_get_aidy_code(p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       lv_levl_code := f_get_levl_code(p_pidm       =>  p_pidm,                                               -- 80900-1
                                       p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       IF lv_levl_code IS NULL THEN                                                                           -- 80900-1
          lv_adj_hours := NULL;                                                                               -- 80900-1
          RETURN lv_adj_hours;                                                                                -- 80900-1
       END IF;                                                                                                -- 80900-1

       OPEN  adj_hour_c ;
       FETCH adj_hour_c INTO lv_adj_hours ;
       IF adj_hour_c%NOTFOUND THEN
          lv_adj_hours := NULL;
       END IF;
       CLOSE adj_hour_c ;

       RETURN lv_adj_hours;

    END f_calc_attend_stud_adj_hrs ;

-------------------------------------------------------------------------------------------------

  FUNCTION f_calc_stud_credit_hrs
             ( p_term_code                        rorenrl.rorenrl_term_code%TYPE,
               p_pidm                             rorenrl.rorenrl_pidm%TYPE,
               p_repeat_ind                   IN  VARCHAR2 DEFAULT 'N'                                        -- 081200-1
             ) RETURN NUMBER IS

     lv_credit_hours                              rorenrl.rorenrl_finaid_credit_hr%TYPE ;
     lv_levl_code                                 sgbstdn.sgbstdn_levl_code%TYPE;                             -- 80900-1
     lv_aidy_code                                 stvterm.stvterm_fa_proc_yr%TYPE ;                           -- 80900-1

     CURSOR credit_hour_c IS
        SELECT SUM(sfrstcr_credit_hr)
          FROM sfrstcr z
         WHERE sfrstcr_term_code             = p_term_code
           AND sfrstcr_pidm                  = p_pidm
           AND (p_repeat_ind = 'N'                                                                            -- 081200-1
                OR                                                                                            -- 081200-1
                 (p_repeat_ind = 'Y'                                                                          -- 081200-1
                  AND                                                                                         -- 081200-1
                  rokrpts.f_is_repeat_violation( sfrstcr_pidm,                                                -- 081200-1
                                                 sfrstcr_term_code,                                           -- 081200-1
                                                 sfrstcr_crn ) = 'N'                                          -- 081200-1
                 )                                                                                            -- 081200-1
               )                                                                                              -- 081200-1
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorsect
                WHERE rorsect_term_code      = z.sfrstcr_term_code
                  AND rorsect_crn            = z.sfrstcr_crn)
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorclve
                WHERE rorclve_aidy_code      = lv_aidy_code                                                   -- 80900-1
                  AND rorclve_stu_levl_code  = lv_levl_code                                                   -- 80900-1
                  AND rorclve_crse_levl_code = z.sfrstcr_levl_code);

     BEGIN
       lv_aidy_code := f_get_aidy_code(p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       lv_levl_code := f_get_levl_code(p_pidm       =>  p_pidm,                                               -- 80900-1
                                       p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       IF lv_levl_code IS NULL THEN                                                                           -- 80900-1
          lv_credit_hours := NULL;                                                                            -- 80900-1
          RETURN lv_credit_hours;                                                                             -- 80900-1
       END IF;                                                                                                -- 80900-1

       OPEN  credit_hour_c ;
       FETCH credit_hour_c INTO lv_credit_hours ;
       IF credit_hour_c%NOTFOUND THEN
          lv_credit_hours := NULL;
       END IF;
       CLOSE credit_hour_c ;

       RETURN lv_credit_hours;

    END f_calc_stud_credit_hrs ;

-------------------------------------------------------------------------------------------------

  FUNCTION f_calc_stud_bill_hrs
             ( p_term_code                        rorenrl.rorenrl_term_code%TYPE,
               p_pidm                             rorenrl.rorenrl_pidm%TYPE,
               p_repeat_ind                   IN  VARCHAR2 DEFAULT 'N'                                        -- 081200-1
             ) RETURN NUMBER IS

     lv_bill_hours                                rorenrl.rorenrl_finaid_bill_hr%TYPE ;
     lv_levl_code                                 sgbstdn.sgbstdn_levl_code%TYPE;                             -- 80900-1
     lv_aidy_code                                 stvterm.stvterm_fa_proc_yr%TYPE ;                           -- 80900-1

     CURSOR bill_hour_c IS
        SELECT SUM(sfrstcr_bill_hr)
          FROM sfrstcr z
         WHERE sfrstcr_term_code             = p_term_code
           AND sfrstcr_pidm                  = p_pidm
           AND (p_repeat_ind = 'N'                                                                            -- 081200-1
                OR                                                                                            -- 081200-1
                 (p_repeat_ind = 'Y'                                                                          -- 081200-1
                  AND                                                                                         -- 081200-1
                  rokrpts.f_is_repeat_violation( sfrstcr_pidm,                                                -- 081200-1
                                                 sfrstcr_term_code,                                           -- 081200-1
                                                 sfrstcr_crn ) = 'N'                                          -- 081200-1
                 )                                                                                            -- 081200-1
               )                                                                                              -- 081200-1
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorsect
                WHERE rorsect_term_code      = z.sfrstcr_term_code
                  AND rorsect_crn            = z.sfrstcr_crn)
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorclve
                WHERE rorclve_aidy_code      = lv_aidy_code                                                   -- 80900-1
                  AND rorclve_stu_levl_code  = lv_levl_code                                                   -- 80900-1
                  AND rorclve_crse_levl_code = z.sfrstcr_levl_code);

     BEGIN
       lv_aidy_code := f_get_aidy_code(p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       lv_levl_code := f_get_levl_code(p_pidm       =>  p_pidm,                                               -- 80900-1
                                       p_term_code  =>  p_term_code                                           -- 80900-1
                                      );                                                                      -- 80900-1
       IF lv_levl_code IS NULL THEN                                                                           -- 80900-1
          lv_bill_hours := NULL;                                                                              -- 80900-1
          RETURN lv_bill_hours;                                                                               -- 80900-1
       END IF;                                                                                                -- 80900-1

       OPEN  bill_hour_c ;
       FETCH bill_hour_c INTO lv_bill_hours ;
       IF bill_hour_c%NOTFOUND THEN
          lv_bill_hours := NULL;
       END IF;
       CLOSE bill_hour_c ;

       RETURN lv_bill_hours;

    END f_calc_stud_bill_hrs ;

  -- moved f_calc_stud_adj_hrs function so it is in the same order as the package spec                        -- 081200-1
  FUNCTION f_calc_stud_adj_hrs
             ( p_term_code                        rorenrl.rorenrl_term_code%TYPE,
               p_pidm                             rorenrl.rorenrl_pidm%TYPE,
               p_repeat_ind                   IN  VARCHAR2 DEFAULT 'N'                                        -- 081200-1
             ) RETURN NUMBER IS

     lv_adj_hours                                 rorenrl.rorenrl_finaid_adj_hr%TYPE ;
     lv_levl_code                                 sgbstdn.sgbstdn_levl_code%TYPE;
     lv_aidy_code                                 stvterm.stvterm_fa_proc_yr%TYPE ;

     CURSOR adj_hour_c IS
        SELECT SUM(sfrstcr_bill_hr)
          FROM sfrstcr z
         WHERE sfrstcr_term_code                   = p_term_code
           AND sfrstcr_pidm                        = p_pidm
           AND (p_repeat_ind = 'N'                                                                            -- 081200-1
                OR                                                                                            -- 081200-1
                 (p_repeat_ind = 'Y'                                                                          -- 081200-1
                  AND                                                                                         -- 081200-1
                  rokrpts.f_is_repeat_violation( sfrstcr_pidm,                                                -- 081200-1
                                                 sfrstcr_term_code,                                           -- 081200-1
                                                 sfrstcr_crn ) = 'N'                                          -- 081200-1
                 )                                                                                            -- 081200-1
               )                                                                                              -- 081200-1
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorsect
                WHERE rorsect_term_code            = z.sfrstcr_term_code
                  AND rorsect_crn                  = z.sfrstcr_crn)
           AND NOT EXISTS
              (SELECT 'Y'
                 FROM rorclve
                WHERE rorclve_aidy_code            = lv_aidy_code
                  AND rorclve_stu_levl_code        = lv_levl_code
                  AND rorclve_crse_levl_code       = z.sfrstcr_levl_code)
           AND EXISTS
                  (SELECT 'X'
                     FROM stvrsts
                    WHERE z.sfrstcr_rsts_code      = stvrsts_code
                      AND stvrsts_incl_sect_enrl   = 'Y')
           AND NOT EXISTS
               (SELECT 'X'
                  FROM roraudt
                 WHERE (roraudt_gmod_code         = z.sfrstcr_gmod_code
                    OR  roraudt_rsts_code         = z.sfrstcr_rsts_code)
                   AND roraudt_aidy_code          = lv_aidy_code
               );

     BEGIN
       lv_aidy_code := f_get_aidy_code(p_term_code  =>  p_term_code
                                      );
       lv_levl_code := f_get_levl_code(p_pidm       =>  p_pidm,
                                       p_term_code  =>  p_term_code
                                      );
       IF lv_levl_code IS NULL THEN
          lv_adj_hours := NULL;
          RETURN lv_adj_hours;
       END IF;

       OPEN  adj_hour_c ;
       FETCH adj_hour_c INTO lv_adj_hours ;
       IF adj_hour_c%NOTFOUND THEN
          lv_adj_hours := NULL;
       END IF;
       CLOSE adj_hour_c ;

       RETURN lv_adj_hours;

    END f_calc_stud_adj_hrs ;

-------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
/* 08080000-1 */
  FUNCTION f_calc_earned_hours (p_term_code	IN  shrtgpa.shrtgpa_term_code%TYPE,
                                p_pidm      IN  shrtgpa.shrtgpa_pidm%TYPE)
  RETURN NUMBER
  IS

     earned_hours          shrtgpa.shrtgpa_hours_earned%TYPE ;

     CURSOR shrtgpa_earned_hours_c IS
        SELECT shrtgpa_hours_earned
          FROM shrtgpa
         WHERE shrtgpa_term_code = p_term_code
           AND shrtgpa_pidm	     = p_pidm;

     BEGIN

       OPEN shrtgpa_earned_hours_c ;
       FETCH shrtgpa_earned_hours_c INTO earned_hours ;
       IF shrtgpa_earned_hours_c %NOTFOUND THEN
          earned_hours := NULL;
       END IF;
       CLOSE shrtgpa_earned_hours_c ;

--
       RETURN earned_hours;
--
    END f_calc_earned_hours ;

-------------------------------------------------------------------------------------------------


  FUNCTION f_get_fa_first_attend_date (p_term_code    IN  rovstcr.rovstcr_term_code%TYPE,
                                       p_pidm         IN  rovstcr.rovstcr_pidm%TYPE)
  RETURN DATE
  IS

     -- define local variables

     start_date          rovstcr.rovstcr_start_date%TYPE ;

     CURSOR rovstcr_start_date_c IS
-- 08040001-1
--         SELECT MIN(rovstcr_start_date)
--           FROM rovstcr x
--          WHERE rovstcr_term_code        = p_term_code
--            AND rovstcr_pidm             = p_pidm
--            AND rovstcr_exclude_section     IS NULL
--            AND rovstcr_exclude_level       IS NULL ;
        SELECT
        		/*+
        		INDEX (z pk_sfrstcr)
        		*/
               MIN(ROKVIEW.F_GET_CLASS_START_DATE(SFRSTCR_TERM_CODE,
                                                  SFRSTCR_PIDM,
                                                  SFRSTCR_CRN,
                                                  SFRSTCR_PTRM_CODE))
          FROM sfrstcr z
         WHERE sfrstcr_term_code        = p_term_code
           AND sfrstcr_pidm             = p_pidm
           AND ROKVIEW.F_GET_EXCLUDE_SECTION_IND(SFRSTCR_TERM_CODE,
                                                 SFRSTCR_CRN)   IS NULL
           AND ROKVIEW.F_GET_EXCLUDE_LEVEL_IND  (SFRSTCR_TERM_CODE,
                                                 SFRSTCR_PIDM,
                                                 SFRSTCR_CRN)   IS NULL;

     BEGIN
       OPEN rovstcr_start_date_c ;
       FETCH rovstcr_start_date_c INTO start_date ;
       IF rovstcr_start_date_c%NOTFOUND THEN
          start_date := NULL;
       END IF;
       CLOSE rovstcr_start_date_c ;
--
       RETURN start_date;
--
    END f_get_fa_first_attend_date ;

-------------------------------------------------------------------------------------------------

  FUNCTION f_get_olr_course_exists (p_term_code    IN  rovstcr.rovstcr_term_code%TYPE,
                                    p_pidm         IN  rovstcr.rovstcr_pidm%TYPE)
  RETURN VARCHAR2
  IS

     -- define local variables

     olr_course_exists_ind          VARCHAR2(1) ;

     CURSOR rovstcr_olr_c IS
         SELECT 'Y'
           FROM dual
          WHERE EXISTS
-- 08040001-1
--                  (SELECT 'Y'
--                     FROM rovstcr
--                    WHERE rovstcr_term_code        = p_term_code
--                      AND rovstcr_pidm             = p_pidm
--                      AND rovstcr_ptrm_code IS NULL);
               (SELECT
               		  /*+
               		   INDEX (z pk_sfrstcr)
               		  */
                       'Y'
                  FROM sfrstcr z
                 WHERE sfrstcr_term_code        = p_term_code
                   AND sfrstcr_pidm             = p_pidm
                   AND sfrstcr_ptrm_code IS NULL);

     BEGIN
       OPEN rovstcr_olr_c ;
       FETCH rovstcr_olr_c INTO olr_course_exists_ind ;
       IF rovstcr_olr_c%NOTFOUND THEN
          olr_course_exists_ind := 'N';
       END IF;
       CLOSE rovstcr_olr_c ;
--
       RETURN olr_course_exists_ind;
--
    END f_get_olr_course_exists ;

-------------------------------------------------------------------------------------------------

  FUNCTION f_get_stud_first_attend_date (p_term_code    IN  rovstcr.rovstcr_term_code%TYPE,
                                         p_pidm         IN  rovstcr.rovstcr_pidm%TYPE)
  RETURN DATE
  IS

     -- define local variables

     start_date          rovstcr.rovstcr_start_date%TYPE ;

     CURSOR rovstcr_start_date_c IS
-- 08040001-1
--         SELECT MIN(rovstcr_start_date)
--           FROM rovstcr x
--          WHERE rovstcr_term_code        = p_term_code
--            AND rovstcr_pidm             = p_pidm ;
        SELECT
        		/*+
        		INDEX (z pk_sfrstcr)
        		*/
               MIN(ROKVIEW.F_GET_CLASS_START_DATE(SFRSTCR_TERM_CODE,
                                                  SFRSTCR_PIDM,
                                                  SFRSTCR_CRN,
                                                  SFRSTCR_PTRM_CODE))
          FROM sfrstcr z
         WHERE sfrstcr_term_code        = p_term_code
           AND sfrstcr_pidm             = p_pidm;

     BEGIN
       OPEN rovstcr_start_date_c ;
       FETCH rovstcr_start_date_c INTO start_date ;
       IF rovstcr_start_date_c%NOTFOUND THEN
          start_date := NULL;
       END IF;
       CLOSE rovstcr_start_date_c ;
--
       RETURN start_date;
--
    END f_get_stud_first_attend_date ;
--
-- 70200-1 JMM
-- returns the next valid schedule date for a fund/term
FUNCTION f_get_valid_schedule_date(p_aidy_code       IN rpradsb.rpradsb_aidy_code%TYPE,
                                   p_pidm            IN rpradsb.rpradsb_pidm%TYPE,
                                   p_term_code       IN rpradsb.rpradsb_term_code%TYPE,
                                   p_fund_code       IN rpradsb.rpradsb_fund_code%TYPE,
                                   p_sched_date      IN rpradsb.rpradsb_schedule_date%TYPE,
                                   p_curr_sched_date IN rpradsb.rpradsb_schedule_date%TYPE)
RETURN rpradsb.rpradsb_schedule_date%TYPE
IS
-- define local variables
    lv_prev_sched_date VARCHAR(2);
    lv_1up_sched_date  rpradsb.rpradsb_schedule_date%TYPE := p_sched_date;
--
    CURSOR has_prev_sched_date_c IS
        SELECT 'X'
          FROM rpradsb
         WHERE rpradsb_aidy_code     = p_aidy_code
           AND rpradsb_pidm          = p_pidm
           AND rpradsb_term_code     = p_term_code
           AND rpradsb_fund_code     = p_fund_code
           AND rpradsb_schedule_date = lv_1up_sched_date;
--
BEGIN
    IF p_curr_sched_date = p_sched_date THEN
        RETURN p_sched_date;
    END IF;
--
    LOOP
        OPEN  has_prev_sched_date_c;
        FETCH has_prev_sched_date_c INTO lv_prev_sched_date;
        EXIT WHEN has_prev_sched_date_c%NOTFOUND;
--
        IF p_curr_sched_date = lv_1up_sched_date THEN
            RETURN lv_1up_sched_date;
        END IF;
--
        lv_1up_sched_date := lv_1up_sched_date + 1;
--
        CLOSE has_prev_sched_date_c;
    END LOOP;
--
    RETURN lv_1up_sched_date;
END f_get_valid_schedule_date;
--
-------------------------------------------------------------------------------------------------

  PROCEDURE p_resched_fund_term_disburse (p_term_code IN rpradsb.rpradsb_term_code%TYPE,
                                          p_pidm      IN rpradsb.rpradsb_pidm%TYPE,
                                          p_fund_code IN rpradsb.rpradsb_fund_code%TYPE)
  IS

     -- define local variables

     aidy_code                        robinst.robinst_aidy_code%TYPE;
     pckg_audit_ind                   robinst.robinst_pckg_audit_ind%TYPE ;
     resched_disb_date_ind            robinst.robinst_resched_disb_date_ind%TYPE ;
     audit_ind                        rordata.rordata_audit_ind%TYPE ;
     first_attend_date                DATE ;
     old_schedule_date                rpradsb.rpradsb_schedule_date%TYPE ;
     new_schedule_date                rpradsb.rpradsb_schedule_date%TYPE ;
     disb_sched_no_days               rpradsb.rpradsb_disb_sched_no_days%TYPE ;

-- 70300-1 JMM
     lv_rowid                         VARCHAR(18);

     CURSOR robinst_resched_disb_date_c IS
        SELECT robinst_aidy_code,
               COALESCE(robinst_pckg_audit_ind,'N'),
               COALESCE(robinst_resched_disb_date_ind,'N')
          FROM robinst
         WHERE robinst_aidy_code =
                  (SELECT stvterm_fa_proc_yr
                     FROM stvterm
                    WHERE stvterm_code = p_term_code) ;

     CURSOR rordata_audit_ind_c IS
        SELECT COALESCE(rordata_audit_ind,'N')
          FROM rordata
         WHERE rordata_aidy_code = aidy_code
           AND rordata_cde       = 'RPRADSB_SCHEDULE_DATE' ;

-- 70300-1 JMM: added rowid column and removed FOR UPDATE clause.
     CURSOR rpradsb_schedule_date_c IS
        SELECT rpradsb_schedule_date,
               rpradsb_disb_sched_no_days,
               rowid
          FROM rpradsb x
         WHERE rpradsb_aidy_code           = aidy_code
           AND rpradsb_pidm                = p_pidm
           AND rpradsb_term_code           = p_term_code
           AND rpradsb_fund_code           = p_fund_code
           AND rpradsb_sys_ind             = 'S'
           AND rpradsb_disb_sched_no_days IS NOT NULL
           AND rpradsb_disburse_date      IS NULL
           AND rpradsb_disburse_amt       IS NULL
           AND NOT EXISTS
                    (SELECT 'Y'
                       FROM rpradsb
                      WHERE rpradsb_aidy_code      = x.rpradsb_aidy_code
                        AND rpradsb_pidm           = x.rpradsb_pidm
                        AND rpradsb_term_code      = x.rpradsb_term_code
                        AND rpradsb_fund_code      = x.rpradsb_fund_code
                        AND rpradsb_disburse_date IS NOT NULL
                        AND rpradsb_disburse_amt  IS NOT NULL );
--      FOR UPDATE;

     BEGIN
       OPEN robinst_resched_disb_date_c ;
       FETCH robinst_resched_disb_date_c INTO aidy_code,
                                              pckg_audit_ind,
                                              resched_disb_date_ind ;
       IF robinst_resched_disb_date_c%NOTFOUND THEN
           resched_disb_date_ind := 'N';
       END IF;
       CLOSE robinst_resched_disb_date_c ;
--
       IF resched_disb_date_ind = 'N' THEN
           RETURN;
       END IF;
--
       first_attend_date := NULL;
       first_attend_date := rokmisc.f_get_fa_first_attend_date(p_term_code,
                                                               p_pidm);
       IF first_attend_date IS NULL THEN
           RETURN;
       END IF;
--
       OPEN rordata_audit_ind_c ;
       FETCH rordata_audit_ind_c INTO audit_ind ;
       IF rordata_audit_ind_c%NOTFOUND THEN
           audit_ind := 'N';
       END IF;
       CLOSE rordata_audit_ind_c ;
--
       OPEN rpradsb_schedule_date_c;
       LOOP
          FETCH rpradsb_schedule_date_c INTO old_schedule_date,
                                             disb_sched_no_days,
                                             lv_rowid;
--
          EXIT WHEN rpradsb_schedule_date_c%NOTFOUND;
--
-- 70200-1 JMM
--        new_schedule_date := (first_attend_date + disb_sched_no_days);
--
          new_schedule_date := f_get_valid_schedule_date(aidy_code,
                                                         p_pidm,
                                                         p_term_code,
                                                         p_fund_code,
                                                         (first_attend_date + disb_sched_no_days),
                                                         old_schedule_date);

          IF old_schedule_date <> new_schedule_date THEN
-- 70300-1 JMM
                rb_award_disbursement.p_update(p_schedule_date => new_schedule_date,
                                               p_data_origin   => gb_common.DATA_ORIGIN,
                                               p_rowid         => lv_rowid);
--
--              UPDATE rpradsb
--                 SET rpradsb_schedule_date = new_schedule_date,
--                     rpradsb_activity_date = SYSDATE,
--                     rpradsb_user_id       = gb_common.f_sct_user
--              WHERE CURRENT OF rpradsb_schedule_date_c ;
--
          END IF;
--
       END LOOP;
       CLOSE rpradsb_schedule_date_c;
--
    END p_resched_fund_term_disburse ;

-------------------------------------------------------------------------------------------------

  PROCEDURE p_resched_fund_year_disburse (p_aidy_code IN rpradsb.rpradsb_aidy_code%TYPE,
                                          p_pidm      IN rpradsb.rpradsb_pidm%TYPE,
                                          p_fund_code IN rpradsb.rpradsb_fund_code%TYPE)
  IS

     -- define local variables

     term_code                        rpradsb.rpradsb_term_code%TYPE ;

     CURSOR rpradsb_term_code_c IS
        SELECT DISTINCT rpradsb_term_code
          FROM rpradsb
         WHERE rpradsb_aidy_code           = p_aidy_code
           AND rpradsb_pidm                = p_pidm
           AND rpradsb_fund_code           = p_fund_code
           AND rpradsb_sys_ind             = 'S'
           AND rpradsb_disb_sched_no_days IS NOT NULL
           AND rpradsb_disburse_date      IS NULL
           AND rpradsb_disburse_amt       IS NULL ;

     BEGIN
       OPEN rpradsb_term_code_c;
       LOOP
          FETCH rpradsb_term_code_c INTO term_code ;
          EXIT WHEN rpradsb_term_code_c%NOTFOUND;
--
          rokmisc.p_resched_fund_term_disburse(term_code,
                                               p_pidm,
                                               p_fund_code) ;
--
       END LOOP;
       CLOSE rpradsb_term_code_c;
--
    END p_resched_fund_year_disburse ;

-------------------------------------------------------------------------------------------------

  PROCEDURE p_resched_term_disburse (p_term_code IN rpradsb.rpradsb_term_code%TYPE,
                                     p_pidm      IN rpradsb.rpradsb_pidm%TYPE)
  IS

     -- define local variables

     aidy_code                        robinst.robinst_aidy_code%TYPE;
     pckg_audit_ind                   robinst.robinst_pckg_audit_ind%TYPE ;
     resched_disb_date_ind            robinst.robinst_resched_disb_date_ind%TYPE ;
     audit_ind                        rordata.rordata_audit_ind%TYPE ;
     first_attend_date                DATE ;
     old_schedule_date                rpradsb.rpradsb_schedule_date%TYPE ;
     new_schedule_date                rpradsb.rpradsb_schedule_date%TYPE ;
     disb_sched_no_days               rpradsb.rpradsb_disb_sched_no_days%TYPE ;
-- 70200-1 JMM
     lv_fund_code                     rpradsb.rpradsb_fund_code%TYPE;
-- 70300-1 JMM
     lv_rowid                         VARCHAR2(18);

     CURSOR robinst_resched_disb_date_c IS
        SELECT robinst_aidy_code,
               COALESCE(robinst_pckg_audit_ind,'N'),
               COALESCE(robinst_resched_disb_date_ind,'N')
          FROM robinst
         WHERE robinst_aidy_code =
                  (SELECT stvterm_fa_proc_yr
                     FROM stvterm
                    WHERE stvterm_code = p_term_code) ;

     CURSOR rordata_audit_ind_c IS
        SELECT COALESCE(rordata_audit_ind,'N')
          FROM rordata
         WHERE rordata_aidy_code = aidy_code
           AND rordata_cde       = 'RPRADSB_SCHEDULE_DATE' ;

-- 70300-1 JMM: added rowid column and removed FOR UPDATE clause.
     CURSOR rpradsb_schedule_date_c IS
        SELECT rpradsb_schedule_date,
               rpradsb_disb_sched_no_days,
               rpradsb_fund_code,
               rowid
          FROM rpradsb x
         WHERE rpradsb_aidy_code           = aidy_code
           AND rpradsb_pidm                = p_pidm
           AND rpradsb_term_code           = p_term_code
           AND rpradsb_sys_ind             = 'S'
           AND rpradsb_disb_sched_no_days IS NOT NULL
           AND rpradsb_disburse_date      IS NULL
           AND rpradsb_disburse_amt       IS NULL
           AND NOT EXISTS
                    (SELECT 'Y'
                       FROM rpradsb
                      WHERE rpradsb_aidy_code      = x.rpradsb_aidy_code
                        AND rpradsb_pidm           = x.rpradsb_pidm
                        AND rpradsb_term_code      = x.rpradsb_term_code
                        AND rpradsb_fund_code      = x.rpradsb_fund_code
                        AND rpradsb_disburse_date IS NOT NULL
                        AND rpradsb_disburse_amt  IS NOT NULL );
--      FOR UPDATE;

     BEGIN
       OPEN robinst_resched_disb_date_c ;
       FETCH robinst_resched_disb_date_c INTO aidy_code,
                                              pckg_audit_ind,
                                              resched_disb_date_ind ;
       IF robinst_resched_disb_date_c%NOTFOUND THEN
           resched_disb_date_ind := 'N';
       END IF;
       CLOSE robinst_resched_disb_date_c ;
--
       IF resched_disb_date_ind = 'N' THEN
           RETURN;
       END IF;
--
       first_attend_date := NULL;
       first_attend_date := rokmisc.f_get_fa_first_attend_date(p_term_code,
                                                               p_pidm);
       IF first_attend_date IS NULL THEN
           RETURN;
       END IF;
--
       OPEN rordata_audit_ind_c ;
       FETCH rordata_audit_ind_c INTO audit_ind ;
       IF rordata_audit_ind_c%NOTFOUND THEN
           audit_ind := 'N';
       END IF;
       CLOSE rordata_audit_ind_c ;
--
       OPEN rpradsb_schedule_date_c;
       LOOP
          FETCH rpradsb_schedule_date_c INTO old_schedule_date,
                                             disb_sched_no_days,
                                             lv_fund_code,
                                             lv_rowid;
--
          EXIT WHEN rpradsb_schedule_date_c%NOTFOUND;
-- 70200-1 JMM
--        new_schedule_date := (first_attend_date + disb_sched_no_days);
--
          new_schedule_date := f_get_valid_schedule_date(aidy_code,
                                                         p_pidm,
                                                         p_term_code,
                                                         lv_fund_code,
                                                         (first_attend_date + disb_sched_no_days),
                                                         old_schedule_date);
--
          IF old_schedule_date <> new_schedule_date THEN
-- 70300-1 JMM
                rb_award_disbursement.p_update(p_schedule_date => new_schedule_date,
                                               p_data_origin   => gb_common.DATA_ORIGIN,
                                               p_rowid         => lv_rowid);
--
--              UPDATE rpradsb
--                 SET rpradsb_schedule_date = new_schedule_date,
--                     rpradsb_activity_date = SYSDATE,
--                     rpradsb_user_id       = gb_common.f_sct_user
--              WHERE CURRENT OF rpradsb_schedule_date_c ;
--
          END IF;
--
       END LOOP;
       CLOSE rpradsb_schedule_date_c;
--
    END p_resched_term_disburse ;

-------------------------------------------------------------------------------------------------

  PROCEDURE p_resched_year_disburse (p_aidy_code IN rpradsb.rpradsb_aidy_code%TYPE,
                                     p_pidm      IN rpradsb.rpradsb_pidm%TYPE)
  IS

     -- define local variables

     term_code                        rpradsb.rpradsb_term_code%TYPE ;

     CURSOR rpradsb_term_code_c IS
        SELECT DISTINCT rpradsb_term_code
          FROM rpradsb
         WHERE rpradsb_aidy_code           = p_aidy_code
           AND rpradsb_pidm                = p_pidm
           AND rpradsb_sys_ind             = 'S'
           AND rpradsb_disb_sched_no_days IS NOT NULL
           AND rpradsb_disburse_date      IS NULL
           AND rpradsb_disburse_amt       IS NULL ;

     BEGIN
       OPEN rpradsb_term_code_c;
       LOOP
          FETCH rpradsb_term_code_c INTO term_code ;
          EXIT WHEN rpradsb_term_code_c%NOTFOUND;
--
          rokmisc.p_resched_term_disburse(term_code,
                                          p_pidm) ;
--
       END LOOP;
       CLOSE rpradsb_term_code_c;
--
    END p_resched_year_disburse ;

-------------------------------------------------------------------------------------------------

END rokmisc;		/* this ends the package */

/
