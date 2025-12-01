library(dplyr)
library(vroom)
library(here)

# This script is used to post-process the merged enforcement and compliance data including converting code values to full descriptions, populating blank fields, and add count range fields, and renaming select columns. 

# Import compiled enforcement/compliance dataframe to conduct post-processing ---------------

merged_enf_compl_df_import <- vroom(here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/merged_enf_compl_df.csv"))

# Post-processing -----------------

## Populate blanks ----------------
merged_enf_compl_df_import_pop_blnks <- merged_enf_compl_df_import %>%
  mutate(
    SOURCE_WATER_TYPE = case_when(
      (SOURCE_WATER_TYPE == "" | is.na(SOURCE_WATER_TYPE)) ~ paste("Data Not Available"),
      TRUE ~ as.character(SOURCE_WATER_TYPE)
    ),
    OUTSTANDING_PERFORMER = case_when(
      (OUTSTANDING_PERFORMER == "" | is.na(OUTSTANDING_PERFORMER)) ~ paste("Data Not Available"),
      TRUE ~ as.character(OUTSTANDING_PERFORMER)
    ),
    TT_4Log = case_when(
      (TT_4Log == "" | is.na(TT_4Log)) ~ paste("N"),
      TRUE ~ as.character(TT_4Log)
    )
  )

## Sanitary Survey -----------------

# Replace survey result code value to full description

# Populate visit reason code with full description
merged_enf_compl_df_ss_mods <-
  merge(
    merged_enf_compl_df_import_pop_blnks,
    subset(
      vroom(here("Input_Data/SDWIS/SDWA_REF_CODE_VALUES.csv")),
      VALUE_TYPE == "VISIT_REASON_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "VISIT_REASON_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  ) %>% dplyr::select(-c("VISIT_REASON_CODE")) %>% rename("SS_VISIT_TYPE" = "VALUE_DESCRIPTION")

# Columns for replacing values
survey_replacement_val_columns <- c(
  "MANAGEMENT_OPS_EVAL_CODE",
  "SOURCE_WATER_EVAL_CODE"     ,
  "SECURITY_EVAL_CODE",
  "PUMPS_EVAL_CODE"  ,
  "OTHER_EVAL_CODE"  ,
  "COMPLIANCE_EVAL_CODE"  ,
  "DATA_VERIFICATION_EVAL_CODE" ,
  "TREATMENT_EVAL_CODE"     ,
  "FINISHED_WATER_STOR_EVAL_CODE" ,
  "DISTRIBUTION_EVAL_CODE" ,
  "FINANCIAL_EVAL_CODE"
)

# Sanitary survey replacement values
SS_replacement_vals <- list(
  "D" = "Sanitary Defect",
  "M" = "Minor deficiencies",
  "N" = "No deficiencies or recommendations",
  "R" =  "Recommendations made",
  "S" = "Significant deficiencies",
  "X" =  "Not evaluated",
  "Z" =  "Not Applicable"
)

# Function to replace values in specified columns based on a match with the replacement list
replace_values <- function(df, columns, replacement_list) {
  df %>%
    mutate(across(all_of(columns), ~ {
      # Replace values using the replacement list
      sapply(., function(x) ifelse(x %in% names(replacement_list), replacement_list[[x]], x))
    }))
}

# Apply the function to the specified columns
merged_enf_compl_df_ss_mods <- replace_values(merged_enf_compl_df_ss_mods, survey_replacement_val_columns, SS_replacement_vals)

# Replace N/As with "No Survey History Available"
survey_columns <- c(
  "SS_VISIT_TYPE",
  "SS_SIGD_OR_SAND_CAP_YN",
  "SS_SIGD_OR_SAND_INFRA_YN",
  "MANAGEMENT_OPS_EVAL_CODE",
  "SOURCE_WATER_EVAL_CODE"     ,
  "SECURITY_EVAL_CODE",
  "PUMPS_EVAL_CODE"  ,
  "OTHER_EVAL_CODE"  ,
  "COMPLIANCE_EVAL_CODE"  ,
  "DATA_VERIFICATION_EVAL_CODE" ,
  "TREATMENT_EVAL_CODE"     ,
  "FINISHED_WATER_STOR_EVAL_CODE" ,
  "DISTRIBUTION_EVAL_CODE" ,
  "FINANCIAL_EVAL_CODE"
)

SS_replacement_val <-
  "Record Not Available or Not Reported to EPA"

merged_enf_compl_df_ss_mods <- merged_enf_compl_df_ss_mods %>%
  mutate_at(vars(survey_columns),  ~ ifelse(is.na(.) | . =="" , SS_replacement_val, .))

## Populate blank values in violation columns ---------------

### "No HBV Identified" -----------
replace_val_no_hbv <- c("HB_RULES_VIOL_NONRTC","HB_RULES_VIOLATED_5YRS")

merged_enf_compl_df_hbv_mods <- merged_enf_compl_df_ss_mods %>%
  mutate_at(
    vars(replace_val_no_hbv),
    ~ ifelse(is.na(.), "No HBV Identified", .)
  )

### Enforcement Priority System ---------------
merged_enf_compl_df_hbv_mods$ENF_PRIORITY_SYS  <-
  ifelse(
    is.na(merged_enf_compl_df_hbv_mods$ENF_PRIORITY_SYS),
    "N",
    merged_enf_compl_df_hbv_mods$ENF_PRIORITY_SYS 
  )

### Replace N/A with 0  ---------------
cols_replace_NA_w_zero <- c(
  "VIOLATIONS_NON_RTC_COUNT",
  "HBV_NON_RTC_COUNT",
  "HBV_COUNT_QTRS_5YRS",
  "LCR_VIOL_NONRTC_COUNT",
  "LCR_VIOL_COUNT_QTRS_5YRS",
  "MR_VIOL_COUNT_QTRS_5YRS",
  "FEA_VIOL_NONRTC_COUNT",
  "LEAD_SAMPLE_COUNT_5YRS",
  "LEAD_ALE_COUNT_5YRS"
)

merged_enf_compl_df_zerosreplaced <- merged_enf_compl_df_hbv_mods %>%
  mutate_at(
    vars(cols_replace_NA_w_zero),
    ~ ifelse(is.na(.), 0, .)
  )

### Group violation counts into ranges ---------------

# Function to cut numeric columns into specified breaks and revalue the ranges
cut_and_revalue_multiple <- function(df, column_names, breaks, labels) {
  # Iterate over each column name
  for (column_name in column_names) {
    # Ensure the column exists in the data frame
    if (!column_name %in% names(df)) {
      stop("The specified column does not exist in the data frame: ", column_name)
    }
    
    # Create the new column name by appending "_range" to the input column name
    new_column_name <- paste0(column_name, "_RANGE")
    
    # Use mutate to add the new column with cut and revalued ranges
    df <- df %>%
      mutate(!!new_column_name := cut(
        .data[[column_name]], 
        breaks = breaks, 
        labels = labels, 
        include.lowest = TRUE, 
        right = TRUE  # Adjust this if you want the intervals to be right-closed
      ))
  }
  
  return(df)
}

#### Run function -------

# 0-5+
range_zero_five <- c("LEAD_ALE_COUNT_5YRS","LEAD_SAMPLE_COUNT_5YRS")
breaks_zero_five <- c(-Inf, 0, 3, 5, Inf)
labels_zero_five <- c("0","1-3","4-5",">5")

merged_enf_compl_df_zero_five <- cut_and_revalue_multiple(merged_enf_compl_df_zerosreplaced, range_zero_five, breaks_zero_five, labels_zero_five)

# 0-30+
range_zero_thirty <- c("VIOLATIONS_NON_RTC_COUNT")
breaks_zero_thirty <- c(-Inf, 0, 10, 20, 30, Inf)
labels_zero_thirty <- c("0","1-10","11-20","21-30",">30")

merged_enf_compl_df_zero_thirty <- cut_and_revalue_multiple(merged_enf_compl_df_zero_five, range_zero_thirty, breaks_zero_thirty, labels_zero_thirty)

#0-15+
range_zero_fifteen <- c("HBV_NON_RTC_COUNT")
breaks_zero_fifteen <- c(-Inf, 0, 5, 10, 15, Inf)
labels_zero_fifteen <- c("0","1-5","6-10","11-15",">15")

merged_enf_compl_df_zero_fifteen <- cut_and_revalue_multiple(merged_enf_compl_df_zero_thirty, range_zero_fifteen, breaks_zero_fifteen, labels_zero_fifteen)

#0-20
range_zero_twenty <- c("HBV_COUNT_QTRS_5YRS", "LCR_VIOL_COUNT_QTRS_5YRS", "MR_VIOL_COUNT_QTRS_5YRS")
breaks_zero_twenty <- c(-Inf, 0, 5, 10, 15, Inf)
labels_zero_twenty <- c("0","1-5","6-10","11-15","16-20")

merged_enf_compl_df_zero_twenty <- cut_and_revalue_multiple(merged_enf_compl_df_zero_fifteen, range_zero_twenty, breaks_zero_twenty, labels_zero_twenty)

# 0-20+
range_zero_twentyplus <- c("FEA_VIOL_NONRTC_COUNT", "LCR_VIOL_NONRTC_COUNT")
breaks_zero_twentyplus <- c(-Inf, 0, 5, 10, 20, Inf)
labels_zero_twentyplus <- c("0","1-5","6-10","11-20",">20")

merged_enf_compl_df_zero_twentyplus <- cut_and_revalue_multiple(merged_enf_compl_df_zero_twenty, range_zero_twentyplus, breaks_zero_twentyplus, labels_zero_twentyplus)

## Add Lead ALE Y/N Column ----
merged_enf_compl_df_zero_twentyplus <- merged_enf_compl_df_zero_twentyplus %>%
  mutate(
    LEAD_ALE_5YRS_YN = ifelse(
      LEAD_ALE_COUNT_5YRS > 0,
      "Y",
      "N"
    )
  )

## Group LSLI Data ----
library(BAMMtools)

# Calculate Jenks breaks for 3 classes
jenks_breaks_LSL_Cnt <- getJenksBreaks(var = merged_enf_compl_df_zero_twentyplus$LSL_Cnt, k = 4)
jenks_breaks_GRR_Cnt <- getJenksBreaks(var = merged_enf_compl_df_zero_twentyplus$GRR_Cnt, k = 4)
jenks_breaks_Unknown_Cnt <- getJenksBreaks(var = merged_enf_compl_df_zero_twentyplus$Unknown_Cnt, k = 5)
jenks_breaks_NonLead_Cnt <- getJenksBreaks(var = merged_enf_compl_df_zero_twentyplus$Non_Lead_Cnt, k = 5)
jenks_breaks_TotalSL_Cnt <- getJenksBreaks(var = merged_enf_compl_df_zero_twentyplus$Tot_SL, k = 5)

summary(merged_enf_compl_df_zero_twentyplus$LSL_Cnt)
hist(merged_enf_compl_df_zero_twentyplus$LSL_Cnt)
print(jenks_breaks_LSL_Cnt)
#0   8114  39323  80595 150767
breaks_LSL <- c(-Inf, 0, 8000, 60000, Inf)
labels_LSL <- c("0","1-8,000","8,001-60,000",">60,001")

summary(merged_enf_compl_df_zero_twentyplus$GRR_Cnt)
hist(merged_enf_compl_df_zero_twentyplus$GRR_Cnt)
print(jenks_breaks_GRR_Cnt)
#0  58 229 518 997
breaks_grr<- c(-Inf, 0, 60, 200, 500, Inf)
labels_grr <- c("0","1-60","61-200","201-500",">500")

summary(merged_enf_compl_df_zero_twentyplus$Unknown_Cnt)
hist(merged_enf_compl_df_zero_twentyplus$Unknown_Cnt)
print(jenks_breaks_Unknown_Cnt)
#0  18372  94340 258104 436341
breaks_unknown<- c(-Inf, 0, 18000, 94000, 260000, Inf)
labels_unknown <- c("0","1-18,000","18,001-94,000","94,001-260,000",">260,000")

summary(merged_enf_compl_df_zero_twentyplus$Tot_SL)
hist(merged_enf_compl_df_zero_twentyplus$Tot_SL)
print(jenks_breaks_NonLead_Cnt)
#0  20111 111224 299350 744960
breaks_nonlead<- c(-Inf, 0, 20000, 111000, 300000, Inf)
labels_nonlead <- c("0","1-20,000","20,001-111,000","111,001-300,000",">300,000")

summary(merged_enf_compl_df_zero_twentyplus$Unknown_Cnt)
hist(merged_enf_compl_df_zero_twentyplus$Unknown_Cnt)
print(jenks_breaks_TotalSL_Cnt)
#0  23641 126926 336126 820465
breaks_totSL<- c(-Inf, 23000, 127000, 336000, 820000, Inf)
labels_totSL <- c("0","1-23,000","23,001-127,000","127,001-336,000",">336,000")

# Check for blanks and NA Values --------------------
blank_count <-
  as.matrix(as.character(merged_enf_compl_df_zero_twentyplus == ""))

blank_counts <-
  colSums(blank_count == "")

na_count <-
  colSums(is.na(merged_enf_compl_df_zero_twentyplus))

summary_df <-
  data.frame(Blank_count = blank_counts, NA_Count = na_count)

print(summary_df)

# Export ---------------------
write.csv(merged_enf_compl_df_zero_twentyplus, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/merged_enf_compl_df_postprocessing_complete.csv"), row.names = FALSE)

  