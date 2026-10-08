# This script calculates area weighted census data for the POTW buffer areas

# Clear environment
rm(list = ls())

library(dplyr)
library(vroom)
library(here)

options(scipen = 999) # turns off scientific notation

# Import data ----
POTW_with_Census <- readRDS(here("R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/Complete_POTW_Crswlk.rds"))

# Calculate Population Weighted Demographic Data ----
POTW_with_demogr_data <- POTW_with_Census %>%
  group_by(buffer_dist,NPDES_ID) %>% # Group data by NPDES_ID and buffer distance (calculating all the below fields at the NPDES_ID level, for each buffer area)
  dplyr::summarize(
    POTW_pop = sum(pop_ovlp, na.rm = TRUE),    # Calculate total census block population intersecting with a POTW
    POTW_HU  = sum(housingunit_ovlp, na.rm = TRUE), #tot census blk housing units intersecting with POTW
    
    pop_lowinc = sum(pop_ovlp * LOWINCPCT, na.rm = TRUE),
    # Overlapping population * pct of the bg that is low income
    pct_lowinc = pop_lowinc / POTW_pop,
    
    pop_unemply = sum(pop_ovlp * UNEMPLYMNTPCT, na.rm = TRUE),
    # Overlapping population * pct of the bg that is low income
    pct_unemply = pop_unemply / POTW_pop,
    
    pop_rural = sum(pop_ovlp * Urban_Rural, na.rm = TRUE),
    # Overlapping population x 0/1 for census blk urban/rural designation
    pct_rural = pop_rural / POTW_pop,
    
    pop_U5 = sum(pop_ovlp * PCT_POP_U5, na.rm = TRUE),
    pct_U5 = pop_U5 / POTW_pop,
    
    pop_U18 = sum(pop_ovlp * PCT_POP_U18, na.rm = TRUE),
    pct_U18 = pop_U18 / POTW_pop,
    
    pop_62plus = sum(pop_ovlp * PCT_POP_62Plus, na.rm = TRUE),
    pct_62plus = pop_62plus / POTW_pop,
    
    cnt_HU_rntr = sum(housingunit_ovlp * PCT_HU_RNTR, na.rm = TRUE),
    pct_HU_rntr = cnt_HU_rntr / POTW_HU,
    
    cnt_MFHU = sum(housingunit_ovlp * PCT_MFHU, na.rm = TRUE),
    pct_MFHU = cnt_MFHU / POTW_HU,
    
    # MHI: exclude negative values before computing weighted average
    POTW_mhi_weighted = {
      valid_mhi <- MHI >= 0 & !is.na(MHI)
      sum(MHI[valid_mhi] * housingunit_ovlp[valid_mhi], na.rm = TRUE) /
        sum(housingunit_ovlp[valid_mhi], na.rm = TRUE)
    },
    
    POTW_LQI_weighted = {
      valid_LQI <- LQI_UL >= 0 & !is.na(LQI_UL)
      sum(LQI_UL[valid_LQI] * housingunit_ovlp[valid_LQI], na.rm = TRUE) /
        sum(housingunit_ovlp[valid_LQI], na.rm = TRUE)
    }
    
  ) %>%
  dplyr::select(
    c(
      "NPDES_ID",
      "POTW_pop",
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
      "POTW_mhi_weighted",
      "POTW_LQI_weighted"
    )
  )

saveRDS(POTW_with_demogr_data,here("R/Wastewater_Analysis/04_Demographic_Analysis/Temp_Outputs/POTW_with_demogr_data.rds"))

