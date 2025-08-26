library(vroom)
library(here)
library(dplyr)

# This script joins the combined violation and lagoon data with CWSRF data

# Import data ----

# Import combined violation/lagoon dataset
POTW_VIOL_LAGOON <- vroom(here("R/Wastewater_Analysis/05_Join_Analysis_Components/NPDES_VIOL_LAGOON.csv"))

# Import CWSRF history data and group the data by NPDES ID
CWSRF_history <- vroom(here("Input_Data/CWSRF/CWSRF_History.csv"))%>%
  rename("CWSRF_Hardship_Community" = "Hardship/Disadvantaged_Community?",
         "NPDES_ID"= "NPDES_Permit_Number") 

CWSRF_history_grouped <- CWSRF_history %>%
  arrange(desc(Initial_Agreement_Date)) %>% # Sort data in date descending order to enable correct selection of disadvantaged assistance value
  group_by(NPDES_ID) %>% 
  summarise(
    CWSRF_AWARDS_10YRS_COUNT = n(),
    CWSRF_Hardship_Community = first(CWSRF_Hardship_Community) # Paste the hardship community value, based on the latest/newest agreement
  )

# Join datasets ----

# Specify label breaks that will be used for the count of DWSRF agreements
breaks_zero_twentyplus <- c(-Inf, 0, 5, 10, 20, Inf)
labels_zero_twentyplus <- c("0","1-5","6-10","11-20",">20")

# Join datasets
POTW_VIOL_LAGOON_DWSRF <-
  merge(
    POTW_VIOL_LAGOON,
    CWSRF_history_grouped,
    by.x = "NPDES_ID",
    by.y = "NPDES_ID",
    all.x = TRUE
  ) %>%
  mutate(
    CWSRF_AWARDS_10YRS_COUNT = ifelse(is.na(CWSRF_AWARDS_10YRS_COUNT), 0, CWSRF_AWARDS_10YRS_COUNT), # Replace NA with 0 for count of CWSRF awards
    CWSRF_Hardship_Community = ifelse(is.na(CWSRF_Hardship_Community), "N/A - No CWSRF", CWSRF_Hardship_Community) # Replace NA with "N/A - No CWSRF" if the POTW has no record of receiving CWSRF
  ) %>%
  mutate(
    CWSRF_AWARDS_10YRS_COUNT_RANGE = cut(
      CWSRF_AWARDS_10YRS_COUNT,
      breaks = breaks_zero_twentyplus,
      labels = labels_zero_twentyplus,
      include.lowest = TRUE,
      right = TRUE  
    ) #Create ranges
  )

# Export ----
vroom_write(POTW_VIOL_LAGOON_DWSRF, here("R/Wastewater_Analysis/05_Join_Analysis_Components/POTW_VIOL_LAGOON_CWSRF_OUT.csv"), delim = ",")
