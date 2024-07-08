
## Project Objectives
1. Identify which offer types generate the highest response rates and revenue. 
2. Understand how different customer segments (segmented by demos like age, gender, income) respond to various offers and identify high-value customer groups.
3. Identify which channels are most effective for reaching customers and driving offer redemptions.
4. Determine the optimal duration and timing for offers to maximize engagement.
5. Calculate the customer lifetime value for different segments and understand how offers influence CLV.

## EDA for customer demographics

17000
became member on 2013-2018 July

percentage of gender:
Female: 41.34%
Male: 57.23%
Trans-gender: 1.43%

age 18-101
age groups
<30: 0.11; 30-40: 0.1; 40-50: 0.15; 50-60: 0.24; 60-70: 0.20; >70: 0.19;

low income(<50,000): 0.4515
medium income(>60,000, <100,000):0.4748
high income(>100,000): 0.0737


	-- Member added top count months: 8, 10, 12, 1
	-- Aug: coincides with the back-to-school seASon, starbucks may offer more discounts for students
    -- Oct: Halloween, fall seASon discount
    -- Dec: holiday seASon promotions
    -- Jan: New year promotions



## Data Cleaning
PROTFOLIO TABLE
-- preprocess and create new table
	-- one hot encoding for channels column
	-- upper case + trim for offer_type

PROFILE TABLE
-- preprocessing and create a new table
	-- replace empty strings to 'U' for gender, TRIM(), UPPER(), the order of TRIM and UPPER does not matter
    -- became_member convert to date and extract year
    -- change income to int or float, replace empty strings '' with NULL or 0, generate both in case they are both needed
	-- rename the columns

    TRANSCRIPT TABLE

    -- turn JSON columns to columns, delete the quotes "" that were also extracted
    -- use COALESCE to create a column with offer_id as value, if NULL then use 'offer id' as the value, otherwise NULL

## Data Analysis Report


