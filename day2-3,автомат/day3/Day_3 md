Exercise 00

```sql
SELECT 
    m.pizza_name,
    m.price,
    p.name AS pizzeria_name,
    po.order_date AS visit_date
FROM 
    person per
JOIN 
    person_order po ON per.id = po.person_id
JOIN 
    menu m ON po.menu_id = m.id
JOIN 
    pizzeria p ON m.pizzeria_id = p.id
WHERE 
    per.name = 'Kate'
    AND m.price BETWEEN 800 AND 1000
ORDER BY 
    m.pizza_name, 
    m.price, 
    p.name;
```
![alt text](image.png)



Exercise 01

```sql
SELECT 
    m.id AS menu_id
FROM 
    menu m
WHERE 
    m.id NOT IN (
        SELECT 
            po.menu_id
        FROM 
            person_order po
    )
ORDER BY 
    m.id;
```
![alt text](image-1.png)



Exercise 02

```sql
SELECT 
    m.pizza_name,
    m.price,
    p.name AS pizzeria_name
FROM 
    menu m
JOIN 
    pizzeria p ON m.pizzeria_id = p.id
WHERE 
    m.id NOT IN (
        SELECT 
            po.menu_id
        FROM 
            person_order po
    )
ORDER BY 
    m.pizza_name, 
    m.price;
```
![alt text](image-2.png)



Exercise 03

```sql
WITH female_visits AS (
    SELECT 
        pv.pizzeria_id,
        COUNT(*) AS visit_count
    FROM 
        person_visits pv
    JOIN 
        person p ON pv.person_id = p.id
    WHERE 
        p.gender = 'female'
    GROUP BY 
        pv.pizzeria_id
),

male_visits AS (
    SELECT 
        pv.pizzeria_id,
        COUNT(*) AS visit_count
    FROM 
        person_visits pv
    JOIN 
        person p ON pv.person_id = p.id
    WHERE 
        p.gender = 'male'
    GROUP BY 
        pv.pizzeria_id
)

SELECT 
    p.name AS pizzeria_name
FROM 
    pizzeria p
WHERE 
    p.id IN (
        SELECT 
            fv.pizzeria_id
        FROM 
            female_visits fv
        LEFT JOIN 
            male_visits mv ON fv.pizzeria_id = mv.pizzeria_id
        WHERE 
            mv.visit_count IS NULL OR fv.visit_count > mv.visit_count

        UNION ALL

        SELECT 
            mv.pizzeria_id
        FROM 
            male_visits mv
        LEFT JOIN 
            female_visits fv ON mv.pizzeria_id = fv.pizzeria_id
        WHERE 
            fv.visit_count IS NULL OR mv.visit_count > fv.visit_count
    )
ORDER BY 
    pizzeria_name;
```
![alt text](image-4.png)



Exercise 04

```sql
-- Пиццерии, которые получили заказы только от женщин
WITH female_only_pizzerias AS (
    SELECT DISTINCT m.pizzeria_id
    FROM person_order po
    JOIN menu m ON po.menu_id = m.id
    JOIN person p ON po.person_id = p.id
    WHERE p.gender = 'female'
    AND NOT EXISTS (
        SELECT 1
        FROM person_order po2
        JOIN menu m2 ON po2.menu_id = m2.id
        JOIN person p2 ON po2.person_id = p2.id
        WHERE m2.pizzeria_id = m.pizzeria_id
        AND p2.gender = 'male'
    )
),
male_only_pizzerias AS (
    SELECT DISTINCT m.pizzeria_id
    FROM person_order po
    JOIN menu m ON po.menu_id = m.id
    JOIN person p ON po.person_id = p.id
    WHERE p.gender = 'male'
    AND NOT EXISTS (
        SELECT 1
        FROM person_order po2
        JOIN menu m2 ON po2.menu_id = m2.id
        JOIN person p2 ON po2.person_id = p2.id
        WHERE m2.pizzeria_id = m.pizzeria_id
        AND p2.gender = 'female'
    )
)

SELECT p.name AS pizzeria_name
FROM pizzeria p
WHERE p.id IN (
    SELECT pizzeria_id FROM female_only_pizzerias
    UNION
    SELECT pizzeria_id FROM male_only_pizzerias
)
ORDER BY pizzeria_name;
```
![alt text](image-5.png)



Exercise 05

