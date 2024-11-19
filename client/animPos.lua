local PlacedPed = nil
local PedHeading = nil
local CurrentEmote = nil

local upKey = Config.AnimPos['up']
local downKey = Config.AnimPos['down']
local leftKey = Config.AnimPos['left']
local rightKey = Config.AnimPos['right']

local forwardKey = Config.AnimPos['forward']
local backwardKey = Config.AnimPos['backward']

local rotateLeftKey = Config.AnimPos['rotateLeft']
local rotateRightKey = Config.AnimPos['rotateRight']

local followMouseKey = Config.AnimPos['followMouse']
local doneKey = Config.AnimPos['done']
local cancelKey = Config.AnimPos['cancel']

local followMouse = true

function deletePlacedPed()
    if PlacedPed ~= nil then
        clearProps(PlacedPed)
        DeleteEntity(PlacedPed)
        PlacedPed = nil
    end
end

function donePlacePed()
    if PlacedPed == nil then return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(PlacedPed)
    local heading = GetEntityHeading(PlacedPed)
    print("^1[brinley-animation] ^3Placing Ped^7", coords.x, coords.y, coords.z, heading, 1.0)
    deletePlacedPed()
    TaskGoStraightToCoord(ped, coords.x, coords.y, coords.z, 1.0, -1, heading, 0.0)
    local timeout = 0
    repeat
        Wait(0)
        timeout = timeout + 1
    until GetScriptTaskStatus(ped, 2106541073) == 7 or timeout > 300
    if timeout > 3000 then
        print("^1[brinley-animation] timed out")
    end
    
    print('walked to location', json.encode(CurrentEmote))
    TriggerServerEvent('brinley-animation:server:syncAnimpos', coords, heading)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true)
    SetEntityHeading(ped, heading)
    if CurrentEmote and CurrentEmote.animSettings and CurrentEmote.animSettings.EmoteMoving == false then
        FreezeEntityPosition(ped, true)
    end
    onAnimTriggered(CurrentEmote)
    CurrentEmote = nil
    PlacedPed = nil
    SetScaleformMovieAsNoLongerNeeded()
end

RegisterNetEvent("brinley-animation:client:syncAnimpos", function(target, coords, heading)
    local targetId = GetPlayerFromServerId(target)
    local targetPed = GetPlayerPed(targetId)
    if targetId ~= nil and targetPed ~= nil and PlayerPedId() ~= targetPed then
        SetEntityCoordsNoOffset(targetPed, coords.x, coords.y, coords.z, true, true)
        SetEntityHeading(targetPed, heading)
    end
end)

