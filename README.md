# RFM AND MARKET BASKET ANALYSIS USING SQL AND PYTHON
## Market Basket Analysis Using FP-Growth Algorithm

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

### Steps
1. **Data Preprocessing**:
   - Grouped the data by `Order ID` and created a list of `Sub-Category` items for each order.
   - Encoded the transaction data into a binary matrix using `TransactionEncoder`.
    ``` python
    basket = df.groupby('Order ID')['Sub-Category'].apply(list).tolist()
    encoder = TransactionEncoder()
    encoded_basket = encoder.fit(basket).transform(basket)
    encoded_basket = pd.DataFrame(encoded_basket, columns = encoder.columns_)
    encoded_basket.head()
    ```
    
2. **Visualization**:
   - Visualized the top 15 most purchased items using a bar plot.
   ``` python
   top_15 = basket_encoded.sum().sort_values(ascending=False)[:15]
   plt.figure(figsize=(20,10))
   sns.barplot(x=top_10.index,y=top_15.values)
   ```
                        ![image](https://github.com/user-attachments/assets/c857ef56-8de1-4ffb-a6af-a7ee5b7e0694)


3. **FP-Growth Algorithm**:
   - Applied the FP-Growth algorithm to find frequent itemsets with a minimum support threshold of `0.003`.
    ``` python
    frequent_items = fpgrowth(encoded_basket, min_support = 0.003, use_colnames=True)
    frequent_items.head()
    ```

4. **Association Rules**:
   - Generated association rules to identify relationships between items.
   ``` python
   rules = association_rules(frequent_items, metric='lift', min_threshold=0.05, num_itemsets=2)
   rules.head()
   ```

## Requirements
- Python 3.x
- Libraries: `pandas`, `mlxtend`, `matplotlib`, `seaborn`

## Installation
```bash
pip install pandas mlxtend matplotlib seaborn
