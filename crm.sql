CREATE DATABASE `crm`;

##################### 1. CREATING TABLES

CREATE TABLE `raw_accounts` (
    `account` VARCHAR(255) NOT NULL,
    `sector` VARCHAR(255) NOT NULL,
    `year_established` INT NOT NULL,
    `revenue` FLOAT NOT NULL,
    `employees` INT NOT NULL,
    `office_location` VARCHAR(255) NOT NULL,
    `subsidiary` VARCHAR(255)
);
CREATE TABLE `raw_products` (
	`product` VARCHAR(255) NOT NULL,
    `series` VARCHAR(255) NOT NULL,
    `sales_price` FLOAT NOT NULL
);
CREATE TABLE `raw_sales_pipeline` (
	`opportunity_id` VARCHAR(255) NOT NULL,
    `sales_agent` VARCHAR(255) NOT NULL,
    `product` VARCHAR(255) NOT NULL,
    `account` VARCHAR(255),
    `deal_stage` VARCHAR(255) NOT NULL,
    `engage_date` VARCHAR(255),
    `close_date` VARCHAR(255),
    `close_value` VARCHAR(255)
);
CREATE TABLE `raw_sales_teams` (
	`sales_agent` VARCHAR(255) NOT NULL,
    `manager` VARCHAR(255) NOT NULL,
    `regional_office` VARCHAR(255) NOT NULL
);
-- Relationship: One-to-many.
-- sales_pipeline to all tables.

##################### 2. IMPORTING DATA TO THE TABLES

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crm/accounts.csv'
INTO TABLE `raw_accounts`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS (
	`account`,
	`sector`,
	`year_established`,
	`revenue`,
    `employees`,
	`office_location`,
	`subsidiary`);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crm/products.csv'
INTO TABLE `raw_products`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS (
	`product`,
    `series`,
    `sales_price`);
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crm/sales_pipeline.csv'
INTO TABLE `raw_sales_pipeline`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS (
	`opportunity_id`,
    `sales_agent`,
    `product`,
    `account`,
    `deal_stage`,
    `engage_date`,
    `close_date`,
    `close_value`);    
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crm/sales_teams.csv'
INTO TABLE `raw_sales_teams`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS (
	`sales_agent`,
    `manager`,
    `regional_office`);
    
SELECT * FROM raw_accounts;
SELECT * FROM raw_products;
SELECT * FROM raw_sales_pipeline;    
SELECT * FROM raw_sales_teams;

##################### 3. STAGING_1: Data Cleaning, Standardizing and Checking for NULL Values

CREATE TABLE `st1_accounts` AS 
SELECT * FROM `raw_accounts`;

CREATE TABLE `st1_products` AS 
SELECT * FROM `raw_products`;

CREATE TABLE `st1_sales_pipeline` AS 
SELECT * FROM `raw_sales_pipeline`;

CREATE TABLE `st1_sales_teams` AS 
SELECT * FROM `raw_sales_teams`;

-- Cleaning columns for trailing spaces and converting blanks to NULL
UPDATE `st1_accounts` 
SET `account` = NULLIF(TRIM(`account`),''),
	`sector` = NULLIF(TRIM(`sector`),''),
	`year_established` = NULLIF(TRIM(`year_established`),''),
    `revenue` = NULLIF(TRIM(`revenue`),''),
    `employees` = NULLIF(TRIM(`employees`),''),
    `office_location` = NULLIF(TRIM(`office_location`),''),
    `subsidiary` = NULLIF(TRIM(`subsidiary`),'');

UPDATE `st1_products` 
SET `product` = NULLIF(TRIM(`product`),''),
	`series` = NULLIF(TRIM(`series`),''),
    `sales_price` = NULLIF(TRIM(`sales_price`),'');
    
