
library(car)
library(carData)
library(MASS)
library(dplyr)
library(ggplot2)
library(ggcorrplot)
library(glmnet)
library(olsrr)

## import
setwd('~/Desktop/02_projects/A1_projects_files/B_sql_starbucks_customer_data_analysis/GIT_starbucks/project_starbucks')
df = read.csv('customer_response_analysis.csv')

## preprocess
df_proc = df %>% 
  ## convert gender to factors
  mutate( 
    gender = as.factor(gender)) %>%
  ## drop useless variables
  select(age, gender, income_null, completed_percentage)

head(df_proc)



## ANCOVA
## testing gender, income, age significance
options(contrasts = c('contr.sum', 'comtr.poly'))
aov2 = aov(lm(completed_percentage ~ (age + gender + income_null)^2, df_proc))
summary(aov2)
car::Anova(aov2, type='III')
drop1(aov2,~.,test = 'F')






