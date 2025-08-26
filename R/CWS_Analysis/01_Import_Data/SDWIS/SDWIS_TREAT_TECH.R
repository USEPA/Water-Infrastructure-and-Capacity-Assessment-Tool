library(here)
library(RODBC)
library(dplyr)

# Import treatment technique data. These data are used to identify PWS with the following 4-log treatment, or greater:
# TREATMENT_PROCESS_CODE 363 4-Log Remove/Inactivate Viruses
# TREATMENT_PROCESS_CODE 361 4-Log Treatment of Viruses
# TREATMENT_PROCESS_CODE 371 5.0-Log Remove/Inactivate Crypto
# TREATMENT_PROCESS_CODE 372 5.5-Log Remove/Inactivate Crypto

# Create a connection to SDWIS -------------------------
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Set up query -------------------------
Greater_than_4log_treatment_query <- paste(
  "SELECT *
  FROM LTST_TREATMENT
  WHERE
   TREATMENT_PROCESS_CODE  IN ('361', '363','371', '372')"
)

# Run query ---------------------------
Greater_than_4log_treatment <- sqlQuery(channel_SDWIS,Greater_than_4log_treatment_query) 

# Export  ---------------------------
write.csv(Greater_than_4log_treatment, here("Input_Data/SDWIS", "SDWIS_TT.csv"), row.names = FALSE)
