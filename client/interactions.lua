-- ==================== INTERACTION SYSTEM ====================
InteractionSystem = {}

-- ==================== ZONE INTERACTIONS ====================
local interactionZones = {}

function InteractionSystem.CreateZone(id, coords, size, label, callback)
    local zone = lib.zones.box({
        coords = coords,
        size = size,
        debug = Config.Debug,
        inside = function()
            -- Show textui when inside zone
            lib.showTextUI('[E] ' .. label, {
                position = 'left-center',
                icon = 'fa-solid fa-car'
            })
        end,
        onExit = function()
            lib.hideTextUI()
        }
    })
    
    interactionZones[id] = {
        zone = zone,
        callback = callback,
        label = label
    }
    
    return zone
end

function InteractionSystem.RemoveZone(id)
    if interactionZones[id] then
        interactionZones[id].zone:remove()
        interactionZones[id] = nil
    end
end

-- ==================== TARGETING ====================
function InteractionSystem.AddEntityTarget(entity, options)
    if not exports.ox_target then
        Utils.Warn('ox_target not loaded')
        return
    end
    
    exports.ox_target:addLocalEntity(entity, options)
end

function InteractionSystem.AddModelTarget(model, options)
    if not exports.ox_target then
        Utils.Warn('ox_target not loaded')
        return
    end
    
    exports.ox_target:addModel(model, options)
end

-- ==================== DISTANCE CHECKS ====================
function InteractionSystem.GetNearestLocation(maxDistance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestLocation = nil
    local nearestDistance = maxDistance or 100
    
    for _, location in ipairs(Config.RentalLocations) do
        local distance = Utils.GetDistance(playerCoords, location.coords)
        
        if distance < nearestDistance then
            nearestDistance = distance
            nearestLocation = location
        end
    end
    
    return nearestLocation, nearestDistance
end

function InteractionSystem.GetNearbyLocations(maxDistance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local locations = {}
    
    for _, location in ipairs(Config.RentalLocations) do
        local distance = Utils.GetDistance(playerCoords, location.coords)
        
        if distance <= maxDistance then
            table.insert(locations, {
                location = location,
                distance = distance
            })
        end
    end
    
    -- Sort by distance
    table.sort(locations, function(a, b)
        return a.distance < b.distance
    end)
    
    return locations
end

-- ==================== MARKERS ====================
function InteractionSystem.DrawMarker(coords, scale, color, rotation)
    rotation = rotation or vector3(0, 0, 0)
    color = color or { r = 0, g = 255, b = 0, a = 100 }
    
    DrawMarker(
        1,  -- Marker type
        coords.x, coords.y, coords.z,
        rotation.x, rotation.y, rotation.z,
        0.0, 0.0, 0.0,
        scale or 1.0,
        color.r, color.g, color.b, color.a,
        false, false, 2, false, nil, nil, false
    )
end

function InteractionSystem.DrawMarkerLoop(id, coords, scale, color)
    local thread = CreateThread(function()
        while true do
            Wait(0)
            if not GetEntityCoords(PlayerPedId()) then break end
            
            InteractionSystem.DrawMarker(coords, scale, color)
        end
    end)
    
    return thread
end

-- ==================== BLIP INTERACTIONS ====================
function InteractionSystem.CreateBlip(coords, sprite, color, scale, name)
    local blip = AddBlipForCoord(coords)
    
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, false)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- ==================== NOTIFICATION INTERACTIONS ====================
function InteractionSystem.ShowActionMenu(location)
    local options = {}
    
    -- Check if player has active rental
    local hasActiveRental = ClientState.activeRental ~= nil
    
    table.insert(options, {
        label = 'Rent Vehicle',
        icon = 'fa-solid fa-car',
        onSelect = function()
            SelectVehicle(nil)  -- Will open vehicle selection
        end
    })
    
    if hasActiveRental then
        table.insert(options, {
            label = 'Return Vehicle',
            icon = 'fa-solid fa-undo',
            description = 'Return your current rental',
            onSelect = function()
                TriggerServerEvent('rental:requestReturn', {
                    damage = 0,
                    fuelUsed = 0
                })
            end
        })
    end
    
    table.insert(options, {
        label = 'Check Rental Status',
        icon = 'fa-solid fa-info',
        onSelect = function()
            TriggerServerEvent('rental:checkStatus')
        end
    })
    
    table.insert(options, {
        label = 'Available Vehicles',
        icon = 'fa-solid fa-list',
        description = 'View all rentable vehicles',
        onSelect = function()
            DisplayAvailableVehicles()
        end
    })
    
    lib.registerContext({
        id = 'rental_action_menu_' .. location.id,
        title = location.name,
        options = options
    })
    
    lib.showContext('rental_action_menu_' .. location.id)
end

function DisplayAvailableVehicles()
    local categories = {}
    
    for _, vehicle in ipairs(Config.Vehicles) do
        if not categories[vehicle.category] then
            categories[vehicle.category] = {}
        end
        table.insert(categories[vehicle.category], vehicle)
    end
    
    local options = {}
    
    for category, vehicles in pairs(categories) do
        local vehicleCount = #vehicles
        
        table.insert(options, {
            label = category .. ' (' .. vehicleCount .. ')',
            icon = 'fa-solid fa-list',
            description = 'Available vehicles in this category'
        })
        
        for _, vehicle in ipairs(vehicles) do
            table.insert(options, {
                label = '  ' .. vehicle.label,
                description = Utils.FormatMoney(vehicle.price) .. '/day',
                icon = 'fa-solid fa-car'
            })
        end
    end
    
    lib.registerContext({
        id = 'available_vehicles_list',
        title = 'Available Vehicles',
        options = options
    })
    
    lib.showContext('available_vehicles_list')
end

-- ==================== KEY BINDS ====================
function InteractionSystem.RegisterKeyBind(key, label, callback)
    RegisterKeyMapping(key, label, 'keyboard', 'E')
    RegisterCommand('+rental_' .. key, callback)
    RegisterCommand('-rental_' .. key, function() end)
end

-- ==================== ENTITY UTILITIES ====================
function InteractionSystem.GetVehicleAtCoords(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    local nearestVehicle = nil
    local nearestDistance = radius or 10
    
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = Utils.GetDistance(coords, vehicleCoords)
            
            if distance < nearestDistance then
                nearestDistance = distance
                nearestVehicle = vehicle
            end
        end
    end
    
    return nearestVehicle, nearestDistance
end

-- ==================== PROMPT SYSTEM ====================
function InteractionSystem.ShowPrompt(message, duration)
    duration = duration or 5000
    
    lib.notify({
        title = 'Prompt',
        description = message,
        type = 'info',
        duration = duration,
        position = 'center-bottom'
    })
end

return InteractionSystem
