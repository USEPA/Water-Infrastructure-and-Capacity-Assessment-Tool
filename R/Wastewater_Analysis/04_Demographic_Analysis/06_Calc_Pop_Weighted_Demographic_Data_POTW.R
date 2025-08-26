library(vroom)
library(here)
library(dplyr)

# This script calculates population weighted demographic data at 1/3/5mi POTW buffers.

options(scipen = 999) #turns off scientific notation

# Import data ----
# 1mi
POTW_with_Census_1mi <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_1mi_OUT.csv"
  ),
)

POTW_with_Census_3mi <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_3mi_OUT.csv"
  ),
)

POTW_with_Census_5mi <- vroom(
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTW_with_Demogr_5mi_OUT.csv"
  ),
)

# Join crosswalks with demographic data ----
## 1-mi ----
POTWs_Demo_Data_1mi <- POTW_with_Census_1mi %>%
  group_by(NPDES_ID) %>% #Group data by NPDES ID (calculating all the below fields at the NPDES ID level)
  dplyr::summarize(
    potw_pop_1mi = sum(pop_ovlp),
    # Calculate total census block population intersecting with a POTW buffer area
    pop_lowinc_1mi = sum(pop_ovlp * LOWINCPCT, na.rm = TRUE), #Overlapping population * pct of the bg that is low income
    pct_lowinc_1mi = sum((pop_lowinc_1mi / potw_pop_1mi), na.rm = TRUE),
    pop_rural_1mi = sum(pop_ovlp * Urban_Rural, na.rm = TRUE), #Overlapping population x 0/1 for census blk urban/rural designation
    pct_rural_1mi = sum(pop_rural_1mi / potw_pop_1mi, na.rm = TRUE),
    pop_hsed_1mi = sum(pop_ovlp * LESSTHANHSPCT, na.rm = TRUE),
    #Overlapping population * pct of the bg that is low income
    pct_hsed_1mi = sum((pop_hsed_1mi / potw_pop_1mi), na.rm = TRUE),
    pop_unemply_1mi = sum(pop_ovlp * UNEMPLYMNTPCT, na.rm = TRUE),
    #Overlapping population * pct of the bg that is low income
    pct_unemply_1mi = sum((pop_unemply_1mi / potw_pop_1mi), na.rm = TRUE)
  ) %>%
  dplyr::select(
    c(
      "NPDES_ID",
      "potw_pop_1mi",
      "pop_lowinc_1mi",
      "pct_lowinc_1mi",
      "pop_hsed_1mi",
      "pct_hsed_1mi",
      "pop_unemply_1mi",
      "pct_unemply_1mi",
      "pop_rural_1mi",
      "pct_rural_1mi"
    )
  ) 

# Calculate weighted MHI
POTW_with_MHI_1mi <- POTW_with_Census_1mi %>%
  filter(MHI != -666666666) %>%
  group_by(NPDES_ID) %>%
  dplyr::summarize(
    potw_pop_1mi = sum(pop_ovlp),
    # Calculate total population intersecting with a POTW buffer area
    potw_mhi_1mi = sum(MHI * pop_ovlp, na.rm = TRUE),
    mhi_weighted_1mi = sum(potw_mhi_1mi / potw_pop_1mi, na.rm = TRUE)
  ) %>%
  dplyr::select(c("NPDES_ID", "potw_mhi_1mi", "mhi_weighted_1mi"))

# Join MHI with Demographic data 
POTW_with_demo_econ_data_1mi <- merge(POTWs_Demo_Data_1mi, POTW_with_MHI_1mi[c("NPDES_ID", "mhi_weighted_1mi")], by = "NPDES_ID")

## 3-mi ----
POTWs_Demo_Data_3mi <- POTW_with_Census_3mi %>%
  group_by(NPDES_ID) %>% #Group data by NPDES ID (calculating all the below fields at the NPDES ID level)
  dplyr::summarize(
    potw_pop_3mi = sum(pop_ovlp),
    # Calculate total census block population intersecting with a POTW buffer area
    pop_lowinc_3mi = sum(pop_ovlp * LOWINCPCT, na.rm = TRUE), #Overlapping population * pct of the bg that is low income
    pct_lowinc_3mi = sum((pop_lowinc_3mi / potw_pop_3mi), na.rm = TRUE),
    pop_rural_3mi = sum(pop_ovlp * Urban_Rural, na.rm = TRUE), #Overlapping population x 0/1 for census blk urban/rural designation
    pct_rural_3mi = sum(pop_rural_3mi / potw_pop_3mi, na.rm = TRUE),
    pop_hsed_3mi = sum(pop_ovlp * LESSTHANHSPCT, na.rm = TRUE),
    #Overlapping population * pct of the bg that is low income
    pct_hsed_3mi = sum((pop_hsed_3mi / potw_pop_3mi), na.rm = TRUE),
    pop_unemply_3mi = sum(pop_ovlp * UNEMPLYMNTPCT, na.rm = TRUE),
    #Overlapping population * pct of the bg that is low income
    pct_unemply_3mi = sum((pop_unemply_3mi / potw_pop_3mi), na.rm = TRUE)
  ) %>%
  dplyr::select(
    c(
      "NPDES_ID",
      "potw_pop_3mi",
      "pop_lowinc_3mi",
      "pct_lowinc_3mi",
      "pop_hsed_3mi",
      "pct_hsed_3mi",
      "pop_unemply_3mi",
      "pct_unemply_3mi",
      "pop_rural_3mi",
      "pct_rural_3mi"
    )
  ) 

