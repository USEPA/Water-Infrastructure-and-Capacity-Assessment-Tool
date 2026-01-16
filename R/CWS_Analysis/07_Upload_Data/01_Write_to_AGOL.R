# library(reticulate)
# install.packages("reticulate")

# install.packages("arcgis", repos = "https://r-arcgis.r-universe.dev")
library(arcgis)
library(sf)
library(here)
library(dplyr)
library(vroom)

#Authentication tips: https://developers.arcgis.com/r-bridge/authentication/authenticating-with-r/
# Overwrite tips: https://developers.arcgis.com/r-bridge/editing/truncate-and-append-features/
# Read feature service help: https://developers.arcgis.com/r-bridge/editing/truncate-and-append-features/

ARCGIS_CLIENT <- Sys.getenv("ARCGIS_CLIENT")
ARCGIS_SECRET <- Sys.getenv("ARCGIS_SECRET")
ARCGIS_USER <- Sys.getenv("ARCGIS_USER")
ARCGIS_PASSWORD <- Sys.getenv("ARCGIS_PASSWORD")
ARCGIS_API_KEY <- Sys.getenv("ARCGIS_API_KEY")
ARCGIS_HOST <- Sys.getenv("ARCGIS_HOST")

token <- auth_code()
set_arc_token(token)

# This script performs final cleaning operations prior to .shp export
# Polygon Overwrite ----
CWS_Polygons_Input <- st_read(here("Final_Exports_for_App/Drinking_Water_Files/PWS_Polygons_2026_01_16.gpkg")) %>%
  sf::st_transform(.,crs = 3857)

CWS_Polygons_Target_URL <- "https://services.arcgis.com/cJ9YHowT8TU7DUyn/arcgis/rest/services/Community_Water_Systems_March_28_2024/FeatureServer/343"

CWS_Polygons_Target <- arc_open(CWS_Polygons_Target_URL)
CWS_Polygons_Target

CWS_Polygons_Target[["supportsTruncate"]]

CWS_Polygons_Target_Truncate <- truncate_layer(CWS_Polygons_Target)
CWS_Polygons_Target_Truncate

CWS_Polygons_Target <- refresh_layer(CWS_Polygons_Target)
CWS_Polygons_Target

CWS_Polygons_Updated <- add_features(CWS_Polygons_Target, CWS_Polygons_Input)
head(CWS_Polygons_Updated)

# Pts Overwrite ----
CWS_without_SAB <- "https://services.arcgis.com/cJ9YHowT8TU7DUyn/arcgis/rest/services/Community_Water_Systems_June_8_2024_Pts/FeatureServer/447"
CWS_without_SAB_orig <- arc_open(CWS_without_SAB) 
CWS_without_SAB_orig

CWS_without_SAB_orig[["supportsTruncate"]]

truncate_fl_orig <- truncate_layer(CWS_without_SAB_orig)
truncate_fl_orig

CWS_without_SAB_orig <- refresh_layer(CWS_without_SAB_orig)
CWS_without_SAB_orig 

CWS_without_SAB_new <- add_features(CWS_without_SAB_orig, final_CWS_dataset_with_DWSRF)
head(CWS_without_SAB_new)

# CWS Table Overwrite ----

# CWS_complete_table_new <- vroom(here("Final_Exports_for_App/Drinking_Water_Files/PWS_Complete_Table_2025_11_17.csv")) 
#   select(-c("SS_OUTSTAND_PERFORM_BEGIN_DATE","SS_DATE_MOST_RECENT"))
# 
# CWS_complete_table <- "https://services.arcgis.com/cJ9YHowT8TU7DUyn/arcgis/rest/services/Community_Water_Systems_June_8_2024_all_CWS/FeatureServer/477"
# CWS_complete_table_orig <- arc_open(CWS_complete_table) 
# CWS_complete_table_orig
# 
# CWS_complete_table_orig[["supportsTruncate"]]
# 
# truncate_tbl_orig <- truncate_layer(CWS_complete_table_orig)
# truncate_tbl_orig
# 
# CWS_complete_table_orig <- refresh_layer(CWS_complete_table_orig)
# CWS_complete_table_orig 
# 
# final_tbl <- add_features(CWS_complete_table_orig, CWS_complete_table_new)
# head(final_tbl)
