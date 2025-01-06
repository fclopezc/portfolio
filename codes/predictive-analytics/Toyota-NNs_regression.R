# Neural Networks for Car Price Prediction
# Franklin López

# Load Required Libraries ----
library(caret)        # For data preprocessing and model evaluation
library(caTools)      # For data splitting
library(neuralnet)    # For fitting neural network models
library(Metrics)      # For calculating performance metrics
library(fastDummies)  # For creating dummy variables (if necessary)
library(dplyr)
library(Metrics)



# Data Loading and Preprocessing ----
#toyota.df <- read.csv(choose.files())  # Load the dataset
toyota.df <- read.csv("datasets/ToyotaCorolla.csv")

# Select Relevant Variables for the Model
toyota.df <- toyota.df[, c("Price", "Age_08_04", "KM", "Fuel_Type", "HP", "Automatic", 
                           "Doors", "Quarterly_Tax", "Mfr_Guarantee", "Guarantee_Period", 
                           "Airco", "Automatic_airco", "CD_Player", "Powered_Windows", 
                           "Sport_Model", "Tow_Bar")]

## Dummy variables----

# List of categorical variables to convert to dummy variables
categorical_vars <- c("Fuel_Type","Doors")

# Transforming dummy variables
toyota.df <- dummy_cols(toyota.df, select_columns = categorical_vars, remove_first_dummy = TRUE)
toyota.df <- toyota.df %>% select(-Fuel_Type, -Doors)

# Data splitting----
set.seed(1234567)

# Split the data into training (60%) and validation (40%) sets
split <- sample.split(toyota.df$Price, SplitRatio = 0.6)

train_data <- subset(toyota.df, split == TRUE)
validation_data <- subset(toyota.df, split == FALSE)

## Normalizing data sets ----
num_cols <- c("Price", "Age_08_04", "KM", "HP", "Quarterly_Tax", "Guarantee_Period")

preProc_train <- preProcess(train_data[,num_cols], method = "range")
preProc_valid <- preProcess(validation_data[,num_cols], method = "range")

# scaling
train_data[, num_cols] <- predict(preProc_train, train_data[, num_cols])
validation_data[, num_cols] <- predict(preProc_valid, validation_data[, num_cols])

# NNets: 1 hiddel layer, two nodes----
# Fitting the Neural Network Model with a Single Hidden Layer of 2 Nodes
nn_h1n2 <- neuralnet(Price ~ ., data = train_data, linear.output = TRUE, hidden = 2)
plot(nn_h1n2, rep="best")

# Calculating RMSE for Training Data
pred.train <- compute(nn_h1n2, train_data[, -1])$net.result  # Exclude the 'Price' column for prediction
error.train <- rmse(train_data[, "Price"], pred.train)
cat("RMSE for Training Data: ", error.train, "\n")

# Calculating RMSE for Validation Data
pred.valid <- compute(nn_h1n2, validation_data[, -1])$net.result  # Exclude the 'Price' column for prediction
error.valid <- rmse(validation_data[, "Price"], pred.valid)
cat("RMSE for Validation Data: ", error.valid, "\n")

# NNets: 1 hidden layer, 5 nodes----
# Fitting the Neural Network Model with a Single Hidden Layer of 2 Nodes
nn_h1n5 <- neuralnet(Price ~ ., data = train_data, linear.output = TRUE, hidden = 5)
plot(nn_h1n5, rep="best")

# Calculating RMSE for Training Data
pred.train_h1n5 <- compute(nn_h1n5, train_data[, -1])$net.result  # Exclude the 'Price' column for prediction
error.train_h1n5 <- rmse(train_data[, "Price"], pred.train_h1n5)
cat("RMSE for Training Data: ", error.train_h1n5, "\n")

# Calculating RMSE for Validation Data
pred.valid_h1n5 <- compute(nn_h1n5, validation_data[, -1])$net.result  # Exclude the 'Price' column for prediction
error.valid_h1n5 <- rmse(validation_data[, "Price"], pred.valid_h1n5)
cat("RMSE for Validation Data: ", error.valid_h1n5, "\n")

# NNets: 2 hidden layer, 5 nodes----
# Fitting the Neural Network Model with a Single Hidden Layer of 2 Nodes
nn_h2n5 <- neuralnet(Price ~ ., data = train_data, linear.output = TRUE, hidden = c(5,5))
plot(nn_h2n5, rep="best")

# Calculating RMSE for Training Data
pred.train_h2n5 <- compute(nn_h2n5, train_data[, -1])$net.result  # Exclude the 'Price' column for prediction
error.train_h2n5 <- rmse(train_data[, "Price"], pred.train_h2n5)
cat("RMSE for Training Data: ", error.train_h2n5, "\n")

# Calculating RMSE for Validation Data
pred.valid_h2n5 <- compute(nn_h2n5, validation_data[, -1])$net.result  # Exclude the 'Price' column for prediction
error.valid_h2n5 <- rmse(validation_data[, "Price"], pred.valid_h2n5)
cat("RMSE for Validation Data: ", error.valid_h2n5, "\n")
