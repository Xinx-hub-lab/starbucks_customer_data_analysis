
library(dplyr)
library(ggplot2)
library(ggcorrplot)
library(gridExtra)
library(car)
library(carData)
library(MASS)
library(glmnet)
library(olsrr)
library(betareg)

## import
### setwd()
df = read.csv('offer_response_analysis.csv')


## preprocess
df_proc = df %>% 
  ## filter out informational offer types
  filter(offer_type != 'INFORMATIONAL') %>%
  ## convert channels and offer type columns to factors
  mutate( 
    offer_type_encoded = ifelse(offer_type == 'BOGO', 0, 1),
    offer_type_encoded = as.factor(offer_type_encoded),
    channel_web = as.factor(channel_web),
    channel_mobile = as.factor(channel_mobile),
    channel_email = as.factor(channel_email),
    channel_social = as.factor(channel_social)) %>%
  ## drop useless variables for more degree of freedom for subsequent statistical analysis
  select(-offer_id, -offer_type, -channel_email) 

df_proc


## plot distribution and pattern
## complete percentage vs. reward
ggplot(df_proc, aes(x=reward, y=completed_percentage, color = offer_type_encoded)) + 
  geom_point(size=2) +
  labs(colour = "Offer Type")

## complete percentage vs. duration
ggplot(df_proc, aes(x=duration, y=completed_percentage, color = offer_type_encoded)) + 
  geom_point(size=2) +
  labs(colour = "Offer Type")

## plot completed_percentage dist
ggplot(df_proc, aes(x=completed_percentage)) + 
  geom_histogram()

## plot reward dist
ggplot(df_proc, aes(x=reward)) + 
  geom_histogram()

## plot duration dist
ggplot(df_proc, aes(x=duration)) + 
  geom_histogram()



## correlation plot
## use dataset with no settings of factors, only numeric allowed
df_corr_plt = df %>% 
  mutate( 
    offer_type_encoded = ifelse(offer_type == 'BOGO', 0, 1)) %>%
  select(-offer_id, -offer_type, -channel_email)

corr = cor(df_corr_plt, method = "pearson") %>% round(1)
print(corr)
corr_p = cor_pmat(df_corr_plt) %>% round(3)
print(corr_p)
ggcorrplot(corr)



## variable importance by lasso
## normalization + use dataset with no settings of factors
df_corr_plt = df_corr_plt %>%
  mutate( 
    reward = reward / 10,
    difficulty = difficulty / 20,
    duration = duration / 10) 

X = model.matrix(completed_percentage ~.-1, df_corr_plt)
y = df_corr_plt$completed_percentage

fit.lasso = glmnet(X, y, alpha = 1)
plot(fit.lasso, xvar = 'lambda', label = T)
plot(fit.lasso, xvar = 'dev', label = T)
fit.lasso = cv.glmnet(X, y, alpha = 1)
plot(fit.lasso)
coef(fit.lasso)



## confirming variable importance by ridge
fit.ridge = glmnet(X, y, alpha = 0)
plot(fit.ridge, xvar = 'lambda', label = T)
plot(fit.ridge, xvar = 'dev', label = T)
cv.ridge = cv.glmnet(X, y, alpha = 0)
plot(cv.ridge)
coef(cv.ridge)
## difficulty, offer_type can be eliminated



## stepwise / backward / forward feature selection
fit_lm = lm(completed_percentage ~ .-difficulty -offer_type_encoded, df_proc)
ols_step_both_p(fit_lm, pent =  0.05, prem =  0.05)
ols_step_backward_p(fit_lm, pent =  0.05, prem =  0.05)
ols_step_forward_p(fit_lm, pent =  0.05, prem =  0.05)



## 1. correlation between covariate X and Y
summary(lm(completed_percentage ~ reward + duration, df_proc))
## no significant correlation, assumption 1 violated

## 2. no correlation between X and categorical variable, tested previously, assumption 2 satisfied

## 3. no interaction between categorical variable and continuos variable, assumption 3 satisfied
ggplot(df_proc, aes(x=duration, y=completed_percentage, color=as.factor(channel_mobile))) +
  geom_point() +
  geom_smooth(method='lm') +
  labs(x='duration', y='Completed percentage', title = 'Check for interaction', color='')
ggplot(df_proc, aes(x=reward, y=completed_percentage, color=as.factor(channel_mobile))) +
  geom_point() +
  geom_smooth(method='lm') +
  labs(x='reward', y='Completed percentage', title = 'Check for interaction', color='')
## no need to test for the other 2 pairs of continuous and categorical variables


## ANCOVA
## selected 4 features according to above output: channel_mobile; channel_social, reward, duration
options(contrasts = c('contr.sum', 'comtr.poly'))
aov2 = aov(lm(completed_percentage ~ 
                channel_mobile + 
                channel_social + 
                reward + 
                duration, 
              df_proc))
summary(aov2)
car::Anova(aov2, type='III')
drop1(aov2,~.,test = 'F')




