#Start the sesison#
rm(list = ls())
#load the required libraries
library(tidyverse) #required for between function
#library(Hmisc) #required for impute function
library(leaps)
library(MASS)
library(class)
set.seed(123)
# Start Data loading and cleansing
df_csv <- read.csv(file = 'G:/Statistical Learning/Assignments/Assignment 1/ANES2016.csv', 
                   header = TRUE, 
                   na.strings = '?'
)
#head(df_csv)
#summary(df_csv)
df_csv <- df_csv[complete.cases(df_csv), ]
#summary(df_csv)
# Select a subset of variables for regression modelling

df_subset <- subset(df_csv, select = c(Media, FamSize, Age, Partner, SpouseEdu, Employment, Birthplace, GBirth, Dependent, Housing, Income, Education2, Marital, PartyID))
#summary(df_subset)
#End Data loading and cleansing

#set training and testing data
row_count <-nrow(df_subset)
train <- sample(1:row_count, row_count * 0.8)
test <- -(train)
train_df <- df_subset[train,]
test_df <- df_subset[test,]

#function to calculate accuracy of confusion matrix
calc_accuracy <- function(confusion_matrix) {
  return ((confusion_matrix[1,1] + confusion_matrix[2,2] + confusion_matrix[3,3] + confusion_matrix[4,4])/sum(confusion_matrix))
}

#function to calculate sensitivity of confusion matrix
calc_sensitivity <- function(confusion_matrix) {
  true_positive <- confusion_matrix[1,1] + confusion_matrix[2,2] + confusion_matrix[3,3] + confusion_matrix[4,4]
  false_negative <- confusion_matrix[1,2] + confusion_matrix[1,3] + confusion_matrix[1,4] +
    confusion_matrix[2,1] + confusion_matrix[2,3] + confusion_matrix[2,4] +
    confusion_matrix[3,1] + confusion_matrix[3,2] + confusion_matrix[3,4] +
    confusion_matrix[4,1] + confusion_matrix[4,2] + confusion_matrix[4,3] 
  return (true_positive/(false_negative + true_positive))                      
}

#function to calculate specificity of confusion matrix
calc_specificity <- function(confusion_matrix) {
  true_negative <- confusion_matrix[1,1] + confusion_matrix[2,2] + confusion_matrix[3,3] + confusion_matrix[4,4]
  false_positive <- confusion_matrix[2,1] + confusion_matrix[3,1] + confusion_matrix[4,1] +
    confusion_matrix[1,2] + confusion_matrix[3,2] + confusion_matrix[4,2] +
    confusion_matrix[1,3] + confusion_matrix[2,3] + confusion_matrix[4,3] +
    confusion_matrix[1,4] + confusion_matrix[2,4] + confusion_matrix[3,4] 
  return (true_negative/(false_positive + true_negative))                      
}

#--------Using Linear Discriminant Analysis Start-------#
lda.model.train <- lda(PartyID~ ., data = train_df)
prediction.train <- predict(lda.model.train, train_df)$class
confusion_matrix <- table(prediction.train, train_df$PartyID)

#calculate accuracy, err, sensitivity, specificity for training set
lda_accuray.train <- calc_accuracy(confusion_matrix)
lda_error.train <- 1 - lda_accuray.train
lda_sensitivity.train <- calc_sensitivity(confusion_matrix)
lda_specificity.train <- calc_specificity(confusion_matrix)

lda.model.test <- lda(PartyID~ ., data = test_df)
prediction.test <- predict(lda.model.test, test_df)$class
confusion_matrix <- table(prediction.test, test_df$PartyID)

#calculate accuracy, err, sensitivity, specificity for testing set
lda_accuray.test <- calc_accuracy(confusion_matrix)
lda_error.test <- 1 - lda_accuray.test
lda_sensitivity.test <- calc_sensitivity(confusion_matrix)
lda_specificity.test <- calc_specificity(confusion_matrix)

#--------Using Linear Discriminant Analysis End-------#

#--------Using Quardratic Discriminant Analysis Start-------#
qda.model.train <- qda(PartyID~ ., data = train_df)
prediction.train <- predict(qda.model.train, train_df)$class
confusion_matrix <- table(prediction.train, train_df$PartyID)

#calculate accuracy, err, sensitivity, specificity for training set
qda_accuray.train <- calc_accuracy(confusion_matrix)
qda_error.train <- 1 - qda_accuray.train
qda_sensitivity.train <- calc_sensitivity(confusion_matrix)
qda_specificity.train <- calc_specificity(confusion_matrix)

qda.model.test <- qda(PartyID~ ., data = test_df)
prediction.test <- predict(qda.model.test, test_df)$class
confusion_matrix <- table(prediction.test, test_df$PartyID)

#calculate accuracy, err, sensitivity, specificity for testing set
qda_accuray.test <- calc_accuracy(confusion_matrix)
qda_error.test <- 1 - qda_accuray.test
qda_sensitivity.test <- calc_sensitivity(confusion_matrix)
qda_specificity.test <- calc_specificity(confusion_matrix)
#--------Using Quardratic Discriminant Analysis End-------#

#--------Using K-Nearest Neighbours Algorithm Start-------#
fit <- train(PartyID ~ ., data = train_df, method = "knn", tuneLength = 20)
fit

predictors <- c("Media", "FamSize", "Age", "Partner", "SpouseEdu", 'Employment', "Birthplace", "GBirth", "Dependent", "Housing", "Income", "Education2", "Marital")

training_data_abscissa <- as.matrix(train_df[predictors])
training_data_ordinate <- as.matrix(train_df[,"PartyID"])
testing_data_abscissa <- as.matrix(test_df[predictors])
testing_data_ordinate <- as.matrix(test_df[,"PartyID"])

prediction <- knn(testing_data_abscissa, training_data_abscissa, testing_data_ordinate, k = 43)
confusion_matrix <- table(prediction, training_data_ordinate)

#calculate accuracy, err, sensitivity, specificity for training set

knn_accuray.train <- calc_accuracy(confusion_matrix)
knn_error.train <- 1 - knn_accuray.train
knn_sensitivity.train <- calc_sensitivity(confusion_matrix)
knn_specificity.train <- calc_specificity(confusion_matrix)

prediction <- knn(training_data_abscissa, testing_data_abscissa, training_data_ordinate, k = 43)
confusion_matrix <- table(prediction, testing_data_ordinate)

#calculate accuracy, err, sensitivity, specificity for testing set
knn_accuray.test <- calc_accuracy(confusion_matrix)
knn_error.test <- 1 - knn_accuray.test
knn_sensitivity.test <- calc_sensitivity(confusion_matrix)
knn_specificity.test <- calc_specificity(confusion_matrix)

#--------Using K-Nearest Neighbours Algorithm End-------#

#choosing the best model as LDA
lda.model <- lda(PartyID~ ., data = df_subset)
lda.model
