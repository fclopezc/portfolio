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

rel_var <- read.csv(paste0(TEMP,"/relevant_variables.csv",sep=""), stringsAsFactors = FALSE)

# Function to rename columns
rename_columns <- function(data, new_names) {
  names(data) <- new_names
  return(data)
}

## For 2009 to 2019 ####
years <- c(2009:2019)

# Loop through each year to load and process datasets
for (year in years) {
  # Dynamically construct the file names and variable names
  file_name <- paste0(A,"/EHPM_", year, ".rda")
  var_col <- paste0("rv", year)
  
  # Load the dataset
  load(file_name)
  
  # Dynamically refer to the dataset by name using get() and assign()
  dataset_name <- paste0("EHPM_", year)
  dataset <- get(dataset_name)
  
  # Subset and rename columns
  dataset <- dataset[, rel_var[[var_col]]]
  dataset <- rename_columns(dataset, rel_var$var_name)
  
  # Assign the modified dataset back to the original variable
  assign(dataset_name, dataset)
}

## From 2021 to 2023 ####

# Function to process each dataset
process_EHPM <- function(year) {
  # Load the dataset file
  data_file <- paste0(A,"/EHPM_", year, ".rda")
  load(data_file)
  
  # Get the data frame dynamically
  data_name <- get(paste0("EHPM_", year))
  
  # Dynamically get relevant variables for the year
  relevant_vars <- rel_var[[paste0("rv", year)]]
  var_names <- rel_var$var_name
  
  # Create r004 and r005 variables
  data_name$r004 <- ifelse(nchar(data_name$codigomunic) == 3,
                           substr(data_name$codigomunic, 1, 1),    # Take the first character if length is 3
                           substr(data_name$codigomunic, 1, 2))    # Take the first two characters if length is 4
  data_name$r005 <- substr(data_name$codigomunic, nchar(data_name$codigomunic) - 1, nchar(data_name$codigomunic))
  
  # Select relevant columns and rename them
  data_name <- data_name[, relevant_vars]
  data_name <- rename_columns(data_name, var_names)
  
  return(data_name)
}

# Loop over the years to process each dataset
EHPM_list <- lapply(2021:2023, process_EHPM)

EHPM_2021 <- EHPM_list[[1]]
EHPM_2022 <- EHPM_list[[2]]
EHPM_2023 <- EHPM_list[[3]]

## Save all this dataframe ####

datasets <- list(EHPM_2009 = EHPM_2009, EHPM_2010 = EHPM_2010,
                 EHPM_2011 = EHPM_2011, EHPM_2012 = EHPM_2012, EHPM_2013 = EHPM_2013,
                 EHPM_2014 = EHPM_2014, EHPM_2015 = EHPM_2015,EHPM_2016 = EHPM_2016,
                 EHPM_2017 = EHPM_2017, EHPM_2018 = EHPM_2018, EHPM_2019 = EHPM_2019,
                 EHPM_2021 = EHPM_2021,EHPM_2022 = EHPM_2022,EHPM_2023 = EHPM_2023)

# Loop through the list and save each dataset
for (dataset_name in names(datasets)) {
  # Get the dataset
  dataset <- datasets[[dataset_name]]
  
  # Construct the full file path for saving
  save_path <- paste0(TEMP,"/", dataset_name, ".rda")
  
  # Save the dataset with the name of the dataset in the global environment
  save(list = dataset_name, file = save_path)
}

## Remove all the EHPMs sub samples created

dataset_names <- c("EHPM_2009", "EHPM_2010", "EHPM_2011", "EHPM_2012", "EHPM_2013", 
                   "EHPM_2014", "EHPM_2015", "EHPM_2016", "EHPM_2017", "EHPM_2018", 
                   "EHPM_2019", "EHPM_2021", "EHPM_2022", "EHPM_2023")

remove(list = dataset_names)