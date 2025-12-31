
-- EUNOIA DATABASE

CREATE TABLE categories (
  category_id SERIAL PRIMARY KEY,
  category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE brands (
  brand_id SERIAL PRIMARY KEY,
  brand_name VARCHAR(100) UNIQUE NOT NULL,
  brand_position VARCHAR(50),      -- premium / mainstream / budget / vegan
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stores (
  store_id SERIAL PRIMARY KEY,
  store_name VARCHAR(100) NOT NULL,
  store_type VARCHAR(20) NOT NULL,   -- physical / online
  city VARCHAR(50),
  country VARCHAR(50),
  opened_at DATE
);

CREATE TABLE stores (
  store_id SERIAL PRIMARY KEY,
  store_name VARCHAR(100) NOT NULL,
  store_type VARCHAR(20) NOT NULL,   
  store_channel VARCHAR(20) NOT NULL, 
  store_market VARCHAR(20) NOT NULL,  
  city VARCHAR(50),
  country VARCHAR(50),
  opened_at DATE
);


CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  gender VARCHAR(20),
  birth_date DATE,
  email VARCHAR(100) UNIQUE,
  city VARCHAR(50),
  country VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
  product_id SERIAL PRIMARY KEY,
  product_name VARCHAR(150) NOT NULL,
  brand_id INT NOT NULL,
  category_id INT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  is_vegan BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_brand
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
  CONSTRAINT fk_product_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL,
  store_id INT NOT NULL,
  order_date TIMESTAMP NOT NULL,
  order_status VARCHAR(30) DEFAULT 'completed',
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_orders_store
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE order_items (
  order_item_id SERIAL PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL,
  CONSTRAINT fk_items_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


INSERT INTO categories (category_name) VALUES
('Face Cleanser'),
('Moisturizer'),
('Serum'),
('Anti-Aging Care'),
('Body Lotion'),
('Hand Cream'),
('Shampoo & Conditioner'),
('Hair Mask'),
('Hair Tonic'),
('Foundation'),
('Lipstick'),
('Mascara'),
('Blush'),
('Eyeliner'),
('Powder'),
('Nail Polish'),
('Perfume'),
('Body Care'),
('Beauty Tools'),
('Sun Care');

SELECT * FROM categories ORDER BY category_id;

INSERT INTO brands (brand_name, brand_position) VALUES
('Lumera',  'premium'),
('Velisse', 'mainstream'),
('Purevia', 'vegan'),
('Nerixa',  'budget'),
('Aurelle', 'premium');

INSERT INTO stores (store_name, store_type, city, country, opened_at) VALUES
-- Turkey - Physical Stores
('Eunoia Istanbul Nisantasi', 'physical', 'Istanbul', 'Turkey', '2023-03-15'),
('Eunoia Ankara Cankaya',     'physical', 'Ankara',   'Turkey', '2023-06-10'),
('Eunoia Izmir Alsancak',     'physical', 'Izmir',    'Turkey', '2023-09-05'),
('Eunoia Antalya Lara',      'physical', 'Antalya',  'Turkey', '2024-04-12'),
('Eunoia Balikesir Merkez',  'physical', 'Balikesir','Turkey', '2024-05-08'),
('Eunoia Amasya Merkez',     'physical', 'Amasya',   'Turkey', '2024-06-18'),
('Eunoia Malatya Merkez',    'physical', 'Malatya',  'Turkey', '2024-07-02'),
('Eunoia Eskisehir Odunpazari','physical','Eskisehir','Turkey','2024-08-10'),
('Eunoia Kayseri Talas',     'physical', 'Kayseri',  'Turkey', '2024-09-01'),

-- Europe - Physical Stores
('Eunoia Paris Le Marais',   'physical', 'Paris',    'France', '2024-02-14'),
('Eunoia Milan Brera',       'physical', 'Milan',    'Italy',  '2024-03-20'),
('Eunoia Stockholm Norrmalm','physical', 'Stockholm','Sweden', '2024-05-30'),

-- Online Channels
('Eunoia Online TR',         'online_tr',     NULL, 'Turkey', '2023-02-01'),
('Eunoia Online Global',     'online_global', NULL, 'Global', '2023-03-01');


-- 500 customers generator for EUNOIA (balanced distribution + newer created_at for abroad)
-- Country totals: Turkey 320, France 70, Italy 65, Sweden 45

INSERT INTO customers
(first_name, last_name, gender, birth_date, email, city, country, created_at)
SELECT
  -- first_name (rotating pool)
  (ARRAY[
    'Aylin','Elif','Zeynep','Ece','Selin','Melis','Derya','Ceren','Deniz','Asli',
    'Mert','Emre','Kerem','Can','Berk','Ozan','Umut','Arda','Kaan','Tolga',
    'Sofia','Emma','Lina','Mia','Chloe','Giulia','Francesca','Elena','Alessia','Martina',
    'Olivia','Alice','Julia','Noah','Liam','Lucas','Leo','Ethan','Milan','Hugo'
  ])[1 + (g.i % 40)] AS first_name,

  -- last_name (rotating pool)
  (ARRAY[
    'Yilmaz','Kaya','Demir','Sahin','Yildiz','Celik','Aydin','Arslan','Kilic','Aslan',
    'Rossi','Bianchi','Romano','Gallo','Costa','Fontana','Moretti','Greco','Conti','Esposito',
    'Dubois','Martin','Bernard','Thomas','Petit','Robert','Richard','Durand','Leroy','Moreau',
    'Johansson','Andersson','Karlsson','Nilsson','Eriksson','Larsson','Olsson','Persson','Svensson','Gustafsson'
  ])[1 + (g.i % 40)] AS last_name,

  -- gender (70% Female, 25% Male, 5% Unknown)
  CASE
    WHEN (g.i % 20) < 14 THEN 'Female'
    WHEN (g.i % 20) < 19 THEN 'Male'
    ELSE 'Unknown'
  END AS gender,

  -- birth_date (age buckets: 18-24:28%, 25-34:34%, 35-44:20%, 45+:18%)
  CASE
    WHEN g.i <= 140 THEN (DATE '2003-01-01' + ((g.i * 37) % 2550))          -- ~18-24
    WHEN g.i <= 310 THEN (DATE '1991-01-01' + ((g.i * 41) % 3650))          -- ~25-34
    WHEN g.i <= 410 THEN (DATE '1981-01-01' + ((g.i * 43) % 3650))          -- ~35-44
    ELSE               (DATE '1965-01-01' + ((g.i * 47) % 5840))            -- ~45+
  END AS birth_date,

  -- unique email
  LOWER(
    CASE
      WHEN g.i <= 320 THEN 'tr'
      WHEN g.i <= 390 THEN 'fr'
      WHEN g.i <= 455 THEN 'it'
      ELSE                'se'
    END
    || '_customer_' || LPAD(g.i::text, 4, '0') || '@eunoia.com'
  ) AS email,

  -- city
  CASE
    -- TURKEY (1..320)
    WHEN g.i BETWEEN 1 AND 85   THEN 'Istanbul'
    WHEN g.i BETWEEN 86 AND 135 THEN 'Ankara'
    WHEN g.i BETWEEN 136 AND 180 THEN 'Izmir'
    WHEN g.i BETWEEN 181 AND 220 THEN 'Antalya'
    WHEN g.i BETWEEN 221 AND 250 THEN 'Balikesir'
    WHEN g.i BETWEEN 251 AND 275 THEN 'Eskisehir'
    WHEN g.i BETWEEN 276 AND 295 THEN 'Kayseri'
    WHEN g.i BETWEEN 296 AND 310 THEN 'Amasya'
    WHEN g.i BETWEEN 311 AND 320 THEN 'Malatya'

    -- FRANCE (321..390)
    WHEN g.i BETWEEN 321 AND 360 THEN 'Paris'
    WHEN g.i BETWEEN 361 AND 380 THEN 'Lyon'
    WHEN g.i BETWEEN 381 AND 390 THEN 'Marseille'

    -- ITALY (391..455)
    WHEN g.i BETWEEN 391 AND 425 THEN 'Milan'
    WHEN g.i BETWEEN 426 AND 445 THEN 'Rome'
    WHEN g.i BETWEEN 446 AND 455 THEN 'Naples'

    -- SWEDEN (456..500)
    WHEN g.i BETWEEN 456 AND 480 THEN 'Stockholm'
    WHEN g.i BETWEEN 481 AND 490 THEN 'Gothenburg'
    ELSE                              'Malmo'
  END AS city,

  -- country
  CASE
    WHEN g.i <= 320 THEN 'Turkey'
    WHEN g.i <= 390 THEN 'France'
    WHEN g.i <= 455 THEN 'Italy'
    ELSE                'Sweden'
  END AS country,

  -- created_at: Turkey older spread, Abroad newer spread (new market)
  CASE
    WHEN g.i <= 320 THEN (NOW() - (INTERVAL '1 day' * (30 + ((g.i * 3) % 330))))  -- ~1-12 months ago
    ELSE               (NOW() - (INTERVAL '1 day' * (  2 + ((g.i * 5) % 120))))  -- ~few days to ~4 months ago
  END AS created_at

FROM generate_series(1, 500) AS g(i);


-- PRODUCTS SEED (EUNOIA) - multi-brand, overlapping categories, price tiers + vegan flags
-- Uses brand_name + category_name mapping (no hardcoded IDs)

WITH product_seed (product_name, brand_name, category_name, price, is_vegan) AS (
  VALUES
  -- ========== SUN CARE (competition + vegan) ==========
  ('Lumera SPF 50+ Face Sunscreen',        'Lumera',  'Sun Care', 899.90, FALSE),
  ('Purevia Mineral Sun Cream SPF 30',     'Purevia', 'Sun Care', 649.90, TRUE),
  ('Aurelle Sun Protect Body Lotion SPF 30','Aurelle','Sun Care', 499.90, FALSE),
  ('Nerixa Daily Sun Stick SPF 50',        'Nerixa',  'Sun Care', 249.90, FALSE),
  ('Velisse Tinted Sunscreen SPF 40',      'Velisse', 'Sun Care', 399.90, FALSE),

  -- ========== FACE CLEANSER (all brands overlap) ==========
  ('Lumera Radiance Face Cleanser',        'Lumera',  'Face Cleanser', 449.90, FALSE),
  ('Velisse Gentle Face Cleanser',         'Velisse', 'Face Cleanser', 219.90, FALSE),
  ('Purevia Sensitive Face Cleanser',      'Purevia', 'Face Cleanser', 289.90, TRUE),
  ('Nerixa Fresh Foam Cleanser',           'Nerixa',  'Face Cleanser', 129.90, FALSE),
  ('Aurelle Daily Purifying Cleanser',     'Aurelle', 'Face Cleanser', 259.90, FALSE),

  -- ========== MOISTURIZER (all brands overlap) ==========
  ('Lumera Hydra-Glow Moisturizer',        'Lumera',  'Moisturizer', 599.90, FALSE),
  ('Velisse Daily Moisturizer',            'Velisse', 'Moisturizer', 249.90, FALSE),
  ('Purevia Vegan Moisturizer',            'Purevia', 'Moisturizer', 329.90, TRUE),
  ('Nerixa Light Gel Moisturizer',         'Nerixa',  'Moisturizer', 149.90, FALSE),
  ('Aurelle Comfort Moisturizer',          'Aurelle', 'Moisturizer', 349.90, FALSE),

  -- ========== SERUM (premium + vegan option) ==========
  ('Lumera Vitamin C Serum',               'Lumera',  'Serum', 799.90, FALSE),
  ('Lumera Hyaluronic Serum',              'Lumera',  'Serum', 749.90, FALSE),
  ('Purevia Barrier Repair Serum',         'Purevia', 'Serum', 539.90, TRUE),
  ('Velisse Glow Booster Serum',           'Velisse', 'Serum', 399.90, FALSE),
  ('Nerixa Mini Glow Serum',               'Nerixa',  'Serum', 199.90, FALSE),

  -- ========== ANTI-AGING CARE (premium-heavy + vegan) ==========
  ('Lumera Retinol Night Cream',           'Lumera',  'Anti-Aging Care', 999.90, FALSE),
  ('Aurelle Firming Night Cream',          'Aurelle', 'Anti-Aging Care', 649.90, FALSE),
  ('Purevia Vegan Peptide Cream',          'Purevia', 'Anti-Aging Care', 729.90, TRUE),
  ('Velisse Anti-Aging Day Cream',         'Velisse', 'Anti-Aging Care', 479.90, FALSE),

  -- ========== BODY LOTION (personal care + vegan strong) ==========
  ('Aurelle Silky Body Lotion',            'Aurelle', 'Body Lotion', 299.90, FALSE),
  ('Purevia Vegan Body Lotion',            'Purevia', 'Body Lotion', 329.90, TRUE),
  ('Nerixa Coconut Body Lotion',           'Nerixa',  'Body Lotion', 159.90, FALSE),
  ('Velisse Soft Body Lotion',             'Velisse', 'Body Lotion', 199.90, FALSE),

  -- ========== HAND CREAM ==========
  ('Purevia Vegan Hand Cream',             'Purevia', 'Hand Cream', 179.90, TRUE),
  ('Aurelle Repair Hand Cream',            'Aurelle', 'Hand Cream', 169.90, FALSE),
  ('Nerixa Mini Hand Cream',               'Nerixa',  'Hand Cream',  89.90, FALSE),
  ('Velisse Daily Hand Cream',             'Velisse', 'Hand Cream', 129.90, FALSE),

  -- ========== SHAMPOO & CONDITIONER (overlap) ==========
  ('Lumera Repair Shampoo & Conditioner',  'Lumera',  'Shampoo & Conditioner', 449.90, FALSE),
  ('Velisse Volume Shampoo & Conditioner', 'Velisse', 'Shampoo & Conditioner', 249.90, FALSE),
  ('Purevia Vegan Shampoo & Conditioner',  'Purevia', 'Shampoo & Conditioner', 329.90, TRUE),
  ('Nerixa Fresh Shampoo & Conditioner',   'Nerixa',  'Shampoo & Conditioner', 159.90, FALSE),
  ('Aurelle Smooth Shampoo & Conditioner', 'Aurelle', 'Shampoo & Conditioner', 279.90, FALSE),

  -- ========== HAIR MASK (overlap) ==========
  ('Lumera Keratin Hair Mask',             'Lumera',  'Hair Mask', 399.90, FALSE),
  ('Purevia Vegan Hair Mask',              'Purevia', 'Hair Mask', 359.90, TRUE),
  ('Nerixa Quick Repair Hair Mask',        'Nerixa',  'Hair Mask', 179.90, FALSE),
  ('Velisse Daily Hair Mask',              'Velisse', 'Hair Mask', 219.90, FALSE),
  ('Aurelle Shine Hair Mask',              'Aurelle', 'Hair Mask', 249.90, FALSE),

  -- ========== HAIR TONIC (focused) ==========
  ('Purevia Scalp Hair Tonic',             'Purevia', 'Hair Tonic', 279.90, TRUE),
  ('Lumera Scalp Renewal Tonic',           'Lumera',  'Hair Tonic', 499.90, FALSE),

  -- ========== MAKEUP (Velisse + Nerixa lead; some premium) ==========
  ('Velisse Everyday Foundation',          'Velisse', 'Foundation', 399.90, FALSE),
  ('Nerixa Matte Foundation',              'Nerixa',  'Foundation', 199.90, FALSE),
  ('Lumera Radiant Foundation',            'Lumera',  'Foundation', 699.90, FALSE),

  ('Velisse Classic Lipstick',             'Velisse', 'Lipstick', 249.90, FALSE),
  ('Nerixa Trend Lipstick',                'Nerixa',  'Lipstick', 139.90, FALSE),
  ('Purevia Vegan Lip Balm',               'Purevia', 'Lipstick', 159.90, TRUE),

  ('Velisse Volume Mascara',               'Velisse', 'Mascara', 219.90, FALSE),
  ('Nerixa Bold Mascara',                  'Nerixa',  'Mascara', 129.90, FALSE),

  ('Velisse Peach Blush',                  'Velisse', 'Blush', 179.90, FALSE),
  ('Nerixa Pink Blush',                    'Nerixa',  'Blush', 109.90, FALSE),

  ('Velisse Precision Eyeliner',           'Velisse', 'Eyeliner', 149.90, FALSE),
  ('Nerixa Waterproof Eyeliner',           'Nerixa',  'Eyeliner',  99.90, FALSE),

  ('Velisse Setting Powder',               'Velisse', 'Powder', 199.90, FALSE),
  ('Nerixa Compact Powder',                'Nerixa',  'Powder', 119.90, FALSE),

  ('Velisse Nude Nail Polish',             'Velisse', 'Nail Polish',  99.90, FALSE),
  ('Nerixa Neon Nail Polish',              'Nerixa',  'Nail Polish',  79.90, FALSE),

  -- ========== PERFUME (Aurelle lead + premium option) ==========
  ('Aurelle Eau de Parfum 50ml',           'Aurelle', 'Perfume', 799.90, FALSE),
  ('Aurelle Eau de Toilette 50ml',         'Aurelle', 'Perfume', 599.90, FALSE),
  ('Lumera Signature Perfume 50ml',        'Lumera',  'Perfume', 1099.90, FALSE),

  -- ========== BODY CARE (Aurelle lead; overlap allowed) ==========
  ('Aurelle Shower Gel',                   'Aurelle', 'Body Care', 219.90, FALSE),
  ('Aurelle Body Cream',                   'Aurelle', 'Body Care', 269.90, FALSE),
  ('Purevia Vegan Body Wash',              'Purevia', 'Body Care', 249.90, TRUE),
  ('Nerixa Body Mist',                     'Nerixa',  'Body Care', 149.90, FALSE),

  -- ========== BEAUTY TOOLS (Nerixa trend + some overlap) ==========
  ('Nerixa Beauty Tools Set',              'Nerixa',  'Beauty Tools', 129.90, FALSE),
  ('Velisse Makeup Sponge',                'Velisse', 'Beauty Tools',  89.90, FALSE),
  ('Purevia Bamboo Cotton Pads',           'Purevia', 'Beauty Tools', 119.90, TRUE)
)
INSERT INTO products (product_name, brand_id, category_id, price, is_vegan)
SELECT
  ps.product_name,
  b.brand_id,
  c.category_id,
  ps.price,
  ps.is_vegan
FROM product_seed ps
JOIN brands b ON b.brand_name = ps.brand_name
JOIN categories c ON c.category_name = ps.category_name;

-- ORDERS (date ranges: 2023–2024)

INSERT INTO orders (customer_id, store_id, order_date, order_status)
SELECT
  c.customer_id,
  s.store_id,
  CASE
    WHEN c.country = 'Turkey' THEN
      DATE '2023-01-01'
      + (floor(random() * (DATE '2024-12-31' - DATE '2023-01-01'))::int)
    ELSE
      DATE '2024-01-01'
      + (floor(random() * (DATE '2024-12-31' - DATE '2024-01-01'))::int)
  END AS order_date,
  CASE
    WHEN random() < 0.90 THEN 'completed'
    WHEN random() < 0.97 THEN 'returned'
    ELSE 'cancelled'
  END AS order_status
FROM customers c
CROSS JOIN LATERAL generate_series(
  1,
  CASE
    WHEN c.country = 'Turkey' THEN (4 + floor(random() * 4))::int   -- 4–7 orders
    ELSE (1 + floor(random() * 3))::int                             -- 1–3 orders
  END
) g(n)
JOIN LATERAL (
  SELECT store_id
  FROM stores
  WHERE
    (
      c.country = 'Turkey'
      AND store_type IN ('physical','online_tr')
      AND country = 'Turkey'
    )
    OR
    (
      c.country <> 'Turkey'
      AND (
        (store_type = 'physical' AND country = c.country)
        OR store_type = 'online_global'
      )
    )
  ORDER BY random()
  LIMIT 1
) s ON TRUE;

-- ORDER ITEMS (trend-driven)
-- Abroad -> more vegan / Purevia
-- Coastal cities -> more Sun Care
-- Younger customers (<=24) -> more Nerixa + makeup/tools

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
  o.order_id,
  p.product_id,
  (1 + floor(random() * 3))::int AS quantity,
  ROUND((p.price * (0.85 + random() * 0.30))::numeric, 2) AS unit_price
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id

-- how many items per order
CROSS JOIN LATERAL generate_series(
  1,
  CASE
    WHEN c.country = 'Turkey' THEN (2 + floor(random() * 5))::int   -- 2..6 items
    ELSE (1 + floor(random() * 4))::int                             -- 1..4 items (new market)
  END
) g(n)

-- pick a product with business rules
JOIN LATERAL (
  SELECT pr.*
  FROM products pr
  JOIN brands b ON b.brand_id = pr.brand_id
  JOIN categories cat ON cat.category_id = pr.category_id
  WHERE
    (
      -- 1) Abroad: higher vegan / Purevia probability
      c.country <> 'Turkey'
      AND (
        (random() < 0.60 AND (pr.is_vegan = TRUE OR b.brand_name = 'Purevia'))
        OR (random() >= 0.60)
      )
    )
    OR
    (
      -- 2) Coastal cities: higher Sun Care probability
      c.city IN ('Izmir','Antalya','Balikesir','Marseille','Naples','Gothenburg')
      AND (
        (random() < 0.45 AND cat.category_name = 'Sun Care')
        OR (random() >= 0.45)
      )
    )
    OR
    (
      -- 3) Younger customers: more Nerixa + makeup/tools
      EXTRACT(YEAR FROM age(o.order_date, c.birth_date)) <= 24
      AND (
        (random() < 0.55 AND (
            b.brand_name = 'Nerixa'
            OR cat.category_name IN ('Foundation','Lipstick','Mascara','Blush','Eyeliner','Powder','Nail Polish','Beauty Tools')
        ))
        OR (random() >= 0.55)
      )
    )
    OR
    (
      -- 4) Everyone: allow any product
      TRUE
    )
  ORDER BY random()
  LIMIT 1
) p ON TRUE;


