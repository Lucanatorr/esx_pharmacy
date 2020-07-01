fx_version 'adamant'

game 'gta5'

name 'ESX Pharmacy'
description 'Pharmacy Shop resource for ESX-based servers'
author 'Lucanatorr'
version '1.0.0'

dependencies {
	'es_extended',
}

server_scripts {
	--'server/version_check.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'server/main.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'client/main.lua',
}
