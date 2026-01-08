Config = {}

-- Rental Locations Configuration
Config.RentalLocations = {
    {
        name = 'Downtown Rental',
        coords = vector3(427.5, 318.2, 103.2),
        heading = 159.5,
        blipColor = 2,
        blipScale = 0.8,
        npcModel = 'a_m_m_business_1',
        npcHeading = 159.5,
        rentalDistanceRadius = 5.0
    },
    {
        name = 'Airport Rental',
        coords = vector3(-1008.5, -2718.8, 13.9),
        heading = 90.0,
        blipColor = 2,
        blipScale = 0.8,
        npcModel = 'a_m_m_business_1',
        npcHeading = 90.0,
        rentalDistanceRadius = 5.0
    },
    {
        name = 'Sandy Shores Rental',
        coords = vector3(1142.5, 2787.5, 52.3),
        heading = 180.0,
        blipColor = 2,
        blipScale = 0.8,
        npcModel = 'a_m_m_business_1',
        npcHeading = 180.0,
        rentalDistanceRadius = 5.0
    }
}

-- Available Rental Vehicles
Config.RentalVehicles = {
    -- Economy Cars
    {
        model = 'dilettante',
        label = 'Dilettante',
        pricePerDay = 150,
        category = 'Economy'
    },
    {
        model = 'issi2',
        label = 'ISSI',
        pricePerDay = 160,
        category = 'Economy'
    },
    {
        model = 'panto',
        label = 'Panto',
        pricePerDay = 140,
        category = 'Economy'
    },
    -- Sedan
    {
        model = 'oracle',
        label = 'Oracle',
        pricePerDay = 250,
        category = 'Sedan'
    },
    {
        model = 'fugitive',
        label = 'Fugitive',
        pricePerDay = 280,
        category = 'Sedan'
    },
    {
        model = 'cognoscenti',
        label = 'Cognoscenti',
        pricePerDay = 350,
        category = 'Sedan'
    },
    -- SUV
    {
        model = 'cavalcade',
        label = 'Cavalcade',
        pricePerDay = 400,
        category = 'SUV'
    },
    {
        model = 'granger',
        label = 'Granger',
        pricePerDay = 380,
        category = 'SUV'
    },
    {
        model = 'baller',
        label = 'Baller',
        pricePerDay = 450,
        category = 'SUV'
    },
    -- Sports
    {
        model = 'jester',
        label = 'Jester',
        pricePerDay = 500,
        category = 'Sports'
    },
    {
        model = 'comet2',
        label = 'Comet',
        pricePerDay = 550,
        category = 'Sports'
    },
    {
        model = 'banshee',
        label = 'Banshee',
        pricePerDay = 600,
        category = 'Sports'
    }
}

-- Rental Duration Options (in days)
Config.RentalDurations = {
    { days = 1, multiplier = 1.0 },
    { days = 3, multiplier = 0.85 },
    { days = 7, multiplier = 0.75 },
    { days = 14, multiplier = 0.65 },
    { days = 30, multiplier = 0.50 }
}

-- Damage Deposit
Config.DamageDeposit = 500  -- Fixed deposit amount

-- Rental Plate Prefix
Config.RentalPlatePrefix = 'RENT'

-- Fuel settings
Config.DefaultFuel = 100  -- Starting fuel percentage

-- Blip Settings
Config.BlipSprite = 227  -- Car rental icon
Config.BlipDisplay = 4
Config.BlipScale = 0.7
Config.BlipAsShortRange = false
