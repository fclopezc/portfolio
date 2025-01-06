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

load(paste0(TEMP,"/tourism_subsample_matched_t.rda"))
df<- df_matched
remove(df_matched)

# Defining the pre and post periods
#dfpre <- df %>% filter(post==0)
dfpre<- df %>% filter(year %in% 2015:2019) 
dfpost <- df %>% filter(post==1)

## Balance test: continuous variables ####

cat("\n--- T-tests for continuous variables between Treatment and Control ---\n")
t_age <- t.test(socdemo_age ~ treat, data = dfpre)
t_income_remitances <- t.test(income_remitances ~ treat, data = dfpre)
t_income_relav <- t.test(income_relav ~ treat, data = dfpre)
t_income_alimony <- t.test(income_alimony ~ treat, data = dfpre)

# Display t-test results
cat("Age T-test:\n")
print(t_age)
cat("\nRemittances T-test:\n")
print(t_income_remitances)
cat("\nRelatives Aid T-test:\n")
print(t_income_relav)
cat("\nAlimony T-test:\n")
print(t_income_alimony)

## Balance test: categorical variables ####
cat("\n--- Chi-square tests for categorical variables between Treatment and Control ---\n")

# Gender
cat("\nGender Chi-square test:\n")
chisq_gen <- chisq.test(table(dfpre$treat, dfpre$socdemo_gen))
print(chisq_gen)

# Civil Status
cat("\nCivil Status Chi-square test:\n")
chisq_civil <- chisq.test(table(dfpre$treat, dfpre$socdemo_civil))
print(chisq_civil)

# Employment Status
cat("\nEmployment Status Chi-square test:\n")
chisq_employ <- chisq.test(table(dfpre$treat, dfpre$employ_status))
print(chisq_employ)

## Exporting variables to results ####

## Store results in a data frame
t_test_results <- data.frame(
  Variable = c("Age", "Remittances", "Relatives Aid", "Alimony"),
  Test_Statistic = c(t_age$statistic, t_income_remitances$statistic, 
                     t_income_relav$statistic, t_income_alimony$statistic),
  P_value = c(t_age$p.value, t_income_remitances$p.value, 
              t_income_relav$p.value, t_income_alimony$p.value)
)

## Store chi-square results in a data frame
chi_square_results <- data.frame(
  Variable = c("Gender", "Civil Status", "Employment Status"),
  Test_Statistic = c(chisq_gen$statistic, chisq_civil$statistic, chisq_employ$statistic),
  P_value = c(chisq_gen$p.value, chisq_civil$p.value, chisq_employ$p.value)
)

# Combine results into a single summary table
bal_test <- bind_rows(
  t_test_results %>% mutate(Test_Type = "T-test"),
  chi_square_results %>% mutate(Test_Type = "Chi-square")
)


## Exporting to results####
latex_output <- xtable(bal_test)

# Save the LaTeX table to a file
print(latex_output, 
      file = paste0(D,"/TAB_bal_test_logit.tex"), # Specify the path where you want to save
      include.rownames = FALSE, # Do not include row names in the output
      booktabs = TRUE) # Use booktabs style for better formatting