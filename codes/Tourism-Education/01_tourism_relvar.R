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

################################################################################################################+
# MAIN PART ####

## Defining relevant variables per edition ####

var_name <- c("year", "socdemo_depart","socdemo_munic", "socdemo_area","socdemo_region", "socdemo_gen", 
                   "socdemo_age", "socdemo_civil", "employ_firm_activ", 
                   "employ_status", "employ_contract", 
                   "educ_aprob1", "educ_curr", "educ_computer", 
                   "income_individual", "income_pc", "income_poverty", 
                   "income_remitances", "income_relav", "income_alimony", 
                   "income_saving","exp_factor")

rv2009 <- c("Edicion", "R004","R005", "AREA","REGION", "R104", "R106", "R107", "R416", "ACTPR", 
            "R419", "APROBA1", "R203", "R33009A", "INGRE", "INGPE", 
            "POBREZA", "R44401A", "R44402A", "R44403A", "R44410A","FAC00")

rv2010 <- c("EDICION", "R004","R005", "AREA","REGION", "R104", "R106", "R107", "R416", "ACTPR", 
            "R4191", "APROBA1", "R203", "R2001B", "INGRE", "INGPE", 
            "POBREZA", "R44401A", "R44402A", "R44403A", "R44410A","FAC00")

rv2011 <- c("EDICION", "R004","R005", "AREA","REGION", "R104", "R106", "R107", "R416", "ACTPR", 
            "R4191", "APROBA1", "R203", "R2001B", "INGRE", "INGPE", 
            "POBREZA", "R44401A", "R44402A", "R44403A", "R44410A","FAC00")

rv2012 <- c("EDICION", "R004","R005", "AREA","region", "R104", "R106", "R107", "R416", "ACTPR2012", 
            "R419", "APROBA1", "R203", "R2001B", "INGRE", "INGPE", 
            "POBREZA", "R44401A", "R44402A", "R44403A", "R44410A","FAC00")

rv2013 <- c("EDICION", "R004","R005", "AREA","REGION", "R104", "R106", "R107", "R416", "actprORIGINAL", 
            "R419", "APROBA1", "R203", "R2001B", "INGRE", "INGPER", 
            "POBREZA", "R44401A", "R44402A", "R44403A", "R44410A","FAC00")

rv2014 <- c("EDICION", "R004","R005", "AREA","REGION", "R104", "R106", "R107", "R416", "actprORIGINAL", 
            "R419", "APROBA1", "R203", "R2001B", "INGRE", "INGPER", 
            "POBREZA", "R44401A", "R44402A", "R44403A", "R44410A","FAC00")

rv2015 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r2001b", "ingre", "ingpe", 
            "pobreza", "r44401a", "r44402a", "r44403a", "r44410a","fac00")

rv2016 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r1002b", "ingre", "ingpe", 
            "pobreza", "r44401a", "r44402a", "r44403a", "r44410a","fac00")

rv2017 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r1002b", "ingre", "ingpe", 
            "pobreza", "r44401a", "r44402a", "r44403a", "r44410a","fac00")

rv2018 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r1002b", "ingre", "ingpe", 
            "pobreza", "r44401a", "r44402a", "r44403a", "r44410a","fac00")

rv2019 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r1002b", "ingre", "ingpe", 
            "pobreza", "r44401a", "r44402a", "r44403a", "r44410a","fac00")

rv2021 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r32309a", "ingre", "ingpe", 
            "pobreza", "ingreso_remesas", "r44001a", "r44002a", "r44009a","fac00")

rv2022 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r32309a", "ingre", "ingpe", 
            "pobreza", "ingreso_remesas", "r44001a", "r44002a", "r44009a","fac00")

rv2023 <- c("edicion", "r004","r005", "area","region", "r104", "r106", "r107", "r416", "actpr", 
            "r419", "aproba1", "r203", "r32309a", "ingre", "ingpe", 
            "pobreza", "ingreso_remesas", "r44001a", "r44002a", "r44009a","fac00")

## Merging all variables ####
all_years <- list(var_name,rv2009, rv2010, rv2011, rv2012, rv2013, rv2014, 
                  rv2015, rv2016, rv2017, rv2018, rv2019, 
                  rv2021, rv2022, rv2023)

relevant_variables <- data.frame(lapply(all_years, `length<-`, max(lengths(all_years))), 
                                 stringsAsFactors = FALSE)

# Rename the columns to the respective years
colnames(relevant_variables) <- c("var_name","rv2009", "rv2010", "rv2011", "rv2012", "rv2013", "rv2014", 
                                  "rv2015", "rv2016", "rv2017", "rv2018", "rv2019", 
                                  "rv2021", "rv2022", "rv2023")

# Write the dataframe to the specified location as a CSV file
write.csv(relevant_variables, file = paste0(TEMP,"/relevant_variables.csv",sep=""), row.names = FALSE)