UPDATE `st1_sales_pipeline` 
SET `opportunity_id` = NULLIF(TRIM(`opportunity_id`),''),
	`sales_agent` = NULLIF(TRIM(`sales_agent`),''),
    `product` = NULLIF(TRIM(`product`),''),
    `account` = NULLIF(TRIM(`account`),''),
    `deal_stage` = NULLIF(TRIM(`deal_stage`),''),
    `engage_date` = NULLIF(TRIM(`engage_date`),''),
    `close_date` = NULLIF(TRIM(`close_date`),''),
    `close_value` = NULLIF(TRIM(`close_value`),'');
	
UPDATE `st1_sales_teams` 
SET `sales_agent` = NULLIF(TRIM(`sales_agent`),''),
	`manager` = NULLIF(TRIM(`manager`),''),
    `regional_office` = NULLIF(TRIM(`regional_office`),'');
    
SELECT * FROM st1_accounts;
SELECT * FROM st1_products;
SELECT * FROM st1_sales_pipeline;
SELECT * FROM st1_sales_teams;

-- Standardizing columns 
UPDATE st1_accounts
SET `sector` = CONCAT(UPPER(LEFT(sector,1)), LOWER(SUBSTRING(sector,2)));

-- Updating column DATA Types
UPDATE st1_sales_pipeline
SET `engage_date` = STR_TO_DATE(`engage_date`, '%Y-%m-%d'),
	`close_date` = STR_TO_DATE(`close_date`, '%Y-%m-%d');
    
UPDATE st1_sales_pipeline
SET st1_sales_pipeline.product = "GTX Pro"
WHERE st1_sales_pipeline.product = "GTXPro";
-- "GTXPro" to "GTX Pro". Based from Products table   
    

ALTER TABLE st1_sales_pipeline 
MODIFY COLUMN `engage_date` DATE,
MODIFY COLUMN `close_date` DATE,
MODIFY COLUMN `close_value` DECIMAL(15, 2);

UPDATE st1_accounts
SET `revenue` = ROUND(`revenue`,2);

ALTER TABLE st1_accounts 
MODIFY COLUMN `revenue` DECIMAL(15,2);

UPDATE st1_products
SET `sales_price` = ROUND(`sales_price`,2);

ALTER TABLE st1_products
MODIFY COLUMN `sales_price` DECIMAL(15,2);

-- Adding Primary Key columns
ALTER TABLE st1_accounts
ADD COLUMN `id` INT AUTO_INCREMENT FIRST,
ADD PRIMARY KEY (`id`);

ALTER TABLE st1_products
ADD COLUMN `id` INT AUTO_INCREMENT FIRST,
ADD PRIMARY KEY (`id`);

ALTER TABLE st1_sales_teams
ADD COLUMN `id` INT AUTO_INCREMENT FIRST,
ADD PRIMARY KEY (`id`);

ALTER TABLE st1_sales_pipeline
ADD COLUMN `id` INT AUTO_INCREMENT FIRST,
ADD PRIMARY KEY (`id`);

##################### 4. STAGING_2: Exploratory Analysis

CREATE TABLE st2_accounts AS
SELECT * FROM st1_accounts;

CREATE TABLE st2_products AS
SELECT * FROM st1_products;

CREATE TABLE st2_sales_pipeline AS
SELECT * FROM st1_sales_pipeline;

CREATE TABLE st2_sales_teams AS
SELECT * FROM st1_sales_teams;

SELECT * FROM st2_accounts;
SELECT * FROM st2_products;
SELECT * FROM st2_sales_pipeline;
SELECT * FROM st2_sales_teams;

-- Account ID to Sales_Pipeline
SELECT	pl.id AS `pl.id`,
			pl.account AS `pl.account`,
				ac.id AS `ac.id`,
					ac.account AS `ac.account`
FROM st2_sales_pipeline  AS pl
JOIN st2_accounts AS ac
	ON pl.account = ac.account;

ALTER TABLE st2_sales_pipeline
ADD COLUMN account_id INT;

