library(vroom)
library(here)
library(dplyr)

# This script joins NPDES Violation/Lagoon/CWSRF data with CSO data

# Import data
CSO_DATA <- vroom(here("Input_Data/ECHO/CSO_COUNT_BY_POTW.csv"))

NDPES_LAGOON_CWSRF <- vroom(here("R/Wastewater_Analysis/05_Join_Analysis_Components/POTW_VIOL_LAGOON_CWSRF_OUT.csv"))

# Join datasets
# Merge NPDES data with CSO data
NDPES_LAGOON_DWSRF_CSO <-
  merge(
    NDPES_LAGOON_CWSRF,
    CSO_DATA[, c("NPDES_ID", "COUNT_OF_CSO_OUTFALLS")],
    by = "NPDES_ID",
    all.x = TRUE
  )

# Add a column for presence of CSO outfalls
NDPES_LAGOON_DWSRF_CSO$COMBINED_SEWER_SYSTEM <- ""

# Populate Blanks
NDPES_LAGOON_DWSRF_CSO <-
  NDPES_LAGOON_DWSRF_CSO %>%
  mutate(
    COMBINED_SEWER_SYSTEM = case_when(
      (COUNT_OF_CSO_OUTFALLS == "" | is.na(COUNT_OF_CSO_OUTFALLS))  ~ "N",
      TRUE ~ "Y"
    )
  )

# Export ----
vroom_write(NDPES_LAGOON_DWSRF_CSO, here("R/Wastewater_Analysis/05_Join_Analysis_Components/POTW_VIOL_LAGOON_CWSRF_CSO_OUT.csv"), delim = ",")
