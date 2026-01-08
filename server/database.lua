Database = {}

-- ==================== DATABASE INITIALIZATION ====================
Database.Init = function()
    -- Create tables if they don't exist
    Database.CreateTables()
    Utils.Success('Database initialized successfully')
end

-- ==================== CREATE TABLES ====================
Database.CreateTables = function()
    -- Rentals table
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS rental_rentals (
            id INT AUTO_INCREMENT PRIMARY KEY,
            player_id INT NOT NULL,
            player_name VARCHAR(50) NOT NULL,
            vehicle_model VARCHAR(50) NOT NULL,
            vehicle_label VARCHAR(100) NOT NULL,
            rental_plate VARCHAR(20) UNIQUE NOT NULL,
            rental_days INT NOT NULL,
            rental_cost INT NOT NULL,
            insurance INT DEFAULT 0,
            start_time BIGINT NOT NULL,
            end_time BIGINT NOT NULL,
            return_time BIGINT DEFAULT NULL,
            damage_amount INT DEFAULT 0,
            fuel_consumed INT DEFAULT 0,
            status VARCHAR(20) DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            returned_at TIMESTAMP NULL,
            INDEX(player_id),
            INDEX(status),
            INDEX(rental_plate)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
    
    -- Return points table
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS rental_return_points (
            id INT AUTO_INCREMENT PRIMARY KEY,
            location_id VARCHAR(50) NOT NULL UNIQUE,
            coords_x FLOAT NOT NULL,
            coords_y FLOAT NOT NULL,
            coords_z FLOAT NOT NULL,
            heading FLOAT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
    
    -- Player rentals cache
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS rental_player_cache (
            player_id INT PRIMARY KEY,
            active_rental_id INT,
            data LONGTEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY(active_rental_id) REFERENCES rental_rentals(id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end

-- ==================== RENTAL RECORDS ====================
Database.CreateRental = function(playerId, playerName, vehicleData, rentalDays, totalCost, hasInsurance, plate)
    local currentTime = os.time()
    local endTime = currentTime + (rentalDays * 86400)
    
    local result = MySQL.insert.await([[
        INSERT INTO rental_rentals 
        (player_id, player_name, vehicle_model, vehicle_label, rental_plate, rental_days, rental_cost, insurance, start_time, end_time, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active')
    ]], {
        playerId,
        playerName,
        vehicleData.model,
        vehicleData.label,
        plate,
        rentalDays,
        totalCost,
        hasInsurance and Config.Insurance.price or 0,
        currentTime,
        endTime
    })
    
    return result
end

Database.GetRentalById = function(rentalId)
    local result = MySQL.query.await(
        'SELECT * FROM rental_rentals WHERE id = ? AND status = ?',
        { rentalId, 'active' }
    )
    
    return result and result[1] or nil
end

Database.GetPlayerActiveRental = function(playerId)
    local result = MySQL.query.await(
        'SELECT * FROM rental_rentals WHERE player_id = ? AND status = ?',
        { playerId, 'active' }
    )
    
    return result and result[1] or nil
end

Database.UpdateRental = function(rentalId, data)
    local setClause = {}
    local values = {}
    
    for key, value in pairs(data) do
        table.insert(setClause, key .. ' = ?')
        table.insert(values, value)
    end
    
    table.insert(values, rentalId)
    
    MySQL.update.await(
        'UPDATE rental_rentals SET ' .. table.concat(setClause, ', ') .. ' WHERE id = ?',
        values
    )
end

Database.CompleteRental = function(rentalId, damageAmount, fuelConsumed)
    Database.UpdateRental(rentalId, {
        status = 'completed',
        return_time = os.time(),
        damage_amount = damageAmount,
        fuel_consumed = fuelConsumed,
        returned_at = os.date('%Y-%m-%d %H:%M:%S')
    })
end

-- ==================== PLAYER CACHE ====================
Database.UpdatePlayerCache = function(playerId, rentalId, vehicleData)
    local data = json.encode(vehicleData)
    
    MySQL.query.await([[
        INSERT INTO rental_player_cache (player_id, active_rental_id, data)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE active_rental_id = ?, data = ?, updated_at = CURRENT_TIMESTAMP
    ]], {
        playerId,
        rentalId,
        data,
        rentalId,
        data
    })
end

Database.ClearPlayerCache = function(playerId)
    MySQL.update.await(
        'UPDATE rental_player_cache SET active_rental_id = NULL, data = NULL WHERE player_id = ?',
        { playerId }
    )
end

Database.GetPlayerCache = function(playerId)
    local result = MySQL.query.await(
        'SELECT * FROM rental_player_cache WHERE player_id = ?',
        { playerId }
    )
    
    if result and result[1] then
        return {
            rentalId = result[1].active_rental_id,
            data = result[1].data and json.decode(result[1].data) or nil
        }
    end
    
    return nil
end

-- ==================== RENTAL HISTORY ====================
Database.GetPlayerRentalHistory = function(playerId, limit)
    limit = limit or 10
    
    local result = MySQL.query.await(
        'SELECT * FROM rental_rentals WHERE player_id = ? ORDER BY created_at DESC LIMIT ?',
        { playerId, limit }
    )
    
    return result or {}
end

Database.GetRentalByPlate = function(plate)
    local result = MySQL.query.await(
        'SELECT * FROM rental_rentals WHERE rental_plate = ? AND status = ?',
        { plate, 'active' }
    )
    
    return result and result[1] or nil
end

-- ==================== STATISTICS ====================
Database.GetStatistics = function()
    local stats = {}
    
    -- Total rentals
    local totalRentals = MySQL.query.await('SELECT COUNT(*) as count FROM rental_rentals')
    stats.totalRentals = totalRentals[1].count
    
    -- Active rentals
    local activeRentals = MySQL.query.await(
        'SELECT COUNT(*) as count FROM rental_rentals WHERE status = ?',
        { 'active' }
    )
    stats.activeRentals = activeRentals[1].count
    
    -- Revenue
    local revenue = MySQL.query.await(
        'SELECT SUM(rental_cost + insurance) as total FROM rental_rentals WHERE status = ?',
        { 'completed' }
    )
    stats.totalRevenue = revenue[1].total or 0
    
    return stats
end

-- Initialize database on script start
CreateThread(function()
    Wait(1000)
    Database.Init()
end)
