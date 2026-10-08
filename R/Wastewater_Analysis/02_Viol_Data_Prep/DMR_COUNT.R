# This script counts the number of quarters (in the last 12) with at least 1 DMR Violation

# Clear all objects from the global environment
rm(list = ls())

library(vroom)
library(dplyr)
library(here)

# Import data ----
DMR_NPDES <- #vroom(here("Input_Data/NPDES/NPDES_VIOL_D80D90_DMR.csv")) 
  readRDS(here("R/Wastewater_Analysis/01_Import_Data/NPDES/Temp_Outputs/NPDES_VIOL_D80D90_DMR.rds"))

# Run analysis ----
DMR_COUNT_3YRS <-
  DMR_NPDES %>%
  group_by(NPDES_ID) %>%
  distinct(NPDES_ID, FYQTR, .keep_all = TRUE) %>%
  summarise(DMR_3YRS_COUNT = n())

# View data ----
hist(DMR_COUNT_3YRS$DMR_3YRS_COUNT)

# Export ----
# vroom_write(
#   DMR_COUNT_3YRS,
#   here(
#     "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/DMR_COUNT_3YRS.csv"
#   ), delim = ","
# )

saveRDS(DMR_COUNT_3YRS,here("R/Wastewater_Analysis/02_Viol_Data_Prep/Temp_Outputs/DMR_COUNT_3YRS.rds"))

