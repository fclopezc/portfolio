# Classifications and performance
# Franklin Lopez

# =====================+
# 1. Load Libraries----
# =====================+
# Import necessary libraries
library(MASS)        # For LDA
library(neuralnet)   # For Neural Networks
library(caret)       # For machine learning utilities
library(caTools)     # For data partitioning
library(tidyverse)   # For data wrangling and visualization

# =====================+
# 2. Load Data----
# =====================+
df <- read.csv(file.choose(), stringsAsFactors = TRUE)

# =====================+
# 3. Define Metric Calculation Function----
# =====================+
calculate_metrics <- function(conf_matrix) {
  # Extract TP, TN, FP, FN
  TP <- conf_matrix["Yes", "Yes"]
  TN <- conf_matrix["No", "No"]
  FP <- conf_matrix["No", "Yes"]
  FN <- conf_matrix["Yes", "No"]
  
  # Accuracy
  accuracy <- (TP + TN) / sum(conf_matrix)
  
  # Misclassification Error
  misclassification_error <- (FP + FN) / sum(conf_matrix)
  
  # Precision
  precision <- TP / (TP + FP)
  
  # Recall
  recall <- TP / (TP + FN)
  
  # F1-Score
  f1_score <- 2 * (precision * recall) / (precision + recall)
  
  # Return all metrics
  return(list(Accuracy = accuracy,
              Misclassification_Error = misclassification_error,
              Precision = precision,
              Recall = recall,
              F1_Score = f1_score))
}

# =====================+
# 4. LDA Analysis with Metrics----
# =====================+
lda_analysis <- function(train_data, valid_data) {
  # Train LDA model
  lda_model <- lda(Completed.task ~ ., data = train_data)
  
  # Predict on training data
  train_predictions <- predict(lda_model, newdata = train_data)
  
  # Predict on validation data
  valid_predictions <- predict(lda_model, newdata = valid_data)
  
  # Confusion matrices
  train_cm <- table(train_data$Completed.task, train_predictions$class)
  valid_cm <- table(valid_data$Completed.task, valid_predictions$class)
  
  # Print confusion matrices
  cat("\nLDA Training Confusion Matrix:\n")
  print(train_cm)
  cat("\nLDA Validation Confusion Matrix:\n")
  print(valid_cm)
  
  # Calculate and display metrics for training and validation data
  cat("\nLDA Training Metrics:\n")
  train_metrics <- calculate_metrics(train_cm)
  print(train_metrics)
  
  cat("\nLDA Validation Metrics:\n")
  valid_metrics <- calculate_metrics(valid_cm)
  print(valid_metrics)
  
  # Return metrics for comparison
  return(list(train_metrics = train_metrics, valid_metrics = valid_metrics))
}

# =====================+
# 5. Neural Network Analysis with Metrics----
# =====================+
nn_analysis <- function(train_data, valid_data) {
  # Preprocessing: Convert outcome variable to numeric
  train_data$Completed.task <- as.numeric(train_data$Completed.task) - 1
  valid_data$Completed.task <- as.numeric(valid_data$Completed.task) - 1
  
  # Scale numeric predictor columns
  train_data_scaled <- train_data
  valid_data_scaled <- valid_data
  numeric_columns <- sapply(train_data[, -ncol(train_data)], is.numeric) # Exclude target
  
  train_data_scaled[, numeric_columns] <- scale(train_data[, numeric_columns])
  valid_data_scaled[, numeric_columns] <- scale(valid_data[, numeric_columns])
  
  # Train Neural Network
  nn_model <- neuralnet(
    formula = Completed.task ~ Experience + Training,
    data = train_data_scaled,
    hidden = 5,
    linear.output = FALSE
  )
  
  # Plot the Neural Network
  plot(nn_model, rep = "best")
  
  # Predict on training data
  train_predictions <- neuralnet::compute(nn_model, train_data_scaled[, numeric_columns])$net.result
  
  # Predict on validation data
  valid_predictions <- neuralnet::compute(nn_model, valid_data_scaled[, numeric_columns])$net.result
  
  # Threshold predictions (binary classification)
  train_predictions <- ifelse(train_predictions > 0.5, 1, 0)
  valid_predictions <- ifelse(valid_predictions > 0.5, 1, 0)
  
  # Convert back to original factor labels for interpretation
  train_predictions <- factor(train_predictions, levels = c(0, 1), labels = c("No", "Yes"))
  valid_predictions <- factor(valid_predictions, levels = c(0, 1), labels = c("No", "Yes"))
  
  # Confusion matrices
  train_cm <- table(factor(train_data$Completed.task, levels = c(0, 1), labels = c("No", "Yes")), train_predictions)
  valid_cm <- table(factor(valid_data$Completed.task, levels = c(0, 1), labels = c("No", "Yes")), valid_predictions)
  
  # Print confusion matrices
  cat("\nNN Training Confusion Matrix:\n")
  print(train_cm)
  cat("\nNN Validation Confusion Matrix:\n")
  print(valid_cm)
  
  # Calculate and display metrics for training and validation data
  cat("\nNN Training Metrics:\n")
  train_metrics <- calculate_metrics(train_cm)
  print(train_metrics)
  
  cat("\nNN Validation Metrics:\n")
  valid_metrics <- calculate_metrics(valid_cm)
  print(valid_metrics)
  
  # Return metrics for comparison
  return(list(train_metrics = train_metrics, valid_metrics = valid_metrics))
}

# =====================+
# 6. Partition Data and Compare Models----
# =====================+
# Function to partition data
partition_data <- function(data, split_ratio = 0.75, seed = 1234567) {
  set.seed(seed)
  split <- sample.split(data$Completed.task, SplitRatio = split_ratio)
  train <- subset(data, split == TRUE)
  valid <- subset(data, split == FALSE)
  return(list(train = train, valid = valid))
}

# Partition the data
data_split <- partition_data(df)
train_df <- data_split$train
valid_df <- data_split$valid

# Run LDA and Neural Network analysis
lda_metrics <- lda_analysis(train_df, valid_df)
nn_metrics <- nn_analysis(train_df, valid_df)

# Compare the models based on Validation Metrics
cat("\nModel Comparison (Validation Metrics):\n")
cat("\nLDA Validation Accuracy: ", lda_metrics$valid_metrics$Accuracy, "\n")
cat("NN Validation Accuracy: ", nn_metrics$valid_metrics$Accuracy, "\n")

# Compare the models based on the other metrics
cat("\nLDA vs NN Performance Comparison (F1-Score, Precision, Recall):\n")
cat("LDA Validation F1-Score: ", lda_metrics$valid_metrics$F1_Score, "\n")
cat("NN Validation F1-Score: ", nn_metrics$valid_metrics$F1_Score, "\n")

cat("LDA Validation Precision: ", lda_metrics$valid_metrics$Precision, "\n")
cat("NN Validation Precision: ", nn_metrics$valid_metrics$Precision, "\n")

cat("LDA Validation Recall: ", lda_metrics$valid_metrics$Recall, "\n")
cat("NN Validation Recall: ", nn_metrics$valid_metrics$Recall, "\n")
