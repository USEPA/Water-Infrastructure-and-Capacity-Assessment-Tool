# This script joins SDWIS Geographic Area (area served) data with tribe name, based on tribal code.

rm(list = ls()) # Clear environment

library(here)
library(vroom)
library(dplyr)
library(stringr)
library(sf)
library(tigris)

# Import Data ----
Geographic_Area_import <- # vroom(here("Input_Data/SDWIS/SDWIS_GEOGRAPHIC_AREA.csv")) %>%
  readRDS(here("R/CWS_Analysis/01_Import_Data/SDWIS/Temp_Outputs/SDWIS_GEOGRAPHIC_AREA.rds")) %>% # Import SDWIS Geographic Area data
  mutate(TRIBAL_CODE = str_pad(TRIBAL_CODE,
    3,
    pad = "0"
  )) %>% # Pad Tribal codes with leading "0" if only 2 digits
  mutate(ANSI_ENTITY_CODE = str_pad(ANSI_ENTITY_CODE,
    3,
    pad = "0"
  )) # Pad ANSI codes with leading "0" if less than 3 digits

Tribal_Area_import <- #vroom(here("Input_Data/Locational/Tribe/tribe_codes_lower48.csv")) %>%
  readRDS(here("R/CWS_Analysis/01_Import_Data/Other_Area_Data/Tribal/Temp_Outputs/tribe_codes_lower48.rds")) %>%
  filter(!is.na(currentBIATribalCode)) # Filter out rows with no Tribal Code

# Match Tribal Codes to Tribe Names ----

SDWIS_GEOGRAPHIC_AREA_tribal <-
  merge(
    Geographic_Area_import, # Pad Tribal codes with leading "0" if only 2 digits
    (Tribal_Area_import[, c("currentName", "currentBIATribalCode")]),
    by.x = "TRIBAL_CODE",
    by.y = "currentBIATribalCode",
    all.x = TRUE
  )

# Export ----
# write.csv(SDWIS_GEOGRAPHIC_AREA_tribal, here("R/CWS_Analysis/04_Area_Served_Analysis/01_SDWIS_GEOGRAPHIC_AREA_TRIBAL.csv"), row.names = FALSE)

saveRDS(SDWIS_GEOGRAPHIC_AREA_tribal, here("R/CWS_Analysis/04_Area_Served_Analysis/Temp_Outputs/01_SDWIS_GEOGRAPHIC_AREA_TRIBAL.rds"))