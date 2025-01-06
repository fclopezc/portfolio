# Predicting Airfares with Linear Regression
# Franklin López


# Load Required Libraries----
library(corrplot)
library(PerformanceAnalytics)
library(caret)

# Step 1: Load and Filter Data----
filepath <- file.choose() # Prompt user to select the file
airfares <- read.csv(filepath)[, c("FARE", "COUPON", "NEW", "VACATION", "SW", "HI", 
                                   "S_INCOME", "E_INCOME", "S_POP", "E_POP", "SLOT", 
                                   "GATE", "PAX", "DISTANCE")]

# Step 2: Split the Data (Train, Test)----
set.seed(42) # For reproducibility
train_idx <- createDataPartition(airfares$FARE, p = 0.8, list = FALSE)
train_data <- airfares[train_idx, ]

# Optional: Uncomment below lines if test/validation sets are needed
# remaining_data <- airfares[-train_idx, ]
# validate_idx <- createDataPartition(remaining_data$FARE, p = 0.5, list = FALSE)
# validate_data <- remaining_data[validate_idx, ]
# test_data <- remaining_data[-validate_idx, ]

# Step 3: Correlation Analysis----
num_cols <- train_data[sapply(train_data, is.numeric)]
corrplot(cor(num_cols, use = "pairwise.complete.obs"), method = "circle", type = "upper", tl.col = "black")
chart.Correlation(num_cols, histogram = TRUE, method = "pearson")

# Step 4: Build Linear Regression Model----
linear_model <- lm(FARE ~ ., data = train_data)

# Step 5: Predict on New Data-----
new_route <- data.frame(
  COUPON = 1.202, NEW = 3, VACATION = "No", SW = "No", HI = 4442.141, 
  S_INCOME = 28760, E_INCOME = 27664, S_POP = 4557004, E_POP = 3195503, 
  SLOT = "Free", GATE = "Free", PAX = 12782, DISTANCE = 1976
)

# Prediction
predicted_fare <- predict(linear_model, newdata = new_route)

# Output Result
cat("Predicted Fare for the New Route: $", round(predicted_fare, 2), "\n")
