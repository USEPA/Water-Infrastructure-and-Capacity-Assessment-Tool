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
    dplyr::select(PWSID, PWS_Name, ORD_SAB) %>%
    st_make_valid()

# QA / check geom types ----
geom_types <- unique(st_geometry_type(CWS_SAB))

# Halt execution if there is more than one unique geometry type or the geometry type is neither POLYGON or MULTIPOLYGON
if (length(geom_types) > 1 | (geom_types != "POLYGON" & geom_types != "MULTIPOLYGON")) {
  stop(paste(
    "Execution stopped: CWS_SAB contains multiple geometry types:", 
    paste(geom_types, collapse = ", ")
  ))
}

# Export ----
saveRDS(CWS_SAB, here("R/CWS_Analysis/01_Import_Data/SABs/Temp_Outputs/CWS_SAB.rds"))