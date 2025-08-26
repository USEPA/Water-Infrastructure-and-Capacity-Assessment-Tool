library(here)
library(sf)
library(dplyr)

# Import SAB dataset ------------------
CWS_SAB <- st_read(here("R/01_Import_Data/SABS/Water_System_Boundaries/Final.shp")) %>%
  mutate(ORD_SAB = "Y") %>%
  dplyr::select(PWSID, PWS_Name, ORD_SAB)

# Export ------------------
st_write(CWS_SAB, here("Input_Data/Locational/SAB", "CWS_SAB.shp"), row.names = FALSE)
