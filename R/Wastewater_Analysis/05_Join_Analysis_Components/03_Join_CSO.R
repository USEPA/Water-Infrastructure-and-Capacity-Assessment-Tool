# This script joins NPDES Violation/Lagoon/CWSRF data with CSO data

# Clear environment
rm(list = ls())

library(vroom)
library(here)
library(dplyr)

# Import data ----
CSO_DATA <- # vroom(here("Input_Data/ECHO/CSO_COUNT_BY_POTW.csv"))
  readRDS(here("R/Wastewater_Analysis/01_Import_Data/NPDES/Temp_Outputs/CSO_COUNT_BY_POTW.rds"))

NDPES_LAGOON_CWSRF <- # vroom(here("R/Wastewater_Analysis/05_Join_Analysis_Components/POTW_VIOL_LAGOON_CWSRF_OUT.csv"))
  readRDS(here("R/Wastewater_Analysis/05_Join_Analysis_Components/Temp_Outputs/POTW_VIOL_LAGOON_CWSRF_OUT.rds"))

# Join datasets ----
# Merge NPDES data with CSO data
NDPES_LAGOON_DWSRF_CSO <-
  merge(
    NDPES_LAGOON_CWSRF,
    CSO_DATA[, c("NPDES_ID", "COUNT_OF_CSO_OUTFALLS")],
    by = "NPDES_ID",
    all.x = TRUE
  )

# Add a column for presence of CSO outfalls
NDPES_LAGOON_DWSRF_CSO$COMBINED_SEWER_SYSTEM <- ""

# Populate Blanks
NDPES_LAGOON_DWSRF_CSO <-
  NDPES_LAGOON_DWSRF_CSO %>%
  mutate(
    COMBINED_SEWER_SYSTEM = case_when(
      (COUNT_OF_CSO_OUTFALLS == "" | is.na(COUNT_OF_CSO_OUTFALLS)) ~ "N",
      TRUE ~ "Y"
    )
  )

# Export ----
# vroom_write(NDPES_LAGOON_DWSRF_CSO, here("R/Wastewater_Analysis/05_Join_Analysis_Components/POTW_VIOL_LAGOON_CWSRF_CSO_OUT.csv"), delim = ",")")

saveRDS(NDPES_LAGOON_DWSRF_CSO, here("R/Wastewater_Analysis/05_Join_Analysis_Components/Temp_Outputs/POTW_VIOL_LAGOON_CWSRF_CSO_OUT.rds"))