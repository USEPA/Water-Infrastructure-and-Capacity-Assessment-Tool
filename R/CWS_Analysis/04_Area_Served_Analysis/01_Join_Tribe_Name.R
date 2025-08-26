library(here)
library(vroom)
library(dplyr)
library(stringr)
library(sf)
library(tigris)

# This script joins SDWIS Geographic Area (area served) data with tribe name, based on tribal code.

# Import Data ---- 
Geographic_Area_import <- vroom(here("Input_Data/SDWIS/SDWIS_GEOGRAPHIC_AREA.csv")) %>% # Import SDWIS Geographic Area data
  mutate(TRIBAL_CODE = str_pad(TRIBAL_CODE,
                               3,
                               pad = "0")) %>% # Pad Tribal codes with leading "0" if only 2 digits 
  mutate(ANSI_ENTITY_CODE = str_pad(ANSI_ENTITY_CODE,
                                    3,
                                    pad = "0")) # Pad ANSI codes with leading "0" if less than 3 digits

Tribal_Area_import <- vroom(here("Input_Data/Locational/Tribe/tribe_codes_lower48.csv")) %>%
  filter(!is.na(currentBIATribalCode)) # Filter out rows with no Tribal Code

# Match Tribal Codes to Tribe Names -----------------

SDWIS_GEOGRAPHIC_AREA_tribal <-
  merge(
    Geographic_Area_import, # Pad Tribal codes with leading "0" if only 2 digits
    (Tribal_Area_import[, c("currentName", "currentBIATribalCode")]),
    by.x = "TRIBAL_CODE",
    by.y = "currentBIATribalCode",
    all.x = TRUE
  ) 

# Export ----
write.csv(SDWIS_GEOGRAPHIC_AREA_tribal, here("R/CWS_Analysis/04_Area_Served_Analysis/01_SDWIS_GEOGRAPHIC_AREA_TRIBAL.csv"), row.names = FALSE)
