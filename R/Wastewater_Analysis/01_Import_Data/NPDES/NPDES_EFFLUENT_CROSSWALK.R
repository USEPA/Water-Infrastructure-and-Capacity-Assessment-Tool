library(vroom)
library(dplyr)
library(here)
# This script imports an effluent parameter crosswalk table from the EPA ECHO website: https://echo.epa.gov/trends/loading-tool/resources#pollutant
# NPDES DMR Parameters
# Select a link to download the parameter and pollutant category lists. The files are refreshed weekly.
# NPDES DMR Parameter to Pollutant Category Crosswalk (CSV) (640 K) - List of DMR parameters from ICIS-NPDES and associated pollutant categories are designated by "Y" flag. This crosswalk is used by the ECHO Wastewater Facility Search and DMR Exceedances Search.

# Import Effluent Parameter Crosswalk ----
effluent_crosswalk <- 
  vroom(here("R/Wastewater_Analysis/01_Import_Data/NPDES/REF_POLLUTANT_PARAMETER.csv")) 

# Function to replace "Y" values with the column header
replace_y_with_column_header <- function(df) {
  for (col in names(df)) {
    df[[col]][df[[col]] == "Y"] <- col
  }
  return(df)
}

# Apply function
effluent_crosswalk_prepped <-
  replace_y_with_column_header(effluent_crosswalk)

# Remove underscores
effluent_crosswalk_prepped <-
  data.frame(lapply(effluent_crosswalk_prepped, function (x)
    gsub("_", " ", x)))


# Function to concatenate values from specified fields
concatenate_fields <- function(df, fields) {
  df %>%
    rowwise() %>%
    mutate(Concatenated = {
      # Extract the values from the specified fields
      values <- c_across(all_of(fields))
      
      # Remove NAs and blanks, and keep only unique values
      unique_values <- unique(na.omit(values[values != ""]))
      
      # Concatenate the unique values with "|"
      paste(unique_values, collapse = "|")
    }) %>%
    ungroup()
}

# Apply the function to concatenate fields
columns_to_group <-
  c(
    "NITROGEN",
    "PHOSPHORUS",
    "ORGANIC_ENRICHMENT",
    "SOLIDS" ,
    "PATHOGEN_INDICATORS",
    "METALS",
    "TEMPERATURE",
    "WASTEWATER_FLOW",
    "COLOR",
    "RADIONUCLIDES",
    "WHOLE_EFFLUENT_TOXICITY",
    "PFAS"
  )

# Apply function
effluent_crosswalk_transformed <- concatenate_fields(effluent_crosswalk_prepped, columns_to_group) %>%
  select(PARAMETER_CODE, POLLUTANT_CATEGORY = Concatenated) %>%
  filter(POLLUTANT_CATEGORY != "")

# Export ----
write.csv(effluent_crosswalk_transformed, here("Input_Data/NPDES/effluent_crosswalk.csv"), row.names = FALSE)
