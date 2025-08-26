library(dplyr)
library(vroom)
library(here)

# This script calculates percent and percent range fields.

# Import data ----------
PWS_Weighted_Outputs <- vroom(here("R/CWS_Analysis/05_Demographic_Analysis/PWS_Weighted_Demog_Data.csv"))

# Specify columns for which ranges will be calculated
pct_cols <-
  c(
    "pct_lowinc",
    "pct_rural",
    "pct_hsed",
    "pct_unemply"
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
        base::cut(
          df[[col]],
          breaks = breaks,
          labels = labels,
          include.lowest = TRUE
        )
    }
    return(df)
  }

# Apply the function
PWS_with_demographic_data_ranges <-
  cut_columns_to_new_labels(PWS_Weighted_Outputs,
                            pct_cols,
                            breaks,
                            labels)


# Export Data ----
write.csv(
  PWS_with_demographic_data_ranges,
  here("R/CWS_Analysis/05_Demographic_Analysis/PWS_Final_Weighted_Demographic_Data_V1DOT2PWS.csv"),
  row.names = FALSE
)
