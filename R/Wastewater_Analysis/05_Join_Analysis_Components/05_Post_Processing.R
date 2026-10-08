# This script performs final cleaning operations prior to final export

# Clear environment
rm(list = ls())

library(here)
library(dplyr)
library(sf)
library(tigris)
library(stringr)
library(readxl)
library(tidyr)
library(vroom)

# Import data ----
NPDES_CENSUS <- # vroom(here("R/Wastewater_Analysis/05_Join_Analysis_Components/NPDES_CENSUS_OUT.csv"))
  readRDS(here("R/Wastewater_Analysis/05_Join_Analysis_Components/Temp_Outputs/NPDES_CENSUS_OUT.rds"))

# State-Region Lookup Table
State_Region_lookup <-
  read_xlsx(here("R/Wastewater_Analysis/01_Import_Data/State_Region_Lookup/State_Region_Lookup.xlsx"))

# Merge State Column with Region Name  ----
NPDES_CENSUS_CLEAN1 <-
  merge(
    NPDES_CENSUS,
    State_Region_lookup,
    by.x = "STATE_CODE",
    by.y = "State_Abbreviation",
    all.x = TRUE
  )

# Subset and Reorder Columns  ----

NPDES_CENSUS_CLEAN2 <-
  dplyr::select(
    NPDES_CENSUS_CLEAN1,
    c(
      "EPA_Region",
      "STATE_CODE",
      "FACILITY_NAME",
      "NPDES_ID",
      "FACILITY_UIN",
      "PERM_COMPONENT_TYPES",
      "FACILITY_TYPE_CODE",
      "LAGOON_AS_PRIMARY_TREATMENT",
      "LAGOON_SOURCE_DATA",
      "COMBINED_SEWER_SYSTEM",
      "MAJOR_MINOR_STATUS_FLAG",
      "CITY",
      "COUNTY_CODE",
      "STATE_CODE",
      "ZIP",
      "FAC_INDIAN_CNTRY_FLG",
      "FAC_US_MEX_BORDER_FLG",
      "FAC_CHESAPEAKE_BAY_FLG",
      "YEARQTR",
      "HLRNC",
      "CWP_SNC_STATUS",
      "CWP_QTRS_WITH_SNC",
      "CWP_QTRS_WITH_SNC_RANGE",
      "FORMAL_ENF_ACT_5YR_COUNT",
      "FORMAL_ENF_ACT_5YR_COUNT_RANGE",
      "EFF_VIOLATIONS_COUNT",
      "EFF_VIOLATIONS_COUNT_RANGE",
      "EFF_PARAMETER_VIOLATIONS_Q12",
      "EFF_PARAM_CATEGORIES_Q12",
      "SEV_OPEN_COUNT",
      "SEV_OPEN_COUNT_RANGE",
      "EFF_VIOLATIONS_3YR_COUNT",
      "EFF_VIOLATIONS_3YR_COUNT_RANGE",
      "EFF_PARAMETER_VIOLATIONS_3YR",
      "EFF_PARAM_CATEGORIES_3YR",
      "DMR_3YRS_COUNT",
      "DMR_3YRS_COUNT_RANGE",
      "EFF_VIOLATIONS_3YR_COUNT",
      "EFF_VIOLATIONS_3YR_COUNT_RANGE",
      "EFF_PARAMETER_VIOLATIONS_3YR",
      "SEV_3YRS_COUNT",
      "SEV_3YRS_COUNT_RANGE",
      "STATE_WATER_BODY",
      "STATE_WATER_BODY_NAME",
      "CWSRF_Hardship_Community",
      "CWSRF_AWARDS_10YRS_COUNT",
      "CWSRF_AWARDS_10YRS_COUNT_RANGE",
      
      "buffer_dist",
      
      "pct_lowinc",
      "pct_unemply",
      "pct_rural",
      "pct_U5",# new 8/31/2026
      "pct_U18",# new 8/31/2026
      "pct_62plus",# new 8/31/2026
      "pct_HU_rntr",# new 8/31/2026
      "pct_MFHU",# new 8/31/2026
      "POTW_mhi_weighted",
      "POTW_LQI_weighted",# new 8/31/2026
      "pct_lowinc_range",
      "pct_unemply_range",
      "pct_rural_range",
      "pct_U5_range",# new 8/31/2026
      "pct_U18_range",# new 8/31/2026
      "pct_62plus_range",# new 8/31/2026
      "pct_HU_rntr_range",# new 8/31/2026
      "pct_MFHU_range",# new 8/31/2026

      "DFR_URL",
      "GEOCODE_LATITUDE",
      "GEOCODE_LONGITUDE"
    )
  ) %>%
  rename(
    "CURRENT_RP_FY_QTR" = "YEARQTR",
    "COMPL_STATUS_CURRENT_RP" = "HLRNC",
    "FRS_ID" = "FACILITY_UIN",
    "STATE_WATER_BODY_CODE" = "STATE_WATER_BODY",
    "PERMIT_COMPONENT_TYPES" = "PERM_COMPONENT_TYPES",
    "ZIPCODE" = "ZIP",
    "MAJOR_OR_MINOR_FACILITY" = "MAJOR_MINOR_STATUS_FLAG",
    "LONGITUDE" = "GEOCODE_LONGITUDE",
    "LATITUDE" = "GEOCODE_LATITUDE",
    "EPA_REGION" = "EPA_Region"
  )