-- Add Sun Care order_items for COASTAL customers ( Sun Care)

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
  o.order_id,
  sp.product_id,
  1 + floor(random() * 2)::int AS quantity,               -- 1-2
  ROUND((sp.price * (0.85 + random() * 0.25))::numeric, 2) AS unit_price
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN LATERAL (
  -- pick a random Sun Care product
  SELECT p.product_id, p.price
  FROM products p
  JOIN categories cat ON cat.category_id = p.category_id
  WHERE cat.category_name = 'Sun Care'
  ORDER BY random()
  LIMIT 1
) sp ON TRUE
WHERE
  o.order_status = 'completed'
  AND c.city IN ('Izmir','Antalya','Balikesir','Marseille','Naples','Gothenburg')
  AND random() < 0.55
  AND NOT EXISTS (
    SELECT 1
    FROM order_items oi
    JOIN products p2 ON p2.product_id = oi.product_id
    JOIN categories cat2 ON cat2.category_id = p2.category_id
    WHERE oi.order_id = o.order_id
      AND cat2.category_name = 'Sun Care'
  );
  
---------------------------------------------------------------------------------------------------------------------------------------
-- 1) Hedef completed sipariş adetleri (senin tablo) EXTRA
WITH targets(store_name, target_cnt) AS (
  VALUES
  ('Eunoia Istanbul Nisantasi', 2049),
  ('Eunoia Online TR', 450),
  ('Eunoia Paris Le Marais', 194),
  ('Eunoia Milan Brera', 111),
  ('Eunoia Stockholm Normalm', 118),
  ('Eunoia Izmir Alsancak', 240),
  ('Eunoia Amasya Merkez', 90),
  ('Eunoia Malatya Merkez', 120),
  ('Eunoia Online Global', 600),
  ('Eunoia Kayseri Talas', 65),
  ('Eunoia Ankara Cankaya', 250),
  ('Eunoia Antalya Lara', 354),
  ('Eunoia Balikesir Merkez', 153),
  ('Eunoia Eskisehir Odunpazari', 123)
),
curr AS (
  SELECT
    s.store_name,
    COUNT(DISTINCT o.order_id) AS current_cnt
  FROM public.stores s
  LEFT JOIN public.orders o
    ON o.store_id = s.store_id
   AND o.order_status = 'completed'
  GROUP BY 1
),
to_add AS (
  SELECT
    t.store_name,
    GREATEST(t.target_cnt - COALESCE(c.current_cnt,0), 0) AS add_cnt
  FROM targets t
  LEFT JOIN curr c ON c.store_name = t.store_name
),
ins_orders AS (
  INSERT INTO public.orders (customer_id, store_id, order_date, order_status)
  SELECT
    -- müşteri: mümkünse store ülkesinden, yoksa rastgele
    COALESCE(c_same.customer_id, c_any.customer_id) AS customer_id,
    s.store_id,
    CASE
      WHEN s.country = 'Turkey' THEN
        DATE '2023-01-01' + (floor(random() * (DATE '2024-12-31' - DATE '2023-01-01'))::int)
      ELSE
        DATE '2024-01-01' + (floor(random() * (DATE '2024-12-31' - DATE '2024-01-01'))::int)
    END AS order_date,
    'completed' AS order_status
  FROM to_add a
  JOIN public.stores s ON s.store_name = a.store_name
  CROSS JOIN LATERAL generate_series(1, a.add_cnt) gs(n)
  LEFT JOIN LATERAL (
    SELECT c.customer_id
    FROM public.customers c
    WHERE c.country = s.country
    ORDER BY random()
    LIMIT 1
  ) c_same ON TRUE
  LEFT JOIN LATERAL (
    SELECT c.customer_id
    FROM public.customers c
    ORDER BY random()
    LIMIT 1
  ) c_any ON TRUE
  WHERE a.add_cnt > 0
  RETURNING order_id, customer_id, store_id, order_date
)
INSERT INTO public.order_items (order_id, product_id, quantity, unit_price)
SELECT
  io.order_id,
  p.product_id,
  (1 + floor(random() * 3))::int AS quantity,
  ROUND((p.price * (0.85 + random() * 0.30))::numeric, 2) AS unit_price
