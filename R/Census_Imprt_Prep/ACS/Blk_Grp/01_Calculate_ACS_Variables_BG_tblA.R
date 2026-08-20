# This script is used to calculate select ACS variables, percent low income, percent unemployment, percent of population under 5, percent of population under 18, percent housing units that are renter occupied, percent of multi-family housing units that are renter occupied.

# Load libraries ----
library(here)
library(dplyr)
library(vroom)

# Import Data ----
ACS_BG_Socioeconomic_Import <-
  vroom(here("Input_Data/Census/ACS/ACS_TblA_BG/ACS_2020_2024a_BG.csv"))

# Calculate ACS Variables ----
ACS_BG_Socioeconomic <- ACS_BG_Socioeconomic_Import %>%
  mutate(
    bg_fips =
      paste0(
        substr(.$GISJOIN, 2, 3),
        substr(.$GISJOIN, 5, 7),
        substr(.$GISJOIN, 9, 15) #Use GISJOIN to create a census block group FIPS code column
      ),
    LOWINCPCT = (AURNE001 - AURNE008) / AURNE001,
    #Percent of Population Low Income (Households whose income is less than or equal to 2x the federal poverty level)
    UNEMPLYMNTPCT = AUTWE005 / AUTWE003,
    #Percent of Population 16 years and over unemployed (civilian labor force only),
    PCT_POP_U5 = (AUOVE003 + AUOVE027) / AUOVE001,
    #Percent of population under 5 years old
    PCT_POP_U18 = (
      AUOVE003 + AUOVE004 + AUOVE005 + AUOVE006 + AUOVE027 + AUOVE028 + AUOVE029 +
        AUOVE030
    ) / AUOVE001,
    #Percent of population under 18 years old
    PCT_POP_62Plus = (
      AUOVE043 + AUOVE044 + AUOVE045 + AUOVE046 + AUOVE047 + AUOVE048 + AUOVE049 +
        AUOVE019 + AUOVE020 + AUOVE021 + AUOVE022 + AUOVE023 + AUOVE024 + AUOVE025
    ) / AUOVE001,
    #Percent of population 62 years and older
    PCT_HU_RNTR = AUUEE003 / AUUEE001,
    #Percent of total housing units that are renter occupied
    PCT_MFHU = (
      AUVME016 + AUVME017 + AUVME018 + AUVME019 + AUVME020 + AUVME021 + AUVME005 +
        AUVME006 + AUVME007 + AUVME008 + AUVME009 + AUVME010
    ) / (
      AUVME014 + AUVME015 + AUVME016 + AUVME017 + AUVME018 + AUVME019 + AUVME020 + AUVME021 + AUVME003 + AUVME004 + AUVME005 +
        AUVME006 + AUVME007 + AUVME008 + AUVME009 + AUVME010
    ) #Percent of total multifamily housing units that are renter occupied
  ) %>%
  dplyr::select(
    .,
    c(
      "bg_fips",
      "STATE",
      "STUSAB",
      "AUO6E001",
      "LOWINCPCT",
      "UNEMPLYMNTPCT",
      "PCT_POP_U5",
      "PCT_POP_U18",
      "PCT_POP_62Plus",
      "PCT_HU_RNTR",
      "PCT_MFHU",
      "AURUE001"
    )
  ) %>%
  dplyr::rename(bg_pop = AUO6E001, MHI = AURUE001)

# hist(ACS_BG_Socioeconomic$PCT_POP_62Plus)
# summary(ACS_BG_Socioeconomic$PCT_POP_62Plus)

# Export ----
saveRDS(
  ACS_BG_Socioeconomic,
  here(
    "R/Census_Imprt_Prep/ACS/Blk_Grp/Outputs/ACS_TblA_BG_ClcdVar.rds"
  )
)
