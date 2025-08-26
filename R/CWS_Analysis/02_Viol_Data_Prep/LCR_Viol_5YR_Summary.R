library(here)
library(zoo)
library(vroom)
library(dplyr)

# This script counts the number of quarters in the last 5-years with at least 1 lead and copper rule violation 

LCR_Violations_5yr_Summary<-
  vroom(here("R/CWS_Analysis/02_Viol_Data_Prep/VIOLATIONS_LESS_THAN_5YRS_CPBD.csv")) %>%
  filter(.,
         RULE == "Lead and Copper Rule") %>%
  group_by(PWSID) %>%
  distinct(PWSID, FYQTR, .keep_all = TRUE) %>%
  reframe(LCR_VIOL_COUNT_QTRS_5YRS = n())

# Export
write.csv(LCR_Violations_5yr_Summary, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/LCR_Violations_5yr_Summary.csv"), row.names = FALSE)