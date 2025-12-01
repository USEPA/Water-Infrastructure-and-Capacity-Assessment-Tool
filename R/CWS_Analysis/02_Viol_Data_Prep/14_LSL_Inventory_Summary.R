library(here)
library(dplyr)
library(vroom)

# This script modified column names from the lead service line inventory data frame

# Import and format data
LSLI_Base <- vroom(here("Input_Data/SDWIS/SDWIS_service_line_inventory_2025Q3.csv")) %>%
  rename(
    "PWSID" = "PWS ID",
    "GRR_Cnt" = '# Galvanized Requiring Replacement Service Lines',
    "LSL_Cnt" = '# Lead Service Lines'  ,
    "Unknown_Cnt" = '# Lead Status Unknown Service Lines' ,
    "Non_Lead_Cnt" = '# Non-lead Service Lines'  ,
    "Tot_SL" = 'Total # Service Lines Reported' ,
    "SL_Rpt_Status"  = 'Service Line Report Status'
  ) %>%
  select(
    "PWSID",
    "GRR_Cnt",
    "LSL_Cnt",
    "Unknown_Cnt",
    "Non_Lead_Cnt",
    "Tot_SL",
    "SL_Rpt_Status"
  )

# Calculate new columns ----
LSLI_New_Cols <- LSLI_Base %>%
  mutate(
    case_when(
      
    ))

  mvsli.NUM_LEAD_SERVICE_LINES IS NOT NULL
  AND mvsli.NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL IS NOT NULL
  AND mvsli.NUM_LEAD_STATUS_UNKNOWN_SL IS NOT NULL
  AND mvsli.PWS_TYPE_CODE <> 'TNCWS'
)
THEN 'Reported all required service line types'

WHEN (
  (mvsli.NUM_LEAD_SERVICE_LINES IS NULL
   OR mvsli.NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL IS NULL
   OR mvsli.NUM_LEAD_STATUS_UNKNOWN_SL IS NULL)
  AND mvsli.PWS_TYPE_CODE <> 'TNCWS'
)
AND NOT (
  mvsli.NUM_LEAD_SERVICE_LINES IS NULL
  AND mvsli.NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL IS NULL
  AND mvsli.NUM_LEAD_STATUS_UNKNOWN_SL IS NULL
)
THEN 'Reported some but not all service line types'

WHEN (
  mvsli.NUM_LEAD_SERVICE_LINES IS NULL
  AND mvsli.NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL IS NULL
  AND mvsli.NUM_LEAD_STATUS_UNKNOWN_SL IS NULL
  AND mvsli.PWS_TYPE_CODE <> 'TNCWS'
)
THEN 'Did not report any required service line types'

ELSE 'System is not required to report'
END AS SERVICE_LINE_REPORT_STATUS

# Export data
write.csv(LSLI_Base, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/LSLI_Data.csv"), row.names = FALSE)
