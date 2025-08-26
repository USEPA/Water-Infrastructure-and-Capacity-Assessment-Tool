library(here)
library(vroom)
library(dplyr)

# This script identifies the date of a CWS's most recent complete sanitary survey and, identifies significant deficiencies or sanitary defects on the most recent sanitary survey

# Sanitary Survey Most Recent Date -----------
# Identify the date of the most recent complete sanitary survey
SDWA_SS_Most_Recent <- vroom(here("Input_Data/SDWIS/SDWA_san_survey.csv")) %>%
  arrange(PWSID, desc(VISIT_DATE)) %>%
  distinct(PWSID, .keep_all = TRUE)

# Identify any significant deficiencies or sanitary defects  -----------
# Create vector of infrastructure related survey elements (columns)
INFRASTRUCTURE_SURVEY_ELEMENTS <- c("SOURCE_WATER_EVAL_CODE", "SECURITY_EVAL_CODE", "PUMPS_EVAL_CODE", "OTHER_EVAL_CODE",
                                    "COMPLIANCE_EVAL_CODE", "DATA_VERIFICATION_EVAL_CODE", "TREATMENT_EVAL_CODE",
                                    "FINISHED_WATER_STOR_EVAL_CODE", "DISTRIBUTION_EVAL_CODE")

# Create vector of capacity related survey elements (columns)
CAPACITY_SURVEY_ELEMENTS <- c("MANAGEMENT_OPS_EVAL_CODE", "FINANCIAL_EVAL_CODE")

# Function to check for significant deficiencies or sanitary defects
Sig_Def_San_Defct <- function(data, columns_to_check) {
  # Apply a function to each row
  result <- apply(data[columns_to_check], 1, function(row) {
    # Check if any value in the row is "S" or "D"
    if (any(row %in% c("S", "D"))) {
      return("Y")
    } else {
      return("N")
    }
  })
  return(result)
}

# Run function to check for significant deficiencies or sanitary defects
SDWA_SS_Most_Recent$SS_SIGD_OR_SAND_INFRA_YN <- Sig_Def_San_Defct(SDWA_SS_Most_Recent, INFRASTRUCTURE_SURVEY_ELEMENTS)
SDWA_SS_Most_Recent$SS_SIGD_OR_SAND_CAP_YN <- Sig_Def_San_Defct(SDWA_SS_Most_Recent, CAPACITY_SURVEY_ELEMENTS)
  
# Select columns
SDWA_SS_Most_Recent <- SDWA_SS_Most_Recent %>%
  select(
    PWSID,
    VISIT_DATE,
    VISIT_REASON_CODE,
    SS_VISIT_FYQTR,
    SS_SIGD_OR_SAND_INFRA_YN,
    SS_SIGD_OR_SAND_CAP_YN,
    MANAGEMENT_OPS_EVAL_CODE,
    SOURCE_WATER_EVAL_CODE,
    SECURITY_EVAL_CODE,
    PUMPS_EVAL_CODE,
    OTHER_EVAL_CODE,
    COMPLIANCE_EVAL_CODE,
    DATA_VERIFICATION_EVAL_CODE,
    TREATMENT_EVAL_CODE,
    FINISHED_WATER_STOR_EVAL_CODE,
    DISTRIBUTION_EVAL_CODE,
    FINANCIAL_EVAL_CODE
  )

# Export
write.csv(SDWA_SS_Most_Recent, here("R/CWS_Analysis/03_Join_Enforc_Compl_Data/01_Join_Enf_Compl_Data/SDWA_SS_Most_Recent.csv"), row.names = FALSE)
