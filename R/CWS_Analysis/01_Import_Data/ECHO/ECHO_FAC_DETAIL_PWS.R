library(here)
library(RODBC)
library(dplyr)

# This script is used download ECHO Facility Details data including enforcement priority status, DFR URL, Facility Registry ID (FRS ID).

# Create a connection to ECHO ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

channel_ECHO <- odbcConnect(db, uid, pwd)

# Set-up Query ----

ECHO_FAC_DETAILS_QUERY <- paste(
  "SELECT PWSID, REGISTRY_ID, SNC
  FROM ECHO_DFR.V_SDWIS_SYSTEMS_PLUS
  WHERE
   PWS_TYPE_CODE = 'CWS' AND
     PWS_ACTIVITY_CODE = 'A'"
) 

# Run query ----
ECHO_FAC_DETAILS <- sqlQuery(channel_ECHO, ECHO_FAC_DETAILS_QUERY) 

ECHO_FAC_DETAILS$DFR_URL <- paste0("	
https://echo.epa.gov/detailed-facility-report?fid=", ECHO_FAC_DETAILS$REGISTRY_ID) 

# Export ----
write.csv(ECHO_FAC_DETAILS, here("Input_Data/ECHO", "ECHO_FAC_DETAILS_PWS.csv"), row.names = FALSE)

