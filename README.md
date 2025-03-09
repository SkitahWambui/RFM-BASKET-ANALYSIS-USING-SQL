# RFM AND MARKET BASKET ANALYSIS USING SQL AND PYTHON
# Market Basket Analysis Using FP-Growth Algorithm

![A basket.](https://www.facebook.com/photo/?fbid=2575698139120326&set=a.973809642642525)
This project performs **Market Basket Analysis** using the **FP-Growth algorithm** to identify frequent itemsets and association rules from transactional data. The goal is to uncover relationships between products and understand which items are frequently purchased together.
Understanding which items are often bought together is important because it can help dictate how a supermarket is arranged. For example, bread and milk might be put on the same aisle because they are often bought together.

For ecommerce stores a masket basket analysis helps to increase sales as a store is able to recommend other items when a customer makes a purchase.
![Frequently bought together.](https://photos.google.com/photo/AF1QipOW59sUXEV-0Jc47DxeFxvY-4KoIy_cSbCxec2L)

## Dataset
The dataset used in this project contains transactional data with the following columns:
- `Order ID`: Unique identifier for each order.
- `Sub-Category`: The category of the product purchased.
- `Quantity`: The number of units purchased.

## Steps
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

2. **FP-Growth Algorithm**:
   - Applied the FP-Growth algorithm to find frequent itemsets with a minimum support threshold of `0.003`.
    ``` python
    frequent_items = fpgrowth(encoded_basket, min_support = 0.003, use_colnames=True)
    frequent_items.head()
    ```

3. **Visualization**:
   - Visualized the top 15 most purchased items using a bar plot.

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
