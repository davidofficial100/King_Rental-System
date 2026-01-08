# Premium Rental System v2.0.0

A professional, enterprise-grade vehicle rental system for FiveM servers with advanced features, comprehensive database integration, and modern UI.

## 🚀 Features

### Core Features
- **Multi-Location Rental** - 3+ configurable rental locations with NPCs and map blips
- **Vehicle Management** - 11+ vehicles across 4 categories (Economy, Sedan, SUV, Sports)
- **Dynamic Pricing** - Configurable daily rates with rental duration multipliers
- **Insurance System** - Optional damage protection for renters
- **Damage Tracking** - Automatic damage assessment and charge calculation
- **Rental Plates** - Custom rental license plates for easy identification
- **Time-Based Rentals** - Support for 1-30 day rental periods

### Advanced Features
- **Database Integration** - Full MySQL/oxmysql support with persistent data
- **Player Cache System** - Optimized data caching for performance
- **Rental History** - Complete rental history tracking and statistics
- **Admin Commands** - Powerful admin tools for rental management
- **Error Handling** - Comprehensive error handling and validation
- **Fuel Tracking** - Monitor fuel consumption during rentals
- **Late Return Fines** - Automatic charges for overdue rentals
- **Damage Deposit** - Security deposit system for damage protection

### Professional Elements
- **Modern UI** - Beautiful HTML5/CSS3 interface
- **ox_lib Integration** - Advanced notifications and dialogs
- **ox_target Support** - Professional interaction system
- **Localization Ready** - Multi-language support structure
- **Debug Mode** - Comprehensive logging for development
- **Code Documentation** - Well-documented, maintainable code

## 📋 Installation

### Prerequisites
- FiveM Server
- oxmysql resource
- ox_lib resource
- ox_target resource
- MySQL Database

### Step 1: Extract Files
```bash
# Copy the rental-system folder to your resources directory
cp -r rental-system /path/to/your/resources/
```

### Step 2: Database Setup
```bash
# Import the SQL file into your MySQL database
mysql -u root -p your_database < rental.sql
```

### Step 3: Update server.cfg
```cfg
# Add to your server.cfg
ensure oxmysql
ensure ox_lib
ensure ox_target
ensure rental-system
```

### Step 4: Configure Dependencies
Update `/shared/config.lua` with your database credentials:

```lua
Config.Database = {
    host = 'localhost',
    user = 'root',
    password = 'your_password',
    database = 'fivem'
}
```

### Step 5: Start Server
```bash
# Restart your server
# Rental system will auto-initialize on startup
```

## ⚙️ Configuration

### Rental Locations
Edit `/shared/config.lua` to add or modify rental locations:

```lua
Config.RentalLocations = {
    {
        id = 'downtown',
        name = 'Downtown Car Rental',
        coords = vector3(427.5, 318.2, 103.2),
        heading = 159.5,
        npcModel = 'a_m_m_business_1',
        returnCoords = vector3(427.5, 318.2, 103.2),
        -- ... more settings
    }
}
```

### Vehicle Pricing
Customize vehicle prices and categories:

```lua
Config.Vehicles = {
    {
        model = 'dilettante',
        label = 'Dilettante',
        category = 'Economy',
        price = 150,  -- Change this
        maxRentalDays = 30
    }
}
```

### Rental Durations
Modify available rental periods and discounts:

```lua
Config.RentalDurations = {
    { days = 1, label = '1 Day', multiplier = 1.0 },
    { days = 7, label = '1 Week', multiplier = 0.75 },
    -- Add more durations as needed
}
```

### Insurance & Fines
```lua
Config.Insurance = {
    enabled = true,
    price = 50  -- Change insurance price
}

Config.Fines = {
    lateReturn = 100,      -- Per day fine
    vehicleDamage = 250,   -- Damage charge
    fuelNotReturned = 200  -- Fuel charge
}
```

## 🎮 Commands

### Player Commands
```
/rentcar <vehicle> <days> [insurance]
  - Rent a vehicle from current location

/returncar
  - Return your rented vehicle

/rentalstatus
  - Check your current rental status
```

