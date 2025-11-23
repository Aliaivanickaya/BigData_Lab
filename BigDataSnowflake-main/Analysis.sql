-- Просмотр структуры таблицы и первых записей
SELECT * FROM mock_data LIMIT 10;

-- Анализ уникальных значений и кардинальности ключевых атрибутов
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT id) as unique_ids,
    COUNT(DISTINCT sale_customer_id) as unique_customers,
    COUNT(DISTINCT sale_seller_id) as unique_sellers,
    COUNT(DISTINCT sale_product_id) as unique_products,
    COUNT(DISTINCT store_name) as unique_stores,
    COUNT(DISTINCT supplier_name) as unique_suppliers
FROM mock_data;

-- Анализ атрибутов покупателей
SELECT 
    COUNT(DISTINCT sale_customer_id) as unique_customer_ids,
    COUNT(DISTINCT customer_first_name || ' ' || customer_last_name) as unique_customer_names,
    COUNT(DISTINCT customer_email) as unique_emails,
    COUNT(DISTINCT customer_country) as unique_customer_countries,
    COUNT(DISTINCT customer_postal_code) as unique_postal_codes,
    COUNT(DISTINCT customer_pet_type) as unique_pet_types,
    COUNT(DISTINCT customer_pet_breed) as unique_pet_breeds
FROM mock_data;

-- Анализ атрибутов продавцов
SELECT 
    COUNT(DISTINCT sale_seller_id) as unique_seller_ids,
    COUNT(DISTINCT seller_first_name || ' ' || seller_last_name) as unique_seller_names,
    COUNT(DISTINCT seller_email) as unique_seller_emails,
    COUNT(DISTINCT seller_country) as unique_seller_countries,
    COUNT(DISTINCT seller_postal_code) as unique_seller_postal_codes
FROM mock_data;

-- Анализ атрибутов товаров
SELECT 
    COUNT(DISTINCT sale_product_id) as unique_product_ids,
    COUNT(DISTINCT product_name) as unique_product_names,
    COUNT(DISTINCT product_category) as unique_categories,
    COUNT(DISTINCT pet_category) as unique_pet_categories,
    COUNT(DISTINCT product_brand) as unique_brands,
    COUNT(DISTINCT product_color) as unique_colors,
    COUNT(DISTINCT product_size) as unique_sizes,
    COUNT(DISTINCT product_material) as unique_materials
FROM mock_data;

-- Анализ атрибутов магазинов
SELECT 
    COUNT(DISTINCT store_name) as unique_store_names,
    COUNT(DISTINCT store_location) as unique_locations,
    COUNT(DISTINCT store_city) as unique_store_cities,
    COUNT(DISTINCT store_state) as unique_store_states,
    COUNT(DISTINCT store_country) as unique_store_countries,
    COUNT(DISTINCT store_phone) as unique_store_phones,
    COUNT(DISTINCT store_email) as unique_store_emails
FROM mock_data;

-- Анализ атрибутов поставщиков
SELECT 
    COUNT(DISTINCT supplier_name) as unique_supplier_names,
    COUNT(DISTINCT supplier_contact) as unique_supplier_contacts,
    COUNT(DISTINCT supplier_email) as unique_supplier_emails,
    COUNT(DISTINCT supplier_phone) as unique_supplier_phones,
    COUNT(DISTINCT supplier_address) as unique_supplier_addresses,
    COUNT(DISTINCT supplier_city) as unique_supplier_cities,
    COUNT(DISTINCT supplier_country) as unique_supplier_countries
FROM mock_data;

-- Анализ числовых атрибутов товаров
SELECT 
    COUNT(DISTINCT product_price) as unique_prices,
    MIN(product_price) as min_price,
    MAX(product_price) as max_price,
    AVG(product_price) as avg_price,
    COUNT(DISTINCT product_quantity) as unique_quantities,
    COUNT(DISTINCT product_weight) as unique_weights,
    COUNT(DISTINCT product_rating) as unique_ratings,
    COUNT(DISTINCT product_reviews) as unique_reviews_count
FROM mock_data;

-- Анализ временных атрибутов
SELECT 
    MIN(sale_date) as first_sale,
    MAX(sale_date) as last_sale,
    COUNT(DISTINCT sale_date) as unique_dates,
    MIN(product_release_date) as first_release,
    MAX(product_release_date) as last_release,
    MIN(product_expiry_date) as first_expiry,
    MAX(product_expiry_date) as last_expiry
FROM mock_data;

-- Проверка на NULL значения в ключевых полях
SELECT 
    COUNT(*) as total_records,
    SUM(CASE WHEN sale_customer_id IS NULL THEN 1 ELSE 0 END) as null_customer_id,
    SUM(CASE WHEN sale_seller_id IS NULL THEN 1 ELSE 0 END) as null_seller_id,
    SUM(CASE WHEN sale_product_id IS NULL THEN 1 ELSE 0 END) as null_product_id,
    SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) as null_sale_date,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) as null_product_name,
    SUM(CASE WHEN store_name IS NULL THEN 1 ELSE 0 END) as null_store_name
FROM mock_data;

-- Анализ продаж по категориям товаров и питомцев
SELECT 
    product_category,
    pet_category,
    COUNT(*) as sales_count,
    AVG(sale_quantity) as avg_sale_quantity,
    AVG(sale_total_price) as avg_sale_amount,
    SUM(sale_total_price) as total_revenue
FROM mock_data
GROUP BY product_category, pet_category
ORDER BY total_revenue DESC;

-- Анализ географического распределения
SELECT 
    customer_country,
    COUNT(DISTINCT sale_customer_id) as customer_count,
    COUNT(*) as sales_count
FROM mock_data
GROUP BY customer_country
ORDER BY sales_count DESC;

-- Анализ по типам питомцев
SELECT 
    customer_pet_type,
    customer_pet_breed,
    COUNT(DISTINCT sale_customer_id) as customer_count,
    COUNT(*) as sales_count
FROM mock_data
GROUP BY customer_pet_type, customer_pet_breed
ORDER BY sales_count DESC;

-- Анализ временных паттернов продаж
SELECT 
    EXTRACT(YEAR FROM sale_date) as sale_year,
    EXTRACT(MONTH FROM sale_date) as sale_month,
    COUNT(*) as sales_count,
    SUM(sale_quantity) as total_quantity,
    SUM(sale_total_price) as total_revenue
FROM mock_data
GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
ORDER BY sale_year, sale_month;

-- Анализ брендов и рейтингов товаров
SELECT 
    product_brand,
    AVG(product_rating) as avg_rating,
    AVG(product_reviews) as avg_reviews,
    COUNT(*) as products_count,
    SUM(sale_quantity) as total_sold
FROM mock_data
GROUP BY product_brand
HAVING AVG(product_rating) IS NOT NULL
ORDER BY avg_rating DESC;