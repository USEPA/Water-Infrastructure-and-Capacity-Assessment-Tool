library(here)
library(sf)
library(dplyr)
library(arcgis)

# This script imports the latest CWS service area boundary dataset. 

# Import SAB dataset ----
furl.SAB <- "https://services.arcgis.com/cJ9YHowT8TU7DUyn/ArcGIS/rest/services/Water_System_Boundaries/FeatureServer/0"

# Save URL as feature layer object (contains layer metadata)
flayer.SAB <- arc_open(furl.SAB)

# Select layer
CWS_SAB <- arc_select(flayer.SAB) %>%
    mutate(ORD_SAB = "Y") %>%
    dplyr::select(PWSID, PWS_Name, ORD_SAB)

# Export ----
st_write(CWS_SAB, here("Input_Data/Locational/SAB", "CWS_SAB.shp"), row.names = FALSE, append=FALSE)