UPDATE st2_sales_pipeline AS pi
JOIN st2_accounts AS ac
	ON pi.account = ac.account
SET pi.account_id = ac.id;

-- Products ID to Sales_Pipeline
SELECT 
	pl.id AS `pl.id`,
    pl.product AS `pl.product`,
    pr.id AS `pr.id`,
    pr.product AS `pr.product`
FROM st2_sales_pipeline AS pl
JOIN st2_products AS pr
	ON pl.product = pr.product;

ALTER TABLE st2_sales_pipeline
ADD COLUMN product_id INT;

UPDATE st2_sales_pipeline AS pl
JOIN st2_products AS pr
	ON pl.product = pr.product
SET pl.product_id = pr.id;

-- Sales_Teams to Sales_Pipeline
SELECT 
	pl.id AS `pl.id`,
    pl.sales_agent AS `pl.sales_agent`,
    ss.id AS `ss.id`,
    ss.sales_agent AS `ss.sales_agent`
FROM st2_sales_pipeline AS pl
JOIN st2_sales_teams AS ss
	ON pl.sales_agent = ss.sales_agent;

ALTER TABLE st2_sales_pipeline
ADD COLUMN agent_id INT;

UPDATE st2_sales_pipeline AS pl
JOIN st2_sales_teams AS ss
	ON pl.sales_agent = ss.sales_agent
SET pl.agent_id = ss.id;

-- Checking for trends, data commonalities, NULLS, etc
SELECT * FROM st2_accounts;
SELECT * FROM st2_products;
SELECT * FROM st2_sales_pipeline;
SELECT * FROM st2_sales_teams;

SELECT * FROM st2_sales_pipeline
WHERE account_id IS NULL;
-- NULL values in account_id based on account column
-- Almost all of the NULLS have "Engaging"  as the deal_stage

SELECT COUNT(id), account_id
FROM st2_sales_pipeline
WHERE account IS NULL
GROUP BY account_id;
-- Total Rows with NULLS based on account_id

SELECT * FROM st2_sales_pipeline
WHERE sales_agent LIKE "%Hammack";

-- Upon checking, multiple sales agents have multiple accounts based on what they sell. 
-- Now, the unresolvable issue is that there are NULL values for Account. This cannot be extracted from account_id (accounts table) because 
-- ever propduct has their own account and every account hase their own agent. No accoutn means no account id

-- Upon analysis, account_id under st2_sales_pipeline has NULL Values. This is because there are also NULL values in the account column.
-- Both NULLS from account and account_id serve no purpose in the data. But columns such as product_id and agent_id do. 
-- Therefore, it is unwise to drop rows with NULLS because of account_id. 
-- Only account and account_id has this issue in regarding to NULL Values. 

##################### 4. STAGING_3: Foreign and Primary Keys 

CREATE TABLE st3_sales_teams AS
SELECT * FROM st2_sales_teams;

CREATE TABLE st3_accounts AS
SELECT * FROM st2_accounts;

CREATE TABLE st3_products AS
SELECT * FROM st2_products;

CREATE TABLE st3_sales_pipeline AS
SELECT * FROM st2_sales_pipeline;

SELECT * FROM st3_accounts;
SELECT * FROM st3_products;
SELECT * FROM st3_sales_pipeline;
SELECT * FROM st3_sales_teams;

-- Primary Keys 
ALTER TABLE st3_accounts
MODIFY COLUMN `id` INT AUTO_INCREMENT,
ADD PRIMARY KEY (`id`); 

ALTER TABLE st3_products
MODIFY COLUMN `id` INT AUTO_INCREMENT,
ADD PRIMARY KEY (`id`); 

ALTER TABLE st3_sales_teams
MODIFY COLUMN `id` INT AUTO_INCREMENT,
ADD PRIMARY KEY (`id`); 

