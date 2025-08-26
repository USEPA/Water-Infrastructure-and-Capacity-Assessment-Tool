library(here)
library(zoo)
library(vroom)
library(dplyr)

# This script modified the input dataset which includes PWS with 4Log or Greater TT to create a summary field indicating if the PWS has 4Log or Greater TT, and removes unneeded columns.

# Import Data
Greater_than_4log_treatment <- vroom(here("Input_Data/SDWIS/SDWIS_TT.csv")) 

# Format
PWS_4LogGreater_TT <- Greater_than_4log_treatment %>%
  group_by(PWSID) %>%
  summarise(
    'TT_4Log' = "Y"
  )

# Export
write.csv(PWS_4LogGreater_TT, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/PWS_4LogGreater_TT.csv"), row.names = FALSE)
