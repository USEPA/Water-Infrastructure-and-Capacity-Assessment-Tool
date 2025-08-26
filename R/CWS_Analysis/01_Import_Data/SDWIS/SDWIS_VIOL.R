library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)
library(vroom)

# This script is used to import 5-years of SDWIS violation data.

# Create a connection to SDWIS -------------------------
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Set-up Query -------------------------

# Load compliance period begin date
load(here("R/01_Import_Data/SDWIS/compliance_period_begin_date.Rdata"))

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

# Run query ---------------------------
SDWIS_VIOLATIONS_BASE <- sqlQuery(channel_SDWIS,violations_query)

# str(SDWIS_VIOLATIONS_BASE)
# view(head(SDWIS_VIOLATIONS_BASE))

# Formatting ------------------------
## Date formatting  ------------------------
SDWIS_VIOLATIONS_BASE$FYQTR <-
  as.yearqtr(SDWIS_VIOLATIONS_BASE$COMPL_PER_BEGIN_DATE) # Convert Quarters to a FY QTR date class

# Add 1Q to the QTR field to "change" to a FY start 10 (Oct) vs FY start 1 (Jan)
SDWIS_VIOLATIONS_BASE$FYQTR <- SDWIS_VIOLATIONS_BASE$FYQTR + .25

# Exclude all violations that occurred AFTER Q12 (latest official quarter of data). Some systems have unofficial/Q13 data that we want to exclude.
SDWIS_VIOLATIONS_BASE <- SDWIS_VIOLATIONS_BASE %>%
  filter(., FYQTR <= j)

## Convert codes to full text ------------------------
# Load SDWA reference codes
SDWA_ref_codes <- vroom(
  here("Input_Data/SDWIS", "SDWA_REF_CODE_VALUES.csv")
)

# Rule Code
SDWIS_VIOLATIONS_BASE <-
  merge(
    SDWIS_VIOLATIONS_BASE,
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
SDWIS_VIOLATIONS_BASE <-
  merge(
    SDWIS_VIOLATIONS_BASE,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "VIOLATION_CATEGORY_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "VIOLATION_CATEGORY_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  )  %>% dplyr::select(-c("VIOLATION_CATEGORY_CODE")) %>% rename("VIOLATION_CATEGORY" = "VALUE_DESCRIPTION")

# Export  ---------------------------
write.csv(SDWIS_VIOLATIONS_BASE, here("Input_Data/SDWIS/SDWIS_VIOLATIONS_BASE.csv"), row.names = FALSE)