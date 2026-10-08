# This script converts a .csv of all active POTWs with coordinate fields to a point layer. This point layer is used to crosswalk with census blocks.

# Import data ----

potws <- read.csv(here("R/Wastewater_Analysis/POTW_Blk_Crswlk/Active_POTW_Coords_2026_08_25.csv"))

# Remove rows with empty coordinates
potws_cleaned <- potws[!is.na(potws$GEOCODE_LONGITUDE) & !is.na(potws$GEOCODE_LATITUDE), ] 

# Convert to sf ----

points_sf <- st_as_sf(potws_cleaned, coords = c("GEOCODE_LONGITUDE", "GEOCODE_LATITUDE"), crs = 4326)

# Export ----
st_write(points_sf, here("R/Wastewater_Analysis/POTW_Blk_Crswlk/Active_POTW_Coords.gdb"), driver = "OpenFileGDB")
