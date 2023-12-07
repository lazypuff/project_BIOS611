library(data.table)
library(stats)
library(nnet)
########## This code is just for self-check use.
reduced_model <- multinom(FTR ~ HAG+HAS+HAST+HAC+AAG+AAS+AAST+AAC, data = train_data_cleaned)
summary(reduced_model)
predicted_reduced_values <- predict(reduced_model, test_data_cleaned)
accuracy_reduced <- mean(test_data_cleaned$FTR == predicted_reduced_values)

predicted_values <- predict(model, test_data_cleaned[,2:39])
predicted_probs <- predict(model, test_data_cleaned, type = "probs")

accuracy <- mean(test_data_cleaned$FTR == predicted_values)


fit_incremental_models <- function(train_data, test_data, response_col_name) {
  predictors <- setdiff(names(train_data), response_col_name)
  accuracies <- c()
  
  for (i in 1:length(predictors)) {
    # Create the formula string
    formula_str <- paste(response_col_name, "~", paste(predictors[1:i], collapse = "+"))
    
    # Fit the model
    model <- multinom(as.formula(formula_str), data = train_data)
    
    # Predict on the test set
    predicted_values <- predict(model, test_data)
    
    # Calculate accuracy
    accuracy <- mean(test_data[[response_col_name]] == predicted_values)
    accuracies <- c(accuracies, accuracy)
    
    # Print the accuracy for this model
    cat("Model with", i, "predictors: Accuracy =", accuracy, "\n")
  }
  
  return(accuracies)
}

fit_incremental_models(train_data_cleaned,test_data_cleaned,"FTR") # 19 variables will make the prediction perfect.

train_reduced <- train_data_cleaned[,c(-17:-19, -37:-39)]
test_reduced <- test_data_cleaned[,c(-17:-19, -37:-39)]
fit_incremental_models(train_data_cleaned,test_data_cleaned,"FTR")


columns_to_scale <- setdiff(names(train_reduced), 'FTR')
train_reduced_df <- as.data.frame(train_reduced)
train_scaled <- train_reduced_df
train_scaled[columns_to_scale] <- scale(train_reduced_df[columns_to_scale])

test_reduced_df <- as.data.frame(test_reduced)
test_scaled <- test_reduced_df
test_scaled[columns_to_scale] <- scale(test_reduced_df[columns_to_scale])

fit_incremental_models(test_scaled,test_scaled,"FTR")


model_test1 <- multinom(FTR ~ HGD, data = train_data_cleaned)
predicted_values_test <- predict(model_test1, test_data_cleaned)

accuracy_test <- mean(test_data_cleaned$FTR == predicted_values)