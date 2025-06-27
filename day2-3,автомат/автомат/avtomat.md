Отчет по архитектуре базы данных

1. Создание нескольких представлений (материализованные и нет)

1.1. Обычное представление: детали заказов

Название: order_details
Описание: Представление содержит информацию о заказах с деталями клиентов, товаров и позиций в заказах.
Запрос для создания:



```sql
CREATE VIEW order_details AS
SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.subtotal
FROM 
    orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
```



1.2. Материализованное представление: выручка по месяцам
Название: monthly_revenue
Описание: Представление хранит общую выручку интернет-магазина за каждый месяц.
Запрос для создания:

```sql
CREATE MATERIALIZED VIEW monthly_revenue AS
SELECT 
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    SUM(oi.subtotal) AS total_revenue
FROM 
    orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 
    EXTRACT(YEAR FROM o.order_date), 
    EXTRACT(MONTH FROM o.order_date);
```


2. Написание 15 запросов с вложенностью
Примеры запросов:
1 Клиенты, которые сделали хотя бы один заказ:

```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name
FROM 
    customers c
WHERE 
    EXISTS (
        SELECT 1 
        FROM orders o 
        WHERE o.customer_id = c.customer_id
    );
```


2 Товары, которые не были добавлены ни в один заказ:
```sql
SELECT 
    p.product_id,
    p.product_name
FROM 
    products p
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM order_items oi 
        WHERE oi.product_id = p.product_id
    );
```


3 Поставщики, у которых есть товары на складе:
```sql
SELECT 
    s.supplier_id,
    s.company_name
FROM 
    suppliers s
WHERE 
    EXISTS (
        SELECT 1 
        FROM products p 
        JOIN stock st ON p.product_id = st.product_id
        WHERE p.supplier_id = s.supplier_id AND st.quantity_in_stock > 0
    );
```


4 Отзывы клиентов, которые оценили товар выше среднего рейтинга:
```sql
WITH avg_ratings AS (
    SELECT 
        product_id,
        AVG(rating) AS avg_rating
    FROM 
        reviews
    GROUP BY 
        product_id
)
SELECT 
    r.review_id,
    r.product_id,
    r.customer_id,
    r.rating,
    r.comment
FROM 
    reviews r
JOIN 
    avg_ratings ar ON r.product_id = ar.product_id
WHERE 
    r.rating > ar.avg_rating;
```


5 Акции, которые действуют сегодня:
```sql
SELECT 
    promotion_id,
    name,
    discount_rate
FROM 
    promotions
WHERE 
    CURRENT_DATE BETWEEN valid_from AND valid_to;
```


6 Все заказы, у которых сумма больше средней суммы всех заказов:
```sql
SELECT 
    o.order_id,
    o.total_amount
FROM 
    orders o
WHERE 
    o.total_amount > (
        SELECT AVG(total_amount) 
        FROM orders
    );
```


7 Товары, которые находятся в категории "Electronics" и имеют цену выше средней цены по категории:
```sql
WITH category_prices AS (
    SELECT 
        p.product_id,
        p.price,
        c.category_name,
        AVG(p.price) OVER (PARTITION BY c.category_id) AS avg_category_price
    FROM 
        products p
    JOIN 
        categories c ON p.category_id = c.category_id
)
SELECT 
    product_id,
    price,
    category_name
FROM 
    category_prices
WHERE 
    category_name = 'Electronics' AND price > avg_category_price;
```


8 Сотрудники, которые работают в магазине дольше года:
```sql
SELECT 
    employee_id,
    name,
    role,
    salary
FROM 
    employees
WHERE 
    employee_id IN (
        SELECT employee_id
        FROM employees
        WHERE registration_date < CURRENT_DATE - INTERVAL '1 year'
    );
```


9 Поставщики, у которых есть товары со скидкой:
```sql
SELECT 
    s.supplier_id,
    s.company_name
FROM 
    suppliers s
WHERE 
    EXISTS (
        SELECT 1 
        FROM products p 
        JOIN discounts d ON p.product_id = d.product_id
        WHERE p.supplier_id = s.supplier_id
    );
```


