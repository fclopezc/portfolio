# PROJECT'S FULL NAME

# TARGET (of this R.script): ordered execution of R.script(s) within public file routine
#NO detailed descriptions of data, method, etc. HERE -> done in R.scripts called upon

# CONVENTIONS of file naming, abbreviations:

#R.scripts: 	in general 		-> named like the dataset they produce, i.e., _varcreation_x.R
#PROGRAMS: 	-> CAPITAL LETTERS, automatically called upon by R.script executed

################################################################################################################+
# INTRO ####

#clear console
cat("/014")

#clear all globals in memory
rm(list = ls()) #needs to go before user-written functions (not libraries) are loaded
sink()

######################+
# non-automatable globals #####

#for master scriptname and extension #####
library(rstudioapi)
MAINNAME <- rstudioapi::getActiveDocumentContext()$path #returns path+name
MAINNAME <- sub(".*/|^[^/]*$", "", MAINNAME)
MAINNAME <- substr(MAINNAME,1,nchar(MAINNAME)-2) #cut off .R

# paths ####

HOME <- choose.dir() # This will display a command where you can select the path to 'projects' dir
# However if you wish, just change the dir below to adapt to your own projects dir
#HOME <- "C:/Users/frank/OneDrive - Escuela Superior de Economia y Negocios/3. WS 2024/AppMacro/projects" #here: path to 'projects' dir 
DO <- paste0(HOME,"/project_tourism/c_program/") #here: path to folder with R.code


######################+
# launch set-up scripts #####
input <- '00_execute_tourism_intro_aux.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)
#DEBUG <- T

##################################+
# Project #####

## Panel data ####

# Defining the relevant variables per survey
## This scrip create a dataframe that will contain all the relevant variables
## that need to be extracted
input <- '01_tourism_relvar.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

# Creating lite versions of the EHPMs
## As each EHPM has more than 800 variables, and not all are codified in same way
## this scrip creates "lite" versions of each one, in order to demand
## less computational resources.
## Note: This can take a while!
input <- '02_tourism_surveys.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

# Merging all the surveys in one single dataframe
## Once the lite versions are created and the name of the variables are
## homogeneous across editions, this scrip bind them into one single
## quasi-panel dataframe
input <- '03_tourism_panelcreation.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

# Assigning the labels to categorical variables
## Since some variable are categorical, this scripts transform them
## into factors
input <- '04_tourism_labelspanel.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

# Extracting the subsample of interest
## Once, the final quasi-panel df is created and labeled
## This scrip extract the target subsample
input <- '05_tourism_subsample.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Balance test and PSM ####

# Checking the Common trend assumption of outcomes

## Visual inspection
### In order to see the evolution, this scrip generates the
### plot to observe it
input <- '06_tourism_trendgraphs.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Formal tests
### This scrip perform t-test and Xi-test to formalize
### the unbalance between groups.
input <- '07_tourism_balancetest.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

### Performing a PSM via Logit ####

## Since the groups are initially unbalanced, I performed a
## Traditional logistic regression to estimate the PSM,
## Then, I used these to matching
input <- '08_tourism_psm_logit.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

# Checking balance test after PSM
## Visual
### This scrip offers a visual inspection of the trends after performing the PSM
input <- '09_tourism_psmlogit_trendgraphs.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Formal test
### This scrip perform t-test and Xi-test to inspect
### any remaining unbalance between groups.
input <- '09_tourism_psmlogit_balancetest.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Overlapping
### if you wish to see the overlap between the PS distributions
### The following scrip has the code that produce that figure
input <- 'FIG_tourism_psmlogit_overlapgraphs.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

### Performing a PSM via LASSO ####

## Since the groups are initially unbalanced, I performed a
## LASSO logistic regression to estimate the PSM. Then, I used these to matching
## Note: this can take a while, so there is a version of the matched subsample already
input <- '08_tourism_psm_lasso.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

# Checking balance test after PSM
## Visual
### This scrip offers a visual inspection of the trends after performing the PSM
input <- '09_tourism_psmlasso_trendgraphs.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Formal test
### This scrip perform t-test and Xi-test to inspect
### any remaining unbalance between groups.
input <- '09_tourism_psmlasso_balancetest.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Overlapping
### if you wish to see the overlap between the PS distributions
### The following scrip has the code that produce that figure
input <- 'FIG_tourism_psmlasso_overlapgraphs.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Regression analysis ####

## This scrip contain the regressions ran for the analysis.
#The output of set of 5 regressions, column (1) subsample without PSM
# nor control, (2)-(3) subsamples after PSM via logit, (4)-(5) after PSM via LASSO
# The output of 1 regressions is the subsample without PSM and controls
## Note: this approach is to make easy to read via R console. In the slides there
## is a version that integrates the 6 regressions, for both outcomes variables.
input <- '10_tourism_regressions.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)

## Placebo test ####
#In order to ensure causal identification, the following script presents the placebo test,
#running the same specifications of the previous regressions but only in the pre-intervention period.
input <- '11_tourism_placebo.R'
source(paste0(DO,input,sep=""), echo=TRUE, max=1000)