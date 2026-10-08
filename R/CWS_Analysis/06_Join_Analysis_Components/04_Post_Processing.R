# This script performs final cleaning operations prior to .shp export

# Clear environment
rm(list = ls())

library(vroom)
library(dplyr)
library(here)
library(sf)
library(tigris)
library(stringr)

# Import data ----
# Import combined CWS dataset (with geometries)
final_CWS_dataset_with_DWSRF <- readRDS(here("R/CWS_Analysis/06_Join_Analysis_Components/Temp_Outputs/final_CWS_dataset_with_DWSRF.rds"))
  # st_read(here("R/CWS_Analysis/06_Join_Analysis_Components/final_CWS_dataset_with_DWSRF.gpkg")) 

# Final cleaning operations ----

## Remove paragraph before DFR URL ----
final_CWS_dataset_with_DWSRF$DFR_URL <- gsub("^\\n", "", final_CWS_dataset_with_DWSRF$DFR_URL)

## Set POSIXct date class ----
final_CWS_dataset_with_DWSRF <- final_CWS_dataset_with_DWSRF %>%
  mutate(
    OUTSTANDING_PERFORM_BEGIN_DATE =  as.POSIXct.Date(final_CWS_dataset_with_DWSRF$OUTSTANDING_PERFORM_BEGIN_DATE, tz = "UTC"),
    VISIT_DATE = as.POSIXct.Date(final_CWS_dataset_with_DWSRF$VISIT_DATE, tz = "UTC")
     )

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
      "ZIP_CODE_SERVED", 
      "CITY_SERVED", 
      "COUNTY_SERVED", 
      "TRIBAL_NAME",
      "TRIBAL_CODE",
      "ANSI_ENTITY_CODE",
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
      "MR_VIOL_COUNT_QTRS_5YRS_RANGE", 
      "FEA_VIOL_NONRTC_COUNT",
      "FEA_VIOL_NONRTC_COUNT_RANGE", 
      "LEAD_ALE_5YRS_YN",
      "LEAD_ALE_COUNT_5YRS",
      "LEAD_ALE_COUNT_5YRS_RANGE" ,
      "LEAD_SAMPLE_COUNT_5YRS",
      "LEAD_SAMPLE_COUNT_5YRS_RANGE",
      "SL_RPT_STATUS", 
      "NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL",
      "NUM_LEAD_SERVICE_LINES", 
      "NUM_LEAD_STATUS_UNKNOWN_SL", 
      "NUM_NONLEAD_SERVICE_LINES", 
      "TOTAL_NUM_SERVICE_LINES_REPORTED", 
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
      "PWS_LQI_WEIGHT",  #New Aug2026
      "PCT_LOWINC",
      "PCT_RURAL" ,
      "PCT_UNEMPLY"  ,      
      "PCT_U5",#New Aug2026
      "PCT_U18",#New Aug2026
      "PCT_62PLUS",#New Aug2026
      "PCT_HU_RNTR",#New Aug2026
      "PCT_MFHU" ,#New Aug2026
      "PCT_LOWINC_RANGE",
      "PCT_RURAL_RANGE",
      "PCT_UNEMPLY_RANGE", 
      "PCT_U5_RANGE",  #New Aug2026                         
      "PCT_U18_RANGE" ,#New Aug2026                         
      "PCT_62PLUS_RANGE" ,#New Aug2026                      
      "PCT_HU_RNTR_RANGE" ,#New Aug2026
      "PCT_MFHU_RANGE", #New Aug2026
      "DFR_URL"
      #,
      #"geom" #removed Aug2026
    )
  ) %>%
  rename(
    "COMP_PERIOD_BEGIN_FYQTR" = "SUBMISSIONYEARQUARTER"  ,
    "TRMT_4LOG_OR_GREATER" = "TT_4LOG",
    "WHOLESALER" = "IS_WHOLESALER_IND",
    "SCHOOL_OR_DAYCARE" = "IS_SCHOOL_OR_DAYCARE_IND",
    "SS_OUTSTAND_PERFORM" = "OUTSTANDING_PERFORMER", 
    "SS_OUTSTAND_PERFORM_BEGIN_DATE" = "OUTSTANDING_PERFORM_BEGIN_DATE", 
    "SS_DATE_MOST_RECENT" = "VISIT_DATE",
    "TRIBE_SERVED" = "TRIBAL_NAME", 
    "BIA_TRIBE_CODE" = "TRIBAL_CODE",
    "STATE_DWSRF_DAC" = "DISADVANTAGED_ASSISTANCE"
  )

