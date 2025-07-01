
-- TABLE CREATION

-- Create Customers table
-- Hint: Define customer_id as the primary key and include name and city columns
CREATE TABLE Customers (
     customer_id INT PRIMARY KEY,
     name VARCHAR(100),
     city VARCHAR(50)
);

-- Create Products table
-- Hint: Define product_id as the primary key and include product_name and price columns
CREATE TABLE Products (
     product_id INT PRIMARY KEY,
     product_name VARCHAR(100),
     price DECIMAL(10,2)
);

-- Create Orders table
-- Hint: Define order_id as the primary key, link customer_id and product_id to their respective tables using foreign keys
CREATE TABLE Orders (
     order_id INT PRIMARY KEY,
     customer_id INT,
     product_id INT,
     quantity INT,
     order_date DATE,
     FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
     FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- DATA INSERTION

-- Insert Customers
-- Hint: Insert customer data with customer_id, name, and city
INSERT INTO Customers VALUES (1, 'Alice', 'New York');
INSERT INTO Customers VALUES (2, 'Bob', 'Los Angeles');
INSERT INTO Customers VALUES (3, 'Charlie', 'Chicago');
INSERT INTO Customers VALUES (4, 'Diana', 'New York');
INSERT INTO Customers VALUES (5, 'Eve', 'Houston');

-- Insert Products
-- Hint: Insert product data with product_id, product_name, and price
INSERT INTO Products VALUES (101, 'Laptop', 1000.00);
INSERT INTO Products VALUES (102, 'Smartphone', 600.00);
INSERT INTO Products VALUES (103, 'Tablet', 300.00);
INSERT INTO Products VALUES (104, 'Headphones', 100.00);
INSERT INTO Products VALUES (105, 'Monitor', 200.00);

-- Insert Orders
-- Hint: Insert order data with order_id, customer_id, product_id, quantity, and order_date
INSERT INTO Orders VALUES (1001, 1, 101, 1, DATE '2024-06-01');
INSERT INTO Orders VALUES (1002, 1, 102, 2, DATE '2024-06-05');
INSERT INTO Orders VALUES (1003, 2, 103, 3, DATE '2024-06-07');
INSERT INTO Orders VALUES (1004, 3, 101, 1, DATE '2024-06-10');
INSERT INTO Orders VALUES (1005, 3, 104, 4, DATE '2024-06-11');
INSERT INTO Orders VALUES (1006, 4, 105, 2, DATE '2024-06-12');
INSERT INTO Orders VALUES (1007, 5, 103, 1, DATE '2024-06-14');
INSERT INTO Orders VALUES (1008, 5, 102, 1, DATE '2024-06-15');

-- EASY QUESTIONS

-- Question 1: List all customers whose city is the same as 'Alice’s city'
-- Hint: Use a subquery to get Alice's city and match it with other customers' cities
SELECT name, city FROM customers WHERE city = (SELECT city FROM customers WHERE name = 'Alice');

-- Question 2: Find all orders for products that cost more than $500
-- Hint: Use a subquery to find product IDs of items priced over $500 and check orders for those products
SELECT * FROM Orders WHERE product_id IN (
     SELECT product_id
     FROM Products
     WHERE price > 500
);

-- Question 3: Show the names of customers who have placed at least one order
-- Hint: Use EXISTS to check if a customer has any orders by matching their customer_id
SELECT name FROM Customers c WHERE EXISTS (
     SELECT 1
     FROM Orders o
     WHERE o.customer_id = c.customer_id
);

-- Question 4: Display product names that have not been ordered by anyone
-- Hint: Use NOT EXISTS to find products with no matching orders by comparing product_id
SELECT product_name FROM products p WHERE NOT EXISTS (
     SELECT 1
     FROM orders o
     WHERE o.product_id = p.product_id
);

-- Question 5: Find customers who ordered a 'Tablet'
-- Hint: Use a subquery to get the product_id of 'Tablet' and find customers who ordered it
SELECT name FROM Customers WHERE customer_id IN (
     SELECT customer_id
     FROM Orders
     WHERE product_id = (
         SELECT product_id
         FROM Products
         WHERE product_name = 'Tablet'
     )
);

-- MEDIUM QUESTIONS

-- Question 6: Display each customer’s name and their total quantity of products ordered
-- Hint: Use a subquery in the SELECT clause to sum the quantity of orders for each customer
SELECT c.name, (SELECT SUM(o.quantity) FROM orders o WHERE c.customer_id = o.customer_id) AS order_per_person FROM customers c;

-- Question 7: Find products ordered by 'Charlie'
-- Hint: Use a subquery in the FROM clause to get Charlie's orders and match their product IDs
SELECT DISTINCT p.product_name FROM Products p WHERE p.product_id IN (
     SELECT charlie_orders.product_id
     FROM (
         SELECT o1.*
         FROM Orders o1
         WHERE o1.customer_id = (
             SELECT c.customer_id
             FROM Customers c
             WHERE c.name = 'Charlie'
         )
     ) charlie_orders
);

-- Question 8: Show customers who ordered both a Laptop and a Smartphone
-- Hint: Use INTERSECT to find product IDs ordered by both customers and match to products
SELECT DISTINCT p.product_name FROM products p WHERE p.product_id IN (
     SELECT o1.product_id
     FROM orders o1
     WHERE o1.customer_id = (
         SELECT c1.customer_id FROM customers c1 WHERE c1.name = 'Alice'
     )
     INTERSECT
     SELECT o2.product_id
     FROM orders o2
     WHERE o2.customer_id = (
         SELECT c2.customer_id FROM customers c2 WHERE c2.name = 'Bob'
     )
);

-- Question 9: Find orders with quantities above the average order quantity
-- Hint: Use a subquery to calculate the average quantity across all orders and compare
SELECT order_id, SUM(quantity) AS total_quantity FROM orders GROUP BY order_id HAVING SUM(quantity) > (
     SELECT AVG(order_total)
     FROM (
         SELECT SUM(quantity) AS order_total
         FROM orders
         GROUP BY order_id
     )
);

-- Question 10: List orders where the product’s price is greater than the average product price
-- Hint: Use a subquery to calculate the average price of products and find orders for those products
SELECT * FROM orders o WHERE o.product_id IN (
     SELECT p.product_id
     FROM products p
     WHERE p.price > (
         SELECT AVG(price)
         FROM products
     )
);

-- ADVANCED QUESTIONS

-- Question 11: Display the top 2 customers with the highest total spending
-- Hint: Join orders with products to calculate total spending, group by customer, and limit to top 2
SELECT c.name, SUM(o.quantity * p.price) AS total_spending FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN products p ON o.product_id = p.product_id GROUP BY c.name ORDER BY total_spending DESC FETCH FIRST 2 ROWS ONLY;

-- Question 12: List products that have been ordered by all customers in New York
-- Hint: Use a correlated subquery to ensure a product is ordered by every New York customer
SELECT p.product_name FROM products p WHERE NOT EXISTS (
     SELECT c.customer_id
     FROM customers c
     WHERE c.city = 'New York'
     AND NOT EXISTS (
         SELECT 1
         FROM orders o
         WHERE o.customer_id = c.customer_id
         AND o.product_id = p.product_id
     )
);

-- Question 13: Show customers who ordered products that no other customer ordered
-- Hint: Use a correlated subquery to find products ordered only by one customer
SELECT c.name FROM customers c WHERE EXISTS (
     SELECT 1
     FROM orders o
     WHERE o.customer_id = c.customer_id
     AND NOT EXISTS (
         SELECT 1
         FROM orders o2
         WHERE o2.product_id = o.product_id
         AND o2.customer_id != c.customer_id
     )
);

-- Question 14: For each customer, show their name and the most expensive product they ordered
-- Hint: Use a correlated subquery to find the product with the highest price for each customer
SELECT c.name, (
     SELECT p.product_name
     FROM products p
     JOIN orders o ON p.product_id = o.product_id
     WHERE o.customer_id = c.customer_id
     ORDER BY p.price DESC
     FETCH FIRST 1 ROW ONLY
) AS most_expensive_product FROM customers c WHERE EXISTS (
     SELECT 1
     FROM orders o
     WHERE o.customer_id = c.customer_id
);

-- Question 15: Find customers with more than 2 orders and no orders for products priced <= 500
-- Hint: Use a subquery to count orders and NOT EXISTS to ensure no low-priced product orders
SELECT c.name FROM customers c WHERE (
     SELECT COUNT(DISTINCT o.order_id)
     FROM orders o
     WHERE o.customer_id = c.customer_id
) > 2 AND NOT EXISTS (
     SELECT 1
     FROM orders o2
     JOIN products p ON o2.product_id = p.product_id
     WHERE o2.customer_id = c.customer_id
     AND p.price <= 500
);
