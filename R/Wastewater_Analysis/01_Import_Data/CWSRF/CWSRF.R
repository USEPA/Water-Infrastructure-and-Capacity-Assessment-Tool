# This script is used to import CWSRF Data from OWSRF
library(here)
library(RODBC)
library(dplyr)
library(vroom)

# Create a connection to SDWIS----

# Set user defined path to environment variables
OWSRF_DB <- Sys.getenv("OWSRF_DB")
OWSRF_UN <- Sys.getenv("OWSRF_UN")
OWSRF_PW <- Sys.getenv("OWSRF_PW")

channel_OWSRF <- odbcConnect(OWSRF_DB, OWSRF_UN, OWSRF_PW)

# Load configuration variables
source(here("R/Wastewater_Analysis/00_Wastewater_Config.R"))

# Clean Water Query ----

CW_Query <- "
SELECT years_after_agree_sign Years_After_agree_Sign,
       a.agreement_date agreement_date, 
       a.init_agreement_date init_agree_date, 
       a.init_agreement_amt init_agree_amt,  
       a.borrower_name,
       a.assistance_type_descr assistance_type,
       a.state_loan_number, 
       a.repayment_period,
       a.funding_method  fund_method, 
       CASE WHEN a.additional_subsidy = 'Y' THEN 'Yes' 
            WHEN a.additional_subsidy = 'N' THEN 'No' END add_sub, 
        a.state_name,
        a.region_name,
        a.interest_rate,
        a.agreement_type_descr agree_type,
        CASE WHEN a.sponsorship_lending = 'Y' THEN 'Yes' 
             WHEN a.sponsorship_lending = 'N' THEN 'No' END sponsorship_lending,
        CASE WHEN a.programmatic_finance = 'Y' THEN 'Yes' 
             WHEN a.programmatic_finance = 'N' THEN 'No' END programmatic_finance,
        a.implement_partner, 
        a.fee_rate,
        a.upfront_fees, 
        a.finance_charge,  
        CASE WHEN a.hardship = 'Y' THEN 'Yes' 
             WHEN a.hardship = 'N' THEN 'No' 
        END hardship,  
        CASE WHEN a.conduit_finance = 'Y' THEN 'Yes' 
             WHEN a.conduit_finance = 'N' THEN 'No' 
        END conduit_finance,
          --Population Served By Project 
        project_tot_project_pop  proj_pop,
        a.tot_agreement_amt agree_amt,
        a.tot_subsidy_amt sub_amt,
        a.project_tot_gpr_amt total_proj_gpr,
        a.tot_local_amt + a.tot_state_amt 
            + a.tot_federal_amt nonSRFFunding, 
        a.agreement_seq agreement_seq,
        CASE WHEN a.fk_epa_tracking_no IS NOT NULL THEN 'Yes' 
             ELSE 'No' 
        END is_linked,
        a.linked_agree_info linked_track, 
        p_needs.p_need_cat,

        a.tot_local_amt localAmt,
        a.tot_state_amt stateAmt,
        a.tot_federal_amt  federalAmt,

        a.project_all_start_date p_start,
        a.project_all_end_date p_end,
        a.project_description  p_description,
        a.tot_no_of_subagreements \"Sub Agreements to Date\",
 
        a.project_facility_name facility_name, 
        a.project_npdes_permit npdes_permitnumber, 
        a.project_non_npdes nonpdes_permit,
        all_pl.county, all_pl.huc12,   --- STATERF-856
        a.project_name,
        a.project_waterquality waterquality,
        a.project_complianceobjective complianceobjective, 
        a.project_affectedwaterbodystatus affectedwaterbodystatus,
        p_pwu.restore_wateruse,
        p_pwu.protect_wateruse,
        a.EPA_TRACKING_NO,
        latitude,
        longitude
