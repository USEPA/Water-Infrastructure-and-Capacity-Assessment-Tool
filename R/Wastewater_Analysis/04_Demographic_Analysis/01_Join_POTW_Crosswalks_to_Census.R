# This script joins 1,3,5-mi buffer POTW-Blk crosswalks with census data

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

# Import POTW crosswalk df ----
potw_crosswalk <- readRDS(here("R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/POTW_Crswlks_df.rds")) %>%
  mutate(bg_fips = substr(GEOID20, 1, 12),
    trct_fips = substr(GEOID20, 1, 11)) 

# ## Census Tract Data ----
# census_trct_data <- readRDS(here("R/Census_Imprt_Prep/ACS/Tract/Temp_Outputs/ACS_TblA_BG_ClcdVar.rds"))
#
# ## Census Block Data  ----
# census_blk_data <-
# #   vroom(
# #   here(
# #     "R/Wastewater_Analysis/04_Demographic_Analysis/census_blk_pop_data_OUT.csv"
# #   )
# # )
#
#
# ## Census Block Group Data  ----
# census_blkgrp_data <- vroom(
#   here(
#     "R/Wastewater_Analysis/04_Demographic_Analysis/census_blkgrp_OUT.csv"
#   )
# )

# ## POTW Crosswalks 1-mi ----
# POTW_Crosswlk_1mi <- vroom(
#   here(
#     "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_1mi_Buffer_OUT.csv"
#   )
# )
#
# ## POTW Crosswalks 3-mi ----
# POTW_Crosswlk_3mi <- vroom(
#   here(
#     "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_3mi_Buffer_OUT.csv"
#   )
# )
#
# ## POTW Crosswalks 5-mi ----
# POTW_Crosswlk_5mi <- vroom(
#   here(
#     "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_5mi_Buffer_OUT.csv"
#   )
# )

# Join Demographic Data to Crosswalk Table ----
# ## Block population and Urban/Rural Data ----
blocks_potw_join <-
  merge(
    potw_crosswalk ,
    # PWSID-Census Block Crosswalk Table
    census_blk_pop_data,
    # Census Block Table (which includes the population and additional census block level data fields)
    # by = "blk_fips",
    by.x = "GEOID20",
    by.y = "GEOCODE",
    all.x = TRUE
  ) %>%
  mutate(
    pop_ovlp = replace_na(decimal_overlap, 0) * U7H001,
    # U7H001 is census block population. Calculate the population of each block that overlaps with a POTW buffer area
    housingunit_ovlp = replace_na(decimal_overlap, 0) * U9V001
  ) # U9V001 is total census block housing units. Calculate the housing units in each block that overlaps with a POTW

# Data Check for NAs (NAs would indicate a block ID in the PWS-crosswalk df did not match with a block ID in the census_blk_pop_data dataframe). This should be zero.

sum(is.na(blocks_potw_join$GISJOIN)) # GISJOIN is a field (from the census_blk_pop_date df) that gets added to the blocks_potw df after joining. If this field is NA, then it means that there was no match between the block id in the POTW buffer df and the census block df.

