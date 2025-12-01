library(here)
library(vroom)
library(dplyr)

# This script identifies all water systems that are an Enforcement Priority
ENF_PRIORITY_SYSTEM <- vroom(here("Input_Data/ECHO/ECHO_FAC_DETAILS_PWS.csv")) %>%
  filter(SNC == "Enforcement Priority") %>%
  mutate(ENF_PRIORITY_SYS = "Y") %>%
  dplyr::select(., PWSID, ENF_PRIORITY_SYS) %>%
  distinct(., PWSID, .keep_all = TRUE) # Remove duplicates based on PWSID

# Export
write.csv(ENF_PRIORITY_SYSTEM, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/ENF_PRIORITY_SYSTEM.csv"), row.names = FALSE)
