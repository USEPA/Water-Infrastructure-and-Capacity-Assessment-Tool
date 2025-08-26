library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)

# This script is used to import SDWA Site Visit dataset, and filter for sanitary surveys:
# SNSV	Sanitary Survey, Complete
# L1SS	Level 1 Assessment and Sanitary Survey
# L2SS	Level 2 Assessment and Sanitary Survey

# Create a connection to SDWIS -------------------------
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Import data -------------------------

# Load compliance period begin date
load("R/01_Import_Data/SDWIS/compliance_period_begin_date.Rdata")

# Set up query
SDWA_site_visits_query <- paste(
  "SELECT *
  FROM LTST_SITE_VISIT
  WHERE
   VISIT_REASON_CODE IN ('SNSV', 'L1SS', 'L2SS')
  AND PWS_TYPE_CODE = 'CWS'
  AND PWS_ACTIVITY_CODE = 'A'"
)

# Run query ---------------------------
SDWA_site_visits <- sqlQuery(channel_SDWIS,SDWA_site_visits_query)

# Date formatting and subsetting ---------------------------

# Convert Quarters to a FY QTR date class
SDWA_site_visits$SS_VISIT_FYQTR <-
  as.yearqtr(SDWA_site_visits$VISIT_DATE) 

# Add 1Q to the QTR field to "change" to a FY start 10 (Oct) vs FY start 1 (Jan)
SDWA_site_visits$SS_VISIT_FYQTR <-
  SDWA_site_visits$SS_VISIT_FYQTR + .25

# Remove all site visits that occurred AFTER Q12 (e.g., the most recent official quarter of data)
SDWA_site_visits <-
  SDWA_site_visits %>%
  filter(., SS_VISIT_FYQTR <= j)

# Export  ---------------------------
write.csv(SDWA_site_visits, here("Input_Data/SDWIS", "SDWA_san_survey.csv"), row.names = FALSE)
