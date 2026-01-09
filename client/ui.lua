-- ==================== UI SYSTEM ====================
UISystem = {}

-- ==================== NOTIFICATIONS ====================
function UISystem.Notify(title, message, type)
    lib.notify({
        title = title,
        description = message,
        type = type or 'info',
        position = 'top-right',
        duration = 5000,
        icon = 'fas fa-car',
        iconAnimation = 'pulse'
    })
end

function UISystem.NotifySuccess(message)
    UISystem.Notify('Rental System', message, 'success')
end

function UISystem.NotifyError(message)
    UISystem.Notify('Error', message, 'error')
end

function UISystem.NotifyWarning(message)
    UISystem.Notify('Warning', message, 'warning')
end

function UISystem.NotifyInfo(message)
    UISystem.Notify('Information', message, 'info')
end

-- ==================== DIALOGS ====================
function UISystem.ShowConfirmDialog(title, message)
    return lib.alertDialog({
        header = title,
        content = message,
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Cancel',
            confirm = 'Confirm'
        }
    })
end

function UISystem.ShowInputDialog(title, inputLabel, defaultValue)
    local input = lib.inputDialog(title, {
        { type = 'input', label = inputLabel, description = '', required = true, default = defaultValue or '' }
    })
    
    if input then
        return input[1]
    end
    
    return nil
end

-- ==================== CONTEXT MENUS ====================
function UISystem.RegisterMenu(id, title, options, onSelect)
    lib.registerContext({
        id = id,
        title = title,
        options = options,
        onSelect = onSelect
    })
end

function UISystem.ShowMenu(id)
    lib.showContext(id)
end

-- ==================== PROGRESS BARS ====================
function UISystem.ShowProgress(label, duration, canCancel)
    canCancel = canCancel ~= false
    
    return lib.progressBar({
        duration = duration or 2000,
        label = label,
        useWhileDead = false,
        canCancel = canCancel,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })
end

-- ==================== TEXTUI ====================
function UISystem.ShowTextUI(text, position)
    position = position or 'left'
    
    lib.showTextUI(text, {
        position = position,
        icon = 'fa-solid fa-car',
        style = {
            borderRadius = 10,
            colorBg = 48, 48, 48,
            colorBorder = 31, 195, 113,
            colorText = 255, 255, 255
        }
    })
end

function UISystem.HideTextUI()
    lib.hideTextUI()
end

-- ==================== ADVANCED MENUS ====================
function UISystem.CreateVehicleMenu(location, categories)
    local options = {}
    
    for category, vehicles in pairs(categories) do
        local subOptions = {}
        for _, vehicle in ipairs(vehicles) do
            table.insert(subOptions, {
                label = vehicle.label .. ' - ' .. Utils.FormatMoney(vehicle.price) .. '/day',
                value = vehicle.model,
                args = vehicle,
                icon = 'fa-solid fa-car'
            })
        end
        
        table.insert(options, {
            label = category .. ' (' .. #vehicles .. ')',
            icon = 'fa-solid fa-list',
            submenu = 'rental_vehicles_' .. category,
            args = { category }
        })
    end
    
    -- Also add quick help
    table.insert(options, {
        label = 'Help - How to Rent',
        icon = 'fa-solid fa-question',
        description = 'View rental information',
        disabled = true
    })
    
    return options
end

function UISystem.CreateDurationMenu(vehicle)
    local options = {}
    
    for _, duration in ipairs(Config.RentalDurations) do
        local costData = Utils.CalculateRentalCost(vehicle.price, duration.days, false)
        local costWithInsurance = Utils.CalculateRentalCost(vehicle.price, duration.days, Config.Insurance.enabled)
        
        local description = string.format('Base: %s | With Insurance: %s', 
            Utils.FormatMoney(costData.baseCost),
            Utils.FormatMoney(costWithInsurance.total)
        )
        
        table.insert(options, {
            label = duration.label .. ' - ' .. Utils.FormatMoney(costData.total),
            value = duration.days,
            description = description,
            icon = 'fa-solid fa-calendar',
            args = duration
        })
    end
    
    return options
end

function UISystem.CreateSummaryText(vehicle, days, hasInsurance)
    local costData = Utils.CalculateRentalCost(vehicle.price, days, hasInsurance)
    
    local summary = {
        '~b~RENTAL SUMMARY~s~',
        '',
        'Vehicle: ~g~' .. vehicle.label .. '~s~',
        'Category: ~g~' .. vehicle.category .. '~s~',
        'Duration: ~g~' .. days .. ' day(s)~s~',
        '',
        'Base Price: ' .. Utils.FormatMoney(vehicle.price) .. '/day',
        'Total Days Cost: ~y~' .. Utils.FormatMoney(costData.baseCost) .. '~s~',
        hasInsurance and ('Insurance: ~g~' .. Utils.FormatMoney(costData.insurance) .. '~s~') or 'Insurance: ~r~Not Included~s~',
        '',
        'TOTAL COST: ~g~' .. Utils.FormatMoney(costData.total) .. '~s~',
        '',
        'Damage Deposit: ' .. Utils.FormatMoney(Config.DamageDeposit)
    }
    
    return table.concat(summary, '\n')
end

-- ==================== BLIP UTILITIES ====================
function UISystem.UpdateBlip(blipHandle, color, scale)
    if not blipHandle then return end
    
    if color then
        SetBlipColour(blipHandle, color)
    end
    
    if scale then
        SetBlipScale(blipHandle, scale)
    end
end

function UISystem.RemoveBlip(blipHandle)
    if blipHandle and DoesBlipExist(blipHandle) then
        RemoveBlip(blipHandle)
    end
end

-- ==================== DRAWING TEXT ====================
function UISystem.DrawText2D(x, y, text, scale, color)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale or 0.45, scale or 0.45)
    SetTextColour(color[1] or 255, color[2] or 255, color[3] or 255, color[4] or 255)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

function UISystem.DrawRect(x, y, width, height, r, g, b, a)
    DrawRect(x, y, width, height, r, g, b, a or 100)
end

-- ==================== PHONE STYLE MENU ====================
function UISystem.ShowPhoneMenu(title, options)
    local menuId = 'phone_menu_' .. GetGameTimer()
    
    lib.registerContext({
        id = menuId,
        title = title,
        menu = 'main',
        options = options
    })
    
    lib.showContext(menuId)
end

return UISystem
