library(vroom)
library(here)
library(dplyr)

# This script preps POTW 5-buffer area-census block crosswalk tables. The crosswalk tables were created in ArcGIS.

# Import Data ----
# 5-mi Buffer 
POTW_Blk_Crosswalk_5mi_Buffer <-
  vroom(here("Input_Data/Census/POTW-Crosswalk/POTW_Blk_5mi_Interesct_SqKm_ExportTable_Feb252025.csv")
  ) %>%
  dplyr::select(
    .,
    c(
      #"OBJECTID",
      "NPDES_ID",
      "STATE_CODE",
      "BUFF_DIST",
      "GEOID",
      "P0010001",
      "Blk_Area_sqkm",
      "Census_Blk_Area_Intersect"
    )) %>%
  dplyr::rename(
    #"Buffer_Distance_5mi" = "BUFF_DIST",
    "blk_fips" = "GEOID",
    "Area_Overlap_5mi_Buffer_SqKm" = "Census_Blk_Area_Intersect"
  ) %>%
  mutate(
    "Buffer_Area_5mi_km" = 50.854297626978 #Area of a circle w/ a 5mi diameter (units in km2)
  ) 

# Export ----
# 5mi Buffer
vroom_write(
  POTW_Blk_Crosswalk_5mi_Buffer,
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_5mi_Buffer_OUT.csv"
  ),
  delim = ","
)