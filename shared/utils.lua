Utils = {}

-- ==================== LOCALIZATION ====================
local Translations = {
    EN = {
        -- Notifications
        notify_success = 'Success',
        notify_error = 'Error',
        notify_warning = 'Warning',
        notify_info = 'Information',
        
        -- Rental
        rental_available = 'Available for Rent',
        rental_success = 'Vehicle rented successfully',
        rental_failed = 'Rental failed',
        rental_returned = 'Vehicle returned successfully',
        rental_expired = 'Your rental period has expired',
        
        -- Errors
        error_invalid_vehicle = 'Invalid vehicle model',
        error_invalid_duration = 'Invalid rental duration',
        error_insufficient_funds = 'Insufficient funds',
        error_max_rentals = 'Maximum rentals reached',
        error_player_not_found = 'Player not found',
        error_vehicle_spawn_failed = 'Failed to spawn vehicle',
        error_no_active_rental = 'You have no active rental',
        
        -- Commands
        cmd_rentcar = 'Rent a car',
        cmd_returncar = 'Return your rented car',
        cmd_rental_status = 'Check rental status',
        
        -- UI
        ui_rent = 'RENT',
        ui_return = 'RETURN',
        ui_price = 'Price',
        ui_duration = 'Duration',
        ui_total = 'Total',
        ui_damage_deposit = 'Damage Deposit',
        ui_insurance = 'Insurance',
        ui_confirm = 'Confirm Rental',
        ui_cancel = 'Cancel'
    }
}

-- Get translation
function Utils.GetText(key)
    local lang = Config.Language or 'EN'
    local trans = Translations[lang]
    if not trans then
        trans = Translations.EN
    end
    return trans[key] or key
end

-- ==================== NOTIFICATIONS ====================
function Utils.Notify(title, message, type)
    type = type or 'info'
    local notificationType = type:lower()
    
    lib.notify({
        title = title,
        description = message,
        type = notificationType,
        position = 'top-right',
        duration = 5000
    })
end

function Utils.NotifyError(message)
    Utils.Notify(Utils.GetText('notify_error'), message, 'error')
end

function Utils.NotifySuccess(message)
    Utils.Notify(Utils.GetText('notify_success'), message, 'success')
end

function Utils.NotifyWarning(message)
    Utils.Notify(Utils.GetText('notify_warning'), message, 'warning')
end

-- ==================== UTILITY FUNCTIONS ====================
function Utils.GetVehicleByModel(model)
    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.model:lower() == model:lower() then
            return vehicle
        end
    end
    return nil
end

function Utils.GetLocationById(id)
    for _, location in ipairs(Config.RentalLocations) do
        if location.id == id then
            return location
        end
    end
    return nil
end

function Utils.CalculateRentalCost(vehiclePrice, days, hasInsurance)
    local multiplier = 1.0
    for _, duration in ipairs(Config.RentalDurations) do
        if duration.days == days then
            multiplier = duration.multiplier
            break
        end
    end
    
    local baseCost = vehiclePrice * days * multiplier
    local insuranceCost = (hasInsurance and Config.Insurance.price) or 0
    
    return {
        baseCost = math.floor(baseCost),
        insurance = insuranceCost,
        total = math.floor(baseCost + insuranceCost)
    }
end

function Utils.FormatMoney(amount)
    return string.format('$%d', amount)
end

function Utils.LoadModel(model)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    
    local attempts = 0
    while not HasModelLoaded(modelHash) and attempts < 100 do
        Wait(10)
        attempts = attempts + 1
    end
    
    if HasModelLoaded(modelHash) then
        return true
    end
    
    return false
end

function Utils.UnloadModel(model)
    local modelHash = GetHashKey(model)
    if HasModelLoaded(modelHash) then
        RemoveModel(modelHash)
    end
end

function Utils.IsValidVector(vec)
    return vec and type(vec) == 'vector3' and 
           (vec.x ~= 0 or vec.y ~= 0 or vec.z ~= 0)
end

function Utils.GetDistance(coords1, coords2)
    return #(coords1 - coords2)
end

function Utils.RoundUp(num, decimals)
    local mult = 10^(decimals or 0)
    return math.ceil(num * mult) / mult
end

function Utils.SecondsToDays(seconds)
    return math.floor(seconds / 86400)
end

function Utils.SecondsToHours(seconds)
    return math.floor((seconds % 86400) / 3600)
end

function Utils.SecondsToMinutes(seconds)
    return math.floor((seconds % 3600) / 60)
end

-- ==================== DEBUGGING ====================
function Utils.Debug(message, data)
    if Config.Debug then
        print('^5[RENTAL-DEBUG]^7 ' .. message)
        if data then
            print(json.encode(data, { indent = true }))
        end
    end
end

function Utils.Warn(message)
    print('^3[RENTAL-WARN]^7 ' .. message)
end

function Utils.Error(message)
    print('^1[RENTAL-ERROR]^7 ' .. message)
end

function Utils.Success(message)
    print('^2[RENTAL]^7 ' .. message)
end

return Utils
