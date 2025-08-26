library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)
library(vroom)

# This script is used to import the base universe of POTWs, importing all active POTWs

# Create a connection to ECHO -------------------------
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

channel_ECHO <- odbcConnect(db, uid, pwd)

# Set up query
ECHO_ACTIVE_POTW_QUERY <- paste(
  "SELECT *
  FROM ECHO_DFR.V_ICIS_PERMITS_DL
  WHERE
   VERSION_NMBR = '0'
   AND FACILITY_TYPE_INDICATOR LIKE '%POTW%'
   AND FACILITY_TYPE_INDICATOR NOT LIKE '%NON-POTW%'
  AND (PERMIT_STATUS_CODE != 'NON' AND PERMIT_STATUS_CODE != 'TRM' AND PERMIT_STATUS_CODE != 'PND' AND PERMIT_STATUS_CODE != 'RET')"
)

# Run query
ECHO_ACTIVE_POTW <- sqlQuery(channel_ECHO, ECHO_ACTIVE_POTW_QUERY)

# Export  ---------------------------
write.csv(ECHO_ACTIVE_POTW, here("Input_Data/NPDES", "ECHO_ACTIVE_POTW.csv"), row.names = FALSE)
