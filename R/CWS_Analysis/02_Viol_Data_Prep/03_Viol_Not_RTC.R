# This script subsets all violations with a compliance period begin date within the last 5-years for violations that have not RTC'd. The script then groups and counts the number of violations not RTC'd by PWSID.

rm(list = ls()) # Clear environment

library(here)
library(zoo)
library(vroom)
library(dplyr)

# All violations that have not RTC (Count) [CPBD <5YRS]
ALL_VIOLATIONS_NON_RTC <- #vroom(here("R/CWS_Analysis/02_Viol_Data_Prep/VIOLATIONS_LESS_THAN_5YRS_CPBD.csv")) %>%
  readRDS(here("R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs/VIOLATIONS_LESS_THAN_5YRS_CPBD.rds"))%>%
  filter(is.na(RTC_DATE)) %>%
  group_by(PWSID) %>%
  reframe(VIOLATIONS_NON_RTC_COUNT = n())

# Export 
# write.csv(ALL_VIOLATIONS_NON_RTC, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/ALL_VIOLATIONS_NON_RTC.csv"), row.names = FALSE)

saveRDS(ALL_VIOLATIONS_NON_RTC, here("R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs/ALL_VIOLATIONS_NON_RTC.rds"))