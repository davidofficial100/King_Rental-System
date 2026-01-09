-- ==================== CLIENT STATE ====================
local ClientState = {
    activeRental = nil,
    spawnedVehicle = nil,
    npcHandles = {},
    blipHandles = {},
    inRentalZone = false,
    currentLocation = nil
}

-- ==================== INITIALIZATION ====================
CreateThread(function()
    Wait(1000)
    
    -- Verify dependencies
    if not Config or not Config.RentalLocations then
        print('^1[RENTAL-ERROR]^7 Config not loaded properly!')
        return
    end
    
    if not Utils or not Utils.Success then
        print('^1[RENTAL-ERROR]^7 Utils not loaded properly!')
        return
    end
    
    -- Load all rental locations
    if Config.RentalLocations and #Config.RentalLocations > 0 then
        InitializeRentalLocations()
    else
        print('^3[RENTAL-WARN]^7 No rental locations configured!')
    end
    
    -- Load persisted rental data from server
    TriggerServerEvent('rental:checkStatus')
    
    Utils.Success('Client rental system initialized successfully')
end)

-- ==================== LOAD RENTAL LOCATIONS ====================
function InitializeRentalLocations()
    for _, location in ipairs(Config.RentalLocations) do
        -- Create blip
        CreateLocationBlip(location)
        
        -- Spawn NPC
        SpawnLocationNPC(location)
        
        -- Setup target interaction
        SetupLocationTarget(location)
    end
    
    Utils.Debug('Loaded ' .. #Config.RentalLocations .. ' rental locations')
end

-- ==================== CREATE BLIPS ====================
function CreateLocationBlip(location)
    if not Utils.IsValidVector(location.coords) then
        Utils.Error('Invalid coordinates for location: ' .. location.name)
        return
    end
    
    local blip = AddBlipForCoord(location.coords)
    
    SetBlipSprite(blip, location.blipSprite)
    SetBlipColour(blip, location.blipColor)
    SetBlipScale(blip, location.blipScale)
    SetBlipAsShortRange(blip, false)
    SetBlipRoute(blip, false)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(location.name)
    EndTextCommandSetBlipName(blip)
    
    -- Add blip to cache
    ClientState.blipHandles[location.id] = blip
    
    Utils.Debug('Created blip for: ' .. location.name)
end

-- ==================== SPAWN NPCs ====================
function SpawnLocationNPC(location)
    if not location then
        Utils.Error('Invalid location data for NPC spawn')
        return
    end
    
    if not location.npcModel or location.npcModel == '' then
        Utils.Error('Invalid NPC model for location: ' .. (location.name or 'Unknown'))
        return
    end
    
    if not Utils.LoadModel(location.npcModel) then
        Utils.Error('Failed to load NPC model: ' .. location.npcModel)
        return
    end
    
    if not location.coords or not location.coords.x then
        Utils.Error('Invalid coordinates for location: ' .. location.name)
        return
    end
    
    local npc = CreatePed(4, GetHashKey(location.npcModel), location.coords.x, location.coords.y, location.coords.z, location.npcHeading or 0.0, true, false)
    
    if not npc or npc == 0 then
        Utils.Error('Failed to spawn NPC at ' .. (location.name or 'Unknown'))
        return
    end
    
    -- Verify NPC created
    if not DoesEntityExist(npc) then
        Utils.Error('NPC entity does not exist after creation')
        return
    end
    
    -- Setup NPC safely
    if npc and DoesEntityExist(npc) then
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        
        -- Start scenario safely
        if location.npcScenario and location.npcScenario ~= '' then
            TaskStartScenarioInPlace(npc, location.npcScenario, 0, true)
        end
    end
    
    -- Add to cache
    if location.id then
        location.npcHandle = npc
        ClientState.npcHandles[location.id] = npc
    end
    
    Utils.Debug('Spawned NPC at: ' .. (location.name or 'Unknown'))
end

-- ==================== SETUP INTERACTIONS ====================
function SetupLocationTarget(location)
    if not location.npcHandle then return end
    
    exports.ox_target:addLocalEntity(location.npcHandle, {
        {
            name = 'rental_' .. location.id,
            icon = 'fa-solid fa-car',
            label = 'Rent Vehicle',
            distance = location.interactionDistance,
            onSelect = function(data)
                OpenRentalMenu(location)
            end
        }
    })
end

-- ==================== RENTAL MENU ====================
function OpenRentalMenu(location)
    ClientState.currentLocation = location
    
    -- Group vehicles by category
    local categories = {}
    for _, vehicle in ipairs(Config.Vehicles) do
        if not categories[vehicle.category] then
            categories[vehicle.category] = {}
        end
        table.insert(categories[vehicle.category], vehicle)
    end
    
    -- Create menu options
    local menuItems = {}
    
    for category, vehicles in pairs(categories) do
        local options = {}
        for _, vehicle in ipairs(vehicles) do
            table.insert(options, {
                label = vehicle.label .. ' - $' .. vehicle.price .. '/day',
                value = vehicle.model,
                icon = 'fa-solid fa-car'
            })
        end
        
        table.insert(menuItems, {
            label = category,
            icon = 'fa-solid fa-list',
            submenu = 'rental_vehicles_' .. category,
            args = { category }
        })
    end
    
    -- Open context menu
    lib.registerContext({
        id = 'rental_main_menu',
        title = 'Vehicle Rental - ' .. location.name,
        options = menuItems
    })
    
    lib.showContext('rental_main_menu')
end

-- ==================== SELECT VEHICLE ====================
function SelectVehicle(vehicleModel)
    local vehicle = Utils.GetVehicleByModel(vehicleModel)
    if not vehicle then
        Utils.NotifyError('Vehicle not found')
        return
    end
    
    SelectRentalDuration(vehicle)
end

-- ==================== SELECT DURATION ====================
function SelectRentalDuration(vehicle)
    local durationOptions = {}
    
    for _, duration in ipairs(Config.RentalDurations) do
        local costData = Utils.CalculateRentalCost(vehicle.price, duration.days, false)
        
        table.insert(durationOptions, {
            label = duration.label .. ' - ' .. Utils.FormatMoney(costData.baseCost),
            value = duration.days,
            icon = 'fa-solid fa-calendar'
        })
    end
    
    -- Add insurance option info
    local insuranceInfo = Config.Insurance.enabled and Utils.FormatMoney(Config.Insurance.price) or 'N/A'
    
    lib.registerContext({
        id = 'rental_duration_menu',
        title = vehicle.label .. ' - Select Duration',
        options = durationOptions,
        onSelect = function(selected)
            local durationDays = selected.value
            SelectInsurance(vehicle, durationDays)
        end
    })
    
    lib.showContext('rental_duration_menu')
end

-- ==================== SELECT INSURANCE ====================
function SelectInsurance(vehicle, rentalDays)
    if not Config.Insurance.enabled then
        ConfirmRental(vehicle, rentalDays, false)
        return
    end
    
    local costData = Utils.CalculateRentalCost(vehicle.price, rentalDays, false)
    local costWithInsurance = Utils.CalculateRentalCost(vehicle.price, rentalDays, true)
    
    lib.registerContext({
        id = 'rental_insurance_menu',
        title = 'Insurance Option',
        options = {
            {
                label = 'Without Insurance - ' .. Utils.FormatMoney(costData.total),
                value = false,
                icon = 'fa-solid fa-x'
            },
            {
                label = 'With Insurance (+' .. Utils.FormatMoney(costWithInsurance.insurance) .. ') - ' .. Utils.FormatMoney(costWithInsurance.total),
                value = true,
                icon = 'fa-solid fa-check'
            }
        },
        onSelect = function(selected)
            ConfirmRental(vehicle, rentalDays, selected.value)
        end
    })
    
    lib.showContext('rental_insurance_menu')
end

-- ==================== CONFIRM RENTAL ====================
function ConfirmRental(vehicle, rentalDays, hasInsurance)
    local costData = Utils.CalculateRentalCost(vehicle.price, rentalDays, hasInsurance)
    
    local alert = lib.alertDialog({
        header = 'Confirm Rental',
        content = 'Vehicle: ' .. vehicle.label .. '\nDays: ' .. rentalDays .. '\nBase Cost: ' .. Utils.FormatMoney(costData.baseCost) .. '\nInsurance: ' .. Utils.FormatMoney(costData.insurance) .. '\n\nTotal Cost: ' .. Utils.FormatMoney(costData.total),
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Cancel',
            confirm = 'Rent Vehicle'
        }
    })
    
    if alert == 'confirm' then
        RequestRental(vehicle, rentalDays, hasInsurance)
    end
