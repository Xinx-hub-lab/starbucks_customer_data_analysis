
## Project Objectives
1. Identify which offer types generate the highest response rates and revenue. 
2. Understand how different customer segments (segmented by demos like age, gender, income) respond to various offers and identify high-value customer groups.
3. Identify which channels are most effective for reaching customers and driving offer redemptions.
4. Determine the optimal duration and timing for offers to maximize engagement.
5. Calculate the customer lifetime value for different segments and understand how offers influence CLV.

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

For the customers, the max number of offers delivered / received is **6** and the min number is **1**. 11916 (**80.38%**) customers experienced all 3 events. 

<br>

They became members between **2013-2018 July**. The largest membership growth happens at **2017**, and the member growth number accelerates year by year except for between 2017-2018.
The top average monthly growth happens at **August** (back-to-school season, student targeted), **October** (Halloween, fall season), **December** (holiday season), and **January** (New Year), which could be due to promotions based on different events including special seasons and holidays.

## Data Analysis II Report

This section displayed 

too few observations and too many predictors, fitting an ANCOVA or ANOVA model can be problematic due to the risk of overfitting and lack of statistical power

duration and difficulty has a large correlation 0.8 (p = 0.005)

difficulty and channel mobile has correlation -0.7, p = 0.014

member_added time series 

customer demographics



