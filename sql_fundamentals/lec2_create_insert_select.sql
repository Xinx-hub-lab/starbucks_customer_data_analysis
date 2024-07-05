CREATE  SCHEMA SQL_BOOTCAMP;
-- sepecify the schema you want to use
USE SQL_BOOTCAMP;

-- create table with column value and data type
CREATE TABLE Customer(
	customerID INT,
    name VARCHAR(40),
    email VARCHAR(40),
    member_since DATE
);


-- insert value into table
INSERT INTO Customer(customerID,name,email,member_since) 
VALUES ( 1, 'AMY' , '123@gmail.com', '2020-01-01');

-- select and display entier table 
SELECT * FROM Customer; 