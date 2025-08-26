library(vroom)
library(dplyr)
library(here)
library(zoo)

# This script counts the number of SNCs by NPDES ID open as of the most current reporting period AND the number of quarters in the last 3-yrs with at least 1 SNC.

# Import data
SNC <- vroom(here("Input_Data/NPDES/NPDES_SE_VIOLATIONS.csv"))
# npdes_set_fyqtr <- Sys.getenv("npdes_set_fyqtr") # Import the "FY QTR" to filter data
# FY_QTR <- as.yearqtr(npdes_set_fyqtr) # Convert to a yearqtr class

# Run analysis

# Filter for all open/unresolved SE Violations - Single event end date is empty/null
# Note: If the violation does not have an end date but has a RNC resolution code, the resolution date becomes the violation end date. (source: https://echo.epa.gov/help/reports/dfr-data-dictionary)
SEV_COUNT_3YRS_OPEN <- SEV_NPDES %>%
  filter(
    .,
    is.na(SINGLE_EVENT_END_DATE) &
      (
        is.na(RNC_RESOLUTION_CODE)|
          RNC_RESOLUTION_CODE == "A" | RNC_RESOLUTION_CODE == "1"
      )
  )

# Count of Single Event Violations that have not returned to compliance
SEV_COUNT_3YRS_OPEN <- SEV_COUNT_3YRS_OPEN %>% 
  group_by(NPDES_ID) %>%
  reframe(SEV_OPEN_COUNT = n())

# Count of quarters in the last 3 years with at least 1 SEV
SEV_3YRS_COUNT <-
  SEV_NPDES %>%
  group_by(NPDES_ID) %>%
  distinct(NPDES_ID, FYQTR, .keep_all = TRUE) %>%
  summarise(SEV_3YRS_COUNT = n())

# Export

vroom_write(
  SEV_COUNT_3YRS_OPEN,
  here(
    "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/SEV_COUNT_3YRS_OPEN.csv"
  ), delim = ","
)

vroom_write(
  SEV_3YRS_COUNT,
  here(
    "R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/SEV_3YRS_COUNT.csv"
  ), delim = ","
)
