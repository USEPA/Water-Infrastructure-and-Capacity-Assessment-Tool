library(here)
library(zoo)
library(DBI)
library(odbc)
library(lubridate)
library(dplyr)
library(vroom)

# This script is used to import the most recent compliance status for POTWs.

# Create db connections and import environment variables ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")
FYQTR_NPDES <- Sys.getenv("FYQTR_NPDES") # Import the FYQTR to run query

con <- dbConnect(odbc::odbc(),
                 dsn = db,
                 uid = uid,
                 pwd = pwd)

# Set up and run query ----
NPDES_CURRENT_COMPL_STAT_QUERY <- paste("SELECT NPDES_ID, YEARQTR, HLRNC
  FROM ECHO_DFR.V_NPDES_QNCR_HISTORY_DL
  WHERE
   YEARQTR =",FYQTR_NPDES)

NPDES_CURRENT_COMPL_STAT <- dbGetQuery(con, NPDES_CURRENT_COMPL_STAT_QUERY) 

# Export  ---------------------------
write.csv(NPDES_CURRENT_COMPL_STAT, here("Input_Data/NPDES/NPDES_LTST_COMPL_STATUS.csv"), row.names = FALSE)
