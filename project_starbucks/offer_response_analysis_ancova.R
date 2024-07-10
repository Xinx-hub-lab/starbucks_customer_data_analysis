
library(car)
library(carData)
library(MASS)
library(dplyr)



## import
offer_response_rate = read.csv('~/Desktop/02_projects/A1_projects_files/B_sql_starbucks_customer_data_analysis/GIT_starbucks/project_starbucks/offer_response_analysis.csv')
offer_response_rate$offer_type = as.character(offer_response_rate$offer_type)
offer_response_rate = offer_response_rate[offer_response_rate$offer_type != 'INFORMATIONAL',]

offer_response_rate

options(contrasts = c('contr.sum', 'comtr.poly'))


## ANOVA for testing channels significance
## channel_email eliminated for only one level
aov1 = aov(lm(completed_percentage ~ as.factor(offer_type) +
                                        as.factor(channel_web) + as.factor(channel_mobile) + 
                                        as.factor(channel_social), offer_response_rate))
summary(aov1) ## channel_mobile, channel_social significant with p<0.05



## Tukey for posthoc analysis
tukey <- PostHocTest(aov1, method = "hsd", conf.level=0.95)
tukey  ## confirm significance of channel_mobile, channel_social


## ANCOVA
## delete channel_web and offer_type since they are not signicant in ANOVA and more degree of freedom is needed
## if added all variables, 8 predictors and 8 obs will lead to 0 residual degrees of freedom
aov2 = aov(lm(completed_percentage ~ as.factor(channel_mobile) + 
                as.factor(channel_social) + reward + difficulty + duration, offer_response_rate))
summary(aov2)
## mobile, social, reward is significant

car::Anova(aov2, type='III')
drop1(aov2,~.,test = 'F')



