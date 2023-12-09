library(data.table)
library(stats)
library(nnet)


train_data <- fread("source_data/train_data.csv", drop = 1)
test_data <- fread("source_data/test_data.csv", drop = 1)

# cleaning the train data
train_data_cleaned <- train_data[,7:46]
train_data_cleaned <- na.omit(train_data_cleaned)
train_betrate <- train_data_cleaned[,20:22]
train_data_cleaned <- train_data_cleaned[,-20:-22]

# cleaning the test data
test_data_cleaned <- test_data[,7:46]
test_data_cleaned <- na.omit(test_data_cleaned)
test_betrate <- test_data_cleaned[,20:22]
test_data_cleaned <- test_data_cleaned[,-20:-22]

# write out data
write.csv(train_data_cleaned,"source_data/train_data_cleaned.csv")
write.csv(train_betrate,"source_data/train_betratio.csv")
write.csv(test_data_cleaned,"source_data/test_data_cleaned.csv")
write.csv(test_betrate,"source_data/test_betratio.csv")

model <- multinom(FTR ~ ., data = train_data_cleaned)

predicted_values <- predict(model, test_data_cleaned)
predicted_probs <- predict(model, test_data_cleaned, type = "probs")

accuracy <- mean(test_data_cleaned$FTR == predicted_values)

cat(paste("The accuracy from a multinomial logistic regression of predicting the result of a game is", format(accuracy, nsmall = 2), 
          "\n", "the accuracy for random guess for win/loss/draw is", format(1/3, nsmall = 2)))

