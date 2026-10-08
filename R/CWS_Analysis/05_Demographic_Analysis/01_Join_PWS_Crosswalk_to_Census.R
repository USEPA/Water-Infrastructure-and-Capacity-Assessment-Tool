# This script joins the PWS-Crosswalk table with Census Data.

# Clear environment
rm(list = ls())

library(dplyr)
library(vroom)
library(here)
library(stringr)
library(data.table)
library(tidyr)
options(scipen = 999)
library(readr)

# Load configuration variables
source(here("R/CWS_Analysis/00_config.R"))

# Import data ----

## Decennial Census Block Data ----

# Import census block population data and create block fips field
census_blk_pop_data <-
  readRDS(here("R/Census_Imprt_Prep/Decennial_Census/Temp_Outputs/2020_DHCa_blk_ClcdVar.rds"))


## ACS Block Group Data ----
ACS_BG_Socioeconomic <-
  readRDS(here("R/Census_Imprt_Prep/ACS/Blk_Grp/Temp_Outputs/ACS_TblA_BG_ClcdVar.rds"))

## ACS Tract Data ----
ACS_Trct_Socioeconomic <-
  readRDS(here("R/Census_Imprt_Prep/ACS/Tract/Temp_Outputs/ACS_TblB_Trct_ClcdVar.rds"))

## Community Water System Service Area Crosswalk Table ----

### Block crosswalk ----
blocks_pws <- read_csv(pws_blk_crswlk_url) %>%
  mutate(bg_fips = substr(GEOID20, 1, 12),
    trct_fips = substr(GEOID20, 1, 11)) 

### OFF Block group crosswalk ----
# blockgrp_pws <- read_csv(pws_blkgrp_crswlk_url)
# 
### OFF Tract crosswalk ----
# trct_pws <- read_csv(pws_trct_crswlk_url)

# Join Demographic Data to Crosswalk Table ----
## Block population and Urban/Rural Data ----

blocks_pws_join <-
  merge(
    blocks_pws,
    # PWSID-Census Block Crosswalk Table
    census_blk_pop_data,
    # Census Block Table (which includes the population and additional census block level data fields)
    # by = "blk_fips",
    by.x = "GEOID20",
    by.y = "GEOCODE",
    all.x = TRUE
  ) %>%
  mutate(
    pop_ovlp = replace_na(Bldg_Weight, 0) * U7H001,
    # U7H001 is census block population. Calculate the population of each block that overlaps with a PWS
    housingunit_ovlp = replace_na(Bldg_Weight, 0) * U9V001
  ) # U9V001 is total census block housing units. Calculate the housing units in each block that overlaps with a PWS

# Data Check for NAs (NAs would indicate a block ID in the PWS-crosswalk df did not match with a block ID in the census_blk_pop_data dataframe). This should be zero.

sum(is.na(blocks_pws_join$GEOID20)) # GISJOIN is a field (from the census_blk_pop_date df) that gets added to the blocks_pws df after joining. If this field is NA, then it means that there was no match between the block id in the PWS df and the census block df.

## Block group ACS Data ----
blocks_pws_with_ACS <-
  merge(
    blocks_pws_join[, c(
      "PWSID",
      "STATE",
      "blk_fips",
      "bg_fips",
      "trct_fips",
      "U7H001",
      "U9V001",
      "U7I001",# temp total population (for rural/urban)
      "U7I003",# temp total rural population
      "Bldg_Weight",
      "pop_ovlp",
      "housingunit_ovlp",
      "Urban_Rural"
    )],
    # subset columns to only necessary fields
    ACS_BG_Socioeconomic,
    # This df includes the ACS demographic/socioeconomic data
    by = "bg_fips",
    all.x = TRUE
  )

# blocks_pws_with_ACS <-
#   merge(
#     blockgrp_pws,
#     ACS_BG_Socioeconomic,
#     by.x = "GEOID20",
#     by.y = "bg_fips",
#     all.x = TRUE
#   )

# blocks_pws_with_ACS <-
#   merge(
#     blocks_pws_join_blkgrp_add[, c(
#       "PWSID",
#       "STATE",
#       "blk_fips",
#       "bg_fips",
#       "U7H001",
#       "U9V001",
#       "U7I001",
#       # temp total population (for rural/urban)
#       "U7I003",
#       # temp total rural population
#       "Bldg_Weight",
#       "pop_ovlp",
#       "housingunit_ovlp",
#       "Urban_Rural"
#     )],
#     # subset columns to only necessary fields
#     ACS_BG_Socioeconomic,
#     # This df includes the ACS demographic/socioeconomic data
#     by.x = "GEOID20",
#     by.y = "bg_fips",
#     all.x = TRUE
#   )

# Data Check for NAs (NAs would indicate a bg IDs in the PWS-crosswalk df did not match with a bg ID the ACS dataset)
sum(is.na(blocks_pws_with_ACS$PCT_POP_U5))

## Tract ACS Data ----
Complete_PWS_Crswlk <-
  merge(
    blocks_pws_with_ACS,
    # subset columns to only necessary fields
    ACS_Trct_Socioeconomic,
    # This df includes the ACS demographic/socioeconomic data
    by.x = "trct_fips",
    by.y = "tract_fips", 
    all.x = TRUE
  )

# Data Check for NAs (NAs would indicate a bg IDs in the PWS-crosswalk df did not match with a bg ID the ACS dataset)
sum(is.na(Complete_PWS_Crswlk$LQI))

# Export ----
# write.csv(
#   blocks_pws_with_ACS,
#   here(
#     "R/CWS_Analysis/05_Demographic_Analysis/PWS_with_Census.csv"
#   ),
#   row.names = FALSE
# )

saveRDS(Complete_PWS_Crswlk,here("R/CWS_Analysis/05_Demographic_Analysis/Temp_Outputs/PWS_with_Census.rds"))
