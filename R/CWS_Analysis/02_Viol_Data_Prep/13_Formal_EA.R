# This script counts the number of Formal Enforcement Actions for violations that have not RTCd

rm(list = ls()) # Clear environment

library(here)
library(vroom)
library(dplyr)

#Count of individual formal enforcement actions that have not returned to compliance
FEA_Not_RTC <- #vroom(here("Input_Data/SDWIS/Formal_Enforcement_Actions.csv")) %>% 
  readRDS(here("R/CWS_Analysis/01_Import_Data/SDWIS/Temp_Outputs/Formal_Enforcement_Actions.rds")) %>% # This .csv is already subset for those that have not RTCd
  group_by(PWSID) %>%
  distinct(PWSID, LATEST_ENFORCEMENT_ID, .keep_all = TRUE) %>% # Remove duplicates based on PWSID and latest enforcement ID.
  reframe(FEA_VIOL_NONRTC_COUNT = n())

# Export
# write.csv(FEA_Not_RTC, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/FEA_Not_RTC.csv"), row.names = FALSE)

saveRDS(FEA_Not_RTC, here("R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs/FEA_Not_RTC.rds"))
