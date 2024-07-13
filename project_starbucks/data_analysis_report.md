
## Project Objectives
1. Identify which offer types generate the highest response rates. 
2. Understand how different customer segments (segmented by demos like age, gender, income) respond to various offers and identify high-value customer groups.
3. Identify which channels are most effective for reaching customers and driving offer redemptions.
4. Determine the optimal duration and timing for offers to maximize engagement.

<br>

## Data Cleaning
### PROTFOLIO TABLE
1. One hot encode the `channels` field
2. Upper case and trim for `offer_type` field

### PROFILE TABLE
1. Replace empty strings to 'U', upper case and trim for `gender` field
2. `became_member_on` convert to date and extract year as another field
3. Change `income` to int or float, replace empty strings with null value or 0, generate both in case they are both needed
4. Eliminate 118 years old customers 

### TRANSCRIPT TABLE
1. Turn JSON column `value` to columns, delete the quotes that were also extracted
2. use COALESCE to create a column to combine values of both `offer_id` and `offer id` keys
3. Turn `time` field to specific timepoint using the time these customers became members

<br>

## Data Analysis I Report:  EDA

The number of unique customers decreased from **17,000** to **14,825** after data cleaning, with age ranges between **18-101**, and their income ranges between **30,000-120,000**. The detailed demographics group percentage are as follows:

| **Category**     | **Group**          | **Percentage** |
|------------------|--------------------|----------------|
| **Gender**       | Female             | 41.34%         |
|                  | Male               | 57.23%         |
|                  | Trans-gender       | 1.43%          |
| **Age Groups**   | <30                | 10.62%         |
|                  | 30-40              | 10.29%         |
|                  | 40-50              | 15.58%         |
|                  | 50-60              | 23.89%         |
|                  | 60-70              | 20.18%         |
|                  | >70                | 19.45%         |
| **Income Levels**| Low income (<60,000)| 43.45%        |
|                  | Medium income (>=60,000, <100,000)| 49.17% |
|                  | High income (>=100,000)| 7.37%      |

<br>

There are **10** distinct offers in total, including bogo, discount and informational offers. The `transcript` dataset showed **4** distinct events: **offer received**, **offer viewed**,  **offer complete** and **transaction**. We consider an offer is completed when an offer experienced all 3 events (offer received > offer viewed > offer complete). Table below showed the counts of each offer type, their specific combination of `difficulty` and `reward`, the offer received percentage, and their completed percentage. 

| **Offer Type**  | **Counts** | **Difficulty / Reward** | **Delivered Percentage** | **Completed Percentage** |
|-----------------|----|---------------------|--------|--------|
| BOGO            | 4  | 5/5, 10/10          | 39.90% | 44.26% |
| DISCOUNT        | 4  | 7/3, 10/2, 20/5     | 40.10% | 47.22% |
| INFORMATIONAL   | 2  | 0/0                 | 20.00% | NA     |
| Total           | 10 | NA                  | 100%   | NA     |

The `difficulty` ranges between 0-20, `reward` ranges between 0-10 and `duration` ranges between 3-10. 

For the customers, the max number of offers delivered / received is **6** and the min number is **1**. Most customers with a number of 11916 (**80.38%**) experienced all 3 events. 

They became members between **2013-2018 July**. The largest membership growth happens at **2017**, and the member growth number accelerates year by year except for between 2017-2018.
The top average monthly growth happens at **August** (back-to-school season, student targeted), **October** (Halloween, fall season), **December** (holiday season), and **January** (New Year), which could be due to promotions based on different events including special seasons and holidays.

<br>

## Data Analysis II Report

### Feature Importance for Offer Response Rate

The offer response rate, `completed_percentage`, for each of 10 specific offers and each of the customers, and output 2 tables `customer_response_analysis.csv` and `offer_response_analysis.csv` is calculated by dividing the number of offer completed by the number of offers received, after filtering out informational offers. Statistical models were used to validate the significance of features in these 2 tables for predicting the response rate. 



In the table `offer_response_analysis.csv`, 2 offers were filtered out since they are informational offers. There were 7  features valid for testing feature importance, with channel_email eliminated as it is a constant. Since we only have 8 observations / offers and 7 features to test, which could cause overfitting and lack of statistical power in statistical analysis. We employed multiple methods to select the most important features. 

We used pearson correlation plot, which indicated a significant and clear correlation between difficulty and duration ($r$ = 0.8, p = 0.005), difficulty and channel_mobile($r$ = -0.7, p = 0.014), offer type and reward ($r$ = -0.8, p = 0.006). Subsequently, LASSO, RIDGE, and stepwise / backward / forward feature selection were applied for reference of feature selection, which overall favors 4 predictors: `channel_mobile`, `channel_social`, `reward`, `duration`.