ALTER TABLE st3_sales_pipeline
MODIFY COLUMN `id` INT AUTO_INCREMENT,
ADD PRIMARY KEY (`id`); 

-- Foreign Keys
-- st3_sales_pipeline.account_id -> st3_accounts.id
ALTER TABLE st3_sales_pipeline
ADD CONSTRAINT fk_sp_acc
FOREIGN KEY (`account_id`) REFERENCES st3_accounts(`id`)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- st3_sales_pipeline.product_id -> st3_products.id
ALTER TABLE st3_sales_pipeline
ADD CONSTRAINT fk_sp_prd
FOREIGN KEY (`product_id`) REFERENCES st3_products(`id`)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- st3_sales_pipeline.agent_id -> st3_sales_teams.id
ALTER TABLE st3_sales_pipeline
ADD CONSTRAINT fk_sp_sls
FOREIGN KEY (`agent_id`) REFERENCES st3_sales_teams(`id`)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- NOTE: ON DELETE RESTRICT for the account_id
	-- Because of NULL valeus in t3_sales_pipeline.account_id, MySQL will allow those NULLS to exist.
    -- But it cannot allow deleting any account linkted to a sale (Data-First Approach). 

ALTER TABLE st3_accounts RENAME TO 1_accounts;
ALTER TABLE st3_products RENAME TO 1_products;
ALTER TABLE st3_sales_pipeline RENAME TO 1_sales_pipeline;
ALTER TABLE st3_sales_teams RENAME TO 1_sales_teams;

##################### 5. Database Performance Optimization

CREATE INDEX idx_sp_account ON 1_sales_pipeline(account_id);
CREATE INDEX idx_sp_product ON 1_sales_pipeline(product_id);
CREATE INDEX idx_sp_sales_teams ON 1_sales_pipeline(agent_id);
CREATE INDEX idx_sp_deal_stage ON 1_sales_pipeline(deal_stage);


##################### 6. Strategic Business Insights (EDA)

-- Number of Offices per Office Location 
SELECT office_location, COUNT(DISTINCT(account)) AS "Number_of_Offices"
FROM 1_accounts
GROUP BY office_location
ORDER BY Number_of_Offices DESC;

-- Number of Employees Per Office Location
SELECT office_location, SUM(employees) AS "Employees_Per_Location"
FROM 1_accounts
GROUP BY office_location
ORDER BY Employees_per_Location DESC;

-- Total Accumulated Revenue per Sector
SELECT DISTINCT(sector), SUM(revenue) AS "Total_Revenue_Per_Sector" 
FROM 1_accounts
GROUP BY sector
ORDER BY Total_Revenue_Per_Sector DESC;

-- Oldest Accounts
SELECT account, office_location, year_established
FROM 1_accounts
ORDER BY year_established ASC
LIMIT 10;

-- Newest Accounts
SELECT account, office_location, year_established 
FROM 1_accounts
ORDER BY year_established DESC
LIMIT 10;

-- Account with the Most Revenue Generated
SELECT account, sector, year_established, revenue, office_location
FROM 1_accounts
ORDER BY revenue DESC
LIMIT 10;

-- Accounts per Sector 
SELECT DISTINCT(sector) AS "Sector", COUNT(account) AS "Number_of_Accounts"
FROM 1_accounts
GROUP BY sector;

-- Highest Revenue per Account and Year
SELECT account, year_established, revenue
FROM (
	SELECT	account,
		year_established,
		revenue,
		RANK() OVER(PARTITION BY year_established ORDER BY revenue) AS "Rev_rank"
	FROM 1_accounts)  AS rank_table
WHERE Rev_rank = 1
ORDER BY year_established ASC;
	-- RANK() acts as a scoring mechanism that assigns a sequential number to every row in your 1_accounts table
	-- OVER() serves as a lens that allows this calculation to happen side-by-side with your data without collapsing the rows into a summary. 
	-- PARTITION BY divides the table into separate "mini-buckets" for each year, ensuring the ranking restarts at 1 every time the year changes. 


