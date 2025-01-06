# TARGET: 
# INDATA: 
# OUTDATA/ OUTPUT:

################################################################################################################+
# INTRO	script-specific ####

#clear gobal environment of all but uppercase objects (globals, myfunctions, scalars)
CLEARCOND()

#get scriptname
MAINNAME <- current_filename()#returns path+name of sourced script (from currently executed master script)
if(is.null(MAINNAME)){
  MAINNAME <- rstudioapi::getActiveDocumentContext()$path #dto. of currently executed script
}
MAINNAME <- sub(".*/|^[^/]*$", "", MAINNAME)
MAINNAME <- substr(MAINNAME,1,nchar(MAINNAME)-2) #cut off .R
######################+
#release unused memory 
gc()

######################################+
# MAIN PART ####

load(paste0(TEMP,"/EHPM_subsample.rda"))
df<- EHPM_subsample
remove(EHPM_subsample)

set.seed(SEED)

## PSM via LASSO ####
# Note: this part can take a while, so if you wish to continue inspecting
# the rest of scrips, feel free to use the provided version in the `TEMP`

# Define the LASSO-based PSM function
perform_psm_lasso <- function(year, data) {
  # Filter the data for the specified year
  df_aux <- data %>% filter(year == !!year)
  
  # Set up the treatment indicator and covariates
  D <- df_aux$treat
  
  # Define the covariates for the design matrix (adjust columns as needed)
  covariates <- df_aux[, c("socdemo_area","socdemo_region","socdemo_age", "socdemo_civil", "socdemo_gen",
                           "employ_status", 
                           "income_remitances", "income_relav","income_alimony")]
  
  # Create the design matrix, including interactions
  X <- model.matrix(~ .^2, data = covariates)
  
  # Fit LASSO model with cross-validation to get propensity scores
  lasso_p <- cv.glmnet(X, D, alpha = 1, family = "binomial")
  Phat <- predict(lasso_p, s = "lambda.min", newx = X, type = "response")
  
  # Add the propensity score to the data frame
  df_aux$propensity_score <- Phat
  
  # Perform the matching based on LASSO propensity scores
  match_result <- matchit(treat ~ propensity_score, 
                          data = df_aux, method = "nearest", distance = "logit", caliper = 0.5)
  
  # Return the matched data
  matched_data <- match.data(match_result)
  return(matched_data)
}

# Initialize an empty data frame to store matched results
df_matched <- data.frame()

# Get unique years from the dataset
unique_years <- unique(df$year)

# Loop through each year and perform PSM with LASSO
for (year in unique_years) {
  matched_year_data <- perform_psm_lasso(year, df)  # Call the LASSO function for each year
  df_matched <- bind_rows(df_matched, matched_year_data)  # Combine results
}

## Save the matched dataframe #####
save(df_matched,file = file.path(paste0(TEMP,"/tourism_subsample_matched.rda")))
