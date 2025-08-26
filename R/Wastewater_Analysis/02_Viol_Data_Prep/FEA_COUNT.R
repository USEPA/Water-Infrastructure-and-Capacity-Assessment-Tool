library(vroom)
library(dplyr)
library(here)

# This script counts the number of FEA by NPDES ID

# Import data ----
FEA_NPDES <- vroom(here("Input_Data/NPDES/NPDES_FORMAL_ENFORCEMENT_ACTIONS.csv"))

# Group enforcement actions by NPDES ID
FEA_COUNT_5YRS <-
  FEA_NPDES %>%
  group_by(SOURCE_ID) %>%
  reframe(FORMAL_ENF_ACT_5YR_COUNT = n()) %>%
  rename("NPDES_ID" = "SOURCE_ID")

# View data
hist(FEA_COUNT_5YRS$FORMAL_ENF_ACT_5YR_COUNT)

# Export
vroom_write(
  FEA_COUNT_5YRS,
  here(
    "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/FEA_COUNT_5YRS.csv"
  ), delim = ","
)
