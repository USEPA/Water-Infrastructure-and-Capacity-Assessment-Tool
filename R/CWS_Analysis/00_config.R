library("zoo")
library("dplyr")

# Values updated quarterly

## SDWIS
COMPL_PER_BEGIN_DATE_SELECT <- as.Date("01-APR-21", "%d-%b-%y", tz = "") %>% 
  format(., "%d-%b-%y") # Start date for compliance period to include in analysis (5yr window)
j <- as.yearqtr("2026 Q2")
k <- "2026Q2"

# Values updated annually
## SRF
DWSRF_Initial_Agreement_Date_Start <- as.Date("2015-07-01", "%Y-%m-%d")  # Start date for DWSRF initial agreements to include in analysis
DWSRF_Initial_Agreement_Date_End <- as.Date("2025-06-30","%Y-%m-%d") # End date for DWSRF initial agreements to include in analysis

## SAB Github 
#Version 3.0 - https://github.com/USEPA/ORD_SAB_Model/tree/main/Version_History/3_0/Census_Tables
pws_blk_crswlk_url  <- "https://media.githubusercontent.com/media/USEPA/ORD_SAB_Model/refs/heads/main/Version_History/3_0/Census_Tables/Blocks_V_3_0.csv"

pws_blkgrp_crswlk_url <- "https://raw.githubusercontent.com/USEPA/ORD_SAB_Model/refs/heads/main/Version_History/3_0/Census_Tables/Block_Groups_V_3_0.csv"

pws_trct_crswlk_url <-"https://raw.githubusercontent.com/USEPA/ORD_SAB_Model/refs/heads/main/Version_History/3_0/Census_Tables/Tracts_V_3_0.csv"
