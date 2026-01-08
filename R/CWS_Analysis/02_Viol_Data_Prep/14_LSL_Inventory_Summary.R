library(here)
library(dplyr)
library(vroom)

# This script modified column names from the lead service line inventory data frame

# Import and format data
LSLI_Base <- vroom(here("Input_Data/SDWIS/SDWIS_service_line_inventory_2025Q3.csv")) %>%
  rename(
    "PWSID" = "PWS ID",
    "GRR_Cnt" = '# Galvanized Requiring Replacement Service Lines',
    "LSL_Cnt" = '# Lead Service Lines'  ,
    "Unknown_Cnt" = '# Lead Status Unknown Service Lines' ,
    "Non_Lead_Cnt" = '# Non-lead Service Lines'  ,
    "Tot_SL" = 'Total # Service Lines Reported' 
  ) %>%
  select(
    "PWSID",
    "GRR_Cnt",
    "LSL_Cnt",
    "Unknown_Cnt",
    "Non_Lead_Cnt",
    "Tot_SL"
  ) %>%
  mutate(
    SL_Rpt_Status = ""
  )

# Calculate new columns ----
LSLI_New_Cols <- LSLI_Base %>%
  mutate(
    SL_Rpt_Status =
      case_when(
        !is.na(LSL_Cnt) &
          !is.na(GRR_Cnt) &
          !is.na(Unknown_Cnt) ~ 'Reported all required service line types', TRUE ~  as.character(SL_Rpt_Status) 
      ),
    SL_Rpt_Status =
      case_when(
        is.na(LSL_Cnt) |
          is.na(GRR_Cnt) |
          is.na(Unknown_Cnt) ~ 'Reported some but not all required service line types', TRUE ~  as.character(SL_Rpt_Status) 
      ),
    SL_Rpt_Status =
      case_when(
        is.na(LSL_Cnt) &
          is.na(GRR_Cnt) &
          is.na(Unknown_Cnt) ~ 'Did not report any required service line types', TRUE ~  as.character(SL_Rpt_Status) 
      )
  )

# Export data
write.csv(LSLI_New_Cols, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/LSLI_Data.csv"), row.names = FALSE)
