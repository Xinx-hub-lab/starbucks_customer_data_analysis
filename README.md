
# Starbucks Customer Data Analysis

This project aims to study customer demographic groups who actively respond to offer types, and customer preferred offers from the Starbucks rewards app simulation data.

## Project Objectives
1. Identify which offer types generate the highest response rates. 
2. Understand how different customer segments (segmented by demos like age, gender, income) respond to various offers and identify high-value customer groups.
3. Identify which channels are most effective for reaching customers and driving offer redemptions.
4. Determine the optimal duration and timing for offers to maximize engagement.

## Dataset
This project utilizes a simulated dataset sourced from [Kaggle](https://www.kaggle.com/datasets/ihormuliar/starbucks-customer-data), governed under the **Community Data License Agreement – Permissive, Version 1.0 (CDLA-Permissive-1.0)**. This license permits the free use, modification, and distribution of the data, provided that all stipulated conditions are adhered to.

The dataset is composed of 3 tables: `portfolio.csv`, `profile.csv`, and `transcript.csv`. Below are detailed descriptions of the variables, based on the initial data dictionary provided with the dataset:

### PORTFOLIO
- **Difficulty**: Minimum required spend to complete an offer

- **Reward**: Reward given for completing an offer

- **Duration**: How many days the offer remains active

### TRANSCRIPT

- **Time**: Time in hours. The data begins at time t=0, when the customer joined as a member.

Arrays within `portfolio.csv` and `transcript.csv` contains **single quotes**, which should be revised to **double quotes** to prevent import error in MySQL Workbench.

## Data Analysis Report

The [Data Analysis Report](https://github.com/Xinx-hub-lab/starbucks_customer_data_analysis/blob/main/project_starbucks/data_analysis_report.md) included the following:
- Summary of the Tables
- Data Cleaning Process
- Exploratory Data Analysis
- Feature Importance Analysis with statistical Modeling.

## Conclusion: Customer Targets & Offer Delivering Strategy

### Important Predictors for Offer Response Rate

From the offers aspect, offer distribution channels is important, with **mobile** and **social** as the most significant channels, and **social** as the most significant channel. Factors including **reward** and **duration** could also effect the offer response rate. But there is no preferrable duration for offers based on the statistical analyses. 

From the customers aspect, **age**, **gender**, **income** are all significant predictors. Thus, the customers were segmented by all the 3 predictors and analysed based on offer completed rate to detect target customer segments.

Specific preferred customer segments have been identified, along with detailed target customer profiles matched with specific offers. These are outlined in the following tables.

### Top 5 Offers with Highest Response Rate (Descending Order)

| Offer ID                          | Offer Type | Duration | Completed Percentage |
|-----------------------------------|------------|----------| ---------------------|
| fafdcd668e3743c1bb461111dcafc2a4  | DISCOUNT   | 10       | 0.6986               |
| 2298d6c36e964ae4a3e7e9706d1fb8c2  | DISCOUNT   | 7        | 0.6669               |
| f19421c1d4aa40978ebb69ca19b0e20d  | BOGO       | 5        | 0.5497               |
| 4d5c57ea9a6940dd891ad53e9dbe8da0  | BOGO       | 5        | 0.4453               |
| ae264e3637204a6fb9bb56bc8210ddfd  | BOGO       | 7        | 0.4404               |

### Top 8 Targeted Customer Segments (by age, income, gender)

The table below displays the top customer segments representing the majority among customers with an **offer response rate >= 80%**.

| Gender | Income Group   | Age Group       | Segment Percentage over 80% Response   |
|--------|----------------|-----------------|---------|
| F      | medium_income  | 50_60           | 0.0865  |
| M      | medium_income  | 50_60           | 0.0775  |
| F      | medium_income  | greaterthan70   | 0.0743  |
| F      | medium_income  | 60_70           | 0.0705  |
| M      | medium_income  | 60_70           | 0.0598  |
| M      | medium_income  | greaterthan70   | 0.0544  |
| M      | medium_income  | 40_50           | 0.0443  |
| F      | medium_income  | 40_50           | 0.0427  |

The table showed customers of **age > 40** and **medium income (50,000 - 100,000)** who prefer to use offers for purchase. The customer segments with the highest total transaction amounts align exactly with those identified in this table, albeit with minor differences in the order.

Therefore, these demographics will be prioritized as future target customer segments.

### Targeted Customer and Their Preferrable Offers (Example of 3 customers)

We compiled a detailed table named `target_customer_offers.csv` to show specific target customers and their preferred offers. Based on the top 8 customer segments with the highest response rates, we selected customers older than 40 within medium income level, and with an offer response rate higher than 80%. Their completed offers were listed along. Below is an example featuring 3 of these customers:

| Customer ID                        | Favorable Offers                                                                                       |
|------------------------------------|----------------------------------------------------------------------------------------------|
| 004b041fbfe44859945daa2c7f79ee64 | {"f19421c1d4aa40978ebb69ca19b0e20d": "BOGO", "fafdcd668e3743c1bb461111dcafc2a4": "DISCOUNT"} |
| 004c5799adbf42868b9cff0396190900 | {"ae264e3637204a6fb9bb56bc8210ddfd": "BOGO", "f19421c1d4aa40978ebb69ca19b0e20d": "BOGO", "fafdcd668e3743c1bb461111dcafc2a4": "DISCOUNT"} |
| 0056df74b63b4298809f0b375a304cf4 | {"0b1e1539f2cc45b7b9fa7c272da2e1d7": "DISCOUNT", "2298d6c36e964ae4a3e7e9706d1fb8c2": "DISCOUNT", "9b98b8c7a33c4b65b9aebfe6a799e6d9": "BOGO"} |