-----------------------------
FROM BASE_AGREEMENT_SUMMARY a,    --- line 65
 ( SELECT fk_agreement_seq, 
          SUM(tot_needs_amount) p_need,  
          LISTAGG(--CASE WHEN tot_needs_amount <> 0 THEN --STATERF-869
                  category_description ||': '||--STATERF-869 remove \".a\"
                  TO_CHAR(tot_needs_amount, 'FML999G999G999G990D00') || '' 
                  --END       --STATERF-869
                  , '
 'ON OVERFLOW TRUNCATE) 
                  WITHIN GROUP (ORDER BY category_order_by) 
                       p_need_cat --STATERF-869 remove \".a\"
    FROM ( --STATERF-869           
          SELECT c.fk_agreement_seq,            --STATERF-869
                 SUM(tot_needs_amount) tot_needs_amount, --STATERF-869
                 a.category_description, a.category_order_by--STATERF-869
                 --------same code just moved to the right            
            FROM BASE_PROJ_NEEDS_CATEGORIES a
               , BASE_CW_PROJECTS c
           WHERE c.project_seq = a.fk_project_seq
             --AND (:P14_NEEDS_CAT IS NULL OR ((INSTR(':'|| :P14_NEEDS_CAT 
             --    || ':', ':' || fk_category_seq ||  ':') > 0  )
             --    AND tot_needs_amount <> 0  ) )
             --AND (:P14_INIT_NEEDS_S_AMT IS NULL 
             --      OR ( tot_needs_amount 
             -->= replace(replace(:P14_INIT_NEEDS_S_AMT, '$', ''), ',','')))
             --AND (:P14_INIT_NEEDS_E_AMT IS NULL 
             --    OR ( tot_needs_amount 
             --<= replace(replace(:P14_INIT_NEEDS_E_AMT, '$', ''), ',','')))
             AND a.year_end =  2025
                   --STATERF-869 TSEARS Duplicate needs listed
             AND c.year_end =  2025  
             AND a.tot_needs_amount <> 0  --STATERF-869
                -----AND fk_agreement_seq = 1331519 --- TEST  
           GROUP BY c.fk_agreement_seq,              --STATERF-869
                 a.category_description, a.category_order_by --STATERF-869  
          )  --STATERF-869           
        GROUP BY fk_agreement_seq
  ) p_needs,    --- original line 87
        (SELECT fk_agreement_seq,  
                SUM(assigned_subsidy_amt) sub_grant1 ,
                SUM(assigned_subsidy_cwa_amt) sub_grant2,
                SUM(tot_subsidy_amt) tot_sub_grant,
                SUM( tot_grant_amt ) tot_grant,
                SUM(assigned_gpr_amt) gpr_grant 
           FROM BASE_RELATED_AGREE_GRANTS a
          --WHERE (:P14_GRANT_NAME IS NULL OR grant_name = :P14_GRANT_NAME)
            where a.year_end = 2025
          GROUP BY fk_agreement_seq
        ) grantUpd,
  (SELECT DISTINCT base_fk_agreement_seq fk_agreement_seq,  -- line 113
        LISTAGG( pl.latitude, '

' ON OVERFLOW TRUNCATE) 
             WITHIN GROUP (ORDER BY pl.fk_project_seq)  latitude,
        
        LISTAGG( pl.longitude, '
' ON OVERFLOW TRUNCATE) 
             WITHIN GROUP (ORDER BY pl.fk_project_seq)  longitude,
             
        LISTAGG( pl.pl_description, '

' ON OVERFLOW TRUNCATE) 
             WITHIN GROUP (ORDER BY pl.fk_project_seq)  pl_description,
        --county, huc12   --- STATERF-856  --- commented STATERF-869
        -- the following new lines for STATERF-869 -------------------------------
        LISTAGG(DISTINCT CASE WHEN pl.county IS NOT NULL THEN pl.county || '' END 
               , '
 ' ON OVERFLOW TRUNCATE) 
             WITHIN GROUP (ORDER BY pl.base_fk_agreement_seq) county,
        LISTAGG(DISTINCT CASE WHEN pl.huc12 IS NOT NULL THEN pl.huc12 || '' END 
               , '
 ' ON OVERFLOW TRUNCATE) 
             WITHIN GROUP (ORDER BY pl.base_fk_agreement_seq) huc12
  FROM BASE_PROJECT_LOCATIONS pl                         -- originally line 119
 WHERE pl.year_end =  2025
GROUP BY base_fk_agreement_seq
) all_pl, 
        (SELECT BASE_FK_AGREEMENT_SEQ fk_agreement_seq, 
            LISTAGG(CASE WHEN Wuo.Restore_Code_Fk IS NOT NULL THEN use_code|| ': ' ||
                    CASE WHEN Wuo.Restore_Code_Fk = 'P' 
                       THEN 'Primary' else 'Secondary' END END, 
                       '

' ON OVERFLOW TRUNCATE) WITHIN GROUP 
                       (ORDER BY use_code_order) restore_wateruse,
            listagg( CASE WHEN Wuo.Protect_Code_Fk IS NOT NULL THEN use_code || ': ' ||
                     CASE WHEN Wuo.Protect_Code_Fk = 'P' 
                        THEN 'Primary' ELSE 'Secondary' END END, 
                        '

' ON OVERFLOW TRUNCATE) WITHIN GROUP 
                        (ORDER BY use_code_order) protect_wateruse   
       FROM BASE_PROJECT_WATERUSE wuo 
      WHERE (Wuo.Protect_Code_Fk IS NOT NULL OR Wuo.Restore_Code_Fk is not null ) 
        AND wuo.year_end = 2025
      GROUP BY BASE_FK_AGREEMENT_SEQ 
        ) p_pwu
--Joins         
WHERE a.agreement_seq = grantUpd.fk_agreement_seq(+)
  AND p_needs.fk_agreement_seq  = a.agreement_seq  
  AND all_pl.fk_agreement_seq (+) = a.agreement_seq
  AND p_pwu.fk_agreement_seq (+) = a.agreement_seq   
  AND a.year_end =  2025
  AND (a.state_fy >= 2016 AND a.state_fy <= 2025)
  AND ( a.latest_amendment_ind = 1 ) 
ORDER BY a.years_after_agree_sign DESC;
"

# Set-up and run query----
CWSRF_Raw_Data <- sqlQuery(
  channel_OWSRF,
  CW_Query)

# Subset on initial agreement date and select columns ----
CWSRF_Subset <- CWSRF_Raw_Data %>%
  filter(as.Date(INIT_AGREE_DATE, "%Y-%m-%d") >= CWSRF_Initial_Agreement_Date_Start) %>%
  dplyr::select(
    NPDES_ID = NPDES_PERMITNUMBER,
    Disadvantaged_Assistance = HARDSHIP,
    Initial_Agreement_Date=INIT_AGREE_DATE 
  )

# Export dataframe ----
write.csv(CWSRF_Subset, here("Input_Data/CWSRF/CWSRF_History.csv"), row.names = FALSE)