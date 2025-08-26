library(here)
library(vroom)
library(dplyr)
library(stringr)
library(tigris)

# This script joins SDWIS Geographic Area (area served) data with Census tigris file to populate missing county name data using ANSI ENtity Code.

# Import Data -------------

# SDWIS area served data with tribe names
SDWIS_AREA_SERVED_TRIBE_NAME <- vroom(here("R/CWS_Analysis/04_Area_Served_Analysis/01_SDWIS_GEOGRAPHIC_AREA_TRIBAL.csv"))

# Import FIPS codes for states and territories
# Get the list of all state and territory FIPS codes
state_fips <- unique(fips_codes$state)[1:57]  

# Function to get county data 
get_county_data <- function(state) {
  counties(state = state, cb = TRUE)  # Use cb = TRUE for a smaller, cartographic boundary
}

# Retrieve county data for all states and territories
all_counties <- lapply(state_fips, get_county_data)

# Combine the list of data frames into a single data frame
all_counties_df <- bind_rows(all_counties) %>%
  mutate(county_code = substr(GEOID, start = 3, stop = 5)) %>%
  st_drop_geometry(.)

# Merge SDWIS Geographic Area data with County Names -----------------
SDWIS_county_detail_included <-
  merge(
    SDWIS_AREA_SERVED_TRIBE_NAME,
    all_counties_df,
    by.x = c("ANSI_ENTITY_CODE", "PRIMACY_AGENCY_CODE"),
    by.y = c("county_code", "STUSPS"),
    all.x = TRUE
  ) 

# This script consolidates SDWIS Geographic Area (e.g., area served) data into a single cell, by area type.
SDWIS_areas_consolidated <- SDWIS_county_detail_included %>%
  group_by(PWSID) %>%
  summarise(
    PRIMACY_AGENCY_CODE = paste(unique(na.omit(PRIMACY_AGENCY_CODE)), collapse = "; "),
    TRIBAL_NAME = paste(unique(na.omit(currentName)), collapse = "; "),
    TRIBAL_CODE = paste(unique(na.omit(TRIBAL_CODE)), collapse = "; "),
    STATE_SERVED = paste(unique(na.omit(STATE_SERVED)), collapse = "; "),
    ANSI_ENTITY_CODE = paste(unique(na.omit(ANSI_ENTITY_CODE)), collapse = "; "),
    ZIP_CODE_SERVED = paste(unique(na.omit(ZIP_CODE_SERVED)), collapse = "; "),
    CITY_SERVED = paste(unique(na.omit(CITY_SERVED)), collapse = "; "),
    COUNTY_SERVED1 = paste(unique(na.omit(COUNTY_SERVED, NAME)), collapse = "; "),
    COUNTY_SERVED2 = paste(unique(na.omit(NAME)), collapse = "; "),
    AREA_TYPE_CODE = paste(unique(na.omit(AREA_TYPE_CODE)), collapse = "; ")
  ) %>%
  mutate(
    COUNTY_SERVED = case_when(
      COUNTY_SERVED1 == "" ~ paste(COUNTY_SERVED2),
      TRUE ~ COUNTY_SERVED1
    ),
    CITY_SERVED = str_to_upper(CITY_SERVED)
  ) 

# Export ----
write.csv(SDWIS_areas_consolidated, here("R/CWS_Analysis/04_Area_Served_Analysis/02_SDWIS_GEOGRAPHIC_AREA_COUNTY.csv"), row.names = FALSE)
