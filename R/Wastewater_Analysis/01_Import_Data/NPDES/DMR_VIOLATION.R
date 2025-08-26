library(vroom)
library(here)
library(readxl)
library(dplyr)
library(zoo)
library(DBI)
library(odbc)

# This script imports DMR (D80 and D90) violations data for the last 3-years.

# Get environment variables
FYQTR_NPDES <- Sys.getenv("FYQTR_NPDES") # Import the "FYQTR" to run SQL query
npdes_set_fyqtr <- Sys.getenv("npdes_set_fyqtr") # Import the "FY QTR" to filter data
npdes_set_fyqtr <- as.yearqtr(npdes_set_fyqtr) # Convert to a yearqtr class

# Create a connection to ECHO ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")
monitoring_period_end_date <- Sys.getenv("MONITORING_PERIOD_END_DATE")

con <- dbConnect(odbc::odbc(),
                 dsn = db,
                 uid = uid,
                 pwd = pwd)

# Set up and run query ----
DMR_Viol_D90_D80_query <- paste(
  "SELECT NPDES_ID, MONITORING_PERIOD_END_DATE, VIOLATION_CODE 
  FROM ECHO_DFR.V_NDPES_EFF_VIO_DL
WHERE VIOLATION_CODE IN ('D90', 'D80')
  AND MONITORING_PERIOD_END_DATE >=","'", monitoring_period_end_date,"'",
  ""
)

DMR_Viol_D90_D80 <- dbGetQuery(con, DMR_Viol_D90_D80_query)

# Formatting ----
# Set date class
DMR_Viol_D90_D80_formatted <- DMR_Viol_D90_D80 %>%
  mutate(MONITORING_PERIOD_END_DATE = as.Date(MONITORING_PERIOD_END_DATE, "%m/%d/%Y"))

# Create a FYQTR column  
DMR_Viol_D90_D80_formatted$FYQTR <- as.yearqtr(DMR_Viol_D90_D80_formatted$MONITORING_PERIOD_END_DATE) 

# Add 1Q to the QTR field to "change" to a FY start 10 (Oct) vs FY start 1 (Jan)
DMR_Viol_D90_D80_formatted$FYQTR <- DMR_Viol_D90_D80_formatted$FYQTR + .25

#Filter for the last 12 quarters (do not include quarter 13)
DMR_Viol_D90_D80_3yrs <- DMR_Viol_D90_D80_formatted %>%
  filter(., FYQTR >  npdes_set_fyqtr - 3 & FYQTR <= npdes_set_fyqtr)

# Export ----
write.csv(DMR_Viol_D90_D80_3yrs, here("Input_Data/NPDES/NPDES_VIOL_D80D90_DMR.csv"), row.names = FALSE)
