library(vroom)
library(here)
library(dplyr)

# This script joins 1,3,5-mi buffer POTW-Blk crosswalks with census block and block group census data

# Import data ----
## Census ----
# Census Block Data
census_blk_data <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/census_blk_pop_data_OUT.csv"
  )
)

# Census Block Group Data
census_blkgrp_data <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/census_blkgrp_OUT.csv"
  )
)

## POTW Crosswalks ----
# 1-mi
POTW_Crosswlk_1mi <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_1mi_Buffer_OUT.csv"
  )
)
# 3-mi
POTW_Crosswlk_3mi <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_3mi_Buffer_OUT.csv"
  )
)
# 5-mi
POTW_Crosswlk_5mi <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_Blk_Crosswalk_5mi_Buffer_OUT.csv"
  )
)

# Join Demographic Data to Crosswalk Table ----
## Block population and Urban/Rural Data ----
### 1-mi Buffer ----
blocks_potw_join_1mi <-
  merge(POTW_Crosswlk_1mi, # Census Block Crosswalk Table
        census_blk_data, # Census Block Table
        by = "blk_fips",
        all.x = TRUE) %>%
  mutate(pct_ovlp = Area_Overlap_1mi_Buffer_SqKm / Blk_Area_sqkm,
         pop_ovlp = pct_ovlp * U7H001) # U7H001 is census block population. Calculate the population of each block that overlaps with a POTW

# Data Check for NAs (NAs would indicate a block ID in the POTW-crosswalk df did not match with a block ID in the block_pop_race dataframe)
sum(is.na(blocks_potw_join_1mi$U7H001))
sum(is.na(blocks_potw_join_1mi$bg_fips))

### 3-mi Buffer ----
blocks_potw_join_3mi <-
  merge(
    POTW_Crosswlk_3mi,
    # Census Block Crosswalk Table
    census_blk_data,
    # Census Block Table
    by = "blk_fips",
    all.x = TRUE
  ) %>%
  mutate(pct_ovlp = Area_Overlap_3mi_Buffer_SqKm / Blk_Area_sqkm,
         pop_ovlp = pct_ovlp * U7H001) # U7H001 is census block population. Calculate the population of each block that overlaps with a POTW

# Data Check for NAs (NAs would indicate a block ID in the POTW-crosswalk df did not match with a block ID in the block_pop_race dataframe)
sum(is.na(blocks_potw_join_3mi$U7H001))
sum(is.na(blocks_potw_join_3mi$bg_fips))

### 5-mi Buffer ----
blocks_potw_join_5mi <-
  merge(
    POTW_Crosswlk_5mi,
    # Census Block Crosswalk Table
    census_blk_data,
    # Census Block Table
    by = "blk_fips",
    all.x = TRUE
  ) %>%
  mutate(pct_ovlp = Area_Overlap_5mi_Buffer_SqKm / Blk_Area_sqkm,
         pop_ovlp = pct_ovlp * U7H001) # U7H001 is census block population. Calculate the population of each block that overlaps with a POTW

# Data Check for NAs (NAs would indicate a block ID in the POTW-crosswalk df did not match with a block ID in the block_pop_race dataframe)
sum(is.na(blocks_potw_join_5mi$U7H001))
sum(is.na(blocks_potw_join_5mi$bg_fips))

## Block group ACS Data ----
### 1-mi Buffer ----

#Join with ACS BG data. 
POTW_with_Demogr_1mi <-
  merge(blocks_potw_join_1mi[, c(
    "NPDES_ID",
    "STATE",
    "blk_fips",
    "bg_fips",
    "U7H001",
    #"U7L001",
    "pct_ovlp",
    "pop_ovlp",
    "Urban_Rural"
  )],
  # subset columns to only necessary fields
  census_blkgrp_data,
  # This df includes the ACS demographic/socioeconomic data
  by = "bg_fips",
  all.x = TRUE) 

### 3-mi Buffer ----
POTW_with_Demogr_3mi <-
  merge(blocks_potw_join_3mi[, c(
    "NPDES_ID",
    "STATE",
    "blk_fips",
    "bg_fips",
    "U7H001",
    #"U7L001",
    "pct_ovlp",
    "pop_ovlp",
    "Urban_Rural"
  )],
  # subset columns to only necessary fields
  census_blkgrp_data,
  # This df includes the ACS demographic/socioeconomic data
  by = "bg_fips",
  all.x = TRUE) 

### 5-mi Buffer ----
POTW_with_Demogr_5mi <-
  merge(blocks_potw_join_5mi[, c(
    "NPDES_ID",
    "STATE",
    "blk_fips",
    "bg_fips",
    "U7H001",
    #"U7L001",
    "pct_ovlp",
    "pop_ovlp",
    "Urban_Rural"
  )],
  # subset columns to only necessary fields
  census_blkgrp_data,
  # This df includes the ACS demographic/socioeconomic data
  by = "bg_fips",
  all.x = TRUE) 

# Export ----
# 1mi
vroom_write(
  POTW_with_Demogr_1mi,
  here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_1mi_OUT.csv"),
  delim = ",",
  col_names = TRUE
)

# 3mi
vroom_write(
  POTW_with_Demogr_3mi,
  here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_3mi_OUT.csv"),
  delim = ",",
  col_names = TRUE
)

# 5mi
vroom_write(
  POTW_with_Demogr_5mi,
  here("R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_5mi_OUT.csv"),
  delim = ",",
  col_names = TRUE
)