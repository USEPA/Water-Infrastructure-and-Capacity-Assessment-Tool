library(here)
library(zoo)
library(lubridate)
library(dplyr)
library(vroom)
library(DBI)
library(odbc)

# This script imports facility information about about permitted POTWs

# Create a connection to ECHO ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

con <- dbConnect(odbc::odbc(),
                 dsn = db,
                 uid = uid,
                 pwd = pwd)

# Set up and run query ----
echo_npdes_facility_data_query <- paste(
  "SELECT NPDES_ID,
      FACILITY_UIN,
      FACILITY_TYPE_CODE,
      FACILITY_NAME,
      CITY,
      COUNTY_CODE,
      STATE_CODE ,
      ZIP  ,
      GEOCODE_LATITUDE ,
      GEOCODE_LONGITUDE  ,
      IMPAIRED_WATERS
  FROM ECHO_DFR.v_ICIS_FACILITIES_DL"
)

echo_npdes_facility_data <- dbGetQuery(con, echo_npdes_facility_data_query)

# Export ----
vroom_write(echo_npdes_facility_data,
          here("Input_Data/NPDES/NPDES_FACILITY_INFO.csv"),
          delim = ",")
