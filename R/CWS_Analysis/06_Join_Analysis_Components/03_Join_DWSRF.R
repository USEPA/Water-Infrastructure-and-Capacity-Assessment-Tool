library(vroom)
library(dplyr)
library(here)
library(sf)
library(tigris)
library(stringr)

# This script joins the combined CWS .shp with DWSRF history data

# Import data ----

# Import combined CWS dataset (with geometries)
final_CWS_dataset <- st_read(here("R/CWS_Analysis/06_Join_Analysis_Components/combined_CWS_result.gpkg")) 

# Import DWSRF history data and group the data by PWSID
DWSRF_history <- vroom(here("Input_Data/DWSRF/DWSRF_History.csv")) 

DWSRF_history_grouped <- DWSRF_history %>%
  arrange(desc(Initial_Agreement_Date)) %>% # Sort data in date descending order to enable correct selection of disadvantaged assistance value
  group_by(PWSID) %>% 
  summarise(
    DWSRF_AWARDS_10YRS_COUNT = n(),
    Disadvantaged_Assistance = first(Disadvantaged_Assistance) # Paste the disadvantaged assistance value, based on the latest/newest agreement
    )

# Join datasets ----

# Specify label breaks that will be used for the count of DWSRF agreements
breaks_zero_twentyplus <- c(-Inf, 0, 5, 10, 20, Inf)
labels_zero_twentyplus <- c("0","1-5","6-10","11-20",">20")

# Join datasets
final_CWS_dataset_with_DWSRF <-
  merge(
    final_CWS_dataset,
    DWSRF_history_grouped,
    by.x = "PWSID",
    by.y = "PWSID",
    all.x = TRUE
  ) %>%
  mutate(
    DWSRF_AWARDS_10YRS_COUNT = ifelse(is.na(DWSRF_AWARDS_10YRS_COUNT), 0, DWSRF_AWARDS_10YRS_COUNT), # Replace NA with 0 for count of DWSRF awards
    Disadvantaged_Assistance = ifelse(is.na(Disadvantaged_Assistance), "N/A - No DWSRF", Disadvantaged_Assistance) # Replace NA with "N/A - No DWSRF" if the CWS has no record of receiving DWSRF
  ) %>%
  mutate(
    DWSRF_AWARDS_10YRS_COUNT_RANGE = cut(
      DWSRF_AWARDS_10YRS_COUNT,
      breaks = breaks_zero_twentyplus,
      labels = labels_zero_twentyplus,
      include.lowest = TRUE,
      right = TRUE  
    ) #Create ranges
  )

# Export ----
st_write(
  final_CWS_dataset_with_DWSRF,
  here("R/CWS_Analysis/06_Join_Analysis_Components/final_CWS_dataset_with_DWSRF.gpkg"),
  append = FALSE
)