end

-- ==================== REQUEST RENTAL ====================
function RequestRental(vehicle, rentalDays, hasInsurance)
    -- Show loading indicator
    lib.progressBar({
        duration = 2000,
        label = 'Processing rental...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })
    
    -- Send request to server
    TriggerServerEvent('rental:requestRent', vehicle.model, rentalDays, hasInsurance)
end

-- ==================== EVENT HANDLERS ====================
RegisterNetEvent('rental:rentalSuccess')
AddEventHandler('rental:rentalSuccess', function(rentalData)
    ClientState.activeRental = rentalData
    
    Utils.NotifySuccess('Vehicle rented successfully!')
    Utils.NotifySuccess('Plate: ' .. rentalData.plate)
    
    -- Spawn vehicle in client
    SpawnRentalVehicle(rentalData)
end)

RegisterNetEvent('rental:rentalError')
AddEventHandler('rental:rentalError', function(errorMessage)
    Utils.NotifyError(errorMessage)
end)

RegisterNetEvent('rental:returnSuccess')
AddEventHandler('rental:returnSuccess', function(returnData)
    ClientState.activeRental = nil
    
    if ClientState.spawnedVehicle and DoesEntityExist(ClientState.spawnedVehicle) then
        DeleteEntity(ClientState.spawnedVehicle)
        ClientState.spawnedVehicle = nil
    end
    
    Utils.NotifySuccess('Vehicle returned successfully!')
    
    if returnData.totalCharges > 0 then
        Utils.NotifyWarning('Total Charges: ' .. Utils.FormatMoney(returnData.totalCharges))
    end
end)

RegisterNetEvent('rental:returnError')
AddEventHandler('rental:returnError', function(errorMessage)
    Utils.NotifyError(errorMessage)
end)

RegisterNetEvent('rental:statusUpdate')
AddEventHandler('rental:statusUpdate', function(status)
    if status then
        local timeStr = string.format('%d days, %d hours, %d minutes', status.daysRemaining, status.hoursRemaining, status.minutesRemaining)
        Utils.NotifySuccess('Active Rental: ' .. status.vehicle .. '\nTime Remaining: ' .. timeStr)
    else
        Utils.NotifyInfo('No active rental')
    end
end)

-- ==================== SPAWN RENTAL VEHICLE ====================
function SpawnRentalVehicle(rentalData)
    if not Utils.LoadModel(rentalData.vehicle.model) then
        Utils.NotifyError('Failed to load vehicle model')
        return
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local location = ClientState.currentLocation
    
    if location then
        playerCoords = location.coords + vector3(0, 0, 0.5)
    end
    
    local vehicle = CreateVehicle(GetHashKey(rentalData.vehicle.model), playerCoords.x, playerCoords.y, playerCoords.z, 0.0, true, false)
    
    if vehicle == 0 then
        Utils.NotifyError('Failed to spawn vehicle')
        return
    end
    
    -- Setup vehicle
    SetVehicleOnGroundProperly(vehicle, true)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleFuelLevel(vehicle, Config.DefaultFuel + 0.0)
    SetVehicleNumberPlateText(vehicle, rentalData.plate)
    
    -- Give keys
    GivePlayerKeys(vehicle)
    
    -- Store reference
    ClientState.spawnedVehicle = vehicle
    
    -- Warp player in
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    
    Utils.Debug('Spawned vehicle: ' .. rentalData.vehicle.label)
end

-- ==================== GIVE KEYS ====================
function GivePlayerKeys(vehicle)
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
end

print('^2[RENTAL]^7 Client script loaded successfully!')
