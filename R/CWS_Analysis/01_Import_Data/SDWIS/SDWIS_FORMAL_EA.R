library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)

# This script is used to import formal enforcement action data for violations that have not yet RTCd.

# Create a connection to SDWIS -------------------------
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Set-up and run query -------------------------

# The following query obtain all formal enforcement actions, for violations that have not RTC and are not Rule Code == 500
SDFW_Formal_Enforcement_Actions <- sqlQuery(
  channel_SDWIS,
  "SELECT *
FROM sfdw.ltst_violation A
    LEFT JOIN sfdw.ltst_violation_enf_assoc B ON A.VIOLATION_ID=B.VIOLATION_ID AND A.PWSID=B.PWSID AND A.LATEST_ENFORCEMENT_ID=B.ENFORCEMENT_ID
    LEFT JOIN sfdw.ltst_enforcement_action C ON B.ENFORCEMENT_ID=C.ENFORCEMENT_ID AND B.PWSID=C.PWSID
WHERE
    A.pws_type_code = 'CWS'
    AND A.rule_code != '500'
    AND A.pws_activity_code = 'A'
    AND A.RTC_date IS NULL
    AND C.enforcement_action_type_code IN ('SFL', 'EFL', 'SFO', 'SF&', 'EF&', 'SF9', 'EF9', 'SFQ', 'EFQ', 'SFV', 'EFV', 'EF/' ,'SF/' , 'SF%', 'EF%', 'SFR', 'EFR', 'SFW', 'EFW', 'SFM', 'EF-', 'EF=', 'EF<')"
)

# Formatting ------------------------

# Convert Quarters to a FY QTR date class
SDFW_Formal_Enforcement_Actions$FYQTR <-
  as.yearqtr(SDFW_Formal_Enforcement_Actions$COMPL_PER_BEGIN_DATE)

# Add 1Q to the QTR field to "change" to a FY start 10 (Oct) vs FY start 1 (Jan)
SDFW_Formal_Enforcement_Actions$FYQTR <-
  SDFW_Formal_Enforcement_Actions$FYQTR + .25

# Filter for all EAs that occurred AFTER Q12
SDFW_Formal_Enforcement_Actions <-
  SDFW_Formal_Enforcement_Actions %>%
  filter(., FYQTR <= j)

# Export  ---------------------------
write.csv(SDFW_Formal_Enforcement_Actions, here("Input_Data/SDWIS", "Formal_Enforcement_Actions.csv"), row.names = FALSE)
