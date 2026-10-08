# This script joins all POTW x Block Group Crosswalks 

rm(list = ls()) # Clear environment

library(dplyr)
library(vroom)
library(here)
library(tidyr)
library(stringr)

# Import and join the 1, 3, 5mi buffer crosswalks ----

# Create list of crosswalk files that will be joined
POTW_Crswlks_directory <- here("R/Wastewater_Analysis/POTW_Blk_Crswlk/Final_Crsswlk_Outputs")

POTW_Crswlks_files <- list.files(
  path = POTW_Crswlks_directory,
  pattern = "\\.csv$",
  full.names = TRUE
) 

# Check if any RDS files are found
if (length(POTW_Crswlks_files) != 168) {
  stop("Unexpected number of files in the directory: ", POTW_Crswlks_directory)
}

# Join all RDS files into a single data frame ----
# Function to read a RDS file
read_csv_file <- function(POTW_Crswlks_directory) {
  vroom(POTW_Crswlks_directory, delim = ",")
}

# Read all RDS files into a list of data frames ----
POTW_Crswlks_combined <- lapply(POTW_Crswlks_files, read_csv_file)

# Select columns ----

keep_cols = c("GEOID20","STATEFP20","block_area_m2","NPDES_ID","BUFF_DIST","buffer_dist","overlap_m2","decimal_overlap","percent_overlap")

subset_list <- lapply(POTW_Crswlks_combined, function(df) {
  # Intersection ensures it won't crash if a data frame is missing a column
  valid_cols <- intersect(keep_cols, colnames(df))
  df[, valid_cols, drop = FALSE]
})

# Join list items ----
POTW_Crswlks_df <- do.call(rbind, subset_list)

# Export ----
saveRDS(POTW_Crswlks_df,here("~/GitHub/Water-Infrastructure-and-Capacity-Assessment-Tool/R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/POTW_Crswlks_df.rds"))
