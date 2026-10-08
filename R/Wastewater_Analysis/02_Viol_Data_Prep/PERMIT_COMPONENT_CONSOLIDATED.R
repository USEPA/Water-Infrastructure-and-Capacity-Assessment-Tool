# This script consolidates permit component types by NPDES ID

rm(list = ls()) # Clear environment

library(vroom)
library(dplyr)
library(here)

# Import data ----
NPDES_PERMIT_COMP <- #vroom(here("Input_Data/NPDES/NPDES_PERMIT_COMPONENTS.csv"))
  readRDS(here("R/Wastewater_Analysis/01_Import_Data/NPDES/Temp_Outputs/NPDES_PERMIT_COMPONENTS.rds"))

# Count the number of quarters with at least 1 effluent violation and the corresponding parameters violated in the last 12 qtrs
NPDES_PERMIT_COMP_CONSOLIDATED <-
  NPDES_PERMIT_COMP  %>%
  group_by(NPDES_ID) %>% # Group data by NPDES_ID
  summarise(PERM_COMPONENT_TYPES = paste0(COMPONENT_TYPE_DESC, collapse = ", ")) %>% # Group permit component types into a single cell
  ungroup()

# Export
# vroom_write(
#   NPDES_PERMIT_COMP_CONSOLIDATED,
#   here(
#     "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/NPDES_PERMIT_COMP_CONSOLIDATED.csv"
#   ), delim = ","
# )

saveRDS(NPDES_PERMIT_COMP_CONSOLIDATED,here("R/Wastewater_Analysis/02_Viol_Data_Prep/Temp_Outputs/NPDES_PERMIT_COMP_CONSOLIDATED.rds"))
