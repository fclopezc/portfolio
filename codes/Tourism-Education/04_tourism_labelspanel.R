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
load(paste0(TEMP,"/EHPM_panel.rda"))

# Asigning the levels of the categorical variables ####

## Sociodemographic
EHPM_panel <- EHPM_panel %>%
  mutate(socdemo_area = factor(socdemo_area, levels = c(0, 1), labels = c("Rural", "Urban")))

EHPM_panel <- EHPM_panel %>%
  mutate(socdemo_gen = factor(socdemo_gen, levels = c(1, 2), labels = c("Male", "Female")))

EHPM_panel <- EHPM_panel %>%
  mutate(socdemo_civil = factor(socdemo_civil, levels = c(1:6), 
                                labels = c("Accompanied", "Married", "Widowed", "Divorced", 
                                           "Separated", "Single")))
EHPM_panel <- EHPM_panel %>%
  mutate(socdemo_region = factor(socdemo_region, levels = c(1:5), 
                                 labels = c("Occidental","Central 1","Central 2","Oriental","AMSS")))

EHPM_panel$cod_munic <- with(EHPM_panel, 
                             paste0(socdemo_depart, 
                                    ifelse(nchar(socdemo_munic) == 1, 
                                           paste0("0", socdemo_munic), 
                                           socdemo_munic)))


EHPM_panel$exp_factor <- ceiling(EHPM_panel$exp_factor)

## Education ####

EHPM_panel <- EHPM_panel %>%
  mutate(educ_curr = factor(educ_curr, levels = c(1, 2), labels = c("Yes", "No")))

EHPM_panel <- EHPM_panel %>%
  mutate(educ_computer = factor(educ_computer, levels = c(1, 2), labels = c("Yes", "No")))

## Employment ####
EHPM_panel <- EHPM_panel %>%
  mutate(employ_status = factor(employ_status, levels = c(10, 20, 30), 
                                labels = c("Employed","Unemployed","Inactive")))

EHPM_panel <- EHPM_panel %>%
  mutate(employ_contract = factor(employ_contract, levels = c(1, 0), labels = c("Yes", "No")))

## Income ####
EHPM_panel <- EHPM_panel %>%
  mutate(income_poverty = factor(income_poverty, levels = c(1, 2, 3), 
                                 labels = c("Extreme poverty", "Relative poverty", "No poverty")))

# Save the dataframe ####
var_sample <- c("year", "socdemo_depart","cod_munic", "socdemo_area","socdemo_region", "socdemo_gen", 
                "socdemo_age", "socdemo_civil", "employ_firm_activ", 
                "employ_status", "employ_contract", 
                "educ_aprob1", "educ_curr", "educ_computer","ln_income",  
                "income_individual", "income_pc", "income_poverty", 
                "income_remitances", "income_relav", "income_alimony", 
                "income_saving","exp_factor")

EHPM_panel_lab <- EHPM_panel[,var_sample]

save(EHPM_panel_lab, file = file.path(TEMP, "/EHPM_panel_lab.rda"))