#### ANCOVA Table
| Predictor       | Df | Sum Sq   | Mean Sq | F value | Pr(>F)   | Significance       |
|-----------------|----|----------|---------|---------|----------|--------------------|
| channel_mobile  | 1  | 0.08015  | 0.08015 | 51.360  | 0.00560  | **                 |
| channel_social  | 1  | 0.07263  | 0.07263 | 46.541  | 0.00644  | **                 |
| reward          | 1  | 0.05163  | 0.05163 | 33.082  | 0.01044  | *                  |
| duration        | 1  | 0.00190  | 0.00190 | 1.219   | 0.35018  |                    |

#### ANOVA Table (Type III tests)
| Predictor       | Sum Sq   | Df | F value  | Pr(>F)   | Significance       |
|-----------------|----------|----|----------|----------|--------------------|
| channel_mobile  | 0.007953 | 1  | 5.0961   | 0.109182 |                    |
| channel_social  | 0.102631 | 1  | 65.7649  | 0.003919 | **                 |
| reward          | 0.027129 | 1  | 17.3839  | 0.025113 | *                  |
| duration        | 0.001902 | 1  | 1.2189   | 0.350181 |                    |

The results showed `channel_social` ($F$ = 65.765, p <0.01) and `reward` ($F$ = 17.384, p < 0.05) are significant predictors of `completed_percentage`, with `channel_social` having the highest impact. `channel_mobile` shows significance in the ANCOVA summary ($F$ = 51.360, p < 0.05) but not in the Type III ANOVA ($F$ = 5.096, p >0.05), suggesting its effect might be less robust when accounting for other variables.
`duration` does not significantly affect `completed_percentage`.

<br>

### Feature Importance for Customer Response Rate

For the table `customer_response_analysis.csv`, we tested variables including `age`, `gender`, `income`, and there pairwise interactions. The models including interactions are in Appendix.

#### Binomial GLM (without interactions)
| Predictor   | Estimate    | P value     |
|-------------|-------------|-------------|
| age         | 3.387e-03   | 0.00117 **  |
| income      | 2.075e-05   | < 2e-16 *** |
| gender1     | 1.479e-01   | 0.00668 **  |
| gender2     | -3.792e-01  | 1.28e-12 ***|

#### Beta GLM (without interactions)
| Predictor   | Estimate      | P value        |
|-------------|---------------|----------------|
| age         | 2.175e-03     | 0.00128 **     |
| income_null | 1.351e-05     | < 2e-16 ***    |
| gender1     | 7.816e-02     | 0.01759 *      |
| gender2     | -2.714e-01    | < 2e-16 ***    |

Based on the GLM results, `income` and `gender` are significant predictors for both models when not considering interactions. `Age` is also significant in the main effects model. However, when interactions are included, `age` becomes not significant, while `income` and `gender` show significant interactions with each other.

<br>

### Validity of Statistical Results
The results from statistical analysis could provide evidence of significance of effect from certain predictors to the offer completed percentage. But some assumptions has not been statisfied in analysis above. In Feature Importance for Offer Response Rate we fitted an ANCOVA model, the assumptions are as follows:

1. Independent observations
2. Normality: the dependent variable Y is normally distributed within each subpopulation (needed when small samples of n < 20).
5. Linearity: Covariates X and the dependent variable Y are correlated.
3. Homogeneity: the variance of the dependent variable must be equal over all subpopulations (needed for sharply unequal sample sizes).
4. Interaction: coefficients for the covariates are equal among all subpopulations / no interaction between categorical variable and covariates.

Due to the small sample size, Assumption 2 and 5 cannot be fully validated, Assumption 1 is violated. Therefore, the results from ANCOVA can only be a reference or a small evidence for the significance of the 4 predictors.

<br>

Strict assumptions were not needed in Feature Importance for Customer Response Rate, which are as follows:

1. Independent observations
2. The dependent variable Y follows the distribution from the exponential family, specifically restricted by the type of GLM corresponding distribution
3. Correct link function

According to the histogram of the offer completed percentage, the distribution ranges between 0 and 1, and there is inflation at 0 and 1, we chose Binomial and Beta GLM to fit the data. Though age has droped significance when considering interactions, the simpler model may be preferred as we are only targeting at simplicity and interpretability. 

<br>

## Data Analysis III Report (Conclusion)

### Top 5 Offers with Highest Response Rate

| Offer ID                          | Offer Type | Duration | Completed Percentage |
|-----------------------------------|------------|----------| ---------------------|
| fafdcd668e3743c1bb461111dcafc2a4  | DISCOUNT   | 10       | 0.6986               |
| 2298d6c36e964ae4a3e7e9706d1fb8c2  | DISCOUNT   | 7        | 0.6669               |
| f19421c1d4aa40978ebb69ca19b0e20d  | BOGO       | 5        | 0.5497               |
| 4d5c57ea9a6940dd891ad53e9dbe8da0  | BOGO       | 5        | 0.4453               |
| ae264e3637204a6fb9bb56bc8210ddfd  | BOGO       | 7        | 0.4404               |

