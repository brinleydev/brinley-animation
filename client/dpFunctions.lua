PlayerProps = {}
function LoadPropDict(model)
    local model = GetHashKey(model)
    if not IsModelValid(model) then return print("NO PROP FOUND!", model) end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

function AddPropToPlayer(ped, prop1, bone, off1, off2, off3, rot1, rot2, rot3, textureVariation)
    print("Adding Prop", prop1, bone, off1, off2, off3, rot1, rot2, rot3, textureVariation)

    local Player = ped or PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(Player))

    if not HasModelLoaded(prop1) then
        LoadPropDict(prop1)
    end

    prop = CreateObject(GetHashKey(prop1), x, y, z + 0.2, true, true, true)
    if textureVariation ~= nil then
        SetObjectTextureVariation(prop, textureVariation)
    end
    off1 = off1 and off1 + 0.0 or 0.0
    off2 = off2 and off2 + 0.0 or 0.0
    off3 = off3 and off3 + 0.0 or 0.0
    rot1 = rot1 and rot1 + 0.0 or 0.0
    rot2 = rot2 and rot2 + 0.0 or 0.0
    rot3 = rot3 and rot3 + 0.0 or 0.0
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true,
        false, true, 1, true)
    table.insert(PlayerProps, prop)
    PlayerHasProp = true
    SetModelAsNoLongerNeeded(prop1)
    return true
end

function DestroyAllProps()
    for _, v in pairs(PlayerProps) do
        DeleteEntity(v)
    end
    PlayerHasProp = false
    print("Destroyed Props")
end

function RunAnimationThread()
    if AnimationThreadStatus then return end
    AnimationThreadStatus = true
    CreateThread(function()
        local sleep
        while AnimationThreadStatus and (playingEmote or PtfxPrompt) do
            sleep = 500

            if playingEmote then
                sleep = 0
                if IsPedShooting(PlayerPedId()) then
                    onEmoteCancel()
                end
            end

            if PtfxPrompt then
                sleep = 0
                if not PtfxNotif then
                    Notify(PtfxInfo)
                    PtfxNotif = true
                end
                if IsControlPressed(0, 47) then
                    PtfxStart()
                    Wait(PtfxWait)
                    if PtfxCanHold then
                        while IsControlPressed(0, 47) and playingEmote and AnimationThreadStatus do
                            Wait(5)
                        end
                    end
                    PtfxStop()
                end
            end

            Wait(sleep)
        end
    end)
end

--- shared part


local isRequestAnim = false
local requestedEmote = ''
local targetPlayerId = ''

-- RegisterNetEvent("SyncPlayEmote")
-- AddEventHandler("SyncPlayEmote", function(emote, player)
--     EmoteCancel()
--     Wait(300)
--     targetPlayerId = player
--     local anim = getAnim(emote)
--     if not anim then return end
--     if anim.animSettings and anim.animSettings.Attachto then
--         local targetEmote = anim.sharedAnim
--         local targetAnim = getAnim(targetEmote)
--         if not targetEmote or not targetAnim or not targetAnim.animSettings or
--             not targetAnim.animSettings.Attachto then
--             local plyServerId = GetPlayerFromServerId(player)
--             local ply = PlayerPedId()
--             local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())
--             local bone = anim.animSettings.bone or -1 -- No bone
--             local xPos = anim.animSettings.xPos or 0.0
--             local yPos = anim.animSettings.yPos or 0.0
--             local zPos = anim.animSettings.zPos or 0.0
--             local xRot = anim.animSettings.xRot or 0.0
--             local yRot = anim.animSettings.yRot or 0.0
--             local zRot = anim.animSettings.zRot or 0.0
--             AttachEntityToEntity(ply, pedInFront, GetPedBoneIndex(pedInFront, bone), xPos, yPos, zPos, xRot, yRot,
--                 zRot, false, false, false, true, 1, true)
--         end
--     end
--     return OnEmotePlay(anim)
-- end)

-- RegisterNetEvent("SyncPlayEmoteSource")
-- AddEventHandler("SyncPlayEmoteSource", function(emote, player)
--     local ply = PlayerPedId()
--     local plyServerId = GetPlayerFromServerId(player)
--     local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())

--     local SyncOffsetFront = 1.0
--     local SyncOffsetSide = 0.0
--     local SyncOffsetHeight = 0.0
--     local SyncOffsetHeading = 180.1

