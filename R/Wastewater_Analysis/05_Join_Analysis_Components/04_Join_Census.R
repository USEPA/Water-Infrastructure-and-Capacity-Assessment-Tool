library(vroom)
library(dplyr)
library(here)
library(sf)

# This script joins the output from the CSO analysis with the census data

# Import Data ----
# Violation/DWSRF/CSO/Lagoon Data
NPDES_VIOL <- vroom(here("R/Wastewater_Analysis/05_Join_Analysis_Components/POTW_VIOL_LAGOON_CWSRF_CSO_OUT.csv"))

# Population weighted census data
Pop_Weighted_Census <- vroom(here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Cleaned_Demographic_data_2025-11-20_FINAL_OUTPUT.csv"))

# Join Data ----
NPDES_VIOL_CENSUS <- merge(NPDES_VIOL,
                           Pop_Weighted_Census,
                           by = "NPDES_ID",
                           all.x = TRUE) 
# Export Data
vroom_write(NPDES_VIOL_CENSUS, here("R/Wastewater_Analysis/05_Join_Analysis_Components/NPDES_CENSUS_OUT.csv"), delim = ",")
