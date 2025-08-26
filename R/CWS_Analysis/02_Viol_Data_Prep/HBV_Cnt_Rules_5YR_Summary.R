library(here)
library(zoo)
library(vroom)
library(dplyr)

# This script counts the number of quarters in the last 5-years with at least 1 HBV, and identifies the corresponding (unique) HB Rules Violated during the same period. 

HBV_Cnt_Rules_notRTC_5yr_Summary <- vroom(here("R/CWS_Analysis/02_Viol_Data_Prep/VIOLATIONS_LESS_THAN_5YRS_CPBD.csv")) %>%
  filter(., IS_HEALTH_BASED_IND == "Y" ) %>% # Filter for HBV 
         group_by(PWSID, FYQTR) %>% # Group data by PWSID and FYQTR
           summarise(HB_RULES_VIOLATED_5YRS = paste0(RULE, collapse = " | ")) %>% # Group HB Rules violated into a single cell
           group_by(PWSID) %>% # Group again, just by PWSID
  summarise(HBV_COUNT_QTRS_5YRS = n(), HB_RULES_VIOLATED_5YRS = paste0(HB_RULES_VIOLATED_5YRS, collapse = " | ")) # Count number of Qtrs and paste all HB Rules violated across all quarters into one cell.

# Function to remove duplicates in the HB_RULES_VIOLATED_5YRS field
remove_duplicates_within_cell <- function(cell) {
  elements <- unlist(strsplit(cell, " \\| "))
  unique_elements <- unique(elements)
  sorted_unique <- sort(unique_elements)
  return(paste(sorted_unique, collapse = " | "))
}

# Run function
HBV_Cnt_Rules_notRTC_5yr_Summary$HB_RULES_VIOLATED_5YRS <-
  sapply(
    HBV_Cnt_Rules_notRTC_5yr_Summary$HB_RULES_VIOLATED_5YRS,
    remove_duplicates_within_cell
  )

# Export
write.csv(HBV_Cnt_Rules_notRTC_5yr_Summary, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/HBV_Cnt_Rules_notRTC_5yr_Summary.csv"), row.names = FALSE)