-- Yearly Revenue by Sector 
SELECT year_established AS "Year", 
	ROUND(SUM(CASE WHEN `sector` = "Employment" THEN revenue ELSE 0 END),2) Employment,
    ROUND(SUM(CASE WHEN `sector` = "Entertainment" THEN revenue ELSE 0 END),2)  Entertainment,
    ROUND(SUM(CASE WHEN `sector` = "Finance" THEN revenue ELSE 0 END),2)  Finance,
    ROUND(SUM(CASE WHEN `sector` = "Marketing" THEN revenue ELSE 0 END),2)  Marketing,
    ROUND(SUM(CASE WHEN `sector` = "Medical" THEN revenue ELSE 0 END),2)  Medical,
	ROUND(SUM(CASE WHEN `sector` = "Retail" THEN revenue ELSE 0 END),2)  Retail,
    ROUND(SUM(CASE WHEN `sector` = "Services" THEN revenue ELSE 0 END),2)  Services,
    ROUND(SUM(CASE WHEN `sector` = "Software" THEN revenue ELSE 0 END),2)  Software,
    ROUND(SUM(CASE WHEN `sector` = "Technology" THEN revenue ELSE 0 END),2)  Technology,
	ROUND(SUM(CASE WHEN `sector` = "Telecommunications" THEN revenue ELSE 0 END),2)  Telecommunications
FROM 1_accounts
GROUP BY year_established
ORDER BY year_established ASC;
    
    
####################################################################################################

-- Agent Performance Summary
SELECT 	
    st.sales_agent AS "Agent_Name",
    st.regional_office AS "Office",
    COUNT(sp.id) AS "Total_Deals",
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS "Deals_Won",
    ROUND(COALESCE((SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) / NULLIF(COUNT(sp.id), 0)) * 100, 0), 2) AS "Win_%",
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS "Deals_Lost",
    ROUND(COALESCE((SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) / NULLIF(COUNT(sp.id), 0)) * 100, 0), 2) AS "Lose_%"
FROM 1_sales_teams AS st
LEFT JOIN 1_sales_pipeline AS sp ON st.id = sp.agent_id
GROUP BY st.regional_office, st.sales_agent
ORDER BY "Total_Deals" DESC;

-- Regional Office Peformance Summary (using Agent Performance)
WITH agent_p AS ( 
SELECT 	
    st.sales_agent AS "Agent_Name",
    st.regional_office AS "Office",
    COUNT(sp.id) AS "Total_Deals",
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS "Deals_Won",
    ROUND(COALESCE((SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) / NULLIF(COUNT(sp.id), 0)) * 100, 0), 2) AS "Win_%",
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS "Deals_Lost",
    ROUND(COALESCE((SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) / NULLIF(COUNT(sp.id), 0)) * 100, 0), 2) AS "Lose_%",
    SUM(CASE WHEN sp.deal_stage = 'Engaging' THEN 1 ELSE 0 END) AS "Engaging",
    SUM(CASE WHEN sp.deal_stage = 'Prospecting' THEN 1 ELSE 0 END) AS "Prospecting"
FROM 1_sales_teams AS st
LEFT JOIN 1_sales_pipeline AS sp ON st.id = sp.agent_id
GROUP BY st.regional_office, st.sales_agent
ORDER BY "Total_Deals" DESC)
SELECT 	Office, 
		SUM(Total_Deals) AS "Total_Deals",
		SUM(Deals_Won) AS "Wins",
        ROUND((SUM(Deals_Won) / NULLIF(SUM(Total_Deals), 0)) * 100, 2) AS "Win_Rate",
		SUM(Deals_Lost) AS "Losses",
        ROUND((SUM(Deals_Lost) / NULLIF(SUM(Total_Deals), 0)) * 100, 2) AS "Lose_Rate",
        SUM(Engaging) AS "Engaging",
        SUM(Prospecting) AS "Prospecting"
