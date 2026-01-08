-- ==================== RENTAL SYSTEM TABLES ====================
-- Created: 2024
-- Purpose: Vehicle Rental System Database Structure

-- ==================== RENTAL RENTALS TABLE ====================
CREATE TABLE IF NOT EXISTS `rental_rentals` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NOT NULL,
    `player_name` VARCHAR(50) NOT NULL,
    `vehicle_model` VARCHAR(50) NOT NULL,
    `vehicle_label` VARCHAR(100) NOT NULL,
    `rental_plate` VARCHAR(20) UNIQUE NOT NULL,
    `rental_days` INT NOT NULL,
    `rental_cost` INT NOT NULL DEFAULT 0,
    `insurance` INT DEFAULT 0,
    `start_time` BIGINT NOT NULL,
    `end_time` BIGINT NOT NULL,
    `return_time` BIGINT DEFAULT NULL,
    `damage_amount` INT DEFAULT 0,
    `fuel_consumed` INT DEFAULT 0,
    `status` VARCHAR(20) DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `returned_at` TIMESTAMP NULL,
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_rental_plate` (`rental_plate`),
    INDEX `idx_created_at` (`created_at`),
    INDEX `idx_player_status` (`player_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== RETURN POINTS TABLE ====================
CREATE TABLE IF NOT EXISTS `rental_return_points` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `location_id` VARCHAR(50) NOT NULL UNIQUE,
    `coords_x` FLOAT NOT NULL,
    `coords_y` FLOAT NOT NULL,
    `coords_z` FLOAT NOT NULL,
    `heading` FLOAT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_location_id` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== PLAYER CACHE TABLE ====================
CREATE TABLE IF NOT EXISTS `rental_player_cache` (
    `player_id` INT PRIMARY KEY,
    `active_rental_id` INT,
    `data` LONGTEXT,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY(`active_rental_id`) REFERENCES `rental_rentals`(`id`) ON DELETE SET NULL,
    INDEX `idx_active_rental` (`active_rental_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== RENTAL HISTORY VIEW ====================
CREATE OR REPLACE VIEW `vw_rental_history` AS
SELECT 
    r.id,
    r.player_id,
    r.player_name,
    r.vehicle_label,
    r.rental_plate,
    r.rental_days,
    r.rental_cost,
    r.insurance,
    r.damage_amount,
    r.status,
    DATE_FORMAT(FROM_UNIXTIME(r.start_time), '%Y-%m-%d %H:%i:%s') as start_date,
    DATE_FORMAT(FROM_UNIXTIME(r.end_time), '%Y-%m-%d %H:%i:%s') as end_date,
    r.returned_at,
    r.created_at
FROM rental_rentals r
ORDER BY r.created_at DESC;

-- ==================== RENTAL STATISTICS VIEW ====================
CREATE OR REPLACE VIEW `vw_rental_stats` AS
SELECT 
    COUNT(*) as total_rentals,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_rentals,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_rentals,
    SUM(CASE WHEN status = 'completed' THEN rental_cost + COALESCE(insurance, 0) ELSE 0 END) as total_revenue,
    AVG(CASE WHEN status = 'completed' THEN rental_cost ELSE NULL END) as avg_rental_cost,
    SUM(CASE WHEN status = 'completed' THEN damage_amount ELSE 0 END) as total_damage_charges
FROM rental_rentals;

-- ==================== INSERT SAMPLE RETURN POINTS ====================
INSERT INTO `rental_return_points` (`location_id`, `coords_x`, `coords_y`, `coords_z`, `heading`) VALUES
('downtown', 427.5, 318.2, 103.2, 159.5),
('airport', -1008.5, -2718.8, 13.9, 90.0),
('sandy', 1142.5, 2787.5, 52.3, 180.0)
ON DUPLICATE KEY UPDATE `heading` = VALUES(`heading`);

-- ==================== GRANTS ====================
-- Uncomment if using a specific database user
-- GRANT SELECT, INSERT, UPDATE, DELETE ON rental_rentals TO 'fivem'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON rental_player_cache TO 'fivem'@'localhost';
-- GRANT SELECT ON rental_return_points TO 'fivem'@'localhost';
-- GRANT SELECT ON vw_rental_history TO 'fivem'@'localhost';
-- GRANT SELECT ON vw_rental_stats TO 'fivem'@'localhost';

-- ==================== INDEXES FOR OPTIMIZATION ====================
ALTER TABLE `rental_rentals` ADD FULLTEXT INDEX `ft_vehicle_label` (`vehicle_label`);
ALTER TABLE `rental_rentals` ADD FULLTEXT INDEX `ft_player_name` (`player_name`);

-- ==================== END ====================
-- All tables created successfully!
