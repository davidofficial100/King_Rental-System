-- ==================== BACKGROUND THREADS ====================

-- Monitor active rental
CreateThread(function()
    while true do
        Wait(1000)
        
        if ClientState.activeRental and ClientState.spawnedVehicle and DoesEntityExist(ClientState.spawnedVehicle) then
            local vehicle = ClientState.spawnedVehicle
            local playerPed = PlayerPedId()
            
            -- Check vehicle damage
            local engineHealth = GetVehicleEngineHealth(vehicle)
            local bodyHealth = GetVehicleBodyHealth(vehicle)
            local deformationDamage = 0
            
            -- Calculate deformation damage
            if engineHealth < 900 then
                deformationDamage = math.floor((1000 - engineHealth) / 10)
            end
            
            if bodyHealth < 900 then
                deformationDamage = deformationDamage + math.floor((1000 - bodyHealth) / 10)
            end
            
            -- Check fuel
            local fuelLevel = GetVehicleFuelLevel(vehicle)
            
            -- Update vehicle state
            ClientState.activeRental.damage = deformationDamage
            ClientState.activeRental.fuel = fuelLevel
        end
    end
end)

-- Monitor rental expiration
CreateThread(function()
    while true do
        Wait(60000)  -- Check every minute
        
        if ClientState.activeRental then
            TriggerServerEvent('rental:checkStatus')
        end
    end
end)

-- Cleanup thread
CreateThread(function()
    while true do
        Wait(5000)
        
        -- Check if vehicle was deleted
        if ClientState.spawnedVehicle and not DoesEntityExist(ClientState.spawnedVehicle) then
            ClientState.spawnedVehicle = nil
        end
        
        -- Check NPC validity
        for id, npcHandle in pairs(ClientState.npcHandles) do
            if not DoesEntityExist(npcHandle) then
                ClientState.npcHandles[id] = nil
            end
        end
        
        -- Check blip validity
        for id, blipHandle in pairs(ClientState.blipHandles) do
            if not DoesBlipExist(blipHandle) then
                ClientState.blipHandles[id] = nil
            end
        end
    end
end)

-- Return vehicle on exit rental zone
CreateThread(function()
    while true do
        Wait(1000)
        
        if ClientState.activeRental and ClientState.spawnedVehicle and DoesEntityExist(ClientState.spawnedVehicle) then
            local vehicle = ClientState.spawnedVehicle
            local vehicleCoords = GetEntityCoords(vehicle)
            local location = ClientState.currentLocation
            
            if location then
                local distance = Utils.GetDistance(vehicleCoords, location.returnCoords)
                
                -- If too far from return point, show warning
                if distance > 500 then
                    if not ClientState.farFromReturnWarning then
                        Utils.NotifyWarning('You are far from the rental return point!')
                        ClientState.farFromReturnWarning = true
                    end
                else
                    ClientState.farFromReturnWarning = false
                end
            end
        end
    end
end)

-- Sync status periodically
CreateThread(function()
    while true do
        Wait(300000)  -- Every 5 minutes
        
        -- Force sync with server
        TriggerServerEvent('rental:checkStatus')
    end
end)

-- Handle script reload
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Cleanup
        if ClientState.spawnedVehicle and DoesEntityExist(ClientState.spawnedVehicle) then
            DeleteEntity(ClientState.spawnedVehicle)
        end
        
        -- Remove blips
        for _, blipHandle in pairs(ClientState.blipHandles) do
            if DoesBlipExist(blipHandle) then
                RemoveBlip(blipHandle)
            end
        end
        
        -- Remove NPCs
        for _, npcHandle in pairs(ClientState.npcHandles) do
            if DoesEntityExist(npcHandle) then
                DeleteEntity(npcHandle)
            end
        end
        
        Utils.Success('Rental system cleaned up')
    end
end)

-- Handle resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Utils.Success('Rental system started')
    end
end)

print('^2[RENTAL]^7 Threads initialized')
