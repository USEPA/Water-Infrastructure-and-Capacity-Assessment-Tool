library(vroom)
library(dplyr)
library(here)
library(sf)
library(tigris)
library(stringr)
library(readxl)

# This script performs final cleaning operations prior to final export

# Import data ----
NPDES_CENSUS <- vroom(here("R/Wastewater_Analysis/05_Join_Analysis_Components/NPDES_CENSUS_OUT.csv"))

#State-Region Lookup Table
State_Region_lookup <-
  read_xlsx(here("Input_Data/Locational/State_Region_Lookup/State_Region_Lookup.xlsx"))

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
      "STATE_CODE" ,
      "ZIP",
      "FAC_INDIAN_CNTRY_FLG",
      "FAC_US_MEX_BORDER_FLG",
      "FAC_CHESAPEAKE_BAY_FLG",
      "YEARQTR",
      "HLRNC",
      "CWP_SNC_STATUS",               # NEW
      "CWP_QTRS_WITH_SNC",            # NEW
      #"SNC_Present",               #REMOVE
      "CWP_QTRS_WITH_SNC_RANGE",      # NEW
      "FORMAL_ENF_ACT_5YR_COUNT" ,
      "FORMAL_ENF_ACT_5YR_COUNT_RANGE" , 
      "EFF_VIOLATIONS_COUNT" ,
      "EFF_VIOLATIONS_COUNT_RANGE" , 
      "EFF_PARAMETER_VIOLATIONS_Q12",
      "EFF_PARAM_CATEGORIES_Q12" ,
      "SEV_OPEN_COUNT" ,
      "SEV_OPEN_COUNT_RANGE" , 
      "EFF_VIOLATIONS_3YR_COUNT" ,
      "EFF_VIOLATIONS_3YR_COUNT_RANGE" , 
      "EFF_PARAMETER_VIOLATIONS_3YR"      ,
      "EFF_PARAM_CATEGORIES_3YR"  ,
      "DMR_3YRS_COUNT" ,
      "DMR_3YRS_COUNT_RANGE" , 
      "EFF_VIOLATIONS_3YR_COUNT" ,
      "EFF_VIOLATIONS_3YR_COUNT_RANGE" , 
      "EFF_PARAMETER_VIOLATIONS_3YR"      ,
      "SEV_3YRS_COUNT",
      "SEV_3YRS_COUNT_RANGE" , 
      "STATE_WATER_BODY" ,
      "STATE_WATER_BODY_NAME"  ,
      "CWSRF_Hardship_Community",
      "CWSRF_AWARDS_10YRS_COUNT",
      "CWSRF_AWARDS_10YRS_COUNT_RANGE", 
      "mhi_weighted_1mi", 
      "pct_lowinc_1mi",
      "pct_unemply_1mi" ,
      "pct_rural_1mi",
      "mhi_weighted_3mi", 
      "pct_lowinc_3mi" ,
      "pct_unemply_3mi" ,
      "pct_rural_3mi",
      "mhi_weighted_5mi", 
      "pct_lowinc_5mi",
      "pct_unemply_5mi" ,
      "pct_rural_5mi",
      "pct_lowinc_1mi_range",
      "pct_unemply_1mi_range" ,
      "pct_rural_1mi_range",
      "pct_lowinc_3mi_range" ,
      "pct_unemply_3mi_range" ,
      "pct_rural_3mi_range" ,
      "pct_lowinc_5mi_range",
      "pct_unemply_5mi_range" ,
      "pct_rural_5mi_range" ,
      "DFR_URL",
      "GEOCODE_LATITUDE",
      "GEOCODE_LONGITUDE"
    )
  ) %>%
  rename(
    "CURRENT_RP_FY_QTR" = "YEARQTR",
    "COMPL_STATUS_CURRENT_RP" = "HLRNC",
    "FRS_ID" = "FACILITY_UIN",
    "STATE_WATER_BODY_CODE"   = "STATE_WATER_BODY",
    "PERMIT_COMPONENT_TYPES" = "PERM_COMPONENT_TYPES",
    "ZIPCODE" = "ZIP",
    "MAJOR_OR_MINOR_FACILITY" = "MAJOR_MINOR_STATUS_FLAG",
    "LONGITUDE" = "GEOCODE_LONGITUDE" ,
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
  mutate_at(vars(columns_to_na),
            ~ ifelse(. == "" | is.na(.), replacement_value, .)) 

# Replace blanks and NULL fields with "Undetermined" in specified columns  ----
replacement_val <-
  "Undetermined"

Undetermined_Val_Replace <- c(
  "PCT_LOWINC_1MI_RANGE",
  "PCT_UNEMPLY_1MI_RANGE",
  "PCT_RURAL_1MI_RANGE",
  "PCT_LOWINC_3MI_RANGE",
  "PCT_UNEMPLY_3MI_RANGE",
  "PCT_RURAL_3MI_RANGE",
  "PCT_LOWINC_5MI_RANGE",
  "PCT_UNEMPLY_5MI_RANGE",
  "PCT_RURAL_5MI_RANGE"
)

NPDES_CENSUS_CLEAN2 <-
  NPDES_CENSUS_CLEAN2 %>%
  mutate_at(vars(Undetermined_Val_Replace),
            ~ ifelse(. == "" | is.na(.), replacement_val, .)) 

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

NPDES_CENSUS_CLEAN2 <-
  NPDES_CENSUS_CLEAN2 %>%
  mutate_at(vars(Data_Not_Avail_Val_Replace),
            ~ ifelse(. == "" | is.na(.), replacement_val_data_not_avail, .)) 

# Check for blanks and NA Values --------------------
blank_count <-
  as.matrix(as.character(NPDES_CENSUS_CLEAN2 == ""))

blank_counts <-
  colSums(blank_count == "")

na_count <-
  colSums(is.na(NPDES_CENSUS_CLEAN2))

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

NPDES_CENSUS_CLEAN2 <-
  NPDES_CENSUS_CLEAN2 %>%
  mutate(CURRENT_RP_FY_QTR = sapply(CURRENT_RP_FY_QTR, reformat_number))

# Convert FRS ID to Character Field
NPDES_CENSUS_CLEAN2 <-
  NPDES_CENSUS_CLEAN2 %>%
  mutate(FRS_ID = as.character(FRS_ID))

# Export
# Excel Export
currentDate <- as.character(Sys.Date())
currentDate <- str_replace_all(currentDate, "-", "_")

# All Facilities
all_fac_excelFileName <-
  paste(
    "Final_Exports_for_App/Wastewater_Files/POTW_Export_",
    currentDate,
    ".csv",
    sep = ""
  )

vroom_write(NPDES_CENSUS_CLEAN2,
  here(all_fac_excelFileName),
  delim = ","
)

# Point Layer Export
# Convert long/lat to a point layer
library(sf)

# Remove NPDES IDs without Long/Lat data
NPDES_CENSUS_CLEAN2_FOR_SHP <-
  NPDES_CENSUS_CLEAN2 %>% filter(LONGITUDE != "")

NPDES_CENSUS_CLEAN2_FOR_SHP <-
  st_as_sf(
    NPDES_CENSUS_CLEAN2_FOR_SHP,
    coords = c("LONGITUDE", "LATITUDE"),
    crs = 4326
  )

#Transform layer
NPDES_CENSUS_CLEAN2_FOR_SHP <-
  st_transform(
    NPDES_CENSUS_CLEAN2_FOR_SHP,
    4326
  )

# Final Export
all_fac_gdbFileName <-
  paste(
    "Final_Exports_for_App/Wastewater_Files/POTW_Export_",
    currentDate,
    ".gpkg",
    sep = ""
  )

st_write(
  NPDES_CENSUS_CLEAN2_FOR_SHP,
  all_fac_gdbFileName,
  append = FALSE
)
