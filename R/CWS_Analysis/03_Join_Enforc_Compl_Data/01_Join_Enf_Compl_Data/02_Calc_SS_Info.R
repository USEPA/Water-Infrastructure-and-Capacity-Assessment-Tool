# This script is used to determine if a sanitary survey is overdue based on outstanding performer, 4log or greater TT, and source water type.

rm(list = ls()) # Clear environment

library(here)
library(zoo)
library(dplyr)
options(scipen = 999)

# Load environment variables for current FYQTR and CPBD ----
source(here("R/CWS_Analysis/00_config.R"))

# Import data ----
Joined_enfcmpl_df <- readRDS(here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/Temp_Outputs/merged_enf_compl_df.rds"))

# Calculate Sanitary Survey Overdue ----

# Sanitary surveys are overdue based one of the below 3 conditions
SS_Calcd <- Joined_enfcmpl_df %>%
  mutate(SS_SURVEY_OVERDUE = "") %>% # Initialize SS_SURVEY_OVERDUE with "" %>%
  mutate(SS_VISIT_FYQTR = as.yearqtr(SS_VISIT_FYQTR)) %>% # Ensure SS_VISIT_FYQTR is numeric
  mutate(
    SS_SURVEY_OVERDUE = case_when(
      # Condition 1: A survey is overdue if there is no date entered for the most recent SS 
      is.na(VISIT_DATE) ~ "Y",
      
      # Condition 2: A survey is overdue if it has been 5-yrs since the last SS for GW systems with greater than 4Log TT OR any outstanding performer
      ((SOURCE_WATER_TYPE == "Groundwater" & TT_4Log == "Y") | OUTSTANDING_PERFORMER == "Y") & j > SS_VISIT_FYQTR + 5 ~ "Y",
      
      # Condition 3: A survey is overdue for all other systems, if it has been more than 3-years since the last survey.
      j > (SS_VISIT_FYQTR + 3) ~ "Y",
      
      # If none of the conditions are true
      TRUE ~ "N"
    )
  )

# Export ----
# write.csv(Joined_enfcmpl_df, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/Joined_enfcmpl_df.csv"), row.names = FALSE)

saveRDS(SS_Calcd, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/Temp_Outputs/Joined_enfcmpl_df.rds"))
