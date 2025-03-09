# RFM AND MARKET BASKET ANALYSIS USING SQL AND PYTHON

## RFM Analysis and Customer Segmentation Using SQL

This project performs **RFM (Recency, Frequency, Monetary) analysis** and **customer segmentation** on a sales dataset using SQL. The goal is to identify customer behavior patterns and segment customers based on their purchasing habits to improve marketing strategies and customer retention.

This is the reason why your friend might have a discount on Bolt and you don't, your RFM scores might be different meaning Bolt is using targeted marketing.

   ![demographic-geographic-psychographic-behavioral-market-segmentation-vector](https://github.com/user-attachments/assets/8e812d5c-dea1-415e-9b21-5624c90a246c)


### Dataset
The dataset used in this project contains two tables:
1. **`orders`**: Contains information about customer orders, including `order_id`, `customer_name`, `order_date`, `state`, and `city`.
2. **`orderdetails`**: Contains details about each order, including `order_id`, `amount`, `profit`, `quantity`, `category`, `subcategory`, and `paymentmode`.

### Steps Performed

#### 1. Data Cleaning
- **Renamed Columns**: Standardized column names for consistency.
  ```sql
  ALTER TABLE orderdetails
      RENAME COLUMN `Order ID` TO order_id,
      RENAME COLUMN `Amount` TO `amount`,
      RENAME COLUMN `Profit` TO `profit`,
      RENAME COLUMN `Quantity` TO `quantity`,
      RENAME COLUMN `Category` TO `category`,
      RENAME COLUMN `Sub-Category` TO `subcategory`,
      RENAME COLUMN `PaymentMode` TO `paymentmode`;
      
      UPDATE orders
      SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y')
      WHERE order_date LIKE '%-%-%';
      ALTER TABLE orders
        MODIFY COLUMN order_date DATE;

#### 2. RFM Analysis
- **Created RFM View:** Calculated Recency, Frequency, and Monetary values for each customer.
  ```sql
  WITH segments AS (
    SELECT
        customer_name,
        last_order_date,
        order_value,
        recency,
        frequency,
        monetary,
        rfm_weights,
        norm_rfm_score,
        CASE 
            WHEN norm_rfm_score = 0 THEN "lost_customers"
            WHEN norm_rfm_score >= 0.8 THEN "top customers"
            WHEN norm_rfm_score >= 0.5 THEN "loyal customers"
            WHEN norm_rfm_score >= 0.2 THEN "At risk/Need attention"
            ELSE "immediate attention"
        END AS segment
    FROM rfm
    ORDER BY norm_rfm_score DESC
   )

   SELECT
       r.customer_name,
       o.state,
       o.city,
       r.segment
   FROM segments r
   LEFT JOIN orders o
   ON r.customer_name = o.customer_name;

#### 3. Results
- **RFM Scores:** Calculated Recency, Frequency, and Monetary values for each customer.
- **Customer Segments:** Customers were segmented into categories such as:
   **Top Customers:** High RFM scores.
   **Loyal Customers:** Moderate RFM scores.
   **At Risk/Need Attention:** Customers who may churn.
   **Immediate Attention:** Customers with low RFM scores.

#### 4. Visualisation on Power BI
As Madhav Stores main goal was to reward top customers, I created a visualisation in Power BI to illustrate the impact of the top customers and their demographics. 

   ![image](https://github.com/user-attachments/assets/06f04e6e-62c9-429e-a536-c0f8e16f3aba)


#### 5. Analysis and Recommendations
This dashboard provides powerful insights for targeted marketing. The store should focus on:
- Rewarding loyalty with special discounts & VIP perks. For example: Top customers get 10% off on sarees & accessories this month!
- Optimizing payment methods to drive more digital transactions; Pay via UPI & get an extra 5% off on your purchase!
- Leveraging seasonal trends for maximum profit; Diwali Special: Buy 2 sarees & get a free stole!
- Using location-based promotions to enhance engagement; Free shipping on all orders from Maharashtra this week!
- Implementing upselling & cross-selling tactics to increase order value; Bought a saree? Add a matching stole for just ₹19!
- Strengthen Customer Engagement via Personalized Communication; Invite top customers to special preview sales & events


## Market Basket Analysis Using FP-Growth Algorithm (Python)

   ![image](https://github.com/user-attachments/assets/e6985768-a603-4b14-8fe8-b0fa2aefd599)

This project performs **Market Basket Analysis** using the **FP-Growth algorithm** to identify frequent itemsets and association rules from transactional data. The goal is to uncover relationships between products and understand which items are frequently purchased together.
Understanding which items are often bought together is important because it can help dictate how a supermarket is arranged. For example, bread and milk might be put on the same aisle because they are often bought together.

For ecommerce stores a masket basket analysis helps to increase sales as a store is able to recommend other items when a customer makes a purchase.

   ![Screenshot_2025-02-27-17-53-10-076_com android chrome](https://github.com/user-attachments/assets/b9614509-7724-4ce1-bb06-b08a4719cc47)


### Dataset
The dataset used in this project contains transactional data with the following columns:
- `Order ID`: Unique identifier for each order.
- `Sub-Category`: The category of the product purchased.
- `Quantity`: The number of units purchased.

### Steps Performed

#### 1. Data Preprocessing:
   - Grouped the data by `Order ID` and created a list of `Sub-Category` items for each order.
   - Encoded the transaction data into a binary matrix using `TransactionEncoder`.
    ``` python
    basket = df.groupby('Order ID')['Sub-Category'].apply(list).tolist()
    encoder = TransactionEncoder()
    encoded_basket = encoder.fit(basket).transform(basket)
    encoded_basket = pd.DataFrame(encoded_basket, columns = encoder.columns_)
    encoded_basket.head()
    ```
    
#### 2. Visualization:
   - Visualized the top 15 most purchased items using a bar plot.
   ``` python
   top_15 = basket_encoded.sum().sort_values(ascending=False)[:15]
   plt.figure(figsize=(20,10))
   sns.barplot(x=top_10.index,y=top_15.values)
   ```
     ![image](https://github.com/user-attachments/assets/c857ef56-8de1-4ffb-a6af-a7ee5b7e0694)


#### 3. FP-Growth Algorithm:
   - Applied the FP-Growth algorithm to find frequent itemsets with a minimum support threshold of `0.003`.
    ``` python
    frequent_items = fpgrowth(encoded_basket, min_support = 0.003, use_colnames=True)
    frequent_items.head()
    ```

#### 4. Association Rules:
   - Generated association rules to identify relationships between items.
   ``` python
   rules = association_rules(frequent_items, metric='lift', min_threshold=0.05, num_itemsets=2)
   rules.head()
   ```

   ![image](https://github.com/user-attachments/assets/c2ff3d61-fd21-40bc-984a-84dfe32668f3)


#### 5. Analysis and Recommendations
- The Market Basket Analysis reveals strong associations between Handkerchief and Stole, making them ideal for cross-selling and bundling. 
- While the association between Handkerchief and Saree is weaker, it still presents an opportunity for targeted promotions.
- By leveraging these insights, you can optimize product placement, marketing strategies, and customer engagement to drive sales and improve customer satisfaction.

## Requirements
- Python 3.x
- Libraries: `pandas`, `mlxtend`, `matplotlib`, `seaborn`

## Installation
```bash
pip install pandas mlxtend matplotlib seaborn
