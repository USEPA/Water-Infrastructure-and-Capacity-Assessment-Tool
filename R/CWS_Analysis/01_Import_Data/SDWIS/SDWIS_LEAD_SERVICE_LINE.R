library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)
library(vroom)
library(usethis)

# This script imports service line inventory data from SDFW.

# Create a connection to SDWIS ----
# Load compliance period begin date
load(here("R/CWS_Analysis/01_Import_Data/SDWIS/compliance_period_begin_date.Rdata"))

db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Set-up Query ----
LSL_Query <- paste0(
  "SELECT PWSID, NUM_LEAD_SERVICE_LINES, NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL, NUM_NONLEAD_SERVICE_LINES, NUM_LEAD_STATUS_UNKNOWN_SL, TOTAL_NUM_SERVICE_LINES_REPORTED, VIOLATION_2E_REPORTED, VIOLATION_4G_REPORTED
  FROM SFDW.V_LEAD_SERVICE_LINE_DQ
   WHERE
   PWS_TYPE_CODE  ='CWS' AND
     PWS_ACTIVITY_CODE = 'A' AND
   SUBMISSIONYEARQUARTER =",
  "'",
  k,
  "'"
 )

# Run query ----
V_LEAD_SERVICE_LINE_DQ <- sqlQuery(channel_SDWIS, LSL_Query)

# Export ----
write.csv(
  V_LEAD_SERVICE_LINE_DQ,
  here("Input_Data/SDWIS/SDWIS_LSL_INVENTORY.csv"),
  row.names = FALSE
)

