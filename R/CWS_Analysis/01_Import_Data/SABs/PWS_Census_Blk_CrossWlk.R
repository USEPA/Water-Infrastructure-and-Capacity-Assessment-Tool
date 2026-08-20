# This script imports the public water system, census block crosswalk from EPA's GitHub page for the service area boundary dataset. This dataset is updated whenever a new version of the service area boundary dataset is released.

# Load packages
library(dplyr)
library(vroom)
library(here)
library(stringr)
library(tidyr)
options(scipen = 999)

# Import public water system x census block crosswalk table ----

blocks_pws <- read.csv("https://media.githubusercontent.com/media/USEPA/ORD_SAB_Model/refs/heads/main/Version_History/3_0/Census_Tables/Blocks_V_3_0.csv")

# Export ----
write.csv(blocks_pws, here("Input_Data/Census/PWS-Crosswalk/PWS_Blks_CrsWlk.csv"), row.names = FALSE)