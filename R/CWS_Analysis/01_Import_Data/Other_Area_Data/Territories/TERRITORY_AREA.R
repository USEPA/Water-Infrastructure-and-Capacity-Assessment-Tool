library(sf)

# Read in territories point data
Territories_point <-
  sf::st_read(here("R/CWS_Analysis/01_Import_Data/Other_Area_Data/Territories", "Territories_point.gdb"))

# Export territories point data ------------------
st_write(Territories_point, here("Input_Data/Locational/Territory", "Territories_point.gdb"), row.names = FALSE)
