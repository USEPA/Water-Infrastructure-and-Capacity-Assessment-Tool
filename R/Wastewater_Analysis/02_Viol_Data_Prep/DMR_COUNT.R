library(vroom)
library(dplyr)
library(here)

# This script counts the number of quarters (in the last 12) with at least 1 DMR Violation

# Import data
DMR_NPDES <- vroom(here("Input_Data/NPDES/NPDES_VIOL_D80D90_DMR.csv"))

# Run analysis
DMR_COUNT_3YRS <-
  DMR_NPDES %>%
  group_by(NPDES_ID) %>%
  distinct(NPDES_ID, FYQTR, .keep_all = TRUE) %>%
  summarise(DMR_3YRS_COUNT = n())

# View data
hist(DMR_COUNT_3YRS$DMR_3YRS_COUNT)

# Export
vroom_write(
  DMR_COUNT_3YRS,
  here(
    "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/DMR_COUNT_3YRS.csv"
  ), delim = ","
)