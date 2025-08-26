library(vroom)
library(here)
library(dplyr)

# This script conducts final post-processing steps for the weighted demographic data at 1/3/5mi POTW buffers.

# Import data ----

POTW_Weighted_Demog <- vroom(
  here("R/Wastewater_Analysis/04_Demographic_Analysis/POTWs_with_Demo_data_all_radii_OUT.csv")
)

# Formatting ----

# Specify columns for which ranges will be calculated
pct_cols_for_ranges <-
  c(
    "pct_lowinc_1mi",
    "pct_unemply_1mi",
    "pct_hsed_1mi",
    "pct_rural_1mi",
    "pct_lowinc_3mi",
    "pct_unemply_3mi",
    "pct_hsed_3mi",
    "pct_rural_3mi",
    "pct_lowinc_5mi",
    "pct_unemply_5mi",
    "pct_hsed_5mi",
    "pct_rural_5mi"
  )

# Specify data breaks
breaks = c(-Inf, 0, .10, .20, .30, .40, .50, .60, .70, .80, .90, Inf)

# Create data labels
labels <- c(
  "(-Inf,0]" = "0%",
  "(0,0.1]" = "1-10%",
  "(0.1,0.2]" = "11-20%",
  "(0.2,0.3]" = "21-30%",
  "(0.3,0.4]" = "31-40%",
  "(0.4,0.5]" = "41-50%",
  "(0.5,0.6]" = "51-60%",
  "(0.6,0.7]" = "61-70%",
  "(0.7,0.8]" = "71-80%",
  "(0.8,0.9]" = "81-90%",
  "(0.9, Inf]" = ">90%"
)

cut_columns_to_new_labels <-
  function(df, cols_to_cut, breaks, labels, suffix = "_range") {
    #Iterate over specified columns
    for (col in cols_to_cut) {
      #Create new columns
      new_col_name <- paste0(col, suffix)
      #Apply cut function to each column using the common breaks
      df[[new_col_name]] <-
        cut(
          df[[col]],
          breaks = breaks,
          labels = labels,
          include.lowest = TRUE
        )
    }
    return(df)
  }

# Apply the function
POTWs_with_Demog_data_135mi_ranges <-
  cut_columns_to_new_labels(POTW_Weighted_Demog,
                            pct_cols_for_ranges,
                            breaks,
                            labels)

# Convert numb values to a 0-100 scale
# POTW_1_3_5mi_Demog_data <- POTW_1_3_5mi_Demog_data %>%
#   mutate_at(chr_to_num_census_2digits, ~ round(., digits = 3)) %>%
#   mutate(
#     pct_lowinc_5mi =  pct_lowinc_5mi * 100 ,
#     pct_hsed_5mi  = pct_hsed_5mi * 100 ,
#     pct_unemply_5mi = pct_unemply_5mi * 100 ,
#     pct_rural_5mi = pct_rural_5mi * 100,
#     pct_lowinc_3mi = pct_lowinc_3mi * 100 ,
#     pct_hsed_3mi = pct_hsed_3mi * 100 ,
#     pct_unemply_3mi = pct_unemply_3mi * 100,
#     pct_rural_3mi = pct_rural_3mi * 100,
#     pct_lowinc_1mi  = pct_lowinc_1mi * 100 ,
#     pct_hsed_1mi  = pct_hsed_1mi * 100,
#     pct_unemply_1mi = pct_unemply_1mi * 100,
#     pct_rural_1mi = pct_rural_1mi * 100
#   ) %>%
#   mutate_at(
#     chr_to_num_census_2digits,
#     ~ round(as.numeric(.), digits = 3)
#   )

# Final column selection ----
POTWs_with_Demog_data_135mi_ranges <-
  POTWs_with_Demog_data_135mi_ranges %>%
  dplyr::select(
    c(
      "NPDES_ID",
      "STATE",
      "potw_pop_1mi",
      "pop_lowinc_1mi",
      "pct_lowinc_1mi_range",
      "pop_unemply_1mi",
      "pct_unemply_1mi_range",
      "pop_rural_1mi",
      "pct_rural_1mi_range",
      "potw_mhi_1mi",
      "mhi_weighted_1mi",
      "potw_pop_3mi",
      "pop_lowinc_3mi",
      "pct_lowinc_3mi_range",
      "pop_unemply_3mi",
      "pct_unemply_3mi_range",
      "pop_rural_3mi",
      "pct_rural_3mi_range",
      "potw_mhi_3mi",
      "mhi_weighted_3mi",
      "potw_pop_5mi",
      "pop_lowinc_5mi",
      "pct_lowinc_5mi_range",
      "pop_unemply_5mi",
      "pct_unemply_5mi_range",
      "pop_rural_5mi",
      "pct_rural_5mi_range"
    )
  )

# Export Data ----
currentDate <- as.character(Sys.Date())
currentDate <- str_replace_all(currentDate, "-", "_")

csvFileName <-
  paste(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Cleaned_Demographic_data_",
    currentDate,
    "_FINAL_OUTPUT.csv",
    sep = ""
  )

vroom_write(
  POTWs_with_Demog_data_135mi_ranges,
  here(csvFileName),
  delim = ",",
  col_names = TRUE
)