FROM agent_p
GROUP BY Office;

-- Regional Office Sales Summary
SELECT 	regional_office AS "Regional_Office" ,	
		SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) AS "Total_Product_Sold",
        SUM(pr.sales_price) AS "Target_Sales",
		SUM(sp.close_value) AS "Actual_Sales"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_sales_teams st
	ON sp.agent_id = st.id
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
GROUP BY regional_office;

-- Managerial Efficiency Summary Analysis
SELECT 	st.manager AS "Manager",
        regional_office AS "Region",
        SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) AS "Total_Wins",
        SUM(CASE WHEN deal_stage = "Lost" THEN 1 ELSE 0 END) AS "Total_Losses",
        SUM(CASE WHEN deal_stage = "Engaging" THEN 1 ELSE 0 END) AS "In_Progress",
        SUM(pr.sales_price) AS "Target_Sales",
		SUM(sp.close_value) AS "Actual_Sales",
        ROUND((SUM(sp.close_value)/NULLIF(SUM(pr.sales_price),0))*100,2)AS "Team_Realization_%",
        ROUND((SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END)*100)/NULLIF(COUNT(sp.id),0),2)AS "Team_Win_Rate",
        ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)),0)AS "Avg_Team_Sales_Velocity"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_sales_teams AS st
	ON sp.agent_id = st.id
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
GROUP BY st.manager, regional_office;

CREATE OR REPLACE VIEW v_mangerial_performance AS 
SELECT 	st.manager AS "Manager",
        regional_office AS "Region",
        SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) AS "Total_Wins",
        SUM(CASE WHEN deal_stage = "Lost" THEN 1 ELSE 0 END) AS "Total_Losses",
        SUM(CASE WHEN deal_stage = "Engaging" THEN 1 ELSE 0 END) AS "In_Progress",
        SUM(pr.sales_price) AS "Target_Sales",
		SUM(sp.close_value) AS "Actual_Sales",
        ROUND((SUM(sp.close_value)/NULLIF(SUM(pr.sales_price),0))*100,2)AS "Team_Realization_%",
        ROUND((SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END)*100)/NULLIF(COUNT(sp.id),0),2)AS "Team_Win_Rate",
        ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)),0)AS "Avg_Team_Sales_Velocity"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_sales_teams AS st
	ON sp.agent_id = st.id
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
GROUP BY st.manager, regional_office;

####################################################################################################

-- Profit Sales Velocity #1 (Agent Efficiency Analysis)
SELECT	sp.sales_agent AS "Agent_Name", 
		st.regional_office AS "Office",
		ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)),1) AS "Avg_Sales_Velocity"
FROM 1_sales_pipeline sp
LEFT JOIN 1_sales_teams AS st
	ON sp.agent_id = st.id
WHERE sp.deal_stage = "Won"
GROUP BY sp.sales_agent, st.regional_office
ORDER BY Avg_Sales_Velocity ASC;

-- Average Agent Sales Velocity 
WITH efficiency_ave AS (
SELECT	sales_agent AS "Agent_Name", 
		ROUND(AVG(DATEDIFF(close_date, engage_date)),1) AS "Avg_Sales_Velocity"
FROM 1_sales_pipeline
WHERE deal_stage = "Won"
GROUP BY sales_agent
ORDER BY Avg_Sales_Velocity ASC)
SELECT ROUND(AVG(Avg_Sales_Velocity),0) AS "Average_Velocity" 
FROM efficiency_ave;

-- Average Region Sales Velocity 
WITH avg_region_v AS (
SELECT	sp.sales_agent AS "Agent_Name", 
		st.regional_office AS "Office",
		ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)),1) AS "Avg_Sales_Velocity"
FROM 1_sales_pipeline sp
LEFT JOIN 1_sales_teams AS st
	ON sp.agent_id = st.id
