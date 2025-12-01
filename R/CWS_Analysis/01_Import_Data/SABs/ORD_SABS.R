library(here)
library(sf)
library(dplyr)

# This script imports the latest CWS service area boundary dataset. 

# Import SAB dataset ----
# CWS_SAB <- st_read(here("R/01_Import_Data/SABS/Water_System_Boundaries/Final.shp")) %>%
#   mutate(ORD_SAB = "Y") %>%
#   dplyr::select(PWSID, PWS_Name, ORD_SAB)

furl.SAB <- "https://services.arcgis.com/cJ9YHowT8TU7DUyn/ArcGIS/rest/services/Water_System_Boundaries/FeatureServer/0"

# Save URL as feature layer object (contains layer metadata)
flayer.SAB <- arc_open(furl.SAB)

# Select layer
CWS_SAB <- arc_select(flayer.SAB) %>%
    mutate(ORD_SAB = "Y") %>%
    dplyr::select(PWSID, PWS_Name, ORD_SAB)

# Export ----
st_write(CWS_SAB, here("Input_Data/Locational/SAB", "CWS_SAB.shp"), row.names = FALSE)
