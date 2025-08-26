library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)

# This script is used to import lead sample results that occurred in the last 5-years AND were greater than or equal to 0.0100 mg/L

# Create a connection to SDWIS -------------------------
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Set-up and Execute Queries -------------------------

# Load compliance period begin date
load(here("R/01_Import_Data/SDWIS/compliance_period_begin_date.Rdata"))

## Query to obtain sample results >= 0.0100 mg/L  -------------------------
LTST_LCR_SAMPLE_RESULT_QUERY <- paste(
  "SELECT *
  FROM LTST_LCR_SAMPLE_RESULT
  WHERE
   CONTAMINANT_CODE = 'PB90'
   AND SAMPLE_MEASURE >= 0.0100"
)

LTST_LCR_SAMPLE_RESULT <- sqlQuery(channel_SDWIS,LTST_LCR_SAMPLE_RESULT_QUERY) # Run query

## Import lead sample results occurring in the last 5-years  -------------------------

# Set sampling period begin date based on latest quarter data are available. The compliance period begin date will reflect the prior 5-years worth of data (from the beginning of the latest FYQTR)
SAMPLING_START_DATE_SELECT <- as.Date(as.yearqtr(j-.25, format = "Q%q/%y"))-years(5)-days(1) 

SAMPLING_START_DATE_SELECT <- as.Date(SAMPLING_START_DATE_SELECT, format = "%Y-%m-%d") %>% format(., "%d-%b-%y") %>% toupper(.)

# Set up query
sample_query <- paste(
  "SELECT *
  FROM LTST_LCR_SAMPLE
  WHERE
   SAMPLING_START_DATE >=","'",
  SAMPLING_START_DATE_SELECT,"'"
)

# Run query
LTST_LCR_SAMPLE <- sqlQuery(channel_SDWIS,sample_query)

# Formatting -------------------------

# Convert Quarters to a FY QTR date class
LTST_LCR_SAMPLE$FYQTR <- as.yearqtr(LTST_LCR_SAMPLE$SAMPLING_START_DATE)

# Add 1Q to the QTR field to "change" to a FY start 10 (Oct) vs FY start 1 (Jan)
LTST_LCR_SAMPLE$FYQTR <- LTST_LCR_SAMPLE$FYQTR + .25

# Subset for all samples taken before Q13 -------------------------
LTST_LCR_SAMPLE <- LTST_LCR_SAMPLE %>%
  filter(., FYQTR <= j)

# Merge sample datasets  -------------------------

LCR_SAMPLES <-
  merge(
    LTST_LCR_SAMPLE_RESULT,
    LTST_LCR_SAMPLE,
    by = c("PWSID", "SAMPLE_ID")
  )

# Export  ---------------------------
write.csv(LCR_SAMPLES, here("Input_Data/SDWIS", "Lead_Samples.csv"), row.names = FALSE)

