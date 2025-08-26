library(here)
library(dplyr)
library(readxl)

# This script is used to reformat CWSRF Data

# Import CWSRF Data -----------------------
CWSRF_History <-
  read_xlsx(
    here(
      "R/Wastewater_Analysis/01_Import_Data/CWSRF/Program_Data",
      "CWSRF Data Pull_7_1_2014 to 6_30_2024.xlsx"
    ),
    1
  )

# Formatting -----------------------
names(CWSRF_History) <- gsub(" ", "_", names(CWSRF_History)) #remove spaces

CWSRF_History_Subset <- CWSRF_History %>%
  filter(., Latest_Agreement_Action == "Initial Agreement") %>% # Only include initial agreements 
  dplyr::select(NPDES_Permit_Number, "Hardship/Disadvantaged_Community?", Latest_Agreement_Action, Initial_Agreement_Date)
  
# Export -----------------------
write.csv(CWSRF_History_Subset, here("Input_Data/CWSRF/CWSRF_History.csv"), row.names = FALSE)
