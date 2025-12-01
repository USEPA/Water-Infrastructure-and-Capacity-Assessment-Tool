library(here)
library(RODBC)

# Create a connection to SDWIS -------------------------
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Import data -------------------------
SDWIS_REF_CODE_QUERY <- paste(
  "SELECT *
  FROM REF_CODE_VALUE"
)

#Run query
SDWIS_REF_CODE <- sqlQuery(channel_SDWIS,SDWIS_REF_CODE_QUERY)

write.csv(SDWIS_REF_CODE, here("Input_Data/SDWIS", "SDWA_REF_CODE_VALUES.csv"), row.names = FALSE)
