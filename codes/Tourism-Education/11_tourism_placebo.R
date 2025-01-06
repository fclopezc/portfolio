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
load_and_filter <- function(filepath, years) {
  data <- get(load(filepath)) %>% 
    filter(year %in% years) %>% 
    mutate(post = ifelse(year >= 2018, 1, 0)) # Add 'post' column
  return(data) # Return the modified data
}

years_to_filter <- 2015:2019

df <- load_and_filter(paste0(TEMP, "/EHPM_subsample.rda"), years_to_filter)
df0 <- load_and_filter(paste0(TEMP, "/tourism_subsample_matched_t.rda"), years_to_filter)
df1 <- load_and_filter(paste0(TEMP, "/tourism_subsample_matched.rda"), years_to_filter)

controls_formula <- paste(c("income_relav", "income_remitances", "income_alimony",
                            "socdemo_civil", "employ_status"), collapse = " + ")

#######################'
## Income effects ####
reg_income1 <- lm(ln_income ~ post + treat + post*treat, 
                  data = df)

income_cotrol <- as.formula(paste("ln_income ~ post + treat + post*treat +", controls_formula))
reg_income2 <- lm(income_cotrol, data = df)

reg_income3 <- lm(ln_income ~ post + treat + post*treat, 
                  data = df0)

reg_income4 <- lm(ln_income ~ post + treat + post*treat + income_relav, 
                  data = df0)

reg_income5 <- lm(ln_income ~ post + treat + post*treat, 
                  data = df1)

reg_income6 <- lm(ln_income ~ post + treat + post*treat + income_relav, 
                  data = df1)

stargazer(reg_income1, reg_income3,
          reg_income4,reg_income5,reg_income6, 
          type = "text")

stargazer(reg_income2, type = "text")

#######################'
## Education effects ####
reg_educ1 <- lm(ln_educ ~ post + treat + post*treat, 
                data = df)

educ_cotrol <- as.formula(paste("ln_educ ~ post + treat + post*treat +", controls_formula))
reg_educ2 <- lm(educ_cotrol, data = df)

reg_educ3 <- lm(ln_educ ~ post + treat + post*treat, 
                data = df0)

reg_educ4 <- lm(ln_educ ~ post + treat + post*treat + income_relav, 
                data = df0)

reg_educ5 <- lm(ln_educ ~ post + treat + post*treat, 
                data = df1)

reg_educ6 <- lm(ln_educ ~ post + treat + post*treat + income_relav, 
                data = df1)

stargazer(reg_educ1, reg_educ3,
          reg_educ4,reg_educ5,reg_educ6, 
          type = "text")

stargazer(reg_educ2, type = "text")