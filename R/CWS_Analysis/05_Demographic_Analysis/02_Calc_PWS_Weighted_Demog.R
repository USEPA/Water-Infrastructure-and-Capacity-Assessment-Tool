library(dplyr)
library(vroom)
library(here)

# This script calculates weighted demographic data at the SAB scale

# Import data ----------
PWS_Census <- vroom(here("R/CWS_Analysis/05_Demographic_Analysis/PWS_with_Census.csv"))

# Calculate Population Weighted Demographic Data ----
options(scipen = 999) # turns off scientific notation

PWS_with_demogr_data <- PWS_Census %>%
  group_by(PWSID) %>% # Group data by PWSID (calculating all the below fields at the PWSID level)
  dplyr::summarize(
    pws_pop = sum(pop_ovlp),
    # Calculate total census block population intersecting with a CWS
    pop_lowinc = sum(pop_ovlp * LOWINCPCT, na.rm = TRUE),
    # Overlapping population * pct of the bg that is low income
    pct_lowinc = sum((pop_lowinc / pws_pop), na.rm = TRUE),
    pop_hsed = sum(pop_ovlp * LESSTHANHSPCT, na.rm = TRUE),
    # Overlapping population * pct of the bg that is low income
    pct_hsed = sum((pop_hsed / pws_pop), na.rm = TRUE),
    pop_unemply = sum(pop_ovlp * UNEMPLYMNTPCT, na.rm = TRUE),
    # Overlapping population * pct of the bg that is low income
    pct_unemply = sum((pop_unemply / pws_pop), na.rm = TRUE),
    pop_rural = sum(pop_ovlp * Urban_Rural, na.rm = TRUE),
    # Overlapping population x 0/1 for census blk urban/rural designation
    pct_rural = sum(pop_rural / pws_pop, na.rm = TRUE)
  ) %>%
  dplyr::select(
    c(
      "PWSID",
      "pws_pop",
      "pop_lowinc",
      "pct_lowinc",
      "pop_hsed",
      "pct_hsed",
      "pop_unemply",
      "pct_unemply",
      "pop_rural",
      "pct_rural"
    )
  )

# Calc Weighted MHI ----
PWS_with_demogr_data_MHI <- PWS_Census %>%
  filter(MHI != -666666666) %>% # Remove null MHI values
  group_by(PWSID) %>%
  dplyr::summarize(
    pws_hunits = sum(housingunit_ovlp),
    # Calculate total housing units intersecting with a CWS
    pws_mhi = sum(MHI * housingunit_ovlp, na.rm = TRUE),
    pws_mhi_weight = sum(pws_mhi / pws_hunits, na.rm = TRUE)
  ) %>%
  dplyr::select(c("PWSID", "pws_mhi", "pws_mhi_weight"))

# Join MHI with Demographic data
PWS_with_demo_econ_data <- merge(PWS_with_demogr_data, PWS_with_demogr_data_MHI[c("PWSID", "pws_mhi_weight")], by = "PWSID")

# Export ----
write.csv(
  PWS_with_demo_econ_data,
  here("R/CWS_Analysis/05_Demographic_Analysis/PWS_Weighted_Demog_Data.csv"),
  row.names = FALSE
)