## Block group ACS Data ----
blocks_potw_with_ACS <-
  merge(
    blocks_potw_join[, c(
      "NPDES_ID",
      "BUFF_DIST",
      "buffer_dist",
      "overlap_m2",
      "decimal_overlap",
      "percent_overlap",
      "STATEFP20",
      "blk_fips",
      "bg_fips",
      "trct_fips",
      "U7H001",
      "U9V001",
      "U7I001",# temp total population (for rural/urban)
      "U7I003",# temp total rural population
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

# Data Check for NAs (NAs would indicate a bg IDs in the POTW-crosswalk df did not match with a bg ID the ACS dataset)
sum(is.na(blocks_potw_with_ACS$PCT_POP_U5))

## Tract ACS Data ----
Complete_POTW_Crswlk <-
  merge(
    blocks_potw_with_ACS,
    # subset columns to only necessary fields
    ACS_Trct_Socioeconomic,
    # This df includes the ACS demographic/socioeconomic data
    by.x = "trct_fips",
    by.y = "tract_fips",
    all.x = TRUE
  )

# Data Check for NAs (NAs would indicate a bg IDs in the POTW-crosswalk df did not match with a bg ID the ACS dataset)
sum(is.na(Complete_POTW_Crswlk$LQI))

saveRDS(Complete_POTW_Crswlk,here("R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/Complete_POTW_Crswlk.rds"))


# ### 1-mi Buffer ----
# blocks_potw_join_1mi <-
#   merge(POTW_Crosswlk_1mi, # Census Block Crosswalk Table
#     census_blk_data, # Census Block Table
#     by = "blk_fips",
#     all.x = TRUE
#   ) %>%
#   mutate(
#     pct_ovlp = Area_Overlap_1mi_Buffer_SqKm / Blk_Area_sqkm,
#     pop_ovlp = pct_ovlp * U7H001
#   ) # U7H001 is census block population. Calculate the population of each block that overlaps with a POTW
# 
# # Data Check for NAs (NAs would indicate a block ID in the POTW-crosswalk df did not match with a block ID in the block_pop_race dataframe)
# sum(is.na(blocks_potw_join_1mi$U7H001))
# sum(is.na(blocks_potw_join_1mi$bg_fips))
# 
# ### 3-mi Buffer ----
# blocks_potw_join_3mi <-
#   merge(
#     POTW_Crosswlk_3mi,
#     # Census Block Crosswalk Table
#     census_blk_data,
#     # Census Block Table
#     by = "blk_fips",
#     all.x = TRUE
#   ) %>%
#   mutate(
#     pct_ovlp = Area_Overlap_3mi_Buffer_SqKm / Blk_Area_sqkm,
#     pop_ovlp = pct_ovlp * U7H001
#   ) # U7H001 is census block population. Calculate the population of each block that overlaps with a POTW

# # Data Check for NAs (NAs would indicate a block ID in the POTW-crosswalk df did not match with a block ID in the block_pop_race dataframe)
# sum(is.na(blocks_potw_join_3mi$U7H001))
# sum(is.na(blocks_potw_join_3mi$bg_fips))
# 
# ### 5-mi Buffer ----
# blocks_potw_join_5mi <-
#   merge(
#     POTW_Crosswlk_5mi,
#     # Census Block Crosswalk Table
#     census_blk_data,
#     # Census Block Table
#     by = "blk_fips",
#     all.x = TRUE
#   ) %>%
#   mutate(
#     pct_ovlp = Area_Overlap_5mi_Buffer_SqKm / Blk_Area_sqkm,
#     pop_ovlp = pct_ovlp * U7H001
#   ) # U7H001 is census block population. Calculate the population of each block that overlaps with a POTW
# 
# # Data Check for NAs (NAs would indicate a block ID in the POTW-crosswalk df did not match with a block ID in the block_pop_race dataframe)
# sum(is.na(blocks_potw_join_5mi$U7H001))
# sum(is.na(blocks_potw_join_5mi$bg_fips))
# 
# ## Block group ACS Data ----
# ### 1-mi Buffer ----
# 
# # Join with ACS BG data.
# POTW_with_Demogr_1mi <-
#   merge(
#     blocks_potw_join_1mi[, c(
#       "NPDES_ID",
#       "STATE",
#       "blk_fips",
#       "bg_fips",
#       "U7H001",
#       # "U7L001",
#       "pct_ovlp",
#       "pop_ovlp",
#       "Urban_Rural"
#     )],
#     # subset columns to only necessary fields
#     census_blkgrp_data,
#     # This df includes the ACS demographic/socioeconomic data
#     by = "bg_fips",
#     all.x = TRUE
#   )
# 
# ### 3-mi Buffer ----
# POTW_with_Demogr_3mi <-
#   merge(
#     blocks_potw_join_3mi[, c(
#       "NPDES_ID",
#       "STATE",
#       "blk_fips",
#       "bg_fips",
#       "U7H001",
#       # "U7L001",
#       "pct_ovlp",
#       "pop_ovlp",
#       "Urban_Rural"
#     )],
#     # subset columns to only necessary fields
#     census_blkgrp_data,
#     # This df includes the ACS demographic/socioeconomic data
#     by = "bg_fips",
#     all.x = TRUE
#   )
# 
# ### 5-mi Buffer ----
# POTW_with_Demogr_5mi <-
#   merge(
#     blocks_potw_join_5mi[, c(
#       "NPDES_ID",
#       "STATE",
#       "blk_fips",
#       "bg_fips",
#       "U7H001",
#       # "U7L001",
#       "pct_ovlp",
#       "pop_ovlp",
#       "Urban_Rural"
#     )],
#     # subset columns to only necessary fields
#     census_blkgrp_data,
#     # This df includes the ACS demographic/socioeconomic data
#     by = "bg_fips",
#     all.x = TRUE
#   )
# 
# # Export ----
# # 1mi
# vroom_write(
#   POTW_with_Demogr_1mi,
#   here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_1mi_OUT.csv"),
#   delim = ",",
#   col_names = TRUE
# )
# 
# # 3mi
# vroom_write(
#   POTW_with_Demogr_3mi,
#   here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_3mi_OUT.csv"),
#   delim = ",",
#   col_names = TRUE
# )
# 
# # 5mi
# vroom_write(
#   POTW_with_Demogr_5mi,
#   here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_5mi_OUT.csv"),
#   delim = ",",
#   col_names = TRUE
# )