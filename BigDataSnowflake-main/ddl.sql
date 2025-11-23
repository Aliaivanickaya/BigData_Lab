-- Создаем схему для нормализованных данных
CREATE SCHEMA IF NOT EXISTS snowflake_schema;

-- Таблица измерения клиентов
CREATE TABLE snowflake_schema.dim_customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    age INTEGER,
    email VARCHAR(255) NOT NULL,
    country VARCHAR(255),
    postal_code VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_customer_unique UNIQUE (first_name, last_name, email, age, country)
);

-- Таблица измерения питомцев
CREATE TABLE snowflake_schema.dim_pets (
    pet_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    pet_type VARCHAR(100),
    pet_name VARCHAR(255) NOT NULL,
    pet_breed VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pets_customer 
        FOREIGN KEY (customer_id) REFERENCES snowflake_schema.dim_customers(customer_id),
    CONSTRAINT uq_pet_unique UNIQUE (customer_id, pet_name, pet_breed)
);

-- Таблица измерения продавцов
CREATE TABLE snowflake_schema.dim_sellers (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    country VARCHAR(255),
    postal_code VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_seller_unique UNIQUE (first_name, last_name, email, country)
);

-- Таблица измерения продуктов
CREATE TABLE snowflake_schema.dim_products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    price DECIMAL(10,2),
    weight DECIMAL(10,2),
    color VARCHAR(100),
    size VARCHAR(50),
    brand VARCHAR(255),
    material VARCHAR(255),
    description TEXT,
    rating DECIMAL(3,2),
    reviews INTEGER,
    release_date VARCHAR(100),
    expiry_date VARCHAR(100),
    pet_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_product_unique UNIQUE (name, category, price, weight, color, size, 
                                       brand, material, description, rating, reviews, 
                                       release_date, expiry_date)
);

-- Таблица измерения магазинов
CREATE TABLE snowflake_schema.dim_stores (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_store_unique UNIQUE (name, location, city, country)
);

-- Таблица измерения поставщиков
CREATE TABLE snowflake_schema.dim_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact VARCHAR(255),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    city VARCHAR(255),
    country VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_supplier_unique UNIQUE (name, contact, email)
);

-- Фактовая таблица продаж
CREATE TABLE snowflake_schema.fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    seller_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    supplier_id INTEGER NOT NULL,
    sale_date VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_sales_customer 
        FOREIGN KEY (customer_id) REFERENCES snowflake_schema.dim_customers(customer_id),
    CONSTRAINT fk_sales_seller 
        FOREIGN KEY (seller_id) REFERENCES snowflake_schema.dim_sellers(seller_id),
    CONSTRAINT fk_sales_product 
        FOREIGN KEY (product_id) REFERENCES snowflake_schema.dim_products(product_id),
    CONSTRAINT fk_sales_store 
        FOREIGN KEY (store_id) REFERENCES snowflake_schema.dim_stores(store_id),
    CONSTRAINT fk_sales_supplier 
        FOREIGN KEY (supplier_id) REFERENCES snowflake_schema.dim_suppliers(supplier_id)
);

-- Создание индексов для улучшения производительности
CREATE INDEX idx_fact_sales_date ON snowflake_schema.fact_sales(sale_date);
CREATE INDEX idx_fact_sales_customer ON snowflake_schema.fact_sales(customer_id);
CREATE INDEX idx_fact_sales_product ON snowflake_schema.fact_sales(product_id);
CREATE INDEX idx_fact_sales_store ON snowflake_schema.fact_sales(store_id);
CREATE INDEX idx_fact_sales_seller ON snowflake_schema.fact_sales(seller_id);
CREATE INDEX idx_fact_sales_supplier ON snowflake_schema.fact_sales(supplier_id);

CREATE INDEX idx_customers_email ON snowflake_schema.dim_customers(email);
CREATE INDEX idx_products_category ON snowflake_schema.dim_products(category);
CREATE INDEX idx_products_brand ON snowflake_schema.dim_products(brand);