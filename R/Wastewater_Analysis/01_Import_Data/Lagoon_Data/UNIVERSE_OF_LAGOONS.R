# This script imports static data identifying POTWs that use lagoons, based on the Universe of Lagoon Report.

# Clear all objects from the global environment
rm(list = ls())

library(here)
library(readxl)

Lagoons_Universe_of_Lagoons <-
  read_xlsx(
    here(
      "R/Wastewater_Analysis/01_Import_Data/Lagoon_Data/POTW Lagoon Data Quality Review_Nov12023.xlsx"
    ),
    "OW Lagoon Codes"
  )

# Export ----
# write.csv(Lagoons_Universe_of_Lagoons,
#           here("Input_Data/Lagoon/LAGOON_UNIV_OF_LAGOONS.csv"),
#           row.names = FALSE)

saveRDS(Lagoons_Universe_of_Lagoons,here("R/Wastewater_Analysis/01_Import_Data/Lagoon_Data/Temp_Outputs/LAGOON_UNIV_OF_LAGOONS.rds"))
