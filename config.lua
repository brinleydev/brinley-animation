Config = {
    -- If you want to change the key, go to https://docs.fivem.net/docs/game-references/controls/

    -- If you want to change the language, go to
    Language = 'en', -- en, tr
    MultipleAnim = true,

    CustomEmotes = true, -- If you want to use custom emotes (AnimationList.json), set this to true
    
    PersistentExpressions = true, -- If you want to keep the expressions active when u relog, set this to true
    PersistentWalkStyle = true, -- If you want to keep the walk styles active when u relog, set this to true

    -- You can find the list of keys on this website
    -- https://docs.fivem.net/docs/game-references/controls/
    AcceptBind = 246, -- Key to accept the emote (Currently: Y) 
    RefuseBind = 244, -- Key to refuse the emote (Currently: M)

    AnimPos = {
        up = 241, -- UP (Currently: Scroll wheel up)
        down = 242, -- DOWN (Currently: Scroll wheel down)

        left = 174, -- LEFT (Currently: ARROW LEFT)
        right = 175, -- RIGHT (Currently: ARROW RIGHT)

        forward = 172, -- FORWARD (Currently: ARROW UP)
        backward = 173, -- BACKWARD (Currently: ARROW DOWN)

        rotateLeft = 52, -- Rotate Left (Currently: Q)
        rotateRight = 51, -- Rotate tRight (Currently: E)

        followMouse = 47, -- Freeze Mouse Follow (Currently: G)
        done = 191, -- Done (Currently: ENTER)
        cancel = 73, -- Done (Currently: ENTER)

        KeyInfos = {
           {label = 'Right', key = 175},
           {label = 'Left', key = 174},
           {label = 'Backward', key = 173},
           {label = 'Forward', key = 172},
           {label = 'Rotate Right', key = 51},
           {label = 'Rotate Left', key = 52},
           {label = 'Up / Down', key = 348},
           {label = 'Enable/Disable Mouse Follow', key = 47},
           {label = 'Cancel', key = 73},
           {label = 'Done', key = 191},
        }
    },
    

    Categories = {
        {
            id = 'all',
            label = 'All',
            icon = 'fas fa-house',
        },
        {
            id = 'favorites',
            label = 'Favorites',
            icon = 'fas fa-star',
        },
        {
            id = 'emotes',
            label = 'General',
            icon = 'fas fa-male',
        },
        {
            id = 'dances',
            label = 'Dances',
            icon = 'fas fa-running',
        },
        {
            id = 'expressions',
            label = 'Expressions',
            icon = 'fas fa-laugh-beam',
        },
        {
            id = 'walks',
            label = 'Walks',
            icon = 'fas fa-running',
        },
        {
            id = 'custom',
            label = 'Custom Emotes',
            icon = 'fas fa-male',
        },
        {
            id = 'erp',
            label = 'Erotic Animations',
            icon = 'fas fa-venus-mars',
        },
    },
}

Notify = function(msg, type)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true, true)
    
    print('notify', msg)
end

Lang = function(msg)
    return Locales[Config.Language][msg] or 'Translation not found'
end

CreateThread(function()
    RegisterNetEvent('emotes:openMenu', function(bool)
        openMenu(bool)
    end)
    
    RegisterCommand('emotemenu', function()
        openMenu()
    end)
    RegisterKeyMapping('emotemenu', 'Open Emotes Menu', 'keyboard', Config.OpenKey)
    
    RegisterCommand('emotecancel', function()
        onEmoteCancel()
    end)
    RegisterKeyMapping('emotecancel', 'Emote Cancel', 'keyboard', 'X')

    -- Animation commands
    RegisterCommand('walk', function(src, args)
        local emote = args[1]
        if not emote then return end
        local emote = emote:lower()
    
        if emote == 'c' or emote == 'cancel' then
            return onWalkCancel()
        end
    
        for _, animation in pairs(Config.AllAnimations) do
            if animation.id == emote and animation.category == 'walks' then
                return onWalk(animation)
            end
        end
    end)

    TriggerEvent('chat:addSuggestion', '/walk', 'Play a walk.', {
        { name = "walk", help = "Walk name" }
    })

    RegisterCommand('expression', function(src, args)
        local emote = args[1]
        if not emote then return end
        local emote = emote:lower()
    
        if emote == 'c' or emote == 'cancel' then
            return onExpressionCancel()
        end
    
        for _, animation in pairs(Config.AllAnimations) do
            if animation.id == emote and animation.category == 'expressions' then
                return onExpression(animation)
            end
        end
    end)

    TriggerEvent('chat:addSuggestion', '/expression', 'Play an expression.', {
        { name = "expression", help = "Expression name" }
    })
    
    RegisterCommand('e', function(source, args)
        local emote = args[1]
        if not emote then return end
        local emote = emote:lower()
    
        if emote == 'c' or emote == 'cancel' then
            return onEmoteCancel()
        end
    
        for _, animation in pairs(Config.AllAnimations) do
            if animation.id == emote and animation.category ~= 'walks' and animation.category ~= 'expressions' then
               return onAnimTriggered(animation)
            end
        end
    
        print('Animation not found: ' .. emote)
    end)

    TriggerEvent('chat:addSuggestion', '/e', 'Play an emote.', {
        { name = "emote", help = "Emote name" }
    })
end)


RegisterCommand('idlecam', function()
    local ped = PlayerPedId()
    local idleCamDisabled = GetResourceKvpString("idleCam") 
    if idleCamDisabled == nil or idleCamDisabled == "on" then
        DisableIdleCamera(true)
        SetPedCanPlayAmbientAnims(ped, false)
        SetResourceKvp("idleCam", "off")
        Notify('Idle cam is disabled!')
    elseif idleCamDisabled == "off" then
        DisableIdleCamera(false)
        SetPedCanPlayAmbientAnims(ped, true)
        SetResourceKvp("idleCam", "on")
        Notify('Idle cam is enabled!')
    end
end)

Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/idlecam", "Enable/disable the idle cam")
    local idleCamDisabled = GetResourceKvpString("idleCam") == "off"
    DisableIdleCamera(idleCamDisabled)
end)
  
