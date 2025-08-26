library(dplyr)
library(vroom)
library(here)
library(tidyr)
# This script is used to post-process the merged enforcement and compliance data including converting code values to full descriptions, populating blank fields, and add count range fields, and renaming select columns. 

# Import data ----
NPDES_CONSOLIDATED_ENF_COMPL_PREP <- vroom(here("R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/NPDES_CONSOLIDATED_ENF_COMPL.csv"))

FYQTR_NPDES <- Sys.getenv("FYQTR_NPDES")

# Check for blanks and NA Values ----
blank_count <-
  as.matrix(as.character(NPDES_CONSOLIDATED_ENF_COMPL_PREP == ""))

blank_counts <-
  colSums(blank_count == "")

na_count <-
  colSums(is.na(NPDES_CONSOLIDATED_ENF_COMPL_PREP))

summary_df <-
  data.frame(Blank_count = blank_counts, NA_Count = na_count)

print(summary_df)

## Calc SNC column ----
SNC_Calc <- NPDES_CONSOLIDATED_ENF_COMPL_PREP %>%
  mutate(
    SNC_Present = case_when(
      is.na(CWP_SNC_STATUS) ~ "N",
      TRUE ~ "Y"
    )
  )

## Populate blanks ----
### No violations reported ----
VIOL_NOT_REPORT <- "No violations reported"

REPL_WITH_NO_VIOL_REPORTED <- c(
  "EFF_PARAMETER_VIOLATIONS_3YR",       
  "EFF_PARAM_CATEGORIES_3YR",        
  "EFF_PARAMETER_VIOLATIONS_Q12",      
  "EFF_PARAM_CATEGORIES_Q12")

SNC_Calc <- SNC_Calc %>%
  mutate(across(all_of(REPL_WITH_NO_VIOL_REPORTED), ~ replace(., is.na(.), VIOL_NOT_REPORT)))

### Custom value replacements ----
NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS <- SNC_Calc %>%
  mutate(
    MAJOR_MINOR_STATUS_FLAG = case_when(
      is.na(MAJOR_MINOR_STATUS_FLAG) ~ paste("Data Not Available"),
      TRUE ~ as.character(MAJOR_MINOR_STATUS_FLAG)
    ),
    MAJOR_MINOR_STATUS_FLAG = case_when(
      MAJOR_MINOR_STATUS_FLAG == "M" ~ paste("Major"),
      TRUE ~ as.character(MAJOR_MINOR_STATUS_FLAG)
    ),
    MAJOR_MINOR_STATUS_FLAG = case_when(
      MAJOR_MINOR_STATUS_FLAG == "N" ~ paste("Minor"),
      TRUE ~ as.character(MAJOR_MINOR_STATUS_FLAG)
    ),
    FACILITY_TYPE_CODE = case_when(
      is.na(FACILITY_TYPE_CODE) ~ paste("Data Not Reported"),
      TRUE ~ as.character(FACILITY_TYPE_CODE)
    ),
    IMPAIRED_WATERS = case_when(
      IMPAIRED_WATERS == "303(D) Listed" ~ paste("Impaired - TMDL needed"),
      TRUE ~ as.character(IMPAIRED_WATERS)
    ),
    YEARQTR = case_when(
      is.na(YEARQTR) ~ paste(FYQTR_NPDES),
      TRUE ~ as.character(YEARQTR)),
      HLRNC = case_when(
        is.na(HLRNC) ~ paste("No violations reported"),
        TRUE ~ as.character(HLRNC)
      ),
    CWP_SNC_STATUS = case_when(
      is.na(CWP_SNC_STATUS) ~ paste("No Significant Noncompliance present in latest quarter"),
      TRUE ~ as.character(CWP_SNC_STATUS)
    )
  )

### Replace Compliance Status for Current Reporting Period ----
CURRENT_COMPL_STAT_REPLC_VAL <- list(
  "X" = "Effluent - Non-monthly Average Limit",
  "E" = "Effluent - Monthly Average Limit",
  "D" = "Failure to Report DMR - Not Received",
  "W" = "Failure to Report DMR - Not Received",
  "V" = "Non-RNC Violations",
  "N" = "Reportable Noncompliance",
  "U" = "Undetermined",
  "T" = "Compliance/Permit Schedule - Reporting",
  "S" = "Compliance/Permit Schedule - Violations",
  "R" = "Resolved",
  "P" = "Enforcement Action - Resolved Pending",
  "Q" = "Enforcement Action - Resolved Pending"
)

# Replace Values
NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS$HLRNC <- sapply(NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS$HLRNC, function(x) {
  if (x %in% names(CURRENT_COMPL_STAT_REPLC_VAL)) {
    CURRENT_COMPL_STAT_REPLC_VAL[[x]]
  } else {
    x
  }
})

