# This script modified the input dataset which includes PWS with 4Log or Greater TT to create a summary field indicating if the PWS has 4Log or Greater TT. This information is used to determine the sanitary survey frequency for the water system. 

rm(list = ls()) # Clear environment

library(here)
library(zoo)
library(vroom)
library(dplyr)

# Import Data
# Greater_than_4log_treatment <- vroom(here("Input_Data/SDWIS/SDWIS_TT.csv")) 
Greater_than_4log_treatment <- readRDS(here("R/CWS_Analysis/01_Import_Data/SDWIS/Temp_Outputs/SDWIS_TT.rds"))

# Format
PWS_4LogGreater_TT <- Greater_than_4log_treatment %>%
  group_by(PWSID) %>%
  summarise(
    'TT_4Log' = "Y"
  )

# Export
# write.csv(PWS_4LogGreater_TT, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/PWS_4LogGreater_TT.csv"), row.names = FALSE)

saveRDS(PWS_4LogGreater_TT, here("R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs/PWS_4LogGreater_TT.rds"))