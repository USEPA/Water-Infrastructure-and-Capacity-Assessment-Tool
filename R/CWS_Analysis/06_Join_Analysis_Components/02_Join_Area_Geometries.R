library(vroom)
library(dplyr)
library(here)
library(sf)
library(tigris)
library(stringr)

# This script joins a merged violation/area served/census dataset with geometry (SAB and centroid point data for Counties/Territories/Tribes).

# Import Data ----
EC_Census_Area_Served <- vroom(
  here(
    "R/CWS_Analysis/06_Join_Analysis_Components/ENF_COMPL_CENSUS_AREA_SERVED.csv"
  )
) %>%
  mutate(TRIBAL_CODE = str_pad(TRIBAL_CODE, 3, pad = "0"))

QACHECK_county <- EC_Census_Area_Served %>%
  filter(COUNTY_SERVED == "Data not available") %>%
  group_by(PRIMACY_AGENCY) %>%
  summarise(
    count = n(),
    PWSID = paste(unique(PWSID), collapse = "; "),
  ) # Check that all counties have been populated

# CWS SAB dataset
CWS_SAB <- st_read(here("Input_Data/Locational/SAB/CWS_SAB.shp")) %>%
  mutate(ORD_SAB = "Y") %>%
  dplyr::select(PWSID, ORD_SAB)

# Get the list of all state FIPS codes
state_territory_fips <- unique(fips_codes$state)[1:57]  # Import FIPS codes for all states and US territories

# Import geometry for counties, municipios, and territories, converting the polygons to centroid points

# Function to get county data (counties, municipio, territory)
get_county_data <- function(state) {
  counties(state = state, cb = TRUE)  # Use cb = TRUE for a smaller, cartographic boundary
}

# Import geometries 
# County, municipio, and territory centroid
county_municipio_territory_centroid <- 
  lapply(state_territory_fips, get_county_data) %>% # Retrieve county data for all states
  bind_rows(.) %>% # Combine the list of data frames into a single data frame
  st_point_on_surface(.) %>%
  st_transform(., crs = 4269)

# Tribe centroid
Offreservation_Trust_Land_centroid <- st_read(here(
  "Input_Data/Locational/Tribe/Off_Reservation_Tribal_Areas.gdb"
))
  
AI_AN_centroid <- st_read(here(
  "Input_Data/Locational/Tribe/Reservation_Tribal_Areas.gdb"
))

# Merge tribal sfs
AI_AN_Res_and_Off_res_point <- rbind(AI_AN_centroid,Offreservation_Trust_Land_centroid) %>%
  st_transform(., crs = 4269)

# Merge SDWIS violation/area served/census data with the SAB, county, municipio, and territory centroid data ----

## Note which CWS have a SAB ----
CWS_Base <- merge(EC_Census_Area_Served,
                  st_drop_geometry(CWS_SAB), #drop geometry to avoid issues with the merge
                  by = "PWSID",
                  all.x = TRUE) %>%
  mutate(ORD_SAB = ifelse(is.na(ORD_SAB), "N", "Y")) 

## Tribal Area Join  ----
tribal_join <- CWS_Base %>%
  filter(ORD_SAB == "N" & PRIMACY_TYPE == "Tribal") %>%
  merge(
    AI_AN_Res_and_Off_res_point[, c("BIA_CODE")],
    .,
    by.x = "BIA_CODE",
    by.y = "TRIBAL_CODE",
    all.y = TRUE
  ) %>%
  .[!duplicated(.$PWSID), ] %>% #The reason there may be some duplicated entries when merged using BIA Code is that some Tribes have both reservation land and trust land, and the merge will create a row for each (as they have different geo-locations).
  rename(TRIBAL_CODE = BIA_CODE,
         geometry = SHAPE)

## County/Municipios and Territory Join ----
county_municipio_territory_join <- CWS_Base %>%
  filter(ORD_SAB == "N" &
           (PRIMACY_TYPE == "State" | PRIMACY_TYPE == "Territory")) %>%
  merge(
    county_municipio_territory_centroid[, c("COUNTYFP", "STATE_NAME")],
    .,
    by.x = c("COUNTYFP", "STATE_NAME"),
    by.y = c("ANSI_ENTITY_CODE", "PRIMACY_AGENCY"),
    all.y = TRUE
   ) %>%
  .[!duplicated(.$PWSID), ] %>%
  rename(
    ANSI_ENTITY_CODE = COUNTYFP,
    PRIMACY_AGENCY = STATE_NAME
  )

## SAB Join ----
SAB_Join <- CWS_Base %>%
  filter(ORD_SAB == "Y") %>%
  merge(
    CWS_SAB[c("PWSID")],
    .,
    by = "PWSID",
    all.y = TRUE
  ) %>%
  st_transform(., crs = 4269) %>%
  .[!duplicated(.$PWSID), ]

# Combine the results ----
combined_CWS_result <- bind_rows(tribal_join, county_municipio_territory_join, SAB_Join) 

# Export ----
st_write(
  combined_CWS_result,
  here("R/CWS_Analysis/06_Join_Analysis_Components/combined_CWS_result.gpkg"),
  append = FALSE
)
