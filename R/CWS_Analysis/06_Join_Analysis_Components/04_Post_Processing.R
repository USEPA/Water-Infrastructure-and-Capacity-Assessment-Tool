library(vroom)
library(dplyr)
library(here)
library(sf)
library(tigris)
library(stringr)

# This script performs final cleaning operations prior to .shp export
# Import data ----
# Import combined CWS dataset (with geometries)
final_CWS_dataset_with_DWSRF <- st_read(here("R/CWS_Analysis/06_Join_Analysis_Components/final_CWS_dataset_with_DWSRF.gpkg")) 

# Final cleaning operations ----

## Add "Region" to Region Column ----
final_CWS_dataset_with_DWSRF$EPA_REGION <-
  paste("Region",
        final_CWS_dataset_with_DWSRF$EPA_REGION)

## Finalize Columns ----

# Make all columns uppercase, excluding the geometry column
names(final_CWS_dataset_with_DWSRF) <- ifelse(
  names(final_CWS_dataset_with_DWSRF) == attr(final_CWS_dataset_with_DWSRF, "sf_column"),
  attr(final_CWS_dataset_with_DWSRF, "sf_column"),
  toupper(names(final_CWS_dataset_with_DWSRF))
)

final_CWS_dataset_with_DWSRF_final_cols <- 
  dplyr::select(
    final_CWS_dataset_with_DWSRF,
    c(
      "PWS_NAME",
      "PWSID",
      "REGISTRY_ID",
      "EPA_REGION",
      "ZIP_CODE_SERVED", #previous ZIP_CODE_SERVED_SDWIS
      "CITY_SERVED", #previous CITY_SERVED_SDWIS
      "COUNTY_SERVED", #previous COUNTY_SERVED_SDWIS
      "TRIBAL_NAME", #previous TRIBE_SERVED_SDWIS
      "TRIBAL_CODE",
      "ANSI_ENTITY_CODE", #new
      "PRIMACY_TYPE",
      "PRIMACY_AGENCY",
      "PWS_TYPE",
      "OWNER_TYPE",
      "IS_SCHOOL_OR_DAYCARE_IND",
      "IS_WHOLESALER_IND",
      "SOURCE_WATER_TYPE" ,
      "POPULATION_SERVED_COUNT",
      "POPULATION_CATEGORY_SERVED",
      "SERVICE_CONNECTIONS_COUNT",
      "SUBMISSIONYEARQUARTER",
      "VIOLATIONS_NON_RTC_COUNT",
      "VIOLATIONS_NON_RTC_COUNT_RANGE",
      "HBV_NON_RTC_COUNT",
      "HBV_NON_RTC_COUNT_RANGE",
      "HB_RULES_VIOL_NONRTC",
      "HBV_COUNT_QTRS_5YRS" ,
      "HBV_COUNT_QTRS_5YRS_RANGE",
      "HB_RULES_VIOLATED_5YRS",
      "LCR_VIOL_NONRTC_COUNT",
      "LCR_VIOL_NONRTC_COUNT_RANGE" ,
      "LCR_VIOL_COUNT_QTRS_5YRS",
      "LCR_VIOL_COUNT_QTRS_5YRS_RANGE",
      "MR_VIOL_COUNT_QTRS_5YRS",
      "MR_VIOL_COUNT_QTRS_5YRS_RANGE", #previous MR_VIOL_COUNT_QTRS_RANGE
      "FEA_VIOL_NONRTC_COUNT",
      "FEA_VIOL_NONRTC_COUNT_RANGE", #previous EA_VIOL_NONRTC_COUNT_RANGE
      "LEAD_ALE_5YRS_YN",
      "LEAD_ALE_COUNT_5YRS",
      "LEAD_ALE_COUNT_5YRS_RANGE" ,
      "LEAD_SAMPLE_COUNT_5YRS",
      "LEAD_SAMPLE_COUNT_5YRS_RANGE",
      "ENF_PRIORITY_SYS",
      "OUTSTANDING_PERFORMER",
      "OUTSTANDING_PERFORM_BEGIN_DATE",
      "TT_4LOG", 
      "VISIT_DATE",
      "SS_SURVEY_OVERDUE",
      "SS_VISIT_TYPE", 
      "SS_SIGD_OR_SAND_INFRA_YN",
      "SS_SIGD_OR_SAND_CAP_YN",
      "MANAGEMENT_OPS_EVAL_CODE",
      "SOURCE_WATER_EVAL_CODE",
      "SECURITY_EVAL_CODE",
      "PUMPS_EVAL_CODE",
      "OTHER_EVAL_CODE",
      "COMPLIANCE_EVAL_CODE",
      "DATA_VERIFICATION_EVAL_CODE" ,
      "TREATMENT_EVAL_CODE",
      "FINISHED_WATER_STOR_EVAL_CODE",
      "DISTRIBUTION_EVAL_CODE",
      "FINANCIAL_EVAL_CODE",
      "DISADVANTAGED_ASSISTANCE", 
      "DWSRF_AWARDS_10YRS_COUNT",
      "DWSRF_AWARDS_10YRS_COUNT_RANGE",
      "PWS_MHI_WEIGHT",
      "PCT_LOWINC",
      "PCT_RURAL" ,
      "PCT_UNEMPLY"  ,
      "PCT_LOWINC_RANGE",
      "PCT_RURAL_RANGE",
      "PCT_UNEMPLY_RANGE",
      "DFR_URL",
      "geom" #previous geometry
    )
  ) %>%
  rename(
    "COMP_PERIOD_BEGIN_FYQTR" = "SUBMISSIONYEARQUARTER"  ,
    "TRMT_4LOG_OR_GREATER" = "TT_4LOG",
    "WHOLESALER" = "IS_WHOLESALER_IND",
    "SCHOOL_OR_DAYCARE" = "IS_SCHOOL_OR_DAYCARE_IND",
    "SS_OUTSTAND_PERFORM" = "OUTSTANDING_PERFORMER", 
    "SS_OUTSTAND_PERFORM_BEGIN_DATE" = "OUTSTANDING_PERFORM_BEGIN_DATE", #previously SS_OUTST_PERFORM_BEGIN_DATE
    "SS_DATE_MOST_RECENT" = "VISIT_DATE",
    "TRIBE_SERVED" = "TRIBAL_NAME", #previous TRIBE_SERVED_SDWIS,
    "BIA_TRIBE_CODE" = "TRIBAL_CODE",
    "STATE_DWSRF_DAC" = "DISADVANTAGED_ASSISTANCE" #previously DISADVANTAGED_ASSISTANCE
  ) %>% mutate(
    REGISTRY_ID = as.numeric(REGISTRY_ID), # Ensure REGISTRY_ID is character
  )

