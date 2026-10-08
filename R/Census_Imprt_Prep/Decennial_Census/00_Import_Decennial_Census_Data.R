# This script imports decennial data directly from IPUMS, NHGIS (https://www.nhgis.org/)

# Clear environment
rm(list = ls())

# Instructions for importing from NHGIS: https://assets.ipums.org/_files/webinars/slides/nhgis03-05-24.pdf
# The following tables are going to be extracted

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


# Load Libraries ----
library(ipumsr)
library(dplyr)
library(here)

# Search metadata
nhgis_ds <- get_metadata_nhgis("datasets")

nhgis_ds %>%
  filter(group == "2020 Decennial Census") %>%
  select(name, description)

# View detailed metadata
ds_meta <- get_metadata_nhgis(dataset = "2020_DHCa")

str(ds_meta, 1)

# Define extract request ----
nhgis_ext <- define_extract_nhgis(
  description = "DHC - P & H Tables [Blocks & Larger Areas]",
  datasets = ds_spec(
    "2020_DHCa",
    data_tables = c("P1", "P2", "H1"),
    geog_levels = "block"
  )
)

# Verify extract
nhgis_ext

# Submit extract request ----
nhgis_ext <- submit_extract(nhgis_ext)

nhgis_ext <- wait_for_extract(nhgis_ext)

# Write an extract to the Decennial Census folder ----
nhgis_files <- download_extract(nhgis_ext, #here(
  #"Input_Data/Census/ACS"
  here("R/Census_Imprt_Prep/Decennial_Census/Temp_Outputs")
)

basename(nhgis_files) # View file name

# Read in files ----
nhgis_data <- read_nhgis(nhgis_files)

# Export ----
saveRDS(nhgis_data,here("R/Census_Imprt_Prep/Decennial_Census/Temp_Outputs/2020_DHCa_blk.rds"))