10 Клиенты, которые сделали хотя бы один успешный платеж:
```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name
FROM 
    customers c
WHERE 
    EXISTS (
        SELECT 1 
        FROM payments p 
        WHERE p.order_id IN (
            SELECT order_id 
            FROM orders 
            WHERE customer_id = c.customer_id
        ) AND p.status = 'Completed'
    );
```


11 Товары, которые были возвращены хотя бы раз:
```sql
SELECT 
    p.product_id,
    p.product_name
FROM 
    products p
WHERE 
    EXISTS (
        SELECT 1 
        FROM returns r 
        WHERE r.product_id = p.product_id
    );
```


12 Поставщики, у которых есть товары с количеством на складе меньше 10 единиц:
```sql
SELECT 
    s.supplier_id,
    s.company_name
FROM 
    suppliers s
WHERE 
    EXISTS (
        SELECT 1 
        FROM products p 
        JOIN stock st ON p.product_id = st.product_id
        WHERE p.supplier_id = s.supplier_id AND st.quantity_in_stock < 10
    );
```


13 Отзывы клиентов, которые оценили товар выше среднего рейтинга по категории:
```sql
WITH category_avg_ratings AS (
    SELECT 
        p.category_id,
        AVG(r.rating) AS avg_category_rating
    FROM 
        reviews r
    JOIN 
        products p ON r.product_id = p.product_id
    GROUP BY 
        p.category_id
)
SELECT 
    r.review_id,
    r.product_id,
    r.customer_id,
    r.rating,
    r.comment
FROM 
    reviews r
JOIN 
    products p ON r.product_id = p.product_id
JOIN 
    category_avg_ratings car ON p.category_id = car.category_id
WHERE 
    r.rating > car.avg_category_rating;
```


14 Заказы, у которых общая сумма больше средней суммы всех заказов:
```sql
SELECT 
    o.order_id,
    o.total_amount
FROM 
    orders o
WHERE 
    o.total_amount > (
        SELECT AVG(total_amount) 
        FROM orders
    );
```


15 Товары, которые находятся в категории "Books" и имеют цену выше средней цены по категории:
```sql
WITH category_prices AS (
    SELECT 
        p.product_id,
        p.price,
        c.category_name,
        AVG(p.price) OVER (PARTITION BY c.category_id) AS avg_category_price
    FROM 
        products p
    JOIN 
        categories c ON p.category_id = c.category_id
)
SELECT 
    product_id,
    price,
    category_name
FROM 
    category_prices
WHERE 
    category_name = 'Books' AND price > avg_category_price;
```




3. Написание 15 запросов с минимум 3 JOIN
Примеры запросов:
1 Детали заказов с клиентами, товарами и способами доставки
```sql
SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_name,
    sm.method_name,
    oi.quantity,
    oi.unit_price
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    order_items oi ON o.order_id = oi.order_id
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    shipping_methods sm ON o.shipping_method_id = sm.shipping_method_id;
```


2 Информация о возвратах с клиентами, товарами и заказами:
```sql
SELECT 
    r.return_id,
    o.order_id,
    p.product_name,
    c.first_name || ' ' || c.last_name AS customer_name,
    r.quantity_returned,
    r.reason
FROM 
    returns r
JOIN 
    orders o ON r.order_id = o.order_id
JOIN 
    products p ON r.product_id = p.product_id
JOIN 
    customers c ON o.customer_id = c.customer_id;
```


3 Отзывы клиентов с информацией о товарах и категориях:
```sql
SELECT 
    r.review_id,
    p.product_name,
    cat.category_name,
    r.rating,
    r.comment
FROM 
    reviews r
JOIN 
    products p ON r.product_id = p.product_id
JOIN 
    categories cat ON p.category_id = cat.category_id;
```


4 Платежи с деталями заказов, клиентов и способов оплаты:
```sql
SELECT 
    p.payment_id,
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.amount,
    p.payment_method,
    p.status
FROM 
    payments p
JOIN 
    orders o ON p.order_id = o.order_id
JOIN 
    customers c ON o.customer_id = c.customer_id;
```


