# This script imports permit component data

# Clear all objects from the global environment
rm(list = ls())

library(here)
library(zoo)
library(lubridate)
library(dplyr)
library(vroom)
library(DBI)
library(odbc)

# Create db connections and import environment variables ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

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
# vroom_write(echo_CWA_permit_components,
#           here("Input_Data/NPDES/NPDES_PERMIT_COMPONENTS.csv"), delim = ",")

saveRDS(echo_CWA_permit_components,here("R/Wastewater_Analysis/01_Import_Data/NPDES/Temp_Outputs/NPDES_PERMIT_COMPONENTS.rds"))
