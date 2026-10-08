This script in this folder are used to import select tables from the ACS 5-year survey. variables within these tables are used to then calculate specific demographic/economic variables of interest at the census ***** scale.

These tract statistics are joined with PWS and POTW crosswalk tables. These joins are conduced within the CWS and POTW Analyses folders.

imports 5-year American Community Survey data directly from IPUMS, NHGIS (https://www.nhgis.org/)
Instructions for importing from NHGIS: https://assets.ipums.org/_files/webinars/slides/nhgis03-05-24.pdf

The following tables are going to be extracted

#   1. Total Population
# Universe:    Total population
# Source code: P1
# NHGIS code:  U7H

# 2. Urban and Rural
# Universe:    Total population
# Source code: P2
# NHGIS code:  U7I

# 3. Housing Units
# Universe:    Housing units
# Source code: H1
# NHGIS code:  U9V