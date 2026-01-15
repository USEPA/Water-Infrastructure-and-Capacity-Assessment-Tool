library("zoo")
library("dplyr")

# Values updated quarterly

## SDWIS
COMPL_PER_BEGIN_DATE_SELECT <- as.Date("01-JAN-20", "%d-%b-%y", tz = "") %>% 
  format(., "%d-%b-%y") # Start date for compliance period to include in analysis
j <- as.yearqtr("2025 Q4")
k <- "2025Q4"

# Values updated annually
## SRF
DWSRF_Initial_Agreement_Date_Start <- as.Date("2015-07-01", "%Y-%m-%d")  # Start date for DWSRF initial agreements to include in analysis
DWSRF_Initial_Agreement_Date_End <- as.Date("2025-06-30","%Y-%m-%d") # End date for DWSRF initial agreements to include in analysis
