library(here)
library(zoo)
library(RODBC)
library(lubridate)
library(dplyr)
library(vroom)

# This script is used to import the base universe of CWS, importing all active CWS

# Create a connection to SDWIS----
db_sdwis <- Sys.getenv("SDWIS_DB")
uid_sdiws <- Sys.getenv("SDWIS_uid")
pwd_sdwis <- Sys.getenv("SDWIS_pwd")

channel_SDWIS <- odbcConnect(db_sdwis, uid_sdiws, pwd_sdwis)

# Set-up and run query----

SDFW_CWS_ACTIVE_ATTRIBUTES <- sqlQuery(
  channel_SDWIS,
  "SELECT * FROM LTST_WATER_SYSTEM WHERE PWS_TYPE_CODE = 'CWS' AND pws_activity_code = 'A'"
)

# Formatting----

## Convert codes to full descriptions----
### Set up query ----
SDWA_ref_codes_query <- paste(
  "SELECT *
  FROM REF_CODE_VALUE
  ")

### Run query ----
SDWA_ref_codes <- sqlQuery(channel_SDWIS,SDWA_ref_codes_query)

### PWS type code----
SDFW_CWS_ACTIVE_ATTRIBUTES <-
  merge(
    SDFW_CWS_ACTIVE_ATTRIBUTES,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "PWS_TYPE_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "PWS_TYPE_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  ) %>% dplyr::select(-c("PWS_TYPE_CODE")) %>% rename("PWS_TYPE" = "VALUE_DESCRIPTION")

### Owner type code----
SDFW_CWS_ACTIVE_ATTRIBUTES <-
  merge(
    SDFW_CWS_ACTIVE_ATTRIBUTES,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "OWNER_TYPE_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "OWNER_TYPE_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  ) %>% dplyr::select(-c("OWNER_TYPE_CODE")) %>% rename("OWNER_TYPE" = "VALUE_DESCRIPTION")

### Source water type code----
SDFW_CWS_ACTIVE_ATTRIBUTES <-
  merge(
    SDFW_CWS_ACTIVE_ATTRIBUTES,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "GW_SW_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "GW_SW_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  ) %>% dplyr::select(-c("GW_SW_CODE")) %>% rename("SOURCE_WATER_TYPE" = "VALUE_DESCRIPTION")

### Population category code----

# Convert Pop Cat 5 Code to character from integer to allow merging in the following chunk
SDFW_CWS_ACTIVE_ATTRIBUTES$POP_CAT_5_CODE <-
  as.character(SDFW_CWS_ACTIVE_ATTRIBUTES$POP_CAT_5_CODE)

SDFW_CWS_ACTIVE_ATTRIBUTES <-
  merge(
    SDFW_CWS_ACTIVE_ATTRIBUTES,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "POP_CAT_5_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "POP_CAT_5_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  )  %>% dplyr::select(-c("POP_CAT_5_CODE")) %>% rename("POPULATION_CATEGORY_SERVED" = "VALUE_DESCRIPTION")

### Primacy Agency Code----
SDFW_CWS_ACTIVE_ATTRIBUTES <-
  merge(
    SDFW_CWS_ACTIVE_ATTRIBUTES,
    subset(
      SDWA_ref_codes,
      VALUE_TYPE == "PRIMACY_AGENCY_CODE",
      select = c("VALUE_CODE", "VALUE_DESCRIPTION")
    ),
    by.x = "PRIMACY_AGENCY_CODE",
    by.y = "VALUE_CODE",
    all.x = TRUE
  )  %>% dplyr::select(-c("PRIMACY_AGENCY_CODE")) %>% rename("PRIMACY_AGENCY" = "VALUE_DESCRIPTION")

# Export----
write.csv(SDFW_CWS_ACTIVE_ATTRIBUTES, here("Input_Data/SDWIS", "SDWIS_CWS_ACTIVE_ATTRIBUTES.csv"), row.names = FALSE)