### Facility Type Code Replacement Value ----
FACILITY_TYPE_CODE_REPLACE_VAL <- list(
  "CNG" = "County Government",
  "COR" = "Corporation",
  "CTG" = "Municipality",
  "DIS" = "District",
  "FDF" = "Federal Facility (U.S. Government)",
  "GOC" = "GOCO (Gov Owned/Contractor Operated)",
  "IND" = "Individual",
  "MWD" = "Municipal or Water District",
  "MXO" = "Mixed Ownership (e.g., Public/Private)",
  "NON" = "Non-Government",
  "POF" = "Privately Owned Facility",
  "SDT" = "School District",
  "STF" = "State Government",
  "TRB" = "Tribal Government",
  "UNK" = "Data Not Reported"
)

# Replace Values
NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS$FACILITY_TYPE_CODE <- sapply(NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS$FACILITY_TYPE_CODE, function(x) {
  if (x %in% names(FACILITY_TYPE_CODE_REPLACE_VAL)) {
    FACILITY_TYPE_CODE_REPLACE_VAL[[x]]
  } else {
    x
  }
})

### Populate NA values with 0 ----
replace_val_with_0 <- c(
  "EFF_VIOLATIONS_3YR_COUNT",
  "EFF_VIOLATIONS_COUNT",
  "DMR_3YRS_COUNT",
  "SEV_OPEN_COUNT",
  "SEV_3YRS_COUNT",
  "FORMAL_ENF_ACT_5YR_COUNT", 
  "CWP_QTRS_WITH_SNC")

NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS <- NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS %>%
  mutate(across(all_of(replace_val_with_0), ~ replace_na(., 0)))

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

#0-100+
range_zero_100 <- c("SEV_OPEN_COUNT")
breaks_zero_100  <- c(-Inf, 0, 5, 10, 50, 100, Inf)
labels_zero_100  <- c("(-Inf,0]" = "0",
                      "(0,5]" = "1-5",
                      "(5,10]" = "6-10",
                      "(10,50]" = "11-50",
                      "(50,100]" = "51-100",
                      "(100, Inf]" = ">100")

NPDES_ZERO_HUNDRD <- cut_and_revalue_multiple(NPDES_CONSOLIDATED_ENF_COMPL_PREP_POP_BLNKS, range_zero_100, breaks_zero_100, labels_zero_100)

#0-12
range_zero_12 <- c("DMR_3YRS_COUNT", "EFF_VIOLATIONS_3YR_COUNT", "SEV_3YRS_COUNT","CWP_QTRS_WITH_SNC")
breaks_zero_12  <- c(-Inf, 0, 5, 10, 12)
labels_zero_12  <- c("(-Inf,0]" = "0",
                     "(0,5]" = "1-5",
                     "(5,10]" = "6-10",
                     "(10,12]" = "11-12")

NPDES_ZERO_12 <- cut_and_revalue_multiple(NPDES_ZERO_HUNDRD, range_zero_12, breaks_zero_12, labels_zero_12)

# 0-20+
range_zero_20 <- c("EFF_VIOLATIONS_COUNT")
breaks_zero_20 <- c(-Inf, 0, 5, 10, 20, Inf)
labels_zero_20 <- c("0","1-5","6-10","11-20",">20")

NPDES_ZERO_20 <- cut_and_revalue_multiple(NPDES_ZERO_12, range_zero_20, breaks_zero_20, labels_zero_20)

# 0-15
range_zero_15 <- c("FORMAL_ENF_ACT_5YR_COUNT")
breaks_zero_15 <- c(-Inf, 0, 5, 10, 15, Inf)
labels_zero_15 <- c("(-Inf,0]" = "0",
                    "(0,5]" = "1-5",
                    "(5,10]" = "6-10",
                    "(10,15]" = "11-15",
                    "(15, Inf]" = ">15")

labels_zero_15 <- cut_and_revalue_multiple(NPDES_ZERO_20, range_zero_15, breaks_zero_15, labels_zero_15)

# Check for blanks and NA Values --------------------
blank_count <-
  as.matrix(as.character(labels_zero_15 == ""))

blank_counts <-
  colSums(blank_count == "")

na_count <-
  colSums(is.na(labels_zero_15))

summary_df <-
  data.frame(Blank_count = blank_counts, NA_Count = na_count)

print(summary_df)

# Export ---------------------
write.csv(labels_zero_15, here("R/Wastewater_Analysis/03_Join_Enforc_Compl_Data/02_Post_Processing/NPDES_ENF_COMPL_FINAL_OUT.csv"), row.names = FALSE)

  