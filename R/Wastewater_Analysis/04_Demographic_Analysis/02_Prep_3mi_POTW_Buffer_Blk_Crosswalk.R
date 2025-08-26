library(vroom)
library(here)
library(dplyr)

# This script preps POTW 3-buffer area-census block crosswalk tables. The crosswalk tables were created in ArcGIS.

# Import Data ----
# 3-mi Buffer 
POTW_Blk_Crosswalk_3mi_Buffer <- vroom(here("Input_Data/Census/POTW-Crosswalk/POTW_Blk_3mi_Interesct_SqKm_ExportTable_Feb252025.csv")
) %>%
  dplyr::select(
    .,
    c(
      "NPDES_ID",
      "STATE_CODE",
      "BUFF_DIST",
      "GEOID",
      "P0010001", #Block Population
      "Blk_Area_sqkm", #Blk Area in Sq Km
      "Blk_Area_POTW_3mi_Ratio"
    )) %>%
  dplyr::rename(
    #"Buffer_Distance_3mi" = "BUFF_DIST",
    "blk_fips" = "GEOID",
    "Area_Overlap_3mi_Buffer_SqKm" ="Blk_Area_POTW_3mi_Ratio"
  ) %>%
  mutate(
    "Buffer_Area_3mi_km" = 18.307531978005 #Area of a circle w/ a 3mi diameter (units in km2)
  )

# Export ----
# 3mi Buffer
vroom_write(
  POTW_Blk_Crosswalk_3mi_Buffer,
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_3mi_Buffer_OUT.csv"
  ),
  delim = ","
)