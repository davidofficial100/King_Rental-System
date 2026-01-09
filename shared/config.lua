Config = {}

-- ==================== VERSION & BASIC SETTINGS ====================
Config.Version = '1.0.1'
Config.Debug = true
Config.Language = 'EN'
Config.EnableAdminPanel = true
Config.AdminPermission = 'rental.admin'

-- ==================== SAFETY SETTINGS ====================
Config.SafetyChecks = {
    validatePlayerData = true,
    validateVehicleModel = true,
    validateCoordinates = true,
    validatePrices = true,
    validateRentalDays = true
}

-- ==================== RENTAL LOCATIONS (DYNAMIC) ====================
Config.RentalLocations = {
    {
        id = 'downtown',
        name = 'Downtown Car Rental',
        coords = vector3(427.5, 318.2, 103.2),
        heading = 159.5,
        blipSprite = 227,
        blipColor = 2,
        blipScale = 0.8,
        npcModel = 'a_m_m_business_1',
        npcHeading = 159.5,
        npcScenario = 'WORLD_HUMAN_CLIPBOARD',
        interactionDistance = 5.0,
        returnCoords = vector3(427.5, 318.2, 103.2),
        returnHeading = 159.5,
        enabled = true
    },
    {
        id = 'airport',
        name = 'Los Santos International Airport',
        coords = vector3(-1008.5, -2718.8, 13.9),
        heading = 90.0,
        blipSprite = 227,
        blipColor = 2,
        blipScale = 0.8,
        npcModel = 'a_m_m_business_1',
        npcHeading = 90.0,
        npcScenario = 'WORLD_HUMAN_CLIPBOARD',
        interactionDistance = 5.0,
        returnCoords = vector3(-1008.5, -2718.8, 13.9),
        returnHeading = 90.0,
        enabled = true
    },
    {
        id = 'sandy',
        name = 'Sandy Shores Car Rental',
        coords = vector3(1142.5, 2787.5, 52.3),
        heading = 180.0,
        blipSprite = 227,
        blipColor = 2,
        blipScale = 0.8,
        npcModel = 'a_m_m_business_1',
        npcHeading = 180.0,
        npcScenario = 'WORLD_HUMAN_CLIPBOARD',
        interactionDistance = 5.0,
        returnCoords = vector3(1142.5, 2787.5, 52.3),
        returnHeading = 180.0,
        enabled = true
    }
}

-- ==================== NPC MODELS ====================
Config.AvailableNPCModels = {
    'a_m_m_business_1',
    'a_m_m_business_2',
    'a_f_y_business_1',
    'a_f_y_business_2',
    'a_m_y_business_1',
    'a_m_y_business_2'
}

-- ==================== VEHICLE MODELS ====================
Config.Vehicles = {
    -- Economy
    {
        model = 'dilettante',
        label = 'Dilettante',
        category = 'Economy',
        price = 150,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 400,
        enabled = true
    },
    {
        model = 'issi2',
        label = 'ISSI',
        category = 'Economy',
        price = 160,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 400,
        enabled = true
    },
    {
        model = 'panto',
        label = 'Panto',
        category = 'Economy',
        price = 140,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 380,
        enabled = true
    },
    -- Sedan
    {
        model = 'oracle',
        label = 'Oracle',
        category = 'Sedan',
        price = 250,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 500,
        enabled = true
    },
    {
        model = 'fugitive',
        label = 'Fugitive',
        category = 'Sedan',
        price = 280,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 520,
        enabled = true
    },
    {
        model = 'cognoscenti',
        label = 'Cognoscenti',
        category = 'Sedan',
        price = 350,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 600,
        enabled = true
    },
    -- SUV
    {
        model = 'cavalcade',
        label = 'Cavalcade',
        category = 'SUV',
        price = 400,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 700,
        enabled = true
    },
    {
        model = 'granger',
        label = 'Granger',
        category = 'SUV',
        price = 380,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 680,
        enabled = true
    },
    {
        model = 'baller',
        label = 'Baller',
        category = 'SUV',
        price = 450,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 750,
        enabled = true
    },
    -- Sports
    {
        model = 'jester',
        label = 'Jester',
        category = 'Sports',
        price = 500,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 400,
        enabled = true
    },
    {
        model = 'comet2',
        label = 'Comet',
        category = 'Sports',
        price = 550,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 420,
        enabled = true
    },
    {
        model = 'banshee',
        label = 'Banshee',
        category = 'Sports',
        price = 600,
        maxRentalDays = 30,
        fuel = 100,
        trunk = 400,
        enabled = true
    }
}

-- ==================== RENTAL SETTINGS ====================
Config.RentalDurations = {
    { days = 1, label = '1 Day', multiplier = 1.0 },
    { days = 3, label = '3 Days', multiplier = 0.85 },
    { days = 7, label = '1 Week', multiplier = 0.75 },
    { days = 14, label = '2 Weeks', multiplier = 0.65 },
    { days = 30, label = '1 Month', multiplier = 0.50 }
}

Config.Insurance = {
    enabled = true,
    price = 50,
    coversAllDamage = true
}

Config.DamageDeposit = 500
Config.RentalPlatePrefix = 'RENT'
Config.DefaultFuel = 100
Config.FuelConsumption = 0.5

-- ==================== FINE SETTINGS ====================
Config.Fines = {
    lateReturn = 100,
    vehicleDamage = 250,
    fuelNotReturned = 200
}

-- ==================== UI SETTINGS ====================
Config.UI = {
    enableAnimations = true,
    animationSpeed = 300,
    notificationDuration = 5000,
    theme = 'dark'  -- dark, light
}

-- ==================== DATABASE ====================
Config.Database = {
    host = 'localhost',
    user = 'root',
    password = '',
    database = 'fivem'
}

-- ==================== BLIP SETTINGS ====================
Config.BlipSettings = {
    sprite = 227,
    scale = 0.8,
    color = 2,
    asShortRange = false,
    route = false
}
