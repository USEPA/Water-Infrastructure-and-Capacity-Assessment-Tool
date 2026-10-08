# This script joins the output from the CSO analysis with the census data

# Clear environment
rm(list = ls())

library(here)
library(dplyr)
library(dplyr)
library(here)
library(sf)

# Import Data ----
# Violation/DWSRF/CSO/Lagoon Data
NPDES_VIOL <- # vroom(here("R/Wastewater_Analysis/05_Join_Analysis_Components/POTW_VIOL_LAGOON_CWSRF_CSO_OUT.csv"))
  readRDS(here("R/Wastewater_Analysis/05_Join_Analysis_Components/Temp_Outputs/POTW_VIOL_LAGOON_CWSRF_CSO_OUT.rds"))

# Population weighted census data
Pop_Weighted_Census <- # vroom(here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Cleaned_Demographic_data_2025-11-20_FINAL_OUTPUT.csv"))
  readRDS(here("R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/POTW_cols_selected.rds"))


# Join Data ----
NPDES_VIOL_CENSUS <- merge(NPDES_VIOL,
  Pop_Weighted_Census,
  by = "NPDES_ID",
  all.x = TRUE
)
# Export Data

saveRDS(NPDES_VIOL_CENSUS, here("R/Wastewater_Analysis/05_Join_Analysis_Components/Temp_Outputs/NPDES_CENSUS_OUT.rds"))
