library(here)
library(zoo)
library(vroom)
library(dplyr)

# This script subsets lead samples from the Lead and Copper Rule (LCR) dataset counting the number of lead samples at/above the lead ALE (0.0155 mg/L)

# Count of Lead ALEs - 5-yr/20-Quarter Summary -------------------
LEAD_ALE_COUNT_LAST_5_YRS <- vroom(here("Input_Data/SDWIS/Lead_Samples.csv")) %>% #Import lead sampling data
  mutate(FYQTR = as.yearqtr(FYQTR, format = "%Y Q%q")) %>% # Convert FYQTR to year-quarter format)
  filter(., FYQTR >  (max(FYQTR) - 5) &
           SAMPLE_MEASURE >= 0.0155) %>% # filter for samples reported in the last 5-years AND are at or above the Lead ALE
  group_by(PWSID) %>%
  summarise(LEAD_ALE_COUNT_5YRS = n()) %>% # Count the number of samples at or above the Lead ALE for each PWSID
  ungroup()

# Export
write.csv(LEAD_ALE_COUNT_LAST_5_YRS, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/LEAD_ALE_COUNT_LAST_5_YRS.csv"), row.names = FALSE)