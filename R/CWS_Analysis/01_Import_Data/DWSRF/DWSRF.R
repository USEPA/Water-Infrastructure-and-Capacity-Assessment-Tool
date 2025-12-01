library(here)
library(dplyr)
library(readxl)

# This script is used to reformat DWSRF Data

# Import DWSRF Data -----------------------
DWSRF_History <-
  read_xlsx(
    here(
      "R/CWS_Analysis/01_Import_Data/DWSRF/Program_Data",
      "DWAgreementReport.xlsx"
    ),
    1
  )

# Formatting -----------------------
names(DWSRF_History) <- gsub(" ", "_", names(DWSRF_History)) #remove spaces

DWSRF_History_Subset <- DWSRF_History %>%
  filter(., Current_Agreement_Type == "Initial Agreement") %>% # Only include initial agreements 
  dplyr::select(PWSID, Disadvantaged_Assistance, Current_Agreement_Type, Initial_Agreement_Date)

# Note - if selection fails. Check column header formatted in source file.
  
# Export -----------------------
write.csv(DWSRF_History_Subset, here("Input_Data/DWSRF/DWSRF_History.csv"), row.names = FALSE)
