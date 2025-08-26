library(here)
library(zoo)
library(lubridate)
library(dplyr)
library(vroom)
library(DBI)
library(odbc)

# This script is used to import single event violation data in the last 3-years/12-qtrs

# Create db connections and import environment variables ----
db <- Sys.getenv("ECHO_DB")
uid <- Sys.getenv("ECHO_uid")
pwd <- Sys.getenv("ECHO_pwd")

FYQTR_NPDES <- Sys.getenv("FYQTR_NPDES") # Import the "FYQTR" to run SQL query
npdes_set_fyqtr <- Sys.getenv("npdes_set_fyqtr") # Import the "FY QTR" to filter data
npdes_set_fyqtr <- as.yearqtr(npdes_set_fyqtr) # Convert to a yearqtr class

con <- dbConnect(odbc::odbc(),
                 dsn = db,
                 uid = uid,
                 pwd = pwd)

# Set up and run query ----
# Set single event violation date
SINGLE_EVENT_VIOLATION_DATE_SELECT <- as.Date(as.yearqtr(npdes_set_fyqtr -
                                                           .25, format = "Q%q/%y")) - years(3) - days(1)

SINGLE_EVENT_VIOLATION_DATE_SELECT <- as.Date(SINGLE_EVENT_VIOLATION_DATE_SELECT, format = "%Y-%m-%d") %>% format(., "%d-%b-%y") %>% toupper(.)

echo_NPDES_SE_VIOLATIONS_query <- paste(
  "SELECT *
  FROM ECHO_DFR.V_SE_VIOLATIONS_DL
  WHERE
  (SINGLE_EVENT_VIOLATION_DATE>=",
  "'",
  SINGLE_EVENT_VIOLATION_DATE_SELECT,
  "')"
)

echo_NPDES_SE_VIOLATIONS <- dbGetQuery(con, echo_NPDES_SE_VIOLATIONS_query)

# Formatting ----
# Filter for all SE violations in last 12 Quarters

# Create FYQTR column
echo_NPDES_SE_VIOLATIONS_FORMATTED <-
  echo_NPDES_SE_VIOLATIONS %>%
  mutate(SINGLE_EVENT_VIOLATION_DATE = as.Date(SINGLE_EVENT_VIOLATION_DATE, format = "%Y/%m/%d")) %>%
      mutate(FYQTR = as.yearqtr(SINGLE_EVENT_VIOLATION_DATE) + .25
      ) 

# Filter for all violations that occurred BEFORE Q13
echo_NPDES_SE_VIOLATIONS_FORMATTED <- echo_NPDES_SE_VIOLATIONS_FORMATTED %>%
  filter(., FYQTR >  npdes_set_fyqtr - 3 & FYQTR <= npdes_set_fyqtr)

# Export ----
vroom_write(echo_NPDES_SE_VIOLATIONS_FORMATTED, here("Input_Data/NPDES/NPDES_SE_VIOLATIONS.csv"), delim = ",")
