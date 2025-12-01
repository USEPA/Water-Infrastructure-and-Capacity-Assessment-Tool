library(dplyr)
library(vroom)
library(here)
library(stringr)
library(data.table)
options(scipen = 999)

# This script imports census block and block group data and the PWS crosswalk table. It then joins the PWS-Crosswalk table with census block population data and ACS demographic data to calculate population-weighted averages for various demographic fields.

# Import data ----

## Demographic Data ----

### 2020 Census Block Population and Rural/Urban ----
# Import the Dicennial 2020 Census Block population count, housing, and rural/urban designation data. Census block population data is obtained from NHGIS. The population data and block geographies reflect the 2020 Census.

# Year:             2020
# Geographic level: Block (by State--County--Census Tract)
# Extent:           All areas
# Dataset:          2020 Census: DHC - P & H Tables [Blocks & Larger Areas]
# NHGIS code:    2020_DHCa
# NHGIS ID:      ds258
# Breakdown(s):     Geographic Component:
#   Total area (00)

# Tables:

#   1. Total Population
# Universe:    Total population
# Source code: P1
# NHGIS code:  U7H

# 2. Urban and Rural
# Universe:    Total population
# Source code: P2
# NHGIS code:  U7I

# 3. Housing Units
# Universe:    Housing units
# Source code: H1
# NHGIS code:  U9V

# Import census block population data and create block fips field
census_blk_pop_data <-
  fread(
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
    Urban_Rural = case_when((URA == "R")  ~ 1, TRUE ~ 0)
    # Convert Rural/Urban to 0/1 for later calculation of population weighted data
  ) 

### 2019-2023 ACS Block Group Socioeconomic Data ----

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
      "Input_Data/Census/Blk-Grp-Data/nhgis0032_csv/nhgis0032_ds267_20235_blck_grp.csv"
    )
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

## Community Water System Service Area Crosswalk Table ----

# Import the Community Water System Service Area Crosswalk Table from github. This file is a crosswalk between PWSID and all intersecting census blocks. This is the central table that will be used to calculate building weighted averages for the various demographic data. This PWS-Census Block crosswalk table was obtained from USEPA's Office of Research and Development. The service area boundary source data and technical documentation can be found here: https://gispub.epa.gov/serviceareas (note this technical documentation does not include discussion of the crosswalk table, just the development of the boundaries themselves).

blocks_pws <- read.csv("https://media.githubusercontent.com/media/USEPA/ORD_SAB_Model/refs/heads/main/Version_History/2_0/Census_Tables/Blocks_V_2_0.csv")

# blocks_pws <-
#   vroom(
#     here(
#       "Input_Data/Census/PWS-Crosswalk/All_Blocks_1DOT2.csv")
#   ) %>%
#   mutate(
#     blk_fips =
#       paste0(
#         substr(.$GISJOIN, 2, 3),
#         substr(.$GISJOIN, 5, 7),
#         substr(.$GISJOIN, 9, 18) #Create block FIPS code column
#       ),
#     bg_fips =
#       paste0(
#         substr(.$GISJOIN, 2, 3),
#         substr(.$GISJOIN, 5, 7),
#         substr(.$GISJOIN, 9, 15) #Create block group FIPS code column
#       )
#   )

# Join Demographic Data to Crosswalk Table ----
## Block population and Urban/Rural Data ----

# Join census block population dataframe to crosswalk table. 
blocks_pws_join <-
  merge(blocks_pws,
        #PWSID-Census Block Crosswalk Table
        census_blk_pop_data,
        #Census Block Table (which includes the population and additional census block level data fields)
        # by = "blk_fips",
        by.x = "GEOID20", by.y = "GEOCODE",
        all.x = TRUE) %>%
  mutate(pop_ovlp = Bldg_Weight * U7H001,
         #U7H001 is census block population. Calculate the population of each block that overlaps with a PWS
         housingunit_ovlp = Bldg_Weight * U9V001) #U9V001 is total census block housing units. Calculate the housing units in each block that overlaps with a PWS

# Data Check for NAs (NAs would indicate a block ID in the PWS-crosswalk df did not match with a block ID in the census_blk_pop_data dataframe). This should be zero.
sum(is.na(blocks_pws_join$U7H001))

## Block group ACS Data ----

# Join with ACS BG data. 
blocks_pws_join_blkgrp_add <- blocks_pws_join %>%
    mutate(
      bg_fips =
        paste0(
          substr(.$blk_fips , 1, 12)
        )
    )

blocks_pws_with_ACS <-
  merge(blocks_pws_join_blkgrp_add[, c(
    "PWSID",
    "STATE",
    "blk_fips",
    "bg_fips",
    "U7H001",
    "U9V001",
    "U7I001", # temp total population (for rural/urban)
    "U7I003", # temp total rural population
    "Bldg_Weight",
    "pop_ovlp",
    "housingunit_ovlp",
    "Urban_Rural"
  )],
  # subset columns to only necessary fields
  ACS_BG_Socioeconomic,
  # This df includes the ACS demographic/socioeconomic data
  by = "bg_fips",
  all.x = TRUE) 

# Data Check for NAs (NAs would indicate a bg IDs in the PWS-crosswalk df did not match with a bg ID the ACS dataset)
sum(is.na(blocks_pws_with_ACS$UNEMPLYMNTPCT))
sum(is.na(blocks_pws_with_ACS$LESSTHANHSPCT))
missing_vals_blkgrp <- filter(blocks_pws_with_ACS, is.na(bg_pop))

# Export ----
write.csv(
  blocks_pws_with_ACS,
  here("R/CWS_Analysis/05_Demographic_Analysis/PWS_with_Census.csv"),
  row.names = FALSE
)
