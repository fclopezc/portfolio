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

# List of dataset names
dataset_names <- c("EHPM_2009", "EHPM_2010", "EHPM_2011", "EHPM_2012", "EHPM_2013", 
                   "EHPM_2014", "EHPM_2015", "EHPM_2016", "EHPM_2017", "EHPM_2018", 
                   "EHPM_2019", "EHPM_2021", "EHPM_2022", "EHPM_2023")

# Loop through dataset names and load each .rda file
for (dataset_name in dataset_names) {
  file_path <- file.path(TEMP, paste0(dataset_name, ".rda"))  # Construct file path
  
  if (file.exists(file_path)) {
    load(file_path)  # Load the .rda file into the environment
    assign(dataset_name, get(dataset_name))  # Assign the dataset to its name in the environment
  } else {
    message(paste("File not found:", file_path))  # Notify if the file doesn't exist
  }
}

datasets <- list(EHPM_2009 = EHPM_2009, EHPM_2010 = EHPM_2010,
                 EHPM_2011 = EHPM_2011, EHPM_2012 = EHPM_2012, EHPM_2013 = EHPM_2013,
                 EHPM_2014 = EHPM_2014, EHPM_2015 = EHPM_2015,EHPM_2016 = EHPM_2016,
                 EHPM_2017 = EHPM_2017, EHPM_2018 = EHPM_2018, EHPM_2019 = EHPM_2019,
                 EHPM_2021 = EHPM_2021,EHPM_2022 = EHPM_2022,EHPM_2023 = EHPM_2023)

###########################################+
## working with remaining categorical variables ####

### employ_status ####

# Function to replace values in the [20, 30) range with 20
replace_employ_status <- function(data) {
  data <- data %>%
    mutate(employ_status = ifelse(employ_status >= 20 & employ_status < 30, 20, employ_status))
  return(data)
}

# Apply the transformation to all datasets in the list
datasets <- lapply(datasets, replace_employ_status)

### employ_contract ####

# Function to transform employ_contract based on dataset year range
transform_employ_contract <- function(data, dataset_name) {
  
  # Extract the year from the dataset name
  dataset_year <- as.numeric(sub("EHPM_", "", dataset_name))
  
  # Apply different transformations based on the dataset year
  if (dataset_year >= 2008 & dataset_year <= 2013) {
    # For 2008 to 2013: Replace 2 and 3 with 0
    data <- data %>%
      mutate(employ_contract = case_when(
        employ_contract == 2 | employ_contract == 3 ~ 0,
        is.na(employ_contract) ~ NA_real_,
        TRUE ~ employ_contract
      ))
    
  } else if (dataset_year >= 2014 & dataset_year <= 2023) {
    # For 2014 to 2019: Replace [1, 6] with 1 and [7, 8] with 0
    data <- data %>%
      mutate(employ_contract = case_when(
        employ_contract >= 1 & employ_contract <= 6 ~ 1,
        employ_contract >= 7 & employ_contract <= 8 ~ 0,
        is.na(employ_contract) ~ NA_real_,
        TRUE ~ employ_contract
      ))
  }
  
  return(data)
}

# Apply the transformation to all datasets
datasets <- imap(datasets, transform_employ_contract)

###########################################+
## Merging all into one single dataframe ####

# Function to convert all columns to numeric
convert_to_numeric <- function(data) {
  data <- data %>%
    mutate_all(as.numeric)
  return(data)
}

# Apply the numeric conversion to all datasets
datasets <- map(datasets, convert_to_numeric)

# Combine all datasets into a single dataframe (panel data)
EHPM_panel <- bind_rows(datasets)

remove(list = dataset_names)

# avoiding N/A

EHPM_panel <- EHPM_panel %>%
  mutate_at(vars(income_remitances, income_relav, income_alimony, income_saving), 
            ~replace(., is.na(.), 0))

# Creating Ln(Income)

EHPM_panel <- EHPM_panel %>%
  mutate(ln_income = ifelse(income_pc > 0, log(income_pc), 0))

# Save the dataset

save(EHPM_panel, file = file.path(TEMP, "EHPM_panel.rda"))
