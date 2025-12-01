library(here)
library(zoo)
library(vroom)
library(dplyr)

# Import Data -----------------
SDWIS_VIOLATIONS_BASE <- vroom(here("Input_Data/SDWIS/SDWIS_VIOLATIONS_BASE.csv"))

# Subset Data  -----------------

# Violations less than 5-yrs old (based on CPBD)
SDWIS_VIOLATIONS_BASE$FYQTR <-
  as.yearqtr(SDWIS_VIOLATIONS_BASE$FYQTR)

VIOLATIONS_LESS_THAN_5YRS_CPBD <- SDWIS_VIOLATIONS_BASE %>%
  filter(., (FYQTR >  max(FYQTR) - 5)) 

# Export   -----------------
write.csv(VIOLATIONS_LESS_THAN_5YRS_CPBD, here("R/CWS_Analysis/02_Viol_Data_Prep/VIOLATIONS_LESS_THAN_5YRS_CPBD.csv"), row.names = FALSE)
