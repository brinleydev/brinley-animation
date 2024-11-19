
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

client_scripts {
    "config.lua",
    "locales/*.lua",
    "animations/*.lua",
    "client/*.lua",
}

server_scripts {
    -- "config.lua",
    "locales/*.lua",
    "AnimationList.lua",
    "server/*.lua"
}

ui_page "html/index.html"

files {
    "animations/AnimationList.json",
    
    "html/index.html",
    "html/assets/*.css",
    -- "html/images/*.png",
    "html/images/*.svg",
    "html/images/no-image.png",
    "html/js/*.js",
    "html/fonts/*.otf",
    "html/fonts/*.ttf",
    "html/fonts/*.TTF",
}


escrow_ignore {
    "config.lua",
    "locales/*.lua",
    "animations/*.lua",
}


data_file 'DLC_ITYP_REQUEST' 'stream/taymckenzienz_rpemotes.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brummie_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/apple_1.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/kaykaymods_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/knjgh_pizzas.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/ultra_ringcase.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/pata_props.ytyp'
data_file "DLC_ITYP_REQUEST" "stream/badge1.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/copbadge.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/prideprops_ytyp"
data_file "DLC_ITYP_REQUEST" "stream/lilflags_ytyp"
data_file 'DLC_ITYP_REQUEST' 'stream/natty_props_lollipops.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/bebekbus.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/badge1.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/copbadge.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_foodpack'
data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_prop_torch_fire001.ytyp'

data_file 'DLC_ITYP_REQUEST' 'stream/[Custom Emotes]/*ytyp.'

data_file 'DLC_ITYP_REQUEST' 'stream/[Props]/*ytyp.' 
