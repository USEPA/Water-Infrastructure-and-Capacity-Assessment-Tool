library(here)
library(zoo)
library(lubridate)
library(dplyr)
library(vroom)
library(DBI)
library(odbc)
# This script is used to import effluent violation data in the last 3-years/12-qtrs

# Create db connections and import environment variables ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")
monitoring_period_end_date <- Sys.getenv("MONITORING_PERIOD_END_DATE")
npdes_set_fyqtr <- Sys.getenv("npdes_set_fyqtr")
npdes_set_fyqtr <- as.yearqtr(npdes_set_fyqtr)

con <- dbConnect(odbc::odbc(),
                 dsn = db,
                 uid = uid,
                 pwd = pwd)

# Set up and run query ----
echo_npdes_effluent_violations_query <- paste(
  "SELECT A.MONITORING_PERIOD_END_DATE, A.NPDES_ID,
          A.VIOLATION_CODE, A.VIOLATION_DESC, A.PARAMETER_CODE,
 A.PARAMETER_DESC
   FROM ECHO_DFR.V_NDPES_EFF_VIO_DL A
  LEFT JOIN ECHO_DFR.V_ICIS_PERMITS_DL B ON A.NPDES_ID = B.EXTERNAL_PERMIT_NMBR
  WHERE
  A.MONITORING_PERIOD_END_DATE >=","'", monitoring_period_end_date,"'",
  "AND A.VIOLATION_CODE = 'E90'
  AND B.VERSION_NMBR = '0'
  AND B.FACILITY_TYPE_INDICATOR = 'POTW'
  AND B.PERMIT_STATUS_CODE NOT IN ('NON', 'TRM', 'PND', 'RET')"
)

echo_npdes_effluent_violations <- dbGetQuery(con, echo_npdes_effluent_violations_query)

# Formatting ----
# Set date class
echo_npdes_effluent_violations_formatted <- echo_npdes_effluent_violations %>%
  mutate(MONITORING_PERIOD_END_DATE = as.Date(MONITORING_PERIOD_END_DATE, "%m/%d/%Y"))

# Create a FYQTR column  
echo_npdes_effluent_violations_formatted$FYQTR <- as.yearqtr(echo_npdes_effluent_violations_formatted$MONITORING_PERIOD_END_DATE) 

# Add 1Q to the QTR field to "change" to a FY start 10 (Oct) vs FY start 1 (Jan)
echo_npdes_effluent_violations_formatted$FYQTR <- echo_npdes_effluent_violations_formatted$FYQTR + .25

 #Filter for the last 12 quarters (do not include quarter 13)
echo_npdes_effluent_violations_formatted <- echo_npdes_effluent_violations_formatted %>%
  filter(., FYQTR >  npdes_set_fyqtr - 3 & FYQTR <= npdes_set_fyqtr)

# Export ----
write.csv(echo_npdes_effluent_violations_formatted, here("Input_Data/NPDES/NPDES_E90_EFFLUENT_VIOLATIONS.csv"), row.names = FALSE)