### Admin Commands
```
/adminreturncar <player_id>
  - Force return a player's rental (admin only)

/rentalinfo <player_id>
  - Get rental information for a player (admin only)

/rentalstats
  - View rental system statistics (admin only)
```

## 🔄 How It Works

### Rental Process
1. Player approaches NPC at rental location
2. Opens rental menu via ox_target interaction
3. Selects vehicle category and specific vehicle
4. Chooses rental duration
5. Optionally adds insurance
6. Reviews rental summary and confirms
7. Vehicle spawns in front of location
8. Player receives vehicle keys

### Return Process
1. Player uses `/returncar` command or visits return point
2. System calculates:
   - Damage charges
   - Late return fines
   - Fuel consumption charges
3. Vehicle is deleted
4. Rental marked as completed in database
5. Charges deducted from player

### Expiration
- Rentals auto-expire after rental period ends
- Late return fees apply immediately
- Player receives notification of expiration

## 📊 Database Structure

### Tables
- `rental_rentals` - Main rental records
- `rental_return_points` - Return location data
- `rental_player_cache` - Active rental cache
- `vw_rental_history` - Rental history view
- `vw_rental_stats` - Statistics view

### Sample Queries

Get active rentals:
```sql
SELECT * FROM rental_rentals WHERE status = 'active';
```

Get rental statistics:
```sql
SELECT * FROM vw_rental_stats;
```

Get player's rental history:
```sql
SELECT * FROM vw_rental_history WHERE player_id = 123 ORDER BY created_at DESC;
```

## 🛠️ API/Exports

### Server Events

Rent Vehicle:
```lua
TriggerServerEvent('rental:requestRent', vehicleModel, rentalDays, hasInsurance)
```

Return Vehicle:
```lua
TriggerServerEvent('rental:requestReturn', vehicleData)
```

Check Status:
```lua
TriggerServerEvent('rental:checkStatus')
```

## 📝 File Structure

```
rental-system/
├── fxmanifest.lua              # Resource manifest
├── rental.sql                  # Database schema
├── shared/
│   ├── config.lua              # Configuration file
│   └── utils.lua               # Shared utilities
├── server/
│   ├── main.lua                # Main server logic
│   ├── database.lua            # Database functions
│   └── commands.lua            # Commands
├── client/
│   ├── main.lua                # Main client logic
│   ├── ui.lua                  # UI system
│   ├── interactions.lua        # Interaction system
│   └── threads.lua             # Background threads
└── html/
    ├── index.html              # UI interface
    ├── style.css               # Styling
    └── script.js               # UI logic
```

## 🐛 Troubleshooting

### Vehicles Not Spawning
- Check if vehicle model is valid in GTA5
- Verify player is not in vehicle or too close to wall
- Check server logs for spawn errors

### Database Errors
- Verify oxmysql is running
- Check database credentials in config
- Ensure SQL file was imported correctly

### NPC Not Appearing
- Check if NPC model is valid
- Verify coordinates are accessible in map
- Check for missing dependencies

### Interactions Not Working
- Ensure ox_target is running
- Check if player is in interaction range
- Verify NPC handles are valid

## 📊 Performance Optimization

The system includes several optimizations:
- Player data caching to reduce database queries
- Efficient thread management with proper Wait() calls
- Cleanup threads for entity management
- Optimized queries with proper indexes
- Lazy loading of vehicle models

## 🔐 Security Features

- Server-side validation for all client requests
- Input sanitization and type checking
- Anti-cheat protection for rental prices
- Player identity verification
- Secure plate generation system

## 📈 Statistics & Monitoring

Access real-time statistics:
```lua
local stats = Database.GetStatistics()
-- Returns: totalRentals, activeRentals, totalRevenue
```

## 📄 License

This rental system is provided as-is for use on FiveM servers.

## 🤝 Support

For issues or questions, check the code comments or contact server administrators.

## 📞 Credits

Developed as a professional FiveM resource with advanced features and production-ready code quality.