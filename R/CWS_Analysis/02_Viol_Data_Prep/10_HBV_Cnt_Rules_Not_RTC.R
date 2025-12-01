library(here)
library(zoo)
library(vroom)
library(dplyr)

# This script subsets violations with a compliance period begin date within the last 5-years for HBV that have not RTC'd. 
# The script then groups and counts the number of HBV not RTC'd, and HB Rules Violated by PWSID. 
# Finally, the script removes duplicate rule violations.

HBV_Cnt_Rules_notRTC <- vroom(here("R/CWS_Analysis/02_Viol_Data_Prep/VIOLATIONS_LESS_THAN_5YRS_CPBD.csv")) %>%
  filter(.,
         IS_HEALTH_BASED_IND == "Y", # Filter for HBV
         is.na(RTC_DATE))  %>% # Filter for HBV that have not RTCd
  group_by(PWSID) %>%
  summarise(HB_RULES_VIOL_NONRTC = paste0(RULE, collapse = " | "), # Group HBV Rule Violations
            HBV_NON_RTC_COUNT = n()) %>% # Count HBVs
  ungroup()

# Function to remove duplicates in the HB_RULES_VIOL_NONRTC field
remove_duplicates_within_cell <- function(cell) {
  elements <- unlist(strsplit(cell, " \\| "))
  unique_elements <- unique(elements)
  sorted_unique <- sort(unique_elements)
  return(paste(sorted_unique, collapse = " | "))
}

# Run function
HBV_Cnt_Rules_notRTC$HB_RULES_VIOL_NONRTC <-
  sapply(
    HBV_Cnt_Rules_notRTC$HB_RULES_VIOL_NONRTC,
    remove_duplicates_within_cell
  )

# Export
write.csv(HBV_Cnt_Rules_notRTC, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/HBV_Cnt_Rules_notRTC.csv"), row.names = FALSE)
