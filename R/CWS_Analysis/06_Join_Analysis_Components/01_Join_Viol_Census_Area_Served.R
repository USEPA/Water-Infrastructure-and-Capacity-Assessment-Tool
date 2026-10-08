# This script joins the output from the enforcement and compliance analysis with the census data and Area Served data

# Clear environment
rm(list = ls())

library(vroom)
library(dplyr)
library(here)
library(sf)

# Import Data ----
# Enforcement and compliance dataset
enf_compl_data <-
  #   vroom(
  #   here(
  #     "R/CWS_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/merged_enf_compl_df_postprocessing_complete.csv"
  #   )
  # )
  readRDS(here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/Temp_Outputs/merged_enf_compl_df_postprocessing_complete.rds"))


# SDWIS area served data (consolidated)
SDWIS_Area_Served_Consolidated <-
  #   vroom(
  #   here(
  #     "R/CWS_Analysis/04_Area_Served_Analysis/03_SDWIS_AREA_SERVED_POPULATED_CNTY.csv"
  #   )
  # )
  readRDS(here("R/CWS_Analysis/04_Area_Served_Analysis/Temp_Outputs/03_SDWIS_AREA_SERVED_POPULATED_CNTY.rds"))

# Population weighted census data
Pop_Weighted_Census <-
  #   vroom(
  #   here(
  #     "R/CWS_Analysis/05_Demographic_Analysis/PWS_Final_Weighted_Demographic_Data.csv"
  #   )
  # )
  readRDS(here("R/CWS_Analysis/05_Demographic_Analysis/Temp_Outputs/PWS_Final_Weighted_Demographic_Data.rds"))

# Join Data ----

# Merge enforcement/compliance data with SDWIS Area Served data, followed by weighted census data
ENF_COMPL_CENSUS_AREA_SERVED <- merge(enf_compl_data,
  SDWIS_Area_Served_Consolidated[c(
    "PWSID",
    "CITY_SERVED",
    "COUNTY_SERVED",
    "TRIBAL_NAME",
    "TRIBAL_CODE",
    "ANSI_ENTITY_CODE",
    "ZIP_CODE_SERVED"
  )],
  by = "PWSID",
  all.x = TRUE
) %>% # Merge enforcement/compliance data with SDWIS Area Served Data
  merge(., Pop_Weighted_Census, by = "PWSID", all.x = TRUE) # Merge above output with SAB and census data

# Export Data
# write.csv(
#   ENF_COMPL_CENSUS_AREA_SERVED,
#   here(
#     "R/CWS_Analysis/06_Join_Analysis_Components/ENF_COMPL_CENSUS_AREA_SERVED.csv"
#   )
# )

saveRDS(ENF_COMPL_CENSUS_AREA_SERVED,here("R/CWS_Analysis/06_Join_Analysis_Components/Temp_Outputs/ENF_COMPL_CENSUS_AREA_SERVED.rds"))
