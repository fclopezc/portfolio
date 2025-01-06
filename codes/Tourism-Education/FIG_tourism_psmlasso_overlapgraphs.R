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

load(paste0(TEMP,"/tourism_subsample_matched.rda"))
df<- df_matched
remove(df_matched)

df <- df %>% filter(year>=2015)

## Visual inspection ####

psm_p <- ggplot(df, aes(x = propensity_score, color = factor(treat))) +
  geom_density() +
  labs(title = "Density of Propensity Scores by Treatment Status",
       x = "Propensity Score", y = "Density")
psm_p
ggsave(paste0(FIGURE,"/FIG_psm_lasso.png"), plot = psm_p)