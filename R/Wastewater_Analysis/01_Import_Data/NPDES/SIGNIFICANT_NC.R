library(here)
library(zoo)
library(lubridate)
library(dplyr)
library(vroom)
library(RODBC)

# This script is used to import significant noncompliance data in the current quarter and last 3-years/12-qtrs.

# Set-up Query ----

# Create db connections and import environment variables ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

channel_ECHO <- odbcConnect(db, uid, pwd)

# Set up and run query ----
SNC_query <- paste(
  "SELECT CWP_FACILITY_TYPE_INDICATOR, SOURCE_ID, CWP_SNC_STATUS, CWP_QTRS_WITH_SNC, CWP_QTRS_EFF_SNC, OTHER_CWA_SNC, CWP_FORMAL_EA_CNT, CWP_13QTRS_COMPL_STATUS, ROLLING_TIME_PD
   FROM ECHO_DFR.V_SNC_CWA_SUMMARY_SEARCH
   WHERE
   CWP_FACILITY_TYPE_INDICATOR = 'POTW'
   AND CWP_SNC_STATUS IS NOT NULL
  "
)

# POTWS_WITH_SNC <- dbGetQuery(con, SNC_query) 
POTWS_WITH_SNC <- sqlQuery(channel_ECHO, SNC_query) 

# Select only distinct POTWs
POTWS_WITH_SNC_DISTINCT <- POTWS_WITH_SNC %>%
  distinct(SOURCE_ID, .keep_all = TRUE) %>%
  rename(NPDES_ID = SOURCE_ID)

# Export ----
write.csv(POTWS_WITH_SNC_DISTINCT, here("Input_Data/NPDES/POTWS_WITH_SNC.CSV"), row.names = FALSE)
