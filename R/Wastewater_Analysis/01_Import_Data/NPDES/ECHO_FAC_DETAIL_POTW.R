library(here)
library(RODBC)
library(dplyr)
library(vroom)

# This script is used download ECHO Facility Details data

##ORACLE QUERY TAKES TOO LONG TO RUN, DOWNLOADING FILE FROM ECHO DATA DOWNLOADS, INSTEAD. ALSO, DOUBLE CHECK V_ECHO_EXPORTER13_DL OR V_ECHO_EXPORTER##

ECHO_FAC_DETAILS <- vroom(here(
  "R/Wastewater_Analysis/01_Import_Data/NPDES/ECHO_EXPORTER.csv"
)) %>%
  filter(NPDES_FLAG == "Y" &
           FAC_ACTIVE_FLAG == "Y") %>% # Subset file for active NPDES facilities
  dplyr::select(
    .,
    NPDES_IDS,
    DFR_URL,
    REGISTRY_ID,
    FAC_INDIAN_CNTRY_FLG,
    FAC_US_MEX_BORDER_FLG,
    FAC_CHESAPEAKE_BAY_FLG
  ) 
#%>%
  #mutate(REGISTRY_ID = as.character(REGISTRY_ID))

# Create a connection to ECHO ----
# db <- Sys.getenv("ECHO_DB")
# uid <- Sys.getenv("ECHO_uid")
# pwd <- Sys.getenv("ECHO_pwd")
# 
# con <- dbConnect(odbc::odbc(),
#                  dsn = db,
#                  uid = uid,
#                  pwd = pwd)
# 
# # Set up and run query ----
# ECHO_FAC_DETAILS_QUERY <- paste(
#   "SELECT NPDES_IDS, DFR_URL, REGISTRY_ID
#     FROM ECHO_DFR.V_ECHO_EXPORTER13_DL
#     WHERE
#      NPDES_FLAG = 'Y'
#       AND FAC_ACTIVE_FLAG = 'Y'"
# ) 
# 
# ECHO_FAC_DETAILS <- dbGetQuery(con, ECHO_FAC_DETAILS_QUERY) %>%
#   mutate(REGISTRY_ID = as.character(REGISTRY_ID))

# Export  ---------------------------
vroom_write(ECHO_FAC_DETAILS, here("Input_Data/ECHO/ECHO_FAC_DETAILS_POTW.csv"), delim = ",")