FROM ins_orders io
-- her order'a 2-5 kalem ürün ekleyelim
CROSS JOIN LATERAL generate_series(1, (2 + floor(random() * 4))::int) g(n)
JOIN LATERAL (
  SELECT pr.product_id, pr.price
  FROM public.products pr
  ORDER BY random()
  LIMIT 1
) p ON TRUE;

----------------------------------------------------------------------------------------------------------------------------------------
--EXTRA 

WITH vegan_targets(store_name, vegan_order_cnt) AS (
  VALUES
    ('Eunoia Paris Le Marais', 260),
    ('Eunoia Milan Brera', 300),
    ('Eunoia Stockholm Normalm', 456)
),
candidate_orders AS (
  SELECT o.order_id, s.store_name
  FROM public.orders o
  JOIN public.stores s ON s.store_id = o.store_id
  WHERE o.order_status = 'completed'
    AND s.store_name IN (SELECT store_name FROM vegan_targets)
),
ranked AS (
  SELECT
    co.store_name,
    co.order_id,
    ROW_NUMBER() OVER (PARTITION BY co.store_name ORDER BY random()) AS rn
  FROM candidate_orders co
),
picked AS (
  SELECT r.store_name, r.order_id
  FROM ranked r
  JOIN vegan_targets vt ON vt.store_name = r.store_name
  WHERE r.rn <= vt.vegan_order_cnt
)
INSERT INTO public.order_items(order_id, product_id, quantity, unit_price)
SELECT
  p.order_id,
  vp.product_id,
  1,
  ROUND((vp.price * (0.90 + random() * 0.20))::numeric, 2)
