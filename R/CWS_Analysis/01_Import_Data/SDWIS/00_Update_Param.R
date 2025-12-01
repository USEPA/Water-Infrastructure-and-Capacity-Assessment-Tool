# This script needs to be updated quarterly. It sets the key date parameters for the SDWIS data pulled.

load("R/CWS_Analysis/01_Import_Data/SDWIS/compliance_period_begin_date.Rdata")
j <- as.yearqtr("2025 Q3")
k <- "2025Q3"
COMPL_PER_BEGIN_DATE_SELECT <- "31-JAN-20"
save(k, j, COMPL_PER_BEGIN_DATE_SELECT, file = "R/CWS_Analysis/01_Import_Data/SDWIS/compliance_period_begin_date.Rdata")
