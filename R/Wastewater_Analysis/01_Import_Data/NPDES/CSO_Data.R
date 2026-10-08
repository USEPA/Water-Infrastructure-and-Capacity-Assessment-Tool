# This script imports data from ECHO Data Downloads and counts the number of CSO outfalls per POTW.

# Clear all objects from the global environment
rm(list = ls())

library(vroom)
library(here)
library(dplyr)
library(arcgis)
library(sf)

# Import data ----
# Import CSO data from the online feature service (ref: https://echo.epa.gov/tools/map-service)
furl <- "https://services.arcgis.com/cJ9YHowT8TU7DUyn/arcgis/rest/services/Combined_Sewer_Overflows/FeatureServer/0"

flayer <- arc_open(furl)

CSO_Data <- arc_select(flayer) %>%
  st_drop_geometry()

# CSO_Data <-
#   vroom(here("R/Wastewater_Analysis/01_Import_Data/NPDES/ALL_CSO_downloads/ALL_CSO_DOWNLOADS.csv"))

# Formatting ----

# Count Number of CSO Outfalls per POTW
COUNT_OF_CSOS_BY_POTW <-
  CSO_Data %>%
  #group_by(NPDES_ID) %>%
  group_by(npdes_id) %>%
  reframe(COUNT_OF_CSO_OUTFALLS = n()) %>%
  rename(NPDES_ID = npdes_id)

# Export ---- 
# write.csv(COUNT_OF_CSOS_BY_POTW,
#           here("Input_Data/ECHO/CSO_COUNT_BY_POTW.csv"),
#           row.names = FALSE)

saveRDS(COUNT_OF_CSOS_BY_POTW,here("R/Wastewater_Analysis/01_Import_Data/NPDES/Temp_Outputs/CSO_COUNT_BY_POTW.rds"))