FROM picked p
JOIN LATERAL (
  SELECT product_id, price
  FROM public.products
  WHERE is_vegan = TRUE
  ORDER BY random()
  LIMIT 1
) vp ON TRUE;




--------------------------------------------------------------------------------------------------------------------------------------
SELECT c.country, COUNT(*) 
FROM orders o JOIN customers c ON c.customer_id=o.customer_id
GROUP BY c.country ORDER BY 2 DESC;



-- Order-level summary view calculating total order amount for reporting and analysis.

CREATE VIEW order_totals AS
SELECT
  o.order_id,
  o.customer_id,
  o.store_id,
  o.order_date,
  SUM(oi.quantity * oi.unit_price) AS order_total_amount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY
  o.order_id,
  o.customer_id,
  o.store_id,
  o.order_date;


-- Reporting view for Power BI: combines sales, customers, products, brands, and categories
-- to analyze customer behavior and brand performance in B2C retail.


CREATE VIEW vw_sales_detail AS
SELECT
  o.order_id,
  o.order_date,
  o.order_status,

  c.customer_id,
  c.first_name,
  c.last_name,
  c.gender,
  c.birth_date,
  c.email,
  c.city   AS customer_city,
  c.country AS customer_country,

  s.store_id,
  s.store_name,
  s.store_type,
  s.city   AS store_city,
  s.country AS store_country,

  oi.order_item_id,
  oi.product_id,
  p.product_name,
  b.brand_id,
  b.brand_name,
  b.brand_position,
  cat.category_id,
  cat.category_name,

  oi.quantity,
  oi.unit_price,
  (oi.quantity * oi.unit_price) AS line_total_amount,

  p.is_vegan,
  p.price AS current_list_price
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN stores s      ON s.store_id = o.store_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p    ON p.product_id = oi.product_id
JOIN brands b      ON b.brand_id = p.brand_id
JOIN categories cat ON cat.category_id = p.category_id;


