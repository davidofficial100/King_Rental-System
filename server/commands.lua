-- ==================== ADMIN COMMANDS ====================

-- Rent vehicle command (for testing/admin)
RegisterCommand('rentcar', function(source, args, rawCommand)
    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'Usage: /rentcar <vehicle> <days> [insurance]' },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local vehicleModel = args[1]
    local rentalDays = tonumber(args[2])
    local hasInsurance = args[3] and string.lower(args[3]) == 'true' or false
    
    if not rentalDays or rentalDays < 1 or rentalDays > 30 then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'Invalid rental days (1-30)' },
            color = { 255, 0, 0 }
        })
        return
    end
    
    TriggerClientEvent('rental:requestRent', source, vehicleModel, rentalDays, hasInsurance)
end, false)

-- Return vehicle command
RegisterCommand('returncar', function(source, args, rawCommand)
    TriggerClientEvent('rental:requestReturn', source, {})
end, false)

-- Check rental status
RegisterCommand('rentalstatus', function(source, args, rawCommand)
    TriggerClientEvent('rental:checkStatus', source)
end, false)

-- Admin: Complete rental (force)
RegisterCommand('adminreturncar', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'command.adminreturncar') then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'No permission' },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local playerId = tonumber(args[1])
    if not playerId then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'Usage: /adminreturncar <player_id>' },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local success, result = RentalSystem.ReturnVehicle(playerId, {})
    
    if success then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'Rental returned for player ' .. playerId },
            color = { 0, 255, 0 }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', result },
            color = { 255, 0, 0 }
        })
    end
end, false)

-- Admin: Get rental info
RegisterCommand('rentalinfo', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'command.rentalinfo') then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'No permission' },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local playerId = tonumber(args[1])
    if not playerId then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'Usage: /rentalinfo <player_id>' },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local rental = RentalSystem.GetPlayerRental(playerId)
    
    if rental then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'Plate: ' .. rental.plate .. ' | Vehicle: ' .. rental.vehicleLabel .. ' | Days: ' .. rental.rentalDays },
            color = { 0, 255, 0 }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'No active rental for player ' .. playerId },
            color = { 255, 0, 0 }
        })
    end
end, false)

-- Admin: Get statistics
RegisterCommand('rentalstats', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'command.rentalstats') then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'RENTAL', 'No permission' },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local stats = Database.GetStatistics()
    
    TriggerClientEvent('chat:addMessage', source, {
        args = { 'RENTAL', 'Total Rentals: ' .. stats.totalRentals .. ' | Active: ' .. stats.activeRentals .. ' | Revenue: $' .. stats.totalRevenue },
        color = { 0, 255, 0 }
    })
end, false)

-- Suggestion system
TriggerEvent('chat:addSuggestion', '/rentcar', 'Rent a vehicle', {
    { name = 'vehicle', help = 'Vehicle model name' },
    { name = 'days', help = 'Number of days' },
    { name = 'insurance', help = 'Add insurance? (true/false)' }
})

TriggerEvent('chat:addSuggestion', '/returncar', 'Return your rented vehicle', {})
TriggerEvent('chat:addSuggestion', '/rentalstatus', 'Check your rental status', {})
TriggerEvent('chat:addSuggestion', '/adminreturncar', 'Force return a rental (admin)', {
    { name = 'player_id', help = 'Player ID' }
})
TriggerEvent('chat:addSuggestion', '/rentalinfo', 'Get rental info (admin)', {
    { name = 'player_id', help = 'Player ID' }
})
TriggerEvent('chat:addSuggestion', '/rentalstats', 'Get rental statistics (admin)', {})

print('^2[RENTAL]^7 Commands loaded successfully!')
