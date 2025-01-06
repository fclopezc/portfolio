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

df <- df %>% filter(year>=2015)

## Visual inspection ####

income_psm <- ggplot(df, aes(x = year, y = ln_income, color = as.factor(treat), fill = as.factor(treat))) +
  stat_summary(geom = "line", fun = "mean") +
  stat_summary(geom = "ribbon", fun.data = mean_cl_normal, alpha = 0.2) +
  labs(title = "Income trends", y = "ln(Income per Capita)", x = "Year", color = "Group") +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red") +
  theme_minimal()
income_psm
#ggsave(paste0(FIGURE,"/income_trends_psm.png"), plot = income_psm)

education_psm <- ggplot(df, aes(x = year, y = ln_educ, color = as.factor(treat), fill = as.factor(treat))) +
  stat_summary(geom = "line", fun = "mean") +
  stat_summary(geom = "ribbon", fun.data = mean_cl_normal, alpha = 0.2) +
  labs(title = "Education trends", y = "ln(Years of education completed)", x = "Year", color = "Group") +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red") +
  theme_minimal()
education_psm
#ggsave(paste0(FIGURE,"/education_trends_psm.png"), plot = education_psm)

## Saving both plots
combined_plot <- grid.arrange(income_psm, education_psm, ncol = 2)

# Save the combined plot
ggsave(paste0(FIGURE, "/FIG_trends_logit.png"), plot = combined_plot, width = 12, height = 6)