CREATE OR REPLACE VIEW vw_region_suncare_summary AS
SELECT
  CASE WHEN c.city IN ('Izmir','Antalya','Balikesir','Marseille','Naples','Gothenburg')
       THEN 'Coastal' ELSE 'Non-Coastal' END AS region,
  COUNT(*) FILTER (WHERE cat.category_name = 'Sun Care') AS sun_items,
  COUNT(*) AS total_items,
  ROUND(100.0 * COUNT(*) FILTER (WHERE cat.category_name = 'Sun Care') / NULLIF(COUNT(*),0), 2) AS sun_share_pct
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
GROUP BY region;

--FINAL DATA GENERATION LOGIC – DO NOT RE-RUN  
--This script generates realistic order_items with controlled behavioral bias (coastal → Sun Care, abroad → Vegan/Purevia, young → Nerixa/Makeup) and was validated for Power BI reporting.  
--Do not execute again unless order_items is truncated; the current table represents the FINAL dataset.


TRUNCATE TABLE order_items RESTART IDENTITY;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
  o.order_id,
  picked.product_id,
  (1 + floor(random() * 3))::int AS quantity,
  ROUND((picked.price * (0.85 + random() * 0.30))::numeric, 2) AS unit_price
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id

CROSS JOIN LATERAL generate_series(
  1,
  CASE
    WHEN c.country = 'Turkey' THEN (2 + floor(random() * 5))::int
    ELSE (1 + floor(random() * 4))::int
  END
) g(n)

