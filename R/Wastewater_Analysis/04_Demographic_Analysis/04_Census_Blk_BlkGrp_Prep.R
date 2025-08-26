#library(tidyverse)
#library(data.table)
library(here)
library(vroom)
library(dplyr)

# This script preps census block and block group demographic data

# Import Data ----

## 2020 Census Block Population and Rural/Urban ----

# Import the Dicennial 2020 Census Block population count, housing, and rural/urban designation data. Census block population data is obtained from NHGIS. The population data and block geographies reflect the 2020 Census.

# Year:             2020
# Geographic level: Block (by State--County--Census Tract)
# Extent:           All areas
# Dataset:          2020 Census: DHC - P & H Tables [Blocks & Larger Areas]
# NHGIS code:    2020_DHCa
# NHGIS ID:      ds258
# Breakdown(s):     Geographic Component:
#   Total area (00)
# 
# Tables:
#   
#   1. Total Population
# Universe:    Total population
# Source code: P1
# NHGIS code:  U7H
# 
# 2. Urban and Rural
# Universe:    Total population
# Source code: P2
# NHGIS code:  U7I
# 
# 3. Housing Units
# Universe:    Housing units
# Source code: H1
# NHGIS code:  U9V


# Import census block population data and create block fips field
census_blk_pop_data <-
  vroom(
    here(
      "Input_Data/Census/Blk-Data/nhgis0034_csv/nhgis0034_ds258_2020_block.csv"
    )
  ) %>%
  mutate(
    blk_fips =
      paste0(
        substr(.$GISJOIN, 2, 3),
        substr(.$GISJOIN, 5, 7),
        substr(.$GISJOIN, 9, 18) #Use GISJOIN to create a census block FIPS code column
      ),
    bg_fips =
      paste0(substr(.$GISJOIN, 2, 3),
             substr(.$GISJOIN, 5, 7),
             substr(.$GISJOIN, 9, 15)), #Use GISJOIN to create a census block group FIPS code column
    Urban_Rural = case_when((URA == "R")  ~ 1, TRUE ~ 0)
    #Convert Rural/Urban to 0/1 for later calculation of population weighted data
  ) 

## 2019-2023 ACS Block Group Socioeconomic Data ----

# Year:             2019-2023
# Geographic level: Block Group (by State--County--Census Tract)
# Extent:           All areas
# Dataset:          2023 American Community Survey: 5-Year Data [2019-2023, Block Groups & Larger Areas]
# NHGIS code:    2019_2023_ACS5a
# NHGIS ID:      ds267
# Breakdown(s):     Geographic Component:
#   Total area (00)
# Data type(s):     (E) Estimates
# (M) Margins of error

# Tables:
#   
#   1. Total Population
# Universe:    Total population
# Source code: B01003
# NHGIS code:  ASN1
# 
# 2. Educational Attainment for the Population 25 Years and Over
# Universe:    Population 25 years and over
# Source code: B15003
# NHGIS code:  ASP3
# 
# 3. Ratio of Income to Poverty Level in the Past 12 Months
# Universe:    Population for whom poverty status is determined
# Source code: C17002
# NHGIS code:  ASQI
# 
# 4. Median Household Income in the Past 12 Months (in 2023 Inflation-Adjusted Dollars)
# Universe:    Households
# Source code: B19013
# NHGIS code:  ASQP
# 
# 5. Employment Status for the Population 16 Years and Over
# Universe:    Population 16 years and over
# Source code: B23025
# NHGIS code:  ASSR
# 
# 6. Housing Units
# Universe:    Housing units
# Source code: B25001
# NHGIS code:  ASS7

ACS_BG_Socioeconomic <-
  vroom(
    here(
      "Input_Data/Census/Blk-Grp-Data/nhgis0032_csv/nhgis0032_ds267_20235_blck_grp.csv" )
  ) %>%
  mutate(
    bg_fips =
      paste0(
        substr(.$GISJOIN, 2, 3),
        substr(.$GISJOIN, 5, 7),
        substr(.$GISJOIN, 9, 15) #Use GISJOIN to create a census block group FIPS code column
      ),
    LESSTHANHSPCT = (
      ASP3E002 + ASP3E003 + ASP3E004 + ASP3E005 + ASP3E006 + ASP3E007 + ASP3E008 +
        ASP3E009 + ASP3E010 + ASP3E011 + ASP3E012 + ASP3E013 + ASP3E014 + ASP3E015 +
        ASP3E016
    ) / ASP3E001,
    ,
    # Percent of people 25 years and over with less than a high school education (ASP3E002 - No schooling completed through ASP3E016 (12th Grade, No diploma))
    LOWINCPCT = (ASQIE001 - ASQIE008) / ASQIE001 ,
    #Percent of Population Low Income (Households whose income is less than or equal to 2x the federal poverty level)
    UNEMPLYMNTPCT = ASSRE005 / ASSRE003 #Percent of Population 16 years and over unemployed (civilian labor force only)
  ) %>%
  dplyr::select(
    .,
    c(
      "bg_fips",
      "STATE",
      "STUSAB",
      "ASN1E001",
      "LESSTHANHSPCT",
      "LOWINCPCT",
      "UNEMPLYMNTPCT",
      "ASQPE001"
    )
  ) %>%
  dplyr::rename(bg_pop = ASN1E001,
                MHI = ASQPE001)

# Export Data ----
vroom_write(
  census_blk_pop_data,
  here("R/Wastewater_Analysis/04_Demographic_Analysis/census_blk_pop_data_OUT.csv"), delim = ","
)

vroom_write(
  ACS_BG_Socioeconomic,
  here("R/Wastewater_Analysis/04_Demographic_Analysis/census_blkgrp_OUT.csv"), delim = ","
)