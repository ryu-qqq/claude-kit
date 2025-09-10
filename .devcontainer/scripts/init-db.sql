-- Claude Code DevContainer MySQL 초기화 스크립트
-- MySQL 8.4 초기 데이터베이스 설정

-- 개발용 데이터베이스 생성 (이미 존재할 수 있으므로 IF NOT EXISTS 사용)
CREATE DATABASE IF NOT EXISTS devdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 개발용 사용자 생성 및 권한 부여
CREATE USER IF NOT EXISTS 'devuser'@'%' IDENTIFIED BY 'devpass';
GRANT ALL PRIVILEGES ON devdb.* TO 'devuser'@'%';

-- 테스트용 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS testdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON testdb.* TO 'devuser'@'%';

-- 권한 적용
FLUSH PRIVILEGES;

-- devdb 사용
USE devdb;

-- 예제 테이블 생성 (Spring Boot 프로젝트용)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- 예제 상품 테이블
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id BIGINT,
    sku VARCHAR(50) UNIQUE,
    stock_quantity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_category_id (category_id),
    INDEX idx_sku (sku),
    INDEX idx_price (price)
);

-- 예제 주문 테이블
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    total_amount DECIMAL(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (status),
    INDEX idx_order_date (order_date)
);

-- 예제 주문 상품 테이블
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

-- 샘플 데이터 삽입
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES 
('admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFe5NQZaK9RaNxy5bKQ0JLG', 'Admin', 'User'),
('developer', 'dev@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFe5NQZaK9RaNxy5bKQ0JLG', 'Dev', 'User')
ON DUPLICATE KEY UPDATE username=VALUES(username);

INSERT INTO products (name, description, price, sku, stock_quantity) VALUES 
('Sample Product 1', 'This is a sample product for testing', 29.99, 'SP-001', 100),
('Sample Product 2', 'Another sample product', 49.99, 'SP-002', 50)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 개발용 설정 확인 쿼리
SELECT 
    'Database Setup Complete' as status,
    COUNT(*) as user_count 
FROM users;

SELECT 
    'Sample Data' as info,
    (SELECT COUNT(*) FROM users) as users,
    (SELECT COUNT(*) FROM products) as products;

-- 유용한 개발용 뷰 생성
CREATE OR REPLACE VIEW user_order_summary AS
SELECT 
    u.id as user_id,
    u.username,
    u.email,
    COUNT(o.id) as order_count,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    MAX(o.order_date) as last_order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username, u.email;

-- 성능 최적화를 위한 추가 인덱스
ALTER TABLE users ADD INDEX idx_active_created (is_active, created_at);
ALTER TABLE products ADD INDEX idx_active_stock (is_active, stock_quantity);
ALTER TABLE orders ADD INDEX idx_user_status_date (user_id, status, order_date);

-- 데이터베이스 상태 확인
SHOW TABLES;

SELECT 'MySQL 8.4 DevContainer Database Initialized Successfully!' as message;