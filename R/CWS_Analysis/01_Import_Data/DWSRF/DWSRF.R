library(here)
library(dplyr)
library(readxl)
library(RODBC)
library(dplyr)
library(vroom)

# This script is used to import DWSRF data from OWSRF.

# Create a connection to OWSRF ----

# Set user defined environment variables
OWSRF_DB <- Sys.getenv("OWSRF_DB")
OWSRF_UN <- Sys.getenv("OWSRF_UN")
OWSRF_PW <- Sys.getenv("OWSRF_PW")

channel_OWSRF <- odbcConnect(OWSRF_DB, OWSRF_UN, OWSRF_PW)

# Load configuration variables
source(here("R/CWS_Analysis/00_config.R"))

# Drinking Water Query ----

# Define the SQL query
dw_query <- "
SELECT 
       a.years_after_agree_sign Years_After_agree_Sign,
       a.agreement_date agreement_date, 
       a.tot_agreement_amt agree_amt,
       a.init_agreement_date init_agree_date, 
       a.init_agreement_amt init_agree_amt, 
       a.borrower_name,
       a.assistance_type_descr assistance_type,
       a.epa_tracking_no,
       a.amendment_id,  
       a.state_loan_number,
       a.other_track_number,
       a.current_ind current_ind,
       a.status_descr status_descr,
       a.action_descr action_description, 
       a.repayment_period,
       a.funding_method fund_method, 
       CASE WHEN a.additional_subsidy = 'Y' THEN 'Yes' 
            WHEN a.additional_subsidy = 'N' THEN 'No' END add_sub,
       CASE WHEN a.nonsrf_state_funding = 'Y' THEN 'Yes' 
            WHEN a.nonsrf_state_funding = 'N' THEN 'No' END state_fund,
       CASE WHEN a.nonsrf_funding = 'Y' THEN 'Yes' 
            WHEN a.nonsrf_funding = 'N' THEN 'No' END fed_fund,
       CASE WHEN a.nonsrf_local_src = 'Y' THEN 'Yes' 
            WHEN a.nonsrf_local_src = 'N' THEN 'No' END local_fund,
       a.tot_no_of_subagreements no_sub_agree,
       a.tot_subsidy_amt  sub_amt,
       a.tot_state_amt + a.tot_federal_amt + a.tot_local_amt  nonSRFFund,
       a.project_count proj_count,
       a.project_tot_cost total_proj_cost,
       a.state_name,
       a.region_name,
       a.interest_rate,
       a.agreement_type_descr agree_type,
       CASE WHEN a.sponsorship_lending = 'Y' THEN 'Yes' 
            WHEN a.sponsorship_lending = 'N' THEN 'No' end sponsorship_lending,
       CASE WHEN a.programmatic_finance = 'Y' THEN 'Yes' 
            WHEN a.programmatic_finance = 'N' THEN 'No' END programmatic_finance,
       a.implement_partner, 
       a.fee_rate,
       a.upfront_fees,
       a.county_served,
       a.finance_charge,  
       CASE WHEN a.hardship = 'Y' THEN 'Yes' 
            WHEN a.hardship = 'N' THEN 'No' end hardship, 
       CASE WHEN a.same_entity = 'Y' THEN 'Yes' 
            WHEN a.same_entity = 'N' Then 'No' END same_entity, 
       a.conduit_finance,
       a.linked_deposit_finance,
       a.pwsid_borrower_pop + a.pwsid_related_pop  pop,
       a.project_count p_count,
       a.agreement_seq,
       CASE WHEN a.fk_epa_tracking_no IS NOT NULL THEN 'Yes' ELSE 'No' END is_linked,
       a.linked_agree_info linked_track,  
       p_comply.p_comply p_comply, 
       p_needs.p_need p_need, 
       p_needs.p_need_cat,
       p_needs.p_need_cat_filter,
       p_comply.p_comply_cat,
       p_comply.p_comply_cat_filter,
       a.tot_local_amt localAmt,
       a.tot_state_amt stateAmt,
       a.tot_federal_amt federalAmt,
       a.borrower_pwsid PWSID,
       a.project_all_start_date p_start,
       a.project_all_end_date p_end,
       nvl(grantUpd.tot_sub_grant, 0) grantSub,
       nvl(grantUpd.gpr_grant, 0) grantGPR,
       a.project_has_pcs has_pcs,
       a.project_tot_pcs_count total_pcs_count,
       bb.pws_type_name, bb.pws_owner,
       a.project_description p_description,
       a.tot_no_of_subagreements \"Sub Agreements to Date\",
       a.project_tot_infra_amt prin_green_amount,
       a.project_tot_energy_amt prin_green_energy,
       a.project_tot_water_amt prin_green_water,
       a.project_tot_innovative_amt prin_green_innovative,
       a.project_tot_est_lines \"EST_LEAD\",
       a.project_tot_final_lines \"FINAL_LEAD\",
       tot_hm_grant_amt + tot_hm_negative_interest_amt + tot_hm_principle_forgive_amt sub_amt_approp,
       a.tot_w_grant_amt + a.tot_w_negative_interest_amt + a.tot_w_principle_forgive_amt sub_amt_wifta,
       a.tot_disadv_neg_int_amt + a.tot_disadv_prin_forgive_amt sub_amt_dis,
       CASE WHEN a.project_contibute_resiliency = 'Y' THEN 'Yes' 
            WHEN a.project_contibute_resiliency = 'N' THEN 'No' END contribute_resiliency,
       a.project_name,
       a.project_has_cns,
       a.project_tot_cns_count,
       bb.city,
       bb.zip,
       bb.pws_name as PWS_Name