##  Check for blanks and NA values ----
# blank_count <-
#   as.matrix(as.character(final_CWS_dataset_with_DWSRF_final_cols == ""))
# 
# blank_counts <-
#   colSums(blank_count == "")
# 
# na_count <-
#   colSums(is.na(final_CWS_dataset_with_DWSRF_final_cols))
# 
# summary_df <-
#   data.frame(Blank_count = blank_counts, NA_Count = na_count)
# 
# View(summary_df)

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
    ),
    PCT_U5_RANGE= case_when( 
      (is.na(PCT_U5_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_U5_RANGE)
    ),
    PCT_U18_RANGE= case_when( 
      (is.na(PCT_U18_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_U18_RANGE)
    ),
    PCT_62PLUS_RANGE= case_when( 
      (is.na(PCT_62PLUS_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_62PLUS_RANGE)
    ),
    PCT_HU_RNTR_RANGE= case_when( 
      (is.na(PCT_HU_RNTR_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_HU_RNTR_RANGE)
    )    ,
    PCT_MFHU_RANGE= case_when( 
      (is.na(PCT_MFHU_RANGE))  ~ paste("Data Not Available"),
      TRUE ~  as.character(PCT_MFHU_RANGE)
    )
)

# Check for blanks/NAs
# blank_count <-
#   as.matrix(as.character(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs == ""))
# 
# blank_counts <-
#   colSums(blank_count == "")
# 
# na_count <-
#   colSums(is.na(final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs))
# 
# summary_df <-
#   data.frame(Blank_count = blank_counts, NA_Count = na_count)
# 
# View(summary_df)

# Specify Number of Digits for all Numeric Values
final_CWS_dataset_set_digits <- final_CWS_dataset_with_DWSRF_final_cols_populate_blanks_NAs %>%
  mutate(
    POPULATION_SERVED_COUNT = round(as.numeric(POPULATION_SERVED_COUNT), 0),
    SERVICE_CONNECTIONS_COUNT = round(as.numeric(SERVICE_CONNECTIONS_COUNT), 0),
    PWS_MHI_WEIGHT = round(as.numeric(PWS_MHI_WEIGHT), 0),
    PWS_LQI_WEIGHT = round(as.numeric(PWS_LQI_WEIGHT), 0),
    PCT_LOWINC = round(as.numeric(PCT_LOWINC), 1),
    PCT_RURAL = round(as.numeric(PCT_RURAL), 1),
    PCT_UNEMPLY = round(as.numeric(PCT_UNEMPLY), 1),
    PCT_U5 = round(as.numeric(PCT_U5), 1),
    PCT_U18 = round(as.numeric(PCT_U18), 1),
    PCT_62PLUS = round(as.numeric(PCT_62PLUS), 1),
    PCT_HU_RNTR = round(as.numeric(PCT_HU_RNTR), 1),
    PCT_MFHU = round(as.numeric(PCT_MFHU), 1),
    LEAD_ALE_COUNT_5YRS = round(as.numeric(LEAD_ALE_COUNT_5YRS), 0),
    LEAD_SAMPLE_COUNT_5YRS = round(as.numeric(LEAD_SAMPLE_COUNT_5YRS), 0),
  NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL = round(as.numeric(NUM_GALVANIZED_REQUIRING_REPLACEMENT_SL), 0),
  NUM_LEAD_SERVICE_LINES = round(as.numeric(NUM_LEAD_SERVICE_LINES), 0),
  NUM_LEAD_STATUS_UNKNOWN_SL = round(as.numeric(NUM_LEAD_STATUS_UNKNOWN_SL), 0),
  NUM_NONLEAD_SERVICE_LINES = round(as.numeric(NUM_NONLEAD_SERVICE_LINES), 0),
  TOTAL_NUM_SERVICE_LINES_REPORTED = round(as.numeric(TOTAL_NUM_SERVICE_LINES_REPORTED), 0),
  VIOLATIONS_NON_RTC_COUNT = round(as.numeric(VIOLATIONS_NON_RTC_COUNT), 0),
  HBV_NON_RTC_COUNT = round(as.numeric(HBV_NON_RTC_COUNT), 0),
  LCR_VIOL_NONRTC_COUNT = round(as.numeric(LCR_VIOL_NONRTC_COUNT), 0),
  FEA_VIOL_NONRTC_COUNT= round(as.numeric(FEA_VIOL_NONRTC_COUNT), 0),
  HBV_COUNT_QTRS_5YRS = round(as.numeric(HBV_COUNT_QTRS_5YRS), 0),
  LCR_VIOL_COUNT_QTRS_5YRS = round(as.numeric(LCR_VIOL_COUNT_QTRS_5YRS), 0),
  MR_VIOL_COUNT_QTRS_5YRS = round(as.numeric(MR_VIOL_COUNT_QTRS_5YRS), 0),
  DWSRF_AWARDS_10YRS_COUNT = round(as.numeric(DWSRF_AWARDS_10YRS_COUNT), 0)
  )

# Export ----
## With geometry ----
currentDate <- as.character(Sys.Date())
currentDate <- str_replace_all(currentDate, "-", "_")

# Export data based on feature class type

# Identify unique feature classes
geom_types <- unique(st_geometry_type(final_CWS_dataset_set_digits))

#Separate sf based on feature classes
for (i in seq_along(geom_types)) {
  GEOM_TYPE <- geom_types[i]
  subset_sf <-
    final_CWS_dataset_set_digits[st_geometry_type(final_CWS_dataset_set_digits) == GEOM_TYPE,]
  assign(paste0("CWS_Shape_Export", GEOM_TYPE),
         final_CWS_dataset_set_digits[st_geometry_type(final_CWS_dataset_set_digits) == GEOM_TYPE,])
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
CWS_Shape_ExportGEOMETRYCOLLECTION <- st_cast(CWS_Shape_ExportGEOMETRYCOLLECTION, "MULTIPOLYGON")

st_write(
rbind(CWS_Shape_ExportGEOMETRYCOLLECTION,CWS_Shape_ExportPOLYGON),
  here(
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

PWS_Complete_Table <- st_drop_geometry(final_CWS_dataset_set_digits)

write.csv(PWS_Complete_Table, here(
  paste0(
    "Final_Exports_for_App\\Drinking_Water_Files\\",
    "PWS_Complete_Table_",
    currentDate,
    ".csv"
  )
))
