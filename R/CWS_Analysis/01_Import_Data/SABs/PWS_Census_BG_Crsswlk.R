# This script imports the public water system, census block group crosswalk from EPA's GitHub page for the service area boundary dataset. This dataset is updated whenever a new version of the service area boundary dataset is released.

# Load packages
library(dplyr)
library(vroom)
library(here)
library(stringr)
library(tidyr)
options(scipen = 999)

# Import public water system x census block crosswalk table ----

blockgrp_pws <- read.csv(
  "https://raw.githubusercontent.com/USEPA/ORD_SAB_Model/refs/heads/main/Version_History/3_0/Census_Tables/Block_Groups_V_3_0.csv"
) %>%
  mutate(GEOID20 = str_pad(
    GEOID20,
    width = 12,
    side = "left",
    pad = "0"
  ))

# Export ----
write.csv(blockgrp_pws, here("Input_Data/Census/PWS-Crosswalk/PWS_BlkGrp_CrsWlk.csv"), row.names = FALSE)