JOIN LATERAL (
  SELECT
    pr.product_id,
    pr.price
  FROM products pr
  JOIN brands b ON b.brand_id = pr.brand_id
  JOIN categories cat ON cat.category_id = pr.category_id
  ORDER BY
    (
      1
      + CASE
          WHEN c.country <> 'Turkey'
           AND (pr.is_vegan OR b.brand_name = 'Purevia')
          THEN 4 ELSE 0
        END

      + CASE
          WHEN c.city IN ('Izmir','Antalya','Balikesir','Marseille','Naples','Gothenburg')
           AND cat.category_name = 'Sun Care'
           AND random() < 0.20
          THEN 1 ELSE 0
        END

      + CASE
          WHEN EXTRACT(YEAR FROM age(o.order_date, c.birth_date)) <= 24
           AND (
             b.brand_name = 'Nerixa'
             OR cat.category_name IN ('Foundation','Lipstick','Mascara','Blush','Eyeliner','Powder','Nail Polish','Beauty Tools')
           )
          THEN 3 ELSE 0
        END
    ) DESC,
    random()
  LIMIT 1
) picked ON TRUE;

--------------------------------------------------------------------------------------------------------------------------------------------

SELECT
  CASE 
    WHEN c.city IN ('Izmir','Antalya','Balikesir','Marseille','Naples','Gothenburg')
    THEN 'Coastal'
    ELSE 'Non-Coastal'
  END AS region,

  COUNT(*) FILTER (WHERE cat.category_name = 'Sun Care') AS sun_care_items,
  COUNT(*) AS total_items,

  ROUND(
    100.0 * COUNT(*) FILTER (WHERE cat.category_name = 'Sun Care')
    / NULLIF(COUNT(*),0),
    2
  ) AS sun_share_pct
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
GROUP BY 1
ORDER BY 1;