WHERE sp.deal_stage = "Won"
GROUP BY sp.sales_agent, st.regional_office
ORDER BY Avg_Sales_Velocity ASC)
SELECT 	Office,
		ROUND(AVG(Avg_Sales_Velocity),1) AS "Avg_Region_Sales_Velocity"
FROM avg_region_v
GROUP BY Office;

-- Agent Per Product Sales Velocity #2 (Agent to Product Analysis)
SELECT 
    st.sales_agent AS "Agent_Name",
    pr.product AS "Product",
    ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)), 1) AS "Avg_Days_to_Close"
FROM 1_sales_pipeline sp
LEFT JOIN 1_sales_teams st 
	ON sp.agent_id = st.id
LEFT JOIN 1_products pr 
	ON sp.product_id = pr.id
WHERE sp.deal_stage = 'Won'
GROUP BY st.sales_agent, pr.product
ORDER BY Avg_Days_to_Close ASC;

####################################################################################################

-- Market Sector Analysis
SELECT 	ac.sector AS "Market_Sector",
		COUNT(sp.id) AS "Total_Opportunities", 
		SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS "Deals_Won",
        ROUND(SUM((CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100)/NULLIF(COUNT(sp.id), 0),2) AS "Win_Rate",
		SUM(sp.close_value) AS "Revenue_Generated"
FROM 1_accounts AS ac
LEFT JOIN 1_sales_pipeline AS sp 
	ON sp.account_id = ac.id 
GROUP BY Market_Sector
ORDER BY Win_Rate DESC;

-- Product Sales Summary
SELECT 	pr.product AS "Product_Name", 
		pr.series AS "Product_Series",
        SUM(sp.close_value) AS "Total_Sales"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
GROUP BY pr.product, pr.series
ORDER BY Total_Sales DESC;

-- Product Sales Variance
SELECT 	sp.product AS "Product_Name",
		SUM(pr.sales_price) AS "Target_Sales",
		SUM(sp.close_value) AS "Actual_Sales"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
WHERE sp.deal_stage = "Won"
GROUP BY sp.product
ORDER BY "Actual_Sales";

-- Sales Variance Per Agent (Profit/Loss Analysis by Agent per Product)
SELECT 	sp.sales_agent AS "Agent_Name",
		sp.account AS "Sold_to",
		pr.product AS "Product_Name",
        sp.opportunity_id AS "Opportunity_ID",
		COALESCE(sp.close_date, "Engaging") AS "Conversion Date",
        COALESCE(pr.sales_price, 0) AS "Target_Price",
        COALESCE(sp.close_value, 0) AS "Actual_Value_Sold",
        COALESCE(sp.close_value-pr.sales_price, 0) AS "Profit_or_Loss"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
WHERE sp.deal_stage = "Won"
ORDER BY "Profit_or_Loss";

-- Average Sales Variance per Product 
WITH product_sales AS ( 
SELECT 	sp.sales_agent AS "Agent_Name",
		pr.product AS "Product_Name",
        sp.opportunity_id AS "Opportunity_ID",
		COALESCE(sp.close_date, "Engaging") AS "Conversion Date",
        COALESCE(pr.sales_price, 0) AS "Target_Price",
        COALESCE(sp.close_value, 0) AS "Actual_Value_Sold",
        COALESCE(sp.close_value-pr.sales_price, 0) AS "Profit_or_Loss"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
WHERE sp.deal_stage = "Won"
ORDER BY "Profit_or_Loss")
SELECT 	Product_Name,
		Target_Price,
        ROUND(AVG(Actual_Value_Sold),2) AS "Avg_Value_Sold",
        ROUND(Target_Price - AVG(Actual_Value_Sold), 2) AS "Avg_Discount",
		ROUND(((Target_Price - AVG(Actual_Value_Sold))/Target_Price)*100, 2) AS "Avg_Variance"
FROM product_sales
GROUP BY Product_Name, Target_Price
ORDER BY Avg_Discount ASC;

-- Revenue Realization and Variance Percentage (Performance and Profitability Summary of Products)
SELECT	sp.product AS "Product_Name",
		COUNT(sp.id) AS "Total_Opportunities",
        SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) AS "Total_Closed_Deals",
		ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)),0)AS "Avg_Sales_Velocity",
		ROUND((SUM(sp.close_value)/NULLIF(SUM(pr.sales_price),0))*100,2) AS "Realization_%",
        ROUND((SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END)*100)/NULLIF(COUNT(sp.id),0),2) AS "Win_Rate"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
