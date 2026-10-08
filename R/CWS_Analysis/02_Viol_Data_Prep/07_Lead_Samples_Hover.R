# This script subsets lead samples from the Lead and Copper Rule (LCR) dataset counting the number of lead samples between 10-15ppb

rm(list = ls()) # Clear environment

library(here)
library(zoo)
library(dplyr)

# Count of Lead samples between 10 and 15ppb (not including 15ppb) - 5-yr/20-Quarter Summary ----
LEAD_SAMPLE_10_THRU_15_COUNT_5YRS <- #vroom(here("Input_Data/SDWIS/Lead_Samples.csv")) %>%
  readRDS(here("R/CWS_Analysis/01_Import_Data/SDWIS/Temp_Outputs/Lead_Samples.rds")) %>%
  mutate(FYQTR = as.yearqtr(FYQTR, format = "%Y Q%q")) %>% # Convert FYQTR to year-quarter format
  filter(., (FYQTR >  (max(FYQTR) - 5)) & 
           (SAMPLE_MEASURE >= 0.01 &
              SAMPLE_MEASURE < 0.0155)) %>% # filter for samples reported in the last 5-years AND are between 0.01 and 0.0155
  group_by(PWSID) %>%
  summarise(LEAD_SAMPLE_COUNT_5YRS = n()) %>% # Count the number of samples between 10 and 15ppb for each PWSID
  ungroup()

# Export  ----
# write.csv(LEAD_SAMPLE_10_THRU_15_COUNT_5YRS, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/LEAD_SAMPLE_10_THRU_15_COUNT_5YRS.csv"), row.names = FALSE)
  
saveRDS(LEAD_SAMPLE_10_THRU_15_COUNT_5YRS, here("R/CWS_Analysis/02_Viol_Data_Prep/Temp_Outputs/LEAD_SAMPLE_10_THRU_15_COUNT_5YRS.rds"))