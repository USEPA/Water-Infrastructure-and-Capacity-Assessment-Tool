library(tigris)
library(sf)
library(dplyr)
library(purrr)
library(readr)
library(here)

options(tigris_use_cache = TRUE)

# ------------------------------------------------------------
# OUTPUT FOLDER (relative to your R project)
# ------------------------------------------------------------
out_dir <- here("R/Wastewater_Analysis/POTW_Blk_Crswlk", "blocks_2020_sf")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------
# STATES + TERRITORIES
# ------------------------------------------------------------
geo_list <- c(
  "AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
  "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
  "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
  "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
  "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI",
  "WY","AS","GU","MP","PR","VI"
)

# ------------------------------------------------------------
# FUNCTION: DOWNLOAD ONE STATE/TERRITORY AND WRITE TO GPKG
# ------------------------------------------------------------
download_blocks_to_gpkg <- function(st, out_dir) {
  message("Downloading blocks for: ", st)
  
  tryCatch({
    blk_sf <- blocks(state = st, year = 2020, class = "sf")
    
    blk_sf <- blk_sf %>%
      select(GEOID20, STATEFP20, geometry)
    
    # Optional: project to equal-area CRS if desired
    # blk_sf <- st_transform(blk_sf, 5070)
    
    #out_file <- file.path(out_dir, paste0("blocks_2020_", st, ".gpkg"))
    
    # Write to GeoPackage
    #st_write(blk_sf, out_file, delete_dsn = TRUE, quiet = TRUE)
    
    st_write(blk_sf, file.path(out_dir, paste0("blocks_2020_", st, ".shp")), delete_layer = TRUE, quiet = TRUE)
    
    #message("Saved: ", out_file)
    TRUE
  }, error = function(e) {
    message("FAILED for ", st, ": ", e$message)
    FALSE
  })
}

# ------------------------------------------------------------
# RUN ALL
# ------------------------------------------------------------
results <- map_lgl(geo_list, download_blocks_to_gpkg, out_dir = out_dir)

message("Done.")
message("Succeeded: ", sum(results))
message("Failed: ", sum(!results))