library(here)
# This shell script executes all R scripts in the CWS_Analysis directory.

# Step 1 Import all drinking water data -----------

# Step 2 Prepare and analyze the data -----------

# Define the directory containing the R scripts
DW_script_directory <- here("R/CWS_Analysis/02_Viol_Data_Prep")

# List all R script files in the directory
DW_script_files <- list.files(path = DW_script_directory, pattern = "\\.R$", full.names = TRUE)

# Check if any scripts are found
if (length(DW_script_files) == 0) {
  stop("No R script files found in the directory: ", DW_script_directory)
}

# Check if any scripts are found
if (length(DW_script_files) == 0) {
  stop("No R script files found in the directory: ", DW_script_directory)
}

# Source each script file and stop execution if an error occurs
for (script in DW_script_files) {
  message("Running script: ", script)
  
  # Snapshot of the environment before sourcing the script
  before_vars <- ls()
  
  # Use tryCatch to handle any errors within the script
  tryCatch({
    source(script)
  }, error = function(e) {
    stop("Error in script: ", script, " - ", e$message)
  })
  
  # Snapshot of the environment after sourcing the script
  after_vars <- ls()
  
  # Identify new variables created by the script
  new_vars <- setdiff(after_vars, before_vars)
  
  # Remove only the new variables
  rm(list = new_vars)
  message("New variables cleared after executing: ", script)
}

message("All scripts have been executed.")

# Step 3 Join enforcement and compliance Data into a single dataframe ------------