##  Check for blanks and NA values ----
blank_count <-
  as.matrix(as.character(final_CWS_dataset_with_DWSRF_final_cols == ""))

blank_counts <-
  colSums(blank_count == "")

na_count <-
  colSums(is.na(final_CWS_dataset_with_DWSRF_final_cols))

summary_df <-
  data.frame(Blank_count = blank_counts, NA_Count = na_count)

View(summary_df)

## Populate blank/NA cells ----

#Populate locational fields with Not Applicable
final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs <-
  final_CWS_dataset_with_DWSRF_final_cols %>%
  mutate(
    ZIP_CODE_SERVED= case_when( 
      (is.na(ZIP_CODE_SERVED))  ~ paste("Data not available"),
      TRUE ~  as.character(ZIP_CODE_SERVED)
    ),
    CITY_SERVED = case_when( 
      (is.na(CITY_SERVED))  ~ paste("Data not available"),
      TRUE ~  as.character(CITY_SERVED)
    ),
    COUNTY_SERVED = case_when( 
      (is.na(COUNTY_SERVED))  ~ paste("Data not available"),
      TRUE ~  as.character(COUNTY_SERVED)
    ),
    TRIBE_SERVED = case_when( 
      (is.na(TRIBE_SERVED) & PRIMACY_TYPE == "TRIBAL")  ~ paste("Data not available"),
      TRUE ~  as.character(TRIBE_SERVED)
    ),
    TRIBE_SERVED = case_when( 
      (is.na(TRIBE_SERVED) & PRIMACY_TYPE != "TRIBAL")  ~ paste("Data not applicable"),
      TRUE ~  as.character(TRIBE_SERVED)
    ),
    BIA_TRIBE_CODE = case_when( 
      (is.na(BIA_TRIBE_CODE) & PRIMACY_TYPE == "TRIBAL")  ~ paste("Data not available"),
      TRUE ~  as.character(BIA_TRIBE_CODE)
    ),
    BIA_TRIBE_CODE = case_when( 
      (is.na(BIA_TRIBE_CODE) & PRIMACY_TYPE != "TRIBAL")  ~ paste("Data not applicable"),
      TRUE ~  as.character(BIA_TRIBE_CODE)
    ),
    ANSI_ENTITY_CODE = case_when( 
      (is.na(ANSI_ENTITY_CODE))  ~ paste("Data not available"),
      TRUE ~  as.character(ANSI_ENTITY_CODE)
    ),
    REGISTRY_ID= case_when( 
      (is.na(REGISTRY_ID))  ~ paste("Data Not Available"),
      TRUE ~  as.character(REGISTRY_ID)
    ),
    ZIP_CODE_SERVED = case_when( 
      (ZIP_CODE_SERVED <= "9999")  ~ paste("0",ZIP_CODE_SERVED, sep =""),
      TRUE ~  as.character(ZIP_CODE_SERVED) #Add a zero in front of zip-codes that had a dropped leading zero
    ),
    PCT_LOWINC_RANGE= case_when( 
      (is.na(PCT_LOWINC_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_LOWINC_RANGE)
    ),
    PCT_RURAL_RANGE= case_when( 
      (is.na(PCT_RURAL_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_RURAL_RANGE)
    ),
    PCT_UNEMPLY_RANGE= case_when( 
      (is.na(PCT_UNEMPLY_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_UNEMPLY_RANGE)
    )
)

# Check for blanks/NAs
blank_count <-
  as.matrix(as.character(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs == ""))

blank_counts <-
  colSums(blank_count == "")

na_count <-
  colSums(is.na(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs))

summary_df <-
  data.frame(Blank_count = blank_counts, NA_Count = na_count)

View(summary_df)

# Export ----
## With geometry ----
currentDate <- as.character(Sys.Date())
currentDate <- str_replace_all(currentDate, "-", "_")

# Export data based on feature class type

# Identify unique feature classes
geom_types <- unique(st_geometry_type(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs))

#Separate sf based on feature classes
for (i in seq_along(geom_types)) {
  GEOM_TYPE <- geom_types[i]
  subset_sf <-
    final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs[st_geometry_type(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs) == GEOM_TYPE,]
  assign(paste0("CWS_Shape_Export", GEOM_TYPE),
         final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs[st_geometry_type(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs) == GEOM_TYPE,])
}

#Write individual sf based on feature class

# Export table of PWS not mapped
CWS_NotMapped <-
  st_drop_geometry(CWS_Shape_ExportGEOMETRYCOLLECTION) 

write.csv(CWS_NotMapped, here(
  paste0(
    "Final_Exports_for_App\\Drinking_Water_Files\\",
    "PWS_Polygons_NotMapped_",
    currentDate,
    ".csv"
  )
))

# Export Polygons
st_write(
  CWS_Shape_ExportMULTIPOLYGON, here(
  paste0(
    "Final_Exports_for_App\\Drinking_Water_Files\\",
    "PWS_Polygons_",
    currentDate,
    ".gpkg"
  )),
  append = FALSE
)

# Export Points
st_write(
  CWS_Shape_ExportPOINT,
  here(paste0("Final_Exports_for_App\\Drinking_Water_Files\\",
    "PWS_Pts_",
    currentDate,
    ".gpkg"
  )),
  append = FALSE
)

## Without Geometry ----

PWS_Complete_Table <- st_drop_geometry(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs)

write.csv(PWS_Complete_Table, here(
  paste0(
    "Final_Exports_for_App\\Drinking_Water_Files\\",
    "PWS_Complete_Table_",
    currentDate,
    ".csv"
  )
))



