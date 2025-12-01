library(vroom)
library(here)
library(zoo)
library(dplyr)

# Import data -------------- 

options(scipen = 999)

# Load environment variables for current FYQTR and CPBD
load(here("R/CWS_Analysis/01_Import_Data/SDWIS/compliance_period_begin_date.Rdata"))

## Import all active CWS file ---------------
CWS_ACTIVE <- vroom(here("Input_Data/SDWIS/SDWIS_CWS_ACTIVE_ATTRIBUTES.csv")) %>%
  select(
    "PWS_NAME",
    "PWSID",
    "EPA_REGION",
    "PRIMACY_TYPE",
    "PRIMACY_AGENCY",
    "PWS_TYPE" ,
    "OWNER_TYPE",
    "SOURCE_WATER_TYPE",
    "OUTSTANDING_PERFORMER",
    "OUTSTANDING_PERFORM_BEGIN_DATE",
    "IS_WHOLESALER_IND",
    "IS_SCHOOL_OR_DAYCARE_IND",
    "POPULATION_SERVED_COUNT",
    "POPULATION_CATEGORY_SERVED",
    "SERVICE_CONNECTIONS_COUNT"  ,
    "SUBMISSIONYEARQUARTER"
  )

## Import all enforcement and compliance data ---------------

# Create list of enforcement and compliance related .csv files that will be joined
enf_compl_dfs_directory <- here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data") # Define directory containing .csv filepath

enf_compl_files <- list.files(path = enf_compl_dfs_directory, pattern = "\\.csv$", full.names = TRUE) %>% 
  append(here("Input_Data/ECHO/ECHO_FAC_DETAILS_PWS.csv")) %>% # List all .csv files in the directory
  print(.) # Print the list of files to the console

# Check if any CSV files are found
if (length(enf_compl_files) == 0) {
  stop("No CSV files found in the directory: ", enf_compl_dfs_directory)
}

# Join all CSV files into a single data frame ----------------
# Function to read a CSV file
read_csv_file <- function(enf_compl_dfs_directory) {
  vroom(enf_compl_dfs_directory, delim = ",")
}

# Read all CSV files into a list of data frames
enf_compl_df <- lapply(enf_compl_files, read_csv_file)

# Function to perform a left join on two data frames using "PWSID"
left_join_by_pwsid <- function(x, y) {
  left_join(x, y, by = "PWSID")
}

# Perform left joins iteratively on all data frames
merged_enf_compl_df <- Reduce(left_join_by_pwsid, enf_compl_df, init = CWS_ACTIVE) 

merged_enf_compl_df <- merged_enf_compl_df %>%
  mutate(REGISTRY_ID = as.character(merged_enf_compl_df$REGISTRY_ID))

# Check columns -----------------
# Function to check for ".x" or ".y" in column names
check_column_names <- function(df) {
  if (any(grepl("\\.x$|\\.y$", names(df)))) {
    stop("Column names contain '.x' or '.y' suffixes. Please resolve these before proceeding.")
  }
}

check_column_names(merged_enf_compl_df)

# Calculate Sanitary Survey Overdue  ----------------

# Sanitary surveys are overdue based one of the below 3 conditions
merged_enf_compl_df <- merged_enf_compl_df %>%
  mutate(SS_SURVEY_OVERDUE = "") %>% # Initialize SS_SURVEY_OVERDUE with "" %>%
  mutate(SS_VISIT_FYQTR = as.yearqtr(SS_VISIT_FYQTR)) %>% # Ensure SS_VISIT_FYQTR is numeric
  mutate(
    SS_SURVEY_OVERDUE = case_when(
      # Condition 1: A survey is overdue if there is no date entered for the most recent SS 
      is.na(VISIT_DATE) ~ "Y",
      
      # Condition 2: A survey is overdue if it has been 5-yrs since the last SS for GW systems with greater than 4Log TT OR any outstanding performer
      ((SOURCE_WATER_TYPE == "Groundwater" & TT_4Log == "Y") | OUTSTANDING_PERFORMER == "Y") & j > SS_VISIT_FYQTR + 5 ~ "Y",
      
      # Condition 3: A survey is overdue for all other systems, if it has been more than 3-years since the last survey.
      j > (SS_VISIT_FYQTR + 3) ~ "Y",
      
      # If none of the conditions are true
      TRUE ~ "N"
    )
  )

# Export --------------------
write.csv(merged_enf_compl_df, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/merged_enf_compl_df.csv"), row.names = FALSE)

# TROUBLESHOOT -----------

# # Assign names to the list elements based on the file names
# names(enf_compl_df) <- basename(enf_compl_files)
# 
# # Function to check for duplicate PWSIDs and print them
# check_for_duplicates <- function(df, df_name) {
#   # Find duplicate PWSIDs
#   dup_pwsids <- df %>%
#     group_by(PWSID) %>%
#     filter(n() > 1) %>%
#     pull(PWSID) %>%
#     unique()
#   
#   # Print the duplicates if any
#   if (length(dup_pwsids) > 0) {
#     cat("Duplicates in", df_name, ":\n")
#     print(dup_pwsids)
#   } else {
#     cat("No duplicates in", df_name, "\n")
#   }
# }
# 
# # Iterate over each data frame and check for duplicates
# for (i in seq_along(enf_compl_df)) {
#   check_for_duplicates(enf_compl_df[[i]], names(enf_compl_df)[i])
# }