```sql
-- Пиццерии, которые посетил Андрей
WITH andrey_visits AS (
    SELECT pv.pizzeria_id
    FROM person_visits pv
    JOIN person p ON pv.person_id = p.id
    WHERE p.name = 'Andrey'
),

-- Пиццерии, в которых Андрей сделал заказы
andrey_orders AS (
    SELECT po.menu_id, m.pizzeria_id
    FROM person_order po
    JOIN menu m ON po.menu_id = m.id
    JOIN person p ON po.person_id = p.id
    WHERE p.name = 'Andrey'
)

-- Пиццерии, которые посетил Андрей, но не сделал заказов
SELECT p.name AS pizzeria_name
FROM pizzeria p
WHERE p.id IN (
    SELECT pizzeria_id FROM andrey_visits
    EXCEPT
    SELECT DISTINCT pizzeria_id FROM andrey_orders
)
ORDER BY pizzeria_name;
```
![alt text](image-6.png)



Exercise 06

```sql
SELECT 
    m1.pizza_name,
    p1.name AS pizzeria_name_1,
    p2.name AS pizzeria_name_2,
    m1.price
FROM 
    menu m1
JOIN 
    menu m2 ON m1.pizza_name = m2.pizza_name AND m1.price = m2.price AND m1.pizzeria_id < m2.pizzeria_id
JOIN 
    pizzeria p1 ON m1.pizzeria_id = p1.id
JOIN 
    pizzeria p2 ON m2.pizzeria_id = p2.id
ORDER BY 
    m1.pizza_name;
```
![alt text](image-8.png)



Exercise 07

```sql
INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES (19, 2, 'greek pizza', 800);
```
![alt text](image-7.png)



Exercise 08

```sql
INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES (
    (SELECT MAX(id) + 1 FROM menu),
    (SELECT id FROM pizzeria WHERE name = 'Dominos'),
    'sicilian pizza',
    900
);
```
![alt text](image-9.png)



Exercise 09

```sql
-- 1. Если таблица person_visits уже существует, можно пересоздать её с SERIAL
DROP TABLE IF EXISTS person_visits;

CREATE TABLE person_visits (
    id serial PRIMARY KEY,
    person_id bigint NOT NULL,
    pizzeria_id bigint NOT NULL,
    visit_date date NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT uk_person_visits UNIQUE (person_id, pizzeria_id, visit_date),
    CONSTRAINT fk_person_visits_person_id FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_visits_pizzeria_id FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

-- 2. Вставка новых записей без указания id
INSERT INTO person_visits (person_id, pizzeria_id, visit_date)
VALUES
    -- Посещение от Denis
    (
        (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24'
    ),
    -- Посещение от Irina
    (
        (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24'
    );

-- 3. Проверка: выводим все посещения от 2022-02-24
SELECT pv.id, p.name AS visitor, pz.name AS pizzeria, pv.visit_date
FROM person_visits pv
JOIN person p ON pv.person_id = p.id
JOIN pizzeria pz ON pv.pizzeria_id = pz.id
WHERE pv.visit_date = '2022-02-24';
```
![alt text](image-10.png)



Exercise 10

```sql
-- 1. Добавляем новую пиццу 'sicilian pizza' в меню Dominos, если её ещё нет
INSERT INTO menu (pizzeria_id, pizza_name, price)
SELECT 
    (SELECT id FROM pizzeria WHERE name = 'Dominos'),
    'sicilian pizza',
    950
WHERE NOT EXISTS (
    SELECT 1
    FROM menu
    WHERE pizza_name = 'sicilian pizza'
      AND pizzeria_id = (SELECT id FROM pizzeria WHERE name = 'Dominos')
);

-- 2. Регистрируем заказы для Denis и Irina
-- Не указываем id — он генерируется автоматически
INSERT INTO person_order (person_id, menu_id, order_date)
VALUES
    -- Заказ от Denis
    (
        (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza' AND pizzeria_id = (SELECT id FROM pizzeria WHERE name = 'Dominos')),
        '2022-02-24'
    ),
    -- Заказ от Irina
    (
        (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza' AND pizzeria_id = (SELECT id FROM pizzeria WHERE name = 'Dominos')),
        '2022-02-24'
    );
```
![alt text](image-11.png)


Exercise 11

```sql
UPDATE menu
SET price = price * 0.90
WHERE pizza_name = 'greek pizza';
```
![alt text](image-12.png)



Exercise 12

```sql
INSERT INTO person_order (person_id, menu_id, order_date)
SELECT 
    p.id AS person_id,
    m.id AS menu_id,
    '2022-02-25' AS order_date
FROM person p
CROSS JOIN (
    SELECT id FROM menu WHERE pizza_name = 'greek pizza'
) m;
```
![alt text](image-13.png)



Exercise 13

```sql
-- 1. Удаление новых заказов, созданных на 2022-02-25
DELETE FROM person_order
WHERE order_date = '2022-02-25';

-- 2. Удаление пиццы "greek pizza" из меню
DELETE FROM menu
WHERE pizza_name = 'greek pizza';
```
![alt text](image-14.png)