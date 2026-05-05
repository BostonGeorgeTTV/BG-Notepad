fx_version 'cerulean'
game 'gta5'

author 'BostonGeorgeTTV'
version '1.0.0'

--use_fxv2_oal 'yes'
lua54        'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    'shared/*.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/css/reset.css',
    'web/css/style.css',
    'web/js/app.js',
    'web/*.png'
}