GROUP BY sp.product
ORDER BY Product_Name ASC;
	-- Win Rate (Success): Measures conversion efficiency by showing the percentage of total opportunities that turned into a "Won" deal. "How effective the sales team is at closing."
	-- Sales Velocity (Speed): Measures time efficiency by calculating the average number of days a deal stays in the pipeline. "How fast the company turns a lead into cash."
	-- Realization Rate (Price Integrity): Measures profitability by comparing the actual price paid to the original target price. "Reveals if agents are giving away too many discounts to get a sale."

CREATE OR REPLACE VIEW v_product_performance AS
SELECT 	
    sp.product AS "Product_Name",
    COUNT(sp.id) AS "Total_Opportunities",
    SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) AS "Total_Closed_Deals",
    ROUND(AVG(DATEDIFF(sp.close_date, sp.engage_date)), 0) AS "Avg_Sales_Velocity",
    ROUND((SUM(sp.close_value) / NULLIF(SUM(pr.sales_price), 0)) * 100, 2) AS "Realization_Rate",
    ROUND((SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) * 100) / NULLIF(COUNT(sp.id), 0), 2) AS "Win_Rate"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_products AS pr ON sp.product_id = pr.id
GROUP BY sp.product;

-- Loss Rate Analysis
SELECT	st.regional_office AS "Region", 
		st.manager AS "Manager", 
        sp.sales_agent AS "Agent", 
        sp.product AS "Product",
		COUNT(sp.id) AS "Total_Opportunities", 
        SUM(CASE WHEN deal_stage = "Lost" THEN 1 ELSE 0 END) AS "Deals_Lost",
        ROUND((SUM(CASE WHEN deal_stage = "Lost" THEN 1 ELSE 0 END)*100)/NULLIF(COUNT(sp.id),0),2)AS "Loss_Rate",
        SUM(CASE WHEN deal_stage = "Lost" THEN pr.sales_price ELSE 0 END) AS "Revenue_Impact"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_sales_teams AS st 
	ON sp.agent_id = st.id
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
GROUP BY st.regional_office, st.manager, sp.sales_agent, sp.product
HAVING Deals_Lost > 5;

CREATE OR REPLACE VIEW v_loss_rate AS 
SELECT	st.regional_office AS "Region", 
		st.manager AS "Manager", 
        sp.sales_agent AS "Agent", 
        sp.product AS "Product",
		COUNT(sp.id) AS "Total_Opportunities", 
        SUM(CASE WHEN deal_stage = "Lost" THEN 1 ELSE 0 END) AS "Deals_Lost",
        ROUND((SUM(CASE WHEN deal_stage = "Lost" THEN 1 ELSE 0 END)*100)/NULLIF(COUNT(sp.id),0),2)AS "Loss_Rate",
        SUM(CASE WHEN deal_stage = "Lost" THEN pr.sales_price ELSE 0 END) AS "Revenue_Impact"
FROM 1_sales_pipeline AS sp
LEFT JOIN 1_sales_teams AS st 
	ON sp.agent_id = st.id
LEFT JOIN 1_products AS pr
	ON sp.product_id = pr.id
GROUP BY st.regional_office, st.manager, sp.sales_agent, sp.product;


#################################################################################################################################################################################
