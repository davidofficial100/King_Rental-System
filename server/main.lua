RentalSystem = {}
local PlayerRentals = {}  -- Cache for active rentals

-- ==================== RENTAL MANAGEMENT ====================
RentalSystem.RentVehicle = function(playerId, vehicleModel, rentalDays, hasInsurance)
    -- Validate player
    local player = GetPlayer(playerId)
    if not player then
        return false, Utils.GetText('error_player_not_found')
    end
    
    -- Validate vehicle
    local vehicleData = Utils.GetVehicleByModel(vehicleModel)
    if not vehicleData then
        return false, Utils.GetText('error_invalid_vehicle')
    end
    
    -- Validate duration
    local durationValid = false
    for _, duration in ipairs(Config.RentalDurations) do
        if duration.days == rentalDays then
            durationValid = true
            break
        end
    end
    
    if not durationValid then
        return false, Utils.GetText('error_invalid_duration')
    end
    
    -- Check if player already has active rental
    local activeRental = Database.GetPlayerActiveRental(playerId)
    if activeRental then
        return false, 'You already have an active rental'
    end
    
    -- Calculate cost
    local costData = Utils.CalculateRentalCost(vehicleData.price, rentalDays, hasInsurance)
    
    -- Check player funds (customize based on your framework)
    -- For now, we'll accept all payments
    if costData.total < 0 then
        return false, Utils.GetText('error_insufficient_funds')
    end
    
    -- Generate plate
    local rentalPlate = RentalSystem.GenerateRentalPlate()
    
    -- Create database record
    local rentalId = Database.CreateRental(playerId, GetPlayerName(playerId), vehicleData, rentalDays, costData.baseCost, hasInsurance, rentalPlate)
    
    if not rentalId then
        return false, 'Failed to create rental record'
    end
    
    -- Store in cache
    PlayerRentals[playerId] = {
        rentalId = rentalId,
        plate = rentalPlate,
        vehicleModel = vehicleModel,
        vehicleLabel = vehicleData.label,
        startTime = os.time(),
        rentalDays = rentalDays,
        totalCost = costData.total
    }
    
    -- Update player cache
    Database.UpdatePlayerCache(playerId, rentalId, PlayerRentals[playerId])
    
    Utils.Success(string.format('Player %s (%d) rented %s for %d days. Plate: %s', GetPlayerName(playerId), playerId, vehicleData.label, rentalDays, rentalPlate))
    
    return true, {
        rentalId = rentalId,
        plate = rentalPlate,
        vehicle = vehicleData,
        days = rentalDays,
        cost = costData
    }
end

RentalSystem.ReturnVehicle = function(playerId, vehicleData)
    -- Get active rental
    local rental = PlayerRentals[playerId] or Database.GetPlayerActiveRental(playerId)
    
    if not rental then
        return false, Utils.GetText('error_no_active_rental')
    end
    
    -- Calculate charges
    local currentTime = os.time()
    local endTime = rental.startTime + (rental.rentalDays * 86400)
    local timeDiff = currentTime - endTime
    local damageCharge = 0
    
    -- Late return fine
    local lateCharge = 0
    if timeDiff > 0 then
        local lateDays = math.ceil(timeDiff / 86400)
        lateCharge = lateDays * Config.Fines.lateReturn
    end
    
    -- Damage fine (from vehicle condition)
    if vehicleData and vehicleData.damage then
        damageCharge = vehicleData.damage
    end
    
    -- Fuel charge
    local fuelCharge = 0
    if vehicleData and vehicleData.fuelUsed then
        fuelCharge = vehicleData.fuelUsed * Config.Fines.fuelNotReturned
    end
    
    local totalCharges = lateCharge + damageCharge + fuelCharge
    
    -- Complete rental
    Database.CompleteRental(rental.rentalId or rental.id, damageCharge, vehicleData and vehicleData.fuelUsed or 0)
    
    -- Clear from cache
    PlayerRentals[playerId] = nil
    Database.ClearPlayerCache(playerId)
    
    Utils.Success(string.format('Player %s (%d) returned %s', GetPlayerName(playerId), playerId, rental.vehicleLabel or rental.vehicle_label))
    
    return true, {
        plate = rental.plate,
        totalCharges = totalCharges,
        breakdown = {
            late = lateCharge,
            damage = damageCharge,
            fuel = fuelCharge
        }
    }
