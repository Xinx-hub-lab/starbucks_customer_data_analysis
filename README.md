
# Starbucks Customer Data Analysis

This project aims to study customer demographic groups who actively respond to offer types, and customer preferred offers from the Starbucks rewards app simulation data.

## Project Objectives
1. Identify which offer types generate the highest response rates. 
2. Understand how different customer segments (segmented by demos like age, gender, income) respond to various offers and identify high-value customer groups.
3. Identify which channels are most effective for reaching customers and driving offer redemptions.
4. Determine the optimal duration and timing for offers to maximize engagement.

## Datasets
The dataset was downloaded from [Kaggle](https://www.kaggle.com/datasets/ihormuliar/starbucks-customer-data) and 3 tables are available: `portfolio.csv`, `profile.csv`, `transcript.csv`. Below are further clarifications on variables, partially extracted from initially provided data dictionary. 

### PORTFOLIO
**Difficulty**: Minimum required spend to complete an offer

**Reward**: Reward given for completing an offer

**Duration**: How many days the offer remains active

### TRANSCRIPT

**Time**: Time in hours. The data begins at time t=0, when the customer joined as a member.

## Note for Import
Arrays within `portfolio.csv` and `transcript.csv` contains **single quotes**, which should be revised to **double quotes** to prevent import error.

## Data Analysis Report

[Data Analysis Report](https://github.com/Xinx-hub-lab/starbucks_customer_data_analysis/blob/main/project_starbucks/data_analysis_report.md) included summary of the datasets, Exploratory Data Analysis, Feature Importance Analysis with statistical methods.

## Conclusion, Customer Targets and Offer Delivering Strategy

### Important Predictors for Offer Response Rate

From the offers aspect, offer distribution channels is important, with **mobile** and **social** as the most significant channels, with social as the most significant channel. Factors including **reward** and **duration** could also effect the offer response rate. But there is no preferrable duration for offers based on the response rate. 

From the customers aspect, **age**, **gender**, **income** are all significant predictors. Therefore, the customers were segmented by all the 3 predictors and analysed based on offer completed rate.

Specific preferred customer segments, and detailed target customers with specific offers were generated, listed in following sections.

### Top 5 Offers with Highest Response Rate (Descending Order)

| Offer ID                          | Offer Type | Duration | Completed Percentage |
|-----------------------------------|------------|----------| ---------------------|
| fafdcd668e3743c1bb461111dcafc2a4  | DISCOUNT   | 10       | 0.6986               |
| 2298d6c36e964ae4a3e7e9706d1fb8c2  | DISCOUNT   | 7        | 0.6669               |
| f19421c1d4aa40978ebb69ca19b0e20d  | BOGO       | 5        | 0.5497               |
| 4d5c57ea9a6940dd891ad53e9dbe8da0  | BOGO       | 5        | 0.4453               |
| ae264e3637204a6fb9bb56bc8210ddfd  | BOGO       | 7        | 0.4404               |

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

The table showed customers of **age > 40** and **medium income (50,000 - 100,000)** prefers to use offers for purchase, which would be the future target customers.

The top customer segments with highest sum of transaction amount intersected exactly with the table above, with subtle change in order.

### Targeted Customer and Their Preferrable Offers (Example of 3 customers)

According to the top 10 customer segments with highest response rate, a table of target customers and their preferred offers was generated, named as `target_customer_offers.csv`. 

Example is as below. 

| Customer ID                        | Offer IDs                                                                 |
|------------------------------------|---------------------------------------------------------------------------|
| 004b041fbfe44859945daa2c7f79ee64   | ["fafdcd668e3743c1bb461111dcafc2a4", "f19421c1d4aa40978ebb69ca19b0e20d"]  |
| 004c5799adbf42868b9cff0396190900   | ["ae264e3637204a6fb9bb56bc8210ddfd", "f19421c1d4aa40978ebb69ca19b0e20d", "fafdcd668e3743c1bb461111dcafc2a4", "fafdcd668e3743c1bb461111dcafc2a4", "f19421c1d4aa40978ebb69ca19b0e20d"] |
| 0056df74b63b4298809f0b375a304cf4   | ["0b1e1539f2cc45b7b9fa7c272da2e1d7", "9b98b8c7a33c4b65b9aebfe6a799e6d9", "2298d6c36e964ae4a3e7e9706d1fb8c2"] |



