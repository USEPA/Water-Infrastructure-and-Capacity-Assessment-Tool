library(here)
library(RODBC)
library(dplyr)

# This script is used download Enforcement Priority Data from ECHO

# Create a connection to ECHO -------------------------
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

channel_ECHO <- odbcConnect(db, uid, pwd)

# Set-up Query -------------------------

enforcement_priority_query <- paste(
  "SELECT *
  FROM ECHO_DFR.SDWIS_SYSTEMS
  WHERE
   CURR_SNC  = 'Enforcement Priority' AND
     PWS_TYPE_CODE = 'CWS' AND
     PWS_ACTIVITY_CODE = 'A'
  "
)

# Run query ---------------------------
SDWIS_ENF_PRIORITY <- sqlQuery(channel_ECHO,enforcement_priority_query)

# Export  ---------------------------
write.csv(SDWIS_ENF_PRIORITY, here("Input_Data/ECHO", "SDWIS_ENF_PRIORITY.csv"), row.names = FALSE)