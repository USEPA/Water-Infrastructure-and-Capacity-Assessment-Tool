# This script calculates weighted demographic data at the SAB scale

# Clear environment
rm(list = ls())

library(dplyr)
library(vroom)
library(here)
options(scipen = 999) # turns off scientific notation

# Import data----
PWS_Census <- 
  #vroom(here("R/CWS_Analysis/05_Demographic_Analysis/PWS_with_Census.csv"))
  readRDS(here("R/CWS_Analysis/05_Demographic_Analysis/Temp_Outputs/PWS_with_Census.rds"))

# Calculate Population Weighted Demographic Data ----
PWS_with_demogr_data <- PWS_Census %>%
  group_by(PWSID) %>% # Group data by PWSID (calculating all the below fields at the PWSID level)
  dplyr::summarize(
    pws_pop = sum(pop_ovlp, na.rm = TRUE),
    # Calculate total census block population intersecting with a CWS
    pws_HU = sum(housingunit_ovlp, na.rm = TRUE), 
    #tot housing units intersecting with CWS
    
    pop_lowinc = sum(pop_ovlp * LOWINCPCT, na.rm = TRUE),
    # Overlapping population * pct of the bg that is low income
    pct_lowinc = pop_lowinc / pws_pop,
    # # Overlapping population * pct of the bg that is low income
    
    pop_unemply = sum(pop_ovlp * UNEMPLYMNTPCT, na.rm = TRUE),
    # Overlapping population * pct of the bg that is low income
    pct_unemply = pop_unemply / pws_pop,
    
    pop_rural = sum(pop_ovlp * Urban_Rural, na.rm = TRUE),
    # Overlapping population x 0/1 for census blk urban/rural designation
    pct_rural = pop_rural / pws_pop,
    
    pop_U5 = sum(pop_ovlp * PCT_POP_U5, na.rm = TRUE),
    pct_U5 = pop_U5 / pws_pop,
    
    pop_U18 = sum(pop_ovlp * PCT_POP_U18, na.rm = TRUE),
    pct_U18 = pop_U18 / pws_pop,
    
    pop_62plus = sum(pop_ovlp * PCT_POP_62Plus, na.rm = TRUE),
    pct_62plus = pop_62plus / pws_pop,
    
    cnt_HU_rntr = sum(housingunit_ovlp * PCT_HU_RNTR, na.rm = TRUE),
    pct_HU_rntr = cnt_HU_rntr / pws_HU ,
    
    cnt_MFHU = sum(housingunit_ovlp * PCT_MFHU, na.rm = TRUE),
    pct_MFHU = cnt_MFHU / pws_HU,
    
    # MHI: exclude negative values before computing weighted average
    pws_mhi_weight = {
      valid_mhi <- MHI >= 0 & !is.na(MHI)
      sum(MHI[valid_mhi] * housingunit_ovlp[valid_mhi], na.rm = TRUE) /
        sum(housingunit_ovlp[valid_mhi], na.rm = TRUE)
    },
    
    pws_LQI_weight = {
      valid_LQI <- LQI_UL >= 0 & !is.na(LQI_UL)
      sum(LQI_UL[valid_LQI] * housingunit_ovlp[valid_LQI], na.rm = TRUE) /
        sum(housingunit_ovlp[valid_LQI], na.rm = TRUE)
    }
    
  ) %>%
  dplyr::select(
    c(
      "PWSID",
      "pws_pop",
      "pop_lowinc",
      "pct_lowinc",
      "pop_unemply",
      "pct_unemply",
      "pop_rural",
      "pct_rural",
      "pop_U5",
      "pct_U5",
      "pop_U18",
      "pct_U18",
      "pop_62plus",
      "pct_62plus",
      "cnt_HU_rntr",
      "pct_HU_rntr",
      "cnt_MFHU",
      "pct_MFHU",
      "pws_mhi_weight",
      "pws_LQI_weight"
    )
  )

# Calc Weighted MHI ----
# PWS_with_demogr_data_MHI <- PWS_Census %>%
#   filter(MHI >0) %>% # Remove null MHI values
#   group_by(PWSID) %>%
#   dplyr::summarize(
#     pws_hunits = sum(housingunit_ovlp),
#     # Calculate total housing units intersecting with a CWS
#     pws_mhi = sum(MHI * housingunit_ovlp, na.rm = TRUE),
#     pws_mhi_weight = sum(pws_mhi / pws_hunits, na.rm = TRUE)
#   ) %>%
#   dplyr::select(c("PWSID", "pws_mhi", "pws_mhi_weight"))

# Join MHI with Demographic data
# PWS_with_demo_econ_data <- merge(PWS_with_demogr_data, PWS_with_demogr_data_MHI[c("PWSID", "pws_mhi_weight")], by = "PWSID")

# Calc Weighted LQI ----
# PWS_LQI <- PWS_Census %>%
#   filter(LQI_UL >0) %>% # Remove null LQI values
#   group_by(PWSID) %>%
#   dplyr::summarize(
#     pws_hunits = sum(housingunit_ovlp),
#     # Calculate total housing units intersecting with a CWS
#     pws_LQI = sum(LQI_UL * housingunit_ovlp, na.rm = TRUE),
#     pws_LQI_weight = sum(pws_LQI / pws_hunits, na.rm = TRUE)
#   ) %>%
#   dplyr::select(c("PWSID", "pws_LQI", "pws_LQI_weight"))

# Join LQI with Demographic data
# PWS_with_all_Census<- merge(PWS_with_demo_econ_data, PWS_LQI[c("PWSID", "pws_LQI_weight")], by = "PWSID")

# Export ----
# write.csv(
#   PWS_with_all_Census,
#   here("R/CWS_Analysis/05_Demographic_Analysis/PWS_Weighted_Demog_Data.csv"),
#   row.names = FALSE
# )

saveRDS(PWS_with_demogr_data,here("R/CWS_Analysis/05_Demographic_Analysis/Temp_Outputs/PWS_Weighted_Demog_Data.rds"))
