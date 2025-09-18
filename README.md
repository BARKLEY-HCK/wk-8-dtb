📖 E-Commerce Store Database – README
🎯 Project Objective

This project implements a relational database management system (RDBMS) for a simple E-commerce Store using MySQL.
It supports managing users, products, suppliers, inventory, orders, payments, and reviews.

🛠️ How to Run

Open MySQL Workbench (or any MySQL client).

Copy and paste the contents of ecommerce_store.sql.

Run the script in your SQL editor.

The database ecommerce_store will be created with all required tables, constraints, and indexes.

📂 Database Schema Overview
1. Users & Addresses

users → Stores customer accounts.

addresses → A user can have multiple addresses (one-to-many).

2. Products & Categories

categories → Hierarchical product classification (self-referencing with parent_id).

products → Stores product details with category link.

product_images → Multiple images per product.

3. Suppliers & Inventory

suppliers → Vendor details.

product_suppliers → Many-to-many relationship between products and suppliers.

inventory → Tracks product stock per warehouse.

4. Orders & Payments

orders → Stores customer orders (links to users + addresses).

order_items → Each order has multiple products.

payments → Payment transactions for orders.

5. Reviews

reviews → Customers can rate & review products (one review per user per product).

🔗 Relationships Summary

One-to-Many

User → Addresses

Category → Products

Product → Product Images

Order → Order Items

Many-to-Many

Product ↔ Supplier (via product_suppliers)

Self-Referencing

Categories can have subcategories (parent_id).

🔒 Constraints

Primary Keys → Unique identifiers for all tables.

Foreign Keys → Maintain referential integrity across tables.

Unique → Prevent duplicate usernames, emails, SKUs, etc.

Check Constraints → Validate positive prices, quantities, and rating ranges.

⚡ Indexes

idx_products_category → Fast lookup of products by category.

idx_inventory_product → Quick access to inventory by product.

idx_orders_user → Efficient retrieval of orders per user.

idx_order_items_order → Fast lookup of order items by order.

🚀 Future Improvements

Add triggers to update inventory when orders are placed.

Implement soft deletes (is_active flags).

Add audit tables for tracking changes.

Support discount codes and shipping methods.
