# CRM: Sales Opportunities and Performance Analysis

This project demonstrates a full-scale ETL (Extract, Transform, and Load) process and EDA (Exploratory Data Analysis) using MySQL. Raw CRM data was transformed into a structured relational database to extract actionable business insights regarding product sales, agent and managerial efficiency, product profitability, regional performance, and pipeline opportunities.

---

## 🏗️ Architecture and Design

### Phase 1: Data Ingestion
The first phase involved ingesting raw CSV files using `LOAD DATA INFILE`:
* `accounts.csv`
* `products.csv`
* `sales_pipeline.csv`
* `sales_teams.csv`

#### 📊 Accounts
Contains data regarding company accounts, their sector, year established, generated revenue, employee count, and office locations.

#### 📦 Products
Contains product details, including product names, series, and target sales prices.

#### 👥 Sales Teams
Contains the names of sales agents, their direct managers, and their regional offices.

#### 📈 Sales Pipeline
Contains the transactional history of accounts and sales agents. It tracks deal stages (Won, Lost, Engaging, Prospecting), opportunity values, and engagement/close dates. 

I established a **one-to-many relationship** branching from the `sales_pipeline` table to all dimension tables by assigning Primary Keys to every table and mapping them to Foreign Keys inside the pipeline table.

---

## 🗺️ Relational Schema

<img width="100%" alt="Relational Schema Diagram" src="https://github.com/user-attachments/assets/6476d4c7-73e4-457a-b69d-3e9ec74ac11e" />

---

### Phase 2: Staging, Cleaning, and Transformation
The second phase involved data layering, type-casting, and standardisation to ensure data integrity.

* **Staging #1 - Data Immutability:** Duplicated raw files into staging tables. This preserved the original data while allowing me to safely clean, standardise text casing, and cast data types (such as string-to-date conversions).
* **Staging #2 - Quality Assurance:** Validated the integrity of the data using `SELECT` statements to check for `NULL` values and structural anomalies.
* **Staging #3 - Relational Mapping:** Created Surrogate Keys (`id`) and mapped relational columns (`account_id`, `product_id`, `agent_id`) to the pipeline table.

---

### Phase 3: Database Performance Optimization
To ensure sub-second query execution at scale, I applied B-Tree indexing to heavily referenced Foreign Keys and high-frequency filter columns:

```sql
CREATE INDEX idx_sp_account ON 1_sales_pipeline(account_id);
CREATE INDEX idx_sp_product ON 1_sales_pipeline(product_id);
CREATE INDEX idx_sp_agent ON 1_sales_pipeline(agent_id);
CREATE INDEX idx_sp_deal_stage ON 1_sales_pipeline(deal_stage);
```
---

## 💡 Key Business Insights

### Sales Agent and Managerial Performance 

#### Observations and Insights: 
Overall average win rate of employees is 41.74%  while the average lose rate is 24.05%. The agent with the highest conversion with Reed Clapper (East) with a 65.40% Win rate
With Donn Cantrell (East) having highest lose rate of 42.55%. In terms of volume, Darcel Schlect (Central) has the highest total of wins with a number of 349 deals won while also having highest number of losses having 204 deals lost. 

For Regional Performance, the Central Office holds the highest number of Wins with a total of 1629 successful deals. West Office is second with a total of 1438 Wins while East Office is Third, having a total of 1171 total Wins. 
In terms of Win Rate, East Office is the highest with a 51.11% Win Rate but also holds the highest lose rate with a 29.99% losing rate. 

In terms of Managerial Analysis, Rocco Neubert and his Team of East Office has the highest Team Realization Percentage with 52.84% while having a average of 46 sales velocity. 
Melvin Marxen and his Team from Central Office has the highest number of wins with a total of 882 while also having the highest number of losses totaling to 536. 
Rocco Neubert and his team has the highest percentage of price integrity. With 52.84% of Team Realization, Rocco Neubert’s management style prioritizes high-quality revenue over high-volume discounting, leading to healthier bottom-line results for the region.
Melvin Marxen and his Team's Realization Percentage is 44.73%, which is the lowest. Him and his team has te lowest win rate and lowest team realization percentage. 

