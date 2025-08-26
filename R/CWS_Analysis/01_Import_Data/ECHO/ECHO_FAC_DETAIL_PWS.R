library(here)
library(RODBC)
library(dplyr)

# This script is used download ECHO Facility Details data

# Create a connection to ECHO -------------------------
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

channel_ECHO <- odbcConnect(db, uid, pwd)

# Set-up Query -------------------------

ECHO_FAC_DETAILS_QUERY <- paste(
  "SELECT *
  FROM ECHO_DFR.SDWIS_SYSTEMS_PLUS
  WHERE
   PWS_TYPE_CODE = 'CWS'
    AND PWS_ACTIVITY_CODE = 'A'"
)

# Run query ---------------------------
ECHO_FAC_DETAILS <- sqlQuery(channel_ECHO, ECHO_FAC_DETAILS_QUERY) %>%
  dplyr::select(.,PWSID,DFR_URL,REGISTRY_ID) %>%
  mutate(REGISTRY_ID = as.character(REGISTRY_ID))

# Export  ---------------------------
write.csv(ECHO_FAC_DETAILS, here("Input_Data/ECHO", "ECHO_FAC_DETAILS_PWS.csv"), row.names = FALSE)

