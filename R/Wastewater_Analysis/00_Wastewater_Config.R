library("zoo")
library("dplyr")

# Values updated quarterly
FYQTR_NPDES = "20262"
npdes_set_fyqtr = as.yearqtr("2026 Q2")

# MONITORING_PERIOD_END_DATE = "30-SEP-22" #"30-JUN-22"
# SINGLE_EVENT_VIOLATION_DATE = "01-NOV-22" #'01-JUL-22'
# SETTLEMENT_ENTERED_DATE = "30-SEP-20" #'30-JUN-2020'

MONITORING_PERIOD_END_DATE = "31-MAR-23" #March 31, 2026 is the MPED for 2026Q2, minus 3 yrs to capture a 3 year period
SINGLE_EVENT_VIOLATION_DATE = "31-MAR-23" # "01-NOV-22" #'01-JUL-22'
SETTLEMENT_ENTERED_DATE = "31-MAR-21" #March 31, 2026 is the MPED for 2026Q2, minus 5 yrs to capture a 5 year enforcement window

# Values updated annually
## SRF
CWSRF_Initial_Agreement_Date_Start <- as.Date("2015-07-01", "%Y-%m-%d")  # Start date for CWSRF initial agreements to include in analysis
CWSRF_Initial_Agreement_Date_End <- as.Date("2025-06-30","%Y-%m-%d") # End date for CWSRF initial agreements to include in analysis

