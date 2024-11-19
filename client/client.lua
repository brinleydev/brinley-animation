local menuState = false
local jsLoaded = false
local shortcuts = {}

function openMenu(bool)
    menuState = bool or not menuState
    SetNuiFocus(menuState, menuState)
    SendNUIMessage({
        action = "open",
        state = menuState,
    })
end

RegisterNUICallback('close', function(data, cb)
    openMenu(false)
    cb('ok')
end)

RegisterNUICallback('jsLoaded', function(data, cb)
    jsLoaded = true
    cb('ok')
end)

CreateThread(function()
    local getAnimationList = function()
        local file = LoadResourceFile(GetCurrentResourceName(), 'animations/AnimationList.json')
        if file == nil or file == '' then
            return {}
        end

        return json.decode(file)
    end

    while not jsLoaded do
        print('Emotes: Waiting for JS to load')
        Wait(100)
    end

    Config.AllAnimations = {}
    -- Config.TestAnimations = {}
    print('Emotes: Loading')
    for _, category in pairs(Config.Categories) do
        if Config.Animations[category.id] then
            for _, animation in pairs(Config.Animations[category.id]) do
                if animation.dict and animation.dict ~= '' and not DoesAnimDictExist(animation.dict) then
                    print('Emotes: Not found: ' .. animation.dict)
                end

                if not animation.label and animation.category == 'dances' then
                    animation.label = ('%s %s'):format('Dance', _)
                end
                if not animation.id then
                    animation.id = ('%s_%s'):format(animation.category, _)
                    if animation.category == 'walks' then
                        animation.gif = ('%s.webp'):format(animation.id)
                    end
                end
                table.insert(Config.AllAnimations, animation)

                -- if animation.anim and animation.dict then
                --     Config.TestAnimations[animation.dict.. '-'..animation.anim] = animation
                -- end
            end
        end
    end

    if Config.CustomEmotes then
        local list = getAnimationList()
        for k, v in pairs(list) do
            for _, animation in pairs(v) do
                if animation.dict and animation.dict ~= '' and not DoesAnimDictExist(animation.dict) then
                    print('Emotes: Not found: ' .. animation.dict)
                end
                table.insert(Config.AllAnimations, animation)
            end
        end
    end

    SendNUIMessage({
        action = "load",
        animations = Config.AllAnimations,
        categories = Config.Categories,

        locales = Locales[Config.Language],
    })
    print('Emotes: Loaded')
end)

RegisterNUICallback('stopAnim', function(data, cb)
    onEmoteCancel()
    cb('ok')
end)

RegisterNUICallback('onAnimClicked', function(data, cb)
    print('onAnimClicked', data.animation)
    onAnimTriggered(data.animation)
    cb('ok')
end)

RegisterNUICallback('getShortcuts', function(data, cb)
    print('getShortcuts', json.encode(data))
    shortcuts = data.shortcuts
    cb('ok')
end)

CreateThread(function()
    local shiftPressed = false
    RegisterKeyMapping('+emote_shortcut', 'Emote Shortcut Bind', 'keyboard', 'LSHIFT')
    RegisterCommand('+emote_shortcut', function()
        shiftPressed = true
    end)
    RegisterCommand('-emote_shortcut', function()
        shiftPressed = false
    end)

    for i = 1, 7 do
        RegisterCommand('emote_shortcut_' .. i, function(source, args)
            -- if emote == 'c' or emote == 'cancel' then
            --     return onEmoteCancel()
            -- end
            if not shiftPressed then
                return print('Shift is not pressed', i)
            end

            local shortcut = shortcuts[i]
            print(120, shortcut and json.encode(shortcut))
            if shortcut and next(shortcut) and shortcut.id then
                for _, animation in pairs(Config.AllAnimations) do
                    if animation.id == shortcuts[i].id then
                        return onAnimTriggered(animation)
                    end
                end
            end
            print('Animation not found: ', shortcut)
        end)

        RegisterKeyMapping('emote_shortcut_' .. i, 'Emote Shortcut ' .. i, 'keyboard',  i)
    end
end)
-- {
--     'id': 1,
--     'timeout': 59999,
--     'title': 'Error',
--     'text': 'Invited Hug 3 animation ',
--     'description': 'Do u want to accept?',
--     'type': 'invite',
--     'anim': {
--         'id': 'beasst',
--         // 'gif': 'beast.webp',
--         'label': 'beast',
--     }
-- },
-- {
--     'id': 2,
--     'timeout': 55555,
--     'title': 'Error',
--     'text': 'Animation removed from favoritesasdddddddddasddasasdasdasdads',
--     'type': 'notification',
-- },

-- RegisterCommand('invite', function()
--     sendNotification({
--         timeout = 5,
--         title = 'Error',
--         text = 'Invited Hug 3 animation ',
--         description = 'Do u want to accept?',
--         type = 'invite',
--         anim = {
--             id = 'beasst',
--             -- gif = 'beast.webp',
--             label = 'beast',
--         }
--     })
-- end)

-- RegisterCommand('notif', function()
--     sendNotification({
--         timeout = 5,
--         title = 'Error',
--         text = 'Animation invite is expired!',
--         type = 'notification',
--     })
-- end)
