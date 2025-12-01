library(here)
library(vroom)

# This script counts the number of quarters in the last 5-years with at least 1 Monitoring and Reporting (MR) violation.

SDFW_MR_Violations_5yrs_grouped <-
  vroom(here("R/CWS_Analysis/02_Viol_Data_Prep/VIOLATIONS_LESS_THAN_5YRS_CPBD.csv")) %>%
  filter(.,
         (
           IS_HEALTH_BASED_IND == "N" &
             (
               VIOLATION_CATEGORY == "Monitoring and Reporting" |
                 VIOLATION_CATEGORY == "Monitoring Violation" |
                 VIOLATION_CATEGORY == "Reporting Violation" |
                 VIOLATION_CATEGORY == "Other"
             )
         ) |
           (
             IS_HEALTH_BASED_IND == "Y" &
               (
                 VIOLATION_CATEGORY == "Maximum Contaminant Level Violation" |
                   VIOLATION_CATEGORY == "Maximum Residual Disinfectant Level" |
                   VIOLATION_CATEGORY ==
                   "Treatment Technique Violation"
               )
           )) %>%
  group_by(PWSID) %>%
  distinct(PWSID, FYQTR, .keep_all = TRUE) %>%
  reframe(MR_VIOL_COUNT_QTRS_5YRS  = n())

# Export
write.csv(SDFW_MR_Violations_5yrs_grouped, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/SDFW_MR_Violations_5yrs_grouped.csv"), row.names = FALSE)
