library(vroom)
library(here)
library(zoo)
library(dplyr)

# Import data ----

## Import active NPDES Facilities ----
NPDES_ACTIVE <- vroom(here("Input_Data/NPDES/ECHO_ACTIVE_POTW.csv")) %>%
  rename(NPDES_ID = EXTERNAL_PERMIT_NMBR) %>%
  select(
    "NPDES_ID",
    "FACILITY_TYPE_INDICATOR",
    "PERMIT_TYPE_CODE",
    "MAJOR_MINOR_STATUS_FLAG",
    "STATE_WATER_BODY",
    "STATE_WATER_BODY_NAME",
    "PERMIT_NAME",
    "AGENCY_TYPE_CODE",
    "RAD_WBD_HUC12S",
    "TOTAL_DESIGN_FLOW_NMBR",
    "ACTUAL_AVERAGE_FLOW_NMBR"
  )
  
ECHO_FACILITY_DETAIL <- vroom(here("Input_Data/ECHO/ECHO_FAC_DETAILS_POTW.csv")) 
ECHO_FACILITY_DETAIL$REGISTRY_ID <- format(ECHO_FACILITY_DETAIL$REGISTRY_ID, scientific = FALSE) # Remove scientific notation

## Import all enforcement and compliance data ----

# Create list of enforcement and compliance related .csv files that will be joined
POTW_enf_compl_dfs_directory <- here("R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data") # Define directory containing .csv filepath

POTW_enf_compl_files <- list.files(path = POTW_enf_compl_dfs_directory, pattern = "\\.csv$", full.names = TRUE) %>% # List all .csv files in the directory
append(here("Input_Data/NPDES/NPDES_LTST_COMPL_STATUS.csv")) %>%
  append(here("Input_Data/NPDES/NPDES_FACILITY_INFO.csv")) %>%
  append(here("Input_Data/NPDES/POTWS_WITH_SNC.CSV")) %>%
  print(.) # Print the list of files to the console

# Check if any CSV files are found
if (length(POTW_enf_compl_files) == 0) {
  stop("No CSV files found in the directory: ", POTW_enf_compl_dfs_directory)
}

# Join all CSV files into a single data frame ----------------
# Function to read a CSV file
read_csv_file <- function(POTW_enf_compl_dfs_directory) {
  vroom(POTW_enf_compl_dfs_directory, delim = ",")
}

# Read all CSV files into a list of data frames
enf_compl_df <- lapply(POTW_enf_compl_files, read_csv_file)

# Function to perform a left join on two data frames using "NPDES_ID"
left_join_by_npdesid <- function(x, y) {
  left_join(x, y, by = "NPDES_ID")
}

# Perform left joins iteratively on all data frames
NPDES_merged_enf_compl_df <- Reduce(left_join_by_npdesid, enf_compl_df, init = NPDES_ACTIVE) 

# Join with ECHO Facility Attributes
# Remove NA values
ECHO_FACILITY_DETAIL <- ECHO_FACILITY_DETAIL %>%
  filter(!is.na(REGISTRY_ID))

NPDES_CONSOLIDATED_ENF_COMPL <- merge(NPDES_merged_enf_compl_df, ECHO_FACILITY_DETAIL,  by.x = "FACILITY_UIN",
                            by.y = "REGISTRY_ID", all.x = TRUE)

# Check columns -----------------
# Function to check for ".x" or ".y" in column names
check_column_names <- function(df) {
  if (any(grepl("\\.x$|\\.y$", names(df)))) {
    stop("Column names contain '.x' or '.y' suffixes. Please resolve these before proceeding.")
  }
}

check_column_names(NPDES_CONSOLIDATED_ENF_COMPL)

# Export --------------------
vroom_write(NPDES_CONSOLIDATED_ENF_COMPL, here("R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/NPDES_CONSOLIDATED_ENF_COMPL.csv"), delim = ",")
