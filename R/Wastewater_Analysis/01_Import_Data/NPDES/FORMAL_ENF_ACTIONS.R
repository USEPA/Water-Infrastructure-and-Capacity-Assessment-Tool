library(here)
library(zoo)
library(lubridate)
library(dplyr)
library(vroom)
library(DBI)
library(odbc)

# This script imports formal enforcement actions over the last 5-years

# Create db connections and import environment variables ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")
SETTLEMENT_ENTERED_DATE <- Sys.getenv("SETTLEMENT_ENTERED_DATE")
npdes_set_fyqtr <- Sys.getenv("npdes_set_fyqtr")
npdes_set_fyqtr <- as.yearqtr(npdes_set_fyqtr)

con <- dbConnect(odbc::odbc(),
                 dsn = db,
                 uid = uid,
                 pwd = pwd)

# Set up and run query ----

echo_NPDES_FEA_query <- paste(
  "SELECT *
  FROM ECHO_DFR.NPDES_FORMAL_ACTIONS
WHERE
(SETTLEMENT_ENTERED_DATE>=",
  "'",
  SETTLEMENT_ENTERED_DATE,
  "')"
)
echo_NPDES_FORMAL_ENFORCEMENT_ACTIONS <- dbGetQuery(con, echo_NPDES_FEA_query) 

# Formatting ----
# Filter for all SE violations in last 60 Quarters (5yrs)

# Create FYQTR column
echo_NPDES_FORMAL_ENFORCEMENT_ACTIONS_FORMATTED <-
  echo_NPDES_FORMAL_ENFORCEMENT_ACTIONS %>%
  mutate(SETTLEMENT_ENTERED_DATE = as.Date(SETTLEMENT_ENTERED_DATE, format = "%Y/%m/%d")) %>%
  mutate(FYQTR = as.yearqtr(SETTLEMENT_ENTERED_DATE) + .25
  ) 

# Filter for all violations that occurred BEFORE Q13
echo_NPDES_FORMAL_ENFORCEMENT_ACTIONS_FORMATTED <- echo_NPDES_FORMAL_ENFORCEMENT_ACTIONS_FORMATTED %>%
  filter(., FYQTR >  npdes_set_fyqtr - 5 & FYQTR <= npdes_set_fyqtr)

# Export ----
vroom_write(echo_NPDES_FORMAL_ENFORCEMENT_ACTIONS,
          here("Input_Data/NPDES/NPDES_FORMAL_ENFORCEMENT_ACTIONS.csv"),
          delim = ",")
