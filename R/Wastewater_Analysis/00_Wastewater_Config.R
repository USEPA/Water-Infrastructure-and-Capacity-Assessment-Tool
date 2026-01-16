library("zoo")
library("dplyr")

# Values updated quarterly
FYQTR_NPDES = "20254"
npdes_set_fyqtr = as.yearqtr("2025 Q4")

MONITORING_PERIOD_END_DATE = "30-SEP-22" #"30-JUN-22"
SINGLE_EVENT_VIOLATION_DATE = "01-NOV-22" #'01-JUL-22'
SETTLEMENT_ENTERED_DATE = "30-SEP-20" #'30-JUN-2020'

# Values updated annually
## SRF
CWSRF_Initial_Agreement_Date_Start <- as.Date("2015-07-01", "%Y-%m-%d")  # Start date for CWSRF initial agreements to include in analysis
CWSRF_Initial_Agreement_Date_End <- as.Date("2025-06-30","%Y-%m-%d") # End date for CWSRF initial agreements to include in analysis