# Make Column Names Uppercase  ----
names(NPDES_CENSUS_CLEAN2) <-
  toupper(names(NPDES_CENSUS_CLEAN2))

# Fill in Blanks (where relevant)  ----
replacement_value <- "N/A"

# Specify columns to replace blanks or NULL fields with N/As
columns_to_na <-
  c(
    "LAGOON_SOURCE_DATA",
    "EFF_PARAMETER_VIOLATIONS_Q12",
    "EFF_PARAM_CATEGORIES_Q12",
    "EFF_PARAMETER_VIOLATIONS_3YR",
    "EFF_PARAM_CATEGORIES_3YR"
  )

# Replace blanks and NULL fields with N/A in specified columns
NPDES_CENSUS_CLEAN2 <-
  NPDES_CENSUS_CLEAN2 %>%
  mutate_at(
    vars(columns_to_na),
    ~ ifelse(. == "" | is.na(.), replacement_value, .)
  )

# Replace blanks and NULL fields with "Undetermined" in specified columns  ----
replacement_val <-
  "Undetermined"

Undetermined_Val_Replace <- c(
  "PCT_LOWINC_RANGE",
  "PCT_UNEMPLY_RANGE",
  "PCT_RURAL_RANGE",
  "PCT_U5_RANGE", # new 8/31/2026
  "PCT_U18_RANGE", # new 8/31/2026
  "PCT_62PLUS_RANGE", # new 8/31/2026
  "PCT_HU_RNTR_RANGE", # new 8/31/2026
  "PCT_MFHU_RANGE" # new 8/31/2026
)

NPDES_CENSUS_CLEANUnd <-
  NPDES_CENSUS_CLEAN2 %>%
  mutate(
    across(
      all_of(Undetermined_Val_Replace),
      ~ {
        if (is.factor(.x)) {
          x <- as.character(.x)
          x[x == "" | is.na(x)] <- replacement_val
          factor(x)
        } else {
          if_else(.x == "" | is.na(.x), replacement_val, as.character(.x))
        }
      }
    )
  )

# Replace blanks and NULL fields with "Data not available" in specified columns  ----
replacement_val_data_not_avail <-
  "Data not available"

Data_Not_Avail_Val_Replace <- c(
  "COUNTY_CODE",
  "FAC_INDIAN_CNTRY_FLG",
  "FAC_US_MEX_BORDER_FLG",
  "FAC_CHESAPEAKE_BAY_FLG",
  "STATE_WATER_BODY_CODE",
  "STATE_WATER_BODY_NAME"
)

NPDES_CENSUS_CLEANDataNotAvail <-
  NPDES_CENSUS_CLEANUnd %>%
  mutate_at(
    vars(Data_Not_Avail_Val_Replace),
    ~ ifelse(. == "" | is.na(.), replacement_val_data_not_avail, .)
  )

# Check for blanks and NA Values ----
blank_count <-
  as.matrix(as.character(NPDES_CENSUS_CLEANDataNotAvail == ""))

blank_counts <-
  colSums(blank_count == "")

na_count <-
  colSums(is.na(NPDES_CENSUS_CLEANDataNotAvail))

summary_df <-
  data.frame(Blank_count = blank_counts, NA_Count = na_count)

print(summary_df)

# Reformat FY QTR Field
reformat_number <- function(character) {
  year <- substr(character, 1, 4)
  quarter <- substr(character, 5, 5)
  formatted <- paste0("FY", year, " Q", quarter)
  return(formatted)
}

NPDES_CENSUS_CLEANfrmt<-
  NPDES_CENSUS_CLEANDataNotAvail %>%
  mutate(CURRENT_RP_FY_QTR = sapply(CURRENT_RP_FY_QTR, reformat_number))

# Convert FRS ID to Character Field
NPDES_CENSUS_CLEANfrs <-
  NPDES_CENSUS_CLEANfrmt %>%
  mutate(FRS_ID = as.character(FRS_ID))

