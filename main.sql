CREATE DATABASE ecommerce_store;
USE ecommerce_store;

-- Table: users
CREATE TABLE users (
  user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: addresses (one user can have many addresses)
CREATE TABLE addresses (
  address_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  label VARCHAR(50), -- e.g., 'Home', 'Office'
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(30),
  country VARCHAR(100) NOT NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table: categories (hierarchical via parent_id)
CREATE TABLE categories (
  category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(120) NOT NULL UNIQUE,
  parent_id INT UNSIGNED,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Table: products
CREATE TABLE products (
  product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  weight_kg DECIMAL(8,3) DEFAULT NULL,
  category_id INT UNSIGNED,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Table: product_images (one-to-many product -> images)
CREATE TABLE product_images (
  image_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  url VARCHAR(1024) NOT NULL,
  alt_text VARCHAR(255),
  position INT UNSIGNED NOT NULL DEFAULT 0,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Table: suppliers
CREATE TABLE suppliers (
  supplier_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  contact_email VARCHAR(255),
  phone VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: product_suppliers (many-to-many product <-> supplier)
CREATE TABLE product_suppliers (
  product_id BIGINT UNSIGNED NOT NULL,
  supplier_id INT UNSIGNED NOT NULL,
  supplier_sku VARCHAR(128),
  cost_price DECIMAL(10,2) CHECK (cost_price >= 0),
  PRIMARY KEY (product_id, supplier_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE
);

-- Table: inventory (keeps stock per product, per location optional)
CREATE TABLE inventory (
  inventory_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  warehouse_code VARCHAR(50) DEFAULT 'MAIN',
  quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  UNIQUE (product_id, warehouse_code)
);

-- Table: orders
CREATE TABLE orders (
  order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_number VARCHAR(50) NOT NULL UNIQUE,
  order_status ENUM('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  shipping_address_id BIGINT UNSIGNED,
  billing_address_id BIGINT UNSIGNED,
  subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
  shipping DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (shipping >= 0),
  tax DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (tax >= 0),
  total DECIMAL(12,2) NOT NULL CHECK (total >= 0),
  placed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id),
  FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id)
);

-- Table:-- order_items (one order has many items)
CREATE TABLE order_items (
  order_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  sku VARCHAR(64) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  quantity INT UNSIGNED NOT NULL CHECK (quantity > 0),
  line_total DECIMAL(12,2) NOT NULL CHECK (line_total >= 0),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Table: payments
CREATE TABLE payments (
  payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  payment_method ENUM('card','paypal','bank_transfer','cash_on_delivery') NOT NULL,
  payment_status ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
  transaction_id VARCHAR(255),
  processed_at TIMESTAMP NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
  );

-- Table: reviews (users review products)
CREATE TABLE reviews (
  review_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title VARCHAR(255),
  body TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (product_id, user_id), -- one review per user per product
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) 
  );

-- indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
