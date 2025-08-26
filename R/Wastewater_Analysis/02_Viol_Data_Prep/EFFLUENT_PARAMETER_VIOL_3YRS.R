library(vroom)
library(dplyr)
library(here)

# This script identifies all effluent parameters associated with effluent violations in the last 12 qtrs. 

# Import data ----
EFF_VIOL <- vroom(here("Input_Data/NPDES/NPDES_E90_EFFLUENT_VIOLATIONS.csv"))
EFF_PARAM <- vroom(here("Input_Data/NPDES/effluent_crosswalk.csv"))

# Add a column to categorize/group effluent parameters into a effluent violation category
EFF_VIOL_WITH_PARAM <-
  merge(
    EFF_VIOL,
    EFF_PARAM[, c("PARAMETER_CODE", "POLLUTANT_CATEGORY")],
    by = "PARAMETER_CODE",
    all.x = TRUE
  ) %>% 
  mutate(POLLUTANT_CATEGORY = ifelse(is.na(POLLUTANT_CATEGORY), "OTHER", POLLUTANT_CATEGORY))

# Count the number of quarters with at least 1 effluent violation and the corresponding parameters violated in the last 12 qtrs
E90_Violations_Param_12Qtrs <-
  EFF_VIOL_WITH_PARAM  %>%
  group_by(NPDES_ID, FYQTR) %>% # Group data by NPDES_ID and FYQTR
  summarise(
    EFF_PARAMETER_VIOLATIONS_3YR = paste0(PARAMETER_DESC, collapse = " | "),
    EFF_PARAM_CATEGORIES_3YR = paste0(POLLUTANT_CATEGORY, collapse = " | ")
  ) %>% # Group pollutant categories and descriptions into a single cell
  group_by(NPDES_ID) %>% # Group again, just by NPDES ID
  summarise(
    EFF_VIOLATIONS_3YR_COUNT = n(),
    EFF_PARAMETER_VIOLATIONS_3YR = paste0(EFF_PARAMETER_VIOLATIONS_3YR, collapse = " | "),
    EFF_PARAM_CATEGORIES_3YR = paste0(EFF_PARAM_CATEGORIES_3YR, collapse = " | ")
  ) %>% # Count number of Qtrs and paste all HB Rules violated across all quarters into one cell.
  ungroup()

# Function to remove duplicates produced by the above code
remove_duplicates_within_cell <- function(cell) {
  elements <- unlist(strsplit(cell, " \\| "))
  unique_elements <- unique(elements)
  sorted_unique <- sort(unique_elements)
  return(paste(sorted_unique, collapse = " | "))
}

# Run function
E90_Violations_Param_12Qtrs$EFF_PARAMETER_VIOLATIONS_3YR <-
  sapply(
    E90_Violations_Param_12Qtrs$EFF_PARAMETER_VIOLATIONS_3YR,
    remove_duplicates_within_cell
  )

E90_Violations_Param_12Qtrs$EFF_PARAM_CATEGORIES_3YR <-
  sapply(
    E90_Violations_Param_12Qtrs$EFF_PARAM_CATEGORIES_3YR,
    remove_duplicates_within_cell
  )

# View data
summary(E90_Violations_Param_12Qtrs$EFF_VIOLATIONS_3YR_COUNT)
hist(E90_Violations_Param_12Qtrs$EFF_VIOLATIONS_3YR_COUNT)

# Export
vroom_write(
  E90_Violations_Param_12Qtrs,
  here(
    "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/E90_Violations_Param_12Qtrs.csv"
  ), delim = ","
)