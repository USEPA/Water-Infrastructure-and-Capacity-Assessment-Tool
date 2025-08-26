library(vroom)
library(here)
library(dplyr)

# This script preps POTW 1-buffer area-census block crosswalk tables. The crosswalk tables were created in ArcGIS.

# Import Data ----

## 1-mi Buffer ----
POTW_Blk_Crosswalk_1mi_Buffer <- vroom(here("Input_Data/Census/POTW-Crosswalk/POTW_Blk_1mi_Interesct_SqKm_ExportTable_Feb252025.csv")
) %>%
  dplyr::select(
    .,
    c(
      "NPDES_ID",
      "STATE_CODE",
      "BUFF_DIST",
      "GEOID",
      "P0010001",
      "Blk_Area_sqkm",
      "Blk_Area_POTW1mi_Ratio" #Area Overlap in SqKm
    )
  ) %>%
  dplyr::rename("Area_Overlap_1mi_Buffer_SqKm" = "Blk_Area_POTW1mi_Ratio",
                "blk_fips" = "GEOID") %>%
  mutate("Buffer_Area_1mi_km" = 2.03417 #Area of a circle w/ a 1mi diameter (units in km2)
  )

# Export ----
# 1mi Buffer
vroom_write(
  POTW_Blk_Crosswalk_1mi_Buffer,
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_1mi_Buffer_OUT.csv"
  ),
  delim = ","
)
