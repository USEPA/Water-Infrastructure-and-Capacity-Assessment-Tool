# This script identifies all water systems that are an Enforcement Priority

rm(list = ls()) # Clear environment

library(here)
library(vroom)
library(dplyr)

ENF_PRIORITY_SYSTEM <- #vroom(here("Input_Data/ECHO/ECHO_FAC_DETAILS_PWS.csv")) %>%
  readRDS(here("R/CWS_Analysis/01_Import_Data/ECHO/Temp_Outputs/ECHO_FAC_DETAILS_PWS.rds")) %>%
  filter(SNC == "Enforcement Priority") %>%
  mutate(ENF_PRIORITY_SYS = "Y") %>%
  dplyr::select(., PWSID, ENF_PRIORITY_SYS) %>%
  distinct(., PWSID, .keep_all = TRUE) # Remove duplicates based on PWSID

# Export
# write.csv(ENF_PRIORITY_SYSTEM, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/ENF_PRIORITY_SYSTEM.csv"), row.names = FALSE)

saveRDS(ENF_PRIORITY_SYSTEM, here("R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs/ENF_PRIORITY_SYSTEM.rds"))
