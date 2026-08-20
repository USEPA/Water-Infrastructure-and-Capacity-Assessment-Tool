# Import census block population data and create block fips field
census_blk_pop_data <-
  fread(
    here(
      "Input_Data/Census/Blk-Data/nhgis0034_csv/nhgis0034_ds258_2020_block.csv"
    )
  ) %>%
  mutate(
    blk_fips =
      paste0(
        substr(.$GISJOIN, 2, 3),
        substr(.$GISJOIN, 5, 7),
        substr(.$GISJOIN, 9, 18) #Use GISJOIN to create a census block FIPS code column
      ),
    Urban_Rural = case_when((URA == "R")  ~ 1, TRUE ~ 0)
    # Convert Rural/Urban to 0/1 for later calculation of population weighted data
  )