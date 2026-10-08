# This script imports static data identifying POTWs that use lagoons, based on their treatment code.

# Clear all objects from the global environment
rm(list = ls())

library(here)
library(readxl)

lagoons_have_icis_code <-
  read_xlsx(
    here(
      "R/Wastewater_Analysis/01_Import_Data/Lagoon_Data/POTW Lagoon Data Quality Review_Nov12023.xlsx"
    ),
    "ICIS_Data"
  )

# Export ----
# write.csv(lagoons_have_icis_code,
#           here("Input_Data/Lagoon/LAGOON_ICIS_CODE.csv"),
#           row.names = FALSE)

saveRDS(lagoons_have_icis_code,here("R/Wastewater_Analysis/01_Import_Data/Lagoon_Data/Temp_Outputs/LAGOON_ICIS_CODE.rds"))