--     local anim = getAnim(emote)
--     print(86, json.encode(anim), emote)
--     if not anim then return print(76) end
--     local animSettings = anim.animSettings
--     if animSettings then
--         if animSettings.SyncOffsetFront then
--             SyncOffsetFront = animSettings.SyncOffsetFront + 0.0
--         end
--         if animSettings.SyncOffsetSide then
--             SyncOffsetSide = animSettings.SyncOffsetSide + 0.0
--         end
--         if animSettings.SyncOffsetHeight then
--             SyncOffsetHeight = animSettings.SyncOffsetHeight + 0.0
--         end
--         if animSettings.SyncOffsetHeading then
--             SyncOffsetHeading = animSettings.SyncOffsetHeading + 0.0
--         end

--         if (animSettings.Attachto) then
--             local bone = animSettings.bone or -1 -- No bone
--             local xPos = animSettings.xPos or 0.0
--             local yPos = animSettings.yPos or 0.0
--             local zPos = animSettings.zPos or 0.0
--             local xRot = animSettings.xRot or 0.0
--             local yRot = animSettings.yRot or 0.0
--             local zRot = animSettings.zRot or 0.0
--             AttachEntityToEntity(ply, pedInFront, GetPedBoneIndex(pedInFront, bone), xPos, yPos, zPos, xRot, yRot, zRot,
--                 false, false, false, true, 1, true)
--         end
--     end
--     local coords = GetOffsetFromEntityInWorldCoords(pedInFront, SyncOffsetSide, SyncOffsetFront, SyncOffsetHeight)
--     local heading = GetEntityHeading(pedInFront)
--     SetEntityHeading(ply, heading - SyncOffsetHeading)
--     SetEntityCoordsNoOffset(ply, coords.x, coords.y, coords.z, 0)
--     EmoteCancel()
--     Wait(300)
--     targetPlayerId = player
--     OnEmotePlay(anim)
--     return
-- end)

-- RegisterNetEvent("SyncCancelEmote")
-- AddEventHandler("SyncCancelEmote", function(player)
--     if targetPlayerId and targetPlayerId == player then
--         targetPlayerId = nil
--         EmoteCancel()
--     end
-- end)

-- RegisterNetEvent("ClientEmoteRequestReceive")
-- AddEventHandler("ClientEmoteRequestReceive", function(anim, etype)
--     isRequestAnim = true
--     requestedEmote = anim.animName
--     if not anim then return print(66) end
--     PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
--     SimpleNotify(Config.Languages[lang]['doyouwanna'] .. anim.label .. "~w~)")
-- end)

