library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)
library(vroom)

# This script is used to import 5-years of SDWIS violation data.

# Create a connection to SDWIS ----
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Set-up Query ----

# Load configuration variables
source(here("R/CWS_Analysis/00_config.R"))

# Set up query
violations_query <- paste(
  "SELECT *
  FROM LTST_VIOLATION
  WHERE
   PWS_TYPE_CODE  = 'CWS'
    AND RULE_CODE != '500'
    AND PWS_ACTIVITY_CODE = 'A'
    AND (COMPL_PER_BEGIN_DATE>=","'",
  COMPL_PER_BEGIN_DATE_SELECT,"')"
)

# Run query ----
SDWIS_VIOLATIONS_BASE <- sqlQuery(channel_SDWIS,violations_query)

# str(SDWIS_VIOLATIONS_BASE)
# view(head(SDWIS_VIOLATIONS_BASE))

# Formatting ----
## Date formatting ----
# Convert compliance period begin date to a YRQTR then convert to a federal fiscal year/quarter
SDWIS_VIOLATIONS_FRMTD <- SDWIS_VIOLATIONS_BASE %>%
  mutate(
    FYQTR = as.yearqtr(SDWIS_VIOLATIONS_BASE$COMPL_PER_BEGIN_DATE) + .25 # Add 1Q to the QTR field to "change" to a FY start 10 (Oct) vs FY start 1 (Jan)
  )

# Exclude all violations that occurred AFTER Q12 (latest official quarter of data). Some systems have unofficial/Q13 data that we want to exclude.
SDWIS_VIOLATIONS_FRMTD <- SDWIS_VIOLATIONS_FRMTD %>%
  filter(., FYQTR <= j)

## Convert codes to full text----
### Set up query ----
SDWA_ref_codes_query <- paste(
  "SELECT *
  FROM REF_CODE_VALUE
  ")

### Run query ----
SDWA_ref_codes <- sqlQuery(channel_SDWIS,SDWA_ref_codes_query)

# Rule Code
SDWIS_VIOLATIONS_FRMTD <-
  merge(
    SDWIS_VIOLATIONS_FRMTD,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "RULE_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "RULE_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  )  %>% dplyr::select(-c("RULE_CODE")) %>% rename("RULE" = "VALUE_DESCRIPTION")

# Violation Category Code
SDWIS_VIOLATIONS_FRMTD <-
  merge(
    SDWIS_VIOLATIONS_FRMTD,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "VIOLATION_CATEGORY_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "VIOLATION_CATEGORY_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  )  %>% dplyr::select(-c("VIOLATION_CATEGORY_CODE")) %>% rename("VIOLATION_CATEGORY" = "VALUE_DESCRIPTION")

# Export ---- 
write.csv(SDWIS_VIOLATIONS_FRMTD, here("Input_Data/SDWIS/SDWIS_VIOLATIONS_BASE.csv"), row.names = FALSE)
