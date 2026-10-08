# This script is used to calculate select Decennial Census variable to identify on a binary, 0/1, as to whether the census block is considered Urban (else Rural).

#Clear environment
rm(list = ls())

# Load libraries ----
library(here)
library(dplyr)
library(vroom)

# Import Data ----
Decennial_Blk_Import <-
  #vroom(here("Input_Data/Census/ACS/ACS_TblA_BG/ACS_2020_2024a_BG.csv"))
readRDS(here("R/Census_Imprt_Prep/Decennial_Census/Temp_Outputs/2020_DHCa_blk.rds"))

# Calculate ACS Variables ----
# Import census block population data and create block fips field
census_blk_pop_data <- Decennial_Blk_Import %>%
  mutate(
    blk_fips =
      paste0(
        substr(.$GISJOIN, 2, 3),
        substr(.$GISJOIN, 5, 7),
        substr(.$GISJOIN, 9, 18) #Use GISJOIN to create a census block FIPS code column
      ),
    Urban_Rural = case_when((URA == "R")  ~ 1, TRUE ~ 0)
    # Convert Rural/Urban to 0/1 for later calculation of population weighted data
  )

# Export ----
saveRDS(
  census_blk_pop_data,
  here(
    "R/Census_Imprt_Prep/Decennial_Census/Temp_Outputs/2020_DHCa_blk_ClcdVar.rds"
  )
)
