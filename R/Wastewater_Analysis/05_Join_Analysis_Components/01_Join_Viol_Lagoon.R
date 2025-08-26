library(vroom)
library(here)

# This script joins violation and lagoon data

# Import data ----
# Lagoon data - ICIS Codes
lagoons_icis <- vroom(here("Input_Data/Lagoon/LAGOON_ICIS_CODE.csv")) %>%
  mutate(LAGOON_AS_PRIMARY_TREATMENT_ICIS_DATA = "Y")

# Lagoon data - Universe of Lagoons Report
lagoon_universe_of_lagoons <- vroom(here("Input_Data/Lagoon/LAGOON_UNIV_OF_LAGOONS.csv")) %>%
  mutate(LAGOON_AS_PRIMARY_TREATMENT_UofL_DATA = "Y")

# Violation data
NPDES_VIOL_DATA <- vroom(here("R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/NPDES_ENF_COMPL_FINAL_OUT.csv")) 

# Merge NPDES data with lagoon data
NPDES_VIOL_LAGOON <-
  merge(
    NPDES_VIOL_DATA,
    lagoons_icis[, c("NPDES_ID", "LAGOON_AS_PRIMARY_TREATMENT_ICIS_DATA")],
    by = "NPDES_ID",
    all.x = TRUE
  ) %>%
  merge(.,lagoon_universe_of_lagoons[, c("NPDES_ID", "LAGOON_AS_PRIMARY_TREATMENT_UofL_DATA")],
        by = "NPDES_ID",
        all.x = TRUE) 

#Add Data Source Indicator (ICIS or Universe of Lagoon)
NPDES_VIOL_LAGOON$LAGOON_AS_PRIMARY_TREATMENT <-
  ""
NPDES_VIOL_LAGOON$LAGOON_SOURCE_DATA <-
  ""

#Fill in Data Source Indicator Field
NPDES_VIOL_LAGOON <- NPDES_VIOL_LAGOON %>%
  mutate(
    LAGOON_AS_PRIMARY_TREATMENT = case_when(
      (
        LAGOON_AS_PRIMARY_TREATMENT_ICIS_DATA == "Y" |
          LAGOON_AS_PRIMARY_TREATMENT_UofL_DATA == "Y"
      )  ~ "Y",
      TRUE ~ as.character(LAGOON_AS_PRIMARY_TREATMENT)
    ),
    LAGOON_AS_PRIMARY_TREATMENT = case_when(
      (LAGOON_AS_PRIMARY_TREATMENT == "")  ~ "N",
      TRUE ~ as.character(LAGOON_AS_PRIMARY_TREATMENT)
    ),
    LAGOON_SOURCE_DATA = case_when(
      (LAGOON_AS_PRIMARY_TREATMENT_ICIS_DATA == "Y")  ~ "ICIS",
      TRUE ~ as.character(LAGOON_SOURCE_DATA)
    ),
    LAGOON_SOURCE_DATA = case_when(
      (LAGOON_SOURCE_DATA == "" & LAGOON_AS_PRIMARY_TREATMENT_UofL_DATA == "Y")  ~ "Universe of Lagoons Report",
      TRUE ~ as.character(LAGOON_SOURCE_DATA)
    )
  )

# Export ----
vroom_write(NPDES_VIOL_LAGOON, here("R/Wastewater_Analysis/05_Join_Analysis_Components/NPDES_VIOL_LAGOON.csv"), delim = ",")
