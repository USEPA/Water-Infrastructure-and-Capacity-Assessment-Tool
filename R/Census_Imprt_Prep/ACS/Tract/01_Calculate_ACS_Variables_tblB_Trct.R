# This script is used to calculate select ACS variables, lowest quintile income.

# Clear environment
rm(list = ls())

# Load libraries ----
library(here)
library(dplyr)
library(vroom)

# Import Data ----
ACS_Trct_Socioeconomic_Import <-
  #vroom(here("Input_Data/Census/ACS/ACS_TblB_Trct/ACS_2020_2024b_trct.csv")) 
  readRDS(here("R/Census_Imprt_Prep/ACS/Tract/Temp_Outputs/ACS_2020_2024b_trct.rds"))

# Calculate ACS Variables ----
ACS_Trct_Socioeconomic <- ACS_Trct_Socioeconomic_Import %>%
  mutate(
    tract_fips =
      paste0(
        substr(.$GISJOIN, 2, 3),
        substr(.$GISJOIN, 5, 7),
        substr(.$GISJOIN, 9, 14) #Use GISJOIN to create a census tract FIPS code column
      ),
    LQI_UL = AVAYE001,
   
  ) %>%
  dplyr::select(
    .,
    c(
      "tract_fips",
      "STATE",
      "STUSAB",
      "LQI_UL"
    )
  ) 

# Histogram ----
ACS_Trct_Socioeconomic_gtr_0 <- ACS_Trct_Socioeconomic %>%
  filter(LQI_UL >=0)

hist(ACS_Trct_Socioeconomic_gtr_0$LQI_UL)
summary(ACS_Trct_Socioeconomic_gtr_0$LQI_UL)

# Export ----
#saveRDS(ACS_BG_Socioeconomic, here("R/Census_Imprt_Prep/ACS/Blk_Grp/Outputs/ACS_TblA_BG_ClcdVar.rds"))
saveRDS(ACS_Trct_Socioeconomic_gtr_0,here("R/Census_Imprt_Prep/ACS/Tract/Temp_Outputs/ACS_TblB_Trct_ClcdVar.rds"))