Citizen.CreateThread(function()
    local acceptBind = Config.AcceptBind
    local refuseBind = Config.RefuseBind
    while true do
        Wait(0)

        if isRequestAnim then
            if (IsControlJustPressed(0, acceptBind)) and isRequestAnim then --N
                PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
                TriggerServerEvent("brinley-animation:server:acceptAnimationInvite", isRequestAnim, requestedEmote)
                isRequestAnim = false
            elseif IsControlJustPressed(0, refuseBind) and isRequestAnim then --M
                PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
                print('refuseemote')
                isRequestAnim = false
            end
        else
            Wait(500)
        end
    end
end)

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index, value in ipairs(players) do
        local target = GetPlayerPed(value)
        if (target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"],
                plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if (closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end
function GetPlayers()
    local players = {}
    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

RegisterNUICallback('sendAnimationInvite', function(data, cb)
    print('sendAnimationInvite', json.encode(data))

    local closestPlayer, closestDistance = GetClosestPlayer()
    if closestPlayer == -1 or closestDistance == -1 or closestDistance > 3.0 then
        return sendNotification({
            timeout = 5,
            title = Lang('notification_error'),
            text = Lang('no_player_nearby'),
            type = 'notification',
        })
    end

    local targetId = GetPlayerServerId(closestPlayer)
    -- local targetId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('brinley-animation:server:sendAnimationInvite', targetId, data)
    cb('ok')
end)

local function getAnimByName(id)
    for k, v in pairs(Config.AllAnimations) do
        if v.id == id then
            return v
        end
    end
    return false
end

RegisterNetEvent('brinley-animation:client:getAnimationInvite', function(animData, senderId)
    PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
    isRequestAnim = senderId
    SetTimeout(5500, function()
        isRequestAnim = false
    end)
    print(1, json.encode(animData))
    local targetAnim = animData.targetAnim and getAnimByName(animData.targetAnim)

    -- Eğer animasyonu bulamazsa aynı animasyonu yaptırtıyorum niye bilmiyorum.
    if not targetAnim then
        targetAnim = animData
    end

    requestedEmote = targetAnim
    print(2, json.encode(targetAnim))
    sendNotification({
        timeout = 5,
        title = Lang('new_invite'),
        text = Lang('invited_animation'):format(targetAnim.label),
        description = Lang('invite_question'),
        type = 'invite',
        anim = animData
    })
end)


RegisterNetEvent('brinley-animation:client:playSyncedAnim', function(emote, player)
    onEmoteCancel()
    Wait(300)
    targetPlayerId = player

    local anim = getAnimByName(emote.id)
    if not anim then return end
    if anim.animSettings and anim.animSettings.Attachto then
        local targetEmote = anim.targetAnim
        local targetAnim = getAnimByName(targetEmote and targetEmote.id)
        if not targetEmote or not targetAnim or not targetAnim.animSettings or
            not targetAnim.animSettings.Attachto then
            print('settings 321', json.encode(AnimationOptions))

            local plyServerId = GetPlayerFromServerId(player)
            local ply = PlayerPedId()
            if not plyServerId or plyServerId == 0 then
                return print('brinley-animation:client:playSyncedAnim: Player not found!', player, plyServerId, ply)
            end
            local pedInFront = GetPlayerPed(plyServerId)
            if not pedInFront or not DoesEntityExist(pedInFront) then
                return print('brinley-animation:client:playSyncedAnim: Player not found!', player, plyServerId, ply)
            end
            local bone = anim.animSettings.bone or -1 -- No bone
            local xPos = anim.animSettings.xPos or 0.0
            local yPos = anim.animSettings.yPos or 0.0
            local zPos = anim.animSettings.zPos or 0.0
            local xRot = anim.animSettings.xRot or 0.0
            local yRot = anim.animSettings.yRot or 0.0
            local zRot = anim.animSettings.zRot or 0.0
            AttachEntityToEntity(ply, pedInFront, GetPedBoneIndex(pedInFront, bone), xPos, yPos, zPos, xRot, yRot,
                zRot, false, false, false, true, 1, true)
        end
    end

    return onAnimTriggered(anim)
end)

RegisterNetEvent('brinley-animation:client:playSyncedAnimSource', function(emote, player)
    print('brinley-animation:client:playSyncedAnimSource', json.encode(emote))
    local ply = PlayerPedId()
    local plyServerId = GetPlayerFromServerId(player)
    if not plyServerId or plyServerId == 0 then
        return print('brinley-animation:client:playSyncedAnimSource: Player not found!', player, plyServerId, ply)
    end
    local pedInFront = GetPlayerPed(plyServerId)
    if not pedInFront or not DoesEntityExist(pedInFront) then
        return print('brinley-animation:client:playSyncedAnimSource: Player not found!', player, plyServerId, ply)
    end

    local SyncOffsetFront = 1.0
    local SyncOffsetSide = 0.0
    local SyncOffsetHeight = 0.0
    local SyncOffsetHeading = 180.1

    local anim = getAnimByName(emote.id)
    if not anim then return end

    local AnimationOptions = anim.animSettings
    print('settings 123', json.encode(AnimationOptions))
    if AnimationOptions then
        if AnimationOptions.SyncOffsetFront then
            SyncOffsetFront = AnimationOptions.SyncOffsetFront + 0.0
        end
        if AnimationOptions.SyncOffsetSide then
            SyncOffsetSide = AnimationOptions.SyncOffsetSide + 0.0
        end
        if AnimationOptions.SyncOffsetHeight then
            SyncOffsetHeight = AnimationOptions.SyncOffsetHeight + 0.0
        end
        if AnimationOptions.SyncOffsetHeading then
            SyncOffsetHeading = AnimationOptions.SyncOffsetHeading + 0.0
        end

        -- There is a priority to the source attached, if it is not set, it will use the target
        if (AnimationOptions.Attachto) then
            local bone = AnimationOptions.bone or -1 -- No bone
            local xPos = AnimationOptions.xPos or 0.0
            local yPos = AnimationOptions.yPos or 0.0
            local zPos = AnimationOptions.zPos or 0.0
            local xRot = AnimationOptions.xRot or 0.0
            local yRot = AnimationOptions.yRot or 0.0
            local zRot = AnimationOptions.zRot or 0.0
            AttachEntityToEntity(ply, pedInFront, GetPedBoneIndex(pedInFront, bone), xPos, yPos, zPos, xRot, yRot, zRot,
                false, false, false, true, 1, true)
        end
    end
    local coords = GetOffsetFromEntityInWorldCoords(pedInFront, SyncOffsetSide, SyncOffsetFront, SyncOffsetHeight)
    local heading = GetEntityHeading(pedInFront)
    SetEntityHeading(ply, heading - SyncOffsetHeading)
    SetEntityCoordsNoOffset(ply, coords.x, coords.y, coords.z, 0)
    onEmoteCancel()
    Wait(300)
    targetPlayerId = player
    return onAnimTriggered(anim)
end)