There is no preferrable duration for offers based on the response rate. 

### Top 10 Targeted Customer Segments (by age, income, gender)

| Gender | Income Group   | Age Group       | Completed Percentage   |
|--------|----------------|-----------------|---------|
| F      | medium_income  | 50_60           | 0.0865  |
| M      | medium_income  | 50_60           | 0.0775  |
| F      | medium_income  | greaterthan70   | 0.0743  |
| F      | medium_income  | 60_70           | 0.0705  |
| M      | medium_income  | 60_70           | 0.0598  |
| M      | medium_income  | greaterthan70   | 0.0544  |
| M      | medium_income  | 40_50           | 0.0443  |
| F      | medium_income  | 40_50           | 0.0427  |

The table showed customers of age > 50 and medium income (50,000 - 100,000) prefers to use offers for purchase which would be the future target customer. The top segments with highest sum of transaction amount intersected exactly with the table above, with subtle change in order.

### Targeted Customer and Their Preferrable Offers (Example of 3 customers)

| Customer ID                        | Offer IDs                                                                 |
|------------------------------------|---------------------------------------------------------------------------|
| 004b041fbfe44859945daa2c7f79ee64   | ["fafdcd668e3743c1bb461111dcafc2a4", "f19421c1d4aa40978ebb69ca19b0e20d"]  |
| 004c5799adbf42868b9cff0396190900   | ["ae264e3637204a6fb9bb56bc8210ddfd", "f19421c1d4aa40978ebb69ca19b0e20d", "fafdcd668e3743c1bb461111dcafc2a4", "fafdcd668e3743c1bb461111dcafc2a4", "f19421c1d4aa40978ebb69ca19b0e20d"] |
| 0056df74b63b4298809f0b375a304cf4   | ["0b1e1539f2cc45b7b9fa7c272da2e1d7", "9b98b8c7a33c4b65b9aebfe6a799e6d9", "2298d6c36e964ae4a3e7e9706d1fb8c2"] |

According to the top 10 customer segments with highest response rate, a table of target customers and their preferred offers was generated. Example is as above.

### Targeted offer ditribution channels

According to the Statistical analysis, the preferred channels to enhance the response rate is **social** and **mobile**, with social as the most significant channel. 

<br>

## References
[SPSS ANCOVA – Beginners Tutorial](https://www.spss-tutorials.com/spss-ancova-analysis-of-covariance/#ancova-assumptions)

## Appendix

#### Binomial GLM (with interactions)
| Predictor           | Estimate      | P value        |
|---------------------|---------------|----------------|
| age                 | -8.816e-04    | 0.847726       |
| income_null         | 1.540e-05     | 0.000284 ***   |
| gender1             | 7.291e-01     | 0.002026 **    |
| gender2             | -9.000e-01    | 0.000101 ***   |
| age:income_null     | 7.608e-08     | 0.178190       |
| age:gender1         | -3.647e-03    | 0.277319       |
| age:gender2         | 1.916e-03     | 0.560766       |
| income_null:gender1 | -5.794e-06    | 0.049265 *     |
| income_null:gender2 | 6.666e-06     | 0.022580 *     |

#### Beta GLM (with interactions)
| Predictor           | Estimate      | P value        |
|---------------------|---------------|----------------|
| age                 | 2.643e-03     | 0.347676       |
| income_null         | 1.255e-05     | 6.36e-07 ***   |
| gender1             | 5.060e-01     | 0.000568 ***   |
| gender2             | -7.576e-01    | 1.51e-07 ***   |
| age:income_null     | -5.324e-09    | 0.872847       |
| age:gender1         | -2.618e-03    | 0.203882       |
| age:gender2         | 1.445e-03     | 0.476736       |
| income_null:gender1 | -4.001e-06    | 0.021136 *     |
| income_null:gender2 | 6.233e-06     | 0.000305 ***   |

<br>

### Targeted Customer Segments (by age)
| Age Group      | Completed Percentage |
|----------------|----------------------|
| 50_60          | 0.2673               |
| greaterthan70  | 0.2137               |
| 60_70          | 0.2101               |
| 40_50          | 0.1489               |
| 30_40          | 0.0870               |
| lessthan30     | 0.0730               |

### Targeted Customer Segments (by gender)
| Gender | Completed Percentage |
|--------|----------------------|
| F      | 0.5099               |
| M      | 0.4716               |
| O      | 0.0186               |

### Targeted Customer Segments (by income)
| Income Group  | Proportion |
|---------------|------------|
| medium_income | 0.5841     |
| low_income    | 0.3183     |
| high_income   | 0.0976     |




