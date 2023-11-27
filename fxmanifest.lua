fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'rsg-questsystem'
version '1.0.1'

client_scripts {
    'client/client.lua',
	'client/npc.lua',
	'client/menu.lua'
}

server_scripts {
    'server/server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@rsg-core/shared/locale.lua',
    'locales/en.lua', -- preferred language
    'config.lua',
}

dependencies {
    'rsg-core',
    'ox_lib',
}

lua54 'yes'
