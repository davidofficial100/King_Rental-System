fx_version 'cerulean'
game 'gta5'

author 'King Developmen'
description 'Professional Vehicle Rental System with Advanced Features'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/utils.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/main.lua',
    'server/commands.lua'
}

client_scripts {
    'client/main.lua',
    'client/ui.lua',
    'client/interactions.lua',
    'client/threads.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql'
}

lua54 'yes'