# Calculate weighted MHI
POTW_with_MHI_3mi <- POTW_with_Census_3mi %>%
  filter(MHI != -666666666) %>%
  group_by(NPDES_ID) %>%
  dplyr::summarize(
    potw_pop_3mi = sum(pop_ovlp),
    # Calculate total population intersecting with a POTW buffer area
    potw_mhi_3mi = sum(MHI * pop_ovlp, na.rm = TRUE),
    mhi_weighted_3mi = sum(potw_mhi_3mi / potw_pop_3mi, na.rm = TRUE)
  ) %>%
  dplyr::select(c("NPDES_ID", "potw_mhi_3mi", "mhi_weighted_3mi"))

# Join MHI with Demographic data
POTW_with_demo_econ_data_3mi <- merge(POTWs_Demo_Data_3mi, POTW_with_MHI_3mi[c("NPDES_ID", "mhi_weighted_3mi")], by = "NPDES_ID")

## 5-mi ----
POTWs_Demo_Data_5mi <- POTW_with_Census_5mi %>%
  group_by(NPDES_ID) %>% #Group data by NPDES ID (calculating all the below fields at the NPDES ID level)
  dplyr::summarize(
    potw_pop_5mi = sum(pop_ovlp),
    # Calculate total census block population intersecting with a POTW buffer area
    pop_lowinc_5mi = sum(pop_ovlp * LOWINCPCT, na.rm = TRUE), #Overlapping population * pct of the bg that is low income
    pct_lowinc_5mi = sum((pop_lowinc_5mi / potw_pop_5mi), na.rm = TRUE),
    pop_rural_5mi = sum(pop_ovlp * Urban_Rural, na.rm = TRUE), #Overlapping population x 0/1 for census blk urban/rural designation
    pct_rural_5mi = sum(pop_rural_5mi / potw_pop_5mi, na.rm = TRUE),
    pop_hsed_5mi = sum(pop_ovlp * LESSTHANHSPCT, na.rm = TRUE),
    #Overlapping population * pct of the bg that is low income
    pct_hsed_5mi = sum((pop_hsed_5mi / potw_pop_5mi), na.rm = TRUE),
    pop_unemply_5mi = sum(pop_ovlp * UNEMPLYMNTPCT, na.rm = TRUE),
    #Overlapping population * pct of the bg that is low income
    pct_unemply_5mi = sum((pop_unemply_5mi / potw_pop_5mi), na.rm = TRUE)
  ) %>%
  dplyr::select(
    c(
      "NPDES_ID",
      "potw_pop_5mi",
      "pop_lowinc_5mi",
      "pct_lowinc_5mi",
      "pop_hsed_5mi",
      "pct_hsed_5mi",
      "pop_unemply_5mi",
      "pct_unemply_5mi",
      "pop_rural_5mi",
      "pct_rural_5mi"
    )
  ) 

## Calculate weighted MHI
POTW_with_MHI_5mi <- POTW_with_Census_5mi %>%
  filter(MHI != -666666666) %>%
  group_by(NPDES_ID) %>%
  dplyr::summarize(
    potw_pop_5mi = sum(pop_ovlp),
    # Calculate total population intersecting with a POTW buffer area
    potw_mhi_5mi = sum(MHI * pop_ovlp, na.rm = TRUE),
    mhi_weighted_5mi = sum(potw_mhi_5mi / potw_pop_5mi, na.rm = TRUE)
  ) %>%
  dplyr::select(c("NPDES_ID", "potw_mhi_5mi", "mhi_weighted_5mi"))

## Join MHI with Demographic data
POTW_with_demo_econ_data_5mi <- merge(POTWs_Demo_Data_5mi, POTW_with_MHI_5mi[c("NPDES_ID", "mhi_weighted_5mi")], by = "NPDES_ID")

# Merge demographic data at all buffer scales together ----
POTWs_with_Demo_data_all_radii <- merge(
  POTW_with_demo_econ_data_5mi,
  POTW_with_demo_econ_data_3mi,
  by = "NPDES_ID",
  all.x = TRUE
) %>%
  merge(.,
        POTW_with_demo_econ_data_1mi,
        by = "NPDES_ID",
        all.x = TRUE)

# Export ----
vroom_write(
  POTWs_with_Demo_data_all_radii,
  here(
    "R/Wastewater_Analysis/04_Demographic_Analysis/POTWs_with_Demo_data_all_radii_OUT.csv"
  ),
  delim = ",",
  col_names = TRUE
)