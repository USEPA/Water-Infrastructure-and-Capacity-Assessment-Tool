library(arcgis)
library(sf)

# Import Data ---------------
## Off Reservation Trust Area  ---------------
furl.OffRes <- "https://geopub.epa.gov/arcgis/rest/services/EMEF/Tribal/MapServer/3"

# Save URL as feature layer object (contains layer metadata)
flayer.OffRes <- arc_open(furl.OffRes)

# Create a point layer from the feature layer object, using the centroid of the area
Off_Res_LT_point <- arc_select(flayer.OffRes) %>%
  st_point_on_surface(.) 

## Reservations  ---------------
furl.AIAN <- "https://geopub.epa.gov/arcgis/rest/services/EMEF/Tribal/MapServer/2"

# Save URL as feature layer object (contains layer metadata)
flayer.AIAN <- arc_open(furl.AIAN)

# Create a point layer from the feature layer object, using the centroid of the area
AI_AN_Res_point <- arc_select(flayer.AIAN) %>%
  st_point_on_surface(.) 

# Export Data ---------------
## Off Reservation Trust Area  ---------------
st_write(Off_Res_LT_point, here("Input_Data/Locational/Tribe/Off_Reservation_Tribal_Areas.gdb"), append = FALSE)

## Reservation  ---------------
st_write(AI_AN_Res_point, here("Input_Data/Locational/Tribe/Reservation_Tribal_Areas.gdb"), append = FALSE)