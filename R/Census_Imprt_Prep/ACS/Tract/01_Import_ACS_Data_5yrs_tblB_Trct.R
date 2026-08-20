# This script imports 5-year American Community Survey data directly from IPUMS, NHGIS (https://www.nhgis.org/)
# Instructions for importing from NHGIS: https://assets.ipums.org/_files/webinars/slides/nhgis03-05-24.pdf

# The following tables are going to be extracted
# B19080: Household Income Quintile Upper Limits

# Load Libraries ----
library(ipumsr)
library(dplyr)
library(here)

# Search metadata
nhgis_ds <- get_metadata_catalog("nhgis", "datasets")

nhgis_ds %>%
  filter(group == "2024 American Community Survey") %>%
  select(name, description)

# View detailed metadata
ds_meta <- get_metadata_nhgis(dataset = "2020_2024_ACS5b")

str(ds_meta, 1)

# Define extract request ----
nhgis_ext <- define_extract_nhgis(
  description = "5-Year Data [2020-2024, Block Groups & Larger Areas]",
  datasets = ds_spec(
    "2020_2024_ACS5b",
    data_tables = c(
     "B19080"
    ),
    geog_levels = "tract"
  )
)

# Verify extract
nhgis_ext

# Submit extract request ----
nhgis_ext <- submit_extract(nhgis_ext)

nhgis_ext <- wait_for_extract(nhgis_ext)

# Write an extract to the ACS folder ----
nhgis_files <- download_extract(nhgis_ext, here("Input_Data/Census/ACS/ACS_TblB_Trct"))

basename(nhgis_files) # View file name

# Read in files ----
nhgis_data <- read_nhgis(nhgis_files)

# Export ----
write.csv(nhgis_data,
  here("Input_Data/Census/ACS/ACS_TblB_Trct/ACS_2020_2024b_trct.csv"),
  row.names = FALSE)
