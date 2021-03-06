#Rahim Abdulmalik                       5/16/2020                      R Programming

#The NBA MVP for the 2019-2020 Season



#Goal: Develop a Machine Learning algorithm that can be used to predict the NBA's MVP


#Note:
#Tables were merged via excel from https://www.basketball-reference.com/awards/mvp.html 



#Libraries used
library(tidyverse)
library(class)
library(gmodels)
library(caret)
library(randomForest)
library(ROCR)
#===================================================
#Random Forest Algorithm
#===================================================

#Import Data
nba_df <- read.csv('NBA_MVP_1980-2018.csv')
str(nba_df)
current_candidates <- read.csv('MVP2020Test.csv')
str(current_candidates)


#Preprocessing
#Deleting unnecessary features
winner_2020 <- current_candidates[-c(1,3,13:14)]
str(winner_2020)
current_candidates <- winner_2020[-1]
str(current_candidates)

nba_18_candidates <- nba_df[280:289,]
nba_val18 <- nba_18_candidates[-c(1:9,19:20,22:23)]
str(nba_val18)

nba_df <- nba_df[-(280:289),]
nba_df <- nba_df[-c(1:9,19:20,22:23)]
str(nba_df)

#missing values
nba_df$X3P.[is.na(nba_df$X3P.)] <- 0
sum(is.na(nba_df))

#Randomize Data
set.seed(300)
nba_df_r <- nba_df[order(runif(389)), ]

#Normalization
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

nba_df_norm <- as.data.frame(lapply(nba_df_r[1:9], normalize))
nba_18_norm <- as.data.frame(lapply(nba_val18[1:9], normalize))
current_candidates_norm <- as.data.frame(lapply(current_candidates, normalize))

#====================================================
#Developing The model

#Training and Test Sets (25%)
nba_train <- nba_df_norm[1:291, ]
nba_test <- nba_df_norm[292:389, ]

nba_train_labels <- nba_df_r[1:291, 10]
nba_test_labels <- nba_df_r[292:389, 10]
nba_val18_labels <- nba_val18[10]

toned_train <- as.data.frame(cbind(nba_train,nba_train_labels))

#======================================
#Decision Tree

#Running the model/Evaluation
grid1 <- expand.grid(.model = 'tree',
                     .trials = c(1, 5, 10, 15, 20, 25, 30, 40),
                     .winnow = 'FALSE')
set.seed(300)
m_dt <- train(nba_train_labels ~ ., data = toned_train, method = 'C5.0', metric = 'Kappa',
              trControl = trainControl(method = 'boot632'),
              tuneGrid = grid1)
m_dt
#trials = 30 has the highest kappa of 0.3692 with an accuracy of 91.83%

#Applying the model to the test set
pdec5 <- predict(m_dt, nba_test)
confusionMatrix(pdec5, nba_test_labels, dnn = c('prediction', 'actual'))

#Applying the trained model with the 2018 MVP set
pdec6 <- predict(m_dt, nba_18_norm, type = 'prob')
cbind(nba_18_candidates[2], pdec6)

#Applying the model with current candidates
pdec7 <- predict(m_dt, current_candidates_norm, type = 'prob')
cbind(winner_2020, pdec7)

#Giannis is the winner for the Decision Tree Algorithm

#============================================
#Random Forest

#Running/Evaluationg the model
set.seed(300)
m_rf <- train(nba_train_labels ~ ., data = toned_train, method = 'rf', metric = 'Kappa',
              trControl = trainControl(method = 'boot632'))
m_rf
#mtry = 9 had the highest kappa of 0.39 accuracy of 92.74%

#Applying the model to the test set
pdec2 <- predict(m_rf, nba_test)
confusionMatrix(pdec2, nba_test_labels, dnn = c('prediction', 'actual'))

#Applying the trained model with the 2018 MVP set
pdec3 <- predict(m_rf, nba_18_norm, type = 'prob')
cbind(nba_18_candidates[2], pdec3)

#Applying the model with current candidates
pdec4 <- predict(m_rf, current_candidates_norm, type = 'prob')
cbind(winner_2020, pdec4)

#Giannis is the winner for the Random Forest Algorithm

#============================================