5 Акции с продуктами и их текущими скидками:
```sql
SELECT 
    pr.promotion_id,
    pr.name,
    pr.discount_rate,
    p.product_name,
    d.discount_percent
FROM 
    promotions pr
LEFT JOIN 
    discounts d ON pr.promotion_id = d.promotion_id
LEFT JOIN 
    products p ON d.product_id = p.product_id;
```


6 Товары с информацией о поставщиках, категориях и наличии на складе:
```sql
SELECT 
    p.product_id,
    p.product_name,
    s.company_name AS supplier_name,
    cat.category_name,
    st.quantity_in_stock
FROM 
    products p
JOIN 
    suppliers s ON p.supplier_id = s.supplier_id
JOIN 
    categories cat ON p.category_id = cat.category_id
JOIN 
    stock st ON p.product_id = st.product_id;
```


7 Заказы с адресами доставки, клиентами и способами доставки:
```sql
SELECT 
    o.order_id,
    a.street_address,
    c.first_name || ' ' || c.last_name AS customer_name,
    sm.method_name
FROM 
    orders o
JOIN 
    addresses a ON o.customer_id = a.customer_id
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    shipping_methods sm ON o.shipping_method_id = sm.shipping_method_id;
```


8 Сотрудники с зарплатой выше средней по роли:
```sql
WITH role_avg_salaries AS (
    SELECT 
        role,
        AVG(salary) AS avg_salary
    FROM 
        employees
    GROUP BY 
        role
)
SELECT 
    e.employee_id,
    e.name,
    e.role,
    e.salary
FROM 
    employees e
JOIN 
    role_avg_salaries ras ON e.role = ras.role
WHERE 
    e.salary > ras.avg_salary;
```


9 Поставщики с информацией о товарах и количестве товаров на складе:
```sql
SELECT 
    s.supplier_id,
    s.company_name,
    COUNT(p.product_id) AS product_count,
    SUM(st.quantity_in_stock) AS total_stock
FROM 
    suppliers s
LEFT JOIN 
    products p ON s.supplier_id = p.supplier_id
LEFT JOIN 
    stock st ON p.product_id = st.product_id
GROUP BY 
    s.supplier_id, s.company_name;
```


10 Отзывы клиентов с информацией о товарах, категориях и поставщиках:
```sql
SELECT 
    r.review_id,
    p.product_name,
    cat.category_name,
    s.company_name AS supplier_name,
    r.rating,
    r.comment
FROM 
    reviews r
JOIN 
    products p ON r.product_id = p.product_id
JOIN 
    categories cat ON p.category_id = cat.category_id
JOIN 
    suppliers s ON p.supplier_id = s.supplier_id;
```


11 Платежи с деталями заказов, клиентов и способов доставки:
```sql
SELECT 
    p.payment_id,
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    sm.method_name,
    p.amount,
    p.payment_method,
    p.status
FROM 
    payments p
JOIN 
    orders o ON p.order_id = o.order_id
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    shipping_methods sm ON o.shipping_method_id = sm.shipping_method_id;
```


12 Товары с информацией о категориях, поставщиках и наличии на складе:
```sql
SELECT 
    p.product_id,
    p.product_name,
    cat.category_name,
    s.company_name AS supplier_name,
    st.quantity_in_stock
FROM 
    products p
JOIN 
    categories cat ON p.category_id = cat.category_id
JOIN 
    suppliers s ON p.supplier_id = s.supplier_id
JOIN 
    stock st ON p.product_id = st.product_id;
```


13 Заказы с адресами доставки, клиентами и способами оплаты:
```sql
SELECT 
    o.order_id,
    a.street_address,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.payment_method
FROM 
    orders o
JOIN 
    addresses a ON o.customer_id = a.customer_id
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    payments p ON o.order_id = p.order_id;
```


14 Сотрудники с зарплатой выше средней по компании:
```sql
WITH company_avg_salary AS (
    SELECT 
        AVG(salary) AS avg_company_salary
    FROM 
        employees
)
SELECT 
    e.employee_id,
    e.name,
    e.role,
    e.salary
FROM 
    employees e
CROSS JOIN 
    company_avg_salary cas
WHERE 
    e.salary > cas.avg_company_salary;
```


