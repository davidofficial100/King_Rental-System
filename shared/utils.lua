Utils = {}

-- ==================== LOCALIZATION (100% ENGLISH) ====================
local Translations = {
    EN = {
        -- Notifications
        notify_success = 'Success',
        notify_error = 'Error',
        notify_warning = 'Warning',
        notify_info = 'Information',
        
        -- Rental Messages
        rental_available = 'Available for Rent',
        rental_success = 'Vehicle rented successfully',
        rental_failed = 'Rental failed - please try again',
        rental_returned = 'Vehicle returned successfully',
        rental_expired = 'Your rental period has expired',
        
        -- Error Messages
        error_invalid_vehicle = 'Invalid vehicle model selected',
        error_invalid_duration = 'Invalid rental duration selected',
        error_insufficient_funds = 'Insufficient funds for this rental',
        error_max_rentals = 'You have reached the maximum active rentals',
        error_player_not_found = 'Player not found on server',
        error_vehicle_spawn_failed = 'Failed to spawn vehicle - please try again',
        error_no_active_rental = 'You do not have an active rental',
        error_invalid_input = 'Invalid input data provided',
        error_database_error = 'Database operation failed',
        error_location_not_found = 'Rental location not found',
        
        -- Command Messages
        cmd_rentcar = 'Rent a vehicle from the current location',
        cmd_returncar = 'Return your currently rented vehicle',
        cmd_rental_status = 'Check your active rental status',
        cmd_admin_panel = 'Open the rental admin panel',
        
        -- UI Text
        ui_rent = 'RENT VEHICLE',
        ui_return = 'RETURN VEHICLE',
        ui_price = 'Price',
        ui_duration = 'Duration',
        ui_total = 'Total Cost',
        ui_damage_deposit = 'Damage Deposit',
        ui_insurance = 'Vehicle Insurance',
        ui_confirm = 'Confirm Rental',
        ui_cancel = 'Cancel Rental'
    }
}

-- Get translation with safety checks
function Utils.GetText(key)
    if not key or key == '' then
        return 'Unknown message'
    end
    
    local lang = (Config and Config.Language) or 'EN'
    
    if not Translations then
        return key
    end
    
    local trans = Translations[lang]
    if not trans then
        trans = Translations.EN or {}
    end
    
    local text = trans[key] or key
    
    if not text or text == '' then
        return key
    end
    
    return text
end

-- ==================== NOTIFICATIONS (WITH SAFETY CHECKS) ====================
function Utils.Notify(title, message, type)
    if not lib or not lib.notify then
        print('^1[RENTAL-ERROR]^7 ox_lib notify function not available')
        return
    end
    
    if not title or title == '' then
        title = 'Notification'
    end
    
    if not message or message == '' then
        message = 'No message provided'
    end
    
    type = (type and type:lower()) or 'info'
    
    -- Validate notification type
    local validTypes = { info = true, success = true, error = true, warning = true }
    if not validTypes[type] then
        type = 'info'
    end
    
    lib.notify({
        title = title,
        description = message,
        type = type,
        position = 'top-right',
        duration = 5000
    })
end

function Utils.NotifyError(message)
    if not message or message == '' then
        message = 'An error occurred'
    end
    Utils.Notify(Utils.GetText('notify_error'), message, 'error')
end

function Utils.NotifySuccess(message)
    if not message or message == '' then
        message = 'Operation completed successfully'
    end
    Utils.Notify(Utils.GetText('notify_success'), message, 'success')
end

function Utils.NotifyWarning(message)
    if not message or message == '' then
        message = 'Warning message'
    end
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