---------------------------------------------------------------------------------------------------------------------------------------------------


SELECT
  EXTRACT(YEAR FROM o.order_date)::int AS year,
  ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1
ORDER BY 1;


SELECT
  EXTRACT(YEAR FROM o.order_date)::int AS year,
  b.brand_name,
  ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN brands b ON b.brand_id = p.brand_id
WHERE o.order_status = 'completed'
GROUP BY 1, 2
ORDER BY 1, revenue DESC;


-- 2024 BOOST INSERT (run once)
-- Goal: 2024 revenue up for most brands, Nerixa stays relatively lower.

WITH new_orders AS (
  INSERT INTO orders (customer_id, store_id, order_date, order_status)
  SELECT
    c.customer_id,
    s.store_id,
    (DATE '2024-01-01' + (random() * (DATE '2024-12-31' - DATE '2024-01-01'))::int) AS order_date,
    'completed'::varchar
  FROM (
    SELECT customer_id
    FROM customers
    ORDER BY random()
    LIMIT 450          -- << artır/azalt: 2024 büyüme şiddeti
  ) c
  CROSS JOIN LATERAL (
    SELECT store_id
    FROM stores
    ORDER BY random()
    LIMIT 1
  ) s
  RETURNING order_id, order_date
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
  o.order_id,
  picked.product_id,
  (1 + floor(random() * 3))::int AS quantity,
  ROUND((picked.price * (0.95 + random() * 0.25))::numeric, 2) AS unit_price
FROM new_orders o
CROSS JOIN LATERAL generate_series(
  1,
  (2 + floor(random() * 4))::int   -- 2..5 items per order
) g(n)
JOIN LATERAL (
  SELECT
    pr.product_id,
    pr.price
  FROM products pr
  JOIN brands b ON b.brand_id = pr.brand_id
  JOIN categories cat ON cat.category_id = pr.category_id
  ORDER BY
    (
      1
      -- Growth brands (boost 2024)
      + CASE WHEN b.brand_name IN ('Purevia','Lumera','Velisse','Aurelle') THEN 8 ELSE 0 END

      -- Keep only one brand "worse" (Nerixa) by NOT boosting it (even slight downweight)
      + CASE WHEN b.brand_name = 'Nerixa' THEN -2 ELSE 0 END

      -- (Optional) still keep your behavioral bias a bit
      + CASE WHEN cat.category_name = 'Sun Care' THEN 1 ELSE 0 END
    ) DESC,
    random()
  LIMIT 1
) picked ON TRUE;


----------------------------------------------------------------------------------------------------------------------------------
--TARGET 
----------------------------------------------------------------------------------------------------------------------------------
-- 1) Targets table

CREATE TABLE IF NOT EXISTS brand_targets (
  target_id   SERIAL PRIMARY KEY,
  brand_id    INT NOT NULL REFERENCES brands(brand_id),
  target_year INT NOT NULL,
  target_revenue NUMERIC(14,2) NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (brand_id, target_year)
);

-- 2) Upsert targets (2023-2024)

INSERT INTO brand_targets (brand_id, target_year, target_revenue)
SELECT b.brand_id, v.target_year, v.target_revenue
FROM (VALUES
  ('Nerixa',  2023,  850000::numeric),
  ('Nerixa',  2024, 1050000::numeric),
  ('Lumera',  2023,  800000::numeric),
  ('Lumera',  2024, 1000000::numeric),
  ('Velisse', 2023,  700000::numeric),
  ('Velisse', 2024, 900000::numeric),
  ('Purevia', 2023,  450000::numeric),
  ('Purevia', 2024,  675000::numeric),
  ('Aurelle', 2023,  400000::numeric),
  ('Aurelle', 2024,  500000::numeric)
) AS v(brand_name, target_year, target_revenue)
JOIN brands b ON b.brand_name = v.brand_name
ON CONFLICT (brand_id, target_year)
DO UPDATE SET target_revenue = EXCLUDED.target_revenue;