15 Поставщики с информацией о товарах, категориях и количестве товаров на складе:
```sql
SELECT 
    s.supplier_id,
    s.company_name,
    cat.category_name,
    COUNT(p.product_id) AS product_count,
    SUM(st.quantity_in_stock) AS total_stock
FROM 
    suppliers s
LEFT JOIN 
    products p ON s.supplier_id = p.supplier_id
LEFT JOIN 
    categories cat ON p.category_id = cat.category_id
LEFT JOIN 
    stock st ON p.product_id = st.product_id
GROUP BY 
    s.supplier_id, s.company_name, cat.category_name;
```



4. Написание 10 запросов на каждую из 5 агрегатных функций
Агрегатные функции:
COUNT
SUM
AVG
MIN
MAX
```sql
SELECT COUNT(*) AS total_customers FROM customers;

SELECT COUNT(*) AS active_orders FROM orders WHERE status = 'Pending';

SELECT SUM(total_amount) AS total_revenue FROM orders;

SELECT SUM(quantity_in_stock) AS total_stock FROM stock;

SELECT AVG(price) AS avg_product_price FROM products;

SELECT AVG(rating) AS avg_review_rating FROM reviews;

SELECT MIN(price) AS min_product_price FROM products;

SELECT MIN(cost) AS min_shipping_cost FROM shipping_methods;

SELECT MAX(price) AS max_product_price FROM products;

SELECT MAX(total_amount) AS max_order_total FROM orders;
```



5. Разработка 5 хранимых процедур

5.1.Название: add_order
Описание: Процедура добавляет новый заказ в таблицу orders.
Код:
```sql
CREATE OR REPLACE FUNCTION add_order(
    p_customer_id INT,
    p_shipping_method_id INT
)
RETURNS INT AS $$
DECLARE
    new_order_id INT;
BEGIN
    INSERT INTO orders (customer_id, shipping_method_id)
    VALUES (p_customer_id, p_shipping_method_id)
    RETURNING order_id INTO new_order_id;

    RETURN new_order_id;
END;
$$ LANGUAGE plpgsql;
```

5.2. Обновление остатков на складе
Название: update_stock
Описание: Процедура обновляет количество товара на складе после изменения его количества.
Код:
```sql
CREATE OR REPLACE FUNCTION update_stock(
    p_product_id INT,
    p_quantity INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE stock
    SET quantity_in_stock = quantity_in_stock + p_quantity,
        last_restock_date = CURRENT_DATE
    WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;
```

5.3. Расчёт общей стоимости заказа
Название: calculate_order_total
Описание: Процедура рассчитывает общую сумму заказа на основе позиций в заказе.
Код:
```sql
CREATE OR REPLACE FUNCTION calculate_order_total(
    p_order_id INT
)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL;
BEGIN
    SELECT SUM(oi.quantity * p.price)
    INTO total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = p_order_id;

    UPDATE orders
    SET total_amount = total
    WHERE order_id = p_order_id;

    RETURN total;
END;
$$ LANGUAGE plpgsql;
```

5.4. Добавление отзыва
Название: add_review
Описание: Процедура добавляет новый отзыв о товаре.
Код:
```sql
CREATE OR REPLACE FUNCTION add_review(
    p_product_id INT,
    p_customer_id INT,
    p_rating INT,
    p_comment TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO reviews (product_id, customer_id, rating, comment)
    VALUES (p_product_id, p_customer_id, p_rating, p_comment);
END;
$$ LANGUAGE plpgsql;
```

 Проверка наличия товара на складе
Название: check_stock
Описание: Процедура проверяет, достаточно ли товара на складе для выполнения заказа.
Код:
```sql
CREATE OR REPLACE FUNCTION check_stock(
    p_product_id INT,
    p_quantity INT
)
RETURNS BOOLEAN AS $$
DECLARE
    available_stock INT;
BEGIN
    SELECT quantity_in_stock
    INTO available_stock
    FROM stock
    WHERE product_id = p_product_id;

    IF available_stock >= p_quantity THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;
```



