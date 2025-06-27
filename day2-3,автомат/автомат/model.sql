-- Удаление старых версий (если нужно)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS discounts;
DROP TABLE IF EXISTS promotions;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS shipping_methods;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- Создание таблиц

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100),
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    address TEXT
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    supplier_id INT,
    price DECIMAL(10, 2),
    description TEXT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE shipping_methods (
    shipping_method_id SERIAL PRIMARY KEY,
    method_name VARCHAR(50),
    cost DECIMAL(10, 2)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_method_id INT,
    status VARCHAR(30) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(shipping_method_id)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    subtotal DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INT,
    street_address TEXT,
    city VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE stock (
    product_id INT PRIMARY KEY,
    quantity_in_stock INT DEFAULT 0,
    last_restock_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50),
    salary DECIMAL(10, 2)
);

CREATE TABLE discounts (
    discount_id SERIAL PRIMARY KEY,
    product_id INT,
    discount_percent DECIMAL(5, 2),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE promotions (
    promotion_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    discount_rate DECIMAL(5, 2),
    valid_from DATE,
    valid_to DATE
);

CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE DEFAULT CURRENT_DATE,
    payment_method VARCHAR(50),
    status VARCHAR(30) DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE returns (
    return_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity_returned INT,
    reason TEXT,
    return_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Вставка тестовых данных

-- Клиенты
INSERT INTO customers (first_name, last_name, email, phone_number)
VALUES 
('Alice', 'Johnson', 'alice@example.com', '+111222333'),
('Bob', 'Smith', 'bob@example.com', '+444555666'),
('Charlie', 'Brown', 'charlie@example.com', '+777888999');

-- Категории
INSERT INTO categories (category_name)
VALUES 
('Electronics'), 
('Books'), 
('Clothing'), 
('Home Appliances'), 
('Toys');

-- Поставщики
INSERT INTO suppliers (company_name, contact_person, phone, address)
VALUES 
('TechSupplies Inc', 'John Doe', '+123456789', '123 Tech Street'),
('BookWorld Ltd', 'Jane Smith', '+987654321', '456 Book Avenue'),
('FashionCo', 'Emily Davis', '+555666777', '789 Fashion Blvd');

-- Товары
INSERT INTO products (product_name, category_id, supplier_id, price, description)
VALUES 
('Smartphone X', 1, 1, 699.99, 'Latest model smartphone'),
('Laptop Pro', 1, 1, 1299.99, 'High-end laptop for professionals'),
('The Art of War', 2, 2, 19.99, 'Classic book on strategy'),
('Leather Jacket', 3, 3, 299.99, 'Premium leather jacket'),
('Blender', 4, 1, 149.99, 'Powerful kitchen blender'),
('Toy Car', 5, 2, 29.99, 'Educational toy car for kids');

-- Способы доставки
INSERT INTO shipping_methods (method_name, cost)
VALUES 
('Standard Delivery', 5.00), 
('Express Delivery', 15.00), 
('Same-Day Delivery', 25.00);

-- Заказы
INSERT INTO orders (customer_id, shipping_method_id)
VALUES 
(1, 1), -- Alice's order
(2, 2), -- Bob's order
(3, 3); -- Charlie's order

-- Позиции заказов
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
VALUES 
(1, 1, 2, 699.99, 1399.98),
(1, 3, 1, 19.99, 19.99),
(2, 4, 1, 299.99, 299.99),
(3, 5, 1, 149.99, 149.99);

-- Адреса доставки
INSERT INTO addresses (customer_id, street_address, city, postal_code, country, is_default)
VALUES 
(1, '789 Main St', 'New York', '10001', 'USA', TRUE),
(2, '101 Oak Ave', 'Los Angeles', '90001', 'USA', TRUE),
(3, '555 Elm St', 'Chicago', '60601', 'USA', TRUE);

-- Остатки на складе
INSERT INTO stock (product_id, quantity_in_stock, last_restock_date)
VALUES 
(1, 100, '2024-03-15'),
(2, 50, '2024-03-10'),
(3, 200, '2024-03-05'),
(4, 30, '2024-03-08'),
(5, 40, '2024-03-12'),
(6, 150, '2024-03-14');

-- Сотрудники
INSERT INTO employees (name, role, salary)
VALUES 
('John Manager', 'Manager', 80000),
('Anna Clerk', 'Clerk', 40000),
('Mike Support', 'Support', 35000);

-- Скидки
INSERT INTO discounts (product_id, discount_percent, start_date, end_date)
VALUES 
(1, 10.00, '2024-03-10', '2024-03-31'),
(2, 15.00, '2024-03-15', '2024-04-15');

-- Акции
INSERT INTO promotions (name, discount_rate, valid_from, valid_to)
VALUES 
('Spring Sale', 20.00, '2024-03-01', '2024-03-31'),
('Summer Promo', 25.00, '2024-06-01', '2024-06-30');

-- Отзывы
INSERT INTO reviews (product_id, customer_id, rating, comment)
VALUES 
(1, 1, 5, 'Excellent phone!'),
(3, 2, 4, 'Good read.'),
(4, 3, 5, 'Great quality jacket.');

-- Платежи
INSERT INTO payments (order_id, amount, payment_method, status)
VALUES 
(1, 1419.97, 'Credit Card', 'Completed'),
(2, 299.99, 'PayPal', 'Completed'),
(3, 149.99, 'Cash', 'Pending');

-- Возвраты
INSERT INTO returns (order_id, product_id, quantity_returned, reason)
VALUES 
(1, 1, 1, 'Faulty item');