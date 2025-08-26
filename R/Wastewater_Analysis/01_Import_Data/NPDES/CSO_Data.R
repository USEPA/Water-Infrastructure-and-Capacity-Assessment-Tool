library(vroom)
library(here)
library(dplyr)
# This script imports data from ECHO Data Downloads and counts the number of CSO outfalls per POTW.

# Import Data ----
CSO_Data <-
  vroom(here("R/Wastewater_Analysis/01_Import_Data/NPDES/ALL_CSO_downloads/ALL_CSO_DOWNLOADS.csv"))

# Formatting ----

# Count Number of CSO Outfalls per POTW
COUNT_OF_CSOS_BY_POTW <-
  CSO_Data %>%
  group_by(NPDES_ID) %>%
  reframe(COUNT_OF_CSO_OUTFALLS = n())

# Export ---- 
write.csv(COUNT_OF_CSOS_BY_POTW,
          here("Input_Data/ECHO/CSO_COUNT_BY_POTW.csv"),
          row.names = FALSE)