FROM BASE_AGREEMENT_SUMMARY a
LEFT JOIN (
    SELECT fk_agreement_seq, 
           SUM(tot_needs_amount) p_need,
           LISTAGG(category_description || ': ' || TO_CHAR(tot_needs_amount, 'FML999G999G999G990D00'), '
' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER BY category_order_by) p_need_cat,
           LISTAGG(category_description, ':') p_need_cat_filter
    FROM (
        SELECT b.fk_agreement_seq, a.category_description, a.category_order_by, SUM(a.tot_needs_amount) tot_needs_amount
        FROM BASE_PROJ_NEEDS_CATEGORIES a
        JOIN BASE_DW_PROJECTS b ON a.fk_dw_project_seq = b.project_seq
        WHERE a.year_end = 2025 AND b.year_end = 2025 AND a.tot_needs_amount <> 0
        GROUP BY b.fk_agreement_seq, a.category_description, a.category_order_by
    )
    GROUP BY fk_agreement_seq
) p_needs ON p_needs.fk_agreement_seq = a.agreement_seq
LEFT JOIN (
    SELECT base_fk_agreement_seq fk_agreement_seq, 
           SUM(tot_comply_amount) p_comply,
           LISTAGG(CASE WHEN tot_comply_amount <> 0 THEN category_description || ': ' || TO_CHAR(tot_comply_amount, 'FML999G999G999G990D00') END, '
' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER BY fk_cc_seq) p_comply_cat,
           LISTAGG(category_description, ':') p_comply_cat_filter
    FROM BASE_PROJ_COMPLIANCE a
    WHERE a.year_end = 2025
    GROUP BY base_fk_agreement_seq
) p_comply ON p_comply.fk_agreement_seq = a.agreement_seq
LEFT JOIN BASE_SRF_WATER_SYSTEM_INFO bb ON a.borrower_pwsid = bb.pwsid AND a.year_end = bb.year_end
LEFT JOIN (
    SELECT fk_agreement_seq, 
           SUM(assigned_subsidy_amt) sub_grant1,
           SUM(ASSIGNED_SUBSIDY_SDWA_AMT) sub_grant2,
           SUM(tot_subsidy_amt) tot_sub_grant,
           SUM(tot_grant_amt) tot_grant,
           SUM(assigned_gpr_amt) gpr_grant
    FROM BASE_RELATED_AGREE_GRANTS a
    WHERE a.year_end = 2025
    GROUP BY fk_agreement_seq
) grantUpd ON a.agreement_seq = grantUpd.fk_agreement_seq
WHERE a.latest_amendment_ind = 1
  AND a.year_end = 2025
  AND a.state_fy BETWEEN 2016 AND 2025
  AND a.program = 'DW'
ORDER BY ROUND((SYSDATE - a.agreement_date)/365, 1) DESC
"

# Set-up and run query----
DWSRF_Raw_Data <- sqlQuery(
  channel_OWSRF,
  dw_query)

# Subset on initial agreement date and select columns ----
DWSRF_Subset <- DWSRF_Raw_Data %>%
  filter(as.Date(INIT_AGREE_DATE, "%Y-%m-%d") >= DWSRF_Initial_Agreement_Date_Start) %>%
  dplyr::select(
    PWSID,
    Disadvantaged_Assistance = HARDSHIP,
   Initial_Agreement_Date=INIT_AGREE_DATE 
  )
  
# Export -----------------------
write.csv(DWSRF_Subset, here("Input_Data/DWSRF/DWSRF_History.csv"), row.names = FALSE)
