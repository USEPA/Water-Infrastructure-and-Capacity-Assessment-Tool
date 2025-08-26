library(vroom)
library(dplyr)
library(here)

# This script identifies all effluent parameters associated with effluent violations in the current quarter. 

# Import data ----
FYQTR_NDPES <- Sys.getenv("npdes_set_fyqtr")
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

# Count the number of effluent violations in the current quarter and the corresponding parameters violated in the last 12 qtrs
EFF_VIOL_WITH_PARAM_Q12 <-
  EFF_VIOL_WITH_PARAM  %>%
  filter(FYQTR == FYQTR_NDPES) %>% 
  group_by(NPDES_ID) %>%
  summarise(
    EFF_PARAMETER_VIOLATIONS_Q12 = paste0(PARAMETER_DESC, collapse = " | "),
    EFF_PARAM_CATEGORIES_Q12 = paste0(POLLUTANT_CATEGORY, collapse = " | "),
    EFF_VIOLATIONS_COUNT = n()
  ) %>%
  ungroup()

# Function to remove duplicates produced by the above code
remove_duplicates_within_cell <- function(cell) {
  elements <- unlist(strsplit(cell, " \\| "))
  unique_elements <- unique(elements)
  sorted_unique <- sort(unique_elements)
  return(paste(sorted_unique, collapse = " | "))
}

# Run function
EFF_VIOL_WITH_PARAM_Q12$EFF_PARAMETER_VIOLATIONS_Q12 <-
  sapply(
    EFF_VIOL_WITH_PARAM_Q12$EFF_PARAMETER_VIOLATIONS_Q12,
    remove_duplicates_within_cell
  )

#Run function to remove duplicates in the EFF_PARAM_CATEGORIES_Q12 field
EFF_VIOL_WITH_PARAM_Q12$EFF_PARAM_CATEGORIES_Q12 <-
  sapply(
    EFF_VIOL_WITH_PARAM_Q12$EFF_PARAM_CATEGORIES_Q12,
    remove_duplicates_within_cell
  )

summary(EFF_VIOL_WITH_PARAM_Q12$EFF_VIOLATIONS_COUNT)
hist(EFF_VIOL_WITH_PARAM_Q12$EFF_VIOLATIONS_COUNT)

# Export
vroom_write(
  EFF_VIOL_WITH_PARAM_Q12,
  here(
    "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/EFF_VIOL_WITH_PARAM_Q12.csv"
  ), delim = ","
)
