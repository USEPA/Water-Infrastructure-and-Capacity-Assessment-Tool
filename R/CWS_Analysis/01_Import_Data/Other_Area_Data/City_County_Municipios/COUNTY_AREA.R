library(arcgis)
library(sf)
library(here)

# This script imports a county shapefile that includes both US counties and PR municipios.

# Import data -----------------

# This counties layer includes US and Puerto Rico Counties 
furl.counties<- "https://services.arcgis.com/cJ9YHowT8TU7DUyn/arcgis/rest/services/counties_t/FeatureServer/0"

# Save URL as feature layer object (contains layer metadata)
flayer.counties <- arc_open(furl.counties)

# Create a sf from the feature layer object, selecting only necessary fields
Counties_point <- arc_select(flayer.counties) %>% 
  st_point_on_surface(.) 

# Export data -----------------
st_write(Counties_point, here("Input_Data/Locational/County-Municipio/Counties_point.gdb"), overwrite = TRUE)