-- 3) View: Actual vs Target (Completed revenue)

CREATE OR REPLACE VIEW vw_brand_actual_vs_target AS
SELECT
  EXTRACT(YEAR FROM o.order_date)::int AS year,
  b.brand_name,
  ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS actual_revenue,
  MAX(bt.target_revenue) AS target_revenue,
  ROUND((SUM(oi.quantity * oi.unit_price) - MAX(bt.target_revenue))::numeric, 2) AS variance,
  ROUND((SUM(oi.quantity * oi.unit_price) / NULLIF(MAX(bt.target_revenue),0) * 100)::numeric, 2) AS achievement_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN brands b ON b.brand_id = p.brand_id
LEFT JOIN brand_targets bt
  ON bt.brand_id = b.brand_id
 AND bt.target_year = EXTRACT(YEAR FROM o.order_date)::int
WHERE o.order_status = 'completed'
GROUP BY 1,2;


------------------------------------------------------------------------------------------------------------------------------------

SELECT
    b.brand_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue,
    ROUND(
        100.0 * SUM(oi.quantity * oi.unit_price)
        / SUM(SUM(oi.quantity * oi.unit_price)) OVER (),
        2
    ) AS revenue_pct
FROM public.orders o
JOIN public.order_items oi ON oi.order_id = o.order_id
JOIN public.products p ON p.product_id = oi.product_id
JOIN public.brands b ON b.brand_id = p.brand_id
WHERE o.order_status = 'completed'
GROUP BY b.brand_name
ORDER BY revenue DESC;

---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_monthly_orders_completed AS
WITH m AS (
  SELECT
    date_trunc('month', o.order_date)::date AS month,
    COUNT(DISTINCT o.order_id) AS completed_orders
  FROM public.orders o
  WHERE o.order_status = 'completed'
  GROUP BY 1
),
x AS (
  SELECT
    month,
    completed_orders,
    LAG(completed_orders) OVER (ORDER BY month) AS prev_month_orders
  FROM m
)
SELECT
  month,
  completed_orders,
  prev_month_orders,
  CASE
    WHEN prev_month_orders IS NULL OR prev_month_orders = 0 THEN NULL
    ELSE ROUND((completed_orders - prev_month_orders)::numeric / prev_month_orders * 100, 2)
  END AS mom_change_pct
FROM x
ORDER BY month;

---------------------------------------------------------------------------------------------------------------------------------

WITH m AS (
  SELECT
    EXTRACT(MONTH FROM o.order_date)::int AS month_no,
    TO_CHAR(o.order_date, 'TMMonth') AS ay,
    EXTRACT(YEAR FROM o.order_date)::int AS yil,
    COUNT(DISTINCT o.order_id) AS siparis_adedi
  FROM public.orders o
  WHERE o.order_status = 'completed'
    AND EXTRACT(YEAR FROM o.order_date) IN (2023, 2024)
  GROUP BY 1,2,3
),
p AS (
  SELECT
    month_no,
    TRIM(ay) AS ay,
    SUM(CASE WHEN yil=2023 THEN siparis_adedi ELSE 0 END) AS "2023",
    SUM(CASE WHEN yil=2024 THEN siparis_adedi ELSE 0 END) AS "2024"
  FROM m
  GROUP BY 1,2
)
SELECT
  ay,
  "2023",
  "2024",
  ROUND( (("2024" - "2023")::numeric / NULLIF("2023",0)), 4) AS degisim_orani
FROM p
ORDER BY month_no;
--------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_monthly_orders_yoy;

CREATE VIEW public.vw_monthly_orders_yoy AS
WITH m AS (
  SELECT
    EXTRACT(MONTH FROM o.order_date)::int AS month_no,
    TO_CHAR(o.order_date, 'TMMonth') AS ay,
    EXTRACT(YEAR FROM o.order_date)::int AS yil,
    COUNT(DISTINCT o.order_id) AS siparis_adedi
  FROM public.orders o
  WHERE o.order_status = 'completed'
    AND EXTRACT(YEAR FROM o.order_date) IN (2023, 2024)
  GROUP BY 1,2,3
),
p AS (
  SELECT
    month_no,
    TRIM(ay) AS ay,
    SUM(CASE WHEN yil=2023 THEN siparis_adedi ELSE 0 END) AS siparis_2023,
    SUM(CASE WHEN yil=2024 THEN siparis_adedi ELSE 0 END) AS siparis_2024
  FROM m
  GROUP BY 1,2
)
SELECT
  month_no,
  ay,
  siparis_2023,
  siparis_2024,
  ROUND(
    (siparis_2024 - siparis_2023)::numeric / NULLIF(siparis_2023,0),
    4
  ) AS degisim_orani
FROM p
ORDER BY month_no;





SELECT
  s.store_name,
  COUNT(DISTINCT o.order_id)                        AS siparis_sayisi,
  SUM(oi.quantity)                                  AS toplam_miktar,
  SUM(oi.quantity * oi.unit_price)                  AS toplam_ciro
FROM public.stores s
LEFT JOIN public.orders o
  ON o.store_id = s.store_id
  AND o.order_status = 'completed'
LEFT JOIN public.order_items oi
  ON oi.order_id = o.order_id
GROUP BY s.store_name
ORDER BY toplam_ciro DESC NULLS LAST;