#### Recommendations: 
The main focus for improvement is East office. Even though they have the highest winning rate percentage, they also have the highest losing percentage of 29.99%. This suggests that there is a High-risk / High-reward environment.
East office should have a lead-qualification audit to ensure agents aren't spending too much time on deals that have a high probability of failing. 
Another solution (if the office is open to it) is to have agents with the highest win rate from Central Office to have a formalized training for East Office.



### Product Profitability

#### Observations and Insights: 
Out of all the products, the GTX Pro is the best seller with a total of 3,510,578 total sales. With a target price of 5482, sales agents sell the product at the average of 5489.88, which is a 7.88 Markup from the Target Price. 
While the GTK 500 is sold at an average of 26,707.47. The product is price at 2678, which means that there is a 60.53 difference or "discount" given to buyers. 
The highest profit for a deal is 30288 with the GTK 500 which was sold by Rosalina Dieter to Groovestreet. Kary Hendrixson on the other hand sold GTX Pro to Hatfan at the price of 3169, failing to sell at or above the target price of 4821. This gives a loss of 1652. 

#### Recommendations: 
The GTX Pro can be considered as the flagship product as it is the mid-range product priced at 4821. This product can be leveraged as a a High-Margin Leader, achieving a 7.88 Markup over its target price. I recommend analyzing the sales scripts used for the GTX Pro to see if the same selling techniques can be applied to other products, specifically those products that are not highly sellable. 
Such analysis can be done through a case study on Rosalina Dieters deal on the GTK 500. Her managing to close a deal with a high markup is a massive success for price realization. A review on that deal can help understand the specifics on how the deal was closed and how other agents can replicate huge wins. 



### Sales Agent Sales Velocity (Agent Efficiency Analysis)

#### Observations and Insights:
The average days for an agent to turn a deal into a win is 52 days, with Cecily Lampkin (Central Office) managing to convert deals in 42 days. While Moses Frase (Central Office) converts deals in 65 days, which is 2 months. 

Central office averages 53 days to close and Win a deal, West closes at 51.5 days while East Office closes at 51 days. This means that East is very efficient in terms of client relationships, selling strategies, and negotiating power. Butin summary all three offices will mange to close a deal within 50 days, which is a month and a half. It all comes down to the leadership of the manager and the skills of the sales agent on how efficient the sale would be. 

#### Recommendations: 
Since both Cecily Lampkin and Moses Frase are in the same office, an internal mentorhip could be done to improve Frase's skills. This can also be done in Central Office as a whole. With Cecily mentoring, she could help other sales agents to improve. After mentoring, she could land into a leadership role as she knows how to be efficient as a Sales Agent. Her being a manager allows her to lead and nurture a team to be efficient. 

Sales Agents with the highest sales velocity rate in East and West office can also do this within their own. Internal Mentorship can improve agent performance and can also nurture future leaders. 



### Market Sector Analysis

#### Observations and Insights:
The Marketing sector has the highest win rate for closing a deal which with 59.94%. While the Retail sector is the most profitable as it has generated 1.86 Million in revenue. 799 deals has been closed for the sector and the Win Rate is 57.19. While the Technology Sector has a higher Win Rate of 57.60, it seems to come second to Retail as deals won for this sector is 671. 
Nevertheless, the most profitable sectors are Retail, Technology, Medical, Software, and Marketing. 

#### Recommendations: 
To gain more revnue, sellers should pitch more to the Tech and Retail Sector as the products are more useful and much more in-demand unlike in the Finance Sector. Marketing the Flagship product (GTX Pro) is a safe way to gain steady footing and establishing a name in the sector. Other products can then be marketed to further meet the demands of the buyers.





















