library(here)
library(zoo)
library(lubridate)
library(dplyr)
library(vroom)
library(DBI)
library(odbc)

# This script is used to import single event violation data in the last 3-years/12-qtrs

# This script imports permit component data

# Create db connections and import environment variables ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

FYQTR_NPDES <- Sys.getenv("FYQTR_NPDES") # Import the "FYQTR" to run SQL query
npdes_set_fyqtr <- Sys.getenv("npdes_set_fyqtr") # Import the "FY QTR" to filter data
npdes_set_fyqtr <- as.yearqtr(npdes_set_fyqtr) # Convert to a yearqtr class

con <- dbConnect(odbc::odbc(),
                 dsn = db,
                 uid = uid,
                 pwd = pwd)

# Set up and run query ----
echo_CWA_permit_components_query <- paste(
  "SELECT *
  FROM ECHO_DFR.v_NPDES_PERM_COMPONENT_DL"
)

echo_CWA_permit_components <- dbGetQuery(con, echo_CWA_permit_components_query) %>%
  rename(NPDES_ID = EXTERNAL_PERMIT_NMBR) 

# Export ----
vroom_write(echo_CWA_permit_components,
          here("Input_Data/NPDES/NPDES_PERMIT_COMPONENTS.csv"), delim = ",")
