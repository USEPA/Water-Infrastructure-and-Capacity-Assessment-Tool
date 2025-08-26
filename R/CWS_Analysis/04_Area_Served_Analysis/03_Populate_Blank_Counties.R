library(here)
library(vroom)
library(dplyr)
library(stringr)
library(tigris)

# This script populates county name information using available City Served data from SDWIS Geographic Area data, and matches it with place data from the tigris package.

# Import Data -------------

# SDWIS area served data with tribe names
SDWIS_AREA_SERVED_COUNTY <- vroom(here("R/CWS_Analysis/04_Area_Served_Analysis/02_SDWIS_GEOGRAPHIC_AREA_COUNTY.csv"))


# Retrieve census place data for states with missing county data ----
QACHECK_Missing_County <- SDWIS_AREA_SERVED_COUNTY %>%
  filter(is.na(COUNTY_SERVED)) %>%
  group_by(PRIMACY_AGENCY_CODE) %>%
  summarise(
    count = n(),
    PWSID = paste(unique(PWSID), collapse = "; "),
    AREA_TYPE_CODE = paste(unique(AREA_TYPE_CODE), collapse = "; ")
  ) 

states_with_missing_county <- QACHECK_Missing_County$PRIMACY_AGENCY_CODE 

# Create vector of state codes to ignore (because county data are not needed)
codes_to_ignore <- c("01", "02", "04", "05" ,"06" ,"07", "08", "09" ,"10" ,"MP", "NN", "AS", "VI", "GU")

# Filter the vector by excluding the codes_to_remove
filtered_states_with_missing_county <- states_with_missing_county[!(states_with_missing_county %in% codes_to_ignore)]

# Function to get place data for a specific state
get_place_data <- function(state) {
  tryCatch({
    places(state = state, cb = TRUE)  # cb = TRUE for cartographic boundary files
  }, error = function(e) {
    message("Error retrieving data for state: ", state, " - ", e$message)
    return(NULL)  # Return NULL if there's an error
  })
}

# Retrieve place data for all specified states
places_list <- lapply(filtered_states_with_missing_county, get_place_data)

# Combine the list of data frames into a single data frame
all_places_df <- bind_rows(places_list) %>%
  mutate(county_code = substr(GEOID, start = 3, stop = 5)) %>%
  st_drop_geometry(.) %>%
  mutate(NAME = str_to_upper(NAME), NAMELSAD = str_to_upper(NAMELSAD)) # Convert place names to uppercase

# Retrieve census county data for states with missing county data ----

# Function to get county data 
get_county_data <- function(state) {
  counties(state = state, cb = TRUE)  # Use cb = TRUE for a smaller, cartographic boundary
}

# Retrieve county data for all states and territories
get_select_counties <- lapply(filtered_states_with_missing_county, get_county_data)

# Combine the list of data frames into a single data frame
all_counties_df <- bind_rows(get_select_counties) %>%
  mutate(county_code = substr(GEOID, start = 3, stop = 5)) %>%
  st_drop_geometry(.)

# Populate county served using census place data ----

# Merge SDWIS City Data with tigris file (places and county tigris files) to populate County Names 

# Create a function to find matches between city names in SDWIS and place names in the tigris file
find_matches <- function(city_served, df_B) {
  match_name <- df_B$NAME == city_served
  match_namelsad <- df_B$NAMELSAD == city_served
  match_idx <- which(match_name | match_namelsad)
  
  if (length(match_idx) > 0) {
    return(df_B[match_idx[1], , drop = FALSE])
  } else {
    return(data.frame(NAME = NA, NAMELSAD = NA, Value_B = NA))
  }
}

# Apply the function to each row in the dataframe to find city name matches
matched_rows <- lapply(SDWIS_AREA_SERVED_COUNTY$CITY_SERVED, find_matches, df_B = all_places_df)

# Combine the matched rows into a data frame
matched_df <- bind_rows(matched_rows)

# Combine df_A with the matched data
df_joined <- bind_cols(SDWIS_AREA_SERVED_COUNTY, matched_df) %>%
  select(
    "CITY_SERVED",
    "PRIMACY_AGENCY_CODE",
    "PWSID",
    "TRIBAL_NAME",
    "TRIBAL_CODE",
    "STATE_SERVED",
    "ANSI_ENTITY_CODE",
    "ZIP_CODE_SERVED",
    "AREA_TYPE_CODE",
    "COUNTY_SERVED",
    "county_code"
  )

# Join county data
SDWIS_areas_city_county_match <- # Merge dataframe with tigris file on populated places, to obtain a corresponding county code
  merge(
    df_joined,
    all_counties_df[, c("COUNTYFP", "NAME", "STUSPS")],
    by.x = c("county_code", "PRIMACY_AGENCY_CODE"),
    by.y = c("COUNTYFP", "STUSPS"),
    all.x = TRUE
  ) %>%  # Merge the above output with tigris file on counties places
  mutate(
    COUNTY_SERVED = case_when(
      is.na(COUNTY_SERVED) ~ paste(NAME),
      TRUE ~ COUNTY_SERVED
    ), # Populate the county served field if it is blank and if there is a county name available from the previous merge
    COUNTY_SERVED = case_when(
      COUNTY_SERVED == "NA" ~ paste("Data not available"),
      TRUE ~ COUNTY_SERVED
    )
  ) 

QACHECK_missing_county_remain <- SDWIS_areas_city_county_match %>%
  filter(COUNTY_SERVED == "Data not available") %>%
  group_by(PRIMACY_AGENCY_CODE) %>%
  summarise(
    count = n(),
    PWSID = paste(unique(PWSID), collapse = "; "),
    AREA_TYPE_CODE = paste(unique(AREA_TYPE_CODE), collapse = "; ")
  ) # Check that all counties have been populated

# Export ----
write.csv(SDWIS_areas_city_county_match, here("R/CWS_Analysis/04_Area_Served_Analysis/03_SDWIS_AREA_SERVED_POPULATED_CNTY.csv"), row.names = FALSE)
