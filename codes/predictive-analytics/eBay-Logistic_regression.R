# Ebay: Logistic Regression Analysis
# Franklin López

# Load Required Libraries ----
library(corrplot)
library(PerformanceAnalytics)
library(caTools)

# Step 1: Load and Split Data ----
eBay <- read.csv(file.choose())  # Prompt user to select the CSV file

set.seed(1234567)
split <- sample.split(eBay$Competitive., SplitRatio = 0.60)
training_set <- subset(eBay, split == TRUE)
test_set <- subset(eBay, split == FALSE)

# Step 2: Build Logistic Regression Model ----
lgmodel1 <- glm(Competitive. ~ ., data = training_set, family = "binomial")

# Print Model Summary
summary(lgmodel1)

# Step 3: Evaluate Model on Test Set ----
# Make predictions
predicted_probabilities <- predict(lgmodel1, test_set, type = "response")

# Convert probabilities to binary classifications
predicted_classes <- ifelse(predicted_probabilities > 0.5, 1, 0)

# Generate Confusion Matrix
conf_matrix <- table(test_set$Competitive., predicted_classes)

# Print Confusion Matrix
print(conf_matrix)

# Calculate Accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
cat("Model Accuracy: ", round(accuracy * 100, 2), "%\n")

# Interpretation
cat("The model achieved an accuracy of 76.4%. Wile this is decent, the confusion 
    matrix shows that there are significant false positives (76) and false negatives (110). 
    This indicates potential for improvement.\n")

# Suggested Improvements
cat("To improve the model's accuracy, consider the following:\n")
cat("- Feature Engineering: Transform or create new features from existing data.\n")
cat("- Feature Selection: Use stepwise selection or LASSO regression to identify the most relevant predictors.\n")
cat("- Hyperparameter Tuning: Adjust model thresholds or experiment with other classification algorithms such as decision trees or random forests.\n")
cat("- Data Balancing: If the dataset is imbalanced, apply techniques such as SMOTE or undersampling.\n")