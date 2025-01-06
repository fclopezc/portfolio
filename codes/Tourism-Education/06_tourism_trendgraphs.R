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

# Filter the years
## Note: this was not done in the previous scrip since all years
## will be used in next scrip.
df <- df %>% filter(year>=2015)

## Visual inspection ####

income <- ggplot(df, aes(x = year, y = ln_income, color = as.factor(treat), fill = as.factor(treat))) +
  stat_summary(geom = "line", fun = "mean") +
  stat_summary(geom = "ribbon", fun.data = mean_cl_normal, alpha = 0.2) +
  labs(title = "Income trends", y = "ln(Income per Capita)", x = "Year", color = "Group") +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red") +
  theme_minimal()
income
#ggsave(paste0(FIGURE,"/FIG_income_trends.png"), plot = income)

education <- ggplot(df, aes(x = year, y = ln_educ, color = as.factor(treat), fill = as.factor(treat))) +
  stat_summary(geom = "line", fun = "mean") +
  stat_summary(geom = "ribbon", fun.data = mean_cl_normal, alpha = 0.2) +
  labs(title = "Education trends", y = "ln(Years of education completed)", x = "Year", color = "Group") +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red") +
  theme_minimal()
education
# If you wish to save this plot activate the comment below
#ggsave(paste0(FIGURE,"/FIG_education_trends.png"), plot = education)

## Saving both plots
combined_plot <- grid.arrange(income, education, ncol = 2)

# Save the combined plot
ggsave(paste0(FIGURE, "/FIG_trends.png"), plot = combined_plot, width = 12, height = 6)

