
library(car)
library(carData)
library(MASS)
library(dplyr)
library(ggplot2)
library(ggcorrplot)
library(glmnet)
library(olsrr)
library(betareg)

## import
setwd('')
df = read.csv('customer_response_analysis.csv')



## preprocess
df_proc = df %>% 
  ## convert gender to factors
  mutate( 
    gender = as.factor(gender)) %>%
  ## drop useless variables
  select(age, gender, income_null, 
         completed_percentage, bogo_complete_percentage, discount_complete_percentage)

head(df)
head(df_proc)



## plot relationship
ggplot(df_proc, aes(x=completed_percentage)) + 
  geom_histogram()
ggplot(df_proc, aes(x=bogo_complete_percentage)) + 
  geom_histogram()
ggplot(df_proc, aes(x=discount_complete_percentage)) + 
  geom_histogram()
ggplot(df_proc, aes(x=age)) + 
  geom_histogram()
ggplot(df_proc, aes(x=income_null)) + 
  geom_histogram()
ggplot(df_proc, aes(x = gender)) +
  geom_bar()



## correlation
df_corr_plt = df %>% 
  mutate( 
    gender = ifelse(gender == 'M', 1, 0)) %>%
  select(age, gender, income_null, 
         completed_percentage)

corr = cor(df_corr_plt, method = "pearson") %>% round(1)
print(corr)
corr_p = cor_pmat(df_corr_plt) %>% round(3)
print(corr_p)
ggcorrplot(corr)
## no correlation



## GLM, no assumptions to validate


## binomial
## without interaction
glm_bino1 = glm(completed_percentage ~ age + income_null + gender,
                df_proc,
                family = binomial(link = "logit"))
summary(glm_bino1)

## with interaction
glm_bino2 = glm(completed_percentage ~ (age + income_null + gender)^2,
               df_proc,
               family = binomial(link = "logit"))
summary(glm_bino2)



## beta
## 0 and 1 not allowed, change 1 to 0.9999 and 0 to 0.0001
df_proc1 = df_proc
df_proc1$completed_percentage = ifelse(df_proc1$completed_percentage == 0, 0.0001, 
                                       df_proc1$completed_percentage)
df_proc1$completed_percentage <- ifelse(df_proc1$completed_percentage == 1, 0.9999, 
                                        df_proc1$completed_percentage)

## without interaction
glm_beta1 <- betareg(completed_percentage ~ age + income_null + gender, df_proc1)
summary(glm_beta1)

## with interaction
glm_beta2 <- betareg(completed_percentage ~ (age + income_null + gender)^2, df_proc1)
summary(glm_beta2)



