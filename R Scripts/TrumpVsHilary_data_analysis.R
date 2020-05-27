rm(list = ls())
set.seed(35)

library(tidyverse) #required for between function
library(MASS)
df_csv <- read.csv(file = 'G:/Statistical Learning/Assignments/Assignment 1/ANES2016.csv')

#recoding the Trump variable
df_csv[between(df_csv$Trump, 1, 3), "Trump"] <- 0 #Liberal
df_csv[between(df_csv$Trump, 4, 7), "Trump"] <- 1 #Conservative

#new filter data frame
df_csv <- filter(df_csv, df_csv$Trump >= 0)

# We can see the missing values in 3 categorical variables, removing those
df_csv <- df_csv[complete.cases(df_csv), ]
#summary(df_csv)

# Create a sub set using the most appropriate variables
df_subset <- subset(df_csv, select = c(Media, FamSize, Age, Partner, SpouseEdu, Employment, Birthplace, GBirth, Dependent, Housing, Income, Education2, Marital, PartyID, Trump))

# create logistic regression for all and use backward elemination for choosing best predictor in the model
all.fit <- glm (Trump ~ ., data = df_subset)
summary(all.fit)

step(all.fit, direction = "backward")
# Model with best fitted predictors given by the algorithm
glm.model = glm(Trump ~ Media + SpouseEdu + Birthplace + GBirth + Dependent + Housing + Income + Education2, 
                data = df_subset)

#set training and testing data
row_count <-nrow(df_subset)
train <- sample(1:row_count, row_count * 0.8)
test <- -(train)
train_df <- df_subset[train,]
test_df <- df_subset[test,]

# looking accuracy in training data
glm.model.train <- glm(Trump ~ Media + SpouseEdu + Birthplace + GBirth + Dependent + Housing + Income + Education2, 
                       data = df_subset,
                       family = binomial,
                       subset = train
)

prediction <- rep(0, nrow(train_df))
probability <- predict(glm.model.train, train_df, type = "response")
prediction[probability > 0.5] <- 1

confusion_matrix <- table(prediction, train_df$Trump)
accuracy_train <- (confusion_matrix[1,1] + confusion_matrix[2,2])/sum(confusion_matrix)
accuracy_train
#80.96% accuray in training set

# looking testing data
glm.model.test <- glm(Trump ~ Media + SpouseEdu + Birthplace + GBirth + Dependent + Housing + Income + Education2, 
                      data = df_subset,
                      family = binomial,
                      subset = test
)

prediction <- rep(0, nrow(test_df))
probability <- predict(glm.model.test, test_df, type = "response")
prediction[probability > 0.5] <- 1

confusion_matrix <- table(prediction, test_df$Trump)
accuracy_test <- (confusion_matrix[1,1] + confusion_matrix[2,2])/sum(confusion_matrix)
accuracy_test
#79.98% accuracy in testing set
#which is some what equal with training sets.

#looking at the summary of the model to have discussion derive the conclusion
summary(glm.model)