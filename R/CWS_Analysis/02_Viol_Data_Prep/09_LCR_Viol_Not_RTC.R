library(here)
library(zoo)
library(vroom)
library(dplyr)

# This script counts the number Lead & Copper Rule Violations that have not RTC'd (with a CPBD <5Yrs).

LCR_Violations_non_RTC <-
  vroom(here("R/CWS_Analysis/02_Viol_Data_Prep/VIOLATIONS_LESS_THAN_5YRS_CPBD.csv")) %>%
  filter(.,
         (is.na(RTC_DATE)) & RULE == "Lead and Copper Rule") %>%
  group_by(PWSID) %>%
  distinct(PWSID, FYQTR, .keep_all = TRUE) %>%
  reframe(LCR_VIOL_NONRTC_COUNT = n())

# Export
write.csv(LCR_Violations_non_RTC, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/LCR_Violations_non_RTC.csv"), row.names = FALSE)

