# 📊 CRM: Sales Opportunities and Performance Analysis

This project demonstrates a full-scale **ETL (Extract, Transform, and Load)** process and **EDA (Exploratory Data Analysis)** using MySQL. Raw CRM data was transformed into a structured relational database to extract actionable business insights regarding product sales, agent and managerial efficiency, product profitability, regional performance, and pipeline opportunities.

---

## 🏗️ Architecture and Design

### Phase 1: Data Ingestion
The first phase involved ingesting raw CSV files using the `LOAD DATA INFILE` command:
* `accounts.csv`
* `products.csv`
* `sales_pipeline.csv`
* `sales_teams.csv`

#### 📊 Data Dimensions
* **Accounts:** Corporate entity data including sector, year established, revenue, and employee count.
* **Products:** Product catalog details, including series and target sales prices.
* **Sales Teams:** Hierarchical mapping of sales agents to their direct managers and regional offices.
* **Sales Pipeline:** Transactional history tracking deal stages (**Won, Lost, Engaging, Prospecting**), opportunity values, and key dates.

I established a **one-to-many relationship** branching from the `sales_pipeline` table to all dimension tables by assigning Primary Keys and mapping them to Foreign Keys within the pipeline table.

---

## 🗺️ Relational Schema

<img width="100%" alt="Relational Schema Diagram" src="https://github.com/user-attachments/assets/6476d4c7-73e4-457a-b69d-3e9ec74ac11e" />

---

### Phase 2: Staging, Cleaning, and Transformation
The second phase utilized a three-layer staging process to ensure data integrity:

1. **Staging #1 - Data Immutability:** Duplicated raw files into staging tables to preserve original data while standardizing text casing and casting string-to-date formats.
2. **Staging #2 - Quality Assurance:** Validated data integrity by auditing for `NULL` values and structural anomalies (e.g., identifying 500 "Prospecting" deals previously excluded from funnel counts).
3. **Staging #3 - Relational Mapping:** Created Surrogate Keys (`id`) and mapped relational columns (`account_id`, `product_id`, `agent_id`) to the final pipeline table.

---

### Phase 3: Database Performance Optimization
To ensure sub-second query execution at scale, I applied B-Tree indexing to high-frequency filter columns and foreign keys:

```sql
CREATE INDEX idx_sp_account ON 1_sales_pipeline(account_id);
CREATE INDEX idx_sp_product ON 1_sales_pipeline(product_id);
CREATE INDEX idx_sp_agent ON 1_sales_pipeline(agent_id);
CREATE INDEX idx_sp_deal_stage ON 1_sales_pipeline(deal_stage);
```

---

## 💡 Key Business Insights

### 1. Sales Agent and Managerial Performance 

#### **Observations and Insights:**
* **Conversion Benchmarks:** The organization maintains an overall average win rate of **41.74%**, while the average loss rate is **24.05%**.
* **Performance Leaders:** **Reed Clapper (East)** leads the organization with a **65.40% Win Rate**, while **Donn Cantrell (East)** recorded the highest loss rate at **42.55%**.
* **Volume Drivers:** **Darcel Schlecht (Central)** handles the highest volume, securing **349 wins** and **204 losses**.
* **Regional Dynamics:** The **Central Office** delivers the highest volume (**1,629 wins**), but the **East Office** is the most efficient with a **51.11% Win Rate**.
* **Price Integrity:** **Rocco Neubert (East)** achieved the highest **Team Realization at 52.84%**, prioritizing high-quality revenue over discounting. Conversely, **Melvin Marxen (Central)** recorded the lowest realization (**44.73%**).

#### **Recommendations:**
* **Execute Lead-Qualification Audits:** The East office presents a "High-Risk/High-Reward" profile. I recommend an audit to ensure agents are not over-investing in low-probability deals.
* **Cross-Regional Training:** Implement formalized training where top performers from the Central Office mentor East Office agents to stabilize conversion volatility.

---

### 2. Product Profitability

#### **Observations and Insights:**
* **Flagship Performance:** The **GTX Pro** is the best seller (**3,510,578 units**). With a target price of **4,821**, it averages a sale price of **5,489.88**—a **7.88 unit markup**.
* **Pricing Gaps:** The **GTK 500** consistently requires an average **60.53 discount** below its target price to close.
* **Deal Variance:** **Rosalina Dieter** secured a record **30,288 profit** on a GTK 500 sale, while **Kary Hendrixson** recorded a **1,652 loss** on a GTX Pro sale.

#### **Recommendations:**
* **Leverage the GTX Pro:** As a high-margin leader, the sales techniques used for the GTX Pro should be analyzed and applied to underperforming lines to defend price integrity.
* **Success Case Study:** Conduct a formal review of high-markup deals to understand specific negotiation techniques and replicate those wins across the fleet.

---

### 3. Sales Velocity (Efficiency Analysis)

#### **Observations and Insights:**
* **Speed-to-Close:** The average time to win a deal is **52 days**. **Cecily Lampkin (Central)** is the efficiency leader (**42 days**), while **Moses Frase (Central)** lags at **65 days**.
* **Regional Benchmarks:** All three offices average between **51 and 53 days** (approx. 1.7 months). The East Office maintains a slight competitive edge in speed and negotiation power.

#### **Recommendations:**
* **Internal Mentorship:** Since the fastest and slowest agents (Lampkin and Frase) are in the same office, a mentorship program should be established to transfer high-velocity techniques.
* **Leadership Pipeline:** Cecily Lampkin’s ability to maintain high velocity makes her an ideal candidate for future leadership roles to lead and nurture a team.

---

### 4. Market Sector Analysis

#### **Observations and Insights:**
* **Sector Efficiency:** The **Marketing** sector has the highest win rate (**59.94%**).
* **Revenue Leaders:** **Retail** is the most profitable sector, generating **1.86 Million** in revenue with a **57.19% Win Rate**.
* **Tech Sector:** Shows strong performance with a **57.60% Win Rate** and **671** deals won.

#### **Recommendations:**
* **Strategic Targeting:** Sales efforts should prioritize **Tech and Retail** sectors where demand and profitability are highest.
* **Anchor Strategy:** Market the flagship **GTX Pro** heavily within these sectors to establish a revenue anchor before upselling secondary products.

---