end

RentalSystem.GenerateRentalPlate = function()
    local plate = Config.RentalPlatePrefix .. string.upper(string.format('%05d', math.random(1, 99999)))
    
    -- Check if plate exists
    local existing = Database.GetRentalByPlate(plate)
    if existing then
        return RentalSystem.GenerateRentalPlate()  -- Recursively generate new plate
    end
    
    return plate
end

-- ==================== SYNC METHODS ====================
RentalSystem.GetPlayerRental = function(playerId)
    -- First check cache
    local cached = PlayerRentals[playerId]
    if cached then
        return cached
    end
    
    -- Then check database
    local dbRental = Database.GetPlayerActiveRental(playerId)
    if dbRental then
        PlayerRentals[playerId] = {
            rentalId = dbRental.id,
            plate = dbRental.rental_plate,
            vehicleModel = dbRental.vehicle_model,
            vehicleLabel = dbRental.vehicle_label,
            startTime = dbRental.start_time,
            rentalDays = dbRental.rental_days,
            totalCost = dbRental.rental_cost
        }
        return PlayerRentals[playerId]
    end
    
    return nil
end

RentalSystem.CheckRentalStatus = function(playerId)
    local rental = RentalSystem.GetPlayerRental(playerId)
    if not rental then
        return nil
    end
    
    local currentTime = os.time()
    local endTime = rental.startTime + (rental.rentalDays * 86400)
    local timeRemaining = endTime - currentTime
    
    return {
        plate = rental.plate,
        vehicle = rental.vehicleLabel,
        daysRemaining = Utils.SecondsToDays(timeRemaining),
        hoursRemaining = Utils.SecondsToHours(timeRemaining),
        minutesRemaining = Utils.SecondsToMinutes(timeRemaining),
        isExpired = timeRemaining <= 0
    }
end

-- ==================== EVENTS ====================
RegisterNetEvent('rental:requestRent')
AddEventHandler('rental:requestRent', function(vehicleModel, rentalDays, hasInsurance)
    local playerId = source
    
    local success, result = RentalSystem.RentVehicle(playerId, vehicleModel, rentalDays, hasInsurance)
    
    if success then
        TriggerClientEvent('rental:rentalSuccess', playerId, result)
    else
        TriggerClientEvent('rental:rentalError', playerId, result)
    end
end)

RegisterNetEvent('rental:requestReturn')
AddEventHandler('rental:requestReturn', function(vehicleData)
    local playerId = source
    
    local success, result = RentalSystem.ReturnVehicle(playerId, vehicleData)
    
    if success then
        TriggerClientEvent('rental:returnSuccess', playerId, result)
    else
        TriggerClientEvent('rental:returnError', playerId, result)
    end
end)

RegisterNetEvent('rental:checkStatus')
AddEventHandler('rental:checkStatus', function()
    local playerId = source
    local status = RentalSystem.CheckRentalStatus(playerId)
    
    TriggerClientEvent('rental:statusUpdate', playerId, status)
end)

-- ==================== CLEANUP ====================
AddEventHandler('playerDropped', function()
    local playerId = source
    
    -- Clear from cache
    if PlayerRentals[playerId] then
        PlayerRentals[playerId] = nil
    end
    
    -- Clear from database cache
    Database.ClearPlayerCache(playerId)
end)

-- ==================== INITIALIZATION ====================
print('^2[RENTAL]^7 Server script loaded successfully!')
