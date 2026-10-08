# This script joins all enforcement and compliance outputs

rm(list = ls()) # Clear environment

library(vroom)
library(here)
library(zoo)
library(dplyr)
options(scipen = 999)

# Load environment variables for current FYQTR and CPBD ----
#source(here("R/CWS_Analysis/00_config.R"))

# Import data ----
## Import all active CWS file ----
CWS_ACTIVE <- #vroom(here("Input_Data/SDWIS/SDWIS_CWS_ACTIVE_ATTRIBUTES.csv")) %>%
  readRDS(here("R/CWS_Analysis/01_Import_Data/SDWIS/Temp_Outputs/SDWIS_CWS_ACTIVE_ATTRIBUTES.rds")) %>%
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

## Import all enforcement and compliance data ----

# Create list of enforcement and compliance related .csv files that will be joined
enf_compl_dfs_directory <- #here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data") 
  here("R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs")# Define directory containing .rds filepath

# enf_compl_files <- list.files(path = enf_compl_dfs_directory, pattern = "\\.csv$", full.names = TRUE) %>%
#   append(here("Input_Data/ECHO/ECHO_FAC_DETAILS_PWS.csv")) %>% # List all .csv files in the directory
#   print(.) # Print the list of files to the console

enf_compl_files <- list.files(path = enf_compl_dfs_directory, pattern = "\\.rds$", full.names = TRUE) %>%
  append(here("R/CWS_Analysis/01_Import_Data/ECHO/Temp_Outputs/ECHO_FAC_DETAILS_PWS.rds")) %>% # List all .rds files in the directory
  print(.) # Print the list of files to the console

# Check if any CSV files are found
if (length(enf_compl_files) == 0) {
  stop("No .rds files found in the directory: ", enf_compl_dfs_directory)
}

# Join all RDS files into a single data frame ----
# Function to read a .rds file
read_rds_file <- function(enf_compl_dfs_directory) {
  #vroom(enf_compl_dfs_directory, delim = ",")
  readRDS(enf_compl_dfs_directory)
}

# Read all Rds files into a list of data frames
enf_compl_df <- lapply(enf_compl_files, read_rds_file)

# Remove dfs to exclude from join
enf_compl_df[[14]] <- NULL # Remove this df as it is was an input to generate other violation dfs: C:/Users/CNEELY01/OneDrive - Environmental Protection Agency (EPA)/Documents/GitHub/Water-Infrastructure-and-Capacity-Assessment-Tool/R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs/VIOLATIONS_LESS_THAN_5YRS_CPBD.rds

#Function to perform a left join on two data frames using "PWSID"
left_join_by_pwsid <- function(x, y) {
  left_join(x, y, by = "PWSID")
}

# Perform left joins iteratively on all data frames
merged_enf_compl_df <- Reduce(left_join_by_pwsid, enf_compl_df, init = CWS_ACTIVE) 

merged_enf_compl_df <- merged_enf_compl_df %>%
  mutate(REGISTRY_ID = as.character(merged_enf_compl_df$REGISTRY_ID))

# Check columns ----
# Function to check for ".x" or ".y" in column names
check_column_names <- function(df) {
  if (any(grepl("\\.x$|\\.y$", names(df)))) {
    stop("Column names contain '.x' or '.y' suffixes. Please resolve these before proceeding.")
  }
}

check_column_names(merged_enf_compl_df)

# Calculate Sanitary Survey Overdue ----

# Sanitary surveys are overdue based one of the below 3 conditions
# merged_enf_compl_df <- merged_enf_compl_df %>%
#   mutate(SS_SURVEY_OVERDUE = "") %>% # Initialize SS_SURVEY_OVERDUE with "" %>%
#   mutate(SS_VISIT_FYQTR = as.yearqtr(SS_VISIT_FYQTR)) %>% # Ensure SS_VISIT_FYQTR is numeric
#   mutate(
#     SS_SURVEY_OVERDUE = case_when(
#       # Condition 1: A survey is overdue if there is no date entered for the most recent SS 
#       is.na(VISIT_DATE) ~ "Y",
#       
#       # Condition 2: A survey is overdue if it has been 5-yrs since the last SS for GW systems with greater than 4Log TT OR any outstanding performer
#       ((SOURCE_WATER_TYPE == "Groundwater" & TT_4Log == "Y") | OUTSTANDING_PERFORMER == "Y") & j > SS_VISIT_FYQTR + 5 ~ "Y",
#       
#       # Condition 3: A survey is overdue for all other systems, if it has been more than 3-years since the last survey.
#       j > (SS_VISIT_FYQTR + 3) ~ "Y",
#       
#       # If none of the conditions are true
#       TRUE ~ "N"
#     )
#   )

# Export ----
# write.csv(merged_enf_compl_df, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/merged_enf_compl_df.csv"), row.names = FALSE)

saveRDS(merged_enf_compl_df, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/Temp_Outputs/merged_enf_compl_df.rds"))