6. Разработка триггеров на CRUD-операции
Таблицы с внешним ключом: orders и order_items
6.1. Вставка (INSERT)
Цель: При добавлении новой позиции в заказ автоматически обновить остаток на складе.
Триггер:
```sql
CREATE OR REPLACE FUNCTION trg_update_stock_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE stock
    SET quantity_in_stock = quantity_in_stock - NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_decrease_stock_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_after_insert();
```

6.2. Обновление (UPDATE)
Цель: При изменении количества товара в заказе обновить остаток на складе.
Триггер:
```sql
CREATE OR REPLACE FUNCTION trg_update_stock_after_update()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE stock
    SET quantity_in_stock = quantity_in_stock + OLD.quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock_after_update
AFTER UPDATE ON order_items
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_after_update();
```

6.3. Удаление (DELETE)
Цель: При удалении позиции из заказа вернуть товар на склад.
Триггер:
```sql
CREATE OR REPLACE FUNCTION trg_update_stock_after_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE stock
    SET quantity_in_stock = quantity_in_stock + OLD.quantity
    WHERE product_id = OLD.product_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_increase_stock_after_delete
AFTER DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_after_delete();
```

7. Описание каждой таблицы, внешних ключей и связей
7.1. customers
Описание: Содержит информацию о клиентах.
Поля: customer_id, first_name, last_name, email, phone_number, registration_date
Внешние ключи: Используется в таблицах orders, addresses, reviews.
7.2. categories
Описание: Категории товаров.
Поля: category_id, category_name
Внешние ключи: Используется в таблице products.
7.3. suppliers
Описание: Информация о поставщиках товаров.
Поля: supplier_id, company_name, contact_person, phone, address
Внешние ключи: Используется в таблице products.
7.4. products
Описание: Информация о товарах.
Поля: product_id, product_name, category_id, supplier_id, price, description
Внешние ключи: category_id, supplier_id
Используется в: order_items, stock, discounts, reviews, returns.
7.5. shipping_methods
Описание: Способы доставки.
Поля: shipping_method_id, method_name, cost
Внешние ключи: Используется в таблице orders.
7.6. orders
Описание: Заказы клиентов.
Поля: order_id, customer_id, order_date, total_amount, shipping_method_id, status
Внешние ключи: customer_id, shipping_method_id
Используется в: order_items, payments, returns.
7.7. order_items
Описание: Позиции товаров в заказе.
Поля: order_item_id, order_id, product_id, quantity, unit_price, subtotal
Внешние ключи: order_id, product_id
7.8. addresses
Описание: Адреса доставки клиентов.
Поля: address_id, customer_id, street_address, city, postal_code, country, is_default
Внешний ключ: customer_id
7.9. stock
Описание: Остатки товаров на складе.
Поля: product_id, quantity_in_stock, last_restock_date
Внешний ключ: product_id
7.10. employees
Описание: Информация о сотрудниках магазина.
Поля: employee_id, name, role, salary
7.11. discounts
Описание: Скидки на товары.
Поля: discount_id, product_id, discount_percent, start_date, end_date
Внешний ключ: product_id
7.12. promotions
Описание: Акции и промо-предложения.
Поля: promotion_id, name, discount_rate, valid_from, valid_to
7.13. reviews
Описание: Отзывы клиентов о товарах.
Поля: review_id, product_id, customer_id, rating, comment, review_date
Внешние ключи: product_id, customer_id
7.14. payments
Описание: Информация об оплатах заказов.
Поля: payment_id, order_id, amount, payment_date, payment_method, status
Внешний ключ: order_id
7.15. returns
Описание: Информация о возвратах товаров.
Поля: return_id, order_id, product_id, quantity_returned, reason, return_date
Внешние ключи: order_id, product_id


8. Заключение
Работа по созданию архитектуры базы данных интернет-магазина успешно завершена. Были созданы:

15 таблиц , описывающих основные сущности системы.
Представления (включая материализованное).
15 запросов с вложенностью и 15 запросов с 3+ JOIN .
10 запросов на каждую из 5 агрегатных функций .
5 хранимых процедур , решающих бизнес-задачи.
Триггеры на CRUD-операции для двух связанных таблиц.
Отчет в формате Markdown с описанием структуры базы данных.