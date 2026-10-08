# This script is used download ECHO Facility Details data

# Clear all objects from the global environment
rm(list = ls())

library(here)
library(RODBC)
library(dplyr)
library(vroom)

##IF ORACLE QUERY TAKES TOO LONG TO RUN, DOWNLOAD FILE FROM ECHO DATA DOWNLOADS, INSTEAD. ALSO, DOUBLE CHECK V_ECHO_EXPORTER13_DL OR V_ECHO_EXPORTER##

# ECHO_FAC_DETAILS <- vroom(here(
#   "R/Wastewater_Analysis/01_Import_Data/NPDES/ECHO_EXPORTER.csv"
# )) %>%
#   filter(NPDES_FLAG == "Y" &
#            FAC_ACTIVE_FLAG == "Y") %>% # Subset file for active NPDES facilities
#   dplyr::select(
#     .,
#     NPDES_IDS,
#     DFR_URL,
#     REGISTRY_ID,
#     FAC_INDIAN_CNTRY_FLG,
#     FAC_US_MEX_BORDER_FLG,
#     FAC_CHESAPEAKE_BAY_FLG
#   ) 
#%>%
  #mutate(REGISTRY_ID = as.character(REGISTRY_ID))

# Create a connection to ECHO ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

con <- odbcConnect(db, uid, pwd)

# Set up and run query ----
ECHO_FAC_DETAILS_QUERY <- paste(
  "SELECT NPDES_IDS, DFR_URL, REGISTRY_ID, FAC_INDIAN_CNTRY_FLG, FAC_US_MEX_BORDER_FLG, FAC_CHESAPEAKE_BAY_FLG
    FROM ECHO_DFR.V_ECHO_EXPORTER
    WHERE
     NPDES_FLAG = 'Y'
      AND FAC_ACTIVE_FLAG = 'Y'"
)

# Set-up and run query----
ECHO_FAC_DETAILS <- sqlQuery(
  con,
  ECHO_FAC_DETAILS_QUERY
)

# Export  ---------------------------
# vroom_write(ECHO_FAC_DETAILS, here("Input_Data/ECHO/ECHO_FAC_DETAILS_POTW.csv"), delim = ",")
saveRDS(ECHO_FAC_DETAILS,here("R/Wastewater_Analysis/01_Import_Data/NPDES/Temp_Outputs/ECHO_FAC_DETAILS_POTW.rds"))
