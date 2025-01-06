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
load(paste0(TEMP,"/EHPM_panel_lab.rda"))
dep_geo <- read_excel(paste0(A,"/dep_geo.xlsx"))

df<- right_join(EHPM_panel_lab,dep_geo,by="socdemo_depart")
remove(dep_geo,EHPM_panel_lab)

## Creating the subsample
EHPM_subsample <- df %>%
  filter(socdemo_age >= 18 & socdemo_age <= 24 & socdemo_region!="AMSS"
         & socdemo_depart!=6)

EHPM_subsample$post <- ifelse(EHPM_subsample$year >= 2020, 1, 0)

EHPM_subsample <- EHPM_subsample %>%
  mutate(ln_educ = ifelse(educ_aprob1 > 0, log(educ_aprob1), 0))

save(EHPM_subsample,file = file.path(paste0(TEMP,"/EHPM_subsample.rda")))