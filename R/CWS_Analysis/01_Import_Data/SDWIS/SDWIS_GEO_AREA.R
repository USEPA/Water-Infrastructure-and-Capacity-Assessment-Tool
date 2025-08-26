library(here)
library(vroom)
library(dplyr)
library(RODBC)

#Read in geographic area service area dataset from SDWIS

# Create a connection to SDWIS -------------------------
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

SDWIS_GEOGRAPHIC_AREA <- sqlQuery(
  channel_SDWIS,
  "SELECT *
  FROM LTST_GEOGRAPHIC_AREA
  WHERE PWS_TYPE_CODE = 'CWS'
  AND PWS_ACTIVITY_CODE = 'A'
"
) 

# Export  ---------------------------
write.csv(SDWIS_GEOGRAPHIC_AREA, here("Input_Data/SDWIS/SDWIS_GEOGRAPHIC_AREA.csv"), row.names = FALSE)

