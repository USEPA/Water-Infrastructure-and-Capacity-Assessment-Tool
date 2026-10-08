# This script conducts final post-processing steps for the weighted demographic data at 1/3/5mi POTW buffers.

# Clear environment
rm(list = ls())

library(dplyr)
# library(vroom)
library(here)

options(scipen = 999) # turns off scientific notation

# Import data ----

POTW_Weighted_Demog <-
  #   vroom(
  #   here("R/Wastewater_Analysis/04_Demographic_Analysis/POTWs_with_Demo_data_all_radii_OUT.csv")
  # )
  readRDS(here("R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/POTW_with_demogr_data.rds"))


# Formatting ----

# Specify columns for which ranges will be calculated
pct_cols_for_ranges <-
  c(
    "pct_lowinc",
    "pct_unemply",
    "pct_rural",
    "pct_U5",
    "pct_U18",
    "pct_62plus",
    "pct_HU_rntr",
    "pct_MFHU"
  )

# Specify data breaks
breaks <- c(-Inf, 0, .10, .20, .30, .40, .50, .60, .70, .80, .90, Inf)

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
    # Iterate over specified columns
    for (col in cols_to_cut) {
      # Create new columns
      new_col_name <- paste0(col, suffix)
      # Apply cut function to each column using the common breaks
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
POTW_Weighted_Demog_with_range <-
  cut_columns_to_new_labels(
    POTW_Weighted_Demog,
    pct_cols_for_ranges,
    breaks,
    labels
  )

# Convert numb values to a 0-100 scale
POTW_calcd_pct <- POTW_Weighted_Demog_with_range %>%
  mutate(
    pct_lowinc = pct_lowinc * 100,
    pct_unemply = pct_unemply * 100,
    pct_rural = pct_rural * 100,
    pct_U5 = pct_U5 * 100,
    pct_U18 = pct_U18 * 100,
    pct_62plus = pct_62plus * 100,
    pct_HU_rntr = pct_HU_rntr * 100,
    pct_MFHU = pct_MFHU * 100
  ) %>%
  mutate_at(
    pct_cols_for_ranges,
    ~ round(., digits = 2)
  )

# Final column selection ----
POTW_cols_selected <-
  POTW_calcd_pct %>%
  dplyr::select(
    c(
      "buffer_dist",
      "NPDES_ID",
      "POTW_mhi_weighted",
      "POTW_LQI_weighted",
      "pct_lowinc",
      "pct_unemply",
      "pct_rural",
      "pct_U5",
      "pct_U18",
      "pct_62plus",
      "pct_HU_rntr",
      "pct_MFHU",
      "pct_lowinc_range",
      "pct_unemply_range",
      "pct_rural_range",
      "pct_U5_range",
      "pct_U18_range",
      "pct_62plus_range",
      "pct_HU_rntr_range",
      "pct_MFHU_range"
    )
  )

# Export Data ----
saveRDS(POTW_cols_selected, here("R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/POTW_cols_selected.rds"))
