library(here)
library(dplyr)
library(vroom)

# This script modified column names from the lead service line inventory data frame

# Import and format data
LSLI_Base <- vroom(here("Input_Data/SDWIS/SDWIS_LSL_INVENTORY.csv")) %>%
  select(
    "PWSID",
    "NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL",
    "NUM_LEAD_SERVICE_LINES",
    "NUM_LEAD_STATUS_UNKNOWN_SL",
    "NUM_NONLEAD_SERVICE_LINES",
    "TOTAL_NUM_SERVICE_LINES_REPORTED"
  ) %>%
  mutate(
    SL_Rpt_Status = ""
  )

# Calculate new columns ----
LSLI_New_Cols <- LSLI_Base %>%
  mutate(
    SL_Rpt_Status =
      case_when(
        !is.na(NUM_LEAD_SERVICE_LINES) &
          !is.na(NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL) &
          !is.na(NUM_LEAD_STATUS_UNKNOWN_SL) ~ 'Reported all required service line types', TRUE ~  as.character(SL_Rpt_Status) 
      ),
    SL_Rpt_Status =
      case_when(
        is.na(NUM_LEAD_SERVICE_LINES) |
          is.na(NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL) |
          is.na(NUM_LEAD_STATUS_UNKNOWN_SL) ~ 'Reported some but not all required service line types', TRUE ~  as.character(SL_Rpt_Status) 
      ),
    SL_Rpt_Status =
      case_when(
        is.na(NUM_LEAD_SERVICE_LINES) &
          is.na(NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL) &
          is.na(NUM_LEAD_STATUS_UNKNOWN_SL) ~ 'Did not report any required service line types', TRUE ~  as.character(SL_Rpt_Status) 
      )
  )

# Export data
write.csv(LSLI_New_Cols, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/LSLI_Data.csv"), row.names = FALSE)