CreateThread(function()
    Wait(5000)
    local function Button(ControlButton)
        N_0xe83a3e3557a56640(ControlButton)
    end
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(1)
    end
    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for i = 1, #Config.AnimPos['KeyInfos'] do 
        local v = Config.AnimPos['KeyInfos'][i]
        if v then
            BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
            ScaleformMovieMethodAddParamInt(i - 1)
            InstructionalButton(GetControlInstructionalButton(0, v.key, 1), v.label)
            EndScaleformMovieMethod()
        end
    end
    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    while true do
        if PlacedPed ~= nil and DoesEntityExist(PlacedPed) then
            disableControls()
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            local ped = PlayerPedId()
            local hit, coords, entity = RayCastGamePlayCamera(13.0)
            local eCoords = GetEntityCoords(PlacedPed)
            local x = eCoords.x
            local y = eCoords.y
            local z = eCoords.z
            if hit then
                -- local ground, posZ = GetGroundZFor_3dCoord(coords.x + 0.0, coords.y + 0.0, coords.z, 1)
                -- print('coords', coords.x, coords.y, coords.z)
                if followMouse then
                    local srcCoords = GetEntityCoords(ped)
                    -- local dist = #(srcCoords - coords)
                    print(coords.z, srcCoords.z, coords.z - (srcCoords.z - 1.0))
                    if coords.z >= 0.0 and coords.z - (srcCoords.z - 1.0) <= 3.0 then
                        SetEntityCoords(PlacedPed, coords.x, coords.y, coords.z, true, true)
                    else
                        SetEntityCoords(PlacedPed, coords.x, coords.y, (srcCoords.z - 1.0 + 2.0), true, true)
                    end
                    SetEntityHeading(PlacedPed, PedHeading)
                end
            end
            if IsDisabledControlPressed(0, rotateLeftKey) then
                PedHeading = PedHeading + 1.0
                SetEntityHeading(PlacedPed, PedHeading)
            elseif IsDisabledControlPressed(0, rotateRightKey) then
                PedHeading = PedHeading - 1.0
                SetEntityHeading(PlacedPed, PedHeading)
            end

            if IsDisabledControlPressed(0, upKey) then -- scrool wheel up
                local srcCoords = GetEntityCoords(ped)
                print('z', srcCoords.z, z, srcCoords.z - z)
                if z - srcCoords.z  <= 3.0 then
                    z = z + 0.1
                    SetEntityCoordsNoOffset(PlacedPed, x, y, z, true, true)
                end
            elseif IsDisabledControlPressed(0, downKey) then -- scrool wheel down
                z = z - 0.1
                SetEntityCoordsNoOffset(PlacedPed, x, y, z, true, true)
            elseif IsDisabledControlPressed(0, leftKey) then -- sol
                x = x + 0.015
                SetEntityCoordsNoOffset(PlacedPed, x, y, z, true, true)
            elseif IsDisabledControlPressed(0, rightKey) then -- sağ
                x = x - 0.015
                SetEntityCoordsNoOffset(PlacedPed, x, y, z, true, true)
            elseif IsDisabledControlPressed(0, forwardKey) then -- ileri
                y = y + 0.015
                SetEntityCoordsNoOffset(PlacedPed, x, y, z, true, true)
            elseif IsDisabledControlPressed(0, backwardKey) then -- geri
                y = y - 0.015
                SetEntityCoordsNoOffset(PlacedPed, x, y, z, true, true)

            elseif IsDisabledControlJustPressed(0, doneKey) then
                donePlacePed()
            elseif IsDisabledControlJustPressed(0, cancelKey) then
                deletePlacedPed()
            elseif IsDisabledControlJustPressed(0, followMouseKey) then
                followMouse = not followMouse
            end
        else
            Wait(500)
        end
        Wait(0)
    end
end)

function disableControls()
    -- DisableAllControlActions()
    DisableControlAction(0, 44, true)
    for k, v in pairs(Config.AnimPos) do
        if k ~= 'KeyInfos' then
            -- print('disable', k, v)
            DisableControlAction(0, v, true)
        end
    end
end

function createClonePed(anim)
    local ped = PlayerPedId()
    PlacedPed = ClonePed(ped, false, false, false)
    local timeout = 0
    repeat
        Wait(0)
        timeout = timeout + 1
    until PlacedPed ~= nil or timeout > 100
    if PlacedPed == nil or not DoesEntityExist(PlacedPed) then
        PlacedPed = nil
        return print("^1[brinley-animation] ^1Failed to create ped^7")
    end
    CurrentEmote = anim
    PedHeading = GetEntityHeading(ped)
    SetEntityCoords(PlacedPed, GetEntityCoords(ped))
    SetEntityHeading(PlacedPed, GetEntityHeading(ped))
    SetEntityAlpha(PlacedPed, 200, false)
    SetEntityCollision(PlacedPed, false, false)
    SetEntityInvincible(PlacedPed, true)
    FreezeEntityPosition(PlacedPed, true)
    SetBlockingOfNonTemporaryEvents(PlacedPed, true)
    SetPedCanRagdoll(PlacedPed, false)
    print(31, PlacedPed, json.encode(anim))
    if anim then
        return onAnimTriggered(anim, PlacedPed)
    end
end

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }

    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }

    return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }

    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination
    .x, destination.y, destination.z, -1, PlayerPedId(), 0))

    return b, c, e
end

RegisterNUICallback('animPos', function(data, cb)
    print('animPos', json.encode(data))
    if data.animation['category'] == 'expressions' or data.animation['category'] == 'walks' then
        return true
    end
    if PlacedPed ~= nil then
        deletePlacedPed()
    end
    createClonePed(data.animation)
    cb('ok')
end)

function InstructionalButton(controlButton, text)
    ScaleformMovieMethodAddParamPlayerNameString(controlButton)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(text)
    EndTextCommandScaleformString()
end
