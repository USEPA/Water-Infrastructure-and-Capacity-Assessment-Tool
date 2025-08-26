library(httr)
library(jsonlite)
library(here)

# Import Tribal Identifier Codes from EPA API  -----------------
# https://www.epa.gov/data-standards/tribes-services-tribal-identifier-data-standard

res_tribal_codes = GET("https://cdxapi.epa.gov/oms-tribes-rest-services/api/v1/tribes?tribeNameQualifier=contains&tribalBandFilter=ExcludeTribalBands")
tribe_codes_lower48 = fromJSON(rawToChar(res_tribal_codes$content))

# Format column names to remove spaces 
names(tribe_codes_lower48) <-
  gsub(" ", "_", names(tribe_codes_lower48))

# Export -----------------
write.csv(tribe_codes_lower48, here("Input_Data/Locational/Tribe/tribe_codes_lower48.csv"), row.names = FALSE)