# Restructure df ----
# base columns that should stay once per facility
base_cols <- c(
  "EPA_REGION",
  "STATE_CODE",
  "FACILITY_NAME",
  "NPDES_ID",
  "FRS_ID",
  "PERMIT_COMPONENT_TYPES",
  "FACILITY_TYPE_CODE",
  "LAGOON_AS_PRIMARY_TREATMENT",
  "LAGOON_SOURCE_DATA",
  "COMBINED_SEWER_SYSTEM",
  "MAJOR_OR_MINOR_FACILITY",
  "CITY",
  "COUNTY_CODE",
  "ZIPCODE",
  "FAC_INDIAN_CNTRY_FLG",
  "FAC_US_MEX_BORDER_FLG",
  "FAC_CHESAPEAKE_BAY_FLG",
  "CURRENT_RP_FY_QTR",
  "COMPL_STATUS_CURRENT_RP",
  "CWP_SNC_STATUS",
  "CWP_QTRS_WITH_SNC",
  "CWP_QTRS_WITH_SNC_RANGE",
  "FORMAL_ENF_ACT_5YR_COUNT",
  "FORMAL_ENF_ACT_5YR_COUNT_RANGE",
  "EFF_VIOLATIONS_COUNT",
  "EFF_VIOLATIONS_COUNT_RANGE",
  "EFF_PARAMETER_VIOLATIONS_Q12",
  "EFF_PARAM_CATEGORIES_Q12",
  "SEV_OPEN_COUNT",
  "SEV_OPEN_COUNT_RANGE",
  "EFF_VIOLATIONS_3YR_COUNT",
  "EFF_VIOLATIONS_3YR_COUNT_RANGE",
  "EFF_PARAMETER_VIOLATIONS_3YR",
  "EFF_PARAM_CATEGORIES_3YR",
  "DMR_3YRS_COUNT",
  "DMR_3YRS_COUNT_RANGE",
  "SEV_3YRS_COUNT",
  "SEV_3YRS_COUNT_RANGE",
  "STATE_WATER_BODY_CODE",
  "STATE_WATER_BODY_NAME",
  "CWSRF_HARDSHIP_COMMUNITY",
  "CWSRF_AWARDS_10YRS_COUNT",
  "CWSRF_AWARDS_10YRS_COUNT_RANGE",
  "DFR_URL",
  "LONGITUDE",
  "LATITUDE"
  #"geometry"
)

# columns to spread across BUFFER_DIST
census_cols <- c(
  "POTW_MHI_WEIGHTED" ,              
  "POTW_LQI_WEIGHTED" ,
  "PCT_LOWINC",
  "PCT_UNEMPLY",
  "PCT_RURAL",
  "PCT_U5",
  "PCT_U18",
  "PCT_62PLUS",
  "PCT_HU_RNTR",
  "PCT_MFHU",
  "PCT_LOWINC_RANGE",
  "PCT_UNEMPLY_RANGE",
  "PCT_RURAL_RANGE",
  "PCT_U5_RANGE",
  "PCT_U18_RANGE",
  "PCT_62PLUS_RANGE",
  "PCT_HU_RNTR_RANGE",
  "PCT_MFHU_RANGE"
)

# make names lower-case to match your desired output style
POTW_sf_refrmt <- NPDES_CENSUS_CLEANfrs %>%
  filter(!is.na(BUFFER_DIST)) %>%
  select(all_of(c(base_cols, "BUFFER_DIST", census_cols))) %>%
  mutate(BUFFER_DIST = as.character(BUFFER_DIST)) %>%
  pivot_wider(
    id_cols = all_of(base_cols),
    names_from = BUFFER_DIST,
    values_from = all_of(census_cols),
    names_glue = "{tolower(.value)}_{BUFFER_DIST}"
  )

# rename *_range_* to *_<buffer>_range 
POTW_sf_refrmt <- POTW_sf_refrmt %>%
  rename_with(
    ~ sub("_(1mi|3mi|5mi)_range$", "_\\1_range", .x),
    matches("^pct_.*_(1mi|3mi|5mi)_range$")
  )

names(POTW_sf_refrmt)<-toupper(names(POTW_sf_refrmt))

# Convert long/lat to a point layer ----
# Remove NPDES IDs without Long/Lat data
POTW_sf_refrmt_shp <-
  POTW_sf_refrmt %>% filter(LONGITUDE != "")

POTW_sf_refrmt_shp <-
  st_as_sf(
    POTW_sf_refrmt_shp,
    coords = c("LONGITUDE", "LATITUDE"),
    crs = 4326
  )

# Export ----

currentDate <- as.character(Sys.Date())
currentDate <- str_replace_all(currentDate, "-", "_")

## Sf Final Export ----
all_fac_gdbFileName <-
  paste(
    "Final_Exports_for_App/Wastewater_Files/Wastewater_Export_",
    currentDate,
    ".gpkg",
    sep = ""
  )

st_write(
  POTW_sf_refrmt_shp,
  all_fac_gdbFileName,
  append = FALSE
)

## Excel Export ----
all_fac_excelFileName <-
  paste(
    "Final_Exports_for_App/Wastewater_Files/Wastewater_Export_",
    currentDate,
    ".csv",
    sep = ""
  )

vroom_write(st_drop_geometry(POTW_sf_refrmt_shp),
  here(all_fac_excelFileName),
  delim = ","
)
